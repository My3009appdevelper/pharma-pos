import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/database/database_service.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/models/detalle_venta_model.dart';
import 'package:pos_farmacia/core/services/inventario_service.dart';
import 'package:pos_farmacia/core/services/inventario_sucursal_service.dart';
import 'package:pos_farmacia/core/services/venta_service.dart';

class VentaProvider extends ChangeNotifier {
  final List<VentaModel> _ventas = [];
  final VentaService _service = VentaService();

  List<VentaModel> get ventas => List.unmodifiable(_ventas);

  void cargarVentas(List<VentaModel> nuevas) {
    _ventas.clear();
    _ventas.addAll(nuevas);
    notifyListeners();
  }

  Future<void> cargarDesdeDB() async {
    final data = await _service.obtenerVentas();
    cargarVentas(data);
  }

  Future<void> procesarVenta(
    VentaModel venta,
    List<DetalleVentaModel> detalles,
  ) async {
    final db = await DatabaseService.database;
    await db.transaction((txn) async {
      for (final d in detalles) {
        final lotes = await txn.query(
          'inventario_sucursal',
          where:
              'id_producto = ? AND id_sucursal = ? AND activo = 1 AND stock_actual > 0',
          whereArgs: [d.idProducto, venta.idSucursal],
          orderBy: 'fecha_entrada ASC',
        );

        int restante = d.cantidad;
        for (final lote in lotes) {
          if (restante <= 0) break;
          final stock = lote['stock_actual'] as int;
          final id = lote['id'] as int;
          final descontar = restante >= stock ? stock : restante;
          final nuevoStock = stock - descontar;
          await txn.update(
            'inventario_sucursal',
            {'stock_actual': nuevoStock},
            where: 'id = ?',
            whereArgs: [id],
          );
          restante -= descontar;
        }

        if (restante > 0)
          throw Exception('Stock insuficiente para producto ${d.idProducto}');
      }

      for (final d in detalles) {
        final stats = await txn.query(
          'productos',
          where: 'id = ?',
          whereArgs: [d.idProducto],
        );
        if (stats.isNotEmpty) {
          final actual = stats.first;
          final historico = (actual['cantidad_vendida_historico'] as int?) ?? 0;
          await txn.update(
            'productos',
            {
              'cantidad_vendida_historico': historico + d.cantidad,
              'ultima_venta': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [d.idProducto],
          );
        }
      }

      final idVenta = await txn.insert('ventas', venta.toMap());
      for (final d in detalles) {
        final map = d.toMap();
        map['uuid_venta'] = idVenta;
        await txn.insert('venta_detalle', map);
      }
    });

    await cargarDesdeDB(); // recargar ventas
  }

  Future<int> insertarVenta(
    VentaModel venta,
    List<DetalleVentaModel> detalles,
  ) async {
    final id = await _service.insertarVenta(venta, detalles);
    await cargarDesdeDB();
    return id;
  }

  Future<void> eliminarVenta(int idVenta) async {
    await _service.eliminarVenta(idVenta);
    _ventas.removeWhere((v) => v.id == idVenta);
    notifyListeners();
  }

  Future<void> marcarVentaSincronizada(int idVenta) async {
    await _service.marcarSincronizado(idVenta);
    await cargarDesdeDB();
  }

  Future<int> contarVentas() async => await _service.contarVentas();

  Future<double> totalVentasDelDia(DateTime fecha) async =>
      await _service.totalVentasDelDia(fecha);

  Future<int> contarVentasPorUsuario(int idUsuario) async =>
      await _service.contarVentasPorUsuario(idUsuario);

  Future<double> totalVentasPorUsuario(int idUsuario) async =>
      await _service.totalVentasPorUsuario(idUsuario);

  Future<double> totalGeneral() async => await _service.totalGeneral();

  Future<List<Map<String, dynamic>>> productosMasVendidos({int? limit}) async =>
      await _service.productosMasVendidos(limit: limit);

  Future<List<Map<String, dynamic>>> ventasPorRango(
    DateTime inicio,
    DateTime fin,
  ) async => await _service.ventasPorRango(inicio, fin);
}
