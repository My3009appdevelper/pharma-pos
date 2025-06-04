import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:pos_farmacia/core/models/receta_detalle_model.dart';

class RecetaDetalleService {
  final db = DatabaseService.database;

  Future<void> insertar(RecetaDetalleModel detalle) async {
    final dbClient = await db;
    await dbClient.insert('receta_detalle', detalle.toMap());
  }

  Future<List<RecetaDetalleModel>> obtenerPorReceta(String uuidReceta) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'receta_detalle',
      where: 'uuid_receta = ?',
      whereArgs: [uuidReceta],
    );
    return maps.map((e) => RecetaDetalleModel.fromMap(e)).toList();
  }

  Future<void> actualizar(RecetaDetalleModel detalle) async {
    final dbClient = await db;
    await dbClient.update(
      'receta_detalle',
      detalle.toMap(),
      where: 'id = ?',
      whereArgs: [detalle.id],
    );
  }

  Future<void> eliminar(int id) async {
    final dbClient = await db;
    await dbClient.delete('receta_detalle', where: 'id = ?', whereArgs: [id]);
  }
}
