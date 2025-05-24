import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/sucursal/logic/sucursal/sucursal_provider.dart';
import 'package:provider/provider.dart';
import 'logic/user_model.dart';
import 'logic/user_provider.dart';

class UserFormPage extends StatefulWidget {
  final UsuarioModel? usuario;
  const UserFormPage({super.key, this.usuario});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _rol = 'cajero';
  int? _idSucursalSeleccionada;

  @override
  void initState() {
    super.initState();
    final usuario = widget.usuario;
    if (usuario != null) {
      _nombreCtrl.text = usuario.nombreCompleto;
      _usuarioCtrl.text = usuario.username;
      _rol = usuario.rol;
      _idSucursalSeleccionada = usuario.idSucursal;
    }

    Future.microtask(() {
      Provider.of<SucursalProvider>(context, listen: false).cargarSucursales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final sucursalProvider = Provider.of<SucursalProvider>(context);
    final sucursales = sucursalProvider.sucursales;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.usuario == null ? 'Nuevo Usuario' : 'Editar Usuario',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _usuarioCtrl,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              if (widget.usuario == null)
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Requerida' : null,
                ),
              DropdownButtonFormField<String>(
                value: _rol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                  DropdownMenuItem(value: 'cajero', child: Text('Cajero')),
                  DropdownMenuItem(
                    value: 'supervisor',
                    child: Text('Supervisor'),
                  ),
                ],
                onChanged: (val) => setState(() => _rol = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _idSucursalSeleccionada,
                decoration: const InputDecoration(labelText: 'Sucursal'),
                items: sucursales.map((s) {
                  return DropdownMenuItem(value: s.id, child: Text(s.nombre));
                }).toList(),
                onChanged: (id) => setState(() => _idSucursalSeleccionada = id),
                validator: (v) => _rol != 'admin' && v == null
                    ? 'Requerido para roles no admin'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final usuario = UsuarioModel(
                      id: widget.usuario?.id,
                      username: _usuarioCtrl.text.trim(),
                      password:
                          widget.usuario?.password ??
                          userProvider.hashPassword(_passwordCtrl.text.trim()),
                      nombreCompleto: _nombreCtrl.text.trim(),
                      rol: _rol,
                      activo: widget.usuario?.activo ?? true,
                      idSucursal: _rol == 'admin'
                          ? null
                          : _idSucursalSeleccionada,
                    );

                    if (widget.usuario == null) {
                      await userProvider.registrarUsuario(usuario);
                    } else {
                      await userProvider.actualizarUsuario(usuario);
                    }

                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
