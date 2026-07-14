-- Lavanderia San Juan - Initial Supabase schema
-- Run in Supabase SQL Editor or as a migration file.

begin;

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.usuarios (
  id text primary key default replace(gen_random_uuid()::text, '-', ''),
  nombre text not null,
  correo text not null unique,
  telefono text,
  password text not null,
  rol text not null default 'cliente' check (rol in ('cliente', 'administrador')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.direcciones (
  id text primary key default replace(gen_random_uuid()::text, '-', ''),
  usuario_id text references public.usuarios(id) on delete set null,
  titulo text not null default 'Nueva direccion',
  lineas text[] not null default '{}',
  telefono text,
  nota text,
  predeterminada boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.metodos_pago (
  id text primary key default replace(gen_random_uuid()::text, '-', ''),
  usuario_id text references public.usuarios(id) on delete set null,
  marca text not null default 'visa',
  ultimos_digitos text not null default '' check (char_length(ultimos_digitos) <= 4),
  expira text not null default '',
  principal boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pedidos (
  id text primary key default replace(gen_random_uuid()::text, '-', ''),
  cliente_id text references public.usuarios(id) on delete set null,
  cliente_nombre text not null,
  servicio text not null,
  fecha date not null default current_date,
  franja_horaria text,
  direccion text,
  instrucciones text not null default '',
  total numeric(10,2) not null default 0,
  estado text not null default 'En proceso',
  historial_estados jsonb not null default '[]'::jsonb,
  calificacion_general integer check (calificacion_general between 1 and 5),
  resena text,
  reporte_tipo text,
  reporte_detalles text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_usuarios_correo on public.usuarios (lower(correo));
create index if not exists idx_direcciones_usuario_id on public.direcciones (usuario_id);
create index if not exists idx_metodos_pago_usuario_id on public.metodos_pago (usuario_id);
create index if not exists idx_pedidos_cliente_id on public.pedidos (cliente_id);
create index if not exists idx_pedidos_estado on public.pedidos (estado);
create index if not exists idx_pedidos_fecha on public.pedidos (fecha desc);

drop trigger if exists trg_usuarios_updated_at on public.usuarios;
create trigger trg_usuarios_updated_at
before update on public.usuarios
for each row execute function public.set_updated_at();

drop trigger if exists trg_direcciones_updated_at on public.direcciones;
create trigger trg_direcciones_updated_at
before update on public.direcciones
for each row execute function public.set_updated_at();

drop trigger if exists trg_metodos_pago_updated_at on public.metodos_pago;
create trigger trg_metodos_pago_updated_at
before update on public.metodos_pago
for each row execute function public.set_updated_at();

drop trigger if exists trg_pedidos_updated_at on public.pedidos;
create trigger trg_pedidos_updated_at
before update on public.pedidos
for each row execute function public.set_updated_at();

alter table public.usuarios enable row level security;
alter table public.direcciones enable row level security;
alter table public.metodos_pago enable row level security;
alter table public.pedidos enable row level security;

-- Service-role only policies. Keep DB private; backend should use service role key.
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public' and tablename = 'usuarios' and policyname = 'service_role_all_usuarios'
  ) then
    create policy "service_role_all_usuarios"
    on public.usuarios
    for all
    using (auth.role() = 'service_role')
    with check (auth.role() = 'service_role');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public' and tablename = 'direcciones' and policyname = 'service_role_all_direcciones'
  ) then
    create policy "service_role_all_direcciones"
    on public.direcciones
    for all
    using (auth.role() = 'service_role')
    with check (auth.role() = 'service_role');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public' and tablename = 'metodos_pago' and policyname = 'service_role_all_metodos_pago'
  ) then
    create policy "service_role_all_metodos_pago"
    on public.metodos_pago
    for all
    using (auth.role() = 'service_role')
    with check (auth.role() = 'service_role');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public' and tablename = 'pedidos' and policyname = 'service_role_all_pedidos'
  ) then
    create policy "service_role_all_pedidos"
    on public.pedidos
    for all
    using (auth.role() = 'service_role')
    with check (auth.role() = 'service_role');
  end if;
end
$$;

-- Seed data aligned with backend defaults.
insert into public.usuarios (id, nombre, correo, telefono, password, rol)
values
  ('admin-id-12345', 'Administrador FreshClean', 'admin@freshclean.com', '9998887777', 'Admin123!', 'administrador'),
  ('cliente-id-12345', 'Abraham San Juan', 'cliente@freshclean.com', '1234567890', 'Cliente123!', 'cliente')
on conflict (id) do nothing;

insert into public.direcciones (id, usuario_id, titulo, lineas, telefono, nota, predeterminada)
values
  ('dir-1', 'cliente-id-12345', 'Casa', array['Av. Linda Vista #402', 'Col. Linda Vista', 'San Juan'], '1234567890', 'Porton verde, timbre al lado de la reja', true),
  ('dir-2', 'cliente-id-12345', 'Trabajo', array['Paseo de la Reforma #115', 'Oficinas Center, Piso 4', 'San Juan'], '0987654321', 'Dejar en recepcion', false)
on conflict (id) do nothing;

insert into public.metodos_pago (id, usuario_id, marca, ultimos_digitos, expira, principal)
values
  ('met-1', 'cliente-id-12345', 'visa', '4242', '12/28', true),
  ('met-2', 'cliente-id-12345', 'mastercard', '5555', '08/29', false)
on conflict (id) do nothing;

insert into public.pedidos (
  id,
  cliente_id,
  cliente_nombre,
  servicio,
  fecha,
  franja_horaria,
  direccion,
  instrucciones,
  total,
  estado,
  historial_estados
)
values
  (
    'ped-1',
    'cliente-id-12345',
    'Abraham San Juan',
    'Lavado por Kilo (Estandar)',
    current_date - interval '2 day',
    '10:00 AM - 12:00 PM',
    'Av. Linda Vista #402, Col. Linda Vista',
    'Cuidado con las prendas delicadas',
    150.00,
    'Entregado',
    jsonb_build_array(
      jsonb_build_object('estado', 'En proceso', 'fecha', now() - interval '2 day', 'observaciones', 'Pedido creado'),
      jsonb_build_object('estado', 'Recolectado', 'fecha', now() - interval '46 hour', 'observaciones', 'Prendas recolectadas'),
      jsonb_build_object('estado', 'En lavado', 'fecha', now() - interval '36 hour', 'observaciones', 'En lavadora'),
      jsonb_build_object('estado', 'Listo para entrega', 'fecha', now() - interval '26 hour', 'observaciones', 'Empacado'),
      jsonb_build_object('estado', 'Entregado', 'fecha', now() - interval '24 hour', 'observaciones', 'Entregado en domicilio')
    )
  ),
  (
    'ped-2',
    'cliente-id-12345',
    'Abraham San Juan',
    'Tintoreria (Traje 2 piezas)',
    current_date,
    '04:00 PM - 06:00 PM',
    'Av. Linda Vista #402, Col. Linda Vista',
    'Planchar con raya marcada',
    280.00,
    'En proceso',
    jsonb_build_array(
      jsonb_build_object('estado', 'En proceso', 'fecha', now(), 'observaciones', 'Pedido recibido')
    )
  )
on conflict (id) do nothing;

commit;
