-- =========================================================================
-- إصلاح إنشاء المستخدمين وتزامنهم مع جدول user_profiles
-- =========================================================================
-- شغّل هذا الملف مرة واحدة من Supabase SQL Editor.
-- الهدف:
-- 1) أي مستخدم جديد في Supabase Auth يتضاف تلقائيًا في user_profiles.
-- 2) إزالة أي سجلات محلية/قديمة بمعرّف غير UUID قد تسبب sync failed.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'staff'),
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- تنظيف احترازي لو كان جدول user_profiles اتعمل بدون UUID constraint في نسخة قديمة.
DELETE FROM public.user_profiles
WHERE id::text LIKE 'pending-user-%';
