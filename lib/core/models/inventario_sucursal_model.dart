class InventarioSucursalModel {
  final int? id;
  final int idProducto;
  final int idSucursal;
  final int stock;
  final int stockMinimo;
  final String? lote;
  final DateTime? caducidad;
  final DateTime? fechaEntrada;
  final double? precioCompra;
  final double? precioVenta;
  final bool activo;
  final String ubicacionFisica;
  final String presentacion;

  InventarioSucursalModel({
    this.id,
    required this.idProducto,
    required this.idSucursal,
    required this.stock,
    this.stockMinimo = 0,
    this.lote,
    this.caducidad,
    this.fechaEntrada,
    this.precioCompra,
    this.precioVenta,
    this.activo = true,
    this.ubicacionFisica = '',
    this.presentacion = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'id_producto': idProducto,
    'id_sucursal': idSucursal,
    'stock_actual': stock,
    'stock_minimo': stockMinimo,
    'lote': lote,
    'caducidad': caducidad?.toIso8601String(),
    'fecha_entrada': fechaEntrada?.toIso8601String(),
    'precio_compra': precioCompra,
    'precio_venta': precioVenta,
    'activo': activo ? 1 : 0,
    'ubicacion_fisica': ubicacionFisica,
    'presentacion': presentacion,
  };

  factory InventarioSucursalModel.fromMap(Map<String, dynamic> map) =>
      InventarioSucursalModel(
        id: map['id'],
        idProducto: map['id_producto'],
        idSucursal: map['id_sucursal'],
        stock: map['stock_actual'],
        stockMinimo: map['stock_minimo'],
        lote: map['lote'],
        caducidad: map['caducidad'] != null
            ? DateTime.tryParse(map['caducidad'])
            : null,
        fechaEntrada: map['fecha_entrada'] != null
            ? DateTime.tryParse(map['fecha_entrada'])
            : null,
        precioCompra: map['precio_compra'] != null
            ? double.tryParse(map['precio_compra'].toString())
            : null,
        precioVenta: map['precio_venta'] != null
            ? double.tryParse(map['precio_venta'].toString())
            : null,
        activo: map['activo'] == 1,
        ubicacionFisica: map['ubicacion_fisica'] ?? '',
        presentacion: map['presentacion'] ?? '',
      );

  int get stockActual => stock;
}
