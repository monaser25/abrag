-- 1. Grant Schema Usage
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- 2. Grant Table Privileges
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- 3. Ensure your user is definitely an Admin
INSERT INTO public.user_profiles (id, email, role, created_at, updated_at)
SELECT id, email, 'admin'::user_role, NOW(), NOW()
FROM auth.users
WHERE email = 'mohamednaser2537@gmail.com'
ON CONFLICT (id) DO UPDATE
SET role = 'admin'::user_role, updated_at = NOW();

-- 4. Re-verify the get_user_role() function has SECURITY DEFINER 
-- This is critical so it can read user_profiles without hitting infinite recursion or RLS blocks
CREATE OR REPLACE FUNCTION public.get_user_role() RETURNS user_role AS $$
  SELECT role FROM public.user_profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- 5. Re-apply robust RLS Policies for Admin operations
-- Drop the existing policies just to be safe
DROP POLICY IF EXISTS "Admins and Staff have full access to buildings" ON public.buildings;
DROP POLICY IF EXISTS "Others can read buildings" ON public.buildings;
DROP POLICY IF EXISTS "Admins and Staff full access" ON public.apartments;

-- Recreate policies for buildings
CREATE POLICY "Admins and Staff have full access to buildings" 
ON public.buildings 
FOR ALL 
TO authenticated 
USING (public.get_user_role() IN ('admin', 'staff'))
WITH CHECK (public.get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Others can read buildings" 
ON public.buildings 
FOR SELECT 
TO authenticated 
USING (true);

-- Recreate policies for apartments
CREATE POLICY "Admins and Staff full access" 
ON public.apartments 
FOR ALL 
TO authenticated 
USING (public.get_user_role() IN ('admin', 'staff'))
WITH CHECK (public.get_user_role() IN ('admin', 'staff'));
