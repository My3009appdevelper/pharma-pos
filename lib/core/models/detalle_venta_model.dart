class DetalleVentaModel {
  final int? id;
  final String uuidVenta;
  final int idProducto;
  final int cantidad;
  final double precioUnitario;
  final double descuento;
  final double total;
  final int? idSucursal;
  final DateTime? creadoEn;
  final DateTime? modificadoEn;
  final bool sincronizado;

  DetalleVentaModel({
    this.id,
    required this.uuidVenta,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.total,
    this.idSucursal,
    this.creadoEn,
    this.modificadoEn,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'uuid_venta': uuidVenta,
    'id_producto': idProducto,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
    'descuento': descuento,
    'total': total,
    'id_sucursal': idSucursal,
    'creado_en': creadoEn?.toIso8601String(),
    'modificado_en': modificadoEn?.toIso8601String(),
    'sincronizado': sincronizado ? 1 : 0,
  };

  factory DetalleVentaModel.fromMap(Map<String, dynamic> map) =>
      DetalleVentaModel(
        id: map['id'],
        uuidVenta: map['uuid_venta'],
        idProducto: map['id_producto'],
        cantidad: map['cantidad'],
        precioUnitario: map['precio_unitario'],
        descuento: map['descuento'],
        total: map['total'],
        idSucursal: map['id_sucursal'],
        creadoEn: map['creado_en'] != null
            ? DateTime.parse(map['creado_en'])
            : null,
        modificadoEn: map['modificado_en'] != null
            ? DateTime.parse(map['modificado_en'])
            : null,
        sincronizado: map['sincronizado'] == 1,
      );

  copyWith({required int idVenta, required String uuidVenta}) {}
}
