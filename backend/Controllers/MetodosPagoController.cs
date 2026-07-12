using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/metodos-pago")]
public class MetodosPagoController : ControllerBase
{
    private static readonly List<MetodoPagoDto> MetodosPago = new()
    {
        new()
        {
            Id = "1",
            Marca = "visa",
            UltimosDigitos = "4242",
            Expira = "12/26",
            Principal = true
        },
        new()
        {
            Id = "2",
            Marca = "mastercard",
            UltimosDigitos = "8819",
            Expira = "08/24",
            Principal = false
        }
    };

    [HttpGet]
    public IActionResult Listar()
    {
        return Ok(MetodosPago);
    }

    [HttpPost]
    public IActionResult Crear([FromBody] CrearMetodoPagoRequest request)
    {
        var metodo = new MetodoPagoDto
        {
            Id = (MetodosPago.Count + 1).ToString(),
            Marca = string.IsNullOrWhiteSpace(request.Marca) ? "visa" : request.Marca,
            UltimosDigitos = request.UltimosDigitos ?? string.Empty,
            Expira = request.Expira ?? string.Empty,
            Principal = request.Principal
        };

        MetodosPago.Add(metodo);
        return CreatedAtAction(nameof(Obtener), new { id = metodo.Id }, metodo);
    }

    [HttpGet("{id}")]
    public IActionResult Obtener(string id)
    {
        var metodo = MetodosPago.FirstOrDefault(m => m.Id == id);
        return metodo == null ? NotFound(new { message = "Método de pago no encontrado" }) : Ok(metodo);
    }
}

public class CrearMetodoPagoRequest
{
    public string? Marca { get; set; }
    public string? UltimosDigitos { get; set; }
    public string? Expira { get; set; }
    public bool Principal { get; set; }
}

public class MetodoPagoDto
{
    public string? Id { get; set; }
    public string? Marca { get; set; }
    public string? UltimosDigitos { get; set; }
    public string? Expira { get; set; }
    public bool Principal { get; set; }
}
