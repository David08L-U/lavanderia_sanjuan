using Microsoft.AspNetCore.Mvc;
using backend;

namespace backend.Controllers;

[ApiController]
[Route("api/direcciones")]
public class DireccionesController : ControllerBase
{
    private readonly AppDataRepository _repository;

    public DireccionesController(AppDataRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> Listar()
    {
        var direcciones = await _repository.ListarDireccionesAsync();
        return Ok(direcciones);
    }

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] CrearDireccionRequest request)
    {
        var direccion = new DireccionDto
        {
            Titulo = string.IsNullOrWhiteSpace(request.Titulo) ? "Nueva dirección" : request.Titulo,
            Lineas = request.Lineas ?? new List<string>(),
            Telefono = request.Telefono,
            Nota = request.Nota,
            Predeterminada = request.Predeterminada
        };

        var creada = await _repository.CrearDireccionAsync(direccion);
        return CreatedAtAction(nameof(Obtener), new { id = creada.Id }, creada);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Obtener(string id)
    {
        var direccion = await _repository.ObtenerDireccionAsync(id);
        return direccion == null ? NotFound(new { message = "Dirección no encontrada" }) : Ok(direccion);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Actualizar(string id, [FromBody] CrearDireccionRequest request)
    {
        var direccionActual = await _repository.ObtenerDireccionAsync(id);
        if (direccionActual == null)
        {
            return NotFound(new { message = "Dirección no encontrada" });
        }

        direccionActual.Titulo = string.IsNullOrWhiteSpace(request.Titulo) ? direccionActual.Titulo : request.Titulo;
        direccionActual.Lineas = request.Lineas ?? direccionActual.Lineas;
        direccionActual.Telefono = request.Telefono;
        direccionActual.Nota = request.Nota;
        direccionActual.Predeterminada = request.Predeterminada;

        var actualizada = await _repository.ActualizarDireccionAsync(id, direccionActual);
        return actualizada == null
            ? NotFound(new { message = "Dirección no encontrada" })
            : Ok(actualizada);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Eliminar(string id)
    {
        var eliminada = await _repository.EliminarDireccionAsync(id);
        if (!eliminada)
        {
            return NotFound(new { message = "Dirección no encontrada" });
        }
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
