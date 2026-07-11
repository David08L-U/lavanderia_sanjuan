using backend;
using backend.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddOpenApi();
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddSingleton<FirebaseService>();
builder.Services.AddSingleton<DatabaseService>();

var app = builder.Build();

var firebaseService = app.Services.GetRequiredService<FirebaseService>();
if (firebaseService.IsConfigured)
{
    var credential = firebaseService.CreateCredential();
    if (credential is not null)
    {
        app.Logger.LogInformation("Firebase configurado para el proyecto {ProjectId}", firebaseService.ProjectId);
    }
}
else
{
    app.Logger.LogWarning("Firebase no está configurado. Configure Firebase:Enabled, Firebase:ProjectId y Firebase:CredentialsPath para habilitarlo.");
}

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors();
app.UseAuthorization();
app.MapControllers();

app.Run();
