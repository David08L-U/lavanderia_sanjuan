# Lavandería San Juan

Monorepo del proyecto: backend en .NET (`Backend/`), app en Flutter (`frontend/`), y capturas de diseño de las pantallas admin (`pantallas-adm/`).

## Backend: conectar Supabase (auth real)

El backend usa [Supabase](https://supabase.com) para autenticación (login, registro, cambiar contraseña, recuperar contraseña). Sin esto configurado, esos endpoints responden `503 Supabase no está configurado en el backend`.

Las credenciales **no se guardan en `appsettings.json`** (para no exponerlas en el repo). Se configuran localmente con `dotnet user-secrets`, que las guarda fuera del proyecto, en tu perfil de usuario de Windows. Cada persona que quiera correr el backend con Supabase real necesita correr estos 4 comandos una sola vez, en su propia máquina:

```bash
cd Backend
dotnet user-secrets init   # solo la primera vez, si el proyecto no tiene ya un UserSecretsId
dotnet user-secrets set "Supabase:Enabled" "true"
dotnet user-secrets set "Supabase:Url" "https://TU-PROYECTO.supabase.co"
dotnet user-secrets set "Supabase:AnonKey" "TU_ANON_KEY"
dotnet user-secrets set "Supabase:ServiceRoleKey" "TU_SERVICE_ROLE_KEY"
```

Después de eso, `dotnet run` dentro de `Backend/` ya arranca conectado a Supabase. Vas a ver en la consola:

```
info: backend[0]
      Supabase configurado para URL https://TU-PROYECTO.supabase.co
```

Si en cambio ves una advertencia de que Supabase no está configurado, revisa que los 4 valores estén bien puestos con `dotnet user-secrets list`.

### ¿Dónde encuentro estas credenciales en Supabase?

Entra a [supabase.com](https://supabase.com) → tu organización → tu proyecto, y luego:

1. Ve al ícono de engrane **Project Settings** (barra lateral izquierda, abajo).
2. Entra a la sección **API** (a veces aparece como "Data API").
3. Ahí vas a encontrar:
   - **Project URL** → esto es `Supabase:Url`. Ojo: debe ser la URL base del proyecto (`https://xxxxx.supabase.co`), **no** la que termina en `/rest/v1/` — esa es para otra cosa (la API de la base de datos, no la de auth).
   - **Project API keys** → ahí aparecen dos:
     - `anon` / `public` → esto es `Supabase:AnonKey`. Es segura de exponer en apps cliente, pero igual no hace falta subirla al repo.
     - `service_role` → esto es `Supabase:ServiceRoleKey`. **Esta sí es secreta** — tiene acceso total, saltándose todas las reglas de seguridad (RLS). Nunca la pongas en el frontend, ni en appsettings.json, ni la compartas por chats o canales no privados.

Nota: Supabase está migrando a un formato nuevo de llaves (`sb_publishable_...` / `sb_secret_...`) en vez del JWT clásico. Ambos formatos deberían funcionar con este backend, pero si algo falla, prueba primero con las llaves en formato JWT (las que dicen `anon` `public` con un token largo que empieza con `eyJ...`).

### Cuentas de prueba

Ya existen 2 cuentas reales creadas directamente en Supabase para testear la app:

| Correo | Contraseña | Rol |
|---|---|---|
| `admin123@gmail.com` | `admin123` | administrador |
| `cliente@gmail.com` | `cliente123` | cliente |

### Fallback temporal (solo si Supabase no está configurado)

`AuthController.cs` tiene un bloque marcado con ⚠️ **TEMPORAL** que reconoce esas mismas 2 cuentas de prueba **sin** pegarle a Supabase. Solo se activa si `Supabase:IsConfigured` es `false` (o sea, si no configuraste los user-secrets de arriba), así que en cuanto Supabase esté conectado este bloque deja de usarse automáticamente. Se puede borrar por completo sin afectar nada más, en cuanto ya no haga falta.

## Probar la app en un celular físico (Android)

El backend corre en tu computadora en `http://localhost:5162`. Si pruebas la app en un **emulador** de Android, esa URL ya funciona tal cual (Flutter/Android resuelve `localhost` dentro del emulador hacia la máquina host). Pero si pruebas en un **celular físico** conectado por USB, `localhost` dentro del teléfono apunta al propio teléfono, no a tu computadora — y vas a ver un error como:

```
ClientException with SocketException: Connection refused (OS Error: Connection refused, errno = 111)
```

Para arreglarlo, cada vez que conectes el celular por USB (con la depuración USB activada) corre, antes de abrir la app:

```bash
adb reverse tcp:5162 tcp:5162
```

Esto reenvía el puerto 5162 del teléfono hacia el 5162 de tu computadora mientras el cable siga conectado. Si desconectas el celular o reinicias, hay que volver a correrlo.

Si vas a probar por WiFi en vez de USB, en cambio necesitas reemplazar `localhost` por la IP local de tu computadora (ej. `192.168.1.50`) en los `_baseUrl` de `frontend/lib/services/` — pero para el USB de arriba no hace falta tocar código.

## Seguridad

- **Nunca** commitees `.env.local` (ya está en `.gitignore`) ni pegues `Supabase:ServiceRoleKey` en código, configs versionados, o mensajes de chats compartidos.
- Si sospechas que una `service_role` key se expuso, revócala y genera una nueva desde Project Settings → API → "Reset service_role key" en Supabase.
