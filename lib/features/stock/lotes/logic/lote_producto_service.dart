// lib/features/stock/logic/lote_producto_service.dart

import 'package:pos_farmacia/core/database/database_service.dart';
import 'lote_producto_model.dart';

class LoteProductoService {
  static Future<void> insertar(LoteProductoModel lote) async {
    final db = await DatabaseService.database;
    await db.insert('lotes_producto', lote.toMap());
  }

  static Future<void> actualizar(LoteProductoModel lote) async {
    final db = await DatabaseService.database;
    await db.update(
      'lotes_producto',
      lote.toMap(),
      where: 'id = ?',
      whereArgs: [lote.id],
    );
  }

  static Future<void> eliminar(int id) async {
    final db = await DatabaseService.database;
    await db.delete('lotes_producto', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<LoteProductoModel>> obtenerPorProductoYSucursal(
    int idProducto,
    int idSucursal,
  ) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'lotes_producto',
      where: 'id_producto = ? AND id_sucursal = ? AND activo = 1',
      whereArgs: [idProducto, idSucursal],
    );
    return result.map((e) => LoteProductoModel.fromMap(e)).toList();
  }

  static Future<List<LoteProductoModel>> obtenerPorProducto(int idProducto) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'lotes_producto',
      where: 'id_producto = ? AND activo = 1',
      whereArgs: [idProducto],
    );
    return result.map((e) => LoteProductoModel.fromMap(e)).toList();
  }

  static Future<List<LoteProductoModel>> obtenerTodos() async {
    final db = await DatabaseService.database;
    final result = await db.query('lotes_producto');
    return result.map((e) => LoteProductoModel.fromMap(e)).toList();
  }
}
