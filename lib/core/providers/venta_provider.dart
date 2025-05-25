import 'package:flutter/material.dart';
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
    // 1. Validar stock
    for (final d in detalles) {
      final lotes = await InventarioSucursalService.obtenerPorProductoYSucursal(
        d.idProducto,
        venta.idSucursal,
      );
      final stockDisponible = lotes.fold<int>(0, (s, l) => s + l.stock);
      if (stockDisponible < d.cantidad) {
        throw Exception('Stock insuficiente para producto ID ${d.idProducto}');
      }
    }

    // 2. Descontar del inventario por sucursal
    for (final d in detalles) {
      await InventarioSucursalService.descontarStock(
        d.idProducto,
        venta.idSucursal,
        d.cantidad,
      );
      await InventarioSucursalService.actualizarStockGlobal(d.idProducto);
    }

    // 3. Actualizar estadísticas del producto
    for (final d in detalles) {
      await InventarioService.actualizarEstadisticasPostVenta(
        idProducto: d.idProducto,
        cantidadVendida: d.cantidad,
      );
    }

    // 4. Registrar venta + detalles
    await VentaService().insertarVenta(venta, detalles);

    // 5. Refrescar lista de ventas
    await cargarDesdeDB();
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
