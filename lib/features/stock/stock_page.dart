import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_farmacia/features/stock/inventario/inventario_page.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/inventario_sucursal_page.dart';
import 'package:pos_farmacia/core/providers/inventario_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_sucursal_provider.dart';
import 'package:pos_farmacia/core/providers/sucursal_provider.dart';
import 'package:pos_farmacia/core/providers/user_provider.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage>
    with SingleTickerProviderStateMixin {
  int? _sucursalSeleccionadaId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final sucursalProvider = Provider.of<SucursalProvider>(
        context,
        listen: false,
      );
      final inventarioSucursalProvider =
          Provider.of<InventarioSucursalProvider>(context, listen: false);

      final idSucursal = userProvider.usuarioActual?.idSucursal;

      await Provider.of<InventarioProvider>(
        context,
        listen: false,
      ).cargarDesdeBD();
      await sucursalProvider.cargarSucursales();

      if (idSucursal != null) {
        await inventarioSucursalProvider.cargarPorSucursal(idSucursal);
      } else {
        await inventarioSucursalProvider.cargarDesdeBD();
      }

      setState(() {
        _sucursalSeleccionadaId = userProvider.usuarioActual?.rol == 'admin'
            ? null
            : idSucursal;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: const Text('Stock')),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Inventario'),
              Tab(text: 'Lotes'),
              Tab(text: 'Caducidad'),
            ],
          ),
          actions: [
            if (Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).usuarioActual?.rol ==
                'admin')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Consumer<SucursalProvider>(
                  builder: (_, sucursalProvider, __) {
                    final sucursales = sucursalProvider.sucursales;
                    return DropdownButton<int?>(
                      value: _sucursalSeleccionadaId,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      underline: const SizedBox(),
                      hint: const Text('Sucursal'),
                      onChanged: (val) async {
                        final inventarioSucursalProvider =
                            Provider.of<InventarioSucursalProvider>(
                              context,
                              listen: false,
                            );

                        setState(() {
                          _sucursalSeleccionadaId = val;
                        });

                        if (val == null) {
                          await inventarioSucursalProvider.cargarDesdeBD();
                        } else {
                          await inventarioSucursalProvider.cargarPorSucursal(
                            val,
                          );
                        }

                        setState(() {});
                      },
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ...sucursales.map(
                          (s) => DropdownMenuItem<int?>(
                            value: s.id,
                            child: Text(s.nombre),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
        body: TabBarView(
          physics:
              const NeverScrollableScrollPhysics(), // ⛔ Desactiva swipe lateral

          children: [
            InventarioPage(idSucursalActual: _sucursalSeleccionadaId),
            InventarioSucursalPage(idSucursal: _sucursalSeleccionadaId),
            const Center(child: Text('Caducidad')), // futura vista
          ],
        ),
      ),
    );
  }
}
