import 'package:flutter/material.dart';

enum TipoServicio { lavadoYPlegado, tintoreria }

class ServicioLavanderiaInfo {
  const ServicioLavanderiaInfo({
    required this.tipo,
    required this.nombre,
    required this.precioTexto,
    required this.totalEstimado,
    required this.icon,
  });

  final TipoServicio tipo;
  final String nombre;
  final String precioTexto;
  final double totalEstimado;
  final IconData icon;
}

const serviciosDisponibles = [
  ServicioLavanderiaInfo(
    tipo: TipoServicio.lavadoYPlegado,
    nombre: 'Lavado y Doblado',
    precioTexto: '\$2.50/lb',
    totalEstimado: 24.50,
    icon: Icons.local_laundry_service_outlined,
  ),
  ServicioLavanderiaInfo(
    tipo: TipoServicio.tintoreria,
    nombre: 'Tintorería',
    precioTexto: 'Desde \$5.00/pieza',
    totalEstimado: 35.00,
    icon: Icons.dry_cleaning_outlined,
  ),
];
