import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/pedido_service.dart';
import '../../../utils/app_colors.dart';
import '../../auth/login/login_screen.dart';

class HomeAdministradorScreen extends StatefulWidget {
  const HomeAdministradorScreen({super.key});

  @override
  State<HomeAdministradorScreen> createState() => _HomeAdministradorScreenState();
}

class _HomeAdministradorScreenState extends State<HomeAdministradorScreen> with SingleTickerProviderStateMixin {
  final _pedidoService = PedidoService();
  late TabController _tabController;
  
  List<Map<String, dynamic>> _pedidos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filtroBusqueda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarPedidos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarPedidos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final datos = await _pedidoService.listarPedidos();
      if (!mounted) return;
      setState(() {
        _pedidos = datos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar los pedidos. Intenta de nuevo.';
        _isLoading = false;
      });
    }
  }

  Future<void> _actualizarEstadoPedido(String id, String nuevoEstado) async {
    try {
      await _pedidoService.actualizarEstado(id, nuevoEstado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido #FC-$id actualizado a: $nuevoEstado'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      _cargarPedidos();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar el estado del pedido'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _cerrarSesion() {
    context.read<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Filtrado de pedidos según la pestaña y la búsqueda
  List<Map<String, dynamic>> _filtrarPedidos(String tab) {
    var lista = _pedidos;

    // Filtro por pestaña
    if (tab == 'pendientes') {
      lista = lista.where((p) => p['estado']?.toString() == 'Pendiente').toList();
    } else if (tab == 'curso') {
      final estadosCurso = ['Aceptado', 'En proceso', 'En planta', 'Secado y Doblado', 'En camino'];
      lista = lista.where((p) => estadosCurso.contains(p['estado']?.toString())).toList();
    } else if (tab == 'historial') {
      final estadosFinalizados = ['Entregado', 'Rechazado', 'Cancelado'];
      lista = lista.where((p) => estadosFinalizados.contains(p['estado']?.toString())).toList();
    }

    // Filtro por barra de búsqueda (ID de pedido, nombre de cliente o tipo de servicio)
    if (_filtroBusqueda.isNotEmpty) {
      final query = _filtroBusqueda.toLowerCase();
      lista = lista.where((p) {
        final id = '#fc-${p['id']}'.toLowerCase();
        final cliente = (p['clienteNombre']?.toString() ?? '').toLowerCase();
        final servicio = (p['servicio']?.toString() ?? '').toLowerCase();
        return id.contains(query) || cliente.contains(query) || servicio.contains(query);
      }).toList();
    }

    // Ordenar por ID de forma descendente (más recientes primero)
    lista.sort((a, b) {
      final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      return idB.compareTo(idA);
    });

    return lista;
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'Aceptado':
        return AppColors.primaryContainer;
      case 'En proceso':
        return Colors.cyan.shade700;
      case 'En planta':
        return Colors.purple;
      case 'Secado y Doblado':
        return Colors.teal;
      case 'En camino':
        return Colors.deepOrange;
      case 'Entregado':
        return Colors.green.shade700;
      case 'Rechazado':
      case 'Cancelado':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcular métricas dinámicas
    final totalPedidosHoy = _pedidos.length;
    final totalPendientes = _pedidos.where((p) => p['estado'] == 'Pendiente').length;
    final totalEntregados = _pedidos.where((p) => p['estado'] == 'Entregado').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'Panel de Control',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
            label: Text(
              'Salir',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarPedidos,
          child: _isLoading && _pedidos.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // MÓDULO DE MÉTRICAS DINÁMICAS
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, Administrador',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _MetricCard(
                                    title: 'Total Pedidos',
                                    value: totalPedidosHoy.toString(),
                                    icon: Icons.local_laundry_service_rounded,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  _MetricCard(
                                    title: 'Por Aprobar',
                                    value: totalPendientes.toString(),
                                    icon: Icons.pending_actions_rounded,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 12),
                                  _MetricCard(
                                    title: 'Completados',
                                    value: totalEntregados.toString(),
                                    icon: Icons.check_circle_outline_rounded,
                                    color: Colors.green.shade700,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // MÓDULO DE BÚSQUEDA Y FILTRADO
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (val) => setState(() => _filtroBusqueda = val),
                              style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Buscar por folio, cliente o servicio...',
                                hintStyle: GoogleFonts.inter(color: AppColors.outline),
                                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
                                filled: true,
                                fillColor: AppColors.surfaceContainerLowest,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppColors.outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppColors.outlineVariant),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TabBar(
                              controller: _tabController,
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.secondary,
                              indicatorColor: AppColors.primary,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                              tabs: const [
                                Tab(text: 'POR APROBAR'),
                                Tab(text: 'EN CURSO'),
                                Tab(text: 'HISTORIAL'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ERROR BANNER
                    if (_errorMessage != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                Text(_errorMessage!, style: GoogleFonts.inter(color: AppColors.error)),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _cargarPedidos,
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // MÓDULO DE LISTAS DE PEDIDOS (VINCULADO AL TAB)
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTabList('pendientes'),
                          _buildTabList('curso'),
                          _buildTabList('historial'),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTabList(String tabType) {
    final pedidosFiltrados = _filtrarPedidos(tabType);

    if (pedidosFiltrados.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.outlineVariant),
              const SizedBox(height: 12),
              Text(
                'No hay pedidos en esta sección',
                style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
      itemCount: pedidosFiltrados.length,
      itemBuilder: (context, index) {
        final pedido = pedidosFiltrados[index];
        final id = pedido['id']?.toString() ?? '';
        final cliente = pedido['clienteNombre']?.toString() ?? 'Cliente Demo';
        final servicio = pedido['servicio']?.toString() ?? 'Lavado';
        final total = double.tryParse(pedido['total']?.toString() ?? '0') ?? 0.0;
        final fecha = pedido['fecha']?.toString() ?? '';
        final direccion = pedido['direccion']?.toString() ?? 'Sin dirección';
        final instrucciones = pedido['instrucciones']?.toString() ?? '';
        final franja = pedido['franjaHoraria']?.toString() ?? 'Tarde';
        final estadoActual = pedido['estado']?.toString() ?? 'Pendiente';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.secondaryContainer.withAlpha(200)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO: Folio y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#FC-$id',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.outline,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _obtenerColorEstado(estadoActual).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      estadoActual.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _obtenerColorEstado(estadoActual),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // DETALLES DEL CLIENTE Y SERVICIO
              Text(
                cliente,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.local_laundry_service_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    servicio,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${total.toStringAsFixed(2)} MXN',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.outlineVariant),

              // DETALLES DE ENTREGA Y AGENDA
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.event_note_rounded, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha y Franja: $fecha ($franja)',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dirección: $direccion',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // INSTRUCCIONES ESPECIALES
              if (instrucciones.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Instrucciones: "$instrucciones"',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // BOTONES DE ACCIÓN DINÁMICOS
              if (estadoActual == 'Pendiente')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _actualizarEstadoPedido(id, 'Rechazado'),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Rechazar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error.withAlpha(127)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _actualizarEstadoPedido(id, 'Aceptado'),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Aceptar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                )
              else if (estadoActual != 'Entregado' && estadoActual != 'Rechazado' && estadoActual != 'Cancelado')
                Row(
                  children: [
                    Text(
                      'Cambiar Estado:',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: estadoActual,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Aceptado', child: Text('Aceptado')),
                              DropdownMenuItem(value: 'En proceso', child: Text('En Lavado')),
                              DropdownMenuItem(value: 'En planta', child: Text('En Planta (Clasificación)')),
                              DropdownMenuItem(value: 'Secado y Doblado', child: Text('Secado y Doblado')),
                              DropdownMenuItem(value: 'En camino', child: Text('En Camino (Reparto)')),
                              DropdownMenuItem(value: 'Entregado', child: Text('Entregado')),
                            ],
                            onChanged: (nuevoEstado) {
                              if (nuevoEstado != null && nuevoEstado != estadoActual) {
                                _actualizarEstadoPedido(id, nuevoEstado);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryContainer.withAlpha(127)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
