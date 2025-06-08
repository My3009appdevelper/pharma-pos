class ClienteModel {
  final int? id;
  final String uuid_cliente;

  final String nombreCompleto;
  final String? apellido;
  final String? telefono;
  final String? email;

  final String? direccion;
  final String? ciudad;
  final String? estado;
  final String? codigoPostal;

  final DateTime creadoEn;
  final DateTime modificadoEn;

  // Datos fiscales (para facturación SAT)
  final String? rfc;
  final String? razonSocial;
  final String? usoCfdi;
  final String? regimenFiscal;

  // Puntos de cliente
  final int puntosAcumulados;

  ClienteModel({
    this.id,
    required this.uuid_cliente,
    required this.nombreCompleto,
    this.apellido,
    this.telefono,
    this.email,
    this.direccion,
    this.ciudad,
    this.estado,
    this.codigoPostal,
    required this.creadoEn,
    required this.modificadoEn,
    this.rfc,
    this.razonSocial,
    this.usoCfdi,
    this.regimenFiscal,
    this.puntosAcumulados = 0,
  });

  factory ClienteModel.fromMap(Map<String, dynamic> map) {
    return ClienteModel(
      id: map['id'],
      uuid_cliente: map['uuid_cliente'],
      nombreCompleto: map['nombreCompleto'],
      apellido: map['apellido'],
      telefono: map['telefono'],
      email: map['email'],
      direccion: map['direccion'],
      ciudad: map['ciudad'],
      estado: map['estado'],
      codigoPostal: map['codigo_postal'],
      creadoEn: DateTime.tryParse(map['creadoEn'] ?? '') ?? DateTime.now(),
      modificadoEn:
          DateTime.tryParse(map['modificadoEn'] ?? '') ?? DateTime.now(),
      rfc: map['rfc'],
      razonSocial: map['razonSocial'],
      usoCfdi: map['usoCfdi'],
      regimenFiscal: map['regimenFiscal'],
      puntosAcumulados: map['puntosAcumulados'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid_cliente': uuid_cliente,
      'nombreCompleto': nombreCompleto,
      'apellido': apellido,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'ciudad': ciudad,
      'estado': estado,
      'codigo_postal': codigoPostal,
      'creadoEn': creadoEn.toIso8601String(),
      'modificadoEn': modificadoEn.toIso8601String(),
      'rfc': rfc,
      'razonSocial': razonSocial,
      'usoCfdi': usoCfdi,
      'regimenFiscal': regimenFiscal,
      'puntosAcumulados': puntosAcumulados,
    };
  }

  ClienteModel copyWith({
    int? id,
    String? uuid_cliente,
    String? nombreCompleto,
    String? apellido,
    String? telefono,
    String? email,
    String? direccion,
    String? ciudad,
    String? estado,
    String? codigoPostal,
    DateTime? creadoEn,
    DateTime? modificadoEn,
    String? rfc,
    String? razonSocial,
    String? usoCfdi,
    String? regimenFiscal,
    int? puntosAcumulados,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      uuid_cliente: uuid_cliente ?? this.uuid_cliente,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      estado: estado ?? this.estado,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      creadoEn: creadoEn ?? this.creadoEn,
      modificadoEn: modificadoEn ?? this.modificadoEn,
      rfc: rfc ?? this.rfc,
      razonSocial: razonSocial ?? this.razonSocial,
      usoCfdi: usoCfdi ?? this.usoCfdi,
      regimenFiscal: regimenFiscal ?? this.regimenFiscal,
      puntosAcumulados: puntosAcumulados ?? this.puntosAcumulados,
    );
  }
}
