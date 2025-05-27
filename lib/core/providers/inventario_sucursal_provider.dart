import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/inventario_sucursal_model.dart';
import 'package:pos_farmacia/core/services/inventario_sucursal_service.dart';

class InventarioSucursalProvider extends ChangeNotifier {
  final List<InventarioSucursalModel> _inventarioSucursal = [];
  final List<InventarioSucursalModel> _inventarioCompleto = [];

  List<InventarioSucursalModel> get inventario =>
      List.unmodifiable(_inventarioSucursal);
  List<InventarioSucursalModel> get inventarioCompleto =>
      List.unmodifiable(_inventarioCompleto);

  void cargarInventario(List<InventarioSucursalModel> lista) {
    _inventarioSucursal.clear();
    _inventarioSucursal.addAll(lista);
    notifyListeners();
  }

  void cargarInventarioCompleto(List<InventarioSucursalModel> lista) {
    _inventarioCompleto.clear();
    _inventarioCompleto.addAll(lista);
  }

  Future<void> agregarRegistro(InventarioSucursalModel registro) async {
    await InventarioSucursalService.insertar(registro); // inserta en BD
    await InventarioSucursalService.actualizarStockGlobal(
      registro.idProducto,
    ); // actualiza stock global
    await cargarDesdeBD(); // recarga para reflejar los cambios
  }

  Future<void> actualizarRegistro(
    int index,
    InventarioSucursalModel actualizado,
  ) async {
    await InventarioSucursalService.actualizar(actualizado);
    _inventarioSucursal[index] = actualizado;
    await InventarioSucursalService.actualizarStockGlobal(
      actualizado.idProducto,
    );
    notifyListeners();
  }

  Future<void> eliminarRegistro(int index) async {
    final id = _inventarioSucursal[index].id;
    if (id != null) {
      await InventarioSucursalService.eliminar(id);
      _inventarioSucursal.removeAt(index);
      notifyListeners();
    }
  }

  List<InventarioSucursalModel> obtenerPorSucursal(int idSucursal) {
    return _inventarioSucursal
        .where((r) => r.idSucursal == idSucursal)
        .toList();
  }

  List<InventarioSucursalModel> obtenerPorProductoYSucursal(
    int idProducto,
    int idSucursal,
  ) {
    return _inventarioSucursal
        .where((r) => r.idProducto == idProducto && r.idSucursal == idSucursal)
        .toList();
  }

  Future<void> cargarDesdeBD() async {
    final data = await InventarioSucursalService.obtenerTodo();
    cargarInventarioCompleto(data);
    cargarInventario(data);
  }

  Future<void> cargarPorSucursal(int idSucursal) async {
    final data = await InventarioSucursalService.obtenerPorSucursal(idSucursal);
    final todos = await InventarioSucursalService.obtenerTodo();
    cargarInventarioCompleto(todos);
    cargarInventario(data);
  }

  int stockGlobalPorProducto(int idProducto) {
    return _inventarioCompleto
        .where((r) => r.idProducto == idProducto)
        .fold<int>(0, (sum, r) => sum + r.stock);
  }

  List<InventarioSucursalModel> obtenerLotesActivosPorProducto(
    int idProducto,
    int idSucursal,
  ) {
    return _inventarioSucursal
        .where(
          (r) =>
              r.idProducto == idProducto &&
              r.idSucursal == idSucursal &&
              r.activo,
        )
        .toList();
  }
}
