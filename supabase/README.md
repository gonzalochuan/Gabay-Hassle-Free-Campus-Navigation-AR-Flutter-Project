# Supabase Edge Functions for Admin Actions

This folder contains the Edge Functions required by the app for admin actions:

- `admin_create_user` – Creates an auth user and inserts the corresponding row into `profiles`.
- `admin_delete_user` – Deletes the auth user by `user_id`.
- `admin_send_reset` – Sends a password recovery email.

## Prerequisites

- Supabase CLI installed.
- Access to your Supabase project.
- Set the service role key as a function secret. Never ship the service role to clients.

## Secrets

These functions expect the following environment variables (set per project):

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Set via CLI:

```bash
supabase secrets set SUPABASE_URL="https://<project-ref>.supabase.co"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="<service_role_key>"
```

Or via Dashboard > Project Settings > Functions.

## Deploy

From the repo root (where `supabase/` exists):

```bash
supabase functions deploy admin_create_user
supabase functions deploy admin_delete_user
supabase functions deploy admin_send_reset
```

Verify:

```bash
supabase functions list
```

## Test (optional)

```bash
curl -i -X POST \
  -H "Authorization: Bearer <ANON_OR_SERVICE_TOKEN_FOR_TESTING_ENDPOINT>" \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com"}' \
  https://<project-ref>.functions.supabase.co/admin_send_reset
```

## Notes

- The mobile app calls these functions through `AdminRepository` (see `lib/repositories/admin_repository.dart`).
- The app already deletes the `profiles` row after a successful auth delete, and will fall back to deleting just the profile row if the function is missing.
- Ensure RLS policies on `profiles` allow reads/updates for admins as needed.
