using Microsoft.AspNetCore.Mvc;
using backend.Services;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Linq;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PedidosController : ControllerBase
{
    private readonly DatabaseService _db;

    public PedidosController(DatabaseService db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> Listar([FromQuery] string? clienteId)
    {
        var pedidos = await _db.ListarPedidosAsync();
        var result = string.IsNullOrWhiteSpace(clienteId)
            ? pedidos
            : pedidos.Where(p => p.ClienteId == clienteId).ToList();

        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Obtener(string id)
    {
        var pedidos = await _db.ListarPedidosAsync();
        var pedido = pedidos.FirstOrDefault(p => p.Id == id);
        return pedido == null ? NotFound(new { message = "Pedido no encontrado" }) : Ok(pedido);
    }

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] CrearPedidoRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Servicio))
        {
            return BadRequest(new { message = "El servicio es obligatorio" });
        }

        var pedidos = await _db.ListarPedidosAsync();
        var pedido = new PedidoDto
        {
            Id = (pedidos.Count + 1).ToString(),
            ClienteId = request.ClienteId ?? "2",
            ClienteNombre = request.ClienteNombre ?? "Cliente Demo",
            Servicio = request.Servicio,
            Fecha = string.IsNullOrWhiteSpace(request.Fecha) ? DateTime.Now.ToString("yyyy-MM-dd") : request.Fecha,
            FranjaHoraria = string.IsNullOrWhiteSpace(request.FranjaHoraria) ? "Tarde" : request.FranjaHoraria,
            Direccion = string.IsNullOrWhiteSpace(request.Direccion) ? "Sin dirección" : request.Direccion,
            Instrucciones = request.Instrucciones ?? string.Empty,
            Total = (double)(request.Total ?? 0m),
            Estado = "Pendiente"
        };

        await _db.GuardarPedidoAsync(pedido);
        return CreatedAtAction(nameof(Obtener), new { id = pedido.Id }, pedido);
    }

    [HttpPut("{id}/estado")]
    public async Task<IActionResult> ActualizarEstado(string id, [FromBody] ActualizarEstadoRequest request)
    {
        var pedidos = await _db.ListarPedidosAsync();
        var pedido = pedidos.FirstOrDefault(p => p.Id == id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        pedido.Estado = string.IsNullOrWhiteSpace(request.Estado) ? pedido.Estado : request.Estado;
        await _db.GuardarPedidoAsync(pedido);
        return Ok(pedido);
    }

    [HttpPost("{id}/cancelar")]
    public async Task<IActionResult> Cancelar(string id, [FromBody] CancelarPedidoRequest request)
    {
        var pedidos = await _db.ListarPedidosAsync();
        var pedido = pedidos.FirstOrDefault(p => p.Id == id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        pedido.Estado = "Cancelado";
        await _db.GuardarPedidoAsync(pedido);
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
        var pedidos = await _db.ListarPedidosAsync();
        var pedido = pedidos.FirstOrDefault(p => p.Id == id);
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
        var pedidos = await _db.ListarPedidosAsync();
        var pedido = pedidos.FirstOrDefault(p => p.Id == id);
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
    public double Total { get; set; }
    public string? Estado { get; set; }
}
