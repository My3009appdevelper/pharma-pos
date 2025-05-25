import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/venta_model.dart';
import 'package:pos_farmacia/core/models/detalle_venta_model.dart';
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
