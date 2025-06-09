import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/providers/user_provider.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/features/ventas/historial_ventas/historial_ventas_data_table.dart'; // importa la tabla
import 'package:provider/provider.dart';

class HistorialVentasPage extends StatelessWidget {
  const HistorialVentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usuario = userProvider.usuarioActual;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Ventas')),
      body: FutureBuilder(
        future: ventaProvider.cargarDesdeDB(usuario: usuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ventas = ventaProvider.ventas;

          if (ventas.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }

          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(child: HistorialVentasDataTable()),
          );
        },
      ),
    );
  }
}
