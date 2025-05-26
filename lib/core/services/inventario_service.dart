import 'dart:convert';
import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:pos_farmacia/core/models/product_model.dart';

class InventarioService {
  static Future<void> insertarProducto(ProductoModel producto) async {
    final db = await DatabaseService.database;

    // Validación previa
    final existente = await buscarPorCodigo(producto.codigo);
    if (existente != null) {
      throw Exception('Ya existe un producto con ese código.');
    }

    await db.insert('productos', {
      'codigo_barra': producto.codigo,
      'nombre': producto.nombre,
      'descripcion': producto.descripcion,
      'categorias': producto.categorias.join(','),
      'unidad_medida': producto.unidad,
      'precio_venta': producto.precio,
      'precio_compra': producto.costo,
      'stock_actual': producto.stock,
      'stock_minimo': producto.stockMinimo,
      'lote': producto.lote,
      'caducidad': producto.caducidad?.toIso8601String(),
      'imagen_url': producto.imagenUrl,
      'temperatura_minima': producto.temperaturaMinima,
      'temperatura_maxima': producto.temperaturaMaxima,
      'humedad_maxima': producto.humedadMaxima,
      'requiere_refrigeracion': producto.requiereRefrigeracion ? 1 : 0,
      'requiere_receta': producto.requiereReceta ? 1 : 0,
      'cantidad_vendida_historico': producto.cantidadVendidaHistorico,
      'ultima_venta': producto.ultimaVenta?.toIso8601String(),
      'veces_en_promocion': producto.vecesEnPromocion,
      'codigo_sat': producto.codigoSAT,
      'presentacion': producto.presentacion,
      'ubicacion_fisica': producto.ubicacionFisica,
      'productos_relacionados': jsonEncode(producto.productosRelacionados),
      'comprados_junto_a': jsonEncode(producto.compradosJuntoA),
      'activo': producto.activo ? 1 : 0,
      'fecha_creado': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> codigoExiste(String codigo, {int? exceptId}) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'productos',
      where: exceptId != null
          ? 'codigo_barra = ? AND id != ?'
          : 'codigo_barra = ?',
      whereArgs: exceptId != null ? [codigo, exceptId] : [codigo],
    );
    return result.isNotEmpty;
  }

  static Future<List<ProductoModel>> obtenerTodosLosProductos() async {
    final db = await DatabaseService.database;
    final result = await db.query('productos');
    return result.map((row) => _mapearFila(row)).toList();
  }

  static Future<void> actualizarProducto(ProductoModel producto) async {
    final db = await DatabaseService.database;

    await db.update(
      'productos',
      {
        'codigo_barra': producto.codigo,
        'nombre': producto.nombre,
        'descripcion': producto.descripcion,
        'categorias': producto.categorias.join(','),
        'unidad_medida': producto.unidad,
        'precio_venta': producto.precio,
        'precio_compra': producto.costo,
        //'stock_actual': producto.stock,
        'stock_minimo': producto.stockMinimo,
        'lote': producto.lote,
        'caducidad': producto.caducidad?.toIso8601String(),
        'imagen_url': producto.imagenUrl,
        'temperatura_minima': producto.temperaturaMinima,
        'temperatura_maxima': producto.temperaturaMaxima,
        'humedad_maxima': producto.humedadMaxima,
        'requiere_refrigeracion': producto.requiereRefrigeracion ? 1 : 0,
        'requiere_receta': producto.requiereReceta ? 1 : 0,
        'cantidad_vendida_historico': producto.cantidadVendidaHistorico,
        'ultima_venta': producto.ultimaVenta?.toIso8601String(),
        'veces_en_promocion': producto.vecesEnPromocion,
        'codigo_sat': producto.codigoSAT,
        'presentacion': producto.presentacion,
        'ubicacion_fisica': producto.ubicacionFisica,
        'productos_relacionados': jsonEncode(producto.productosRelacionados),
        'comprados_junto_a': jsonEncode(producto.compradosJuntoA),
        'activo': producto.activo ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  static Future<ProductoModel?> buscarPorCodigo(String codigo) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'productos',
      where: 'codigo_barra = ?',
      whereArgs: [codigo],
    );
    if (result.isEmpty) return null;
    return _mapearFila(result.first);
  }

  static ProductoModel _mapearFila(Map<String, dynamic> row) {
    return ProductoModel(
      id: row['id'] as int?,
      codigo: row['codigo_barra'] as String,
      nombre: row['nombre'] as String,
      descripcion: row['descripcion'] ?? '',
      categorias: (row['categorias'] as String)
          .split(',')
          .map((e) => e.trim())
          .toList(),
      unidad: row['unidad_medida'] as String,
      precio: row['precio_venta'] as double,
      costo: row['precio_compra'] as double,
      stock: row['stock_actual'] as int,
      stockMinimo: row['stock_minimo'] as int,
      lote: row['lote'],
      caducidad: row['caducidad'] != null
          ? DateTime.parse(row['caducidad'])
          : null,
      imagenUrl: row['imagen_url'],
      productosRelacionados: List<String>.from(
        jsonDecode(row['productos_relacionados'] ?? '[]'),
      ),
      compradosJuntoA: List<String>.from(
        jsonDecode(row['comprados_junto_a'] ?? '[]'),
      ),
      temperaturaMinima: row['temperatura_minima'] as double?,
      temperaturaMaxima: row['temperatura_maxima'] as double?,
      humedadMaxima: row['humedad_maxima'] as double?,
      requiereRefrigeracion: row['requiere_refrigeracion'] == 1,
      requiereReceta: row['requiere_receta'] == 1,
      cantidadVendidaHistorico: row['cantidad_vendida_historico'] as int,
      ultimaVenta: row['ultima_venta'] != null
          ? DateTime.parse(row['ultima_venta'])
          : null,
      vecesEnPromocion: row['veces_en_promocion'] as int,
      codigoSAT: row['codigo_sat'],
      presentacion: row['presentacion'],
      ubicacionFisica: row['ubicacion_fisica'],
      activo: row['activo'] == 1,
    );
  }

  static Future<void> actualizarEstadisticasPostVenta({
    required int idProducto,
    required int cantidadVendida,
  }) async {
    final db = await DatabaseService.database;

    // Obtén datos actuales
    final result = await db.query(
      'productos',
      where: 'id = ?',
      whereArgs: [idProducto],
    );

    if (result.isEmpty) return;

    final actual = result.first;
    final historico = (actual['cantidad_vendida_historico'] as int?) ?? 0;

    await db.update(
      'productos',
      {
        'cantidad_vendida_historico': historico + cantidadVendida,
        'ultima_venta': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [idProducto],
    );
  }
}
