import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/pedido_admin.dart';
import '../../../providers/admin_provider.dart';
import '../../../utils/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.pedido});

  final PedidoAdmin pedido;

  IconData _getIconForStatus(PedidoEstado estado) {
    switch (estado) {
      case PedidoEstado.recibido:
        return Icons.shopping_basket_outlined;
      case PedidoEstado.asignado:
        return Icons.person_outline;
      case PedidoEstado.enPlanta:
        return Icons.storefront_outlined;
      case PedidoEstado.lavando:
        return Icons.local_laundry_service_rounded;
      case PedidoEstado.secandoDoblado:
        return Icons.iron_outlined;
      case PedidoEstado.enCamino:
        return Icons.local_shipping_outlined;
      case PedidoEstado.listo:
        return Icons.check_circle_outline_rounded;
      case PedidoEstado.entregado:
        return Icons.task_alt_rounded;
      case PedidoEstado.atencion:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en el proveedor para tener los datos actualizados
    final currentPedido = context.watch<AdminProvider>().pedidos.firstWhere(
          (p) => p.id == pedido.id,
          orElse: () => pedido,
        );

    final isWarning = currentPedido.estado == PedidoEstado.atencion &&
        currentPedido.warningMessage != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pedido ${currentPedido.id}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client details header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryFixed,
                      child: Text(
                        currentPedido.clienteNombre.substring(0, 1),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPedido.clienteNombre,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            currentPedido.clienteEmail,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: ${currentPedido.fecha}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (isWarning) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning, color: AppColors.error, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requiere Atención Especial',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentPedido.warningMessage!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Service details
              Text(
                'Detalles del Servicio',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    _buildRowDetail('Servicio', currentPedido.servicioNombre),
                    const Divider(color: AppColors.surfaceVariant, height: 24),
                    _buildRowDetail('Entrega', currentPedido.tipoEntrega),
                    const Divider(color: AppColors.surfaceVariant, height: 24),
                    _buildRowDetail(
                      'Repartidor',
                      currentPedido.repartidorNombre ?? 'No asignado',
                      trailing: currentPedido.tipoEntrega == 'Domicilio'
                          ? TextButton(
                              onPressed: () => _showDriverSelectionDialog(context, currentPedido),
                              child: Text(
                                currentPedido.repartidorNombre != null ? 'Cambiar' : 'Asignar',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status Selector
              Text(
                'Progreso del Servicio',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Seleccione la etapa actual en la que se encuentra la ropa del cliente:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: PedidoEstado.values.map((estado) {
                    // Omitir el estado "atencion" si no es el actual, para no agregarlo como opción regular
                    if (estado == PedidoEstado.atencion &&
                        currentPedido.estado != PedidoEstado.atencion) {
                      return const SizedBox.shrink();
                    }

                    final isSelected = currentPedido.estado == estado;
                    return Column(
                      children: [
                        RadioListTile<PedidoEstado>.adaptive(
                          value: estado,
                          groupValue: currentPedido.estado,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            if (val != null) {
                              context.read<AdminProvider>().updatePedidoEstado(pedido.id, val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Estado actualizado a: ${estadoToString(val)}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          secondary: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForStatus(estado),
                              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            estadoToString(estado),
                            style: GoogleFonts.inter(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            _getSubtitleForStatus(estado),
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                        ),
                        if (estado != PedidoEstado.values.last)
                          const Divider(color: AppColors.surfaceVariant, height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowDetail(String label, String value, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        ?trailing,
      ],
    );
  }

  String _getSubtitleForStatus(PedidoEstado estado) {
    switch (estado) {
      case PedidoEstado.recibido:
        return 'Pedido recibido o recogido del cliente.';
      case PedidoEstado.asignado:
        return 'Repartidor asignado en camino a recolección.';
      case PedidoEstado.enPlanta:
        return 'Recibido en las instalaciones.';
      case PedidoEstado.lavando:
        return 'Proceso de lavado activo.';
      case PedidoEstado.secandoDoblado:
        return 'Prendas secándose y doblándose.';
      case PedidoEstado.enCamino:
        return 'El repartidor está en ruta de entrega.';
      case PedidoEstado.listo:
        return 'Listo para entrega o recogida.';
      case PedidoEstado.entregado:
        return 'Pedido completado y entregado.';
      case PedidoEstado.atencion:
        return 'Falta artículo o verificación manual requerida.';
    }
  }

  void _showDriverSelectionDialog(BuildContext context, PedidoAdmin currentPedido) {
    final drivers = [
      (name: 'Carlos Mendoza', vehicle: 'FreshVan #042', rating: '4.9 (124 viajes)', initials: 'CM'),
      (name: 'Laura Gómez', vehicle: 'FreshBike #12', rating: '4.7 (89 viajes)', initials: 'LG'),
      (name: 'Roberto Díaz', vehicle: 'FreshVan #018', rating: '5.0 (312 viajes)', initials: 'RD'),
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asignar Repartidor',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seleccione un repartidor disponible para esta entrega.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.surfaceVariant),
                const SizedBox(height: 8),

                ...drivers.map((driver) {
                  final isCurrentlySelected = currentPedido.repartidorNombre == driver.name;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCurrentlySelected ? AppColors.primary : AppColors.surfaceVariant,
                        width: isCurrentlySelected ? 2 : 1,
                      ),
                    ),
                    color: isCurrentlySelected
                        ? AppColors.primaryFixed.withValues(alpha: 0.3)
                        : AppColors.surfaceContainerLowest,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.read<AdminProvider>().assignRepartidor(currentPedido.id, driver.name);
                        Navigator.pop(dialogCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Repartidor ${driver.name} asignado al pedido.'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.secondaryContainer,
                              child: Text(
                                driver.initials,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver.name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.local_shipping_outlined,
                                          color: AppColors.onSurfaceVariant, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        driver.vehicle,
                                        style: GoogleFonts.inter(
                                            fontSize: 12, color: AppColors.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  driver.rating.split(' ')[0],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
