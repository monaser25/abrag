-- 17_harden_function_search_path.sql
-- تحذير أمني من Supabase advisors: الدوال دي كانت من غير search_path مثبّت.
-- من غير التثبيت، حد يقدر يغيّر search_path فتنادي الدالة (وهي SECURITY DEFINER)
-- جدول أو دالة مزيفة بدل بتاعت public. الجسم نفسه ما اتغيّرش خالص.
--
-- اتطبّق على مشروع "abrag" اللايف (ref lxxmabivvucxkjktkipd) يوم 2026-08-08،
-- واتأكدنا بعدها إن trigger الـ updated_at لسه شغال.
--
-- ملحوظة مقصودة: EXECUTE على get_user_role() سايبينه زي ما هو لأن سياسات
-- الـ RLS نفسها بتناديها — لو اتسحبت الصلاحية دي، كل قراءة من أي جدول هتفشل.

CREATE OR REPLACE FUNCTION public.get_user_role()
 RETURNS user_role
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path = public, pg_temp
AS $function$
  SELECT role FROM public.user_profiles WHERE id = auth.uid();
$function$;

CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path = public, pg_temp
AS $function$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path = public, pg_temp
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$;
