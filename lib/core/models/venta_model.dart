class VentaModel {
  final int? id;
  final String uuid;
  final String folio;
  final DateTime fecha;
  final int idSucursal;
  final int idUsuario;
  final String? uuid_cliente;
  final double total;
  final double subtotal;
  final double descuentoTotal;
  final String metodoPago;
  final String? observaciones;
  final DateTime creadoEn;
  final DateTime? modificadoEn;
  final int sincronizado;

  VentaModel({
    this.id,
    required this.uuid,
    required this.folio,
    required this.fecha,
    required this.idSucursal,
    required this.idUsuario,
    this.uuid_cliente,
    required this.total,
    required this.subtotal,
    required this.descuentoTotal,
    required this.metodoPago,
    this.observaciones,
    required this.creadoEn,
    this.modificadoEn,
    this.sincronizado = 0,
  });

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'folio': folio,
    'fecha': fecha.toIso8601String(),
    'id_sucursal': idSucursal,
    'id_usuario': idUsuario,
    'uuid_cliente': uuid_cliente,
    'total': total,
    'subtotal': subtotal,
    'descuento_total': descuentoTotal,
    'metodo_pago': metodoPago,
    'observaciones': observaciones,
    'creado_en': creadoEn.toIso8601String(),
    'modificado_en': modificadoEn?.toIso8601String(),
    'sincronizado': sincronizado,
  };

  factory VentaModel.fromMap(Map<String, dynamic> map) => VentaModel(
    id: map['id'],
    uuid: map['uuid'],
    folio: map['folio'],
    fecha: DateTime.parse(map['fecha']),
    idSucursal: map['id_sucursal'],
    idUsuario: map['id_usuario'],
    uuid_cliente: map['uuid_cliente'],
    total: map['total'],
    subtotal: map['subtotal'],
    descuentoTotal: map['descuento_total'],
    metodoPago: map['metodo_pago'],
    observaciones: map['observaciones'],
    creadoEn: DateTime.parse(map['creado_en']),
    modificadoEn: map['modificado_en'] != null
        ? DateTime.parse(map['modificado_en'])
        : null,
    sincronizado: map['sincronizado'] ?? 0,
  );
}
