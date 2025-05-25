import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:pos_farmacia/core/models/inventario_sucursal_model.dart';

class InventarioSucursalService {
  static Future<void> insertar(InventarioSucursalModel inv) async {
    final db = await DatabaseService.database;
    await db.insert('inventario_sucursal', inv.toMap());
    print(
      '✅ Insertado inventario: producto=${inv.idProducto} sucursal=${inv.idSucursal}',
    );
  }

  static Future<void> actualizar(InventarioSucursalModel inv) async {
    final db = await DatabaseService.database;
    await db.update(
      'inventario_sucursal',
      inv.toMap(),
      where: 'id = ?',
      whereArgs: [inv.id],
    );
  }

  static Future<List<InventarioSucursalModel>> obtenerTodo() async {
    final db = await DatabaseService.database;
    final data = await db.query('inventario_sucursal');
    return data.map((e) => InventarioSucursalModel.fromMap(e)).toList();
  }

  static Future<List<InventarioSucursalModel>> obtenerPorSucursal(
    int idSucursal,
  ) async {
    final db = await DatabaseService.database;
    final data = await db.query(
      'inventario_sucursal',
      where: 'id_sucursal = ? AND activo = 1',
      whereArgs: [idSucursal],
    );
    return data.map((e) => InventarioSucursalModel.fromMap(e)).toList();
  }

  static Future<List<InventarioSucursalModel>> obtenerPorProductoYSucursal(
    int idProducto,
    int idSucursal,
  ) async {
    final db = await DatabaseService.database;
    final data = await db.query(
      'inventario_sucursal',
      where: 'id_producto = ? AND id_sucursal = ? AND activo = 1',
      whereArgs: [idProducto, idSucursal],
    );
    return data.map((e) => InventarioSucursalModel.fromMap(e)).toList();
  }

  static Future<void> actualizarStockGlobal(int idProducto) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(stock_actual) as total FROM inventario_sucursal WHERE id_producto = ? AND activo = 1',
      [idProducto],
    );
    final total = (result.first['total'] as int?) ?? 0;
    await db.update(
      'productos',
      {'stock_actual': total},
      where: 'id = ?',
      whereArgs: [idProducto],
    );
  }

  static Future<void> eliminar(int id) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'inventario_sucursal',
      where: 'id = ?',
      whereArgs: [id],
    );
    final idProducto = result.isNotEmpty
        ? result.first['id_producto'] as int
        : null;
    await db.delete('inventario_sucursal', where: 'id = ?', whereArgs: [id]);
    if (idProducto != null) {
      await actualizarStockGlobal(idProducto);
    }
  }
}
