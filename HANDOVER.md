# SatyaPedia — Handover & Operations Guide
Keep this file in the GitHub repo. Give it to any developer you hire. (Prices/limits below can change — re-check each service's pricing page.)

## 1. What it is
India-first directory of KYC-verified public pages (people, businesses, leaders, creators). Hindi + English. Text-only pages (fast). Verified pages are indexed by Google; unverified pages work by link but are `noindex`.

## 2. Architecture
| Part | Tool | Files |
|---|---|---|
| Frontend app (login, dashboard, admin, home) | static HTML + JS | `index.html` |
| Public profile pages (SEO, server-rendered) | Vercel serverless | `api/profile.js` |
| Sitemap / robots | Vercel serverless | `api/sitemap.js`, `api/robots.js` |
| URL rules | Vercel | `vercel.json` (`/p/slug`, `/hi/p/slug`) |
| Legal pages | static | `privacy.html`, `terms.html`, `site-config.js` (edit email/officer/court here) |
| Database, login, ID-photo storage | Supabase | `schema.sql` → `schema5.sql` (run in order) |
| Code hosting + auto deploy | GitHub → Vercel | push to `main` = new deploy |

Supabase URL + **publishable** key are in `index.html` and `api/*.js` (safe to be public). **Never** put the secret key in any file.

## 3. Data model (Supabase)
`profiles` (public read), `kyc` (owner/admin only), `edits` (public edit log), `reports`, `admins`. Storage bucket `kyc` (private).
Rules enforced **in the database** (trigger `guard()` + RLS), not just the UI:
- 1 user: max 1 personal + 1 business profile; 1 GST = 1 business profile; 1 ID hash = 1 user.
- After verification: name, founder, est, gst are locked; slug/tick/verified/hidden changeable only by admin.
- Every change to address/product/values/bio/headline/city/website/links is logged in `edits` and counted.
- Unverified or `hidden` pages are `noindex` / 404 and excluded from sitemap.

## 4. Verification playbook (manual, admin panel)
Always: match name on document with profile name. Approve → page gets tick, goes public to Google. Photo is deleted after decision (`DELETE_DOCS=true` in `index.html`).
| Tick | Evidence to ask for |
|---|---|
| Common person | PAN/Aadhaar/Voter ID/Passport photo; name matches profile |
| Business | Owner ID + GST number checked on the GST portal's public "Search Taxpayer"; company: MCA master data |
| Government (in office) | Official gov.in / nic.in email OR official ID/appointment letter, AND the person listed on an official site (e.g. sansad.in, state assembly, ministry page) |
| Opposition | Same as above (elected, listed on official site with party) or letter on party letterhead + party's official page link |
| Celebrity | 3 independent reliable sources (news/Wikipedia) AND proof of control of their official social account (put a code we give in the bio) or an agency email |
Tick = factual status from official records, never SatyaPedia's opinion. If unsure → reject politely and ask for more proof. User's requested tick appears as "Claim" in admin; admin picks the final tick.

## 5. Categories (kept small on purpose)
~14 main categories (Politician, Business, Health, Legal/Finance, Education, Sports, Celebrity, Artist, Journalist, Tech, Trades & Services, Farmer, Student, NGO/Social, Other). Specific job (e.g. "Cardiologist", "Cricketer") goes in the free-text **headline**, which is shown on Google. Later: look at the most common headlines and promote them to new categories (data-driven), add `specialty` column + hub pages `/city/surat`, `/category/health`.

## 6. Deploy / rollback
Deploy: upload/commit files to GitHub `main` → Vercel auto-builds in ~1 min.
Rollback (if something breaks): Vercel → project → Deployments → pick last good one → ⋯ → **Promote to Production / Instant Rollback**. Fix calmly after.
DB changes: always run new `schemaN.sql` in Supabase SQL Editor **before** deploying code that needs it.

## 7. Backups (do this weekly until on a paid plan)
Free Supabase has **no automatic backups**. Weekly: Supabase → Table Editor → each table (`profiles`, `edits`, `kyc`, `reports`, `admins`) → Export CSV; save in a private drive folder. Supabase Pro ($25/mo approx.) adds daily backups — upgrade before real users arrive. GitHub already backs up the code.

## 8. Costs & limits (verify!)
- GitHub: free for this use.
- **Vercel Hobby (free) is for non-commercial use.** Once you charge for ticks, take donations or show ads, move to Vercel Pro (~$20/mo) or another host that allows commercial use on its free plan.
- **Supabase Free pauses a project after ~1 week of inactivity** and has small DB/storage limits. Pro ~$25/mo. Upgrade before launch/marketing.
- Domain: renewal price can differ from the first-year price. Turn on auto-renew and registrar 2FA.
Realistic serious-launch cost ≈ $45–50/month + domain.

## 9. Security checklist
- 2FA on GitHub, Vercel, Supabase, domain registrar and the admin email. Strong unique admin password.
- Rotate the Supabase **secret** key if it was ever shared (it was pasted in chat once).
- Supabase Auth: turn **Confirm email ON** before launch; add CAPTCHA (Cloudflare Turnstile) when spam appears.
- **Known weakness:** ID hash is plain SHA-256 computed in the browser. PAN/Aadhaar have small search spaces, so a leaked database could be brute-forced. Fix: move hashing to a Supabase Edge Function using HMAC with a secret pepper. Until then keep `kyc` table access strictly owner/admin (already RLS).
- Photos are deleted after review. If you keep them, you must secure and justify retention (DPDP Act).
- Get Privacy Policy/Terms reviewed by a lawyer; fill `site-config.js`.

## 10. Monitoring
UptimeRobot (free) pinging `/` and one `/p/...` URL with email alerts. Later: Sentry for errors. Vercel → Logs shows function errors; Supabase → Logs shows DB/API errors.

## 11. SEO strategy (realistic)
Do not aim to beat Wikipedia on its own name. Win queries Wikipedia does not answer: "verified [business/doctor/lawyer] in [city]", "is [name] genuine", Hindi queries, local search. Already done: server-rendered pages, unique title/description, JSON-LD (Person/Organization + sameAs), canonical, hreflang en/hi, sitemap, text-only speed. Next: Google Search Console + Bing Webmaster (covers Yahoo/DuckDuckGo), city/category hub pages, FAQ pages ("How to verify a business in India"), "Check if someone is verified" search, trust badge/QR for owners to embed (gives backlinks), 20+ fully filled founding-member pages.

## 12. Roadmap
**Now (before launch):** schema1–5 run; Confirm email ON; site-config.js filled; backups routine; uptime monitor; domain + Search Console; 10–20 founding members.
**Next (1–3 months):** payments (start with Razorpay Payment Links/UPI, admin sets tick; then Razorpay Checkout + webhook to set `tick`/expiry), donation/support page, phone OTP, QR code + embeddable "Verified on SatyaPedia" badge, hub pages, owner analytics, email notifications, moderator role, audit log, Hindi-slug transliteration.
**Later:** GST/PAN/DigiLocker verification APIs, more Indian languages, public API/data export, 2FA for users, ads (after traffic + policy pages), global launch.
Payments need a registered business (or proprietor) with a bank account and PAN for Razorpay; invoices/GST may apply — consult an accountant.

## 13. Admin runbook
- Make someone admin: `insert into admins select id from auth.users where email='x@y.com';`
- Unhide a page: `update profiles set hidden=false where slug='...';`
- Delete a user's data on request: delete from `auth.users` (cascades to kyc/profiles/edits).
- Locked field correction: `update profiles set name='...' where slug='...';` run as admin in SQL editor (trigger allows admin; logged manually).

## 14. Known limitations / tech debt
Single-file `index.html` app (fine now; split into components when a developer joins); no automated tests; manual KYC; Hindi names get `profile-xxxxxx` slugs; no OG share image; reports have no CAPTCHA/rate limit. Data is standard Postgres + plain JS, so any developer can take over or migrate.

## 15. Confirmed product policy (founder decisions)
- **Verification is free.** No one can buy a tick or a better review. Paid services (if any) are separate and never affect verification. Free and paid pages follow identical standards. ("Verification is free. Trust is never for sale.")
- **Profile deletion:** the owner can delete their own page any time (My Account → Delete this page). Deleting removes the page and its public history. Anyone else can send a "Removal request" through the report form.
- **Corrections:** owners edit non-locked fields themselves (logged publicly); locked facts change only after admin review. Any visitor can report an error or suggest a correction ("Report an error / suggest a correction"), reviewed by admin.
- **Scoped verification:** each verified page shows the date and exactly what the reviewer ticked (identity document / GST portal / official sources / owner KYC + admin page review) and what is not covered. Never tick a box that was not actually done. Public standards: `/verification`.
- **New pages always need admin review.** Even if the owner's KYC is already verified, a new page starts unverified and appears in Admin → "Pages awaiting review". Limitation: the ID photo is deleted after the first review, so for later pages the admin judges consistency with the verified identity (and checks GST on the portal). Consider storing a "verified legal name" field in a future version.
- **Commercial independence:** sponsored content labelled; no selling private identity data; no removing accurate facts for payment.
- **Out of scope for now:** jobs / funding / marriage ("Connect"), knowledge articles, places, products, photos, API, payments. Revisit only after trust operations are stable (scam and moderation risk).

Schema run order: schema.sql → schema2 → schema3 → schema4 → schema5 → schema6 → schema7 → schema8.
