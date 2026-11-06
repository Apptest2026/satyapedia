-- Run once in Supabase > SQL Editor
alter table profiles add column website text, add column links text, add column hidden boolean not null default false;
alter table profiles add constraint url_ok check ((website is null or (website ~* '^https?://[^ ]+$' and char_length(website)<=200)) and char_length(coalesce(links,''))<=800) not valid;

create table reports(
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles on delete cascade,
  reason text not null check (char_length(reason)<=50),
  details text check (char_length(details)<=1000),
  contact text check (char_length(contact)<=200),
  status text not null default 'open' check (status in ('open','actioned','dismissed')),
  created_at timestamptz default now());
alter table reports enable row level security;
create policy rp_ins on reports for insert to anon, authenticated with check (status='open');
create policy rp_sel on reports for select using (is_admin());
create policy rp_upd on reports for update using (is_admin());
grant insert on reports to anon, authenticated;

create or replace function guard() returns trigger language plpgsql security definer set search_path=public as $$
declare f text;
begin
  if tg_op = 'INSERT' then
    new.slug := make_slug(new.name, new.id);
    if not is_admin() then
      new.tick := case when new.kind='business' then 'biz' else 'common' end;
      new.verified := exists(select 1 from kyc where user_id=new.owner and status='verified');
      new.edits := 0; new.hidden := false;
    end if;
    return new;
  end if;
  if not is_admin() then
    new.owner := old.owner; new.kind := old.kind; new.tick := old.tick; new.slug := old.slug;
    new.verified := old.verified; new.edits := old.edits; new.hidden := old.hidden;
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
