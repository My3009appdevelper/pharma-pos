class UsuarioModel {
  final int? id;
  final String username;
  final String password; // Hasheada
  final String nombreCompleto;
  final String rol;
  final bool activo;
  final int? idSucursal; // Nueva variable opcional

  UsuarioModel({
    this.id,
    required this.username,
    required this.password,
    required this.nombreCompleto,
    required this.rol,
    this.activo = true,
    this.idSucursal,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'password': password,
    'nombre_completo': nombreCompleto,
    'rol': rol,
    'activo': activo ? 1 : 0,
    'id_sucursal': idSucursal,
  };

  factory UsuarioModel.fromMap(Map<String, dynamic> map) => UsuarioModel(
    id: map['id'],
    username: map['username'],
    password: map['password'],
    nombreCompleto: map['nombre_completo'],
    rol: map['rol'],
    activo: map['activo'] == 1,
    idSucursal: map['id_sucursal'],
  );
}
