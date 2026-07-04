-- 13_viewer_read_bookings.sql
-- #20: let a read-only "general supervisor" (viewer role) open the smart agenda,
-- which shows all summer bookings. Additive read-only SELECT policies so the
-- viewer's device can pull the bookings + apartments the calendar needs.
-- Applied to the abrag project (ref lxxmabivvucxkjktkipd) on 2026-07-04.

CREATE POLICY "Viewers can view all summer bookings"
  ON public.summer_bookings FOR SELECT
  USING (public.get_user_role() = 'viewer'::public.user_role);

CREATE POLICY "Viewers can view all apartments"
  ON public.apartments FOR SELECT
  USING (public.get_user_role() = 'viewer'::public.user_role);
