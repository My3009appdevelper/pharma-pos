import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_provider.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/product_model.dart';
import 'package:pos_farmacia/features/stock/inventario por sucursal/logic/inventario_sucursal_model.dart';

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

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventarioProvider = Provider.of<InventarioProvider>(context);

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
                  DataColumn(label: SizedBox(width: 60, child: Text('Imagen'))),
                  DataColumn(
                    label: SizedBox(width: 100, child: Text('Código')),
                  ),
                  DataColumn(
                    label: SizedBox(width: 140, child: Text('Nombre')),
                  ),
                  DataColumn(label: SizedBox(width: 100, child: Text('Lote'))),
                  DataColumn(
                    label: SizedBox(width: 100, child: Text('Caducidad')),
                  ),
                  DataColumn(
                    label: SizedBox(width: 110, child: Text('Fecha Entrada')),
                  ),
                  DataColumn(label: SizedBox(width: 70, child: Text('Stock'))),
                  DataColumn(
                    label: SizedBox(width: 110, child: Text('Precio Compra')),
                  ),
                  DataColumn(
                    label: SizedBox(width: 110, child: Text('Precio Venta')),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 90,
                      child: Center(child: Text('Activo')),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 80,
                      child: Center(child: Text('Editar')),
                    ),
                  ),
                ],
                rows: widget.inventarioSucursal.map((inv) {
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
                          width: 100,
                          child: Text(
                            producto.codigo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            producto.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(width: 100, child: Text(inv.lote ?? '-')),
                      ),
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            inv.caducidad?.toIso8601String().split('T').first ??
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
                        SizedBox(width: 70, child: Text(inv.stock.toString())),
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
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Abrir modal para editar el lote
                              },
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
