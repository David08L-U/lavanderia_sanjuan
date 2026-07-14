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

/// Pedido visto desde el panel de administrador: incluye datos operativos
/// (repartidor, progreso, alertas) que el panel de cliente no necesita.
class PedidoAdmin {
  PedidoAdmin({
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
}
