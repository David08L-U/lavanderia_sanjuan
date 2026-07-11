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
public class UsuariosController : ControllerBase
{
    private readonly DatabaseService _db;

    public UsuariosController(DatabaseService db)
    {
        _db = db;
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> ActualizarPerfil(string id, [FromBody] ActualizarPerfilRequest request)
    {
        var usuarios = await _db.ListarUsuariosAsync();
        var usuario = usuarios.FirstOrDefault(u => u.Id == id);
        if (usuario == null)
        {
            return NotFound(new { message = "Usuario no encontrado" });
        }

        if (!string.IsNullOrWhiteSpace(request.Correo))
        {
            var existe = usuarios.Any(u => u.Id != id && string.Equals(u.Correo, request.Correo, StringComparison.OrdinalIgnoreCase));
            if (existe)
            {
                return Conflict(new { message = "Ese correo ya está registrado" });
            }
        }

        usuario.Nombre = string.IsNullOrWhiteSpace(request.Nombre) ? usuario.Nombre : request.Nombre;
        usuario.Correo = string.IsNullOrWhiteSpace(request.Correo) ? usuario.Correo : request.Correo;
        usuario.Telefono = string.IsNullOrWhiteSpace(request.Telefono) ? usuario.Telefono : request.Telefono;

        await _db.GuardarUsuarioAsync(usuario);
        return Ok(usuario);
    }

    [HttpPost("cambiar-password")]
    public async Task<IActionResult> CambiarPassword([FromBody] CambiarPasswordRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.PasswordActual) || string.IsNullOrWhiteSpace(request.PasswordNueva))
        {
            return BadRequest(new { message = "Se requieren ambas contraseñas" });
        }

        var usuarios = await _db.ListarUsuariosAsync();
        var usuario = string.IsNullOrWhiteSpace(request.Correo)
            ? usuarios.FirstOrDefault(u => string.Equals(u.Password, request.PasswordActual, StringComparison.Ordinal))
            : usuarios.FirstOrDefault(u => string.Equals(u.Correo, request.Correo, StringComparison.OrdinalIgnoreCase));

        if (usuario == null)
        {
            return NotFound(new { message = "Usuario no encontrado" });
        }

        if (!string.Equals(usuario.Password, request.PasswordActual, StringComparison.Ordinal))
        {
            return Unauthorized(new { message = "La contraseña actual es incorrecta" });
        }

        usuario.Password = request.PasswordNueva;
        await _db.GuardarUsuarioAsync(usuario);
        return Ok(new { message = "Contraseña actualizada" });
    }
}

public class ActualizarPerfilRequest
{
    public string? Nombre { get; set; }
    public string? Correo { get; set; }
    public string? Telefono { get; set; }
}

public class CambiarPasswordRequest
{
    public string? Correo { get; set; }
    public string? PasswordActual { get; set; }
    public string? PasswordNueva { get; set; }
}
