// lib/features/stock/logic/lote_producto_model.dart

class LoteProductoModel {
  final int? id;
  final int idProducto;
  final int idSucursal;
  final String lote;
  final DateTime fechaEntrada;
  final DateTime fechaCaducidad;
  final int stock;
  final double precioCompra;
  final double precioVenta;
  final bool activo;

  LoteProductoModel({
    this.id,
    required this.idProducto,
    required this.idSucursal,
    required this.lote,
    required this.fechaEntrada,
    required this.fechaCaducidad,
    required this.stock,
    required this.precioCompra,
    required this.precioVenta,
    this.activo = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'id_producto': idProducto,
    'id_sucursal': idSucursal,
    'lote': lote,
    'fecha_entrada': fechaEntrada.toIso8601String(),
    'fecha_caducidad': fechaCaducidad.toIso8601String(),
    'stock': stock,
    'precio_compra': precioCompra,
    'precio_venta': precioVenta,
    'activo': activo ? 1 : 0,
  };

  factory LoteProductoModel.fromMap(Map<String, dynamic> map) =>
      LoteProductoModel(
        id: map['id'],
        idProducto: map['id_producto'],
        idSucursal: map['id_sucursal'],
        lote: map['lote'],
        fechaEntrada: DateTime.parse(map['fecha_entrada']),
        fechaCaducidad: DateTime.parse(map['fecha_caducidad']),
        stock: map['stock'],
        precioCompra: map['precio_compra'],
        precioVenta: map['precio_venta'],
        activo: map['activo'] == 1,
      );
}
