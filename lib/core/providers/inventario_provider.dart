import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/services/inventario_service.dart';
import 'package:pos_farmacia/core/models/product_model.dart';

class InventarioProvider extends ChangeNotifier {
  final List<ProductoModel> _productos = [];

  List<ProductoModel> get productos => List.unmodifiable(_productos);

  Future<void> agregarProducto(ProductoModel producto) async {
    await InventarioService.insertarProducto(producto);
    _productos.add(producto);
    notifyListeners();
  }

  Future<void> actualizarProducto(int index, ProductoModel actualizado) async {
    await InventarioService.actualizarProducto(actualizado);
    _productos[index] = actualizado;
    notifyListeners();
  }

  Future<void> eliminarProducto(int id) async {
    await InventarioService.eliminarProducto(id);
    _productos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void cargarDesdeBaseDeDatos(List<ProductoModel> datos) {
    _productos.clear();
    _productos.addAll(datos);
    notifyListeners();
  }

  ProductoModel? obtenerPorCodigo(String codigo) {
    try {
      return _productos.firstWhere((p) => p.codigo == codigo);
    } catch (_) {
      return null;
    }
  }

  Future<ProductoModel?> buscarPorCodigoEnBD(String codigo) async {
    return await InventarioService.buscarPorCodigo(codigo);
  }

  Future<bool> codigoExiste(String codigo, {int? exceptId}) async {
    return await InventarioService.codigoExiste(codigo, exceptId: exceptId);
  }

  void registrarVenta(String codigo, int cantidad) {
    final producto = obtenerPorCodigo(codigo);
    if (producto != null) {
      final nuevoStock = producto.stock - cantidad;
      final actualizado = ProductoModel(
        // Copiar todo y actualizar stock y ventas
        id: producto.id,
        codigo: producto.codigo,
        nombre: producto.nombre,
        descripcion: producto.descripcion,
        categorias: producto.categorias,
        unidad: producto.unidad,
        precio: producto.precio,
        costo: producto.costo,
        stock: nuevoStock,
        stockMinimo: producto.stockMinimo,
        lote: producto.lote,
        caducidad: producto.caducidad,
        imagenUrl: producto.imagenUrl,
        historialPrecios: producto.historialPrecios,
        historialCostos: producto.historialCostos,
        productosRelacionados: producto.productosRelacionados,
        compradosJuntoA: producto.compradosJuntoA,
        temperaturaMinima: producto.temperaturaMinima,
        temperaturaMaxima: producto.temperaturaMaxima,
        humedadMaxima: producto.humedadMaxima,
        requiereRefrigeracion: producto.requiereRefrigeracion,
        requiereReceta: producto.requiereReceta,
        cantidadVendidaHistorico: producto.cantidadVendidaHistorico + cantidad,
        ultimaVenta: DateTime.now(),
        vecesEnPromocion: producto.vecesEnPromocion,
        codigoSAT: producto.codigoSAT,
        presentacion: producto.presentacion,
        ubicacionFisica: producto.ubicacionFisica,
        activo: producto.activo,
      );
      actualizarProducto(_productos.indexOf(producto), actualizado);
    }
  }

  Future<void> reemplazarProducto(ProductoModel actualizado) async {
    await InventarioService.actualizarProducto(actualizado);
    final index = _productos.indexWhere((p) => p.id == actualizado.id);
    if (index != -1) {
      _productos[index] = actualizado;
      notifyListeners();
    }
  }

  // Obtener productos relacionados
  List<ProductoModel> obtenerRelacionados(ProductoModel? base) {
    if (base == null || base.codigo.isEmpty) return _productos.take(5).toList();

    if (base.productosRelacionados.isNotEmpty) {
      return _productos
          .where((p) => base.productosRelacionados.contains(p.codigo))
          .toList();
    } else {
      return _productos
          .where(
            (p) =>
                p.codigo != base.codigo &&
                p.categorias.any((cat) => base.categorias.contains(cat)),
          )
          .take(5)
          .toList();
    }
  }

  Future<void> cargarDesdeBD() async {
    final lista = await InventarioService.obtenerTodosLosProductos();
    cargarDesdeBaseDeDatos(lista);
  }
}
