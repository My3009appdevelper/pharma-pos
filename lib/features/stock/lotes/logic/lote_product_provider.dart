import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/lotes/logic/lote_producto_model.dart';
import 'package:pos_farmacia/features/stock/lotes/logic/lote_producto_service.dart';

class LoteProductoProvider extends ChangeNotifier {
  final List<LoteProductoModel> _lotes = [];

  List<LoteProductoModel> get lotes => List.unmodifiable(_lotes);

  Future<void> cargarDesdeBD() async {
    final data = await LoteProductoService.obtenerTodos();
    _lotes.clear();
    _lotes.addAll(data);
    notifyListeners();
  }

  Future<void> cargarPorProducto(int idProducto) async {
    final data = await LoteProductoService.obtenerPorProducto(idProducto);
    _lotes.clear();
    _lotes.addAll(data);
    notifyListeners();
  }

  Future<void> cargarPorProductoYSucursal(
    int idProducto,
    int idSucursal,
  ) async {
    final data = await LoteProductoService.obtenerPorProductoYSucursal(
      idProducto,
      idSucursal,
    );
    _lotes.clear();
    _lotes.addAll(data);
    notifyListeners();
  }

  Future<void> agregarLote(LoteProductoModel lote) async {
    await LoteProductoService.insertar(lote);
    await cargarDesdeBD();
  }

  Future<void> actualizarLote(LoteProductoModel lote) async {
    await LoteProductoService.actualizar(lote);
    await cargarDesdeBD();
  }

  Future<void> eliminarLote(int id) async {
    await LoteProductoService.eliminar(id);
    await cargarDesdeBD();
  }

  List<LoteProductoModel> obtenerLotesPEPS(int idProducto, int idSucursal) {
    return _lotes
        .where(
          (l) =>
              l.idProducto == idProducto &&
              l.idSucursal == idSucursal &&
              l.activo,
        )
        .toList()
      ..sort((a, b) => a.fechaCaducidad.compareTo(b.fechaCaducidad));
  }
}
