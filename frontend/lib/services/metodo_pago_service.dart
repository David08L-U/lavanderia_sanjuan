import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/tarjeta.dart';

class MetodoPagoService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5162/api';
    }
    if (Platform.isAndroid) {
      return 'http://localhost:5162/api';
    }
    return 'http://localhost:5162/api';
  }

  Future<List<TarjetaGuardada>> listarMetodosPago() async {
    final response = await http.get(Uri.parse('$_baseUrl/metodos-pago'));
    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los métodos de pago');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.map((item) => TarjetaGuardada.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<TarjetaGuardada> guardarMetodoPago(TarjetaGuardada tarjeta) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/metodos-pago'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(tarjeta.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo guardar el método de pago');
    }

    return TarjetaGuardada.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
