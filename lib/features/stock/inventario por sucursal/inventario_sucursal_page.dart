import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/logic/inventario_sucursal_provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/product_model.dart';
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
      appBar: AppBar(title: const Text('Inventario por Sucursal')),
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
