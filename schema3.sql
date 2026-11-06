-- Run once in Supabase > SQL Editor (lets admin delete ID photos after review)
create policy s_del on storage.objects for delete using (bucket_id='kyc' and is_admin());
