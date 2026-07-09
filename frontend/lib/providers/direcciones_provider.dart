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

  Direccion? get predeterminada {
    if (_direcciones.isEmpty) return null;
    return _direcciones.firstWhere(
      (direccion) => direccion.predeterminada,
      orElse: () => _direcciones.first,
    );
  }

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
    try {
      final actualizada = await _direccionService.actualizarDireccion(index.toString(), direccion);
      _direcciones[index] = actualizada;
      notifyListeners();
    } catch (_) {
      _direcciones[index] = direccion;
      notifyListeners();
    }
  }

  Future<void> eliminar(int index) async {
    final eraPredeterminada = _direcciones[index].predeterminada;
    try {
      await _direccionService.eliminarDireccion((index + 1).toString());
    } catch (_) {}

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
