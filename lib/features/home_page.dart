import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/stock_page.dart';
import 'package:pos_farmacia/features/sucursal/sucursal_page.dart';
import 'package:pos_farmacia/features/ventas/historial_ventas_page.dart';
import 'package:pos_farmacia/features/ventas/ventas_page.dart';
import 'package:provider/provider.dart';
import '../core/themes/theme_provider.dart';
import '../core/providers/user_provider.dart';
import 'users/usuarios_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final usuario = userProvider.usuarioActual;

    final tabs = <Tab>[
      const Tab(text: 'Ventas', icon: Icon(Icons.point_of_sale)),
      const Tab(text: 'Inventario', icon: Icon(Icons.inventory_2)),
      const Tab(
        text: 'Historial de Ventas',
        icon: Icon(Icons.receipt_long_outlined),
      ),
      const Tab(text: 'Corte de Caja', icon: Icon(Icons.receipt_long)),
      const Tab(text: 'Operaciones', icon: Icon(Icons.settings)),
      const Tab(text: 'Reportes', icon: Icon(Icons.bar_chart)),
      const Tab(text: 'Clientes', icon: Icon(Icons.person_search)),
      if (usuario?.rol == 'admin')
        const Tab(text: 'Usuarios', icon: Icon(Icons.people)),
      if (usuario?.rol == 'admin')
        const Tab(text: 'Sucursales', icon: Icon(Icons.store)),
    ];

    final tabViews = <Widget>[
      VentasPage(),
      StockPage(),
      HistorialVentasPage(),
      const Text('Corte de Caja'),
      const Text('Operaciones'),
      const Text('Reportes'),
      const Text('Clientes'),
      if (usuario?.rol == 'admin') const UsuariosPage(),
      if (usuario?.rol == 'admin') const SucursalPage(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            tooltip: 'Cambiar tema',
            onPressed: () {
              themeProvider.toggle();
            },
          ),
          title: Center(child: Text('POS - ${usuario?.rol.toUpperCase()}')),
          bottom: TabBar(isScrollable: true, tabs: tabs),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                userProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
        body: TabBarView(
          physics:
              const NeverScrollableScrollPhysics(), // ⛔ Desactiva swipe lateral
          children: tabViews,
        ),
      ),
    );
  }
}
