import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/inventario_sucursal_page.dart';
import 'package:pos_farmacia/features/stock/inventario/inventario_page.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_provider.dart';
import 'package:pos_farmacia/features/stock/lotes/lotes_page.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/logic/inventario_sucursal_provider.dart';
import 'package:pos_farmacia/features/sucursal/logic/sucursal/sucursal_provider.dart';
import 'package:pos_farmacia/features/users/logic/user_provider.dart';
import 'package:provider/provider.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  int? _sucursalSeleccionadaId;
  String _vistaSeleccionada = 'Inventario';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final sucursalProvider = Provider.of<SucursalProvider>(
        context,
        listen: false,
      );

      Provider.of<InventarioSucursalProvider>(
        context,
        listen: false,
      ).cargarDesdeBD();

      final idSucursal = userProvider.usuarioActual?.idSucursal;
      if (idSucursal != null) {
        Provider.of<InventarioSucursalProvider>(
          context,
          listen: false,
        ).cargarPorSucursal(idSucursal);
      }

      sucursalProvider.cargarSucursales().then((_) {
        final idSucursal = userProvider.usuarioActual?.idSucursal;
        setState(() {
          _sucursalSeleccionadaId = userProvider.usuarioActual?.rol == 'admin'
              ? null
              : idSucursal;
        });
      });

      Provider.of<InventarioProvider>(context, listen: false).cargarDesdeBD();
    });
  }

  Widget _buildVista() {
    switch (_vistaSeleccionada) {
      case 'Lotes':
        return InventarioSucursalPage(
          idSucursal: _sucursalSeleccionadaId ?? null,
        );
      case 'Caducidad':
        return Center(child: Text("Caducidad"));
      case 'Inventario':
      default:
        return InventarioPage(
          idSucursalActual: _sucursalSeleccionadaId ?? null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
        leading: PopupMenuButton<String>(
          initialValue: _vistaSeleccionada,
          onSelected: (value) => setState(() => _vistaSeleccionada = value),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'Inventario', child: Text('Inventario')),
            PopupMenuItem(value: 'Lotes', child: Text('Lotes')),
            PopupMenuItem(value: 'Caducidad', child: Text('Caducidad')),
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
                      final sucursalProvider = Provider.of<SucursalProvider>(
                        context,
                        listen: false,
                      );
                      final inventarioSucursalProvider =
                          Provider.of<InventarioSucursalProvider>(
                            context,
                            listen: false,
                          );

                      setState(() {
                        _sucursalSeleccionadaId = val;
                        sucursalProvider.seleccionarSucursalPorId(val ?? 0);
                      });

                      if (val == null) {
                        await inventarioSucursalProvider.cargarDesdeBD();
                      } else {
                        await inventarioSucursalProvider.cargarPorSucursal(val);
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
      body: _buildVista(),
    );
  }
}
