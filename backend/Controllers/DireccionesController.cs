using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/direcciones")]
public class DireccionesController : ControllerBase
{
    private static readonly List<DireccionDto> Direcciones = new()
    {
        new()
        {
            Id = "1",
            Titulo = "Casa Principal",
            Lineas = new List<string> { "Av. Siempre Viva 742", "Springfield, CP 12345" },
            Telefono = "+34 555 123 456",
            Nota = "Entregar en la puerta principal",
            Predeterminada = true
        },
        new()
        {
            Id = "2",
            Titulo = "Oficina",
            Lineas = new List<string> { "Torre Empresarial, Piso 5", "Centro, CP 54321" },
            Telefono = "+34 555 987 654",
            Nota = "Entregar en recepción",
            Predeterminada = false
        }
    };

    [HttpGet]
    public IActionResult Listar()
    {
        return Ok(Direcciones);
    }

    [HttpPost]
    public IActionResult Crear([FromBody] CrearDireccionRequest request)
    {
        var direccion = new DireccionDto
        {
            Id = (Direcciones.Count + 1).ToString(),
            Titulo = string.IsNullOrWhiteSpace(request.Titulo) ? "Nueva dirección" : request.Titulo,
            Lineas = request.Lineas ?? new List<string>(),
            Telefono = request.Telefono,
            Nota = request.Nota,
            Predeterminada = request.Predeterminada
        };

        Direcciones.Add(direccion);
        return CreatedAtAction(nameof(Obtener), new { id = direccion.Id }, direccion);
    }

    [HttpGet("{id}")]
    public IActionResult Obtener(string id)
    {
        var direccion = Direcciones.FirstOrDefault(d => d.Id == id);
        return direccion == null ? NotFound(new { message = "Dirección no encontrada" }) : Ok(direccion);
    }

    [HttpPut("{id}")]
    public IActionResult Actualizar(string id, [FromBody] CrearDireccionRequest request)
    {
        var direccion = Direcciones.FirstOrDefault(d => d.Id == id);
        if (direccion == null)
        {
            return NotFound(new { message = "Dirección no encontrada" });
        }

        direccion.Titulo = string.IsNullOrWhiteSpace(request.Titulo) ? direccion.Titulo : request.Titulo;
        direccion.Lineas = request.Lineas ?? direccion.Lineas;
        direccion.Telefono = request.Telefono;
        direccion.Nota = request.Nota;
        direccion.Predeterminada = request.Predeterminada;

        return Ok(direccion);
    }

    [HttpDelete("{id}")]
    public IActionResult Eliminar(string id)
    {
        var direccion = Direcciones.FirstOrDefault(d => d.Id == id);
        if (direccion == null)
        {
            return NotFound(new { message = "Dirección no encontrada" });
        }

        Direcciones.Remove(direccion);
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
