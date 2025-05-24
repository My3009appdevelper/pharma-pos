// lib/core/database/database_service.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'db_schema.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    return await _initDB();
  }

  static Future<Database> _initDB() async {
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, 'pos_farmacia.db');

    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      ),
    );

    _db = db;
    return db;
  }

  static Future<void> _createTables(Database db) async {
    await db.execute(DBSchema.createProductos);
    await db.execute(DBSchema.createVentas);
    await db.execute(DBSchema.createVentaDetalle);
    await db.execute(DBSchema.createUsuarios);
    await db.execute(DBSchema.createMovimientosStock);
    await db.execute(DBSchema.createSyncLog);
    await db.execute(DBSchema.createSucursales);
    await db.execute(DBSchema.createInventarioSucursal);
    await db.execute(DBSchema.createLotesProducto);
  }

  static Future<void> borrarBaseDeDatos() async {
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, 'pos_farmacia.db');
    final file = File(path);

    // 1. Cierra si está abierta
    if (_db != null) {
      await _db!.close();
      _db = null;
      print('🔒 Base de datos cerrada.');
    }

    // 2. Borra archivo
    if (await file.exists()) {
      await file.delete();
      print('🗑️ Base de datos eliminada correctamente.');
    } else {
      print('⚠️ No se encontró la base de datos.');
    }
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
