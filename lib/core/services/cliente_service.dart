import 'package:sqflite/sqflite.dart';
import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:pos_farmacia/core/models/cliente_model.dart';

class ClienteService {
  Future<int> insertarCliente(ClienteModel cliente) async {
    final db = await DatabaseService.database;
    return await db.insert(
      'clientes',
      cliente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClienteModel>> obtenerClientes() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      orderBy: 'nombreCompleto ASC',
    );
    return maps.map((map) => ClienteModel.fromMap(map)).toList();
  }

  Future<ClienteModel?> obtenerClientePorUuid(String uuidCliente) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'uuid_cliente = ?',
      whereArgs: [uuidCliente],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return ClienteModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> actualizarCliente(ClienteModel cliente) async {
    final db = await DatabaseService.database;
    return await db.update(
      'clientes',
      cliente.toMap(),
      where: 'uuid_cliente = ?',
      whereArgs: [cliente.uuidCliente],
    );
  }

  Future<int> eliminarClientePorUuid(String uuidCliente) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'clientes',
      where: 'uuid_cliente = ?',
      whereArgs: [uuidCliente],
    );
  }

  Future<void> actualizarPuntos(String uuidCliente, int puntosNuevos) async {
    final db = await DatabaseService.database;
    await db.update(
      'clientes',
      {'puntosAcumulados': puntosNuevos},
      where: 'uuid_cliente = ?',
      whereArgs: [uuidCliente],
    );
  }
}
