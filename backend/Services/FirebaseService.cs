using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;

namespace backend;

public class FirebaseService
{
    private readonly IConfiguration _configuration;

    public FirebaseService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public bool IsConfigured => Enabled && !string.IsNullOrWhiteSpace(ProjectId);

    public bool Enabled => bool.TryParse(_configuration["Firebase:Enabled"], out var enabled) ? enabled : false;

    public string? ProjectId => _configuration["Firebase:ProjectId"];

    public string? CredentialsPath => _configuration["Firebase:CredentialsPath"];

    public GoogleCredential? CreateCredential()
    {
        if (!IsConfigured)
        {
            return null;
        }

        if (string.IsNullOrWhiteSpace(CredentialsPath))
        {
            return GoogleCredential.GetApplicationDefault();
        }

        return GoogleCredential.FromFile(CredentialsPath);
    }
}
