using Microsoft.AspNetCore.Mvc;
using backend;

namespace backend.Controllers;

[ApiController]
[Route("api/metodos-pago")]
public class MetodosPagoController : ControllerBase
{
    private readonly AppDataRepository _repository;

    public MetodosPagoController(AppDataRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> Listar()
    {
        var metodos = await _repository.ListarMetodosPagoAsync();
        return Ok(metodos);
    }

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] CrearMetodoPagoRequest request)
    {
        var metodo = new MetodoPagoDto
        {
            Marca = string.IsNullOrWhiteSpace(request.Marca) ? "visa" : request.Marca,
            UltimosDigitos = request.UltimosDigitos ?? string.Empty,
            Expira = request.Expira ?? string.Empty,
            Principal = request.Principal
        };

        var creado = await _repository.CrearMetodoPagoAsync(metodo);
        return CreatedAtAction(nameof(Obtener), new { id = creado.Id }, creado);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Obtener(string id)
    {
        var metodo = await _repository.ObtenerMetodoPagoAsync(id);
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
