import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_farmacia/core/models/inventario_sucursal_model.dart';
import 'package:pos_farmacia/core/services_providers/inventario_sucursal_provider.dart';
import 'package:pos_farmacia/core/services_providers/inventario_provider.dart';
import 'package:pos_farmacia/core/models/product_model.dart';
import 'package:pos_farmacia/core/services_providers/inventario_sucursal_service.dart';
import 'package:pos_farmacia/core/services_providers/user_provider.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/agregar_producto_sucursal_page.dart';
import 'package:pos_farmacia/widgets/inventario_sucursal_table.dart';
import 'package:pos_farmacia/widgets/navigation_rail_categories.dart';
import 'package:provider/provider.dart';

class InventarioSucursalPage extends StatefulWidget {
  final int? idSucursal;
  const InventarioSucursalPage({super.key, required this.idSucursal});

  @override
  State<InventarioSucursalPage> createState() => _InventarioSucursalPageState();
}

class _InventarioSucursalPageState extends State<InventarioSucursalPage> {
  String _busqueda = '';
  String _categoriaSeleccionada = 'Todas';

  DateTime? parseFechaDDMMAAAA(String? input) {
    if (input == null || input.trim().isEmpty) return null;

    final partes = input.trim().split('/');
    if (partes.length != 3) return null;

    try {
      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final anio = int.parse(partes[2]);
      return DateTime(anio, mes, dia);
    } catch (_) {
      return null;
    }
  }

  Future<void> _importarInventarioSucursalCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final input = File(path).openRead();
      final rows = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      final provider = Provider.of<InventarioSucursalProvider>(
        context,
        listen: false,
      );

      for (var row in rows.skip(1)) {
        final inv = InventarioSucursalModel(
          idProducto: int.parse(row[0].toString()),
          idSucursal: int.parse(row[1].toString()),
          stock: int.parse(row[2].toString()),
          stockMinimo: int.tryParse(row[3].toString()) ?? 0,
          lote: row[4]?.toString(),
          caducidad: parseFechaDDMMAAAA(row[5]?.toString()),
          fechaEntrada: parseFechaDDMMAAAA(row[6]?.toString()),
          precioCompra: double.tryParse(row[7].toString()),
          precioVenta: double.tryParse(row[8].toString()),
          activo: row.length > 10 ? row[9].toString() == '1' : true,
          ubicacionFisica: row.length > 10 ? row[10].toString() : '',
          presentacion: row.length > 10 ? row[11].toString() : '',
        );
        await InventarioSucursalService.insertar(inv);
      }

      await provider.cargarDesdeBD();

      final productosUnicos = rows
          .skip(1)
          .map((row) => int.parse(row[0].toString()))
          .toSet();

      for (final idProducto in productosUnicos) {
        await InventarioSucursalService.actualizarStockGlobal(idProducto);
      }

      await Provider.of<InventarioProvider>(
        context,
        listen: false,
      ).cargarDesdeBD();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventario por sucursal importado')),
      );
    }
  }

  Future<void> _exportarInventarioSucursalCSV() async {
    final inventarioSucursalProvider = Provider.of<InventarioSucursalProvider>(
      context,
      listen: false,
    );

    final registros = inventarioSucursalProvider.inventario;

    final rows = [
      [
        'id',
        'id_producto',
        'id_sucursal',
        'presentacion',
        'stock',
        'stock_minimo',
        'lote',
        'caducidad',
      ],
      ...registros.map(
        (r) => [
          r.id?.toString() ?? '',
          r.idProducto,
          r.idSucursal,
          r.presentacion,
          r.stock,
          r.stockMinimo,
          r.lote ?? '',
          r.caducidad?.toIso8601String() ?? '',
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/inventario_por_sucursal_exportado.csv');
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inventario exportado a: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventarioProvider = Provider.of<InventarioProvider>(context);
    final inventarioSucursalProvider = Provider.of<InventarioSucursalProvider>(
      context,
    );

    final categoriasUnicas =
        inventarioProvider.productos
            .expand((p) => p.categorias)
            .toSet()
            .toList()
          ..sort();

    final productosFiltrados = inventarioProvider.productos.where((p) {
      final coincideBusqueda = p.nombre.toLowerCase().contains(
        _busqueda.toLowerCase(),
      );
      final coincideCategoria =
          _categoriaSeleccionada == 'Todas' ||
          p.categorias.contains(_categoriaSeleccionada);

      final enSucursal =
          widget.idSucursal == null ||
          inventarioSucursalProvider.obtenerPorProductoYSucursal(
                p.id ?? 0,
                widget.idSucursal!,
              ) !=
              null;
      return coincideBusqueda && coincideCategoria && enSucursal;
    }).toList();

    final registrosSucursal = inventarioSucursalProvider.inventario.where((r) {
      return (widget.idSucursal == null || r.idSucursal == widget.idSucursal) &&
          productosFiltrados.any((p) => p.id == r.idProducto);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos por Lote'),
        actions: [
          if (Provider.of<UserProvider>(
                context,
                listen: false,
              ).usuarioActual?.rol ==
              'admin') ...[
            IconButton(
              icon: const Icon(Icons.file_upload_rounded),
              tooltip: 'Importar CSV por Sucursal',
              onPressed: _importarInventarioSucursalCSV,
            ),
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Exportar CSV por Sucursal',
              onPressed: _exportarInventarioSucursalCSV,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Agregar producto por Sucursal',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const AgregarProductoSucursalPage(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Row(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRailCategorias(
                      categoriaSeleccionada: _categoriaSeleccionada,
                      onCategoriaSeleccionada: (nombre) =>
                          setState(() => _categoriaSeleccionada = nombre),
                      categorias: categoriasUnicas,
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (valor) => setState(() => _busqueda = valor),
                  ),
                  const SizedBox(height: 16),
                  registrosSucursal.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron productos en esta sucursal',
                          ),
                        )
                      : InventarioSucursalDataTable(
                          inventarioSucursal: registrosSucursal,
                          idSucursalActual: widget.idSucursal ?? null,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
