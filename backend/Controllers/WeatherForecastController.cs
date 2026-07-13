using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Resumenes =
    [
        "Helado", "Frio intenso", "Frio", "Fresco", "Templado", "Calido", "Agradable", "Caluroso", "Bochornoso", "Ardiente"
    ];

    [HttpGet(Name = "ObtenerPronosticoClima")]
    public IEnumerable<WeatherForecast> Get()
    {
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Resumenes[Random.Shared.Next(Resumenes.Length)]
        })
        .ToArray();
    }
}
