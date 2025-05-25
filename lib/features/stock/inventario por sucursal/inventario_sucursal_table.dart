import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/core/services_providers/inventario_provider.dart';
import 'package:pos_farmacia/core/models/product_model.dart';
import 'package:pos_farmacia/core/models/inventario_sucursal_model.dart';

class InventarioSucursalDataTable extends StatefulWidget {
  final List<InventarioSucursalModel> inventarioSucursal;
  final int? idSucursalActual;

  const InventarioSucursalDataTable({
    super.key,
    required this.inventarioSucursal,
    required this.idSucursalActual,
  });

  @override
  State<InventarioSucursalDataTable> createState() =>
      _InventarioSucursalDataTableState();
}

class _InventarioSucursalDataTableState
    extends State<InventarioSucursalDataTable> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<InventarioSucursalModel> _inventarioOrdenado;

  @override
  void initState() {
    super.initState();
    _inventarioOrdenado = List.from(widget.inventarioSucursal);
  }

  @override
  void didUpdateWidget(covariant InventarioSucursalDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _inventarioOrdenado = List.from(widget.inventarioSucursal);
    if (_sortColumnIndex != null) {
      _reordenarPorColumna(_sortColumnIndex!, _sortAscending);
    }
  }

  void _ordenar<T>(
    Comparable<T> Function(InventarioSucursalModel i) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _inventarioOrdenado.sort((a, b) {
        final aVal = getField(a);
        final bVal = getField(b);
        return ascending
            ? Comparable.compare(aVal, bVal)
            : Comparable.compare(bVal, aVal);
      });
    });
  }

  void _reordenarPorColumna(int columnIndex, bool ascending) {
    final inventarioProvider = Provider.of<InventarioProvider>(
      context,
      listen: false,
    );
    switch (columnIndex) {
      case 1:
        _ordenar(
          (i) {
            final p = inventarioProvider.productos.firstWhere(
              (p) => p.id == i.idProducto,
              orElse: () => ProductoModel.vacio(),
            );
            return p.codigo;
          },
          columnIndex,
          ascending,
        );
        break;
      case 2:
        _ordenar(
          (i) {
            final p = inventarioProvider.productos.firstWhere(
              (p) => p.id == i.idProducto,
              orElse: () => ProductoModel.vacio(),
            );
            return p.nombre;
          },
          columnIndex,
          ascending,
        );
        break;
      case 3:
        _ordenar((i) => i.lote ?? '', columnIndex, ascending);
        break;
      case 4:
        _ordenar(
          (i) {
            final p = inventarioProvider.productos.firstWhere(
              (p) => p.id == i.idProducto,
              orElse: () => ProductoModel.vacio(),
            );
            return p.presentacion ?? '';
          },
          columnIndex,
          ascending,
        );
        break;
      case 5:
        _ordenar((i) => i.caducidad ?? DateTime(2100), columnIndex, ascending);
        break;
      case 6:
        _ordenar(
          (i) => i.fechaEntrada ?? DateTime(2100),
          columnIndex,
          ascending,
        );
        break;
      case 7:
        _ordenar((i) => i.stock, columnIndex, ascending);
        break;
      case 8:
        _ordenar((i) => i.precioCompra ?? 0.0, columnIndex, ascending);
        break;
      case 9:
        _ordenar((i) => i.precioVenta ?? 0.0, columnIndex, ascending);
        break;
      case 10:
        _ordenar((i) => i.activo ? 1 : 0, columnIndex, ascending);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventarioProvider = Provider.of<InventarioProvider>(context);

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
              controller: _horizontalController,
              scrollbarOrientation: ScrollbarOrientation.top,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columnSpacing: 20,
                  columns: [
                    const DataColumn(
                      label: SizedBox(width: 60, child: Text('Imagen')),
                    ),
                    const DataColumn(
                      label: SizedBox(
                        width: 80,
                        child: Center(child: Text('Editar')),
                      ),
                    ),
                    DataColumn(
                      label: const SizedBox(width: 100, child: Text('Código')),
                      onSort: (i, asc) => _reordenarPorColumna(i, asc),
                    ),
                    DataColumn(
                      label: const SizedBox(width: 140, child: Text('Nombre')),
                      onSort: (i, asc) => _reordenarPorColumna(i, asc),
                    ),
                    DataColumn(
                      label: const SizedBox(width: 100, child: Text('Lote')),
                      onSort: (i, asc) => _ordenar((i) => i.lote ?? '', i, asc),
                    ),
                    DataColumn(
                      label: const SizedBox(
                        width: 100,
                        child: Text('Presentación'),
                      ),
                      onSort: (i, asc) => _reordenarPorColumna(i, asc),
                    ),
                    DataColumn(
                      label: const SizedBox(
                        width: 100,
                        child: Text('Caducidad'),
                      ),
                      onSort: (i, asc) => _ordenar(
                        (i) => i.caducidad ?? DateTime(2100),
                        i,
                        asc,
                      ),
                    ),
                    DataColumn(
                      label: const SizedBox(
                        width: 110,
                        child: Text('Fecha Entrada'),
                      ),
                      onSort: (i, asc) => _ordenar(
                        (i) => i.fechaEntrada ?? DateTime(2100),
                        i,
                        asc,
                      ),
                    ),
                    DataColumn(
                      label: const SizedBox(width: 70, child: Text('Stock')),
                      numeric: true,
                      onSort: (i, asc) => _ordenar((i) => i.stock, i, asc),
                    ),
                    DataColumn(
                      label: const SizedBox(
                        width: 110,
                        child: Text('Precio Compra'),
                      ),
                      numeric: true,
                      onSort: (i, asc) =>
                          _ordenar((i) => i.precioCompra ?? 0.0, i, asc),
                    ),
                    DataColumn(
                      label: const SizedBox(
                        width: 110,
                        child: Text('Precio Venta'),
                      ),
                      numeric: true,
                      onSort: (i, asc) =>
                          _ordenar((i) => i.precioVenta ?? 0.0, i, asc),
                    ),
                    DataColumn(
                      label: const SizedBox(
                        width: 90,
                        child: Center(child: Text('Activo')),
                      ),
                      onSort: (i, asc) =>
                          _ordenar((i) => i.activo ? 1 : 0, i, asc),
                    ),
                  ],
                  rows: _inventarioOrdenado.map((inv) {
                    final producto = inventarioProvider.productos.firstWhere(
                      (p) => p.id == inv.idProducto,
                      orElse: () => ProductoModel.vacio(),
                    );

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
                            width: 80,
                            child: Center(
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(width: 100, child: Text(producto.codigo)),
                        ),
                        DataCell(
                          SizedBox(width: 140, child: Text(producto.nombre)),
                        ),
                        DataCell(
                          SizedBox(width: 100, child: Text(inv.lote ?? '-')),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(producto.presentacion ?? '-'),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              inv.caducidad
                                      ?.toIso8601String()
                                      .split('T')
                                      .first ??
                                  '-',
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 110,
                            child: Text(
                              inv.fechaEntrada
                                      ?.toIso8601String()
                                      .split('T')
                                      .first ??
                                  '-',
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: Text(inv.stock.toString()),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 110,
                            child: Text(
                              '\$${inv.precioCompra?.toStringAsFixed(2) ?? '0.00'}',
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 110,
                            child: Text(
                              '\$${inv.precioVenta?.toStringAsFixed(2) ?? '0.00'}',
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 90,
                            child: Center(
                              child: Icon(
                                inv.activo ? Icons.check : Icons.close,
                                color: inv.activo ? Colors.green : Colors.red,
                              ),
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
    );
  }
}
