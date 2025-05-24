import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/themes/theme_provider.dart';
import 'package:pos_farmacia/features/home_page.dart';
import 'package:pos_farmacia/widgets/elevated_button.dart';
import 'package:pos_farmacia/widgets/text_form_field.dart';
import 'package:provider/provider.dart';
import '../../core/services_providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login POS'),
        leading: IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          ),
          tooltip: 'Cambiar tema',
          onPressed: () {
            themeProvider.toggle();
          },
        ),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          elevation: 8,
          color: colorScheme.surface, // ✅ ahora depende del tema
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Inicio de Sesión',
                        style: textTheme.headlineLarge, // ✅ usa textTheme
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        label: 'Usuario',
                        controller: _usernameCtrl,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Requerido' : null,
                        prefixIcon: const Icon(Icons.person),
                      ),
                      CustomTextFormField(
                        label: 'Contraseña',
                        controller: _passwordCtrl,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Requerido' : null,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 24),
                      CustomElevatedButton(
                        loading: _cargando,
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            setState(() {
                              _cargando = true;
                              _error = null;
                            });

                            final success = await userProvider.login(
                              _usernameCtrl.text.trim(),
                              _passwordCtrl.text.trim(),
                            );

                            setState(() => _cargando = false);

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomePage(),
                                ),
                              );
                            } else {
                              setState(
                                () =>
                                    _error = 'Usuario o contraseña incorrectos',
                              );
                            }
                          }
                        },
                        child: const Text('Iniciar Sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
