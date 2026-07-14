import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Servicios',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildServiceItem('Lavado Seco', '\$5.00'),
              _buildServiceItem('Planchado', '\$3.00'),
              _buildServiceItem('Edredones', '\$10.00'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String name, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        trailing: Text(price, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
