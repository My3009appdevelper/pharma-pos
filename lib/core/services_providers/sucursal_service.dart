import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:pos_farmacia/features/sucursal/logic/sucursal/sucursal_model.dart';

class SucursalService {
  static Future<void> insertar(SucursalModel sucursal) async {
    final db = await DatabaseService.database;
    await db.insert('sucursales', sucursal.toMap());
    print('Insertada en DB: ${sucursal.nombre}');
  }

  static Future<void> actualizar(SucursalModel sucursal) async {
    final db = await DatabaseService.database;
    await db.update(
      'sucursales',
      sucursal.toMap(),
      where: 'id = ?',
      whereArgs: [sucursal.id],
    );
  }

  static Future<List<SucursalModel>> obtenerTodas() async {
    final db = await DatabaseService.database;
    final data = await db.query('sucursales');
    return data.map((e) => SucursalModel.fromMap(e)).toList();
  }

  static Future<SucursalModel?> buscarPorId(int id) async {
    final db = await DatabaseService.database;
    final data = await db.query('sucursales', where: 'id = ?', whereArgs: [id]);
    if (data.isEmpty) return null;
    return SucursalModel.fromMap(data.first);
  }

  static Future<void> eliminar(int id) async {
    final db = await DatabaseService.database;
    await db.delete('sucursales', where: 'id = ?', whereArgs: [id]);
  }
}
