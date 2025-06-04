class RecetaDetalleModel {
  final int? id;
  final String uuidReceta; // UUID de la receta
  final int idProducto; // Producto asociado
  final int cantidad; // Cantidad autorizada
  final String? indicaciones; // Ej. "1 tableta cada 8 horas"
  final DateTime creadoEn;
  final DateTime? modificadoEn;
  final bool sincronizado;

  RecetaDetalleModel({
    this.id,
    required this.uuidReceta,
    required this.idProducto,
    required this.cantidad,
    this.indicaciones,
    required this.creadoEn,
    this.modificadoEn,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'uuid_receta': uuidReceta,
    'id_producto': idProducto,
    'cantidad': cantidad,
    'indicaciones': indicaciones,
    'creado_en': creadoEn.toIso8601String(),
    'modificado_en': modificadoEn?.toIso8601String(),
    'sincronizado': sincronizado ? 1 : 0,
  };

  factory RecetaDetalleModel.fromMap(Map<String, dynamic> map) =>
      RecetaDetalleModel(
        id: map['id'],
        uuidReceta: map['uuid_receta'],
        idProducto: map['id_producto'],
        cantidad: map['cantidad'],
        indicaciones: map['indicaciones'],
        creadoEn: DateTime.parse(map['creado_en']),
        modificadoEn: map['modificado_en'] != null
            ? DateTime.parse(map['modificado_en'])
            : null,
        sincronizado: map['sincronizado'] == 1,
      );
}
