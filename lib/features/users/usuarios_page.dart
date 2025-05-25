import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import 'user_form_page.dart';
import '../../core/models/user_model.dart';

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo Usuario',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserFormPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: userProvider.cargarUsuarios(),
        builder: (context, snapshot) {
          final usuarios = userProvider.usuarios;

          return ListView.separated(
            itemCount: usuarios.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final u = usuarios[index];

              return ListTile(
                leading: Icon(
                  u.activo ? Icons.check_circle : Icons.cancel,
                  color: u.activo ? Colors.green : Colors.red,
                ),
                title: Text(u.username),
                subtitle: Text('${u.nombreCompleto} • ${u.rol}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserFormPage(usuario: u),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: u.activo ? 'Desactivar' : 'Activar',
                      icon: Icon(u.activo ? Icons.lock : Icons.lock_open),
                      onPressed: () async {
                        final nuevo = UsuarioModel(
                          id: u.id,
                          username: u.username,
                          password: u.password,
                          nombreCompleto: u.nombreCompleto,
                          rol: u.rol,
                          activo: !u.activo,
                        );
                        await userProvider.actualizarUsuario(nuevo);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
