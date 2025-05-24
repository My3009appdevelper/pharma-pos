import 'package:flutter/material.dart';
import 'package:pos_farmacia/features/stock/inventario%20por%20sucursal/logic/inventario_sucursal_model.dart';

class Categoria {
  final String nombre;
  final IconData icono;
  Categoria({required this.nombre, required this.icono});
}

class PrecioHistorico {
  final DateTime fecha;
  final double precio;

  PrecioHistorico({required this.fecha, required this.precio});
}

class CostoHistorico {
  final DateTime fecha;
  final double costo;

  CostoHistorico({required this.fecha, required this.costo});
}

class ProductoModel {
  final int? id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final List<String> categorias;
  final String unidad;
  final double precio;
  final double costo;
  final int stock;
  final int stockMinimo;
  final String? lote;
  final DateTime? caducidad;
  final String? imagenUrl;

  final List<PrecioHistorico> historialPrecios;
  final List<CostoHistorico> historialCostos;
  final List<String> productosRelacionados;
  final List<String> compradosJuntoA;

  // Variables específicas para farmacia
  final double? temperaturaMinima;
  final double? temperaturaMaxima;
  final double? humedadMaxima;
  final bool requiereRefrigeracion;
  final bool requiereReceta;
  final int cantidadVendidaHistorico;
  final DateTime? ultimaVenta;
  final int vecesEnPromocion;
  final String? codigoSAT;
  final String? presentacion;
  final String? ubicacionFisica;

  final bool activo;

  ProductoModel({
    this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion = '',
    required this.categorias,
    required this.unidad,
    required this.precio,
    required this.costo,
    this.stock = 0,
    this.stockMinimo = 0,
    this.lote,
    this.caducidad,
    this.imagenUrl,
    this.historialPrecios = const [],
    this.historialCostos = const [],
    this.productosRelacionados = const [],
    this.compradosJuntoA = const [],
    this.temperaturaMinima,
    this.temperaturaMaxima,
    this.humedadMaxima,
    this.requiereRefrigeracion = false,
    this.requiereReceta = false,
    this.cantidadVendidaHistorico = 0,
    this.ultimaVenta,
    this.vecesEnPromocion = 0,
    this.codigoSAT,
    this.presentacion,
    this.ubicacionFisica,
    this.activo = true,
  });

  int calcularStockGlobal(List<InventarioSucursalModel> inventariosSucursal) {
    return inventariosSucursal
        .where((r) => r.idProducto == id)
        .fold(0, (suma, r) => suma + r.stock);
  }

  factory ProductoModel.empty() {
    return ProductoModel(
      id: 0,
      codigo: '',
      nombre: '',
      descripcion: '',
      categorias: [],
      unidad: '',
      precio: 0.0,
      costo: 0.0,
      stock: 0,
      stockMinimo: 0,
      lote: '',
      caducidad: null,
      imagenUrl: null,
      temperaturaMinima: null,
      temperaturaMaxima: null,
      humedadMaxima: null,
      requiereRefrigeracion: false,
      requiereReceta: false,
      cantidadVendidaHistorico: 0,
      ultimaVenta: null,
      vecesEnPromocion: 0,
      codigoSAT: '',
      presentacion: '',
      ubicacionFisica: '',
      productosRelacionados: [],
      compradosJuntoA: [],
      historialPrecios: [],
      historialCostos: [],
      activo: true,
    );
  }

  ProductoModel copyWith({
    int? id,
    String? codigo,
    String? nombre,
    String? descripcion,
    List<String>? categorias,
    String? unidad,
    double? precio,
    double? costo,
    bool? requiereRefrigeracion,
    bool? requiereReceta,
    bool? activo,
    double? temperaturaMinima,
    double? temperaturaMaxima,
    double? humedadMaxima,
    String? presentacion,
    String? imagenUrl,
    List<PrecioHistorico>? historialPrecios,
    List<CostoHistorico>? historialCostos,
    List<String>? productosRelacionados,
    List<String>? compradosJuntoA,
  }) {
    return ProductoModel(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categorias: categorias ?? this.categorias,
      unidad: unidad ?? this.unidad,
      precio: precio ?? this.precio,
      costo: costo ?? this.costo,
      requiereRefrigeracion:
          requiereRefrigeracion ?? this.requiereRefrigeracion,
      requiereReceta: requiereReceta ?? this.requiereReceta,
      activo: activo ?? this.activo,
      temperaturaMinima: temperaturaMinima ?? this.temperaturaMinima,
      temperaturaMaxima: temperaturaMaxima ?? this.temperaturaMaxima,
      humedadMaxima: humedadMaxima ?? this.humedadMaxima,
      presentacion: presentacion ?? this.presentacion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      historialPrecios: historialPrecios ?? this.historialPrecios,
      historialCostos: historialCostos ?? this.historialCostos,
      productosRelacionados:
          productosRelacionados ?? this.productosRelacionados,
      compradosJuntoA: compradosJuntoA ?? this.compradosJuntoA,
    );
  }

  static vacio() {}
}
