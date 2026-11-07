-- Run once in Supabase > SQL Editor (after schema8.sql)
-- Owner can request a correction of a LOCKED fact (name, founder, established, GST); admin approves; change is shown in the public page history.
create table corrections(
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles on delete cascade,
  requester uuid not null references auth.users on delete cascade,
  field text not null check (field in ('name','founder','est','gst')),
  new_value text not null check (char_length(new_value)<=200),
  reason text check (char_length(reason)<=1000),
  status text not null default 'open' check (status in ('open','approved','rejected')),
  created_at timestamptz default now(),
  decided_at timestamptz);
alter table corrections enable row level security;
create policy co_ins on corrections for insert with check (
  requester=auth.uid() and exists(select 1 from profiles p where p.id=profile_id and p.owner=auth.uid()));
create policy co_sel on corrections for select using (requester=auth.uid() or is_admin());
create policy co_upd on corrections for update using (is_admin());

create or replace function guard() returns trigger language plpgsql security definer set search_path=public as $$
declare f text;
begin
  if tg_op = 'INSERT' then
    new.slug := make_slug(new.name, new.id);
    if not is_admin() then
      new.tick := case when new.kind='business' then 'biz' else 'common' end;
      new.verified := false; new.verified_at := null; new.verified_basis := null;
      new.edits := 0; new.hidden := false;
    end if;
    return new;
  end if;
  if not is_admin() then
    new.owner := old.owner; new.kind := old.kind; new.tick := old.tick; new.slug := old.slug;
    new.verified := old.verified; new.edits := old.edits; new.hidden := old.hidden;
    new.verified_at := old.verified_at; new.verified_basis := old.verified_basis;
    if old.verified then
      new.name := old.name; new.founder := old.founder; new.est := old.est; new.gst := old.gst;
    end if;
  end if;
  foreach f in array array['address','product','vals','bio','headline','city','website','links'] loop
    if to_jsonb(new)->>f is distinct from to_jsonb(old)->>f then
      insert into edits(profile_id, field, old_v, new_v) values (old.id, f, to_jsonb(old)->>f, to_jsonb(new)->>f);
      new.edits := new.edits + 1;
    end if;
  end loop;
  if old.verified then   -- an admin-approved correction of a locked fact is logged publicly
    foreach f in array array['name','founder','est','gst'] loop
      if to_jsonb(new)->>f is distinct from to_jsonb(old)->>f then
        insert into edits(profile_id, field, old_v, new_v) values (old.id, f, to_jsonb(old)->>f, to_jsonb(new)->>f);
        new.edits := new.edits + 1;
      end if;
    end loop;
  end if;
  return new;
end $$;
