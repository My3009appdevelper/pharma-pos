import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/models/cliente_model.dart';
import 'package:pos_farmacia/core/services/cliente_service.dart';

class ClienteProvider extends ChangeNotifier {
  final ClienteService _clienteService = ClienteService();

  List<ClienteModel> _clientes = [];
  ClienteModel? _clienteSeleccionado;

  List<ClienteModel> get clientes => List.unmodifiable(_clientes);
  ClienteModel? get clienteSeleccionado => _clienteSeleccionado;

  /// Carga todos los clientes de la base de datos
  Future<void> cargarClientes() async {
    _clientes = await _clienteService.obtenerClientes();
    notifyListeners();
  }

  /// Selecciona un cliente en el flujo de venta
  void seleccionarCliente(ClienteModel cliente) {
    _clienteSeleccionado = cliente;
    notifyListeners();
  }

  /// Limpia la selección actual (por ejemplo, nueva venta)
  void limpiarSeleccion() {
    _clienteSeleccionado = null;
    notifyListeners();
  }

  /// Agrega un cliente nuevo a la BD y al estado local
  Future<void> agregarCliente(ClienteModel cliente) async {
    await _clienteService.insertarCliente(cliente);
    await cargarClientes(); // Refresca la lista
  }

  /// Actualiza un cliente en la base y en memoria
  Future<void> actualizarCliente(ClienteModel cliente) async {
    await _clienteService.actualizarCliente(cliente);
    await cargarClientes();
    if (_clienteSeleccionado?.uuidCliente == cliente.uuidCliente) {
      _clienteSeleccionado = cliente;
    }
    notifyListeners();
  }

  /// Elimina un cliente por su UUID
  Future<void> eliminarCliente(String uuidCliente) async {
    await _clienteService.eliminarClientePorUuid(uuidCliente);
    await cargarClientes();
    if (_clienteSeleccionado?.uuidCliente == uuidCliente) {
      limpiarSeleccion();
    }
    notifyListeners();
  }

  /// Actualiza solo los puntos acumulados
  Future<void> actualizarPuntos(String uuidCliente, int nuevosPuntos) async {
    await _clienteService.actualizarPuntos(uuidCliente, nuevosPuntos);
    await cargarClientes();
    notifyListeners();
  }
}
// This file is part of the POS Farmacia project.
// It defines the ClienteProvider class which manages the state and operations related to clients in the pharmacy POS system.