import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:pos_farmacia/core/providers/detalle_venta_provider.dart';
import 'package:pos_farmacia/core/providers/receta_provider.dart';
import 'package:pos_farmacia/core/providers/venta_provider.dart';
import 'package:pos_farmacia/core/themes/dark_mode.dart';
import 'package:pos_farmacia/core/themes/light_mode.dart';
import 'package:pos_farmacia/core/themes/theme_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_provider.dart';
import 'package:pos_farmacia/core/providers/inventario_sucursal_provider.dart';
import 'package:pos_farmacia/core/providers/sucursal_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/providers/user_provider.dart';
import 'features/users/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  //await DatabaseService.borrarBaseDeDatos();

  await DatabaseService.database;

  final userProvider = UserProvider();
  await userProvider.crearAdminSiNoExiste();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => SucursalProvider()),
        ChangeNotifierProvider(create: (_) => InventarioSucursalProvider()),
        ChangeNotifierProvider(create: (_) => VentaProvider()),
        ChangeNotifierProvider(create: (_) => DetalleVentaProvider()),
        ChangeNotifierProvider(create: (_) => RecetaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'POS Farmacia',
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: themeProvider.themeMode,
          home: const LoginPage(),
        );
      },
    );
  }
}
