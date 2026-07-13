using Microsoft.AspNetCore.Mvc;
using backend;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDataRepository _repository;

    public AuthController(AppDataRepository repository)
    {
        _repository = repository;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Correo) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Correo y contraseña son requeridos" });
        }

        var usuario = await _repository.GetUsuarioByCorreoAsync(request.Correo.Trim());
        if (usuario == null)
        {
            return NotFound(new { message = "Usuario no encontrado" });
        }

        if (!string.Equals(usuario.Password, request.Password, StringComparison.Ordinal))
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
    public async Task<IActionResult> Registro([FromBody] RegistroRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Nombre) || string.IsNullOrWhiteSpace(request.Apellido) || string.IsNullOrWhiteSpace(request.Correo) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Faltan datos obligatorios" });
        }

        var correo = request.Correo.Trim().ToLowerInvariant();
        var existe = await _repository.ExisteCorreoAsync(correo);
        if (existe)
        {
            return Conflict(new { message = "Ese correo ya está registrado" });
        }

        var nuevo = new UsuarioDto
        {
            Nombre = $"{request.Nombre} {request.Apellido}",
            Correo = correo,
            Telefono = request.Telefono,
            Password = request.Password,
            Rol = "cliente"
        };

        var creado = await _repository.CrearUsuarioAsync(nuevo);

        return CreatedAtAction(nameof(Login), new { id = creado.Id }, creado);
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
