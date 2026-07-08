import 'package:flutter/material.dart';

import '../models/direccion.dart';

/// Fuente única de las direcciones guardadas del cliente, compartida entre
/// Mis Direcciones, Seleccionar Dirección y el flujo de Agendar Recolección.
class DireccionesProvider extends ChangeNotifier {
  final List<Direccion> _direcciones = [
    const Direccion(
      icon: Icons.home_rounded,
      titulo: 'Casa Principal',
      lineas: ['Av. Siempre Viva 742', 'Springfield, CP 12345'],
      telefono: '+34 555 123 456',
      predeterminada: true,
    ),
    const Direccion(
      icon: Icons.business_rounded,
      titulo: 'Oficina',
      lineas: ['Torre Empresarial, Piso 5', 'Centro, CP 54321'],
      telefono: '+34 555 987 654',
      nota: 'Entregar en recepción',
    ),
  ];

  List<Direccion> get direcciones => List.unmodifiable(_direcciones);

  Direccion get predeterminada => _direcciones.firstWhere(
    (direccion) => direccion.predeterminada,
    orElse: () => _direcciones.first,
  );

  // TODO: sincronizar con el backend cuando exista el endpoint de direcciones.
  void agregar(Direccion direccion) {
    final esLaPrimera = _direcciones.isEmpty;
    _direcciones.add(esLaPrimera ? direccion.copyWith(predeterminada: true) : direccion);
    notifyListeners();
  }

  void actualizar(int index, Direccion direccion) {
    _direcciones[index] = direccion;
    notifyListeners();
  }

  void eliminar(int index) {
    final eraPredeterminada = _direcciones[index].predeterminada;
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
