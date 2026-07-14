class Servicio {
  Servicio({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.precio,
    required this.unidad,
    required this.descripcion,
    this.activo = true,
  });

  final String id;
  String nombre;
  String icono;
  double precio;
  String unidad;
  String descripcion;
  bool activo;
}
