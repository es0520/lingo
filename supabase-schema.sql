-- Supabase Dashboard > SQL Editor에서 한 번 실행하세요.
create table if not exists public.decks (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 100),
  language text not null default '스페인어',
  icon text not null default '📚',
  created_at timestamptz not null default now()
);
create table if not exists public.words (
  id uuid primary key default gen_random_uuid(),
  deck_id uuid not null references public.decks(id) on delete cascade,
  front text not null,
  back text not null,
  example text not null default '',
  created_at timestamptz not null default now()
);
create table if not exists public.mistakes (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  word_id uuid not null references public.words(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(owner_id, word_id)
);
alter table public.decks enable row level security;
alter table public.words enable row level security;
alter table public.mistakes enable row level security;
create policy "own decks" on public.decks for all to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "own deck words" on public.words for all to authenticated using (exists (select 1 from public.decks d where d.id = deck_id and d.owner_id = (select auth.uid()))) with check (exists (select 1 from public.decks d where d.id = deck_id and d.owner_id = (select auth.uid())));
create policy "own mistakes" on public.mistakes for all to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
