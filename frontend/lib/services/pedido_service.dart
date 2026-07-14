import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PedidoService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5162/api';
    }
    if (Platform.isAndroid) {
      return 'http://localhost:5162/api';
    }
    return 'http://localhost:5162/api';
  }

  Future<List<Map<String, dynamic>>> listarPedidos({String? clienteId}) async {
    final uri = Uri.parse('$_baseUrl/pedidos').replace(queryParameters: clienteId == null ? null : {'clienteId': clienteId});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los pedidos');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> crearPedido(Map<String, dynamic> pedido) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/pedidos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pedido),
    );
    if (response.statusCode != 201) {
      throw Exception('No se pudo crear el pedido');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> actualizarEstado(String id, String estado) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/pedidos/$id/estado'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'estado': estado}),
    );
    if (response.statusCode != 200) {
      throw Exception('No se pudo actualizar el estado');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
