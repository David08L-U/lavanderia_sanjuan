using backend.Controllers;
using Microsoft.AspNetCore.Mvc;
using Xunit;

namespace backend.tests;

public class PedidosControllerTests
{
    [Fact]
    public void CancelarPedido_DeberiaRetornarOk()
    {
        var controller = new PedidosController();

        var result = controller.Cancelar("1", new CancelarPedidoRequest
        {
            Razon = "Otro",
            Comentarios = "Necesito cancelar"
        });

        var ok = Assert.IsType<OkObjectResult>(result);
        Assert.NotNull(ok.Value);
    }
}
