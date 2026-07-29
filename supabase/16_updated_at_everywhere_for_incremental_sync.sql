-- 16_updated_at_everywhere_for_incremental_sync.sql
-- Prerequisite for incremental sync (performance work).
--
-- Problem: the client pulled EVERY row of EVERY table every 15 seconds. To pull
-- only what changed, each table needs a reliable `updated_at`. 9 of the 16
-- synced tables had only `created_at` (audit_logs, booking_payments, buildings,
-- cleaning_transactions, expenses, financial_transfers, meter_readings,
-- technicians, winter_payments). Filtering those on `created_at` would have
-- silently dropped EDITS -- e.g. correcting an expense amount would never reach
-- another device. That is unacceptable in a financial app.
--
-- Fix: add `updated_at` where missing (backfilled from created_at), and stamp it
-- from a BEFORE UPDATE trigger so the SERVER owns the value regardless of what
-- any client sends. Indexed because every incremental pull filters on it.
--
-- Applied to the live "abrag" project (ref lxxmabivvucxkjktkipd) on 2026-07-29.

-- 1. Add the column where missing, backfilled from created_at.
ALTER TABLE public.audit_logs            ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE public.booking_payments      ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE public.buildings             ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE public.cleaning_transactions ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE public.expenses              ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE public.financial_transfers   ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE public.meter_readings        ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE public.technicians           ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE public.winter_payments       ADD COLUMN IF NOT EXISTS updated_at timestamptz;

UPDATE public.audit_logs            SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;
UPDATE public.booking_payments      SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;
UPDATE public.buildings             SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;
UPDATE public.cleaning_transactions SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;
UPDATE public.expenses              SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;
UPDATE public.financial_transfers   SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;
UPDATE public.meter_readings        SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;
UPDATE public.technicians           SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;
UPDATE public.winter_payments       SET updated_at = COALESCE(updated_at, created_at, now()) WHERE updated_at IS NULL;

ALTER TABLE public.audit_logs            ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE public.booking_payments      ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE public.buildings             ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE public.cleaning_transactions ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE public.expenses              ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE public.financial_transfers   ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE public.meter_readings        ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE public.technicians           ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE public.winter_payments       ALTER COLUMN updated_at SET DEFAULT now(), ALTER COLUMN updated_at SET NOT NULL;

-- 2. Server-maintained freshness: stamp updated_at on every UPDATE.
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'user_profiles','buildings','apartments','summer_bookings','winter_contracts',
    'winter_payments','booking_payments','meter_readings','expenses',
    'financial_transfers','technicians','cleaning_supplies','cleaning_transactions',
    'apartment_inspections','maintenance_requests','audit_logs'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_set_updated_at ON public.%I', t);
    EXECUTE format(
      'CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.%I
         FOR EACH ROW EXECUTE FUNCTION public.set_updated_at()', t);
  END LOOP;
END $$;

-- 3. Index the column every incremental pull filters on.
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'user_profiles','buildings','apartments','summer_bookings','winter_contracts',
    'winter_payments','booking_payments','meter_readings','expenses',
    'financial_transfers','technicians','cleaning_supplies','cleaning_transactions',
    'apartment_inspections','maintenance_requests','audit_logs'
  ]
  LOOP
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON public.%I (updated_at)',
      t || '_updated_at_idx', t);
  END LOOP;
END $$;
