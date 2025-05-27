import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/models/detalle_venta_model.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/core/providers/detalle_venta_provider.dart';
import 'package:pos_farmacia/features/ventas/detalle_venta_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistorialVentasPage extends StatelessWidget {
  const HistorialVentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ventaProvider = Provider.of<VentaProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Ventas')),
      body: FutureBuilder(
        future: ventaProvider.cargarDesdeDB(),
        builder: (context, snapshot) {
          final ventas = ventaProvider.ventas;

          if (ventas.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }

          return ListView.builder(
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              final venta = ventas[index];
              return ListTile(
                leading: const Icon(Icons.receipt),
                title: Text('Folio: ${venta.folio}'),
                subtitle: Text(
                  '${DateFormat.yMMMMEEEEd().add_jm().format(venta.fecha)}\nTotal: \$${venta.total.toStringAsFixed(2)} - ${venta.metodoPago}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetalleVentaPage(venta: venta),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
