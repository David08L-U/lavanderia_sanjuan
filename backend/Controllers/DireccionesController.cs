using Microsoft.AspNetCore.Mvc;
using backend.Services;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Linq;

namespace backend.Controllers;

[ApiController]
[Route("api/direcciones")]
public class DireccionesController : ControllerBase
{
    private readonly DatabaseService _db;

    public DireccionesController(DatabaseService db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> Listar()
    {
        var direcciones = await _db.ListarDireccionesAsync();
        return Ok(direcciones);
    }

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] CrearDireccionRequest request)
    {
        var direcciones = await _db.ListarDireccionesAsync();
        var direccion = new DireccionDto
        {
            Id = (direcciones.Count + 1).ToString(),
            Titulo = string.IsNullOrWhiteSpace(request.Titulo) ? "Nueva dirección" : request.Titulo,
            Lineas = request.Lineas ?? new List<string>(),
            Telefono = request.Telefono,
            Nota = request.Nota,
            Predeterminada = request.Predeterminada
        };

        await _db.GuardarDireccionAsync(direccion);
        return CreatedAtAction(nameof(Obtener), new { id = direccion.Id }, direccion);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Obtener(string id)
    {
        var direcciones = await _db.ListarDireccionesAsync();
        var direccion = direcciones.FirstOrDefault(d => d.Id == id);
        return direccion == null ? NotFound(new { message = "Dirección no encontrada" }) : Ok(direccion);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Actualizar(string id, [FromBody] CrearDireccionRequest request)
    {
        var direcciones = await _db.ListarDireccionesAsync();
        var direccion = direcciones.FirstOrDefault(d => d.Id == id);
        if (direccion == null)
        {
            return NotFound(new { message = "Dirección no encontrada" });
        }

        direccion.Titulo = string.IsNullOrWhiteSpace(request.Titulo) ? direccion.Titulo : request.Titulo;
        direccion.Lineas = request.Lineas ?? direccion.Lineas;
        direccion.Telefono = request.Telefono;
        direccion.Nota = request.Nota;
        direccion.Predeterminada = request.Predeterminada;

        await _db.GuardarDireccionAsync(direccion);
        return Ok(direccion);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Eliminar(string id)
    {
        var direcciones = await _db.ListarDireccionesAsync();
        var direccion = direcciones.FirstOrDefault(d => d.Id == id);
        if (direccion == null)
        {
            return NotFound(new { message = "Dirección no encontrada" });
        }

        await _db.EliminarDireccionAsync(id);
        return Ok(new { message = "Dirección eliminada" });
    }
}

public class CrearDireccionRequest
{
    public string? Titulo { get; set; }
    public List<string>? Lineas { get; set; }
    public string? Telefono { get; set; }
    public string? Nota { get; set; }
    public bool Predeterminada { get; set; }
}

public class DireccionDto
{
    public string? Id { get; set; }
    public string? Titulo { get; set; }
    public List<string>? Lineas { get; set; }
    public string? Telefono { get; set; }
    public string? Nota { get; set; }
    public bool Predeterminada { get; set; }
}
