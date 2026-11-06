-- SatyaPedia schema. Supabase > SQL Editor > New query > paste all > Run
create table admins(user_id uuid primary key references auth.users on delete cascade);

create table kyc(
  user_id uuid primary key references auth.users on delete cascade,
  id_hash text unique not null,          -- one KYC ID = one user (hash only, no full ID stored)
  last4 text, doc_type text, doc_path text,
  status text not null default 'pending' check (status in ('pending','verified','rejected')),
  created_at timestamptz default now());

create table profiles(
  id uuid primary key default gen_random_uuid(),
  owner uuid not null references auth.users on delete cascade,
  kind text not null check (kind in ('personal','business')),
  tick text not null default 'common' check (tick in ('common','biz','gov','opp','celeb','premium')),
  verified boolean not null default false,
  name text not null, founder text, est text,
  gst text unique,                       -- one GST = one account
  address text, product text, vals text, bio text,
  edits int not null default 0,
  created_at timestamptz default now(),
  unique (owner, kind),                  -- max 2 accounts per KYC: 1 personal + 1 business
  check (kind = 'personal' or gst is not null));

create table edits(
  id bigserial primary key,
  profile_id uuid references profiles on delete cascade,
  field text, old_v text, new_v text, at timestamptz default now());

create function is_admin() returns boolean language sql stable security definer set search_path=public as
$$ select exists(select 1 from admins where user_id = auth.uid()) $$;

create function guard() returns trigger language plpgsql security definer set search_path=public as $$
declare f text;
begin
  if tg_op = 'INSERT' then
    if not is_admin() then
      new.tick := case when new.kind='business' then 'biz' else 'common' end;
      new.verified := false; new.edits := 0;
    end if;
    return new;
  end if;
  if not is_admin() then
    new.owner := old.owner; new.kind := old.kind; new.tick := old.tick;
    new.verified := old.verified; new.edits := old.edits;
    if old.verified then            -- LOCK after verification
      new.name := old.name; new.founder := old.founder; new.est := old.est; new.gst := old.gst;
    end if;
  end if;
  foreach f in array array['address','product','vals','bio'] loop
    if to_jsonb(new)->>f is distinct from to_jsonb(old)->>f then
      insert into edits(profile_id, field, old_v, new_v) values (old.id, f, to_jsonb(old)->>f, to_jsonb(new)->>f);
      new.edits := new.edits + 1;
    end if;
  end loop;
  return new;
end $$;
create trigger profiles_guard before insert or update on profiles for each row execute function guard();

alter table admins enable row level security;
alter table kyc enable row level security;
alter table profiles enable row level security;
alter table edits enable row level security;

create policy a_sel on admins for select using (user_id = auth.uid());
create policy k_sel on kyc for select using (user_id = auth.uid() or is_admin());
create policy k_ins on kyc for insert with check (user_id = auth.uid() and status = 'pending');
create policy k_upd on kyc for update using (is_admin());
create policy k_del on kyc for delete using (user_id = auth.uid() and status = 'rejected');
create policy p_sel on profiles for select using (true);
create policy p_ins on profiles for insert with check (owner = auth.uid());
create policy p_upd on profiles for update using (owner = auth.uid() or is_admin());
create policy e_sel on edits for select using (true);

-- private storage for KYC documents
insert into storage.buckets (id, name, public) values ('kyc','kyc',false);
create policy s_ins on storage.objects for insert with check (bucket_id='kyc' and (storage.foldername(name))[1] = auth.uid()::text);
create policy s_sel on storage.objects for select using (bucket_id='kyc' and ((storage.foldername(name))[1] = auth.uid()::text or is_admin()));

-- AFTER you sign up on your site once, make yourself admin (change the email), run:
-- insert into admins select id from auth.users where email = 'YOUR_EMAIL@example.com';
