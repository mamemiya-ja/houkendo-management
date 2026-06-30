create extension if not exists pgcrypto;

create table if not exists public.user_ledgers (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  revision bigint not null default 1,
  updated_at timestamptz not null default now()
);

create or replace function public.bump_user_ledger_revision()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' then
    new.revision = old.revision + 1;
  end if;
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists user_ledgers_bump_revision on public.user_ledgers;
create trigger user_ledgers_bump_revision
before update on public.user_ledgers
for each row execute function public.bump_user_ledger_revision();

alter table public.user_ledgers enable row level security;

drop policy if exists "users can read own ledger" on public.user_ledgers;
create policy "users can read own ledger"
on public.user_ledgers for select
using (user_id = auth.uid());

drop policy if exists "users can create own ledger" on public.user_ledgers;
create policy "users can create own ledger"
on public.user_ledgers for insert
with check (user_id = auth.uid());

drop policy if exists "users can update own ledger" on public.user_ledgers;
create policy "users can update own ledger"
on public.user_ledgers for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

grant usage on schema public to authenticated;
grant select, insert, update on public.user_ledgers to authenticated;

-- If the old shared-ledger schema exists, keep the owner's ledger data before removing it.
do $$
begin
  if to_regclass('public.ledgers') is not null and to_regclass('public.workspaces') is not null then
    execute $migration$
      insert into public.user_ledgers (user_id, data, updated_at)
      select w.owner_id, l.data, coalesce(l.updated_at, now())
      from public.ledgers l
      join public.workspaces w on w.id = l.workspace_id
      where w.owner_id is not null
      on conflict (user_id) do update
        set data = case
              when public.user_ledgers.data = '{}'::jsonb then excluded.data
              else public.user_ledgers.data
            end,
            updated_at = greatest(public.user_ledgers.updated_at, excluded.updated_at)
    $migration$;
  end if;
end;
$$;

-- Remove the old shared schema implementation.
drop table if exists public.workspace_members cascade;
drop table if exists public.ledgers cascade;
drop table if exists public.workspaces cascade;

drop function if exists public.rotate_workspace_invite(uuid) cascade;
drop function if exists public.join_workspace_with_code(text) cascade;
drop function if exists public.create_personal_workspace(text) cascade;
drop function if exists public.has_workspace_role(uuid, text[]) cascade;
drop function if exists public.is_workspace_member(uuid) cascade;
drop function if exists public.bump_ledger_revision() cascade;
drop function if exists public.touch_updated_at() cascade;
