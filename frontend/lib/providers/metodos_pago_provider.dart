import 'package:flutter/material.dart';

import '../models/tarjeta.dart';

/// Fuente única de las tarjetas guardadas del cliente, compartida entre
/// Métodos de Pago y el flujo de Agendar Recolección.
class MetodosPagoProvider extends ChangeNotifier {
  final List<TarjetaGuardada> _tarjetas = [
    const TarjetaGuardada(
      marca: MarcaTarjeta.visa,
      ultimosDigitos: '4242',
      expira: '12/26',
      principal: true,
    ),
    const TarjetaGuardada(
      marca: MarcaTarjeta.mastercard,
      ultimosDigitos: '8819',
      expira: '08/24',
    ),
  ];

  List<TarjetaGuardada> get tarjetas => List.unmodifiable(_tarjetas);

  TarjetaGuardada? get principal {
    for (final tarjeta in _tarjetas) {
      if (tarjeta.principal) return tarjeta;
    }
    return _tarjetas.isEmpty ? null : _tarjetas.first;
  }

  // TODO: sincronizar con el proveedor de pagos / backend.
  void agregar(TarjetaGuardada tarjeta) {
    if (tarjeta.principal) {
      for (var i = 0; i < _tarjetas.length; i++) {
        _tarjetas[i] = _tarjetas[i].copyWith(principal: false);
      }
    }
    _tarjetas.add(tarjeta);
    notifyListeners();
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
