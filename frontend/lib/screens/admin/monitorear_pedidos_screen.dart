import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/pedido_service.dart';
import '../../../utils/app_colors.dart';

class MonitorearPedidosScreen extends StatefulWidget {
  const MonitorearPedidosScreen({super.key});

  @override
  State<MonitorearPedidosScreen> createState() => _MonitorearPedidosScreenState();
}

class _MonitorearPedidosScreenState extends State<MonitorearPedidosScreen> {
  final _pedidoService = PedidoService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _pedidoService.listarPedidos();
      setState(() {
        _pedidos = data;
      });
    } catch (e) {
      setState(() => _error = 'No se pudieron cargar los pedidos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':
        return Colors.green;
      case 'en proceso':
        return AppColors.primary;
      case 'recolectado':
        return Colors.orange;
      case 'en lavado':
        return Colors.blue;
      case 'listo para entrega':
        return Colors.teal;
      case 'cancelado':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  Future<void> _mostrarCambiarEstado(BuildContext context, String pedidoId, String estadoActual) async {
    final estados = ['En proceso', 'Recolectado', 'En lavado', 'Listo para entrega', 'Entregado', 'Cancelado'];
    
    final nuevoEstado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualizar Estado',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona el nuevo estado para este pedido.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: estados.length,
                    itemBuilder: (context, index) {
                      final estado = estados[index];
                      final esActual = estado.toLowerCase() == estadoActual.toLowerCase();
                      
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(estado),
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(estado).withValues(alpha: 0.1),
                          child: Icon(
                            Icons.circle,
                            color: _getStatusColor(estado),
                            size: 16,
                          ),
                        ),
                        title: Text(
                          estado,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: esActual ? FontWeight.w700 : FontWeight.w500,
                            color: esActual ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                        trailing: esActual
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (nuevoEstado != null && nuevoEstado.toLowerCase() != estadoActual.toLowerCase() && mounted) {
      setState(() => _isLoading = true);
      try {
        await _pedidoService.actualizarEstado(pedidoId, nuevoEstado);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a "$nuevoEstado"')),
        );
        _cargarPedidos();
      } catch (e) {
        if (!context.mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el estado: $e')),
        );
      }
    }
  }

  void _verDetallesPedido(BuildContext context, Map<String, dynamic> pedido) {
    showDialog(
      context: context,
      builder: (context) {
        final historial = (pedido['historialEstados'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return AlertDialog(
          title: Text(
            'Detalles de Orden FC-${pedido['id']}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                _buildDetailRow('Cliente:', pedido['clienteNombre'] ?? 'Sin nombre'),
                _buildDetailRow('Servicio:', pedido['servicio'] ?? ''),
                _buildDetailRow('Fecha:', pedido['fecha'] ?? ''),
                _buildDetailRow('Horario:', pedido['franjaHoraria'] ?? ''),
                _buildDetailRow('Dirección:', pedido['direccion'] ?? ''),
                _buildDetailRow('Total:', '\$${pedido['total']} MXN'),
                _buildDetailRow('Instrucciones:', pedido['instrucciones']?.toString().isNotEmpty == true ? pedido['instrucciones'] : 'Ninguna'),
                const SizedBox(height: 16),
                Text(
                  'Historial de Estados',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const Divider(),
                if (historial.isEmpty)
                  const Text('Sin historial registrado')
                else
                  ...historial.map((h) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: _getStatusColor(h['estado'] ?? '')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${h['estado']} - ${h['fecha'] != null ? h['fecha'].toString().split('T')[0] : ""}',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                if (h['observaciones'] != null && h['observaciones'].toString().isNotEmpty)
                                  Text(
                                    h['observaciones'],
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 14),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value),
          ],
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Monitorear Pedidos',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _cargarPedidos,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, style: GoogleFonts.inter(color: AppColors.error), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _cargarPedidos,
                            child: const Text('Reintentar'),
                          )
                        ],
                      ),
                    ),
                  )
                : _pedidos.isEmpty
                    ? Center(
                        child: Text(
                          'No hay pedidos registrados en el sistema.',
                          style: GoogleFonts.inter(color: AppColors.secondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarPedidos,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: _pedidos.length,
                          itemBuilder: (context, index) {
                            final pedido = _pedidos[index];
                            final id = pedido['id'] ?? '';
                            final cliente = pedido['clienteNombre'] ?? 'Cliente';
                            final servicio = pedido['servicio'] ?? '';
                            final total = pedido['total'] ?? 0;
                            final estado = pedido['estado'] ?? 'En proceso';
                            final fecha = pedido['fecha'] ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.secondaryContainer),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'FC-$id',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(estado).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          estado,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: _getStatusColor(estado),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    cliente,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$servicio • $fecha',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$$total MXN',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () => _verDetallesPedido(context, pedido),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(
                                              'Detalles',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () => _mostrarCambiarEstado(context, id, estado),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              minimumSize: Size.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              'Estado',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
