# Prompt para crear todo el proyecto Lavanderia San Juan

Usa el siguiente prompt para pedirle a una IA que construya el proyecto completo desde cero, respetando el flujo funcional, la arquitectura general y los módulos principales.

## Prompt

```text
Quiero que construyas un proyecto completo llamado "Lavanderia San Juan", orientado a la gestion de una lavanderia con app para clientes y panel administrativo.

Objetivo general:
Crear una solucion full stack compuesta por:
1. Un backend REST API con ASP.NET Core.
2. Un frontend en Flutter.
3. Integracion lista para funcionar en entorno local.
4. Persistencia preparada para Firebase/Firestore, con fallback temporal en memoria si Firebase no esta configurado.

Quiero que el resultado sea un proyecto real, organizado, ejecutable y mantenible, no solo ejemplos sueltos.

## Stack obligatorio

Backend:
- ASP.NET Core Web API.
- Arquitectura basada en controllers y servicios/repositorio.
- CORS habilitado para permitir consumo desde Flutter.
- OpenAPI/Swagger o equivalente para pruebas en desarrollo.
- Persistencia desacoplada para soportar Firebase Firestore.
- Si Firebase no esta disponible, usar almacenamiento temporal en memoria sin romper la API.

Frontend:
- Flutter.
- Manejo de estado con Provider.
- Estructura modular por pantallas, servicios, modelos, providers, widgets y config.
- Tema visual limpio y profesional.
- Navegacion entre pantallas de autenticacion, cliente y administrador.

## Contexto funcional del negocio

La aplicacion es para una lavanderia que permite a los clientes:
- Registrarse e iniciar sesion.
- Ver servicios disponibles.
- Crear un pedido de lavanderia.
- Programar recoleccion o entrega.
- Guardar y administrar direcciones.
- Guardar y administrar metodos de pago.
- Consultar sus pedidos.
- Ver detalle de factura.
- Repetir pedidos.
- Cancelar pedidos.
- Calificar el servicio.
- Reportar problemas.
- Ver notificaciones.
- Editar su perfil.

Tambien debe existir un flujo administrativo para:
- Ver y monitorear pedidos.
- Administrar clientes.
- Configurar servicios o catalogo.
- Tener una pantalla principal de administrador.

## Modulos funcionales minimos

Debes implementar estos modulos:

### 1. Autenticacion
- Login con correo y contrasena.
- Registro de nuevos usuarios.
- Recuperacion de contrasena con respuesta simulada o flujo desacoplado.
- Roles de usuario: cliente y administrador.

### 2. Usuarios
- Modelo de usuario con id, nombre, correo, telefono, password y rol.
- Endpoint para consultar o usar datos del usuario autenticado.
- Validaciones basicas de datos obligatorios.

### 3. Pedidos
- Crear pedido de lavanderia.
- Listar todos los pedidos o filtrar por cliente.
- Obtener pedido por id.
- Actualizar estado del pedido.
- Cancelar pedido.
- Calificar pedido.
- Reportar problema de pedido.

Cada pedido debe incluir como minimo:
- Id.
- ClienteId.
- ClienteNombre.
- Servicio.
- Fecha.
- FranjaHoraria.
- Direccion.
- Instrucciones.
- Total.
- Estado.
- Historial de estados.

El estado inicial del pedido debe ser "En proceso" y debe mantenerse un historial con fecha y observaciones.

### 4. Direcciones
- Crear direccion.
- Listar direcciones por usuario.
- Editar direccion.
- Eliminar direccion.
- Elegir direccion principal para un pedido.

### 5. Metodos de pago
- Crear metodo de pago.
- Listar tarjetas o metodos guardados.
- Editar alias o datos visibles.
- Eliminar metodo.
- Seleccionar metodo de pago en el flujo del pedido.

### 6. Catalogo de servicios de lavanderia
- Pantalla y modelo para mostrar servicios.
- Servicios sugeridos: lavado por kilo, planchado, tintoreria, edredones y opciones de doblado.
- Cada servicio debe poder mostrar descripcion, precio estimado o configuracion relevante.

### 7. Perfil del cliente
- Ver perfil.
- Editar perfil.
- Cambiar contrasena.
- Ver direcciones.
- Ver metodos de pago.

### 8. Notificaciones
- Pantalla de listado de notificaciones.
- Pantalla de detalle de notificacion.
- Datos mock o generados desde backend si se desea.

### 9. Administracion
- Home del administrador.
- Pantalla para monitorear pedidos.
- Pantalla para administrar clientes.
- Pantalla para configurar servicios.

## Requisitos del backend

Implementa una API REST con endpoints organizados como minimo en estos controladores:
- AuthController
- UsuariosController
- PedidosController
- DireccionesController
- MetodosPagoController

Rutas esperadas de ejemplo:
- POST /api/auth/login
- POST /api/auth/registro
- POST /api/auth/recuperar-password
- GET /api/pedidos
- GET /api/pedidos/{id}
- POST /api/pedidos
- PUT /api/pedidos/{id}/estado
- POST /api/pedidos/{id}/cancelar
- POST /api/pedidos/{id}/calificar
- POST /api/pedidos/{id}/reportar

Tambien crea endpoints coherentes para direcciones, usuarios y metodos de pago.

Condiciones tecnicas:
- Validar campos obligatorios y devolver codigos HTTP correctos.
- Responder JSON consistente.
- Separar modelos DTO, controladores y repositorio/servicio de datos.
- Preparar una capa de acceso a datos tipo AppDataRepository.
- Preparar un servicio tipo FirebaseService para configurar credenciales, project id y Firestore.
- Si Firebase esta mal configurado o no disponible, continuar con almacenamiento temporal en memoria.

## Requisitos del frontend Flutter

La app Flutter debe incluir como minimo:
- main.dart con MultiProvider.
- Providers separados para autenticacion, login, direcciones y metodos de pago.
- Servicios HTTP para auth, pedidos, direcciones y metodos de pago.
- Config centralizada para la URL del backend.
- Modelos Dart para usuario, direccion, tarjeta, servicios de lavanderia y franjas horarias.

La estructura sugerida es:
- lib/config/
- lib/models/
- lib/providers/
- lib/screens/
- lib/services/
- lib/utils/
- lib/widgets/

Pantallas minimas del frontend:

Autenticacion:
- Login.
- Crear cuenta.
- Recuperar contrasena.
- Terminos y condiciones.

Cliente:
- Home cliente.
- Servicios.
- Nueva orden.
- Agendar recoleccion.
- Pedido recibido.
- Mis pedidos.
- Detalle de factura.
- Repetir pedido.
- Pedido y seguimiento en vivo.
- Cancelar pedido.
- Calificar servicio.
- Reportar problema.
- Notificaciones.
- Mi perfil.
- Editar perfil.
- Cambiar contrasena.
- Mis direcciones.
- Formulario de direccion.
- Metodos de pago.
- Agregar tarjeta.
- Seleccionar direccion.
- Seleccionar metodo de pago.

Administrador:
- Home administrador.
- Monitorear pedidos.
- Administrar clientes.
- Configurar servicios.

## Flujo funcional esperado

El flujo general debe ser este:

1. El usuario abre la app.
2. Inicia sesion o crea una cuenta.
3. Si es cliente, entra al home de cliente.
4. Explora servicios de lavanderia.
5. Crea una nueva orden.
6. Selecciona servicio, direccion, franja horaria, instrucciones y metodo de pago.
7. Confirma el pedido.
8. El backend guarda el pedido con estado inicial "En proceso".
9. El cliente puede revisar sus pedidos, ver detalles, repetir, cancelar, calificar o reportar problemas.
10. El administrador puede monitorear y actualizar el estado del pedido.
11. El cliente visualiza cambios de estado y notificaciones asociadas.

## Requisitos de calidad

Quiero que el proyecto incluya:
- Codigo claro y ordenado.
- Nombres consistentes.
- Estructura mantenible.
- Validaciones basicas.
- Datos semilla o mock inicial para pruebas locales.
- Manejo de errores en frontend y backend.
- Comentarios solo cuando aporten contexto real.
- Separacion razonable entre UI, logica y acceso a datos.

## Requisitos de testing

Agrega pruebas minimas para backend, especialmente para:
- Login.
- Registro.
- Creacion de pedidos.
- Consulta de pedidos.
- Casos de error por datos faltantes.

## Entregables esperados

Genera:
- Estructura completa de carpetas.
- Archivos base del backend.
- Archivos base del frontend.
- Modelos, providers, servicios, pantallas y controladores necesarios.
- Configuracion local de entorno.
- Instrucciones para ejecutar backend y frontend.
- Datos de ejemplo para validar el flujo.

## Restricciones importantes

- No me entregues solo pseudocodigo.
- No simplifiques el proyecto a una sola pantalla o un solo endpoint.
- No acoples toda la logica al UI.
- No omitas la separacion entre cliente y administrador.
- No dependas obligatoriamente de Firebase para correr localmente.

## Resultado final esperado

Quiero una base de proyecto que permita demostrar un flujo completo de lavanderia de punta a punta: autenticacion, catalogo, creacion de pedido, gestion de direcciones, pagos, seguimiento de pedido y administracion.

Si necesitas tomar decisiones de implementacion, prioriza simplicidad, mantenibilidad y que el flujo principal funcione de extremo a extremo.
```

## Uso sugerido

Puedes pegar el prompt anterior en Copilot, ChatGPT o cualquier otra IA para pedir la generacion de una version completa del proyecto con backend y frontend.