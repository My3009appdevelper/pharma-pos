import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_farmacia/features/stock/lotes/logic/lote_product_provider.dart';
import 'package:pos_farmacia/features/stock/lotes/logic/lote_producto_model.dart';
import 'package:pos_farmacia/features/stock/lotes/logic/lote_producto_service.dart';
import 'package:provider/provider.dart';

class LotesPage extends StatefulWidget {
  final int? idSucursalActual;
  const LotesPage({super.key, required this.idSucursalActual});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  @override
  void initState() {
    super.initState();
    if (widget.idSucursalActual != null) {
      Provider.of<LoteProductoProvider>(
        context,
        listen: false,
      ).cargarDesdeBD(); // Opcional: podrías cargar por sucursal si lo implementas
    }
  }

  Future<void> _importarLotesCSV() async {
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

      for (var row in rows.skip(1)) {
        try {
          final lote = LoteProductoModel(
            idProducto: int.parse(row[1].toString()),
            idSucursal: int.parse(row[2].toString()),
            lote: row[3].toString(),
            fechaEntrada: DateTime.parse(row[4].toString()),
            fechaCaducidad: DateTime.parse(row[5].toString()),
            stock: int.parse(row[6].toString()),
            precioCompra: double.parse(row[7].toString()),
            precioVenta: double.parse(row[8].toString()),
            activo: row[9].toString() == '1',
          );
          await LoteProductoService.insertar(lote);
        } catch (e) {
          debugPrint('❌ Error importando lote: $e\n$row');
        }
      }

      await Provider.of<LoteProductoProvider>(
        context,
        listen: false,
      ).cargarDesdeBD();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lotes importados correctamente')),
      );
    }
  }

  Future<void> _exportarLotesCSV() async {
    final lotes = Provider.of<LoteProductoProvider>(
      context,
      listen: false,
    ).lotes;

    final rows = [
      [
        'id',
        'id_producto',
        'id_sucursal',
        'lote',
        'fecha_entrada',
        'fecha_caducidad',
        'stock',
        'precio_compra',
        'precio_venta',
        'activo',
      ],
      ...lotes.map(
        (l) => [
          l.id?.toString() ?? '',
          l.idProducto,
          l.idSucursal,
          l.lote,
          l.fechaEntrada.toIso8601String(),
          l.fechaCaducidad.toIso8601String(),
          l.stock,
          l.precioCompra,
          l.precioVenta,
          l.activo ? '1' : '0',
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/lotes_exportados.csv');
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lotes exportados en: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotesProvider = Provider.of<LoteProductoProvider>(context);
    final lotesFiltrados = lotesProvider.lotes.where((lote) {
      return widget.idSucursalActual == null ||
          lote.idSucursal == widget.idSucursalActual;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotes por Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Importar CSV de Lotes',
            onPressed: _importarLotesCSV,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar CSV de Lotes',
            onPressed: _exportarLotesCSV,
          ),
        ],
      ),
      body: lotesFiltrados.isEmpty
          ? const Center(child: Text('No hay lotes registrados'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('Lote')),
                  DataColumn(label: Text('Entrada')),
                  DataColumn(label: Text('Caducidad')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('Precio Compra')),
                  DataColumn(label: Text('Precio Venta')),
                ],
                rows: lotesFiltrados.map((lote) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text('${lote.idProducto}'),
                      ), // Puedes reemplazar con nombre del producto
                      DataCell(Text(lote.lote)),
                      DataCell(
                        Text(
                          '${lote.fechaEntrada.day}/${lote.fechaEntrada.month}/${lote.fechaEntrada.year}',
                        ),
                      ),
                      DataCell(
                        Text(
                          '${lote.fechaCaducidad.day}/${lote.fechaCaducidad.month}/${lote.fechaCaducidad.year}',
                        ),
                      ),
                      DataCell(Text(lote.stock.toString())),
                      DataCell(
                        Text('\$${lote.precioCompra.toStringAsFixed(2)}'),
                      ),
                      DataCell(
                        Text('\$${lote.precioVenta.toStringAsFixed(2)}'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
