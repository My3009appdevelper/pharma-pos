import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_farmacia/core/models/cliente_model.dart';
import 'package:pos_farmacia/core/providers/cliente_provider.dart';
import 'package:pos_farmacia/core/services/cliente_service.dart';
import 'package:pos_farmacia/features/clientes/cliente_form_page.dart';
import 'package:pos_farmacia/features/clientes/clientes_data_table.dart';
import 'package:pos_farmacia/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({Key? key}) : super(key: key);

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );
    clienteProvider.cargarClientes();
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = Provider.of<ClienteProvider>(context);
    final clientesFiltrados = clienteProvider.clientes.where((cliente) {
      final filtroLower = _filtro.toLowerCase();
      return cliente.nombreCompleto.toLowerCase().contains(filtroLower) ||
          (cliente.telefono?.toLowerCase().contains(filtroLower) ?? false) ||
          (cliente.email?.toLowerCase().contains(filtroLower) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Importar CSV',
            onPressed: _importarClientesCSV,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar CSV',
            onPressed: _exportarClientesCSV,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Agregar Cliente',
            onPressed: _mostrarFormularioCliente,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar cliente por nombre, teléfono o correo',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _filtro = value;
                });
              },
            ),
          ),
          Expanded(child: ClientesDataTable(clientes: clientesFiltrados)),
        ],
      ),
    );
  }

  Future<void> _importarClientesCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final provider = Provider.of<ClienteProvider>(context, listen: false);
      final service = ClienteService();

      List<List<dynamic>> fields;

      try {
        final input = File(path).openRead();
        fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter(eol: '\n'))
            .toList();
      } catch (e) {
        debugPrint('❌ Error al leer o parsear el CSV: $e');
        if (context.mounted) {
          SnackBarUtils.show(
            context,
            message:
                '⚠️ No se pudo leer el archivo CSV.\nAsegúrate de que esté en formato UTF-8 y con la estructura correcta.',
            type: SnackBarType.error,
          );
        }
        return;
      }

      int agregados = 0;
      int duplicados = 0;

      for (var row in fields.skip(1)) {
        try {
          final uuid = row[0].toString().trim();
          final existente = await service.obtenerClientePorUuid(uuid);

          if (existente != null) {
            debugPrint('⚠️ Cliente duplicado con UUID: $uuid');
            duplicados++;
            continue;
          }

          final cliente = ClienteModel(
            uuidCliente: uuid,
            nombreCompleto: row[1].toString(),
            apellido: row[2].toString(),
            telefono: row[3].toString(),
            email: row[4].toString(),
            direccion: row[5].toString(),
            ciudad: row[6].toString(),
            estado: row[7].toString(),
            codigoPostal: row[8].toString(),
            creadoEn: DateTime.tryParse(row[9].toString()) ?? DateTime.now(),
            modificadoEn:
                DateTime.tryParse(row[10].toString()) ?? DateTime.now(),
            rfc: row[11].toString(),
            razonSocial: row[12].toString(),
            usoCfdi: row[13].toString(),
            regimenFiscal: row[14].toString(),
            puntosAcumulados: int.tryParse(row[15].toString()) ?? 0,
          );

          await provider.agregarCliente(cliente);
          agregados++;
        } catch (e) {
          debugPrint('❌ Error importando fila: $e\\n$row');
        }
      }

      await provider.cargarClientes();

      SnackBarUtils.show(
        context,
        message:
            '✅ Importación completada.\nClientes agregados: $agregados\nDuplicados ignorados: $duplicados',
        type: SnackBarType.success,
      );
    }
  }

  Future<void> _exportarClientesCSV() async {
    final clientes = Provider.of<ClienteProvider>(
      context,
      listen: false,
    ).clientes;

    final List<List<String>> rows = [
      [
        'uuid_cliente',
        'nombreCompleto',
        'apellido',
        'telefono',
        'email',
        'direccion',
        'ciudad',
        'estado',
        'codigo_postal',
        'creadoEn',
        'modificadoEn',
        'rfc',
        'razonSocial',
        'usoCfdi',
        'regimenFiscal',
        'puntosAcumulados',
      ],
      ...clientes.map(
        (c) => [
          c.uuidCliente,
          c.nombreCompleto,
          c.apellido ?? '',
          c.telefono ?? '',
          c.email ?? '',
          c.direccion ?? '',
          c.ciudad ?? '',
          c.estado ?? '',
          c.codigoPostal ?? '',
          c.creadoEn.toIso8601String(),
          c.modificadoEn.toIso8601String(),
          c.rfc ?? '',
          c.razonSocial ?? '',
          c.usoCfdi ?? '',
          c.regimenFiscal ?? '',
          c.puntosAcumulados.toString(),
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/clientes_exportados.csv');

    await file.writeAsString(csv, encoding: const Utf8Codec());

    SnackBarUtils.show(
      context,
      message: '✅ Clientes exportados a:\n${file.path}',
      type: SnackBarType.success,
    );
  }

  void _mostrarFormularioCliente() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ClienteFormPage(),
      ),
    );
  }
}
