using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    // ⚠️ TEMPORAL — cuentas de prueba locales para poder testear la app mientras
    // Supabase no está configurado (Supabase:Enabled/Url/AnonKey/ServiceRoleKey vacíos).
    // Solo se usan cuando _supabaseService.IsConfigured es false, así que en cuanto
    // se configure Supabase real este bloque deja de activarse solo — se puede borrar
    // por completo (este diccionario + el bloque "if (!_supabaseService.IsConfigured)"
    // dentro de Login) sin afectar el resto del flujo.
    private static readonly Dictionary<string, (string Password, UsuarioDto Usuario)> CuentasDePruebaLocales = new()
    {
        ["admin123@gmail.com"] = ("admin123", new UsuarioDto { Id = "test-admin", Nombre = "Admin de Prueba", Correo = "admin123@gmail.com", Rol = "administrador" }),
        ["cliente@gmail.com"] = ("cliente123", new UsuarioDto { Id = "test-cliente", Nombre = "Cliente de Prueba", Correo = "cliente@gmail.com", Rol = "cliente" }),
    };

    private readonly SupabaseService _supabaseService;

    public AuthController(SupabaseService supabaseService)
    {
        _supabaseService = supabaseService;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Correo) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Correo y contraseña son requeridos" });
        }

        if (!_supabaseService.IsConfigured)
        {
            var correo = request.Correo.Trim().ToLowerInvariant();
            if (CuentasDePruebaLocales.TryGetValue(correo, out var cuenta))
            {
                if (cuenta.Password != request.Password)
                {
                    return Unauthorized(new { message = "Correo o contraseña incorrectos" });
                }
                return Ok(cuenta.Usuario);
            }

            return StatusCode(StatusCodes.Status503ServiceUnavailable, new { message = "Supabase no está configurado en el backend" });
        }

        var login = await _supabaseService.LoginAsync(request.Correo, request.Password);
        if (!login.Success)
        {
            return StatusCode(login.StatusCode, new { message = login.ErrorMessage ?? "No se pudo iniciar sesión" });
        }

        return Ok(login.Usuario);
    }

    [HttpPost("registro")]
    public async Task<IActionResult> Registro([FromBody] RegistroRequest request)
    {
        if (!_supabaseService.IsConfigured)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable, new { message = "Supabase no está configurado en el backend" });
        }

        if (string.IsNullOrWhiteSpace(request.Nombre) || string.IsNullOrWhiteSpace(request.Apellido) || string.IsNullOrWhiteSpace(request.Correo) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Faltan datos obligatorios" });
        }

        var registro = await _supabaseService.RegisterAsync(
            request.Nombre,
            request.Apellido,
            request.Correo,
            request.Telefono ?? string.Empty,
            request.Password);

        if (!registro.Success)
        {
            return StatusCode(registro.StatusCode, new { message = registro.ErrorMessage ?? "No se pudo crear la cuenta" });
        }

        return CreatedAtAction(nameof(Login), new { id = registro.Usuario?.Id }, registro.Usuario);
    }

    [HttpPost("recuperar-password")]
    public async Task<IActionResult> RecuperarPassword([FromBody] RecuperarPasswordRequest request)
    {
        if (!_supabaseService.IsConfigured)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable, new { message = "Supabase no está configurado en el backend" });
        }

        if (string.IsNullOrWhiteSpace(request.Correo))
        {
            return BadRequest(new { message = "Correo requerido" });
        }

        var result = await _supabaseService.RequestPasswordRecoveryAsync(request.Correo);
        if (!result.Success)
        {
            return StatusCode(result.StatusCode, new { message = result.ErrorMessage ?? "No se pudo procesar la recuperación" });
        }

        return Ok(new { message = "Si el correo existe, se enviará un enlace de recuperación" });
    }
}

public class LoginRequest
{
    public string? Correo { get; set; }
    public string? Password { get; set; }
}

public class RegistroRequest
{
    public string? Nombre { get; set; }
    public string? Apellido { get; set; }
    public string? Correo { get; set; }
    public string? Telefono { get; set; }
    public string? Password { get; set; }
}

public class RecuperarPasswordRequest
{
    public string? Correo { get; set; }
}

public class UsuarioDto
{
    public string? Id { get; set; }
    public string? Nombre { get; set; }
    public string? Correo { get; set; }
    public string? Telefono { get; set; }
    public string? Password { get; set; }
    public string? Rol { get; set; }
}
