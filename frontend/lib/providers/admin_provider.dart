import 'package:flutter/material.dart';
import '../models/pedido_admin.dart';
import '../models/servicio.dart';

class AdminProvider extends ChangeNotifier {
  final List<PedidoAdmin> _pedidos = [
    PedidoAdmin(
      id: 'ORD-4923',
      clienteNombre: 'David Miller',
      clienteEmail: 'david.miller@example.com',
      servicioNombre: 'Solo Planchado',
      servicioIcono: 'iron',
      tipoEntrega: 'Domicilio',
      estado: PedidoEstado.atencion,
      progreso: 0.0,
      fecha: 'Hoy, 08:30 AM',
      warningMessage: 'Falta artículo en el inventario. Se requiere verificación manual.',
    ),
    PedidoAdmin(
      id: 'ORD-1042',
      clienteNombre: 'Marcus Sterling',
      clienteEmail: 'marcus.s@example.com',
      servicioNombre: 'Lavado y Doblado',
      servicioIcono: 'local_laundry_service',
      tipoEntrega: 'Domicilio',
      estado: PedidoEstado.lavando,
      progreso: 0.4,
      fecha: 'Hoy, 09:15 AM',
    ),
    PedidoAdmin(
      id: 'ORD-3819',
      clienteNombre: 'Sophia Chen',
      clienteEmail: 'sophia.chen@example.com',
      servicioNombre: 'Tintorería',
      servicioIcono: 'dry_cleaning',
      tipoEntrega: 'Domicilio',
      estado: PedidoEstado.recibido,
      progreso: 0.1,
      fecha: 'Hoy, 10:00 AM',
      detallesAdicionales: 'Programado para hoy, 14:00 - 16:00',
    ),
    PedidoAdmin(
      id: 'ORD-8492',
      clienteNombre: 'María González',
      clienteEmail: 'maria.g@example.com',
      servicioNombre: 'Planchado',
      servicioIcono: 'iron',
      tipoEntrega: 'Domicilio',
      estado: PedidoEstado.recibido,
      progreso: 0.1,
      fecha: 'Hoy, 09:30 AM',
    ),
    PedidoAdmin(
      id: 'ORD-8924',
      clienteNombre: 'Laura G.',
      clienteEmail: 'laura.g@example.com',
      servicioNombre: 'Limpieza de Edredones',
      servicioIcono: 'bed',
      tipoEntrega: 'Domicilio',
      estado: PedidoEstado.asignado,
      progreso: 0.3,
      fecha: 'Ayer, 06:00 PM',
      repartidorNombre: 'Carlos Mendoza',
    ),
    PedidoAdmin(
      id: 'ORD-2718',
      clienteNombre: 'Juan Pérez',
      clienteEmail: 'juan.perez@example.com',
      servicioNombre: 'Lavado x Kilo',
      servicioIcono: 'scale',
      tipoEntrega: 'Local',
      estado: PedidoEstado.enPlanta,
      progreso: 0.6,
      fecha: 'Hoy, 11:00 AM',
    ),
  ];

  final List<Servicio> _servicios = [
    Servicio(
      id: 'S-001',
      nombre: 'Lavado y Doblado',
      icono: 'local_laundry_service',
      precio: 1.50,
      unidad: 'kg',
      descripcion: 'Servicio estándar para ropa de uso diario. Incluye lavado, secado y doblado profesional.',
      activo: true,
    ),
    Servicio(
      id: 'S-002',
      nombre: 'Tintorería',
      icono: 'dry_cleaning',
      precio: 5.00,
      unidad: 'prenda',
      descripcion: 'Limpieza en seco para prendas delicadas, trajes, vestidos y ropa formal.',
      activo: true,
    ),
    Servicio(
      id: 'S-003',
      nombre: 'Planchado',
      icono: 'iron',
      precio: 1.00,
      unidad: 'prenda',
      descripcion: 'Planchado profesional para camisas, pantalones y prendas cotidianas.',
      activo: true,
    ),
    Servicio(
      id: 'S-004',
      nombre: 'Edredones',
      icono: 'bed',
      precio: 12.00,
      unidad: 'pieza',
      descripcion: 'Limpieza profunda para edredones, cobijas y ropa de cama de gran volumen.',
      activo: true,
    ),
  ];

  List<PedidoAdmin> get pedidos => List.unmodifiable(_pedidos);
  List<Servicio> get servicios => List.unmodifiable(_servicios);

  void updatePedidoEstado(String id, PedidoEstado nuevoEstado) {
    final index = _pedidos.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pedidos[index].estado = nuevoEstado;
      
      // Ajustar progreso según el estado de forma automática
      switch (nuevoEstado) {
        case PedidoEstado.recibido:
          _pedidos[index].progreso = 0.1;
          break;
        case PedidoEstado.asignado:
          _pedidos[index].progreso = 0.3;
          break;
        case PedidoEstado.enPlanta:
          _pedidos[index].progreso = 0.4;
          break;
        case PedidoEstado.lavando:
          _pedidos[index].progreso = 0.6;
          break;
        case PedidoEstado.secandoDoblado:
          _pedidos[index].progreso = 0.8;
          break;
        case PedidoEstado.enCamino:
          _pedidos[index].progreso = 0.9;
          break;
        case PedidoEstado.listo:
        case PedidoEstado.entregado:
          _pedidos[index].progreso = 1.0;
          break;
        case PedidoEstado.atencion:
          _pedidos[index].progreso = 0.0;
          break;
      }
      
      notifyListeners();
    }
  }

  void assignRepartidor(String id, String repartidorNombre) {
    final index = _pedidos.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pedidos[index].repartidorNombre = repartidorNombre;
      _pedidos[index].estado = PedidoEstado.asignado;
      _pedidos[index].progreso = 0.3;
      notifyListeners();
    }
  }

  void addServicio(Servicio servicio) {
    _servicios.add(servicio);
    notifyListeners();
  }

  void updateServicio(
    String id, {
    String? nombre,
    double? precio,
    String? unidad,
    String? descripcion,
    bool? activo,
  }) {
    final index = _servicios.indexWhere((s) => s.id == id);
    if (index != -1) {
      if (nombre != null) _servicios[index].nombre = nombre;
      if (precio != null) _servicios[index].precio = precio;
      if (unidad != null) _servicios[index].unidad = unidad;
      if (descripcion != null) _servicios[index].descripcion = descripcion;
      if (activo != null) _servicios[index].activo = activo;
      notifyListeners();
    }
  }

  void toggleServicioActivo(String id) {
    final index = _servicios.indexWhere((s) => s.id == id);
    if (index != -1) {
      _servicios[index].activo = !_servicios[index].activo;
      notifyListeners();
    }
  }
}
