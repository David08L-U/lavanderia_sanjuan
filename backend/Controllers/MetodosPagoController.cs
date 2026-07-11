using Microsoft.AspNetCore.Mvc;
using Google.Cloud.Firestore;
using backend.Services;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Linq;

namespace backend.Controllers;

[ApiController]
[Route("api/metodos-pago")]
public class MetodosPagoController : ControllerBase
{
    private readonly DatabaseService _db;

    public MetodosPagoController(DatabaseService db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> Listar()
    {
        var metodos = await _db.ListarMetodosPagoAsync();
        return Ok(metodos);
    }

    [HttpPost]
    public async Task<IActionResult> Crear([FromBody] CrearMetodoPagoRequest request)
    {
        var metodos = await _db.ListarMetodosPagoAsync();
        var metodo = new MetodoPagoDto
        {
            Id = (metodos.Count + 1).ToString(),
            Marca = string.IsNullOrWhiteSpace(request.Marca) ? "visa" : request.Marca,
            UltimosDigitos = request.UltimosDigitos ?? string.Empty,
            Expira = request.Expira ?? string.Empty,
            Principal = request.Principal
        };

        await _db.GuardarMetodoPagoAsync(metodo);
        return CreatedAtAction(nameof(Obtener), new { id = metodo.Id }, metodo);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Obtener(string id)
    {
        var metodos = await _db.ListarMetodosPagoAsync();
        var metodo = metodos.FirstOrDefault(m => m.Id == id);
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

[FirestoreData]
public class MetodoPagoDto
{
    [FirestoreProperty]
    public string? Id { get; set; }
    [FirestoreProperty]
    public string? Marca { get; set; }
    [FirestoreProperty]
    public string? UltimosDigitos { get; set; }
    [FirestoreProperty]
    public string? Expira { get; set; }
    [FirestoreProperty]
    public bool Principal { get; set; }
}
