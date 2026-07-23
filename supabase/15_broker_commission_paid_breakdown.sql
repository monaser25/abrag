-- 15_broker_commission_paid_breakdown.sql
-- Feature: record HOW a broker's commission was paid, split by method
-- (cash / vodafone_cash / instapay), including "part and part" splits.
--
-- Before this, the commission was always deducted from the booking's primary
-- payment method. These columns let the owner pay the broker via a different
-- channel than the guest's deposit (e.g. guest paid cash, broker took his cut
-- via Vodafone Cash), so each method's cash pool stays accurate.
--
-- Finance code deducts each method's commission from that method's pool; when
-- all three columns are 0 it falls back to the booking's primary payment method
-- (legacy behavior), so existing rows are unaffected.
--
-- Applied to the live "abrag" project (ref lxxmabivvucxkjktkipd) on 2026-07-23.

ALTER TABLE public.summer_bookings
  ADD COLUMN IF NOT EXISTS broker_commission_paid_cash_egp numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS broker_commission_paid_vodafone_egp numeric NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS broker_commission_paid_instapay_egp numeric NOT NULL DEFAULT 0;
