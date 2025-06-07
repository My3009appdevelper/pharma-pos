import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_farmacia/core/models/sucursal_model.dart';
import 'package:pos_farmacia/core/providers/sucursal_provider.dart';
import 'package:pos_farmacia/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class SucursalPage extends StatefulWidget {
  const SucursalPage({super.key});

  @override
  State<SucursalPage> createState() => _SucursalPageState();
}

class _SucursalPageState extends State<SucursalPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SucursalProvider>(context, listen: false).cargarSucursales();
    });
  }

  Future<void> _importarCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final input = File(result.files.single.path!).openRead();
      final fields = await input
          .transform(latin1.decoder)
          .transform(const CsvToListConverter())
          .toList();

      final provider = Provider.of<SucursalProvider>(context, listen: false);
      for (var row in fields.skip(1)) {
        if (row.length >= 5) {
          final sucursal = SucursalModel(
            nombre: row[0].toString(),
            direccion: row[1].toString(),
            telefono: row[2].toString(),
            ciudad: row[3].toString(),
            estado: row[4].toString(),
          );
          await provider.agregarSucursal(sucursal);
          print('Sucursal añadida: ${sucursal.nombre}');
        }
      }

      // 🔥 Refresca la lista después de importar
      await provider.cargarSucursales();

      SnackBarUtils.show(
        context,
        message: 'Sucursales importadas exitosamente',
        type: SnackBarType.success,
      );
    }
  }

  Future<void> _exportarCSV() async {
    final sucursales = Provider.of<SucursalProvider>(
      context,
      listen: false,
    ).sucursales;

    final rows = [
      ['id', 'nombre', 'direccion', 'ciudad', 'estado', 'telefono'],
      ...sucursales.map(
        (s) => [
          s.id?.toString() ?? '',
          s.nombre,
          s.direccion,
          s.ciudad,
          s.estado,
          s.telefono,
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sucursales_exportadas.csv');
    await file.writeAsString(csv);

    SnackBarUtils.show(
      context,
      message: 'Exportado a: ${file.path}',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sucursales = Provider.of<SucursalProvider>(context).sucursales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sucursales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Importar CSV',
            onPressed: _importarCSV,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar CSV',
            onPressed: _exportarCSV,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar sucursal',
            onPressed: () {
              // TODO: agregar formulario de sucursal manual
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: sucursales.isEmpty
            ? const Center(child: Text('No hay sucursales registradas.'))
            : DataTable(
                columns: const [
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Dirección')),
                  DataColumn(label: Text('Teléfono')),
                  DataColumn(label: Text('Ciudad')),
                  DataColumn(label: Text('Estado')),
                ],
                rows: sucursales.map((s) {
                  return DataRow(
                    cells: [
                      DataCell(Text(s.nombre)),
                      DataCell(Text(s.direccion)),
                      DataCell(Text(s.telefono)),
                      DataCell(Text(s.ciudad)),
                      DataCell(Text(s.estado)),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }
}
