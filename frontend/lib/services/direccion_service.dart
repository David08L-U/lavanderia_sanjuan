import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/direccion.dart';

class DireccionService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5162/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5162/api';
    }
    return 'http://localhost:5162/api';
  }

  Future<List<Direccion>> listarDirecciones() async {
    final response = await http.get(Uri.parse('$_baseUrl/direcciones'));
    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las direcciones');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Direccion.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Direccion> crearDireccion(Direccion direccion) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/direcciones'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(direccion.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo guardar la dirección');
    }

    return Direccion.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Direccion> actualizarDireccion(String id, Direccion direccion) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/direcciones/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(direccion.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo actualizar la dirección');
    }

    return Direccion.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> eliminarDireccion(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/direcciones/$id'));
    if (response.statusCode != 200) {
      throw Exception('No se pudo eliminar la dirección');
    }
  }
}
