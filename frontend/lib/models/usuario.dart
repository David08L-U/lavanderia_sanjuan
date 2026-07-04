enum UserRole { cliente, administrador }

UserRole userRoleFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'administrador':
    case 'admin':
      return UserRole.administrador;
    case 'cliente':
    default:
      return UserRole.cliente;
  }
}

class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? json['email'] as String? ?? '',
      rol: userRoleFromString(json['rol'] as String? ?? json['role'] as String?),
    );
  }

  final String id;
  final String nombre;
  final String correo;
  final UserRole rol;
}
