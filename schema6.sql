-- Run once in Supabase > SQL Editor (safe to run even if parts exist)
alter table profiles add column if not exists website text, add column if not exists links text, add column if not exists hidden boolean not null default false;

alter table profiles drop constraint if exists len_ok;
alter table profiles add constraint len_ok check (
  char_length(name)<=120 and char_length(coalesce(headline,''))<=160 and char_length(coalesce(bio,''))<=5000 and
  char_length(coalesce(address,''))<=300 and char_length(coalesce(product,''))<=2000 and char_length(coalesce(vals,''))<=2000) not valid;

alter table profiles drop constraint if exists url_ok;
alter table profiles add constraint url_ok check (
  (website is null or (website ~* '^https?://[^ ]+$' and char_length(website)<=200)) and char_length(coalesce(links,''))<=1200) not valid;
