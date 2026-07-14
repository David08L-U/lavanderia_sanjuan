import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors.dart';
import '../../cliente/notificaciones/notificaciones_screen.dart';
import '../administrar_clientes_screen.dart';
import '../configurar_servicios_screen.dart';
import '../monitorear_pedidos_screen.dart';

class HomeAdministradorScreen extends StatelessWidget {
  const HomeAdministradorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'Panel Administrador',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.secondaryContainer),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.rocket_launch_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Estado inicial de la app',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todo comienza en cero: sin pedidos activos y sin operaciones previas. '
                      'Registra clientes y crea pedidos para iniciar la operación.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _MetricCard(
                    title: 'Pedidos hoy',
                    value: '0',
                    helper: 'Sin actividad aún',
                    icon: Icons.local_laundry_service_rounded,
                  ),
                  _MetricCard(
                    title: 'En proceso',
                    value: '0',
                    helper: 'Ningún pedido activo',
                    icon: Icons.pending_actions_rounded,
                  ),
                  _MetricCard(
                    title: 'Entregados',
                    value: '0',
                    helper: 'Historial vacío',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Primeros pasos recomendados',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                title: 'Monitorear pedidos',
                subtitle:
                    'Visualiza y actualiza estados en cuanto entren nuevas órdenes',
                icon: Icons.assignment_turned_in_outlined,
                tone: _ActionTone.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MonitorearPedidosScreen()),
                ),
              ),
              _ActionTile(
                title: 'Configurar servicios',
                subtitle:
                    'Define precios, tiempos y reglas antes de recibir demanda',
                icon: Icons.price_change_outlined,
                tone: _ActionTone.neutral,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ConfigurarServiciosScreen()),
                ),
              ),
              _ActionTile(
                title: 'Administrar clientes',
                subtitle: 'Consulta nuevos registros y su historial de actividad',
                icon: Icons.people_alt_outlined,
                tone: _ActionTone.neutral,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdministrarClientesScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
  });

  final String title;
  final String value;
  final String helper;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ActionTone { primary, neutral }

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _ActionTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPrimary = tone == _ActionTone.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.secondaryContainer,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppColors.surfaceContainerLowest
                    : AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
