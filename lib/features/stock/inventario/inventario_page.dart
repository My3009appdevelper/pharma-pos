import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/inventario/agregar_producto_page.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_provider.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/logic/inventario_sucursal_provider.dart';
import 'package:pos_farmacia/features/users/logic/user_provider.dart';
import 'package:pos_farmacia/widgets/navigation_rail_categories.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/product_model.dart';
import 'package:pos_farmacia/widgets/product_data_table.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_service.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/logic/inventario_sucursal_model.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/logic/inventario_sucursal_service.dart';

import '../inventario por sucursal/agregar_producto_sucursal_page.dart';

final List<Categoria> categoriasFarmacia = [
  Categoria(nombre: 'Medicamentos', icono: Icons.medication),
  Categoria(nombre: 'Cuidado Personal', icono: Icons.spa),
  Categoria(nombre: 'Bebés y Maternidad', icono: Icons.child_friendly),
  Categoria(nombre: 'Hogar y Limpieza', icono: Icons.cleaning_services),
  Categoria(nombre: 'Alimentos y Bebidas', icono: Icons.fastfood),
  Categoria(nombre: 'Otros', icono: Icons.category),
];

class InventarioPage extends StatefulWidget {
  final int? idSucursalActual;
  const InventarioPage({super.key, required this.idSucursalActual});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  String _busqueda = '';
  String _categoriaSeleccionada = 'Todas';

  Future<void> _importarCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final input = File(path).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      final provider = Provider.of<InventarioProvider>(context, listen: false);

      for (var row in fields.skip(1)) {
        try {
          final historialPrecios = row[27]
              .toString()
              .split('|')
              .where((e) => e.contains(':'))
              .map((e) {
                final parts = e.split(':');
                return PrecioHistorico(
                  fecha: DateTime.parse(parts[0]),
                  precio: double.tryParse(parts[1]) ?? 0,
                );
              })
              .toList();

          final historialCostos = row[28]
              .toString()
              .split('|')
              .where((e) => e.contains(':'))
              .map((e) {
                final parts = e.split(':');
                return CostoHistorico(
                  fecha: DateTime.parse(parts[0]),
                  costo: double.tryParse(parts[1]) ?? 0,
                );
              })
              .toList();

          final producto = ProductoModel(
            id: int.tryParse(row[0].toString()),
            codigo: row[1].toString(),
            nombre: row[2].toString(),
            descripcion: row[3].toString(),
            categorias: row[4]
                .toString()
                .replaceAll('[', '')
                .replaceAll(']', '')
                .replaceAll('"', '')
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),

            unidad: row[5].toString(),
            precio: double.tryParse(row[6].toString()) ?? 0,
            costo: double.tryParse(row[7].toString()) ?? 0,
            stock: int.tryParse(row[8].toString()) ?? 0,
            stockMinimo: int.tryParse(row[9].toString()) ?? 0,
            lote: row[10].toString(),
            caducidad: row[11].toString().isNotEmpty
                ? DateTime.tryParse(row[11])
                : null,
            imagenUrl: row[12].toString(),
            temperaturaMinima: double.tryParse(row[13].toString()),
            temperaturaMaxima: double.tryParse(row[14].toString()),
            humedadMaxima: double.tryParse(row[15].toString()),
            requiereRefrigeracion: row[16].toString() == '1',
            requiereReceta: row[17].toString() == '1',
            cantidadVendidaHistorico: int.tryParse(row[18].toString()) ?? 0,
            ultimaVenta: row[19].toString().isNotEmpty
                ? DateTime.tryParse(row[19])
                : null,
            vecesEnPromocion: int.tryParse(row[20].toString()) ?? 0,
            codigoSAT: row[21].toString(),
            presentacion: row[22].toString(),
            ubicacionFisica: row[23].toString(),
            productosRelacionados: row[24].toString().split(','),
            compradosJuntoA: row[25].toString().split(','),
            historialPrecios: historialPrecios,
            historialCostos: historialCostos,
            activo: row.length > 29 ? row[29].toString() == '1' : true,
          );

          await InventarioService.insertarProducto(producto);
        } catch (e) {
          debugPrint('❌ Error importando fila: $e\n$row');
        }
      }

      await provider.cargarDesdeBD();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Importación completada')));
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
          caducidad: DateTime.tryParse(row[5]?.toString() ?? ''),
          fechaEntrada: DateTime.tryParse(row[6]?.toString() ?? ''),
          precioCompra: double.tryParse(row[7].toString()),
          precioVenta: double.tryParse(row[8].toString()),
          activo: row.length > 10 ? row[9].toString() == '1' : true,
          ubicacionFisica: row.length > 10 ? row[10].toString() : '',
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

  Future<void> _exportarCSV() async {
    final productos = Provider.of<InventarioProvider>(
      context,
      listen: false,
    ).productos;

    final List<List<String>> rows = [
      [
        'id',
        'codigo',
        'nombre',
        'descripcion',
        'categorias',
        'unidad',
        'precio',
        'costo',
        'stock',
        'stock_minimo',
        'lote',
        'caducidad',
        'imagen_url',
        'temperatura_minima',
        'temperatura_maxima',
        'humedad_maxima',
        'requiere_refrigeracion',
        'requiere_receta',
        'cantidad_vendida_historico',
        'ultima_venta',
        'veces_en_promocion',
        'codigo_sat',
        'presentacion',
        'ubicacion_fisica',
        'productos_relacionados',
        'comprados_junto_a',
        'historial_precios',
        'historial_costos',
        'activo',
      ],
      ...productos.map(
        (p) => [
          p.id?.toString() ?? '',
          p.codigo,
          p.nombre,
          p.descripcion,
          p.categorias.join(','),
          p.unidad,
          p.precio.toString(),
          p.costo.toString(),
          p.stock.toString(),
          p.stockMinimo.toString(),
          p.lote ?? '',
          p.caducidad?.toIso8601String() ?? '',
          p.imagenUrl ?? '',
          p.temperaturaMinima?.toString() ?? '',
          p.temperaturaMaxima?.toString() ?? '',
          p.humedadMaxima?.toString() ?? '',
          p.requiereRefrigeracion ? '1' : '0',
          p.requiereReceta ? '1' : '0',
          p.cantidadVendidaHistorico.toString(),
          p.ultimaVenta?.toIso8601String() ?? '',
          p.vecesEnPromocion.toString(),
          p.codigoSAT ?? '',
          p.presentacion ?? '',
          p.ubicacionFisica ?? '',
          p.productosRelacionados.join(','),
          p.compradosJuntoA.join(','),
          // Historial como lista de "fecha:valor"
          p.historialPrecios
              .map((e) => '${e.fecha.toIso8601String()}:${e.precio}')
              .join('|'),
          p.historialCostos
              .map((e) => '${e.fecha.toIso8601String()}:${e.costo}')
              .join('|'),
          p.activo ? '1' : '0',
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/productos_completos_exportados.csv');
    await file.writeAsString(csv);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Exportado a: ${file.path}')));
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
    final inventario = Provider.of<InventarioProvider>(context);
    final inventarioSucursalProvider = Provider.of<InventarioSucursalProvider>(
      context,
    );

    final categoriasUnicas =
        inventario.productos.expand((p) => p.categorias).toSet().toList()
          ..sort();

    final productosFiltrados = inventario.productos.where((p) {
      final coincideBusqueda = p.nombre.toLowerCase().contains(
        _busqueda.toLowerCase(),
      );
      final coincideCategoria =
          _categoriaSeleccionada == 'Todas' ||
          p.categorias.contains(_categoriaSeleccionada);

      final enSucursal =
          widget.idSucursalActual == null ||
          inventarioSucursalProvider.obtenerPorProductoYSucursal(
                p.id ?? 0,
                widget.idSucursalActual!,
              ) !=
              null;
      return coincideBusqueda && coincideCategoria && enSucursal;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos por Categoría'),
        actions: [
          if (Provider.of<UserProvider>(
                context,
                listen: false,
              ).usuarioActual?.rol ==
              'admin') ...[
            IconButton(
              icon: const Icon(Icons.file_upload),
              tooltip: 'Importar CSV',
              onPressed: _importarCSV,
            ),
            IconButton(
              icon: const Icon(Icons.file_upload_rounded),
              tooltip: 'Importar CSV por Sucursal',
              onPressed: _importarInventarioSucursalCSV,
            ),
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Exportar CSV',
              onPressed: _exportarCSV,
            ),
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Exportar CSV por Sucursal',
              onPressed: _exportarInventarioSucursalCSV,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Agregar producto',
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
                    child: const AgregarProductoPage(),
                  ),
                );
              },
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
                      onCategoriaSeleccionada: (nombre) {
                        setState(() => _categoriaSeleccionada = nombre);
                      },
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

                  productosFiltrados.isEmpty
                      ? const Center(child: Text('No se encontraron productos'))
                      : ProductDataTable(
                          productos: productosFiltrados,
                          idSucursalActual: widget.idSucursalActual,
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
