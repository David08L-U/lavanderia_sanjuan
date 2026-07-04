import '../models/usuario.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  // TODO: reemplazar por la URL real del servidor cuando esté desplegado.
  // ignore: unused_field
  static const _baseUrl = 'http://localhost:3000/api';

  /// Llama al endpoint de login del backend.
  ///
  /// El backend es quien valida la contraseña y decide el rol del usuario
  /// (cliente/administrador). Este servicio solo debe:
  /// - Mandar correo y contraseña.
  /// - Si el backend responde 401 (contraseña incorrecta) o 404 (usuario no
  ///   existe), lanzar [AuthException] con un mensaje para mostrar en pantalla.
  /// - Si responde 200, construir un [Usuario] a partir del JSON, incluyendo
  ///   su `rol` ("cliente" u "administrador"), para que la app navegue a la
  ///   pantalla correcta.
  Future<Usuario> login({
    required String correo,
    required String password,
  }) async {
    // TODO: sustituir este stub por la llamada real, por ejemplo:
    //
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/auth/login'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'correo': correo, 'password': password}),
    // );
    //
    // if (response.statusCode == 401) {
    //   throw AuthException('Correo o contraseña incorrectos');
    // }
    // if (response.statusCode != 200) {
    //   throw AuthException('No se pudo iniciar sesión, intenta de nuevo');
    // }
    // return Usuario.fromJson(jsonDecode(response.body));

    await Future.delayed(const Duration(milliseconds: 600));
    return Usuario(
      id: '0',
      nombre: 'Usuario',
      correo: correo,
      rol: UserRole.cliente,
    );
  }
}
