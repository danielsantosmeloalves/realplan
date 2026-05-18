# RealPlan

Plataforma de mentoria para concursos públicos.

## Stack
- **Frontend/Backend**: Next.js 14 (App Router)
- **Banco de dados**: Supabase (PostgreSQL)
- **Hospedagem**: Vercel
- **Storage**: Supabase Storage (uploads de arquivos)

---

## 1. Configurar o Supabase

### 1.1 Executar o SQL
1. Acesse seu projeto em [supabase.com](https://supabase.com)
2. Vá em **SQL Editor → New query**
3. Cole todo o conteúdo de `supabase_setup.sql` e clique em **Run**

### 1.2 Criar o bucket de storage
1. Vá em **Storage → New bucket**
2. Nome: `realplan`
3. Marque **Public bucket**
4. Clique em **Save**

### 1.3 Criar o usuário admin
1. Vá em **Authentication → Users → Add user**
2. Preencha o e-mail e senha do professor/admin
3. Copie o **UUID** gerado
4. Vá em **SQL Editor** e rode:
```sql
insert into profiles (id, full_name, email, role)
values ('COLE-O-UUID-AQUI', 'Seu Nome', 'seu@email.com', 'admin');
```

---

## 2. Rodar localmente

```bash
# Instalar dependências
npm install

# Rodar em desenvolvimento
npm run dev
```

Acesse: http://localhost:3000

---

## 3. Deploy no Vercel

### 3.1 Subir o código no GitHub
```bash
git init
git add .
git commit -m "feat: initial RealPlan setup"
git remote add origin https://github.com/danielsantosmeloalves/realplan.git
git push -u origin main
```

### 3.2 Criar o projeto no Vercel
1. Acesse [vercel.com](https://vercel.com)
2. Clique em **Add New Project**
3. Importe o repositório `danielsantosmeloalves/realplan`
4. Em **Environment Variables**, adicione:
   - `NEXT_PUBLIC_SUPABASE_URL` = `https://nflshxligczohzqzlefw.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = sua chave publishable
5. Clique em **Deploy**

---

## Estrutura do projeto

```
app/
  auth/login/       → Página de login
  admin/            → Painel do professor
    page.tsx        → Dashboard
    alunos/         → Cadastro de alunos e disponibilidade
    materias/       → Matérias e metas
    ciclos/         → Ciclos de estudo (sequência)
  aluno/            → Área do aluno
    page.tsx        → Calendário semanal (plano)
    metas/          → Todas as metas com uploads
```

---

## Funcionalidades

### Professor (Admin)
- Cadastrar alunos com disponibilidade individual por dia (0-8h, seg-dom)
- Criar matérias do edital (incluindo matéria de redação)
- Criar metas dentro de cada matéria: nome, tempo sugerido, orientações, material de estudo
- Organizar ciclos de estudo com sequência de matérias por aluno

### Aluno
- Ver calendário semanal com as metas distribuídas de acordo com sua disponibilidade
- Clicar em cada meta e ver detalhes: orientações do professor, material de estudo
- Fazer upload do material de revisão em cada meta
- Fazer upload de redação (nas metas marcadas como redação)
