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
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const serviceRoleKey2 = Deno.env.get('SERVICE_ROLE_KEY')!;

    const decodeRole = (token: string) => {
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        return payload.role;
      } catch (_e) {
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

    const { data: adminProfile, error: profileError } = await adminClient
      .from('user_profiles')
      .select('role')
      .eq('id', authData.user.id)
      .single();

    if (profileError || adminProfile?.role !== 'admin') {
      throw new Error('هذه العملية متاحة للمدير فقط.');
    }

    const body = await req.json();
    const userId = String(body.userId ?? '').trim();
    const email = String(body.email ?? '').trim().toLowerCase();
    const fullName = String(body.fullName ?? '').trim();
    const password = String(body.password ?? '');
    const role = String(body.role ?? 'staff');

    if (!userId) throw new Error('معرف المستخدم مطلوب.');
    if (!email) throw new Error('البريد الإلكتروني مطلوب.');
    if (!fullName) throw new Error('الاسم مطلوب.');
    if (password && password.length < 6) {
      throw new Error('كلمة المرور يجب ألا تقل عن 6 حروف.');
    }

    const allowedRoles = ['admin', 'staff', 'broker', 'cleaner', 'viewer'];
    if (!allowedRoles.includes(role)) {
      throw new Error('نوع المستخدم غير صحيح.');
    }

    const updateAttrs: any = {
      email,
      email_confirm: true,
      user_metadata: { full_name: fullName, role },
    };
    if (password) updateAttrs.password = password;

    const { error: updateError } = await adminClient.auth.admin.updateUserById(
      userId,
      updateAttrs,
    );
    if (updateError) throw updateError;

    const now = new Date().toISOString();
    const { data: existingProfile } = await adminClient
      .from('user_profiles')
      .select('created_at')
      .eq('id', userId)
      .maybeSingle();

    const profilePayload: Record<string, unknown> = {
      id: userId,
      email,
      full_name: fullName,
      role,
      updated_at: now,
    };
    if (!existingProfile) profilePayload.created_at = now;

    const { error: upsertError } = await adminClient
      .from('user_profiles')
      .upsert(profilePayload);
    if (upsertError) throw upsertError;

    return new Response(JSON.stringify({ ok: true, id: userId, email }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message ?? String(error) }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
