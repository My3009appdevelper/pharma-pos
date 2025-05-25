import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/inventario/agregar_producto_page.dart';
import 'package:pos_farmacia/core/providers/inventario_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_sucursal_provider.dart';
import 'package:pos_farmacia/core/providers/user_provider.dart';
import 'package:pos_farmacia/widgets/navigation_rail_categories.dart';
import 'package:pos_farmacia/core/models/product_model.dart';
import 'package:pos_farmacia/features/stock/inventario/product_data_table.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_farmacia/core/services/inventario_service.dart';
import 'package:pos_farmacia/core/models/inventario_sucursal_model.dart';
import 'package:pos_farmacia/core/services/inventario_sucursal_service.dart';

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
      final provider = Provider.of<InventarioProvider>(context, listen: false);

      List<List<dynamic>> fields;

      try {
        final input = File(path).openRead();
        fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();
      } catch (e) {
        debugPrint('❌ Error al leer o parsear el CSV: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ No se pudo leer el archivo CSV.\nAsegúrate de que esté en formato UTF-8 y con la estructura correcta.',
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      int agregados = 0;
      int duplicados = 0;

      for (var row in fields.skip(1)) {
        try {
          final codigo = row[1].toString().trim();

          final existente = await InventarioService.buscarPorCodigo(codigo);
          if (existente != null) {
            debugPrint('⚠️ Producto duplicado con código: $codigo');
            duplicados++;
            continue;
          }

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
            codigo: codigo,
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
          agregados++;
        } catch (e) {
          debugPrint('❌ Error importando fila: $e\n$row');
        }
      }

      await provider.cargarDesdeBD();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Importación completada.\nProductos agregados: $agregados\nDuplicados ignorados: $duplicados',
          ),
          duration: const Duration(seconds: 4),
        ),
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
              icon: const Icon(Icons.file_download),
              tooltip: 'Exportar CSV',
              onPressed: _exportarCSV,
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
