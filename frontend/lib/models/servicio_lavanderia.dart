import 'package:flutter/material.dart';

enum TipoServicio { lavadoYPlegado, tintoreria, planchado, edredones }

class ServicioLavanderiaInfo {
  const ServicioLavanderiaInfo({
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.precioTexto,
    required this.totalEstimado,
    required this.icon,
    this.destacado = false,
  });

  final TipoServicio tipo;
  final String nombre;
  final String descripcion;
  final String precioTexto;
  final double totalEstimado;
  final IconData icon;
  final bool destacado;
}

const serviciosDisponibles = [
  ServicioLavanderiaInfo(
    tipo: TipoServicio.lavadoYPlegado,
    nombre: 'Lavado x Kilo',
    descripcion:
        'Nuestro servicio estándar de lavado, secado y doblado. Perfecto para tu ropa de todos los días.',
    precioTexto: 'Desde \$25/kg',
    totalEstimado: 25.00,
    icon: Icons.local_laundry_service_rounded,
    destacado: true,
  ),
  ServicioLavanderiaInfo(
    tipo: TipoServicio.tintoreria,
    nombre: 'Tintorería',
    descripcion: 'Cuidado premium para telas delicadas.',
    precioTexto: 'Desde \$50/prenda',
    totalEstimado: 50.00,
    icon: Icons.checkroom_rounded,
  ),
  ServicioLavanderiaInfo(
    tipo: TipoServicio.planchado,
    nombre: 'Planchado',
    descripcion: 'Servicio de planchado profesional.',
    precioTexto: 'Desde \$15/prenda',
    totalEstimado: 15.00,
    icon: Icons.iron_rounded,
  ),
  ServicioLavanderiaInfo(
    tipo: TipoServicio.edredones,
    nombre: 'Edredones',
    descripcion: 'Limpieza profunda para blancos de cama de gran volumen.',
    precioTexto: 'Desde \$120/pieza',
    totalEstimado: 120.00,
    icon: Icons.bed_rounded,
  ),
];
