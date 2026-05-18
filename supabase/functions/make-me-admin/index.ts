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
    if (!authHeader) throw new Error('Unauthorized');

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    
    // Try both keys to see which one works
    let serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    let serviceRoleKey2 = Deno.env.get('SERVICE_ROLE_KEY')!;

    // Decode JWT to see the role
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
    else throw new Error(`لا يوجد مفتاح مدير صالح. Key1: ${role1}, Key2: ${role2}`);

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, finalKey);

    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) throw new Error('Unauthorized');

    const { error: updateError } = await adminClient
      .from('user_profiles')
      .upsert({ 
        id: authData.user.id, 
        email: authData.user.email ?? '', 
        role: 'admin', 
        updated_at: new Date().toISOString() 
      });

    if (updateError) throw updateError;

    return new Response(JSON.stringify({ success: true, message: 'You are now an admin' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message ?? String(error) }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
