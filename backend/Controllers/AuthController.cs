using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private static readonly List<UsuarioDto> Usuarios = new()
    {
        new() { Id = "1", Nombre = "Admin San Juan", Correo = "admin@sanjuan.com", Telefono = "3001234567", Password = "admin123", Rol = "administrador" },
        new() { Id = "2", Nombre = "Cliente Demo", Correo = "cliente@sanjuan.com", Telefono = "3007654321", Password = "cliente123", Rol = "cliente" }
    };

    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Correo) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Correo y contraseña son requeridos" });
        }

        var usuario = Usuarios.FirstOrDefault(u => u.Correo.Equals(request.Correo, StringComparison.OrdinalIgnoreCase));
        if (usuario == null)
        {
            return NotFound(new { message = "Usuario no encontrado" });
        }

        if (!usuario.Password.Equals(request.Password))
        {
            return Unauthorized(new { message = "Correo o contraseña incorrectos" });
        }

        return Ok(new UsuarioDto
        {
            Id = usuario.Id,
            Nombre = usuario.Nombre,
            Correo = usuario.Correo,
            Telefono = usuario.Telefono,
            Rol = usuario.Rol
        });
    }

    [HttpPost("registro")]
    public IActionResult Registro([FromBody] RegistroRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Nombre) || string.IsNullOrWhiteSpace(request.Apellido) || string.IsNullOrWhiteSpace(request.Correo) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Faltan datos obligatorios" });
        }

        var existe = Usuarios.Any(u => u.Correo.Equals(request.Correo, StringComparison.OrdinalIgnoreCase));
        if (existe)
        {
            return Conflict(new { message = "Ese correo ya está registrado" });
        }

        var nuevo = new UsuarioDto
        {
            Id = (Usuarios.Count + 1).ToString(),
            Nombre = $"{request.Nombre} {request.Apellido}",
            Correo = request.Correo,
            Telefono = request.Telefono,
            Password = request.Password,
            Rol = "cliente"
        };

        Usuarios.Add(nuevo);

        return CreatedAtAction(nameof(Login), new { id = nuevo.Id }, nuevo);
    }

    [HttpPost("recuperar-password")]
    public IActionResult RecuperarPassword([FromBody] RecuperarPasswordRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Correo))
        {
            return BadRequest(new { message = "Correo requerido" });
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
