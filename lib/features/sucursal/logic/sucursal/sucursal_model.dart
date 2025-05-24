class SucursalModel {
  final int? id;
  final String nombre;
  final String direccion;
  final String ciudad;
  final String estado;
  final String telefono;

  SucursalModel({
    this.id,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    required this.estado,
    required this.telefono,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'direccion': direccion,
    'ciudad': ciudad,
    'estado': estado,
    'telefono': telefono,
  };

  factory SucursalModel.fromMap(Map<String, dynamic> map) => SucursalModel(
    id: map['id'],
    nombre: map['nombre'],
    direccion: map['direccion'],
    ciudad: map['ciudad'],
    estado: map['estado'],
    telefono: map['telefono'],
  );
}
