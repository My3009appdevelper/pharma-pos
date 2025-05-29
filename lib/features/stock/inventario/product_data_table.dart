import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/inventario/editar_producto_page.dart';
import 'package:pos_farmacia/core/models/product_model.dart';
import 'package:pos_farmacia/core/providers/inventario_sucursal_provider.dart';
import 'package:provider/provider.dart';

class ProductDataTable extends StatefulWidget {
  final List<ProductoModel> productos;
  final int? idSucursalActual;

  const ProductDataTable({
    super.key,
    required this.productos,
    required this.idSucursalActual,
  });

  @override
  State<ProductDataTable> createState() => _ProductDataTableState();
}

class _ProductDataTableState extends State<ProductDataTable> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<ProductoModel> _productosOrdenados;

  @override
  void initState() {
    super.initState();
    _productosOrdenados = List.from(widget.productos);
  }

  void _ordenar<T>(
    Comparable<T> Function(ProductoModel p) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _productosOrdenados.sort((a, b) {
        final aVal = getField(a);
        final bVal = getField(b);
        return ascending
            ? Comparable.compare(aVal, bVal)
            : Comparable.compare(bVal, aVal);
      });
    });
  }

  @override
  void didUpdateWidget(ProductDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _productosOrdenados = List.from(widget.productos);
    if (_sortColumnIndex != null) {
      switch (_sortColumnIndex) {
        case 2:
          _ordenar((p) => p.codigo, _sortColumnIndex!, _sortAscending);
          break;
        case 3:
          _ordenar((p) => p.nombre, _sortColumnIndex!, _sortAscending);
          break;
        case 4:
          _ordenar((p) => p.precio, _sortColumnIndex!, _sortAscending);
          break;
        case 5:
          _ordenar(
            (p) => p.categorias.join(', '),
            _sortColumnIndex!,
            _sortAscending,
          );
          break;
        case 6:
          _ordenar(
            (p) => p.presentacion ?? '',
            _sortColumnIndex!,
            _sortAscending,
          );
          break;
        case 7:
          _ordenar((p) => p.activo ? 1 : 0, _sortColumnIndex!, _sortAscending);
          break;
        case 8:
          _ordenar(
            (p) =>
                Provider.of<InventarioSucursalProvider>(context, listen: false)
                    .inventarioCompleto
                    .where((r) => r.idProducto == p.id)
                    .fold<int>(0, (sum, r) => sum + r.stock),
            _sortColumnIndex!,
            _sortAscending,
          );
          break;
        case 9:
          _ordenar(
            (p) => widget.idSucursalActual == null
                ? Provider.of<InventarioSucursalProvider>(
                        context,
                        listen: false,
                      ).inventarioCompleto
                      .where((r) => r.idProducto == p.id)
                      .fold<int>(0, (sum, r) => sum + r.stock)
                : Provider.of<InventarioSucursalProvider>(
                        context,
                        listen: false,
                      ).inventario
                      .where(
                        (r) =>
                            r.idProducto == p.id &&
                            r.idSucursal == widget.idSucursalActual,
                      )
                      .fold<int>(0, (sum, r) => sum + r.stock),
            _sortColumnIndex!,
            _sortAscending,
          );
          break;
      }
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventarioSucursalProvider = Provider.of<InventarioSucursalProvider>(
      context,
    );

    return Expanded(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
        child: Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.top,
              controller: _horizontalController,
              thumbVisibility: true,
              notificationPredicate: (notification) => true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1000),
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columnSpacing: 20,
                    columns: [
                      const DataColumn(
                        label: SizedBox(width: 70, child: Text('Imagen')),
                      ),
                      const DataColumn(
                        label: SizedBox(
                          width: 60,
                          child: Center(child: Text('Editar')),
                        ),
                      ),
                      DataColumn(
                        label: const SizedBox(width: 80, child: Text('Código')),
                        onSort: (i, asc) => _ordenar((p) => p.codigo, i, asc),
                      ),
                      DataColumn(
                        label: const SizedBox(
                          width: 120,
                          child: Text('Nombre'),
                        ),
                        onSort: (i, asc) => _ordenar((p) => p.nombre, i, asc),
                      ),
                      DataColumn(
                        label: const SizedBox(width: 90, child: Text('Precio')),
                        numeric: true,
                        onSort: (i, asc) => _ordenar((p) => p.precio, i, asc),
                      ),
                      DataColumn(
                        label: const SizedBox(
                          width: 150,
                          child: Text('Categorías'),
                        ),
                        onSort: (i, asc) =>
                            _ordenar((p) => p.categorias.join(', '), i, asc),
                      ),
                      DataColumn(
                        label: const SizedBox(
                          width: 120,
                          child: Text('Presentación'),
                        ),
                        onSort: (i, asc) =>
                            _ordenar((p) => p.presentacion ?? '', i, asc),
                      ),
                      DataColumn(
                        label: const SizedBox(
                          width: 40,
                          child: Center(child: Text('Activo')),
                        ),
                        onSort: (i, asc) =>
                            _ordenar((p) => p.activo ? 1 : 0, i, asc),
                      ),
                      DataColumn(
                        label: const SizedBox(
                          width: 90,
                          child: Center(child: Text('Stock Global')),
                        ),
                        numeric: true,
                        onSort: (i, asc) => _ordenar(
                          (p) => inventarioSucursalProvider.inventarioCompleto
                              .where((r) => r.idProducto == p.id)
                              .fold<int>(0, (sum, r) => sum + r.stock),
                          i,
                          asc,
                        ),
                      ),
                      DataColumn(
                        label: const SizedBox(
                          width: 110,
                          child: Center(child: Text('Stock Sucursal')),
                        ),
                        numeric: true,
                        onSort: (i, asc) => _ordenar(
                          (p) => widget.idSucursalActual == null
                              ? inventarioSucursalProvider.inventarioCompleto
                                    .where((r) => r.idProducto == p.id)
                                    .fold<int>(0, (sum, r) => sum + r.stock)
                              : inventarioSucursalProvider.inventario
                                    .where(
                                      (r) =>
                                          r.idProducto == p.id &&
                                          r.idSucursal ==
                                              widget.idSucursalActual,
                                    )
                                    .fold<int>(0, (sum, r) => sum + r.stock),
                          i,
                          asc,
                        ),
                      ),
                    ],
                    rows: _productosOrdenados.map((producto) {
                      final stockSucursal = widget.idSucursalActual == null
                          ? inventarioSucursalProvider.inventarioCompleto
                                .where((r) => r.idProducto == producto.id)
                                .fold<int>(0, (sum, r) => sum + r.stock)
                          : inventarioSucursalProvider.inventario
                                .where(
                                  (r) =>
                                      r.idProducto == producto.id &&
                                      r.idSucursal == widget.idSucursalActual,
                                )
                                .fold<int>(0, (sum, r) => sum + r.stock);

                      final stockGlobal = inventarioSucursalProvider
                          .inventarioCompleto
                          .where((r) => r.idProducto == producto.id)
                          .fold<int>(0, (sum, r) => sum + r.stock);

                      return DataRow(
                        cells: [
                          DataCell(
                            producto.imagenUrl != null &&
                                    File(producto.imagenUrl!).existsSync()
                                ? Image.file(
                                    File(producto.imagenUrl!),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 60,
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                      ),
                                      builder: (context) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom,
                                        ),
                                        child: EditarProductoPage(
                                          producto: producto,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(width: 80, child: Text(producto.codigo)),
                          ),
                          DataCell(
                            SizedBox(width: 120, child: Text(producto.nombre)),
                          ),
                          DataCell(
                            SizedBox(
                              width: 90,
                              child: Text(
                                '\$${producto.precio.toStringAsFixed(2)}',
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 150,
                              child: Text(producto.categorias.join(', ')),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: Text(producto.presentacion ?? '-'),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Icon(
                                  producto.activo ? Icons.check : Icons.close,
                                  color: producto.activo
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 90,
                              child: Center(
                                child: Text(stockGlobal.toString()),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 110,
                              child: Center(
                                child: Text(stockSucursal.toString()),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
