using backend;
using backend.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace backend.tests;

public class PedidosControllerTests
{
    [Fact]
    public async Task CancelarPedido_DeberiaRetornarOk()
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Firebase:Enabled"] = "false",
                ["Firebase:ProjectId"] = string.Empty,
                ["Firebase:CredentialsPath"] = string.Empty
            })
            .Build();

        var firebase = new FirebaseService(config);
        var repository = new AppDataRepository(firebase, NullLogger<AppDataRepository>.Instance);
        var controller = new PedidosController(repository);

        var creado = await controller.Crear(new CrearPedidoRequest
        {
            ClienteId = "cliente-prueba",
            ClienteNombre = "Cliente Prueba",
            Servicio = "Lavado x Kilo",
            Fecha = "2026-07-13",
            FranjaHoraria = "Tarde",
            Direccion = "Calle 123",
            Instrucciones = "Ninguna",
            Total = 20
        });

        var created = Assert.IsType<CreatedAtActionResult>(creado);
        var pedido = Assert.IsType<PedidoDto>(created.Value);

        var result = await controller.Cancelar(pedido.Id!, new CancelarPedidoRequest
        {
            Razon = "Otro",
            Comentarios = "Necesito cancelar"
        });

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.NotNull(ok.Value);
    }
}
