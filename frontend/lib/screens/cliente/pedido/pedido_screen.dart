import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/pedido_service.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../home_cliente/home_cliente_screen.dart';
import '../mi_perfil/mi_perfil_screen.dart';
import '../mis_pedidos/mis_pedidos_screen.dart';
import '../servicios/servicios_screen.dart';
import 'calificar_servicio_screen.dart';
import 'cancelar_pedido_screen.dart';
import 'reportar_problema_screen.dart';
import 'seguimiento_en_vivo_screen.dart';

enum _PasoEstado { completado, actual, pendiente }

class _PasoPedido {
  const _PasoPedido({
    required this.titulo,
    required this.descripcion,
    required this.estado,
    this.hora,
  });

  final String titulo;
  final String descripcion;
  final _PasoEstado estado;
  final String? hora;
}

class PedidoScreen extends StatefulWidget {
  const PedidoScreen({super.key, this.pedido, this.pedidoId});

  final Map<String, dynamic>? pedido;
  final String? pedidoId;

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final _pedidoService = PedidoService();
  Map<String, dynamic>? _pedido;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.pedido != null) {
      _pedido = widget.pedido;
    } else {
      _cargarPedido();
    }
  }

  Future<void> _cargarPedido() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final pedidos = await _pedidoService.listarPedidos(clienteId: auth.currentUser?.id);
      
      if (!mounted) return;

      if (widget.pedidoId != null) {
        final p = pedidos.firstWhere(
          (item) => item['id']?.toString() == widget.pedidoId,
          orElse: () => {},
        );
        if (p.isNotEmpty) {
          setState(() {
            _pedido = p;
          });
        } else {
          setState(() {
            _error = 'No se encontró el pedido #FC-${widget.pedidoId}';
          });
        }
      } else {
        // Cargar el primer pedido activo
        final estadosFinales = ['entregado', 'rechazado', 'cancelado'];
        final p = pedidos.firstWhere(
          (item) => !estadosFinales.contains(item['estado']?.toString().toLowerCase()),
          orElse: () => {},
        );
        if (p.isNotEmpty) {
          setState(() {
            _pedido = p;
          });
        } else if (pedidos.isNotEmpty) {
          // Si no hay activos, el más reciente
          setState(() {
            _pedido = pedidos.first;
          });
        } else {
          setState(() {
            _error = 'No tienes pedidos registrados';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Error al conectar con el servidor';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MisPedidosScreen()),
        );
      case AppBottomTab.profile:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
        );
    }
  }

  List<_PasoPedido> _obtenerPasos(String estado) {
    final estadoLower = estado.toLowerCase();
    
    if (estadoLower == 'cancelado' || estadoLower == 'rechazado') {
      return [
        _PasoPedido(
          titulo: 'Pedido Creado',
          descripcion: 'El pedido fue recibido en el sistema.',
          estado: _PasoEstado.completado,
        ),
        _PasoPedido(
          titulo: estadoLower == 'cancelado' ? 'Cancelado' : 'Rechazado',
          descripcion: estadoLower == 'cancelado' 
              ? 'El pedido fue cancelado por el usuario.' 
              : 'El pedido fue rechazado por la administración.',
          estado: _PasoEstado.actual,
        ),
      ];
    }

    int indiceActual = 0;
    if (estadoLower == 'pendiente') indiceActual = 0;
    else if (estadoLower == 'aceptado') indiceActual = 1;
    else if (estadoLower == 'en proceso' || estadoLower == 'en planta') indiceActual = 2;
    else if (estadoLower == 'secado y doblado') indiceActual = 3;
    else if (estadoLower == 'en camino') indiceActual = 4;
    else if (estadoLower == 'entregado') indiceActual = 5;

    _PasoEstado obtenerEstadoPaso(int index) {
      if (index < indiceActual) return _PasoEstado.completado;
      if (index == indiceActual) return _PasoEstado.actual;
      return _PasoEstado.pendiente;
    }

    return [
      _PasoPedido(
        titulo: 'Creado',
        descripcion: 'Pedido recibido en el sistema.',
        estado: obtenerEstadoPaso(0),
      ),
      _PasoPedido(
        titulo: 'Aprobado',
        descripcion: 'Pedido aceptado por la administración.',
        estado: obtenerEstadoPaso(1),
      ),
      _PasoPedido(
        titulo: 'En Proceso',
        descripcion: 'Tu ropa está siendo lavada y tratada.',
        estado: obtenerEstadoPaso(2),
      ),
      _PasoPedido(
        titulo: 'Secado y Doblado',
        descripcion: 'Ropa seca y cuidadosamente doblada.',
        estado: obtenerEstadoPaso(3),
      ),
      _PasoPedido(
        titulo: 'En Camino',
        descripcion: 'El repartidor va hacia tu dirección.',
        estado: obtenerEstadoPaso(4),
      ),
      _PasoPedido(
        titulo: 'Entregado',
        descripcion: '¡Disfruta de tu ropa limpia!',
        estado: obtenerEstadoPaso(5),
      ),
    ];
  }

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
      case 'cancelado':
      case 'rechazado':
        return 1.0;
      default:
        return 0.0;
    }
  }

  String _obtenerSubtituloEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Esperando aprobación';
      case 'aceptado':
        return 'Recolección programada';
      case 'en proceso':
      case 'en planta':
        return 'Lavado en planta';
      case 'secado y doblado':
        return 'Listo para envío';
      case 'en camino':
        return 'En reparto';
      case 'entregado':
        return 'Entregado con éxito';
      case 'cancelado':
        return 'Cancelado por el cliente';
      case 'rechazado':
        return 'Rechazado por administración';
      default:
        return 'Procesando';
    }
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'aceptado':
        return AppColors.primaryContainer;
      case 'en proceso':
      case 'en planta':
        return Colors.cyan.shade700;
      case 'secado y doblado':
        return Colors.teal;
      case 'en camino':
        return Colors.deepOrange;
      case 'entregado':
        return Colors.green.shade700;
      case 'cancelado':
      case 'rechazado':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _pedido == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Seguimiento',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.outlineVariant),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'No tienes pedidos en curso',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 16, color: AppColors.secondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _cargarPedido,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reintentar'),
                )
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

    final pedido = _pedido!;
    final id = pedido['id']?.toString() ?? '';
    final estado = pedido['estado']?.toString() ?? 'Pendiente';
    final servicio = pedido['servicio']?.toString() ?? 'Servicio de Lavandería';
    final fecha = pedido['fecha']?.toString() ?? 'Hoy';
    final franja = pedido['franjaHoraria']?.toString() ?? 'Tarde';
    final total = double.tryParse(pedido['total']?.toString() ?? '0') ?? 0.0;
    
    final progreso = _obtenerProgreso(estado);
    final subtituloEstado = _obtenerSubtituloEstado(estado);
    final colorEstado = _obtenerColorEstado(estado);
    final pasos = _obtenerPasos(estado);

    final esEstadoFinal = ['entregado', 'rechazado', 'cancelado'].contains(estado.toLowerCase());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: Text(
          'Pedido #FC-$id',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorEstado.withAlpha(25),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: colorEstado, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    estado.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorEstado,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _cargarPedido,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ESTIMACION CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondaryContainer.withAlpha(127)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  servicio,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$subtituloEstado • \$$total MXN',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => SeguimientoEnVivoScreen(pedidoId: id)),
                            ),
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progreso,
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(colorEstado),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Programado', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary)),
                          Text('Procesando', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary)),
                          Text('Entregando', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary)),
                        ],
                      ),
                      const Divider(height: 32, color: AppColors.outlineVariant),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Entrega: $fecha ($franja)',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // TIMELINE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondaryContainer.withAlpha(127)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de Seguimiento',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (var i = 0; i < pasos.length; i++)
                        _TimelineStep(paso: pasos[i], isLast: i == pasos.length - 1),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // REPARTIDOR CARD
                const _RepartidorCard(),
                const SizedBox(height: 24),
                
                // ACCIONES DE PEDIDO
                if (!esEstadoFinal)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ReportarProblemaScreen()),
                          ),
                          icon: const Icon(Icons.flag_outlined, size: 18),
                          label: Text(
                            'Reportar Problema',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CancelarPedidoScreen()),
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: Text(
                            'Cancelar Pedido',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        ),
                      ),
                    ],
                  )
                else if (estado.toLowerCase() == 'entregado')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CalificarServicioScreen()),
                      ),
                      icon: const Icon(Icons.star_rate_rounded, size: 20),
                      label: Text(
                        'Calificar Servicio',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
              ],
            ),
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

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.paso, required this.isLast});

  final _PasoPedido paso;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final atenuado = paso.estado == _PasoEstado.pendiente;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildDot(),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.secondaryContainer.withAlpha(127)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        paso.titulo,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: paso.estado == _PasoEstado.actual
                              ? AppColors.primary
                              : atenuado
                              ? AppColors.secondary
                              : AppColors.onSurface,
                        ),
                      ),
                      if (paso.hora != null)
                        Text(
                          paso.hora!,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary),
                        )
                      else if (paso.estado == _PasoEstado.actual)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Actual',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (paso.descripcion.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        paso.descripcion,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: atenuado ? AppColors.secondary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    switch (paso.estado) {
      case _PasoEstado.completado:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
        );
      case _PasoEstado.actual:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ),
        );
      case _PasoEstado.pendiente:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
        );
    }
  }
}

class _RepartidorCard extends StatelessWidget {
  const _RepartidorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryContainer.withAlpha(127)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu Repartidor',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.onSurfaceVariant, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carlos Mendoza',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '4.9 (120 entregas) • FreshVan #042',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Llamando a Carlos Mendoza...')),
                    );
                  },
                  icon: const Icon(Icons.call_rounded, size: 20),
                  label: const Text('Llamar'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    foregroundColor: AppColors.primary,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abriendo soporte técnico...')),
                    );
                  },
                  icon: const Icon(Icons.support_agent_rounded, size: 20),
                  label: const Text('Soporte'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    foregroundColor: AppColors.primary,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
