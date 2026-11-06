-- Run AFTER schema.sql (Supabase > SQL Editor > New query > Run)
alter table profiles add column slug text unique, add column city text, add column category text, add column headline text;

create function make_slug(n text, i uuid) returns text language sql immutable as $$
  select coalesce(nullif(trim(both '-' from left(regexp_replace(lower(n),'[^a-z0-9]+','-','g'),40)),''),'profile')
         || '-' || substr(replace(i::text,'-',''),1,6) $$;
update profiles set slug = make_slug(name, id) where slug is null;

-- abuse / data-quality limits (apply to new writes)
alter table profiles add constraint len_ok check (
  char_length(name)<=120 and char_length(coalesce(headline,''))<=160 and char_length(coalesce(bio,''))<=2000 and
  char_length(coalesce(address,''))<=300 and char_length(coalesce(product,''))<=500 and char_length(coalesce(vals,''))<=500) not valid;
alter table profiles add constraint gst_fmt check (gst is null or gst ~ '^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$') not valid;

create or replace function guard() returns trigger language plpgsql security definer set search_path=public as $$
declare f text;
begin
  if tg_op = 'INSERT' then
    new.slug := make_slug(new.name, new.id);
    if not is_admin() then
      new.tick := case when new.kind='business' then 'biz' else 'common' end;
      -- FIX: user already KYC-verified gets a verified page immediately
      new.verified := exists(select 1 from kyc where user_id=new.owner and status='verified');
      new.edits := 0;
    end if;
    return new;
  end if;
  if not is_admin() then
    new.owner := old.owner; new.kind := old.kind; new.tick := old.tick; new.slug := old.slug;
    new.verified := old.verified; new.edits := old.edits;
    if old.verified then
      new.name := old.name; new.founder := old.founder; new.est := old.est; new.gst := old.gst;
    end if;
  end if;
  foreach f in array array['address','product','vals','bio','headline','city'] loop
    if to_jsonb(new)->>f is distinct from to_jsonb(old)->>f then
      insert into edits(profile_id, field, old_v, new_v) values (old.id, f, to_jsonb(old)->>f, to_jsonb(new)->>f);
      new.edits := new.edits + 1;
    end if;
  end loop;
  return new;
end $$;
