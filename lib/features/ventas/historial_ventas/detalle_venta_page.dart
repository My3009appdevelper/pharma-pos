import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/providers/detalle_venta_provider.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/features/ventas/historial_ventas/ticket_generator.dart';
import 'package:provider/provider.dart';

class DetalleVentaPage extends StatelessWidget {
  final VentaModel venta;
  const DetalleVentaPage({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    final detalleProvider = Provider.of<DetalleVentaProvider>(context);
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final nombreCliente =
        ventaProvider.clientesMap[venta.uuid_cliente]?.nombreCompleto ?? '—';

    return Scaffold(
      appBar: AppBar(title: Text('Venta ${venta.folio}')),
      body: FutureBuilder(
        future: detalleProvider.cargarDesdeDB(venta.uuid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }

          final detalles = detalleProvider.detalles
              .where((d) => d.uuidVenta == venta.uuid)
              .toList();

          if (detalles.isEmpty) {
            return const Center(child: Text('Sin detalles de venta.'));
          }

          return Column(
            children: [
              ListTile(
                title: Text("Cliente: $nombreCliente"),
                subtitle: Text("Método: ${venta.metodoPago}"),
                trailing: Text("Total: \$${venta.total.toStringAsFixed(2)}"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: detalles.length,
                  itemBuilder: (context, index) {
                    final d = detalles[index];
                    return ListTile(
                      title: Text('Producto ID: ${d.idProducto}'),
                      subtitle: Text(
                        'Cantidad: ${d.cantidad} x \$${d.precioUnitario}',
                      ),
                      trailing: Text('Total: \$${d.total.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.receipt),
                label: const Text('Imprimir ticket'),
                onPressed: () async {
                  final cliente = ventaProvider.clientesMap[venta.uuid_cliente];
                  await generarTicketPDF(venta, detalles, cliente);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
