import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/servicio_lavanderia.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/pedido_service.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../mi_perfil/mi_perfil_screen.dart';
import '../mis_pedidos/mis_pedidos_screen.dart';
import '../notificaciones/notificaciones_screen.dart';
import '../nueva_orden/nueva_orden_screen.dart';
import '../pedido/pedido_screen.dart';
import '../servicios/edredones_screen.dart';
import '../servicios/lavado_kilo_screen.dart';
import '../servicios/planchado_screen.dart';
import '../servicios/servicios_screen.dart';
import '../servicios/tintoreria_screen.dart';
import 'detalle_oferta_screen.dart';

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  final _pedidoService = PedidoService();
  bool _isLoading = true;
  Map<String, dynamic>? _pedidoActivo;

  @override
  void initState() {
    super.initState();
    _cargarPedidoActivo();
  }

  Future<void> _cargarPedidoActivo() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final pedidos = await _pedidoService.listarPedidos(clienteId: auth.currentUser!.id);
      if (!mounted) return;

      // Buscar el primer pedido activo (no entregado, ni rechazado, ni cancelado)
      final estadosFinales = ['entregado', 'rechazado', 'cancelado'];
      final activo = pedidos.firstWhere(
        (p) => !estadosFinales.contains(p['estado']?.toString().toLowerCase()),
        orElse: () => {},
      );

      setState(() {
        _pedidoActivo = activo.isEmpty ? null : activo;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _pedidoActivo = null;
          _isLoading = false;
        });
      }
    }
  }

  void _onServicioTap(BuildContext context, ServicioLavanderiaInfo servicio) {
    switch (servicio.tipo) {
      case TipoServicio.tintoreria:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TintoreriaScreen()),
        );
      case TipoServicio.planchado:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlanchadoScreen()),
        );
      case TipoServicio.edredones:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EdredonesScreen()),
        );
      case TipoServicio.lavadoYPlegado:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LavadoKiloScreen()),
        );
    }
  }

  void _onTabSelected(BuildContext context, AppBottomTab tab) {
    switch (tab) {
      case AppBottomTab.home:
        break;
      case AppBottomTab.services:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ServiciosScreen()),
        );
      case AppBottomTab.profile:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
        );
      case AppBottomTab.orders:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MisPedidosScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.watch<AuthProvider>().currentUser?.nombre ?? 'Usuario';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.water_drop_rounded, color: AppColors.primary, size: 26),
            const SizedBox(width: 8),
            Text(
              'FreshClean',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.secondary),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _cargarPedidoActivo,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Greeting(nombre: nombre),
                const SizedBox(height: 24),
                _HeroBanner(
                  onOrderNow: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NuevaOrdenScreen()),
                  ).then((_) => _cargarPedidoActivo()),
                ),
                
                // MÓDULO PEDIDO ACTIVO DINÁMICO
                if (_isLoading) ...[
                  const SizedBox(height: 32),
                  const Center(child: CircularProgressIndicator()),
                ] else if (_pedidoActivo != null) ...[
                  const SizedBox(height: 32),
                  _ActiveOrderSection(
                    pedido: _pedidoActivo!,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PedidoScreen(pedido: _pedidoActivo),
                      ),
                    ).then((_) => _cargarPedidoActivo()),
                  ),
                ],
                
                const SizedBox(height: 32),
                _ServicesSection(
                  onServicioTap: (servicio) => _onServicioTap(context, servicio),
                ),
                const SizedBox(height: 24),
                _WeeklyOfferBanner(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DetalleOfertaScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentTab: AppBottomTab.home,
        onTabSelected: (tab) => _onTabSelected(context, tab),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola, $nombre!',
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.secondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Bienvenido de nuevo',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onOrderNow});

  final VoidCallback onOrderNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -12,
            bottom: -16,
            child: Opacity(
              opacity: 0.12,
              child: Transform.rotate(
                angle: 0.2,
                child: const Icon(
                  Icons.local_laundry_service_rounded,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ropa fresca,\nsin esfuerzo.',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  letterSpacing: -0.24,
                  color: AppColors.onPrimaryFixed,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  'Nosotros nos encargamos de tu colada mientras tú disfrutas de tu tiempo.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onPrimaryFixedVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onOrderNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ordenar Ahora',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveOrderSection extends StatelessWidget {
  const _ActiveOrderSection({required this.pedido, required this.onTap});

  final Map<String, dynamic> pedido;
  final VoidCallback onTap;

  double _obtenerProgreso(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 0.15;
      case 'aceptado':
        return 0.30;
      case 'en proceso':
      case 'en planta':
        return 0.50;
      case 'secado y doblado':
        return 0.75;
      case 'en camino':
        return 0.90;
      case 'entregado':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String _obtenerProgresoTexto(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return '15%';
      case 'aceptado':
        return '30%';
      case 'en proceso':
      case 'en planta':
        return '50%';
      case 'secado y doblado':
        return '75%';
      case 'en camino':
        return '90%';
      default:
        return '0%';
    }
  }

  String _obtenerEstadoVisual(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Por aprobar';
      case 'aceptado':
        return 'Recolección aceptada';
      case 'en proceso':
      case 'en planta':
        return 'Lavando';
      case 'secado y doblado':
        return 'Doblado y empaquetado';
      case 'en camino':
        return 'En reparto';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = pedido['id']?.toString() ?? '';
    final estado = pedido['estado']?.toString() ?? 'Pendiente';
    final fecha = pedido['fecha']?.toString() ?? '';
    final franja = pedido['franjaHoraria']?.toString() ?? '';
    
    final progreso = _obtenerProgreso(estado);
    final progresoTexto = _obtenerProgresoTexto(estado);
    final estadoVisual = _obtenerEstadoVisual(estado);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pedido Activo',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Ver detalles',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondaryContainer.withAlpha(127)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_laundry_service_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Orden #FC-$id',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                Text(
                                  estadoVisual,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Entrega',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary),
                        ),
                        Text(
                          '$fecha ($franja)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
                    ),
                    Text(
                      progresoTexto,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.location_on_outlined, size: 18),
                    label: const Text('Rastrear pedido'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow,
                      foregroundColor: AppColors.primary,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.onServicioTap});

  final ValueChanged<ServicioLavanderiaInfo> onServicioTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios Disponibles',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: serviciosDisponibles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final servicio = serviciosDisponibles[index];
            return _ServiceCard(
              icon: servicio.icon,
              title: servicio.nombre,
              subtitle: servicio.precioTexto,
              onTap: () => onServicioTap(servicio),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryContainer.withAlpha(127)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyOfferBanner extends StatelessWidget {
  const _WeeklyOfferBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryFixed),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OFERTA SEMANAL',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '20% OFF en Tintorería',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      text: 'Usa el código: ',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: 'FRESH20',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sell_rounded, color: AppColors.primary, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
