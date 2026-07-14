import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/usuario.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_colors.dart';

class AdministrarClientesScreen extends StatefulWidget {
  const AdministrarClientesScreen({super.key});

  @override
  State<AdministrarClientesScreen> createState() => _AdministrarClientesScreenState();
}

class _AdministrarClientesScreenState extends State<AdministrarClientesScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  String? _error;
  List<Usuario> _clientes = [];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _authService.listarClientes();
      setState(() {
        _clientes = data;
      });
    } catch (e) {
      setState(() => _error = 'No se pudieron cargar los clientes: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getRandomColor(String name) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    return colors[hash % colors.length];
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
          'Administrar Clientes',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _cargarClientes,
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
                          Text(
                            _error!,
                            style: GoogleFonts.inter(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _cargarClientes,
                            child: const Text('Reintentar'),
                          )
                        ],
                      ),
                    ),
                  )
                : _clientes.isEmpty
                    ? Center(
                        child: Text(
                          'No hay clientes registrados.',
                          style: GoogleFonts.inter(color: AppColors.secondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarClientes,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: _clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = _clientes[index];
                            final nombre = cliente.nombre;
                            final correo = cliente.correo;
                            final telefono = cliente.telefono ?? 'Sin teléfono';
                            final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';
                            final avatarColor = _getRandomColor(nombre);

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
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: avatarColor.withValues(alpha: 0.15),
                                    child: Text(
                                      inicial,
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: avatarColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.email_outlined, size: 14, color: AppColors.secondary),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                correo,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: AppColors.secondary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_outlined, size: 14, color: AppColors.secondary),
                                            const SizedBox(width: 6),
                                            Text(
                                              telefono.isNotEmpty ? telefono : 'No proporcionado',
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppColors.secondary,
                                              ),
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
      ),
    );
  }
}
