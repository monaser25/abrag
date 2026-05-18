-- =========================================================================
-- إعداد Supabase Storage لصور العقود والإيصالات
-- =========================================================================
-- شغّل هذا الملف مرة واحدة في Supabase SQL Editor.
-- يجعل bucket باسم abrag_storage متاحًا لرفع وقراءة صور العقود من كل الأجهزة.

INSERT INTO storage.buckets (id, name, public)
VALUES ('abrag_storage', 'abrag_storage', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Abrag authenticated users can upload files" ON storage.objects;
CREATE POLICY "Abrag authenticated users can upload files"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'abrag_storage');

DROP POLICY IF EXISTS "Abrag authenticated users can update files" ON storage.objects;
CREATE POLICY "Abrag authenticated users can update files"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'abrag_storage')
WITH CHECK (bucket_id = 'abrag_storage');

DROP POLICY IF EXISTS "Abrag authenticated users can read files" ON storage.objects;
CREATE POLICY "Abrag authenticated users can read files"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'abrag_storage');

DROP POLICY IF EXISTS "Abrag public can read files" ON storage.objects;
CREATE POLICY "Abrag public can read files"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'abrag_storage');
