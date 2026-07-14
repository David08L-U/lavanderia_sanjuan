using backend.Controllers;
using backend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Xunit;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.tests;

public class PedidosControllerTests
{
    [Fact]
    public async Task CancelarPedido_DeberiaRetornarOk()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Supabase:Enabled"] = "false"
        }).Build();
        var supabaseService = new SupabaseService(config);
        var dbService = new DatabaseService(supabaseService);
        var controller = new PedidosController(dbService);

        var result = await controller.Cancelar("1", new CancelarPedidoRequest
        {
            Razon = "Otro",
            Comentarios = "Necesito cancelar"
        });

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.NotNull(ok.Value);
    }
}
