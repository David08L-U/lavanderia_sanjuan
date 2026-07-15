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
            ClienteEmail = "cliente@sanjuan.com",
            ClienteTelefono = "3007654321",
            Servicio = "Lavado y Doblado",
            Fecha = "2026-07-08",
            FranjaHoraria = "Tarde",
            Direccion = "Calle 45 # 10-20",
            Instrucciones = "Lavar con agua fría",
            EcoFriendly = false,
            Fragancia = "Lavanda",
            CantidadAproximada = 5,
            MetodoPago = "Efectivo contra entrega",
            Total = 25m,
            Estado = "Recibido"
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
            ClienteEmail = request.ClienteEmail,
            ClienteTelefono = request.ClienteTelefono,
            Servicio = request.Servicio,
            Fecha = string.IsNullOrWhiteSpace(request.Fecha) ? DateTime.Now.ToString("yyyy-MM-dd") : request.Fecha,
            FranjaHoraria = string.IsNullOrWhiteSpace(request.FranjaHoraria) ? "Tarde" : request.FranjaHoraria,
            Direccion = string.IsNullOrWhiteSpace(request.Direccion) ? "Sin dirección" : request.Direccion,
            Instrucciones = request.Instrucciones ?? string.Empty,
            EcoFriendly = request.EcoFriendly ?? false,
            Fragancia = request.Fragancia,
            CantidadAproximada = request.CantidadAproximada,
            MetodoPago = request.MetodoPago,
            Total = request.Total ?? 0m,
            Estado = "Recibido"
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

    [HttpPut("{id}/repartidor")]
    public IActionResult AsignarRepartidor(string id, [FromBody] AsignarRepartidorRequest request)
    {
        var pedido = Pedidos.FirstOrDefault(p => p.Id == id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        pedido.Repartidor = request.Repartidor;
        if (pedido.Estado == "Recibido")
        {
            pedido.Estado = "Asignado";
        }
        return Ok(pedido);
    }

    [HttpPut("{id}/confirmar-precio")]
    public IActionResult ConfirmarPrecio(string id, [FromBody] ConfirmarPrecioRequest request)
    {
        var pedido = Pedidos.FirstOrDefault(p => p.Id == id);
        if (pedido == null)
        {
            return NotFound(new { message = "Pedido no encontrado" });
        }

        pedido.PesoConfirmado = request.PesoConfirmado;
        pedido.TotalConfirmado = request.TotalConfirmado;
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
    public string? ClienteEmail { get; set; }
    public string? ClienteTelefono { get; set; }
    public string? Servicio { get; set; }
    public string? Fecha { get; set; }
    public string? FranjaHoraria { get; set; }
    public string? Direccion { get; set; }
    public string? Instrucciones { get; set; }
    public bool? EcoFriendly { get; set; }
    public string? Fragancia { get; set; }
    public int? CantidadAproximada { get; set; }
    public string? MetodoPago { get; set; }
    public decimal? Total { get; set; }
}

public class ActualizarEstadoRequest
{
    public string? Estado { get; set; }
}

public class AsignarRepartidorRequest
{
    public string? Repartidor { get; set; }
}

public class ConfirmarPrecioRequest
{
    public double? PesoConfirmado { get; set; }
    public decimal TotalConfirmado { get; set; }
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
    public string? ClienteEmail { get; set; }
    public string? ClienteTelefono { get; set; }
    public string? Servicio { get; set; }
    public string? Fecha { get; set; }
    public string? FranjaHoraria { get; set; }
    public string? Direccion { get; set; }
    public string? Instrucciones { get; set; }
    public bool EcoFriendly { get; set; }
    public string? Fragancia { get; set; }
    public int? CantidadAproximada { get; set; }
    public string? MetodoPago { get; set; }
    public string? Repartidor { get; set; }
    public double? PesoConfirmado { get; set; }
    public decimal? TotalConfirmado { get; set; }
    public decimal Total { get; set; }
    public string? Estado { get; set; }
}
