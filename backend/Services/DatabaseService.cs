using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using backend.Controllers;
using Npgsql;

namespace backend.Services;

public class DatabaseService
{
    private readonly string? _connectionString;
    private readonly string _localDataDir;

    public DatabaseService(SupabaseService supabaseService)
    {
        _localDataDir = Path.Combine(AppContext.BaseDirectory, "data");
        if (!Directory.Exists(_localDataDir))
        {
            Directory.CreateDirectory(_localDataDir);
        }

        if (supabaseService.IsConfigured)
        {
            try
            {
                _connectionString = supabaseService.ConnectionString;
                EnsureSchemaAsync().GetAwaiter().GetResult();
                Console.WriteLine("Supabase/Postgres inicializado con éxito.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al inicializar Supabase/Postgres: {ex.Message}");
            }
        }
    }

    public bool IsCloud => !string.IsNullOrWhiteSpace(_connectionString);

    private NpgsqlConnection CreateConnection() => new(_connectionString!);

    private async Task EnsureSchemaAsync()
    {
        if (!IsCloud)
        {
            return;
        }

        const string sql = @"
CREATE TABLE IF NOT EXISTS usuarios (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    correo TEXT NOT NULL UNIQUE,
    telefono TEXT,
    password TEXT NOT NULL,
    rol TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS pedidos (
    id TEXT PRIMARY KEY,
    cliente_id TEXT,
    cliente_nombre TEXT NOT NULL,
    servicio TEXT NOT NULL,
    fecha DATE,
    franja_horaria TEXT,
    direccion TEXT,
    instrucciones TEXT NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    estado TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS direcciones (
    id TEXT PRIMARY KEY,
    usuario_id TEXT,
    titulo TEXT NOT NULL,
    lineas TEXT[] NOT NULL,
    telefono TEXT,
    nota TEXT,
    predeterminada BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS metodos_pago (
    id TEXT PRIMARY KEY,
    usuario_id TEXT,
    marca TEXT NOT NULL,
    ultimos_digitos TEXT NOT NULL,
    expira TEXT NOT NULL,
    principal BOOLEAN NOT NULL
);";

        await using var connection = CreateConnection();
        await connection.OpenAsync();
        await using var command = new NpgsqlCommand(sql, connection);
        await command.ExecuteNonQueryAsync();
    }

    // Pedidos
    public async Task<List<PedidoDto>> ListarPedidosAsync()
    {
        if (IsCloud)
        {
            var list = new List<PedidoDto>();
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = "SELECT id, cliente_id, cliente_nombre, servicio, to_char(fecha, 'YYYY-MM-DD') AS fecha, franja_horaria, direccion, instrucciones, total, estado FROM pedidos";
            await using var command = new NpgsqlCommand(sql, connection);
            await using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                list.Add(new PedidoDto
                {
                    Id = reader["id"] as string,
                    ClienteId = reader["cliente_id"] as string,
                    ClienteNombre = reader["cliente_nombre"] as string,
                    Servicio = reader["servicio"] as string,
                    Fecha = reader["fecha"] as string,
                    FranjaHoraria = reader["franja_horaria"] as string,
                    Direccion = reader["direccion"] as string,
                    Instrucciones = reader["instrucciones"] as string,
                    Total = reader["total"] is DBNull ? 0d : Convert.ToDouble(reader["total"]),
                    Estado = reader["estado"] as string
                });
            }

            return list;
        }
        else
        {
            return await LeerLocalAsync<PedidoDto>("pedidos.json") ?? new List<PedidoDto>
            {
                new()
                {
                    Id = "1",
                    ClienteId = "2",
                    ClienteNombre = "Cliente Demo",
                    Servicio = "Lavado y Doblado",
                    Fecha = "2026-07-08",
                    FranjaHoraria = "Tarde",
                    Direccion = "Calle 45 # 10-20",
                    Instrucciones = "Lavar con agua fría",
                    Total = 25.0,
                    Estado = "En proceso"
                }
            };
        }
    }

    public async Task GuardarPedidoAsync(PedidoDto pedido)
    {
        if (IsCloud)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = @"
INSERT INTO pedidos (id, cliente_id, cliente_nombre, servicio, fecha, franja_horaria, direccion, instrucciones, total, estado)
VALUES (@id, @cliente_id, @cliente_nombre, @servicio, @fecha, @franja_horaria, @direccion, @instrucciones, @total, @estado)
ON CONFLICT (id)
DO UPDATE SET
    cliente_id = EXCLUDED.cliente_id,
    cliente_nombre = EXCLUDED.cliente_nombre,
    servicio = EXCLUDED.servicio,
    fecha = EXCLUDED.fecha,
    franja_horaria = EXCLUDED.franja_horaria,
    direccion = EXCLUDED.direccion,
    instrucciones = EXCLUDED.instrucciones,
    total = EXCLUDED.total,
    estado = EXCLUDED.estado;";

            await using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddWithValue("id", pedido.Id ?? Guid.NewGuid().ToString());
            command.Parameters.AddWithValue("cliente_id", (object?)pedido.ClienteId ?? DBNull.Value);
            command.Parameters.AddWithValue("cliente_nombre", pedido.ClienteNombre ?? "Cliente");
            command.Parameters.AddWithValue("servicio", pedido.Servicio ?? "Servicio");
            var fecha = DateTime.TryParse(pedido.Fecha, out var parsedDate) ? parsedDate.Date : DateTime.UtcNow.Date;
            command.Parameters.AddWithValue("fecha", fecha);
            command.Parameters.AddWithValue("franja_horaria", (object?)pedido.FranjaHoraria ?? DBNull.Value);
            command.Parameters.AddWithValue("direccion", (object?)pedido.Direccion ?? DBNull.Value);
            command.Parameters.AddWithValue("instrucciones", pedido.Instrucciones ?? string.Empty);
            command.Parameters.AddWithValue("total", Convert.ToDecimal(pedido.Total));
            command.Parameters.AddWithValue("estado", pedido.Estado ?? "En proceso");
            await command.ExecuteNonQueryAsync();
        }
        else
        {
            var list = await ListarPedidosAsync();
            var index = list.FindIndex(p => p.Id == pedido.Id);
            if (index >= 0) list[index] = pedido;
            else list.Add(pedido);
            await EscribirLocalAsync("pedidos.json", list);
        }
    }

    // Usuarios
    public async Task<List<UsuarioDto>> ListarUsuariosAsync()
    {
        if (IsCloud)
        {
            var list = new List<UsuarioDto>();
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = "SELECT id, nombre, correo, telefono, password, rol FROM usuarios";
            await using var command = new NpgsqlCommand(sql, connection);
            await using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                list.Add(new UsuarioDto
                {
                    Id = reader["id"] as string,
                    Nombre = reader["nombre"] as string,
                    Correo = reader["correo"] as string,
                    Telefono = reader["telefono"] as string,
                    Password = reader["password"] as string,
                    Rol = reader["rol"] as string
                });
            }

            return list;
        }
        else
        {
            return await LeerLocalAsync<UsuarioDto>("usuarios.json") ?? new List<UsuarioDto>
            {
                new() { Id = "1", Nombre = "Admin San Juan", Correo = "admin@sanjuan.com", Telefono = "3001234567", Password = "admin123", Rol = "administrador" },
                new() { Id = "2", Nombre = "Cliente Demo", Correo = "cliente@sanjuan.com", Telefono = "3007654321", Password = "cliente123", Rol = "cliente" }
            };
        }
    }

    public async Task GuardarUsuarioAsync(UsuarioDto usuario)
    {
        if (IsCloud)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = @"
INSERT INTO usuarios (id, nombre, correo, telefono, password, rol)
VALUES (@id, @nombre, @correo, @telefono, @password, @rol)
ON CONFLICT (id)
DO UPDATE SET
    nombre = EXCLUDED.nombre,
    correo = EXCLUDED.correo,
    telefono = EXCLUDED.telefono,
    password = EXCLUDED.password,
    rol = EXCLUDED.rol;";

            await using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddWithValue("id", usuario.Id ?? Guid.NewGuid().ToString());
            command.Parameters.AddWithValue("nombre", usuario.Nombre ?? string.Empty);
            command.Parameters.AddWithValue("correo", usuario.Correo ?? string.Empty);
            command.Parameters.AddWithValue("telefono", (object?)usuario.Telefono ?? DBNull.Value);
            command.Parameters.AddWithValue("password", usuario.Password ?? string.Empty);
            command.Parameters.AddWithValue("rol", usuario.Rol ?? "cliente");
            await command.ExecuteNonQueryAsync();
        }
        else
        {
            var list = await ListarUsuariosAsync();
            var index = list.FindIndex(u => u.Id == usuario.Id);
            if (index >= 0) list[index] = usuario;
            else list.Add(usuario);
            await EscribirLocalAsync("usuarios.json", list);
        }
    }

    // Direcciones
    public async Task<List<DireccionDto>> ListarDireccionesAsync()
    {
        if (IsCloud)
        {
            var list = new List<DireccionDto>();
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = "SELECT id, titulo, lineas, telefono, nota, predeterminada FROM direcciones";
            await using var command = new NpgsqlCommand(sql, connection);
            await using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                var lineasArray = reader["lineas"] as string[];
                list.Add(new DireccionDto
                {
                    Id = reader["id"] as string,
                    Titulo = reader["titulo"] as string,
                    Lineas = lineasArray?.ToList() ?? new List<string>(),
                    Telefono = reader["telefono"] as string,
                    Nota = reader["nota"] as string,
                    Predeterminada = reader["predeterminada"] is bool value && value
                });
            }

            return list;
        }
        else
        {
            return await LeerLocalAsync<DireccionDto>("direcciones.json") ?? new List<DireccionDto>
            {
                new()
                {
                    Id = "1",
                    Titulo = "Casa Principal",
                    Lineas = new List<string> { "Av. Siempre Viva 742", "Springfield, CP 12345" },
                    Telefono = "+34 555 123 456",
                    Nota = "Entregar en la puerta principal",
                    Predeterminada = true
                },
                new()
                {
                    Id = "2",
                    Titulo = "Oficina",
                    Lineas = new List<string> { "Torre Empresarial, Piso 5", "Centro, CP 54321" },
                    Telefono = "+34 555 987 654",
                    Nota = "Entregar en recepción",
                    Predeterminada = false
                }
            };
        }
    }

    public async Task GuardarDireccionAsync(DireccionDto direccion)
    {
        if (IsCloud)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = @"
INSERT INTO direcciones (id, titulo, lineas, telefono, nota, predeterminada)
VALUES (@id, @titulo, @lineas, @telefono, @nota, @predeterminada)
ON CONFLICT (id)
DO UPDATE SET
    titulo = EXCLUDED.titulo,
    lineas = EXCLUDED.lineas,
    telefono = EXCLUDED.telefono,
    nota = EXCLUDED.nota,
    predeterminada = EXCLUDED.predeterminada;";

            await using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddWithValue("id", direccion.Id ?? Guid.NewGuid().ToString());
            command.Parameters.AddWithValue("titulo", direccion.Titulo ?? "Nueva direccion");
            command.Parameters.AddWithValue("lineas", (direccion.Lineas ?? new List<string>()).ToArray());
            command.Parameters.AddWithValue("telefono", (object?)direccion.Telefono ?? DBNull.Value);
            command.Parameters.AddWithValue("nota", (object?)direccion.Nota ?? DBNull.Value);
            command.Parameters.AddWithValue("predeterminada", direccion.Predeterminada);
            await command.ExecuteNonQueryAsync();
        }
        else
        {
            var list = await ListarDireccionesAsync();
            var index = list.FindIndex(d => d.Id == direccion.Id);
            if (index >= 0) list[index] = direccion;
            else list.Add(direccion);
            await EscribirLocalAsync("direcciones.json", list);
        }
    }

    public async Task EliminarDireccionAsync(string id)
    {
        if (IsCloud)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = "DELETE FROM direcciones WHERE id = @id";
            await using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddWithValue("id", id);
            await command.ExecuteNonQueryAsync();
        }
        else
        {
            var list = await ListarDireccionesAsync();
            list.RemoveAll(d => d.Id == id);
            await EscribirLocalAsync("direcciones.json", list);
        }
    }

    // MetodosPago
    public async Task<List<MetodoPagoDto>> ListarMetodosPagoAsync()
    {
        if (IsCloud)
        {
            var list = new List<MetodoPagoDto>();
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = "SELECT id, marca, ultimos_digitos, expira, principal FROM metodos_pago";
            await using var command = new NpgsqlCommand(sql, connection);
            await using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                list.Add(new MetodoPagoDto
                {
                    Id = reader["id"] as string,
                    Marca = reader["marca"] as string,
                    UltimosDigitos = reader["ultimos_digitos"] as string,
                    Expira = reader["expira"] as string,
                    Principal = reader["principal"] is bool value && value
                });
            }

            return list;
        }
        else
        {
            return await LeerLocalAsync<MetodoPagoDto>("metodosPago.json") ?? new List<MetodoPagoDto>
            {
                new() { Id = "1", Marca = "visa", UltimosDigitos = "4242", Expira = "12/26", Principal = true },
                new() { Id = "2", Marca = "mastercard", UltimosDigitos = "8819", Expira = "08/24", Principal = false }
            };
        }
    }

    public async Task GuardarMetodoPagoAsync(MetodoPagoDto metodo)
    {
        if (IsCloud)
        {
            await using var connection = CreateConnection();
            await connection.OpenAsync();
            const string sql = @"
INSERT INTO metodos_pago (id, marca, ultimos_digitos, expira, principal)
VALUES (@id, @marca, @ultimos_digitos, @expira, @principal)
ON CONFLICT (id)
DO UPDATE SET
    marca = EXCLUDED.marca,
    ultimos_digitos = EXCLUDED.ultimos_digitos,
    expira = EXCLUDED.expira,
    principal = EXCLUDED.principal;";

            await using var command = new NpgsqlCommand(sql, connection);
            command.Parameters.AddWithValue("id", metodo.Id ?? Guid.NewGuid().ToString());
            command.Parameters.AddWithValue("marca", metodo.Marca ?? "visa");
            command.Parameters.AddWithValue("ultimos_digitos", metodo.UltimosDigitos ?? string.Empty);
            command.Parameters.AddWithValue("expira", metodo.Expira ?? string.Empty);
            command.Parameters.AddWithValue("principal", metodo.Principal);
            await command.ExecuteNonQueryAsync();
        }
        else
        {
            var list = await ListarMetodosPagoAsync();
            var index = list.FindIndex(m => m.Id == metodo.Id);
            if (index >= 0) list[index] = metodo;
            else list.Add(metodo);
            await EscribirLocalAsync("metodosPago.json", list);
        }
    }

    // Helpers locales
    private async Task<List<T>?> LeerLocalAsync<T>(string filename)
    {
        var filePath = Path.Combine(_localDataDir, filename);
        if (!File.Exists(filePath)) return null;
        try
        {
            var json = await File.ReadAllTextAsync(filePath);
            return JsonSerializer.Deserialize<List<T>>(json);
        }
        catch
        {
            return null;
        }
    }

    private async Task EscribirLocalAsync<T>(string filename, List<T> list)
    {
        var filePath = Path.Combine(_localDataDir, filename);
        try
        {
            var json = JsonSerializer.Serialize(list, new JsonSerializerOptions { WriteIndented = true });
            await File.WriteAllTextAsync(filePath, json);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error al escribir localmente {filename}: {ex.Message}");
        }
    }
}
