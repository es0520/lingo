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

-- Phase 1 업데이트: 예문 뜻/동의어, 공유 링크, 오답 복습 주기, 닉네임
alter table public.words add column if not exists example_ko text not null default '';
alter table public.words add column if not exists synonyms text not null default '';
alter table public.decks add column if not exists share_token uuid unique;
alter table public.mistakes add column if not exists wrong_count int not null default 1;
alter table public.mistakes add column if not exists next_review_at timestamptz not null default now();

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (char_length(nickname) between 1 and 30),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "own profile" on public.profiles for all to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

-- 공유 링크: 소유자가 아니어도 share_token이 설정된 덱/단어는 읽을 수 있게 허용
create policy "read shared deck" on public.decks for select to authenticated using (share_token is not null);
create policy "read shared deck words" on public.words for select to authenticated using (exists (select 1 from public.decks d where d.id = deck_id and d.share_token is not null));

-- Phase 2 업데이트: 중국어 병음
alter table public.words add column if not exists pinyin text not null default '';

-- 이미 만들어진 기본 스페인어 단어장에 예문 뜻/동의어 채우기 (이미 채워져 있으면 덮어쓰지 않음)
update public.words set example_ko = '안녕! 어떻게 지내?' where front = 'hola' and example_ko = '';
update public.words set example_ko = '정말 고마워요.', synonyms = '감사합니다' where front = 'gracias' and example_ko = '';
update public.words set example_ko = '커피 한 잔 부탁해요.', synonyms = '부탁해요' where front = 'por favor' and example_ko = '';
update public.words set example_ko = '화장실이 어디에 있나요?' where front = '¿dónde está...?' and example_ko = '';
update public.words set example_ko = '계산서 부탁해요.', synonyms = '영수증' where front = 'la cuenta' and example_ko = '';
update public.words set example_ko = '그는 내 친구예요.' where front = 'amigo' and example_ko = '';
update public.words set example_ko = '우리 가족은 대가족이에요.' where front = 'familia' and example_ko = '';
update public.words set example_ko = '먹고 싶어요.' where front = 'comer' and example_ko = '';
update public.words set example_ko = '오늘은 월요일이에요.' where front = 'hoy' and example_ko = '';
