-- 11 — technicians.secondary_phone
--
-- Optional second contact number for technicians/workers.
-- Additive, nullable; synced by the app alongside phone.

alter table public.technicians
  add column if not exists secondary_phone text;
