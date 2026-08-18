# Supabase feature-branch test

This branch is `feature/supabase-auth`. `main` has not been changed.

## What is in this branch

- `supabase-feature-test.html` — isolated test shell with email + 6-digit PIN auth, persistent Supabase session, Forgot PIN recovery, sign-out, and synchronization around the existing `index.html` UI.
- `supabase_schema.sql` — Postgres table plus Row Level Security policies.
- `index.html` — unchanged from the live branch in this feature test. It runs inside an iframe after authentication; the wrapper syncs its existing local data format to Supabase.

This deliberately isolates the first test from the production page instead of replacing `index.html` immediately.

## Supabase setup

1. Create a separate Supabase project for testing. Do not reuse a production database.
2. Open SQL Editor and run `supabase_schema.sql`.
3. In `supabase-feature-test.html`, replace:

```js
const SUPABASE_URL='https://YOUR-PROJECT.supabase.co';
const SUPABASE_PUBLISHABLE_KEY='YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY';
```

Use only the publishable/anon key in browser code. Never expose `service_role`.

4. Enable the Email provider in Supabase Authentication.
5. Configure email confirmation as desired for the test project.
6. Configure the password minimum so the requested 6-digit numeric PIN is accepted if your project currently requires a longer password.
7. Add the deployed feature-test URL to Authentication → URL Configuration → Redirect URLs. Forgot PIN uses Supabase's password-reset email flow.

## Test URL

If GitHub Pages is configured to deploy this branch, open:

`https://<your-pages-host>/supabase-feature-test.html`

The current production root `/index.html` is not replaced on `main`.

## Test checklist

1. Create User A with email + PIN.
2. Add applications.
3. Click Sync and refresh.
4. Open the feature page on another device/browser and sign in as User A.
5. Confirm the same applications appear.
6. Create User B and confirm User A's applications do not appear.
7. Try changing the browser's local data and sync again.
8. Test Forgot PIN and create a new PIN through the email link.
9. Sign out and confirm the ledger is inaccessible until signing in again.
10. Only after this passes should the Supabase persistence be integrated directly into the production `index.html` and merged into `main`.

## Security note

The 6-digit PIN is intentionally weak compared with a normal password. Supabase Auth still handles the credential and session; RLS is the database boundary that prevents one user's rows being returned to another user.
