import 'package:flutter/material.dart';

class Direccion {
  const Direccion({
    required this.icon,
    required this.titulo,
    required this.lineas,
    this.telefono,
    this.nota,
    this.predeterminada = false,
  });

  final IconData icon;
  final String titulo;
  final List<String> lineas;
  final String? telefono;
  final String? nota;
  final bool predeterminada;

  Direccion copyWith({bool? predeterminada}) => Direccion(
    icon: icon,
    titulo: titulo,
    lineas: lineas,
    telefono: telefono,
    nota: nota,
    predeterminada: predeterminada ?? this.predeterminada,
  );
}

IconData iconoParaEtiqueta(String etiqueta) {
  final valor = etiqueta.toLowerCase();
  if (valor.contains('casa') || valor.contains('home')) return Icons.home_rounded;
  if (valor.contains('oficina') || valor.contains('office')) return Icons.business_rounded;
  return Icons.location_on_rounded;
}
