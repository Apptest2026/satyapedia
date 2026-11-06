-- Run once in Supabase > SQL Editor (after schema4.sql)
alter table kyc add column claim text check (claim in ('common','gov','opp','celeb'));
alter table kyc add column proof text check (char_length(proof)<=1000);
