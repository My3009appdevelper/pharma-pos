import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/inventario/editar_producto_page.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/product_model.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/logic/inventario_sucursal_provider.dart';
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
      child: Scrollbar(
        controller: _verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,

              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: SizedBox(width: 70, child: Text('Imagen'))),
                  DataColumn(label: SizedBox(width: 80, child: Text('Código'))),
                  DataColumn(
                    label: SizedBox(width: 120, child: Text('Nombre')),
                  ),
                  DataColumn(label: SizedBox(width: 90, child: Text('Precio'))),
                  DataColumn(
                    label: SizedBox(width: 150, child: Text('Categorías')),
                  ),
                  DataColumn(label: SizedBox(width: 80, child: Text('Unidad'))),
                  DataColumn(
                    label: SizedBox(
                      width: 60,
                      child: Center(child: Text('Activo')),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 60,
                      child: Center(child: Text('Editar')),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 90,
                      child: Center(child: Text('Stock Global')),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 110,
                      child: Center(child: Text('Stock Sucursal')),
                    ),
                  ),
                ],
                rows: widget.productos.map((producto) {
                  final stockSucursal = widget.idSucursalActual == null
                      ? producto.stock
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
                          width: 80,
                          child: Text(
                            producto.codigo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 120,
                          child: Text(
                            producto.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 90,
                          child: Text(
                            '\$${producto.precio.toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            producto.categorias.join(', '),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Text(
                            producto.unidad,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 60,
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
                        SizedBox(
                          width: 90,
                          child: Center(
                            child: Text(
                              stockGlobal.toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 110,
                          child: Center(
                            child: Text(
                              stockSucursal.toString(),
                              overflow: TextOverflow.ellipsis,
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
    );
  }
}
