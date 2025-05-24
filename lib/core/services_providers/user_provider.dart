import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/database/database_service.dart';
import 'user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  List<UsuarioModel> _usuarios = [];
  UsuarioModel? _usuarioActual;

  List<UsuarioModel> get usuarios => _usuarios;
  UsuarioModel? get usuarioActual => _usuarioActual;

  /// 💾 Cargar usuarios desde SQLite
  Future<void> cargarUsuarios() async {
    final db = await DatabaseService.database;
    final data = await db.query('usuarios');
    _usuarios = data.map((e) => UsuarioModel.fromMap(e)).toList();
    notifyListeners();
  }

  /// 🔐 Validar login
  Future<bool> login(String username, String passwordPlano) async {
    final db = await DatabaseService.database;
    final hashed = hashPassword(passwordPlano);

    final res = await db.query(
      'usuarios',
      where: 'username = ? AND password = ? AND activo = 1',
      whereArgs: [username, hashed],
    );

    if (res.isNotEmpty) {
      _usuarioActual = UsuarioModel.fromMap(res.first);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 🔓 Cerrar sesión
  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }

  /// ➕ Registrar nuevo usuario
  Future<void> registrarUsuario(UsuarioModel usuario) async {
    final db = await DatabaseService.database;
    await db.insert('usuarios', usuario.toMap());
    await cargarUsuarios();
  }

  /// 🔄 Actualizar usuario
  Future<void> actualizarUsuario(UsuarioModel usuario) async {
    final db = await DatabaseService.database;
    await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
    await cargarUsuarios();
  }

  /// 🧂 Hasheo seguro
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// 🔐 Crear usuario admin si no hay ninguno
  Future<void> crearAdminSiNoExiste() async {
    final db = await DatabaseService.database;
    final res = await db.query(
      'usuarios',
      where: 'rol = ?',
      whereArgs: ['admin'],
    );

    if (res.isEmpty) {
      final admin = UsuarioModel(
        username: 'admin',
        password: hashPassword('admin123'),
        nombreCompleto: 'Administrador',
        rol: 'admin',
        idSucursal: null, // Admin puede no estar atado a una sucursal
      );
      await registrarUsuario(admin);
    }
  }
}
