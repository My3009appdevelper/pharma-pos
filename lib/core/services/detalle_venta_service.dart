import 'package:pos_farmacia/core/models/venta_detalle_model.dart';
import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DetalleVentaService {
  Future<void> insertarDetalle(DetalleVentaModel detalle) async {
    final db = await DatabaseService.database;
    await db.insert('venta_detalle', detalle.toMap());
  }

  Future<void> insertarMultiplesDetalles(
    List<DetalleVentaModel> detalles,
  ) async {
    final db = await DatabaseService.database;
    final batch = db.batch();
    for (final d in detalles) {
      batch.insert('venta_detalle', d.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<DetalleVentaModel>> obtenerPorUuid(String uuidVenta) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'venta_detalle',
      where: 'uuid_venta = ?',
      whereArgs: [uuidVenta],
    );
    return result.map((map) => DetalleVentaModel.fromMap(map)).toList();
  }

  Future<void> eliminarPorUuid(String uuidVenta) async {
    final db = await DatabaseService.database;
    await db.delete(
      'venta_detalle',
      where: 'uuid_venta = ?',
      whereArgs: [uuidVenta],
    );
  }

  Future<int> contarDetalles() async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM venta_detalle');
    final count = result.isNotEmpty ? result.first.values.first as int : 0;
    return count;
  }

  Future<List<DetalleVentaModel>> obtenerTodos() async {
    final db = await DatabaseService.database;
    final result = await db.query('venta_detalle', orderBy: 'creado_en DESC');
    return result.map((map) => DetalleVentaModel.fromMap(map)).toList();
  }

  Future<void> marcarSincronizados(String uuidVenta) async {
    final db = await DatabaseService.database;
    await db.update(
      'venta_detalle',
      {'sincronizado': 1},
      where: 'uuid_venta = ?',
      whereArgs: [uuidVenta],
    );
  }
}
