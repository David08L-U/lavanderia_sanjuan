using Microsoft.AspNetCore.Mvc;
using backend;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private readonly AppDataRepository _repository;

    public UsuariosController(AppDataRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> Listar([FromQuery] string? rol)
    {
        var usuarios = await _repository.ListarUsuariosAsync();
        if (!string.IsNullOrWhiteSpace(rol))
        {
            usuarios = usuarios.Where(u => string.Equals(u.Rol, rol, StringComparison.OrdinalIgnoreCase)).ToList();
        }
        return Ok(usuarios);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> ActualizarPerfil(string id, [FromBody] ActualizarPerfilRequest request)
    {
        var usuario = await _repository.GetUsuarioByIdAsync(id);
        if (usuario == null)
        {
            return NotFound(new { message = "Usuario no encontrado" });
        }

        if (!string.IsNullOrWhiteSpace(request.Correo))
        {
            var existe = await _repository.ExisteCorreoAsync(request.Correo.Trim().ToLowerInvariant(), id);
            if (existe)
            {
                return Conflict(new { message = "Ese correo ya está registrado" });
            }
        }

        usuario.Nombre = string.IsNullOrWhiteSpace(request.Nombre) ? usuario.Nombre : request.Nombre;
        usuario.Correo = string.IsNullOrWhiteSpace(request.Correo) ? usuario.Correo : request.Correo;
        usuario.Telefono = string.IsNullOrWhiteSpace(request.Telefono) ? usuario.Telefono : request.Telefono;

        var guardado = await _repository.GuardarUsuarioAsync(usuario);
        return guardado == null
            ? NotFound(new { message = "Usuario no encontrado" })
            : Ok(guardado);
    }

    [HttpPost("cambiar-password")]
    public async Task<IActionResult> CambiarPassword([FromBody] CambiarPasswordRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.PasswordActual) || string.IsNullOrWhiteSpace(request.PasswordNueva))
        {
            return BadRequest(new { message = "Se requieren ambas contraseñas" });
        }

        var usuario = string.IsNullOrWhiteSpace(request.Correo)
            ? await _repository.GetUsuarioByPasswordAsync(request.PasswordActual)
            : await _repository.GetUsuarioByCorreoAsync(request.Correo.Trim().ToLowerInvariant());

        if (usuario == null)
        {
            return NotFound(new { message = "Usuario no encontrado" });
        }

        if (!string.Equals(usuario.Password, request.PasswordActual, StringComparison.Ordinal))
        {
            return Unauthorized(new { message = "La contraseña actual es incorrecta" });
        }

        usuario.Password = request.PasswordNueva;
        await _repository.GuardarUsuarioAsync(usuario);
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
