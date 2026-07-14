# Plan: Conectar Pantallas de Administrador

## Objetivo
Implementar la estructura de navegación principal para el panel de administrador, conectando las vistas de Dashboard, Pedidos, Clientes y Servicios, basándose en los diseños proporcionados en `pantallas-adm/`.

## Archivos Clave
- `frontend/lib/screens/home_administrador/home_administrador_screen.dart`: Shell principal.
- `frontend/lib/screens/home_administrador/views/`: Directorio para las vistas de sección.
- `frontend/lib/utils/app_colors.dart`: Definición de colores y estilo.

## Pasos de Implementación

### 1. Preparación de Vistas
Crear las vistas principales en `frontend/lib/screens/home_administrador/views/`:
- `dashboard_view.dart`: Panel de control con métricas y pedidos recientes.
- `orders_view.dart`: Gestión y listado de pedidos.
- `customers_view.dart`: Directorio de clientes.
- `services_view.dart`: Configuración de servicios de lavandería.

### 2. Refactorización del Shell (HomeAdministradorScreen)
Actualizar `home_administrador_screen.dart` para:
- Usar un `Scaffold` con `BottomNavigationBar` (Íconos: Dashboard, ListAlt, People, Settings).
- Gestionar el índice de la vista seleccionada.
- Implementar un `IndexedStack` o similar para mantener el estado de las vistas al navegar.

### 3. Implementación Detallada (UI de Referencia)
Para cada vista, implementar los componentes básicos siguiendo el diseño HTML:
- **Dashboard**: Cards de métricas y lista simplificada de pedidos recientes.
- **Orders**: Buscador, filtros y lista de pedidos con estados (Atención, Proceso, etc.).
- **Customers**: Lista de clientes con avatar e información de contacto.
- **Services**: Grid de servicios activos con precios.

### 4. Conexiones y Navegación Interna
- Asegurar que el botón de "Perfil" (si existe en el AppBar) funcione o muestre un placeholder.
- Preparar la navegación a los detalles de pedido (aunque el detalle sea un stub por ahora).

## Verificación
1. Iniciar sesión como administrador (usando credenciales de prueba si existen).
2. Probar el cambio entre pestañas en la barra inferior.
3. Verificar la consistencia visual de los colores (Primary: #0058BC, Surface: #F9F9FF).
