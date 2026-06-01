-- Firebase Cloud Messaging device tokens for closed-app push notifications.
-- Run this once in Supabase SQL Editor before enabling push notifications.

CREATE TABLE IF NOT EXISTS public.device_tokens (
    token TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    platform TEXT NOT NULL DEFAULT 'android',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id
    ON public.device_tokens(user_id);

ALTER TABLE public.device_tokens REPLICA IDENTITY FULL;

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can upsert their own device tokens" ON public.device_tokens;
DROP POLICY IF EXISTS "Users can read their own device tokens" ON public.device_tokens;
DROP POLICY IF EXISTS "Users can insert their own device tokens" ON public.device_tokens;
DROP POLICY IF EXISTS "Users can update device tokens to their account" ON public.device_tokens;
DROP POLICY IF EXISTS "Users can delete their own device tokens" ON public.device_tokens;

CREATE POLICY "Users can read their own device tokens"
ON public.device_tokens
FOR SELECT
USING (auth.uid() = user_id OR public.get_user_role() = 'admin');

CREATE POLICY "Users can insert their own device tokens"
ON public.device_tokens
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update device tokens to their account"
ON public.device_tokens
FOR UPDATE
USING (true)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own device tokens"
ON public.device_tokens
FOR DELETE
USING (auth.uid() = user_id OR public.get_user_role() = 'admin');

GRANT SELECT, INSERT, UPDATE, DELETE ON public.device_tokens TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.device_tokens TO service_role;
