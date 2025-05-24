import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/sucursal/logic/sucursal/sucursal_model.dart';
import 'package:pos_farmacia/features/sucursal/logic/sucursal/sucursal_service.dart';

class SucursalProvider extends ChangeNotifier {
  List<SucursalModel> _sucursales = [];
  SucursalModel? _sucursalActual;

  List<SucursalModel> get sucursales => List.unmodifiable(_sucursales);
  SucursalModel? get sucursalActual => _sucursalActual;

  Future<void> cargarSucursales() async {
    _sucursales = await SucursalService.obtenerTodas();
    notifyListeners();
  }

  Future<void> agregarSucursal(SucursalModel sucursal) async {
    await SucursalService.insertar(sucursal);
    await cargarSucursales();
    notifyListeners();
  }

  Future<void> actualizarSucursal(SucursalModel sucursal) async {
    await SucursalService.actualizar(sucursal);
    await cargarSucursales();
    notifyListeners();
  }

  void seleccionarSucursal(SucursalModel sucursal) {
    _sucursalActual = sucursal;
    notifyListeners();
  }

  void seleccionarSucursalPorId(int id) {
    _sucursalActual = _sucursales.firstWhere(
      (s) => s.id == id,
      orElse: () => _sucursales.isNotEmpty
          ? _sucursales.first
          : SucursalModel(
              id: 0,
              nombre: 'Ninguna',
              direccion: '',
              telefono: '',
              ciudad: '',
              estado: '',
            ),
    );
    notifyListeners();
  }
}
