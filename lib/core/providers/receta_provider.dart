import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/receta_model.dart';
import 'package:pos_farmacia/core/models/receta_detalle_model.dart';
import 'package:pos_farmacia/core/services/receta_detalle_service.dart';
import 'package:pos_farmacia/core/services/receta_service.dart';

class RecetaProvider extends ChangeNotifier {
  final RecetaService _recetaService = RecetaService();
  final RecetaDetalleService _detalleService = RecetaDetalleService();

  RecetaModel? receta;
  List<RecetaDetalleModel> detalles = [];

  Future<void> cargarReceta(String uuidVenta) async {
    final recetas = await _recetaService.obtenerPorVenta(uuidVenta);
    receta = recetas.isNotEmpty ? recetas.first : null;
    if (receta != null) {
      detalles = await _detalleService.obtenerPorReceta(receta!.uuid);
    } else {
      detalles = [];
    }
    notifyListeners();
  }

  void limpiar() {
    receta = null;
    detalles = [];
    notifyListeners();
  }

  Future<void> guardarReceta(
    RecetaModel nuevaReceta,
    List<RecetaDetalleModel> nuevosDetalles,
  ) async {
    await _recetaService.insertar(nuevaReceta);
    for (var d in nuevosDetalles) {
      await _detalleService.insertar(d);
    }
    await cargarReceta(nuevaReceta.uuidVenta);
  }

  Future<void> eliminarDetalle(int id) async {
    await _detalleService.eliminar(id);
    detalles.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void agregarDetalle(RecetaDetalleModel detalle) {
    detalles.add(detalle);
    notifyListeners();
  }

  void actualizarDetalle(int index, RecetaDetalleModel detalle) {
    detalles[index] = detalle;
    notifyListeners();
  }
}
