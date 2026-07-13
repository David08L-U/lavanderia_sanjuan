using backend;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace backend.tests;

public class FirebaseServiceTests
{
    [Fact]
    public void Inicializacion_ConFirebaseDeshabilitado_NoDebeConfigurar()
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Firebase:Enabled"] = "false",
                ["Firebase:ProjectId"] = "demo-project",
                ["Firebase:CredentialsPath"] = "credentials.json"
            })
            .Build();

        var service = new FirebaseService(config);

        Assert.False(service.IsConfigured);
        Assert.Equal("demo-project", service.ProjectId);
    }
}
