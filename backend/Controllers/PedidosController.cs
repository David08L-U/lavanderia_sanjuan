using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PedidosController : ControllerBase
{
    private static readonly List<PedidoDto> Pedidos = new()
    {
        new()
        {
            Id = "1",
            ClienteId = "2",
            ClienteNombre = "Cliente Demo",
            Servicio = "Lavado y Doblado",
            Fecha = "2026-07-08",
            FranjaHoraria = "Tarde",
            Direccion = "Calle 45 # 10-20",
            Instrucciones = "Lavar con agua fría",
            Total = 25m,
            Estado = "En proceso",
            HistorialEstados = new List<EstadoHistorial>
            {
                new() { Estado = "Creado", Fecha = "2026-07-08T10:00:00", Observaciones = "Pedido creado exitosamente" },
                new() { Estado = "Confirmado", Fecha = "2026-07-08T11:30:00", Observaciones = "Pedido confirmado por el equipo" },
                new() { Estado = "En proceso", Fecha = "2026-07-09T09:00:00", Observaciones = "Inicio del servicio de lavado" }
            }
        }
    };

    [HttpGet]
    public IActionResult Listar([FromQuery] string? clienteId)
    {
        var result = string.IsNullOrWhiteSpace(clienteId)
            ? Pedidos
            : Pedidos.Where(p => p.ClienteId == clienteId).ToList();

        return Ok(result);
    }

    [HttpGet("{id}")]
    public IActionResult Obtener(string id)
    {
        var pedido = Pedidos.FirstOrDefault(p => p.Id == id);
        return pedido == null ? NotFound(new { message = "Pedido no encontrado" }) : Ok(pedido);
    }

    [HttpPost]
    public IActionResult Crear([FromBody] CrearPedidoRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Servicio))
        {
            return BadRequest(new { message = "El servicio es obligatorio" });
        }

        var pedido = new PedidoDto
        {
            Id = (Pedidos.Count + 1).ToString(),
            ClienteId = request.ClienteId ?? "2",
            ClienteNombre = request.ClienteNombre ?? "Cliente Demo",
            Servicio = request.Servicio,
            Fecha = string.IsNullOrWhiteSpace(request.Fecha) ? DateTime.Now.ToString("yyyy-MM-dd") : request.Fecha,
            FranjaHoraria = string.IsNullOrWhiteSpace(request.FranjaHoraria) ? "Tarde" : request.FranjaHoraria,
            Direccion = string.IsNullOrWhiteSpace(request.Direccion) ? "Sin dirección" : request.Direccion,
            Instrucciones = request.Instrucciones ?? string.Empty,
            Total = request.Total ?? 0m,
            Estado = "En proceso"
        };

        Pedidos.Add(pedido);
        return CreatedAtAction(nameof(Obtener), new { id = pedido.Id }, pedido);
    }

    [HttpPut("{id}/estado")]
    public IActionResult ActualizarEstado(string id, [FromBody] ActualizarEstadoRequest request)
    {
        var pedido = Pedidos.FirstOrDefault(p => p.Id == id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        pedido.Estado = string.IsNullOrWhiteSpace(request.Estado) ? pedido.Estado : request.Estado;
        return Ok(pedido);
    }

    [HttpPost("{id}/cancelar")]
    public IActionResult Cancelar(string id, [FromBody] CancelarPedidoRequest request)
    {
        var pedido = Pedidos.FirstOrDefault(p => p.Id == id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        pedido.Estado = "Cancelado";
        return Ok(new
        {
            message = "Pedido cancelado correctamente",
            pedidoId = id,
            razon = request.Razon ?? "Otro",
            comentarios = request.Comentarios ?? string.Empty
        });
    }

    [HttpPost("{id}/calificar")]
    public IActionResult Calificar(string id, [FromBody] CalificarPedidoRequest request)
    {
        var pedido = Pedidos.FirstOrDefault(p => p.Id == id);
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
    public IActionResult Reportar(string id, [FromBody] ReportarPedidoRequest request)
    {
        var pedido = Pedidos.FirstOrDefault(p => p.Id == id);
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
}
