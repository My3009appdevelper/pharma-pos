import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/providers/detalle_venta_provider.dart';
import 'package:provider/provider.dart';

class DetalleVentaPage extends StatelessWidget {
  final VentaModel venta;
  const DetalleVentaPage({super.key, required this.venta});

  @override
  Widget build(BuildContext context) {
    final detalleProvider = Provider.of<DetalleVentaProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Venta ${venta.folio}')),
      body: FutureBuilder(
        future: detalleProvider.cargarDesdeDB(venta.uuid),
        builder: (context, snapshot) {
          final detalles = detalleProvider.detalles;

          if (detalles.isEmpty) {
            return const Center(child: Text('Sin detalles de venta.'));
          }

          return ListView.builder(
            itemCount: detalles.length,
            itemBuilder: (context, index) {
              final d = detalles[index];
              return ListTile(
                title: Text('Producto ID: ${d.idProducto}'),
                subtitle: Text(
                  'Cantidad: ${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}',
                ),
                trailing: Text('Total: \$${d.total.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}
