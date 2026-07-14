import 'package:flutter/material.dart';

import '../models/direccion.dart';
import '../services/direccion_service.dart';

/// Fuente única de las direcciones guardadas del cliente, compartida entre
/// Mis Direcciones, Seleccionar Dirección y el flujo de Agendar Recolección.
class DireccionesProvider extends ChangeNotifier {
  DireccionesProvider({DireccionService? direccionService})
    : _direccionService = direccionService ?? DireccionService() {
    Future.microtask(cargar);
  }

  final DireccionService _direccionService;
  final List<Direccion> _direcciones = [];

  List<Direccion> get direcciones => List.unmodifiable(_direcciones);

  /// Null si todavía no ha cargado ninguna dirección (primera carga en
  /// curso, falló la conexión, o el cliente aún no tiene direcciones
  /// guardadas). Las pantallas que la usan deben manejar ese caso en vez
  /// de asumir que siempre hay al menos una.
  Direccion? get predeterminada => _direcciones.isEmpty
      ? null
      : _direcciones.firstWhere(
          (direccion) => direccion.predeterminada,
          orElse: () => _direcciones.first,
        );

  Future<void> cargar() async {
    try {
      final datos = await _direccionService.listarDirecciones();
      _direcciones
        ..clear()
        ..addAll(datos);
      notifyListeners();
    } catch (_) {
      // Se conserva la lista local vacía si la API no responde.
    }
  }

  Future<void> agregar(Direccion direccion) async {
    try {
      final guardada = await _direccionService.crearDireccion(direccion);
      _direcciones.add(guardada);
      notifyListeners();
    } catch (_) {
      final esLaPrimera = _direcciones.isEmpty;
      _direcciones.add(esLaPrimera ? direccion.copyWith(predeterminada: true) : direccion);
      notifyListeners();
    }
  }

  Future<void> actualizar(int index, Direccion direccion) async {
    final id = _direcciones[index].id;
    if (id == null) {
      // Nunca se guardó en el backend (id desconocido): solo se puede
      // actualizar el estado local.
      _direcciones[index] = direccion;
      notifyListeners();
      return;
    }

    try {
      final actualizada = await _direccionService.actualizarDireccion(id, direccion);
      _direcciones[index] = actualizada;
      notifyListeners();
    } catch (_) {
      _direcciones[index] = direccion;
      notifyListeners();
    }
  }

  Future<void> eliminar(int index) async {
    final eraPredeterminada = _direcciones[index].predeterminada;
    final id = _direcciones[index].id;
    if (id != null) {
      try {
        await _direccionService.eliminarDireccion(id);
      } catch (_) {}
    }

    _direcciones.removeAt(index);
    if (eraPredeterminada && _direcciones.isNotEmpty) {
      _direcciones[0] = _direcciones[0].copyWith(predeterminada: true);
    }
    notifyListeners();
  }

  void marcarPredeterminada(int index) {
    for (var i = 0; i < _direcciones.length; i++) {
      _direcciones[i] = _direcciones[i].copyWith(predeterminada: i == index);
    }
    notifyListeners();
  }
}
