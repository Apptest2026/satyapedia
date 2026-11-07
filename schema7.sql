-- Run once in Supabase > SQL Editor (after schema6.sql): founder <-> company links
create table roles(
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references profiles on delete cascade,     -- the business page
  person_id uuid not null references profiles on delete cascade,  -- the personal page
  title text not null default 'Founder' check (title in ('Founder','Co-founder','Director','Partner','Owner')),
  status text not null default 'pending' check (status in ('pending','approved')),
  created_at timestamptz default now(),
  unique (org_id, person_id));
alter table roles enable row level security;

create policy ro_sel on roles for select using (
  status='approved' or is_admin() or exists(select 1 from profiles x where x.id in (roles.org_id, roles.person_id) and x.owner=auth.uid()));
create policy ro_ins on roles for insert with check (
  exists(select 1 from profiles o where o.id=org_id and o.owner=auth.uid() and o.kind='business')
  and exists(select 1 from profiles p where p.id=person_id and p.kind='personal'));
create policy ro_upd on roles for update using (
  is_admin() or exists(select 1 from profiles p where p.id=roles.person_id and p.owner=auth.uid()));
create policy ro_del on roles for delete using (
  is_admin() or exists(select 1 from profiles x where x.id in (roles.org_id, roles.person_id) and x.owner=auth.uid()));

create function roles_before() returns trigger language plpgsql security definer set search_path=public as $$
begin
  if tg_op='INSERT' then
    -- same owner on both pages = auto approved; someone else's page must approve first
    if (select owner from profiles where id=new.org_id) = (select owner from profiles where id=new.person_id)
      then new.status:='approved'; else new.status:='pending'; end if;
    return new;
  end if;
  if not is_admin() then new.org_id:=old.org_id; new.person_id:=old.person_id; new.title:=old.title; end if;
  return new;
end $$;
create trigger roles_guard before insert or update on roles for each row execute function roles_before();

-- auto-link a person's own personal + business pages
create function autolink() returns trigger language plpgsql security definer set search_path=public as $$
begin
  if new.kind='business' then
    insert into roles(org_id,person_id,title) select new.id,pr.id,'Founder' from profiles pr where pr.owner=new.owner and pr.kind='personal' on conflict do nothing;
  else
    insert into roles(org_id,person_id,title) select o.id,new.id,'Founder' from profiles o where o.owner=new.owner and o.kind='business' on conflict do nothing;
  end if;
  return new;
end $$;
create trigger profiles_autolink after insert on profiles for each row execute function autolink();

-- link pages that already exist
insert into roles(org_id,person_id,title)
select o.id, pr.id, 'Founder' from profiles o join profiles pr on pr.owner=o.owner and pr.kind='personal' where o.kind='business'
on conflict do nothing;
