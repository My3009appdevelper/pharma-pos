import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/inventario_service.dart';
import 'package:pos_farmacia/features/stock/inventario/logic/product_model.dart';

class InventarioProvider extends ChangeNotifier {
  final List<ProductoModel> _productos = [];

  List<ProductoModel> get productos => List.unmodifiable(_productos);

  void agregarProducto(ProductoModel producto) {
    _productos.add(producto);
    notifyListeners();
  }

  void actualizarProducto(int index, ProductoModel actualizado) {
    _productos[index] = actualizado;
    notifyListeners();
  }

  void eliminarProducto(int index) {
    _productos.removeAt(index);
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

  Future<void> cargarDesdeBD() async {
    final lista = await InventarioService.obtenerTodosLosProductos();
    cargarDesdeBaseDeDatos(lista);
  }
}
