using backend;

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
builder.Services.AddSingleton<AppDataRepository>();

var app = builder.Build();

var firebaseService = app.Services.GetRequiredService<FirebaseService>();
var dataRepository = app.Services.GetRequiredService<AppDataRepository>();
if (firebaseService.IsConfigured)
{
    try
    {
        var credential = firebaseService.CreateCredential();
        if (credential is not null)
        {
            app.Logger.LogInformation("Firebase configurado para el proyecto {ProjectId}", firebaseService.ProjectId);
            app.Logger.LogInformation(
                dataRepository.IsUsingFirestore
                    ? "Persistencia activa en Firebase Firestore"
                    : "Firebase está configurado pero Firestore no pudo inicializarse. Se usará almacenamiento temporal en memoria.");
        }
    }
    catch (Exception ex)
    {
        app.Logger.LogError(ex, "No fue posible cargar credenciales de Firebase. Se usará almacenamiento temporal en memoria.");
    }
}
else
{
    app.Logger.LogWarning("Firebase no está configurado. Configure Firebase:Enabled y Firebase:ProjectId para habilitarlo (CredentialsPath es opcional).");
}

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors();
app.UseAuthorization();
app.MapControllers();

app.Run();
