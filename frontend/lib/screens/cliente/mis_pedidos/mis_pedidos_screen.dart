import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/servicio_lavanderia.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../home_cliente/home_cliente_screen.dart';
import '../mi_perfil/mi_perfil_screen.dart';
import '../notificaciones/notificaciones_screen.dart';
import '../pedido/pedido_screen.dart';
import '../servicios/servicios_screen.dart';
import 'detalle_factura_screen.dart';
import 'repetir_pedido_screen.dart';

enum _EstadoPedido { enProceso, entregado }

class _Pedido {
  const _Pedido({
    required this.numero,
    required this.servicio,
    required this.fecha,
    required this.monto,
    required this.montoNumerico,
    required this.estado,
    required this.tipoServicio,
    this.pesoEstimado,
    this.progreso = 1.0,
  });

  final String numero;
  final String servicio;
  final String fecha;
  final String monto;
  final double montoNumerico;
  final _EstadoPedido estado;
  final TipoServicio tipoServicio;
  final String? pesoEstimado;
  final double progreso;
}

const _pedidos = [
  _Pedido(
    numero: '#FC-8921',
    servicio: 'Lavado y Doblado',
    fecha: '12 Oct, 2023',
    monto: '\$320.00 MXN',
    montoNumerico: 320.00,
    estado: _EstadoPedido.enProceso,
    tipoServicio: TipoServicio.lavadoYPlegado,
    pesoEstimado: '16kg total',
    progreso: 0.45,
  ),
  _Pedido(
    numero: '#FC-8854',
    servicio: 'Planchado Express',
    fecha: '05 Oct, 2023',
    monto: '\$180.00 MXN',
    montoNumerico: 180.00,
    estado: _EstadoPedido.entregado,
    tipoServicio: TipoServicio.planchado,
  ),
  _Pedido(
    numero: '#FC-8799',
    servicio: 'Limpieza en Seco',
    fecha: '28 Sep, 2023',
    monto: '\$450.00 MXN',
    montoNumerico: 450.00,
    estado: _EstadoPedido.entregado,
    tipoServicio: TipoServicio.tintoreria,
  ),
];

class MisPedidosScreen extends StatelessWidget {
  const MisPedidosScreen({super.key});

  void _onTabSelected(BuildContext context, AppBottomTab tab) {
    switch (tab) {
      case AppBottomTab.home:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeClienteScreen()),
        );
      case AppBottomTab.services:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ServiciosScreen()),
        );
      case AppBottomTab.orders:
        break;
      case AppBottomTab.profile:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
        );
    }
  }

  void _repetirPedido(BuildContext context, _Pedido pedido) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepetirPedidoScreen(
          nombreServicio: pedido.servicio,
          fechaAnterior: pedido.fecha,
          precioBase: pedido.montoNumerico,
          tipoServicio: pedido.tipoServicio,
          pesoEstimado: pedido.pesoEstimado,
        ),
      ),
    );
  }

  void _verFactura(BuildContext context, _Pedido pedido) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleFacturaScreen(
          numeroPedido: pedido.numero,
          servicio: pedido.servicio,
          fechaEntrega: pedido.fecha,
          montoServicio: pedido.montoNumerico,
          tipoServicio: pedido.tipoServicio,
          pesoEstimado: pedido.pesoEstimado,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Mis Pedidos',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              for (var i = 0; i < _pedidos.length; i++) ...[
                _PedidoCard(
                  pedido: _pedidos[i],
                  onVerDetalles: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PedidoScreen()),
                  ),
                  onRepetirPedido: () => _repetirPedido(context, _pedidos[i]),
                  onFactura: () => _verFactura(context, _pedidos[i]),
                ),
                if (i != _pedidos.length - 1) const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppBottomTab.orders,
        onTabSelected: (tab) => _onTabSelected(context, tab),
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({
    required this.pedido,
    required this.onVerDetalles,
    required this.onRepetirPedido,
    required this.onFactura,
  });

  final _Pedido pedido;
  final VoidCallback onVerDetalles;
  final VoidCallback onRepetirPedido;
  final VoidCallback onFactura;

  @override
  Widget build(BuildContext context) {
    final enProceso = pedido.estado == _EstadoPedido.enProceso;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryContainer),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pedido.numero,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pedido.servicio,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: enProceso ? AppColors.primaryContainer : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      enProceso ? Icons.local_laundry_service_rounded : Icons.check_circle_rounded,
                      size: 14,
                      color: enProceso ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      enProceso ? 'En proceso' : 'Entregado',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: enProceso ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                pedido.fecha,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.payments_rounded, size: 15, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                pedido.monto,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          if (enProceso) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pedido.progreso,
                minHeight: 6,
                backgroundColor: AppColors.surfaceContainerLow,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (enProceso)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onVerDetalles,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: AppColors.primary,
                  side: BorderSide.none,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Ver Detalles',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRepetirPedido,
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: Text(
                      'Repetir Pedido',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onFactura,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.primary,
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 20),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
