using Microsoft.AspNetCore.Mvc;
using backend;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PedidosController : ControllerBase
{
    private readonly AppDataRepository _repository;

    public PedidosController(AppDataRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> Listar([FromQuery] string? clienteId)
    {
        var result = await _repository.ListarPedidosAsync(clienteId);
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Obtener(string id)
    {
        var pedido = await _repository.ObtenerPedidoAsync(id);
        return pedido == null ? NotFound(new { message = "Pedido no encontrado" }) : Ok(pedido);
    }

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] CrearPedidoRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Servicio))
        {
            return BadRequest(new { message = "El servicio es obligatorio" });
        }

        var pedido = new PedidoDto
        {
            ClienteId = request.ClienteId ?? "2",
            ClienteNombre = request.ClienteNombre ?? "Cliente Demo",
            Servicio = request.Servicio,
            Fecha = string.IsNullOrWhiteSpace(request.Fecha) ? DateTime.Now.ToString("yyyy-MM-dd") : request.Fecha,
            FranjaHoraria = string.IsNullOrWhiteSpace(request.FranjaHoraria) ? "Tarde" : request.FranjaHoraria,
            Direccion = string.IsNullOrWhiteSpace(request.Direccion) ? "Sin dirección" : request.Direccion,
            Instrucciones = request.Instrucciones ?? string.Empty,
            Total = request.Total ?? 0m,
            Estado = "En proceso",
            HistorialEstados =
            [
                new()
                {
                    Estado = "En proceso",
                    Fecha = DateTime.UtcNow.ToString("O"),
                    Observaciones = "Pedido creado exitosamente"
                }
            ]
        };

        var creado = await _repository.CrearPedidoAsync(pedido);
        return CreatedAtAction(nameof(Obtener), new { id = creado.Id }, creado);
    }

    [HttpPut("{id}/estado")]
    public async Task<IActionResult> ActualizarEstado(string id, [FromBody] ActualizarEstadoRequest request)
    {
        var pedido = await _repository.ObtenerPedidoAsync(id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        pedido.Estado = string.IsNullOrWhiteSpace(request.Estado) ? pedido.Estado : request.Estado;
        pedido.HistorialEstados.Add(new EstadoHistorial
        {
            Estado = pedido.Estado,
            Fecha = DateTime.UtcNow.ToString("O"),
            Observaciones = "Estado actualizado"
        });

        await _repository.GuardarPedidoAsync(pedido);
        return Ok(pedido);
    }

    [HttpPost("{id}/cancelar")]
    public async Task<IActionResult> Cancelar(string id, [FromBody] CancelarPedidoRequest request)
    {
        var pedido = await _repository.ObtenerPedidoAsync(id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        pedido.Estado = "Cancelado";
        pedido.HistorialEstados.Add(new EstadoHistorial
        {
            Estado = "Cancelado",
            Fecha = DateTime.UtcNow.ToString("O"),
            Observaciones = request.Comentarios
        });
        await _repository.GuardarPedidoAsync(pedido);

        return Ok(new
        {
            message = "Pedido cancelado correctamente",
            pedidoId = id,
            razon = request.Razon ?? "Otro",
            comentarios = request.Comentarios ?? string.Empty
        });
    }

    [HttpPost("{id}/calificar")]
    public async Task<IActionResult> Calificar(string id, [FromBody] CalificarPedidoRequest request)
    {
        var pedido = await _repository.ObtenerPedidoAsync(id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        return Ok(new
        {
            message = "Calificación enviada correctamente",
            pedidoId = id,
            calificacionGeneral = request.CalificacionGeneral,
            reseña = request.Resena ?? string.Empty
        });
    }

    [HttpPost("{id}/reportar")]
    public async Task<IActionResult> Reportar(string id, [FromBody] ReportarPedidoRequest request)
    {
        var pedido = await _repository.ObtenerPedidoAsync(id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        return Ok(new
        {
            message = "Reporte enviado correctamente",
            pedidoId = id,
            tipo = request.Tipo ?? "Otro problema",
            detalles = request.Detalles ?? string.Empty
        });
    }
}

public class CrearPedidoRequest
{
    public string? ClienteId { get; set; }
    public string? ClienteNombre { get; set; }
    public string? Servicio { get; set; }
    public string? Fecha { get; set; }
    public string? FranjaHoraria { get; set; }
    public string? Direccion { get; set; }
    public string? Instrucciones { get; set; }
    public decimal? Total { get; set; }
}

public class ActualizarEstadoRequest
{
    public string? Estado { get; set; }
}

public class CancelarPedidoRequest
{
    public string? Razon { get; set; }
    public string? Comentarios { get; set; }
}

public class CalificarPedidoRequest
{
    public int CalificacionGeneral { get; set; }
    public string? Resena { get; set; }
}

public class ReportarPedidoRequest
{
    public string? Tipo { get; set; }
    public string? Detalles { get; set; }
}

public class PedidoDto
{
    public string? Id { get; set; }
    public string? ClienteId { get; set; }
    public string? ClienteNombre { get; set; }
    public string? Servicio { get; set; }
    public string? Fecha { get; set; }
    public string? FranjaHoraria { get; set; }
    public string? Direccion { get; set; }
    public string? Instrucciones { get; set; }
    public decimal Total { get; set; }
    public string? Estado { get; set; }
    public List<EstadoHistorial> HistorialEstados { get; set; } = [];
}

public class EstadoHistorial
{
    public string? Estado { get; set; }
    public string? Fecha { get; set; }
    public string? Observaciones { get; set; }
}
