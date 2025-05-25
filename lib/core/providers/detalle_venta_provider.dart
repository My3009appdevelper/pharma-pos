import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/detalle_venta_model.dart';
import 'package:pos_farmacia/core/services/detalle_venta_service.dart';

class DetalleVentaProvider extends ChangeNotifier {
  final List<DetalleVentaModel> _detalles = [];
  final DetalleVentaService _service = DetalleVentaService();

  List<DetalleVentaModel> get detalles => List.unmodifiable(_detalles);

  void cargarDetalles(List<DetalleVentaModel> nuevos) {
    _detalles.clear();
    _detalles.addAll(nuevos);
    notifyListeners();
  }

  void agregarDetalle(DetalleVentaModel detalle) {
    _detalles.add(detalle);
    notifyListeners();
  }

  void eliminarDetalle(DetalleVentaModel detalle) {
    _detalles.remove(detalle);
    notifyListeners();
  }

  void limpiarDetalles() {
    _detalles.clear();
    notifyListeners();
  }

  double get totalVenta => _detalles.fold(0.0, (suma, d) => suma + d.total);

  Future<void> guardarDetalles(String uuidVenta) async {
    final detallesConUUID = _detalles
        .map(
          (d) => DetalleVentaModel(
            id: d.id,
            uuidVenta: uuidVenta,
            idProducto: d.idProducto,
            cantidad: d.cantidad,
            precioUnitario: d.precioUnitario,
            descuento: d.descuento,
            total: d.total,
            idSucursal: d.idSucursal,
            creadoEn: d.creadoEn,
            modificadoEn: d.modificadoEn,
            sincronizado: d.sincronizado,
          ),
        )
        .toList();
    await _service.insertarMultiplesDetalles(detallesConUUID);
  }

  Future<void> cargarDesdeDB(String uuidVenta) async {
    final result = await _service.obtenerPorUuid(uuidVenta);
    cargarDetalles(result);
  }

  Future<void> eliminarDesdeDB(String uuidVenta) async {
    await _service.eliminarPorUuid(uuidVenta);
    limpiarDetalles();
  }

  Future<void> marcarSincronizados(String uuidVenta) async {
    await _service.marcarSincronizados(uuidVenta);
  }

  Future<List<DetalleVentaModel>> obtenerTodos() async {
    return await _service.obtenerTodos();
  }

  Future<int> contarDetalles() async {
    return await _service.contarDetalles();
  }
}
