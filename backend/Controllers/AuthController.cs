using Microsoft.AspNetCore.Mvc;
using Google.Cloud.Firestore;
using backend.Services;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Linq;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly DatabaseService _db;

    public AuthController(DatabaseService db)
    {
        _db = db;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Correo) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new { message = "Correo y contraseña son requeridos" });
        }

        var usuarios = await _db.ListarUsuariosAsync();
        var usuario = usuarios.FirstOrDefault(u => string.Equals(u.Correo, request.Correo, StringComparison.OrdinalIgnoreCase));
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

        var usuarios = await _db.ListarUsuariosAsync();
        var existe = usuarios.Any(u => string.Equals(u.Correo, request.Correo, StringComparison.OrdinalIgnoreCase));
        if (existe)
        {
            return Conflict(new { message = "Ese correo ya está registrado" });
        }

        var nuevo = new UsuarioDto
        {
            Id = (usuarios.Count + 1).ToString(),
            Nombre = $"{request.Nombre} {request.Apellido}",
            Correo = request.Correo,
            Telefono = request.Telefono,
            Password = request.Password,
            Rol = "cliente"
        };

        await _db.GuardarUsuarioAsync(nuevo);

        return StatusCode(201, nuevo);
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

[FirestoreData]
public class UsuarioDto
{
    [FirestoreProperty]
    public string? Id { get; set; }
    [FirestoreProperty]
    public string? Nombre { get; set; }
    [FirestoreProperty]
    public string? Correo { get; set; }
    [FirestoreProperty]
    public string? Telefono { get; set; }
    [FirestoreProperty]
    public string? Password { get; set; }
    [FirestoreProperty]
    public string? Rol { get; set; }
}
