import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/direccion.dart';
import '../../../models/franja_horaria.dart';
import '../../../models/servicio_lavanderia.dart';
import '../../../models/tarjeta.dart';
import '../../../providers/agendar_recoleccion_provider.dart';
import '../../../providers/direcciones_provider.dart';
import '../../../providers/metodos_pago_provider.dart';
import '../../../utils/app_colors.dart';
import '../agendar_recoleccion/pedido_recibido_screen.dart';
import '../mi_perfil/seleccionar_direccion_screen.dart';
import '../mi_perfil/seleccionar_metodo_pago_screen.dart';

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

bool _esMismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class RepetirPedidoScreen extends StatelessWidget {
  const RepetirPedidoScreen({
    super.key,
    required this.nombreServicio,
    required this.fechaAnterior,
    required this.precioBase,
    required this.tipoServicio,
    this.pesoEstimado,
    this.etiquetas = const ['Eco-friendly', 'Suavizante extra'],
  });

  final String nombreServicio;
  final String fechaAnterior;
  final double precioBase;
  final TipoServicio tipoServicio;
  final String? pesoEstimado;
  final List<String> etiquetas;

  Future<void> _confirmar(
    BuildContext context,
    AgendarRecoleccionProvider provider,
    Direccion direccionActual,
  ) async {
    await provider.agendarRecoleccion();
    if (!context.mounted) return;
    final fecha = provider.fechaSeleccionada;
    final franjaInfo = franjasDisponibles.firstWhere(
      (f) => f.valor == provider.franja,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PedidoRecibidoScreen(
          servicioNombre: nombreServicio,
          direccionTitulo: direccionActual.titulo,
          direccionLinea: direccionActual.lineas.join(', '),
          fechaTexto:
              '${_diasSemana[fecha.weekday - 1]}, ${fecha.day} de '
              '${_meses[fecha.month - 1].substring(0, 3)}',
          horarioTexto: '${franjaInfo.etiqueta} (${franjaInfo.horario})',
          total: precioBase * (1 - provider.tasaDescuento),
        ),
      ),
    );
  }

  Future<void> _seleccionarDireccion(
    BuildContext context,
    AgendarRecoleccionProvider provider,
    Direccion direccionActual,
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
    return ChangeNotifierProvider(
      create: (_) => AgendarRecoleccionProvider(servicioInicial: tipoServicio),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Repetir Pedido',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Consumer<AgendarRecoleccionProvider>(
            builder: (context, provider, _) {
              final direccionActual =
                  provider.direccionSeleccionada ??
                  context.watch<DireccionesProvider>().predeterminada;
              final tarjetaActual =
                  provider.tarjetaSeleccionada ??
                  context.watch<MetodosPagoProvider>().principal;
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Detalles del servicio original'),
                        const SizedBox(height: 16),
                        _ServicioOriginalCard(
                          nombreServicio: nombreServicio,
                          fechaAnterior: fechaAnterior,
                          precioBase: precioBase,
                          pesoEstimado: pesoEstimado,
                          etiquetas: etiquetas,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SectionTitle('Dirección de recolección'),
                            TextButton(
                              onPressed: () => _seleccionarDireccion(
                                context,
                                provider,
                                direccionActual,
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Editar',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _AddressCard(direccion: direccionActual),
                        const SizedBox(height: 32),
                        _SectionTitle('Fecha de recolección'),
                        const SizedBox(height: 16),
                        _DateSelector(provider: provider),
                        const SizedBox(height: 32),
                        _SectionTitle('Horario'),
                        const SizedBox(height: 16),
                        _TimeWindowSelector(provider: provider),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SectionTitle('Método de Pago'),
                            if (tarjetaActual != null)
                              TextButton(
                                onPressed: () => _seleccionarTarjeta(
                                  context,
                                  provider,
                                  tarjetaActual,
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Cambiar',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PaymentCard(tarjeta: tarjetaActual),
                        const SizedBox(height: 32),
                        _SectionTitle('Instrucciones especiales'),
                        const SizedBox(height: 16),
                        _InstructionsField(provider: provider),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomActionBar(
                      provider: provider,
                      total: precioBase * (1 - provider.tasaDescuento),
                      onAplicarCodigo: () =>
                          _aplicarCodigoPromocional(context, provider),
                      onConfirmar: () =>
                          _confirmar(context, provider, direccionActual),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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

class _ServicioOriginalCard extends StatelessWidget {
  const _ServicioOriginalCard({
    required this.nombreServicio,
    required this.fechaAnterior,
    required this.precioBase,
    required this.pesoEstimado,
    required this.etiquetas,
  });

  final String nombreServicio;
  final String fechaAnterior;
  final double precioBase;
  final String? pesoEstimado;
  final List<String> etiquetas;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreServicio,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pedido anterior: $fechaAnterior',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.local_laundry_service_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceVariant, height: 1),
          const SizedBox(height: 16),
          if (pesoEstimado != null) ...[
            _DetalleRow(
              icon: Icons.scale_rounded,
              label: 'Peso estimado',
              valor: pesoEstimado!,
            ),
            const SizedBox(height: 12),
          ],
          _DetalleRow(
            icon: Icons.sell_rounded,
            label: 'Precio base',
            valor: '\$${precioBase.toStringAsFixed(2)} MXN',
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceVariant, height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final etiqueta in etiquetas)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    etiqueta,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
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

class _DetalleRow extends StatelessWidget {
  const _DetalleRow({
    required this.icon,
    required this.label,
    required this.valor,
  });

  final IconData icon;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          valor,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.direccion});

  final Direccion direccion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(direccion.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  direccion.titulo,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  direccion.lineas.join(', '),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.tarjeta});

  final TarjetaGuardada? tarjeta;

  @override
  Widget build(BuildContext context) {
    final tarjetaActual = tarjeta;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: tarjetaActual == null
                ? Text(
                    'Sin método de pago',
                    style: GoogleFonts.inter(
                      fontSize: 16,
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
                      Text(
                        'Vence ${tarjetaActual.expira}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.provider});

  final AgendarRecoleccionProvider provider;

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.fechasDisponibles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final fecha = provider.fechasDisponibles[index];
          final esHoy = _esMismoDia(fecha, hoy);
          final selected = _esMismoDia(fecha, provider.fechaSeleccionada);
          return InkWell(
            onTap: () => provider.seleccionarFecha(fecha),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _diasSemana[fecha.weekday - 1],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white70
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${fecha.day}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                  if (esHoy)
                    Text(
                      'HOY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white70
                            : AppColors.onSurfaceVariant,
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
                    ? AppColors.secondaryContainer
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(franjaInfo.icon, color: AppColors.primary),
                  const SizedBox(width: 12),
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
                            color: AppColors.onSurfaceVariant,
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
        hintText: 'Ej. Dejar en recepción, timbre no funciona...',
        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.outline),
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

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.provider,
    required this.total,
    required this.onAplicarCodigo,
    required this.onConfirmar,
  });

  final AgendarRecoleccionProvider provider;
  final double total;
  final VoidCallback onAplicarCodigo;
  final VoidCallback onConfirmar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: provider.codigoPromoController,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      hintText: 'Código promocional',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.outlineVariant,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total estimado',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)} MXN',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: provider.isLoading ? null : onConfirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Confirmar y Agendar',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
