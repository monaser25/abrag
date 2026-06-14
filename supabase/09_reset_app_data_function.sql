-- 09 — reset_app_data()
--
-- Admin-only, atomic wipe of operational data used by the in-app
-- "مسح البيانات" (Data Management) action. Keeps user_profiles and auth
-- accounts so logins survive the reset.
--
-- Why a function instead of client-side deletes: every table's DELETE policy
-- requires get_user_role() = 'admin' (a few also allow 'staff'; expenses is
-- admin-only). A plain client `.delete()` run by a non-admin silently affects
-- 0 rows with no error. This SECURITY DEFINER function bypasses per-table RLS
-- but enforces an explicit admin guard, so the reset is all-or-nothing and
-- fails loudly for non-admins.

create or replace function public.reset_app_data()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if get_user_role() is distinct from 'admin'::user_role then
    raise exception 'only admins can reset app data';
  end if;

  -- FK-safe order: children before parents.
  delete from audit_logs;
  delete from maintenance_requests;
  delete from apartment_inspections;
  delete from cleaning_transactions;
  delete from cleaning_supplies;
  delete from technicians;
  delete from financial_transfers;
  delete from expenses;
  delete from meter_readings;
  delete from winter_payments;
  delete from winter_contracts;
  delete from summer_bookings;
  delete from apartments;
  delete from buildings;
end;
$$;

revoke all on function public.reset_app_data() from public, anon;
grant execute on function public.reset_app_data() to authenticated;
