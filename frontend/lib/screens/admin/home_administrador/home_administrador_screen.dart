import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

// TODO: pendiente el diseño real de esta pantalla (aún no llega en Pantallas/).
class HomeAdministradorScreen extends StatelessWidget {
  const HomeAdministradorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Panel Administrador'),
      ),
      body: const Center(
        child: Text('Pantalla de administrador pendiente de diseño'),
      ),
    );
  }
}
