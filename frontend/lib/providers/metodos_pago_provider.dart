import 'package:flutter/material.dart';

import '../models/tarjeta.dart';
import '../services/metodo_pago_service.dart';

/// Fuente única de las tarjetas guardadas del cliente, compartida entre
/// Métodos de Pago y el flujo de Agendar Recolección.
class MetodosPagoProvider extends ChangeNotifier {
  MetodosPagoProvider({MetodoPagoService? metodoPagoService})
    : _metodoPagoService = metodoPagoService ?? MetodoPagoService() {
    Future.microtask(cargar);
  }

  final MetodoPagoService _metodoPagoService;
  final List<TarjetaGuardada> _tarjetas = [];

  List<TarjetaGuardada> get tarjetas => List.unmodifiable(_tarjetas);

  TarjetaGuardada? get principal {
    for (final tarjeta in _tarjetas) {
      if (tarjeta.principal) return tarjeta;
    }
    return _tarjetas.isEmpty ? null : _tarjetas.first;
  }

  Future<void> cargar() async {
    try {
      final datos = await _metodoPagoService.listarMetodosPago();
      _tarjetas
        ..clear()
        ..addAll(datos);
      notifyListeners();
    } catch (_) {
      // Se conserva la lista local vacía si la API no responde.
    }
  }

  Future<void> agregar(TarjetaGuardada tarjeta) async {
    try {
      final guardada = await _metodoPagoService.guardarMetodoPago(tarjeta);
      if (guardada.principal) {
        for (var i = 0; i < _tarjetas.length; i++) {
          _tarjetas[i] = _tarjetas[i].copyWith(principal: false);
        }
      }
      _tarjetas.add(guardada);
      notifyListeners();
    } catch (_) {
      if (tarjeta.principal) {
        for (var i = 0; i < _tarjetas.length; i++) {
          _tarjetas[i] = _tarjetas[i].copyWith(principal: false);
        }
      }
      _tarjetas.add(tarjeta);
      notifyListeners();
    }
  }

  void eliminar(int index) {
    final eraPrincipal = _tarjetas[index].principal;
    _tarjetas.removeAt(index);
    if (eraPrincipal && _tarjetas.isNotEmpty) {
      _tarjetas[0] = _tarjetas[0].copyWith(principal: true);
    }
    notifyListeners();
  }

  void marcarPrincipal(int index) {
    for (var i = 0; i < _tarjetas.length; i++) {
      _tarjetas[i] = _tarjetas[i].copyWith(principal: i == index);
    }
    notifyListeners();
  }
}
