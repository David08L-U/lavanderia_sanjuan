import 'package:flutter/material.dart';

import '../models/franja_horaria.dart';
import '../models/servicio_lavanderia.dart';

class AgendarRecoleccionProvider extends ChangeNotifier {
  AgendarRecoleccionProvider() : fechasDisponibles = _generarFechas() {
    _fechaSeleccionada = fechasDisponibles.first;
  }

  static List<DateTime> _generarFechas() {
    final hoy = DateTime.now();
    return List.generate(7, (i) => DateTime(hoy.year, hoy.month, hoy.day + i));
  }

  final List<DateTime> fechasDisponibles;
  final instruccionesController = TextEditingController();

  TipoServicio _servicio = TipoServicio.lavadoYPlegado;
  TipoServicio get servicio => _servicio;

  late DateTime _fechaSeleccionada;
  DateTime get fechaSeleccionada => _fechaSeleccionada;

  FranjaHoraria _franja = FranjaHoraria.tarde;
  FranjaHoraria get franja => _franja;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ServicioLavanderiaInfo get servicioInfo =>
      serviciosDisponibles.firstWhere((s) => s.tipo == _servicio);

  double get totalEstimado => servicioInfo.totalEstimado;

  void seleccionarServicio(TipoServicio tipo) {
    _servicio = tipo;
    notifyListeners();
  }

  void seleccionarFecha(DateTime fecha) {
    _fechaSeleccionada = fecha;
    notifyListeners();
  }

  void seleccionarFranja(FranjaHoraria franja) {
    _franja = franja;
    notifyListeners();
  }

  // TODO: conectar con el backend para crear el ticket de lavandería,
  // enviando servicio, fecha, franja horaria, dirección e instrucciones.
  Future<void> agendarRecoleccion() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    instruccionesController.dispose();
    super.dispose();
  }
}
