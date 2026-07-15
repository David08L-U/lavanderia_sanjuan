/// Un solo lugar para la URL del backend, en vez de repetirla en cada
/// servicio. Cuando el backend ya esté desplegado en la nube, este es el
/// único archivo que hay que editar (y recompilar el APK) para que la app
/// deje de depender de que la compu de alguien tenga `dotnet run` corriendo.
class ApiConfig {
  const ApiConfig._();

  /// URL base de la API. Reemplaza esto por la URL pública una vez que el
  /// backend esté desplegado (ej. 'https://freshclean-backend.onrender.com/api').
  ///
  /// 'http://localhost:5162/api' solo funciona para desarrollo local: en un
  /// emulador de Android (con la IP 10.0.2.2, no localhost) o en un celular
  /// físico conectado por USB con `adb reverse tcp:5162 tcp:5162` corrido antes
  /// de abrir la app. No funciona si compartes el APK con alguien más.
  static const String baseUrl = 'http://localhost:5162/api';
}
