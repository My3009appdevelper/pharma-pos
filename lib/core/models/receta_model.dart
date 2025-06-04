class RecetaModel {
  final int? id;
  final String uuid; // ID único de la receta
  final String uuidVenta; // Venta asociada
  final String nombrePaciente;
  final String nombreMedico;
  final String cedulaProfesional;
  final String? observaciones;
  final DateTime fechaEmision;
  final DateTime creadoEn;
  final DateTime? modificadoEn;
  final bool sincronizado;

  RecetaModel({
    this.id,
    required this.uuid,
    required this.uuidVenta,
    required this.nombrePaciente,
    required this.nombreMedico,
    required this.cedulaProfesional,
    this.observaciones,
    required this.fechaEmision,
    required this.creadoEn,
    this.modificadoEn,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'uuid': uuid,
    'uuid_venta': uuidVenta,
    'nombre_paciente': nombrePaciente,
    'nombre_medico': nombreMedico,
    'cedula_profesional': cedulaProfesional,
    'observaciones': observaciones,
    'fecha_emision': fechaEmision.toIso8601String(),
    'creado_en': creadoEn.toIso8601String(),
    'modificado_en': modificadoEn?.toIso8601String(),
    'sincronizado': sincronizado ? 1 : 0,
  };

  factory RecetaModel.fromMap(Map<String, dynamic> map) => RecetaModel(
    id: map['id'],
    uuid: map['uuid'],
    uuidVenta: map['uuid_venta'],
    nombrePaciente: map['nombre_paciente'],
    nombreMedico: map['nombre_medico'],
    cedulaProfesional: map['cedula_profesional'],
    observaciones: map['observaciones'],
    fechaEmision: DateTime.parse(map['fecha_emision']),
    creadoEn: DateTime.parse(map['creado_en']),
    modificadoEn: map['modificado_en'] != null
        ? DateTime.parse(map['modificado_en'])
        : null,
    sincronizado: map['sincronizado'] == 1,
  );
}
