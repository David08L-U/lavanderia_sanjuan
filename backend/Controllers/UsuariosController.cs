using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private static readonly List<UsuarioDto> Usuarios = UsuarioRepository.Usuarios;


    [HttpPut("{id}")]
    public IActionResult ActualizarPerfil(string id, [FromBody] ActualizarPerfilRequest request)
    {
        var usuario = Usuarios.FirstOrDefault(u => u.Id == id);
        if (usuario == null)
        {
            return NotFound(new { message = "Usuario no encontrado" });
        }

        if (!string.IsNullOrWhiteSpace(request.Correo))
        {
            var existe = Usuarios.Any(u => u.Id != id && string.Equals(u.Correo, request.Correo, StringComparison.OrdinalIgnoreCase));
            if (existe)
            {
                return Conflict(new { message = "Ese correo ya está registrado" });
            }
        }

        usuario.Nombre = string.IsNullOrWhiteSpace(request.Nombre) ? usuario.Nombre : request.Nombre;
        usuario.Correo = string.IsNullOrWhiteSpace(request.Correo) ? usuario.Correo : request.Correo;
        usuario.Telefono = string.IsNullOrWhiteSpace(request.Telefono) ? usuario.Telefono : request.Telefono;

        return Ok(usuario);
    }

    [HttpPost("cambiar-password")]
    public IActionResult CambiarPassword([FromBody] CambiarPasswordRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.PasswordActual) || string.IsNullOrWhiteSpace(request.PasswordNueva))
        {
            return BadRequest(new { message = "Se requieren ambas contraseñas" });
        }

        var usuario = string.IsNullOrWhiteSpace(request.Correo)
            ? Usuarios.FirstOrDefault(u => string.Equals(u.Password, request.PasswordActual, StringComparison.Ordinal))
            : Usuarios.FirstOrDefault(u => string.Equals(u.Correo, request.Correo, StringComparison.OrdinalIgnoreCase));

        if (usuario == null)
        {
            return NotFound(new { message = "Usuario no encontrado" });
        }

        if (!string.Equals(usuario.Password, request.PasswordActual, StringComparison.Ordinal))
        {
            return Unauthorized(new { message = "La contraseña actual es incorrecta" });
        }

        usuario.Password = request.PasswordNueva;
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
