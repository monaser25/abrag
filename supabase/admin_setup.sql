-- SUPABASE ADMIN SETUP SNIPPET
-- Run this in the Supabase SQL Editor to grant yourself the 'admin' role.
-- Replace 'YOUR_EMAIL@EXAMPLE.COM' with the email you signed up with.

INSERT INTO public.user_profiles (id, email, role, created_at, updated_at)
SELECT id, email, 'admin'::user_role, NOW(), NOW()
FROM auth.users
WHERE email = 'YOUR_EMAIL@EXAMPLE.COM'
ON CONFLICT (id) DO UPDATE
SET role = 'admin'::user_role, updated_at = NOW();


-- Optional: Trigger to automatically create profiles for new sign-ups
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, role)
  VALUES (new.id, new.email, 'viewer'::user_role); -- Default role
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
