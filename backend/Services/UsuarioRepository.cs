using backend.Controllers;

namespace backend;

public static class UsuarioRepository
{
    public static readonly List<UsuarioDto> Usuarios = new()
    {
        new() { Id = "1", Nombre = "Admin San Juan", Correo = "admin@sanjuan.com", Telefono = "3001234567", Password = "admin123", Rol = "administrador" },
        new() { Id = "2", Nombre = "Cliente Demo", Correo = "cliente@sanjuan.com", Telefono = "3007654321", Password = "cliente123", Rol = "cliente" }
    };
}
