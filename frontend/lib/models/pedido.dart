<<<<<<< HEAD
import 'servicio_lavanderia.dart';

enum EstadoPedido { enProceso, entregado, cancelado }

EstadoPedido estadoPedidoFromString(String? value) {
  switch (value) {
    case 'Entregado':
      return EstadoPedido.entregado;
    case 'Cancelado':
      return EstadoPedido.cancelado;
    default:
      return EstadoPedido.enProceso;
  }
}

/// Representa un pedido tal como lo devuelve el backend, ya interpretado
/// para la UI (servicio real, estado real) en vez de asumir datos fijos.
class Pedido {
  const Pedido({
    required this.id,
    required this.servicio,
    required this.tipoServicio,
    required this.fecha,
    required this.franjaHoraria,
    required this.direccion,
    required this.instrucciones,
    required this.total,
    required this.estado,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final servicioNombre = json['servicio']?.toString() ?? 'Servicio';
    final tipoServicio = serviciosDisponibles
        .firstWhere(
          (s) => s.nombre == servicioNombre,
          orElse: () => serviciosDisponibles.first,
        )
        .tipo;
    final instrucciones = json['instrucciones']?.toString().trim();

    return Pedido(
      id: json['id']?.toString() ?? '',
      servicio: servicioNombre,
      tipoServicio: tipoServicio,
      fecha: json['fecha']?.toString() ?? 'Sin fecha',
      franjaHoraria: json['franjaHoraria']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? 'Sin dirección',
      instrucciones: (instrucciones == null || instrucciones.isEmpty) ? null : instrucciones,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      estado: estadoPedidoFromString(json['estado']?.toString()),
    );
  }

  final String id;
  final String servicio;
  final TipoServicio tipoServicio;
  final String fecha;
  final String franjaHoraria;
  final String direccion;
  final String? instrucciones;
  final double total;
  final EstadoPedido estado;

  String get numero => '#FC-$id';

  static const _meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  /// El backend guarda la fecha como texto (a veces ISO 8601, a veces ya
  /// legible). Si se puede interpretar como fecha, se muestra en un
  /// formato corto y consistente; si no, se muestra tal cual llegó.
  String get fechaFormateada {
    final parsed = DateTime.tryParse(fecha);
    if (parsed == null) return fecha;
    return '${parsed.day} ${_meses[parsed.month - 1]}. ${parsed.year}';
  }
=======
enum PedidoEstado {
  recibido,
  asignado,
  enPlanta,
  lavando,
  secandoDoblado,
  enCamino,
  listo,
  entregado,
  atencion
}

String estadoToString(PedidoEstado estado) {
  switch (estado) {
    case PedidoEstado.recibido:
      return 'Recibido';
    case PedidoEstado.asignado:
      return 'Repartidor Asignado';
    case PedidoEstado.enPlanta:
      return 'En Planta';
    case PedidoEstado.lavando:
      return 'Lavando';
    case PedidoEstado.secandoDoblado:
      return 'Secando y Doblado';
    case PedidoEstado.enCamino:
      return 'En camino';
    case PedidoEstado.listo:
      return 'Listo';
    case PedidoEstado.entregado:
      return 'Entregado';
    case PedidoEstado.atencion:
      return 'Atención';
  }
}

class Pedido {
  Pedido({
    required this.id,
    required this.clienteNombre,
    required this.clienteEmail,
    required this.servicioNombre,
    required this.servicioIcono,
    required this.tipoEntrega,
    required this.estado,
    required this.progreso,
    required this.fecha,
    this.warningMessage,
    this.repartidorNombre,
    this.detallesAdicionales,
  });

  final String id;
  final String clienteNombre;
  final String clienteEmail;
  final String servicioNombre;
  final String servicioIcono;
  final String tipoEntrega;
  PedidoEstado estado;
  double progreso;
  final String fecha;
  String? warningMessage;
  String? repartidorNombre;
  String? detallesAdicionales;
>>>>>>> 5c9e703d44001684717913344e4e3fdd2b2ce222
}
