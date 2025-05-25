import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_service.dart';
import '../models/venta_model.dart';
import '../models/detalle_venta_model.dart';

class VentaService {
  Future<int> insertarVenta(
    VentaModel venta,
    List<DetalleVentaModel> detalles,
  ) async {
    final db = await DatabaseService.database;
    return await db.transaction((txn) async {
      final idVenta = await txn.insert('ventas', venta.toMap());

      for (final detalle in detalles) {
        final detalleMap = detalle.toMap();
        detalleMap['id_venta'] = idVenta; // 🔧 Agrega idVenta directamente
        await txn.insert('venta_detalle', detalleMap);
      }

      return idVenta;
    });
  }

  Future<List<VentaModel>> obtenerVentas() async {
    final db = await DatabaseService.database;
    final result = await db.query('ventas', orderBy: 'fecha DESC');
    return result.map(VentaModel.fromMap).toList();
  }

  Future<List<DetalleVentaModel>> obtenerDetallesPorVenta(int idVenta) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'venta_detalle',
      where: 'id_venta = ?',
      whereArgs: [idVenta],
    );
    return result.map(DetalleVentaModel.fromMap).toList();
  }

  Future<void> eliminarVenta(int idVenta) async {
    final db = await DatabaseService.database;
    await db.delete(
      'venta_detalle',
      where: 'id_venta = ?',
      whereArgs: [idVenta],
    );
    await db.delete('ventas', where: 'id = ?', whereArgs: [idVenta]);
  }

  Future<void> marcarSincronizado(int idVenta) async {
    final db = await DatabaseService.database;
    await db.update(
      'ventas',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [idVenta],
    );
  }

  Future<int> contarVentas() async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM ventas');
    final count = result.isNotEmpty && result.first.values.isNotEmpty
        ? result.first.values.first as int
        : 0;
    return count;
  }

  Future<double> totalVentasDelDia(DateTime fecha) async {
    final db = await DatabaseService.database;
    final fechaStr = fecha.toIso8601String().split('T').first;
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM ventas WHERE DATE(fecha) = ?',
      [fechaStr],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<int> contarVentasPorUsuario(int idUsuario) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ventas WHERE id_usuario = ?',
      [idUsuario],
    );
    return result.first.values.first as int;
  }

  Future<double> totalVentasPorUsuario(int idUsuario) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM ventas WHERE id_usuario = ?',
      [idUsuario],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> productosMasVendidos({int? limit}) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('''
      SELECT p.nombre, SUM(dv.cantidad) as total_vendido
      FROM venta_detalle dv
      JOIN productos p ON p.id = dv.id_producto
      GROUP BY dv.id_producto
      ORDER BY total_vendido DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> ventasPorRango(
    DateTime inicio,
    DateTime fin,
  ) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      '''
      SELECT * FROM ventas
      WHERE DATE(fecha) BETWEEN ? AND ?
      ORDER BY fecha DESC
      ''',
      [inicio.toIso8601String(), fin.toIso8601String()],
    );
    return result;
  }

  Future<double> totalGeneral() async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('SELECT SUM(total) as total FROM ventas');
    return (result.first['total'] as double?) ?? 0.0;
  }
}
