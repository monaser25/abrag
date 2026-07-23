-- 14_maintenance_reported_by_text.sql
-- Fix: sync of maintenance_requests always failed with
--   ERROR: invalid input syntax for type uuid: "<name>"   (POST .../maintenance_requests -> 400)
-- which aborted the whole client sync ("حدث خطأ").
--
-- Cause: the app stores `reported_by` as the free-text inspector/recipient name
-- (the inspection form field "اسم الفاحص / المُستلم"; local Drift column is text),
-- but the server column was uuid + FK to user_profiles, so every insert was rejected.
--
-- Table was empty (no maintenance request had ever synced), so widening is safe.
-- Also drops the redundant uuid-only insert policy ("reported_by = auth.uid()");
-- admins/staff already have full access via "Admins and Staff full access to maintenance".
-- Applied to the live "abrag" project (ref lxxmabivvucxkjktkipd) on 2026-07-14.

DROP POLICY IF EXISTS "Anyone can insert maintenance for their apartments"
  ON public.maintenance_requests;

ALTER TABLE public.maintenance_requests
  DROP CONSTRAINT IF EXISTS maintenance_requests_reported_by_fkey;

ALTER TABLE public.maintenance_requests
  ALTER COLUMN reported_by TYPE text USING reported_by::text;
