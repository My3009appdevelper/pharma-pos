import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:pos_farmacia/core/models/receta_model.dart';

class RecetaService {
  final db = DatabaseService.database;

  Future<void> insertar(RecetaModel receta) async {
    final dbClient = await db;
    await dbClient.insert('recetas', receta.toMap());
  }

  Future<List<RecetaModel>> obtenerPorVenta(String uuidVenta) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'recetas',
      where: 'uuid_venta = ?',
      whereArgs: [uuidVenta],
    );
    return maps.map((e) => RecetaModel.fromMap(e)).toList();
  }

  Future<void> actualizar(RecetaModel receta) async {
    final dbClient = await db;
    await dbClient.update(
      'recetas',
      receta.toMap(),
      where: 'uuid = ?',
      whereArgs: [receta.uuid],
    );
  }

  Future<void> eliminar(String uuid) async {
    final dbClient = await db;
    await dbClient.delete('recetas', where: 'uuid = ?', whereArgs: [uuid]);
  }
}
