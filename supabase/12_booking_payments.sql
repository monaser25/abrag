-- 12_booking_payments.sql
-- Per-payment breakdown for summer bookings: split payment methods on a booking
-- (#3) and settling the remaining balance with a chosen method (#18).
-- Additive only: creates a new table, does not touch existing tables/data.
-- Applied to the live "abrag" project (ref lxxmabivvucxkjktkipd) on 2026-07-04.

CREATE TABLE IF NOT EXISTS public.booking_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL,
    amount_egp NUMERIC(10, 2) NOT NULL DEFAULT 0,
    payment_method TEXT NOT NULL DEFAULT 'cash', -- cash, vodafone_cash, instapay
    payment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Full-row replication for realtime UPDATE/DELETE events (supabase_realtime
-- publication is already FOR ALL TABLES, so the table is auto-included).
ALTER TABLE public.booking_payments REPLICA IDENTITY FULL;

-- Protect the table like every other synced table: RLS on, admin/staff full access
-- (matches the "Admins and Staff full access to winter payments" policy).
ALTER TABLE public.booking_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins and Staff full access to booking payments"
  ON public.booking_payments
  FOR ALL
  USING (public.get_user_role() = ANY (ARRAY['admin'::public.user_role, 'staff'::public.user_role]));

-- Base table privileges. RLS controls ROW access, but the role still needs the
-- table-level GRANT, or PostgREST (as `authenticated`) gets
-- "permission denied for table booking_payments" and EVERY client sync fails on
-- this table (push aborts before pull, so nothing syncs at all). apply_migration
-- does NOT auto-grant these, so grant them explicitly to match the sibling
-- synced tables (e.g. winter_payments). Applied to the live project 2026-07-04.
GRANT ALL ON TABLE public.booking_payments TO anon, authenticated, service_role;
