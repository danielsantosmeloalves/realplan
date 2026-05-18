-- =============================================
-- REALPLAN — SQL de configuração do banco
-- Execute no Supabase: SQL Editor > New query
-- =============================================

-- 1. Tabela de perfis (admin e alunos)
create table if not exists profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  full_name text not null,
  email text not null,
  role text not null default 'aluno' check (role in ('admin', 'aluno')),
  created_at timestamptz default now()
);

-- 2. Disponibilidade de horas por dia do aluno
create table if not exists disponibilidade (
  id uuid default gen_random_uuid() primary key,
  aluno_id uuid references profiles(id) on delete cascade not null unique,
  seg int default 4 check (seg between 0 and 8),
  ter int default 4 check (ter between 0 and 8),
  qua int default 4 check (qua between 0 and 8),
  qui int default 4 check (qui between 0 and 8),
  sex int default 4 check (sex between 0 and 8),
  sab int default 6 check (sab between 0 and 8),
  dom int default 2 check (dom between 0 and 8),
  updated_at timestamptz default now()
);

-- 3. Matérias do edital
create table if not exists materias (
  id uuid default gen_random_uuid() primary key,
  nome text not null,
  descricao text default '',
  is_redacao boolean default false,
  created_at timestamptz default now()
);

-- 4. Metas dentro de cada matéria
create table if not exists metas (
  id uuid default gen_random_uuid() primary key,
  materia_id uuid references materias(id) on delete cascade not null,
  nome text not null,
  tempo_sugerido int not null default 1,  -- em horas
  orientacoes text default '',
  material_url text,
  is_redacao boolean default false,
  ordem int default 1,
  created_at timestamptz default now()
);

-- 5. Ciclos de estudo
create table if not exists ciclos (
  id uuid default gen_random_uuid() primary key,
  nome text not null,
  aluno_id uuid references profiles(id) on delete set null,
  created_at timestamptz default now()
);

-- 6. Sequência das matérias dentro de cada ciclo
create table if not exists ciclo_materias (
  id uuid default gen_random_uuid() primary key,
  ciclo_id uuid references ciclos(id) on delete cascade not null,
  materia_id uuid references materias(id) on delete cascade not null,
  ordem int default 1,
  created_at timestamptz default now()
);

-- 7. Uploads dos alunos (revisão e redação)
create table if not exists uploads_aluno (
  id uuid default gen_random_uuid() primary key,
  aluno_id uuid references profiles(id) on delete cascade not null,
  meta_id uuid references metas(id) on delete cascade not null,
  tipo text not null check (tipo in ('revisao', 'redacao')),
  url text not null,
  created_at timestamptz default now()
);

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================

alter table profiles enable row level security;
alter table disponibilidade enable row level security;
alter table materias enable row level security;
alter table metas enable row level security;
alter table ciclos enable row level security;
alter table ciclo_materias enable row level security;
alter table uploads_aluno enable row level security;

-- Profiles: cada um vê o próprio, admin vê todos
create policy "profiles_select" on profiles for select using (
  auth.uid() = id or
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "profiles_insert" on profiles for insert with check (true);
create policy "profiles_update" on profiles for update using (
  auth.uid() = id or
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Disponibilidade
create policy "disp_select" on disponibilidade for select using (
  aluno_id = auth.uid() or
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "disp_insert" on disponibilidade for insert with check (true);
create policy "disp_update" on disponibilidade for update using (true);

-- Matérias (todos leem, só admin escreve)
create policy "materias_select" on materias for select using (true);
create policy "materias_write" on materias for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Metas (todos leem, só admin escreve)
create policy "metas_select" on metas for select using (true);
create policy "metas_write" on metas for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Ciclos
create policy "ciclos_select" on ciclos for select using (true);
create policy "ciclos_write" on ciclos for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Ciclo Matérias
create policy "ciclo_materias_select" on ciclo_materias for select using (true);
create policy "ciclo_materias_write" on ciclo_materias for all using (
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);

-- Uploads
create policy "uploads_select" on uploads_aluno for select using (
  aluno_id = auth.uid() or
  exists (select 1 from profiles where id = auth.uid() and role = 'admin')
);
create policy "uploads_insert" on uploads_aluno for insert with check (aluno_id = auth.uid());

-- =============================================
-- STORAGE BUCKET
-- Execute separado se necessário
-- =============================================
-- insert into storage.buckets (id, name, public) values ('realplan', 'realplan', true);

-- =============================================
-- CRIAR CONTA ADMIN (substitua os dados)
-- Após criar o usuário pelo Auth do Supabase,
-- rode este insert com o UUID gerado:
-- =============================================
-- insert into profiles (id, full_name, email, role)
-- values ('UUID-DO-USUARIO-ADMIN', 'Seu Nome', 'seu@email.com', 'admin');
