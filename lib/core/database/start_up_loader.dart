import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/providers/app_state_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_provider.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/core/providers/user_provider.dart';
import 'package:pos_farmacia/core/providers/sucursal_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_sucursal_provider.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/core/providers/cliente_provider.dart';

class StartupLoader {
  static Future<void> cargarDatosIniciales(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sucursalProvider = Provider.of<SucursalProvider>(
      context,
      listen: false,
    );

    final inventarioProvider = Provider.of<InventarioProvider>(
      context,
      listen: false,
    );

    final inventarioSucursalProvider = Provider.of<InventarioSucursalProvider>(
      context,
      listen: false,
    );
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    final usuario = userProvider.usuarioActual;
    await inventarioProvider.cargarDesdeBD();

    if (usuario?.rol == 'admin') {
      await sucursalProvider.cargarSucursales();
      await inventarioSucursalProvider.cargarDesdeBD();
    } else if (usuario?.idSucursal != null) {
      await inventarioSucursalProvider.cargarPorSucursal(usuario!.idSucursal!);
    }

    await clienteProvider.cargarDesdeDB();
    await ventaProvider.cargarDesdeDB();

    // 🟢 AHORA SÍ marca la app como cargada
    appState.marcarComoCargada();
  }
}
