-- 10 — user_profiles.secondary_phone
--
-- Optional second contact number for brokers (and any user profile).
-- Additive, nullable; synced by the app alongside phone_number.

alter table public.user_profiles
  add column if not exists secondary_phone text;
