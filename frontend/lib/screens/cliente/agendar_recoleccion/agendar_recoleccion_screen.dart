import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/direccion.dart';
import '../../../models/franja_horaria.dart';
import '../../../models/servicio_lavanderia.dart';
import '../../../models/tarjeta.dart';
import '../../../providers/agendar_recoleccion_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/direcciones_provider.dart';
import '../../../providers/metodos_pago_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/app_bottom_nav_bar.dart';
import '../home_cliente/home_cliente_screen.dart';
import '../mi_perfil/mi_perfil_screen.dart';
import '../mi_perfil/seleccionar_direccion_screen.dart';
import '../mi_perfil/seleccionar_metodo_pago_screen.dart';
import '../mis_pedidos/mis_pedidos_screen.dart';
import '../servicios/servicios_screen.dart';
import 'pedido_recibido_screen.dart';

const _diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _meses = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

String _etiquetaChip(int index, DateTime fecha) {
  if (index == 0) return 'Hoy';
  if (index == 1) return 'Mañ';
  return _diasSemana[fecha.weekday - 1];
}

class AgendarRecoleccionScreen extends StatelessWidget {
  const AgendarRecoleccionScreen({super.key});

  static Route<void> route({TipoServicio? servicioInicial}) {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            AgendarRecoleccionProvider(servicioInicial: servicioInicial),
        child: const AgendarRecoleccionScreen(),
      ),
    );
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

  Future<void> _submit(
    BuildContext context,
    AgendarRecoleccionProvider provider,
    Direccion? direccionActual,
  ) async {
    if (direccionActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar una dirección de entrega')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    await provider.agendarRecoleccion(
      clienteId: auth.currentUser?.id ?? '2',
      clienteNombre: auth.currentUser?.nombre ?? 'Cliente Demo',
      direccion: '${direccionActual.titulo}: ${direccionActual.lineas.join(", ")}',
    );
    if (!context.mounted) return;
    final fecha = provider.fechaSeleccionada;
    final franjaInfo = franjasDisponibles.firstWhere(
      (f) => f.valor == provider.franja,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PedidoRecibidoScreen(
          servicioNombre: provider.servicioInfo.nombre,
          direccionTitulo: direccionActual.titulo,
          direccionLinea: direccionActual.lineas.join(', '),
          fechaTexto:
              '${_diasSemana[fecha.weekday - 1]}, ${fecha.day} de '
              '${_meses[fecha.month - 1].substring(0, 3)}',
          horarioTexto: '${franjaInfo.etiqueta} (${franjaInfo.horario})',
          total: provider.totalConDescuento,
        ),
      ),
    );
  }

  Future<void> _seleccionarDireccion(
    BuildContext context,
    AgendarRecoleccionProvider provider,
    Direccion? direccionActual,
  ) async {
    final resultado = await Navigator.of(context).push<Direccion>(
      MaterialPageRoute(
        builder: (_) =>
            SeleccionarDireccionScreen(seleccionActual: direccionActual),
      ),
    );
    if (resultado != null) {
      provider.seleccionarDireccion(resultado);
    }
  }

  Future<void> _seleccionarTarjeta(
    BuildContext context,
    AgendarRecoleccionProvider provider,
    TarjetaGuardada tarjetaActual,
  ) async {
    final resultado = await Navigator.of(context).push<TarjetaGuardada>(
      MaterialPageRoute(
        builder: (_) =>
            SeleccionarMetodoPagoScreen(seleccionActual: tarjetaActual),
      ),
    );
    if (resultado != null) {
      provider.seleccionarTarjeta(resultado);
    }
  }

  void _aplicarCodigoPromocional(
    BuildContext context,
    AgendarRecoleccionProvider provider,
  ) {
    provider.aplicarCodigoPromocional();
    final mensaje = provider.mensajePromo;
    if (mensaje != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgendarRecoleccionProvider>();
    final direccionActual =
        provider.direccionSeleccionada ??
        context.watch<DireccionesProvider>().predeterminada;
    final tarjetaActual =
        provider.tarjetaSeleccionada ??
        context.watch<MetodosPagoProvider>().principal;

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
          'Agendar Recolección',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Dirección'),
              const SizedBox(height: 16),
              _AddressCard(
                direccion: direccionActual,
                onTap: () =>
                    _seleccionarDireccion(context, provider, direccionActual),
              ),
              const SizedBox(height: 32),
              const _SectionTitle('Fecha'),
              const SizedBox(height: 16),
              _DateSelector(provider: provider),
              const SizedBox(height: 32),
              const _SectionTitle('Horario'),
              const SizedBox(height: 16),
              _TimeWindowSelector(provider: provider),
              const SizedBox(height: 32),
              const _SectionTitle('Método de Pago'),
              const SizedBox(height: 16),
              _PaymentCard(
                tarjeta: tarjetaActual,
                onTap: tarjetaActual == null
                    ? null
                    : () =>
                          _seleccionarTarjeta(context, provider, tarjetaActual),
              ),
              const SizedBox(height: 32),
              const _SectionTitle('Instrucciones especiales'),
              const SizedBox(height: 16),
              _InstructionsField(provider: provider),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ConfirmarPedidoBar(
            isLoading: provider.isLoading,
            codigoPromoController: provider.codigoPromoController,
            onAplicarCodigo: () => _aplicarCodigoPromocional(context, provider),
            onConfirmar: () => _submit(context, provider, direccionActual),
          ),
          AppBottomNavBar(
            currentTab: AppBottomTab.orders,
            onTabSelected: (tab) => _onTabSelected(context, tab),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.direccion, required this.onTap});

  final Direccion? direccion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dir = direccion;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryContainer),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(dir?.icon ?? Icons.location_on_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: dir == null
                  ? Text(
                      'Agregar dirección de entrega',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dir.titulo,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dir.lineas.join(', '),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.tarjeta, required this.onTap});

  final TarjetaGuardada? tarjeta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tarjetaActual = tarjeta;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryContainer),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: tarjetaActual == null
                  ? Text(
                      'Agregar método de pago',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tarjetaActual.marca == MarcaTarjeta.mastercard ? 'Mastercard' : 'Visa'} **** ${tarjetaActual.ultimosDigitos}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Vence ${tarjetaActual.expira}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
            ),
            if (tarjetaActual != null)
              Text(
                'Cambiar',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.provider});

  final AgendarRecoleccionProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.fechasDisponibles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final fecha = provider.fechasDisponibles[index];
          final selected = fecha == provider.fechaSeleccionada;
          return InkWell(
            onTap: () => provider.seleccionarFecha(fecha),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 72,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _etiquetaChip(index, fecha).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: selected
                          ? AppColors.primaryFixedDim
                          : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${fecha.day}',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeWindowSelector extends StatelessWidget {
  const _TimeWindowSelector({required this.provider});

  final AgendarRecoleccionProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: franjasDisponibles.map((franjaInfo) {
        final selected = franjaInfo.valor == provider.franja;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => provider.seleccionarFranja(franjaInfo.valor),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.surfaceContainerLowest
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    franjaInfo.icon,
                    color: selected ? AppColors.primary : AppColors.secondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          franjaInfo.etiqueta,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.primary
                                : AppColors.onSurface,
                          ),
                        ),
                        Text(
                          franjaInfo.horario,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.8)
                                : AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<FranjaHoraria>(
                    value: franjaInfo.valor,
                    // ignore: deprecated_member_use
                    groupValue: provider.franja,
                    activeColor: AppColors.primary,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      if (value != null) provider.seleccionarFranja(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InstructionsField extends StatelessWidget {
  const _InstructionsField({required this.provider});

  final AgendarRecoleccionProvider provider;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: provider.instruccionesController,
      minLines: 4,
      maxLines: 4,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        hintText: 'Ej: Dejar en portería, cuidado con el perro, etc.',
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.outlineVariant,
        ),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _ConfirmarPedidoBar extends StatelessWidget {
  const _ConfirmarPedidoBar({
    required this.isLoading,
    required this.codigoPromoController,
    required this.onAplicarCodigo,
    required this.onConfirmar,
  });

  final bool isLoading;
  final TextEditingController codigoPromoController;
  final VoidCallback onAplicarCodigo;
  final VoidCallback onConfirmar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codigoPromoController,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    hintText: 'Código promocional',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.outlineVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onAplicarCodigo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Aplicar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirmar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirmar Pedido',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
