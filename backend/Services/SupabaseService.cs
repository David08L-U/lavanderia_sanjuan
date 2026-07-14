using Microsoft.Extensions.Configuration;

namespace backend.Services;

public class SupabaseService
{
    private readonly IConfiguration _configuration;

    public SupabaseService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public bool Enabled => bool.TryParse(_configuration["Supabase:Enabled"], out var enabled) && enabled;

    public string? ConnectionString => _configuration["Supabase:ConnectionString"];

    public string? ProjectUrl => _configuration["Supabase:ProjectUrl"];

    public bool IsConfigured => Enabled && !string.IsNullOrWhiteSpace(ConnectionString);
}
