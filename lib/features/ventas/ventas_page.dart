// lib/features/ventas/pages/ventas_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/core/models/detalle_venta_model.dart';
import 'package:pos_farmacia/core/models/product_model.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/providers/detalle_venta_provider.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_provider.dart';

class VentasPage extends StatelessWidget {
  const VentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final detalleProvider = Provider.of<DetalleVentaProvider>(context);
    final inventarioProvider = Provider.of<InventarioProvider>(context);

    final TextEditingController codigoController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Venta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código de barras o producto',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (codigo) {
                      final producto = inventarioProvider.obtenerPorCodigo(
                        codigo,
                      );
                      if (producto != null) {
                        detalleProvider.agregarDetalle(
                          DetalleVentaModel(
                            uuidVenta: '',
                            idProducto: producto.id!,
                            cantidad: 1,
                            precioUnitario: producto.precio,
                            descuento: 0.0,
                            total: producto.precio,
                            idSucursal: 1,
                            creadoEn: DateTime.now(),
                            sincronizado: false,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto no encontrado.'),
                          ),
                        );
                      }
                      codigoController.clear();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Productos en la venta:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: detalleProvider.detalles.length,
                itemBuilder: (context, index) {
                  final d = detalleProvider.detalles[index];
                  final producto = inventarioProvider.productos.firstWhere(
                    (p) => p.id == d.idProducto,
                  );
                  return ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text(
                      'Cantidad: ${d.cantidad}  Total: \$${d.total.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => detalleProvider.eliminarDetalle(d),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${detalleProvider.totalVenta.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Pagar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
