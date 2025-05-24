import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/themes/dark_mode.dart';
import 'package:pos_farmacia/core/themes/light_mode.dart';
import 'package:pos_farmacia/core/themes/theme_provider.dart';
import 'package:pos_farmacia/features/users/login_page.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (themeProvider.cargando) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'POS Farmacia',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeProvider.themeMode,
      home: const LoginPage(),
    );
  }
}
