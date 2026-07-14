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

builder.Services.AddSingleton<SupabaseService>();
builder.Services.AddSingleton<DatabaseService>();

var app = builder.Build();

var supabaseService = app.Services.GetRequiredService<SupabaseService>();
if (supabaseService.IsConfigured)
{
    app.Logger.LogInformation("Supabase habilitado para el proyecto {ProjectUrl}", supabaseService.ProjectUrl ?? "No definido");
}
else
{
    app.Logger.LogWarning("Supabase no está configurado. Configure Supabase:Enabled y Supabase:ConnectionString para habilitarlo.");
}

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors();
app.UseAuthorization();
app.MapControllers();

app.Run();
