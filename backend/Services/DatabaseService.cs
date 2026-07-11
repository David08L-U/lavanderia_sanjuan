using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using Google.Cloud.Firestore;
using backend.Controllers;

namespace backend.Services;

public class DatabaseService
{
    private readonly FirestoreDb? _firestoreDb;
    private readonly string _localDataDir;

    public DatabaseService(FirebaseService firebaseService)
    {
        _localDataDir = Path.Combine(AppContext.BaseDirectory, "data");
        if (!Directory.Exists(_localDataDir))
        {
            Directory.CreateDirectory(_localDataDir);
        }

        if (firebaseService.IsConfigured)
        {
            try
            {
                var dbBuilder = new FirestoreDbBuilder
                {
                    ProjectId = firebaseService.ProjectId,
                    Credential = firebaseService.CreateCredential()
                };
                _firestoreDb = dbBuilder.Build();
                Console.WriteLine($"Firestore inicializado con éxito para el proyecto: {firebaseService.ProjectId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al inicializar Firestore: {ex.Message}");
            }
        }
    }

    public bool IsCloud => _firestoreDb != null;

    // Pedidos
    public async Task<List<PedidoDto>> ListarPedidosAsync()
    {
        if (IsCloud)
        {
            var snapshot = await _firestoreDb!.Collection("pedidos").GetSnapshotAsync();
            var list = new List<PedidoDto>();
            foreach (var doc in snapshot.Documents)
            {
                var item = doc.ConvertTo<PedidoDto>();
                item.Id = doc.Id;
                list.Add(item);
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
            var docRef = _firestoreDb!.Collection("pedidos").Document(pedido.Id);
            await docRef.SetAsync(pedido);
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
            var snapshot = await _firestoreDb!.Collection("usuarios").GetSnapshotAsync();
            var list = new List<UsuarioDto>();
            foreach (var doc in snapshot.Documents)
            {
                var item = doc.ConvertTo<UsuarioDto>();
                item.Id = doc.Id;
                list.Add(item);
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
            var docRef = _firestoreDb!.Collection("usuarios").Document(usuario.Id);
            await docRef.SetAsync(usuario);
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
            var snapshot = await _firestoreDb!.Collection("direcciones").GetSnapshotAsync();
            var list = new List<DireccionDto>();
            foreach (var doc in snapshot.Documents)
            {
                var item = doc.ConvertTo<DireccionDto>();
                item.Id = doc.Id;
                list.Add(item);
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
            var docRef = _firestoreDb!.Collection("direcciones").Document(direccion.Id);
            await docRef.SetAsync(direccion);
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
            var docRef = _firestoreDb!.Collection("direcciones").Document(id);
            await docRef.DeleteAsync();
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
            var snapshot = await _firestoreDb!.Collection("metodosPago").GetSnapshotAsync();
            var list = new List<MetodoPagoDto>();
            foreach (var doc in snapshot.Documents)
            {
                var item = doc.ConvertTo<MetodoPagoDto>();
                item.Id = doc.Id;
                list.Add(item);
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
            var docRef = _firestoreDb!.Collection("metodosPago").Document(metodo.Id);
            await docRef.SetAsync(metodo);
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
