import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) throw new Error('غير مصرح. سجل دخول كمدير أولًا.');

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    let serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    let serviceRoleKey2 = Deno.env.get('SERVICE_ROLE_KEY')!;

    const decodeRole = (token: string) => {
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        return payload.role;
      } catch (e) {
        return 'invalid';
      }
    };

    const role1 = decodeRole(serviceRoleKey);
    const role2 = decodeRole(serviceRoleKey2);

    let finalKey = serviceRoleKey;
    if (role2 === 'service_role') finalKey = serviceRoleKey2;
    else if (role1 === 'service_role') finalKey = serviceRoleKey;
    else throw new Error('مفتاح السيرفر (SUPABASE_SERVICE_ROLE_KEY) غير صحيح. يرجى التأكد من نسخة من إعدادات Supabase.');

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, finalKey);

    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) throw new Error('غير مصرح.');

    const { data: profile, error: profileError } = await adminClient
      .from('user_profiles')
      .select('role')
      .eq('id', authData.user.id)
      .single();

    if (profileError || profile?.role !== 'admin') {
      throw new Error('هذه العملية متاحة للمدير فقط.');
    }

    const body = await req.json();
    const email = String(body.email ?? '').trim().toLowerCase();
    const password = String(body.password ?? '');
    const fullName = String(body.fullName ?? '').trim();
    const role = String(body.role ?? 'staff');

    if (!email || password.length < 6) {
      throw new Error('البريد مطلوب وكلمة المرور يجب ألا تقل عن 6 حروف.');
    }

    const { data: created, error: createError } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: fullName, role },
    });

    if (createError) throw createError;
    const user = created.user;
    if (!user) throw new Error('لم يتم إنشاء المستخدم.');

    const { error: upsertError } = await adminClient.from('user_profiles').upsert({
      id: user.id,
      email,
      full_name: fullName,
      role,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
    if (upsertError) throw upsertError;

    return new Response(JSON.stringify({ id: user.id, email }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message ?? String(error) }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
