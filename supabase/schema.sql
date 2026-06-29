create extension if not exists pgcrypto;

create table if not exists public.workspaces (
  id uuid primary key default gen_random_uuid(),
  name text not null default '委託販売台帳',
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  invite_code text not null unique default upper(substr(encode(gen_random_bytes(8), 'hex'), 1, 12)),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workspace_members (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'editor' check (role in ('owner', 'editor', 'viewer')),
  created_at timestamptz not null default now(),
  primary key (workspace_id, user_id)
);

create table if not exists public.ledgers (
  workspace_id uuid primary key references public.workspaces(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  revision bigint not null default 1,
  updated_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now()
);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists workspaces_touch_updated_at on public.workspaces;
create trigger workspaces_touch_updated_at
before update on public.workspaces
for each row execute function public.touch_updated_at();

create or replace function public.bump_ledger_revision()
returns trigger
language plpgsql
as $$
begin
  new.revision = old.revision + 1;
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists ledgers_bump_revision on public.ledgers;
create trigger ledgers_bump_revision
before update on public.ledgers
for each row execute function public.bump_ledger_revision();

create or replace function public.is_workspace_member(target_workspace_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspace_members
    where workspace_id = target_workspace_id
      and user_id = auth.uid()
  );
$$;

create or replace function public.has_workspace_role(target_workspace_id uuid, allowed_roles text[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.workspace_members
    where workspace_id = target_workspace_id
      and user_id = auth.uid()
      and role = any(allowed_roles)
  );
$$;

create or replace function public.create_personal_workspace(workspace_name text default '委託販売台帳')
returns public.workspaces
language plpgsql
security definer
set search_path = public
as $$
declare
  created_workspace public.workspaces;
begin
  if auth.uid() is null then
    raise exception 'Login is required.';
  end if;

  insert into public.workspaces (name, owner_id)
  values (coalesce(nullif(trim(workspace_name), ''), '委託販売台帳'), auth.uid())
  returning * into created_workspace;

  insert into public.workspace_members (workspace_id, user_id, role)
  values (created_workspace.id, auth.uid(), 'owner');

  insert into public.ledgers (workspace_id, data, updated_by)
  values (created_workspace.id, '{}'::jsonb, auth.uid());

  return created_workspace;
end;
$$;

create or replace function public.join_workspace_with_code(join_code text)
returns public.workspaces
language plpgsql
security definer
set search_path = public
as $$
declare
  target_workspace public.workspaces;
begin
  if auth.uid() is null then
    raise exception 'Login is required.';
  end if;

  select *
    into target_workspace
    from public.workspaces
    where invite_code = upper(trim(join_code));

  if target_workspace.id is null then
    raise exception 'Invite code was not found.';
  end if;

  insert into public.workspace_members (workspace_id, user_id, role)
  values (target_workspace.id, auth.uid(), 'editor')
  on conflict (workspace_id, user_id) do nothing;

  return target_workspace;
end;
$$;

create or replace function public.rotate_workspace_invite(target_workspace_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  new_code text;
begin
  if not public.has_workspace_role(target_workspace_id, array['owner']) then
    raise exception 'Owner role is required.';
  end if;

  new_code := upper(substr(encode(gen_random_bytes(8), 'hex'), 1, 12));

  update public.workspaces
    set invite_code = new_code
    where id = target_workspace_id;

  return new_code;
end;
$$;

alter table public.workspaces enable row level security;
alter table public.workspace_members enable row level security;
alter table public.ledgers enable row level security;

drop policy if exists "members can read workspaces" on public.workspaces;
create policy "members can read workspaces"
on public.workspaces for select
using (public.is_workspace_member(id));

drop policy if exists "owners can update workspaces" on public.workspaces;
create policy "owners can update workspaces"
on public.workspaces for update
using (public.has_workspace_role(id, array['owner']))
with check (public.has_workspace_role(id, array['owner']));

drop policy if exists "users can create own workspace" on public.workspaces;
create policy "users can create own workspace"
on public.workspaces for insert
with check (owner_id = auth.uid());

drop policy if exists "members can read workspace members" on public.workspace_members;
create policy "members can read workspace members"
on public.workspace_members for select
using (public.is_workspace_member(workspace_id));

drop policy if exists "owners can manage workspace members" on public.workspace_members;
create policy "owners can manage workspace members"
on public.workspace_members for all
using (public.has_workspace_role(workspace_id, array['owner']))
with check (public.has_workspace_role(workspace_id, array['owner']));

drop policy if exists "members can read ledgers" on public.ledgers;
create policy "members can read ledgers"
on public.ledgers for select
using (public.is_workspace_member(workspace_id));

drop policy if exists "editors can update ledgers" on public.ledgers;
create policy "editors can update ledgers"
on public.ledgers for update
using (public.has_workspace_role(workspace_id, array['owner', 'editor']))
with check (public.has_workspace_role(workspace_id, array['owner', 'editor']));

drop policy if exists "editors can create ledgers" on public.ledgers;
create policy "editors can create ledgers"
on public.ledgers for insert
with check (public.has_workspace_role(workspace_id, array['owner', 'editor']));

grant usage on schema public to authenticated;
grant select, insert, update on public.workspaces to authenticated;
grant select, insert, update, delete on public.workspace_members to authenticated;
grant select, insert, update on public.ledgers to authenticated;

revoke execute on function public.create_personal_workspace(text) from public;
revoke execute on function public.join_workspace_with_code(text) from public;
revoke execute on function public.rotate_workspace_invite(uuid) from public;
grant execute on function public.create_personal_workspace(text) to authenticated;
grant execute on function public.join_workspace_with_code(text) to authenticated;
grant execute on function public.rotate_workspace_invite(uuid) to authenticated;
