using System.Globalization;
using backend.Controllers;
using Google.Cloud.Firestore;

namespace backend;

public class AppDataRepository
{
    private readonly FirebaseService _firebaseService;
    private readonly ILogger<AppDataRepository> _logger;
    private readonly object _sync = new();

    private readonly List<UsuarioDto> _usuarios = [];
    private readonly List<DireccionDto> _direcciones = [];
    private readonly List<MetodoPagoDto> _metodosPago = [];
    private readonly List<PedidoDto> _pedidos = [];

    private readonly FirestoreDb? _db;

    public AppDataRepository(FirebaseService firebaseService, ILogger<AppDataRepository> logger)
    {
        _firebaseService = firebaseService;
        _logger = logger;
        _db = CreateFirestoreDb();
        SeedData();
    }

    public bool IsUsingFirestore => _db is not null;

    private FirestoreDb? CreateFirestoreDb()
    {
        if (!_firebaseService.IsConfigured)
        {
            return null;
        }

        try
        {
            if (!string.IsNullOrWhiteSpace(_firebaseService.CredentialsPath))
            {
                Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", _firebaseService.CredentialsPath);
            }

            var builder = new FirestoreDbBuilder
            {
                ProjectId = _firebaseService.ProjectId
            };

            return builder.Build();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "No fue posible inicializar Firestore. Se usará almacenamiento en memoria.");
            return null;
        }
    }

    public async Task<UsuarioDto?> GetUsuarioByCorreoAsync(string correo)
    {
        if (_db is not null)
        {
            var query = _db.Collection("usuarios")
                .WhereEqualTo("correo", correo.ToLowerInvariant())
                .Limit(1);
            var snapshot = await query.GetSnapshotAsync();
            var doc = snapshot.Documents.FirstOrDefault();
            return doc is null ? null : MapUsuario(doc);
        }

        lock (_sync)
        {
            return _usuarios.FirstOrDefault(u => string.Equals(u.Correo, correo, StringComparison.OrdinalIgnoreCase));
        }
    }

    public async Task<UsuarioDto?> GetUsuarioByIdAsync(string id)
    {
        if (_db is not null)
        {
            var doc = await _db.Collection("usuarios").Document(id).GetSnapshotAsync();
            return doc.Exists ? MapUsuario(doc) : null;
        }

        lock (_sync)
        {
            return _usuarios.FirstOrDefault(u => u.Id == id);
        }
    }

    public async Task<UsuarioDto?> GetUsuarioByPasswordAsync(string passwordActual)
    {
        if (_db is not null)
        {
            var query = _db.Collection("usuarios")
                .WhereEqualTo("password", passwordActual)
                .Limit(1);
            var snapshot = await query.GetSnapshotAsync();
            var doc = snapshot.Documents.FirstOrDefault();
            return doc is null ? null : MapUsuario(doc);
        }

        lock (_sync)
        {
            return _usuarios.FirstOrDefault(u => string.Equals(u.Password, passwordActual, StringComparison.Ordinal));
        }
    }

    public async Task<bool> ExisteCorreoAsync(string correo, string? excluirId = null)
    {
        if (_db is not null)
        {
            var query = _db.Collection("usuarios")
                .WhereEqualTo("correo", correo.ToLowerInvariant());
            var snapshot = await query.GetSnapshotAsync();
            return snapshot.Documents.Any(d => !string.Equals(d.Id, excluirId, StringComparison.Ordinal));
        }

        lock (_sync)
        {
            return _usuarios.Any(u =>
                !string.Equals(u.Id, excluirId, StringComparison.Ordinal) &&
                string.Equals(u.Correo, correo, StringComparison.OrdinalIgnoreCase));
        }
    }

    public async Task<UsuarioDto> CrearUsuarioAsync(UsuarioDto usuario)
    {
        var nuevo = new UsuarioDto
        {
            Id = Guid.NewGuid().ToString("N"),
            Nombre = usuario.Nombre,
            Correo = usuario.Correo?.Trim().ToLowerInvariant(),
            Telefono = usuario.Telefono,
            Password = usuario.Password,
            Rol = string.IsNullOrWhiteSpace(usuario.Rol) ? "cliente" : usuario.Rol
        };

        if (_db is not null)
        {
            await _db.Collection("usuarios").Document(nuevo.Id).SetAsync(ToUsuarioMap(nuevo));
            return nuevo;
        }

        lock (_sync)
        {
            _usuarios.Add(nuevo);
            return nuevo;
        }
    }

    public async Task<UsuarioDto?> GuardarUsuarioAsync(UsuarioDto usuario)
    {
        if (string.IsNullOrWhiteSpace(usuario.Id))
        {
            return null;
        }

        if (_db is not null)
        {
            await _db.Collection("usuarios").Document(usuario.Id).SetAsync(ToUsuarioMap(usuario));
            return usuario;
        }

        lock (_sync)
        {
            var index = _usuarios.FindIndex(u => u.Id == usuario.Id);
            if (index < 0)
            {
                return null;
            }

            _usuarios[index] = usuario;
            return usuario;
        }
    }

    public async Task<List<UsuarioDto>> ListarUsuariosAsync()
    {
        if (_db is not null)
        {
            var snapshot = await _db.Collection("usuarios").GetSnapshotAsync();
            return snapshot.Documents.Select(MapUsuario).ToList();
        }

        lock (_sync)
        {
            return _usuarios.Select(u => new UsuarioDto
            {
                Id = u.Id,
                Nombre = u.Nombre,
                Correo = u.Correo,
                Telefono = u.Telefono,
                Rol = u.Rol
            }).ToList();
        }
    }

    public async Task<List<DireccionDto>> ListarDireccionesAsync()
    {
        if (_db is not null)
        {
            var snapshot = await _db.Collection("direcciones").GetSnapshotAsync();
            return snapshot.Documents.Select(MapDireccion).ToList();
        }

        lock (_sync)
        {
            return _direcciones.Select(CloneDireccion).ToList();
        }
    }

    public async Task<DireccionDto?> ObtenerDireccionAsync(string id)
    {
        if (_db is not null)
        {
            var doc = await _db.Collection("direcciones").Document(id).GetSnapshotAsync();
            return doc.Exists ? MapDireccion(doc) : null;
        }

        lock (_sync)
        {
            var direccion = _direcciones.FirstOrDefault(d => d.Id == id);
            return direccion is null ? null : CloneDireccion(direccion);
        }
    }

    public async Task<DireccionDto> CrearDireccionAsync(DireccionDto direccion)
    {
        var nueva = CloneDireccion(direccion);
        nueva.Id = Guid.NewGuid().ToString("N");

        if (_db is not null)
        {
            await _db.Collection("direcciones").Document(nueva.Id).SetAsync(ToDireccionMap(nueva));
            return nueva;
        }

        lock (_sync)
        {
            _direcciones.Add(nueva);
            return CloneDireccion(nueva);
        }
    }

    public async Task<DireccionDto?> ActualizarDireccionAsync(string id, DireccionDto direccion)
    {
        var actualizada = CloneDireccion(direccion);
        actualizada.Id = id;

        if (_db is not null)
        {
            var docRef = _db.Collection("direcciones").Document(id);
            var doc = await docRef.GetSnapshotAsync();
            if (!doc.Exists)
            {
                return null;
            }

            await docRef.SetAsync(ToDireccionMap(actualizada));
            return actualizada;
        }

        lock (_sync)
        {
            var index = _direcciones.FindIndex(d => d.Id == id);
            if (index < 0)
            {
                return null;
            }

            _direcciones[index] = actualizada;
            return CloneDireccion(actualizada);
        }
    }

    public async Task<bool> EliminarDireccionAsync(string id)
    {
        if (_db is not null)
        {
            var docRef = _db.Collection("direcciones").Document(id);
            var doc = await docRef.GetSnapshotAsync();
            if (!doc.Exists)
            {
                return false;
            }

            await docRef.DeleteAsync();
            return true;
        }

        lock (_sync)
        {
            var index = _direcciones.FindIndex(d => d.Id == id);
            if (index < 0)
            {
                return false;
            }

            _direcciones.RemoveAt(index);
            return true;
        }
    }

    public async Task<List<MetodoPagoDto>> ListarMetodosPagoAsync()
    {
        if (_db is not null)
        {
            var snapshot = await _db.Collection("metodosPago").GetSnapshotAsync();
            return snapshot.Documents.Select(MapMetodoPago).ToList();
        }

        lock (_sync)
        {
            return _metodosPago.Select(CloneMetodoPago).ToList();
        }
    }

    public async Task<MetodoPagoDto?> ObtenerMetodoPagoAsync(string id)
    {
        if (_db is not null)
        {
            var doc = await _db.Collection("metodosPago").Document(id).GetSnapshotAsync();
            return doc.Exists ? MapMetodoPago(doc) : null;
        }

        lock (_sync)
        {
            var metodo = _metodosPago.FirstOrDefault(m => m.Id == id);
            return metodo is null ? null : CloneMetodoPago(metodo);
        }
    }

    public async Task<MetodoPagoDto> CrearMetodoPagoAsync(MetodoPagoDto metodo)
    {
        var nuevo = CloneMetodoPago(metodo);
        nuevo.Id = Guid.NewGuid().ToString("N");

        if (_db is not null)
        {
            await _db.Collection("metodosPago").Document(nuevo.Id).SetAsync(ToMetodoPagoMap(nuevo));
            return nuevo;
        }

        lock (_sync)
        {
            _metodosPago.Add(nuevo);
            return CloneMetodoPago(nuevo);
        }
    }

    public async Task<List<PedidoDto>> ListarPedidosAsync(string? clienteId)
    {
        if (_db is not null)
        {
            CollectionReference collection = _db.Collection("pedidos");
            Query query = collection;
            if (!string.IsNullOrWhiteSpace(clienteId))
            {
                query = query.WhereEqualTo("clienteId", clienteId);
            }

            var snapshot = await query.GetSnapshotAsync();
            return snapshot.Documents.Select(MapPedido).ToList();
        }

        lock (_sync)
        {
            var result = string.IsNullOrWhiteSpace(clienteId)
                ? _pedidos
                : _pedidos.Where(p => p.ClienteId == clienteId).ToList();
            return result.Select(ClonePedido).ToList();
        }
    }

    public async Task<PedidoDto?> ObtenerPedidoAsync(string id)
    {
        if (_db is not null)
        {
            var doc = await _db.Collection("pedidos").Document(id).GetSnapshotAsync();
            return doc.Exists ? MapPedido(doc) : null;
        }

        lock (_sync)
        {
            var pedido = _pedidos.FirstOrDefault(p => p.Id == id);
            return pedido is null ? null : ClonePedido(pedido);
        }
    }

    public async Task<PedidoDto> CrearPedidoAsync(PedidoDto pedido)
    {
        var nuevo = ClonePedido(pedido);
        nuevo.Id = Guid.NewGuid().ToString("N");

        if (_db is not null)
        {
            await _db.Collection("pedidos").Document(nuevo.Id).SetAsync(ToPedidoMap(nuevo));
            return nuevo;
        }

        lock (_sync)
        {
            _pedidos.Add(nuevo);
            return ClonePedido(nuevo);
        }
    }

    public async Task<PedidoDto?> GuardarPedidoAsync(PedidoDto pedido)
    {
        if (string.IsNullOrWhiteSpace(pedido.Id))
        {
            return null;
        }

        if (_db is not null)
        {
            var docRef = _db.Collection("pedidos").Document(pedido.Id);
            var doc = await docRef.GetSnapshotAsync();
            if (!doc.Exists)
            {
                return null;
            }

            await docRef.SetAsync(ToPedidoMap(pedido));
            return pedido;
        }

        lock (_sync)
        {
            var index = _pedidos.FindIndex(p => p.Id == pedido.Id);
            if (index < 0)
            {
                return null;
            }

            _pedidos[index] = ClonePedido(pedido);
            return ClonePedido(pedido);
        }
    }

    private void SeedData()
    {
        lock (_sync)
        {
            var adminId = "admin-id-12345";
            var clienteId = "cliente-id-12345";

            _usuarios.Add(new UsuarioDto
            {
                Id = adminId,
                Nombre = "Administrador FreshClean",
                Correo = "admin@freshclean.com",
                Telefono = "9998887777",
                Password = "Admin123!",
                Rol = "administrador"
            });

            _usuarios.Add(new UsuarioDto
            {
                Id = clienteId,
                Nombre = "Abraham San Juan",
                Correo = "cliente@freshclean.com",
                Telefono = "1234567890",
                Password = "Cliente123!",
                Rol = "cliente"
            });

            _direcciones.Add(new DireccionDto
            {
                Id = "dir-1",
                Titulo = "Casa",
                Lineas = new List<string> { "Av. Linda Vista #402", "Col. Linda Vista", "San Juan" },
                Telefono = "1234567890",
                Nota = "Portón verde, timbre al lado de la reja",
                Predeterminada = true
            });

            _direcciones.Add(new DireccionDto
            {
                Id = "dir-2",
                Titulo = "Trabajo",
                Lineas = new List<string> { "Paseo de la Reforma #115", "Oficinas Center, Piso 4", "San Juan" },
                Telefono = "0987654321",
                Nota = "Dejar en recepción",
                Predeterminada = false
            });

            _metodosPago.Add(new MetodoPagoDto
            {
                Id = "met-1",
                Marca = "visa",
                UltimosDigitos = "4242",
                Expira = "12/28",
                Principal = true
            });

            _metodosPago.Add(new MetodoPagoDto
            {
                Id = "met-2",
                Marca = "mastercard",
                UltimosDigitos = "5555",
                Expira = "08/29",
                Principal = false
            });

            // Seed some orders
            _pedidos.Add(new PedidoDto
            {
                Id = "ped-1",
                ClienteId = clienteId,
                ClienteNombre = "Abraham San Juan",
                Servicio = "Lavado por Kilo (Estándar)",
                Fecha = DateTime.Now.AddDays(-2).ToString("yyyy-MM-dd"),
                FranjaHoraria = "10:00 AM - 12:00 PM",
                Direccion = "Av. Linda Vista #402, Col. Linda Vista",
                Instrucciones = "Cuidado con las prendas delicadas",
                Total = 150.00m,
                Estado = "Entregado",
                HistorialEstados = new List<EstadoHistorial>
                {
                    new() { Estado = "En proceso", Fecha = DateTime.UtcNow.AddDays(-2).ToString("O"), Observaciones = "Pedido creado" },
                    new() { Estado = "Recolectado", Fecha = DateTime.UtcNow.AddDays(-1.9).ToString("O"), Observaciones = "Prendas recolectadas" },
                    new() { Estado = "En lavado", Fecha = DateTime.UtcNow.AddDays(-1.5).ToString("O"), Observaciones = "En lavadora" },
                    new() { Estado = "Listo para entrega", Fecha = DateTime.UtcNow.AddDays(-1.1).ToString("O"), Observaciones = "Empacado" },
                    new() { Estado = "Entregado", Fecha = DateTime.UtcNow.AddDays(-1.0).ToString("O"), Observaciones = "Entregado en domicilio" }
                }
            });

            _pedidos.Add(new PedidoDto
            {
                Id = "ped-2",
                ClienteId = clienteId,
                ClienteNombre = "Abraham San Juan",
                Servicio = "Tintorería (Traje 2 piezas)",
                Fecha = DateTime.Now.ToString("yyyy-MM-dd"),
                FranjaHoraria = "04:00 PM - 06:00 PM",
                Direccion = "Av. Linda Vista #402, Col. Linda Vista",
                Instrucciones = "Planchar con raya marcada",
                Total = 280.00m,
                Estado = "En proceso",
                HistorialEstados = new List<EstadoHistorial>
                {
                    new() { Estado = "En proceso", Fecha = DateTime.UtcNow.ToString("O"), Observaciones = "Pedido recibido" }
                }
            });
        }
    }

    private static Dictionary<string, object?> ToUsuarioMap(UsuarioDto usuario) => new()
    {
        ["id"] = usuario.Id,
        ["nombre"] = usuario.Nombre,
        ["correo"] = usuario.Correo?.ToLowerInvariant(),
        ["telefono"] = usuario.Telefono,
        ["password"] = usuario.Password,
        ["rol"] = usuario.Rol
    };

    private static UsuarioDto MapUsuario(DocumentSnapshot doc)
    {
        var data = doc.ToDictionary();
        return new UsuarioDto
        {
            Id = doc.Id,
            Nombre = GetString(data, "nombre"),
            Correo = GetString(data, "correo"),
            Telefono = GetString(data, "telefono"),
            Password = GetString(data, "password"),
            Rol = GetString(data, "rol")
        };
    }

    private static Dictionary<string, object?> ToDireccionMap(DireccionDto direccion) => new()
    {
        ["id"] = direccion.Id,
        ["titulo"] = direccion.Titulo,
        ["lineas"] = direccion.Lineas ?? [],
        ["telefono"] = direccion.Telefono,
        ["nota"] = direccion.Nota,
        ["predeterminada"] = direccion.Predeterminada
    };

    private static DireccionDto MapDireccion(DocumentSnapshot doc)
    {
        var data = doc.ToDictionary();
        return new DireccionDto
        {
            Id = doc.Id,
            Titulo = GetString(data, "titulo"),
            Lineas = GetStringList(data, "lineas"),
            Telefono = GetString(data, "telefono"),
            Nota = GetString(data, "nota"),
            Predeterminada = GetBool(data, "predeterminada")
        };
    }

    private static DireccionDto CloneDireccion(DireccionDto direccion) => new()
    {
        Id = direccion.Id,
        Titulo = direccion.Titulo,
        Lineas = direccion.Lineas is null ? [] : [..direccion.Lineas],
        Telefono = direccion.Telefono,
        Nota = direccion.Nota,
        Predeterminada = direccion.Predeterminada
    };

    private static Dictionary<string, object?> ToMetodoPagoMap(MetodoPagoDto metodo) => new()
    {
        ["id"] = metodo.Id,
        ["marca"] = metodo.Marca,
        ["ultimosDigitos"] = metodo.UltimosDigitos,
        ["expira"] = metodo.Expira,
        ["principal"] = metodo.Principal
    };

    private static MetodoPagoDto MapMetodoPago(DocumentSnapshot doc)
    {
        var data = doc.ToDictionary();
        return new MetodoPagoDto
        {
            Id = doc.Id,
            Marca = GetString(data, "marca"),
            UltimosDigitos = GetString(data, "ultimosDigitos"),
            Expira = GetString(data, "expira"),
            Principal = GetBool(data, "principal")
        };
    }

    private static MetodoPagoDto CloneMetodoPago(MetodoPagoDto metodo) => new()
    {
        Id = metodo.Id,
        Marca = metodo.Marca,
        UltimosDigitos = metodo.UltimosDigitos,
        Expira = metodo.Expira,
        Principal = metodo.Principal
    };

    private static Dictionary<string, object?> ToPedidoMap(PedidoDto pedido) => new()
    {
        ["id"] = pedido.Id,
        ["clienteId"] = pedido.ClienteId,
        ["clienteNombre"] = pedido.ClienteNombre,
        ["servicio"] = pedido.Servicio,
        ["fecha"] = pedido.Fecha,
        ["franjaHoraria"] = pedido.FranjaHoraria,
        ["direccion"] = pedido.Direccion,
        ["instrucciones"] = pedido.Instrucciones,
        ["total"] = pedido.Total,
        ["estado"] = pedido.Estado,
        ["historialEstados"] = (pedido.HistorialEstados ?? [])
            .Select(h => new Dictionary<string, object?>
            {
                ["estado"] = h.Estado,
                ["fecha"] = h.Fecha,
                ["observaciones"] = h.Observaciones
            })
            .ToList()
    };

    private static PedidoDto MapPedido(DocumentSnapshot doc)
    {
        var data = doc.ToDictionary();
        return new PedidoDto
        {
            Id = doc.Id,
            ClienteId = GetString(data, "clienteId"),
            ClienteNombre = GetString(data, "clienteNombre"),
            Servicio = GetString(data, "servicio"),
            Fecha = GetString(data, "fecha"),
            FranjaHoraria = GetString(data, "franjaHoraria"),
            Direccion = GetString(data, "direccion"),
            Instrucciones = GetString(data, "instrucciones"),
            Total = GetDecimal(data, "total"),
            Estado = GetString(data, "estado"),
            HistorialEstados = GetHistorial(data, "historialEstados")
        };
    }

    private static PedidoDto ClonePedido(PedidoDto pedido) => new()
    {
        Id = pedido.Id,
        ClienteId = pedido.ClienteId,
        ClienteNombre = pedido.ClienteNombre,
        Servicio = pedido.Servicio,
        Fecha = pedido.Fecha,
        FranjaHoraria = pedido.FranjaHoraria,
        Direccion = pedido.Direccion,
        Instrucciones = pedido.Instrucciones,
        Total = pedido.Total,
        Estado = pedido.Estado,
        HistorialEstados = (pedido.HistorialEstados ?? []).Select(h => new EstadoHistorial
        {
            Estado = h.Estado,
            Fecha = h.Fecha,
            Observaciones = h.Observaciones
        }).ToList()
    };

    private static string? GetString(IReadOnlyDictionary<string, object> data, string key)
    {
        return data.TryGetValue(key, out var value) ? value?.ToString() : null;
    }

    private static bool GetBool(IReadOnlyDictionary<string, object> data, string key)
    {
        if (!data.TryGetValue(key, out var value) || value is null)
        {
            return false;
        }

        return value switch
        {
            bool b => b,
            string s when bool.TryParse(s, out var parsed) => parsed,
            _ => false
        };
    }

    private static decimal GetDecimal(IReadOnlyDictionary<string, object> data, string key)
    {
        if (!data.TryGetValue(key, out var value) || value is null)
        {
            return 0m;
        }

        return value switch
        {
            decimal d => d,
            double db => Convert.ToDecimal(db),
            float f => Convert.ToDecimal(f),
            int i => i,
            long l => l,
            string s when decimal.TryParse(s, NumberStyles.Any, CultureInfo.InvariantCulture, out var parsed) => parsed,
            _ => 0m
        };
    }

    private static List<string> GetStringList(IReadOnlyDictionary<string, object> data, string key)
    {
        if (!data.TryGetValue(key, out var value) || value is null)
        {
            return [];
        }

        return value switch
        {
            IEnumerable<object> list => list.Select(x => x?.ToString() ?? string.Empty).ToList(),
            _ => []
        };
    }

    private static List<EstadoHistorial> GetHistorial(IReadOnlyDictionary<string, object> data, string key)
    {
        if (!data.TryGetValue(key, out var value) || value is null)
        {
            return [];
        }

        if (value is not IEnumerable<object> items)
        {
            return [];
        }

        var result = new List<EstadoHistorial>();
        foreach (var item in items)
        {
            if (item is IReadOnlyDictionary<string, object> map)
            {
                result.Add(new EstadoHistorial
                {
                    Estado = GetString(map, "estado"),
                    Fecha = GetString(map, "fecha"),
                    Observaciones = GetString(map, "observaciones")
                });
            }
        }

        return result;
    }
}