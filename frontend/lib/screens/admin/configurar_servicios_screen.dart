import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/servicio_lavanderia.dart';
import '../../../utils/app_colors.dart';

class ConfigurarServiciosScreen extends StatefulWidget {
  const ConfigurarServiciosScreen({super.key});

  @override
  State<ConfigurarServiciosScreen> createState() => _ConfigurarServiciosScreenState();
}

class _ConfigurarServiciosScreenState extends State<ConfigurarServiciosScreen> {
  final List<ServicioLavanderiaInfo> _servicios = List.from(serviciosDisponibles);
  final bool _isLoading = false;

  void _editarServicio(BuildContext context, int index) {
    final servicio = _servicios[index];
    final nombreController = TextEditingController(text: servicio.nombre);
    final descController = TextEditingController(text: servicio.descripcion);
    final precioController = TextEditingController(text: servicio.totalEstimado.toStringAsFixed(2));
    final precioTextoController = TextEditingController(text: servicio.precioTexto);
    bool destacado = servicio.destacado;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Editar Servicio',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre del Servicio'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: precioController,
                      decoration: const InputDecoration(
                        labelText: 'Precio Estimado (Numérico)',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: precioTextoController,
                      decoration: const InputDecoration(
                        labelText: 'Texto de Precio (ej: Desde \$25/kg)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Destacar servicio',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        Switch(
                          value: destacado,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            setDialogState(() {
                              destacado = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final nuevoPrecio = double.tryParse(precioController.text) ?? servicio.totalEstimado;
                    setState(() {
                      _servicios[index] = ServicioLavanderiaInfo(
                        tipo: servicio.tipo,
                        nombre: nombreController.text,
                        descripcion: descController.text,
                        precioTexto: precioTextoController.text,
                        totalEstimado: nuevoPrecio,
                        icon: servicio.icon,
                        destacado: destacado,
                      );
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Servicio actualizado (simulado)')),
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
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
          'Configurar Servicios',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: _servicios.length,
                itemBuilder: (context, index) {
                  final servicio = _servicios[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: servicio.destacado ? AppColors.primary : AppColors.secondaryContainer,
                        width: servicio.destacado ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(servicio.icon, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      servicio.nombre,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (servicio.destacado)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Destacado',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                servicio.descripcion,
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
                                    servicio.precioTexto,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _editarServicio(context, index),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.all(8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(Icons.edit_rounded, size: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
