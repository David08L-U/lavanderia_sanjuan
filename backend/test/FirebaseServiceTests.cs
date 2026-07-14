using backend.Services;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace backend.tests;

public class SupabaseServiceTests
{
    [Fact]
    public void Inicializacion_ConSupabaseDeshabilitado_NoDebeConfigurar()
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Supabase:Enabled"] = "false",
                ["Supabase:ProjectUrl"] = "https://demo.supabase.co",
                ["Supabase:ConnectionString"] = "Host=localhost;Username=postgres;Password=postgres;Database=postgres"
            })
            .Build();

        var service = new SupabaseService(config);

        Assert.False(service.IsConfigured);
        Assert.NotNull(service.ProjectUrl);
    }
}
