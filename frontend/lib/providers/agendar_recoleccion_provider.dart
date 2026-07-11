import 'package:flutter/material.dart';

import '../models/direccion.dart';
import '../models/franja_horaria.dart';
import '../models/servicio_lavanderia.dart';
import '../models/tarjeta.dart';
import '../services/pedido_service.dart';

const _codigoPromoCorrecto = 'FRESH20';
const _tasaDescuentoPromo = 0.20;

class AgendarRecoleccionProvider extends ChangeNotifier {
  AgendarRecoleccionProvider({TipoServicio? servicioInicial})
    : fechasDisponibles = _generarFechas(),
      _servicio = servicioInicial ?? TipoServicio.lavadoYPlegado {
    _fechaSeleccionada = fechasDisponibles.first;
  }

  static List<DateTime> _generarFechas() {
    final hoy = DateTime.now();
    return List.generate(7, (i) => DateTime(hoy.year, hoy.month, hoy.day + i));
  }

  final List<DateTime> fechasDisponibles;
  final instruccionesController = TextEditingController();

  TipoServicio _servicio;
  TipoServicio get servicio => _servicio;

  late DateTime _fechaSeleccionada;
  DateTime get fechaSeleccionada => _fechaSeleccionada;

  FranjaHoraria _franja = FranjaHoraria.tarde;
  FranjaHoraria get franja => _franja;

  Direccion? _direccionSeleccionada;
  Direccion? get direccionSeleccionada => _direccionSeleccionada;

  void seleccionarDireccion(Direccion direccion) {
    _direccionSeleccionada = direccion;
    notifyListeners();
  }

  TarjetaGuardada? _tarjetaSeleccionada;
  TarjetaGuardada? get tarjetaSeleccionada => _tarjetaSeleccionada;

  void seleccionarTarjeta(TarjetaGuardada tarjeta) {
    _tarjetaSeleccionada = tarjeta;
    notifyListeners();
  }

  final codigoPromoController = TextEditingController();
  bool _codigoPromoValido = false;
  String? _mensajePromo;
  String? get mensajePromo => _mensajePromo;

  /// Fracción de descuento a aplicar sobre el total (0 si no hay código válido).
  double get tasaDescuento => _codigoPromoValido ? _tasaDescuentoPromo : 0;

  void aplicarCodigoPromocional() {
    final codigo = codigoPromoController.text.trim().toUpperCase();
    if (codigo.isEmpty) return;
    _codigoPromoValido = codigo == _codigoPromoCorrecto;
    _mensajePromo = _codigoPromoValido
        ? '¡Código aplicado! ${(_tasaDescuentoPromo * 100).round()}% de descuento.'
        : 'Código promocional no válido.';
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ServicioLavanderiaInfo get servicioInfo =>
      serviciosDisponibles.firstWhere((s) => s.tipo == _servicio);

  double get totalEstimado => servicioInfo.totalEstimado;

  double get descuento => totalEstimado * tasaDescuento;

  double get totalConDescuento =>
      (totalEstimado - descuento).clamp(0, double.infinity);

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

  Future<Map<String, dynamic>> agendarRecoleccion({
    String? clienteId,
    String? clienteNombre,
    required String direccion,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final pedidoService = PedidoService();
      final franjaEtiqueta = franjasDisponibles
          .firstWhere((f) => f.valor == _franja)
          .etiqueta;

      final res = await pedidoService.crearPedido({
        'clienteId': clienteId ?? '2',
        'clienteNombre': clienteNombre ?? 'Cliente Demo',
        'servicio': servicioInfo.nombre,
        'fecha': _fechaSeleccionada.toIso8601String(),
        'franjaHoraria': franjaEtiqueta,
        'direccion': direccion,
        'instrucciones': instruccionesController.text.trim(),
        'total': totalConDescuento,
      });
      return res;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    instruccionesController.dispose();
    codigoPromoController.dispose();
    super.dispose();
  }
}
