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

builder.Services.AddHttpClient();
builder.Services.AddSingleton<SupabaseService>();

var app = builder.Build();

var supabaseService = app.Services.GetRequiredService<SupabaseService>();
if (supabaseService.IsConfigured)
{
    app.Logger.LogInformation("Supabase configurado para URL {SupabaseUrl}", supabaseService.Url);
}
else
{
    app.Logger.LogWarning("Supabase no está configurado. Configure Supabase:Enabled, Supabase:Url, Supabase:AnonKey y Supabase:ServiceRoleKey para habilitarlo.");
}

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors();
app.UseAuthorization();
app.MapControllers();

app.Run();
