import 'package:flutter/material.dart';

enum FranjaHoraria { manana, tarde, noche }

class FranjaHorariaInfo {
  const FranjaHorariaInfo({
    required this.valor,
    required this.etiqueta,
    required this.horario,
    required this.icon,
  });

  final FranjaHoraria valor;
  final String etiqueta;
  final String horario;
  final IconData icon;
}

const franjasDisponibles = [
  FranjaHorariaInfo(
    valor: FranjaHoraria.manana,
    etiqueta: 'Mañana',
    horario: '08:00 - 12:00',
    icon: Icons.wb_sunny_outlined,
  ),
  FranjaHorariaInfo(
    valor: FranjaHoraria.tarde,
    etiqueta: 'Tarde',
    horario: '12:00 - 16:00',
    icon: Icons.wb_sunny_rounded,
  ),
  FranjaHorariaInfo(
    valor: FranjaHoraria.noche,
    etiqueta: 'Noche',
    horario: '16:00 - 20:00',
    icon: Icons.nightlight_round,
  ),
];
