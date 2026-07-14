# Supabase setup

Se genero una migracion completa para el proyecto en:

- supabase/migrations/20260714_001_init_lavanderia.sql

## Que crea

- Tablas: usuarios, direcciones, metodos_pago, pedidos
- Relaciones por foreign key
- Indices para busquedas frecuentes
- Trigger de updated_at
- RLS habilitado con politica service_role
- Datos semilla compatibles con el backend actual

## Como ejecutarla

1. Abre Supabase -> SQL Editor.
2. Copia el contenido de la migracion.
3. Ejecuta el script completo.
4. Verifica las tablas en Table Editor.

## Notas de integracion

- Este esquema mantiene ids tipo texto para compatibilidad con el backend actual.
- La base queda privada por RLS para uso desde backend con service role.
- Si luego quieres acceso directo desde cliente Flutter, hay que agregar politicas RLS para authenticated/anon segun el flujo.
