-- Run once in Supabase > SQL Editor (after schema7.sql)
-- 1) what was checked + when, 2) owner can delete own page, 3) new pages always need admin review
alter table profiles add column if not exists verified_at timestamptz, add column if not exists verified_basis text;
update profiles set verified_at=coalesce(verified_at,now()), verified_basis=coalesce(verified_basis,'id_name') where verified;

drop policy if exists p_del on profiles;
create policy p_del on profiles for delete using (owner=auth.uid() or is_admin());

create or replace function guard() returns trigger language plpgsql security definer set search_path=public as $$
declare f text;
begin
  if tg_op = 'INSERT' then
    new.slug := make_slug(new.name, new.id);
    if not is_admin() then
      new.tick := case when new.kind='business' then 'biz' else 'common' end;
      new.verified := false; new.verified_at := null; new.verified_basis := null;   -- always needs admin review
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
  return new;
end $$;
