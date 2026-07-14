import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Control',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMetricCard('Pedidos hoy', '12', Icons.shopping_bag_outlined),
              const SizedBox(width: 16),
              _buildMetricCard('En proceso', '5', Icons.loop),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Pedidos recientes',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildRecentOrder('Pedido #1234', 'Juan Pérez', 'En proceso'),
          _buildRecentOrder('Pedido #1235', 'María García', 'Listo para entrega'),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrder(String id, String customer, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.surfaceContainerHigh)),
      child: ListTile(
        title: Text(id, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        subtitle: Text(customer, style: GoogleFonts.inter()),
        trailing: Text(status, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
