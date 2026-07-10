// daily-checkout-reminders
// Scheduled (pg_cron) push reminder: every night at 21:00 Cairo time, send the
// admins a Firebase push listing the apartments whose summer-booking checkout is
// TOMORROW — so they know before the guests leave (checkout is usually 8 AM).
//
// Scheduling note (DST-proof): pg_cron fires this at 18:00 AND 19:00 UTC. Egypt is
// UTC+3 in summer (18:00 UTC = 21:00 Cairo) and UTC+2 in winter (19:00 UTC = 21:00
// Cairo), so exactly one of the two daily runs lands on 21:00 Cairo year-round; the
// other is gated out below. Pass ?force=1 to bypass the hour gate, ?dry=1 to compute
// the message without sending, and ?date=YYYY-MM-DD to target a specific Cairo day.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

const TZ = 'Africa/Cairo';
const REMINDER_HOUR = 21; // 9 PM Cairo, the night before checkout

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
  token_uri?: string;
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const dry = url.searchParams.get('dry') === '1';
    const force = url.searchParams.get('force') === '1';
    const dateOverride = url.searchParams.get('date'); // YYYY-MM-DD (Cairo day)

    const now = new Date();
    const cairoHour = Number(
      new Intl.DateTimeFormat('en-US', {
        timeZone: TZ,
        hour: '2-digit',
        hour12: false,
        hourCycle: 'h23',
      }).format(now),
    );

    // Only actually run at 21:00 Cairo (unless forced or a dry run).
    if (!dry && !force && cairoHour !== REMINDER_HOUR) {
      return json({ ok: true, skipped: true, cairoHour });
    }

    const targetDate = dateOverride ?? cairoDatePlusDays(now, 1); // tomorrow in Cairo

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ??
      Deno.env.get('SERVICE_ROLE_KEY');
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
    if (!serviceRoleKey) throw new Error('SUPABASE_SERVICE_ROLE_KEY غير موجود.');

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // Active summer bookings (exclude cancelled / already checked-out / deleted).
    // Note: `status` is the Postgres enum `booking_status`, which has no
    // 'deleted' value (deletes remove the row), so we only exclude the two
    // terminal states that exist remotely.
    const { data: bookings, error: bookingsError } = await adminClient
      .from('summer_bookings')
      .select('id, apartment_id, status, check_out_date, early_checkout_date')
      .not('status', 'in', '("cancelled","checked_out")');
    if (bookingsError) throw bookingsError;

    // Keep the ones whose effective checkout falls on the target Cairo day.
    const dueToday = (bookings ?? []).filter((b) => {
      const checkout = b.early_checkout_date ?? b.check_out_date;
      if (!checkout) return false;
      return cairoDay(new Date(checkout)) === targetDate;
    });

    if (dueToday.length === 0) {
      return json({ ok: true, sent: 0, targetDate, count: 0 });
    }

    // Map apartment ids -> apartment numbers for a readable message.
    const apartmentIds = [...new Set(dueToday.map((b) => b.apartment_id))];
    const { data: apartments, error: apartmentsError } = await adminClient
      .from('apartments')
      .select('id, apartment_number')
      .in('id', apartmentIds);
    if (apartmentsError) throw apartmentsError;
    const apartmentNumberById = new Map(
      (apartments ?? []).map((a) => [a.id as string, a.apartment_number]),
    );

    const numbers = dueToday
      .map(
        (b) => String(apartmentNumberById.get(b.apartment_id) ?? b.apartment_id),
      )
      .sort((a, b) => a.localeCompare(b, 'ar', { numeric: true }));

    const count = numbers.length;
    const title = `🔔 خروج بكرة — ${count} ${count === 1 ? 'شقة' : 'شقق'}`;
    const body = numbers.map((n) => `شقة ${n}`).join('   ·   ');
    const route = '/summer_bookings/calendar';

    if (dry) {
      return json({ ok: true, dry: true, targetDate, count, title, body });
    }

    if (!serviceAccountJson) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON غير موجود.');
    }

    // Recipients: every admin's registered device.
    const { data: admins, error: adminsError } = await adminClient
      .from('user_profiles')
      .select('id')
      .eq('role', 'admin');
    if (adminsError) throw adminsError;
    const adminIds = (admins ?? [])
      .map((a) => a.id as string)
      .filter(Boolean);
    if (adminIds.length === 0) {
      return json({ ok: true, sent: 0, reason: 'لا يوجد مدير لاستقبال الإشعار.' });
    }

    const { data: deviceTokens, error: tokensError } = await adminClient
      .from('device_tokens')
      .select('token')
      .in('user_id', adminIds);
    if (tokensError) throw tokensError;
    const tokens = [
      ...new Set(
        (deviceTokens ?? []).map((t) => t.token as string).filter(Boolean),
      ),
    ];
    if (tokens.length === 0) {
      return json({ ok: true, sent: 0, reason: 'لا توجد أجهزة مسجلة للمديرين.' });
    }

    const serviceAccount = JSON.parse(serviceAccountJson) as ServiceAccount;
    const accessToken = await getFirebaseAccessToken(serviceAccount);

    let sent = 0;
    const invalidTokens: string[] = [];
    for (const token of tokens) {
      const result = await sendFcmMessage({
        accessToken,
        projectId: serviceAccount.project_id,
        token,
        title,
        body,
        route,
      });
      if (result.ok) sent += 1;
      else if (result.invalidToken) invalidTokens.push(token);
    }
    if (invalidTokens.length > 0) {
      await adminClient.from('device_tokens').delete().in('token', invalidTokens);
    }

    return json({ ok: true, sent, count, targetDate, invalidTokens: invalidTokens.length });
  } catch (error) {
    return json({ error: (error as Error).message ?? String(error) }, 400);
  }
});

// ---- date helpers (all in Africa/Cairo) ----

function cairoDay(date: Date): string {
  // 'YYYY-MM-DD' for the given instant, in Cairo local time.
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: TZ,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date);
}

function cairoDatePlusDays(from: Date, days: number): string {
  const [y, m, d] = cairoDay(from).split('-').map(Number);
  const base = new Date(Date.UTC(y, m - 1, d));
  base.setUTCDate(base.getUTCDate() + days);
  return base.toISOString().slice(0, 10);
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

// ---- Firebase FCM (mirrors send-push-notification) ----

async function getFirebaseAccessToken(
  serviceAccount: ServiceAccount,
): Promise<string> {
  const tokenUri = serviceAccount.token_uri ?? 'https://oauth2.googleapis.com/token';
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: tokenUri,
    iat: now,
    exp: now + 3600,
  };
  const unsignedJwt = `${base64UrlJson(header)}.${base64UrlJson(payload)}`;
  const signature = await signJwt(unsignedJwt, serviceAccount.private_key);
  const assertion = `${unsignedJwt}.${signature}`;

  const response = await fetch(tokenUri, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  const body = await response.json();
  if (!response.ok) {
    throw new Error(`Firebase OAuth failed: ${JSON.stringify(body)}`);
  }
  return body.access_token as string;
}

async function sendFcmMessage({
  accessToken,
  projectId,
  token,
  title,
  body,
  route,
}: {
  accessToken: string;
  projectId: string;
  token: string;
  title: string;
  body: string;
  route: string;
}): Promise<{ ok: boolean; invalidToken: boolean }> {
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: { route },
          android: {
            priority: 'HIGH',
            notification: { channel_id: 'abrag_push_channel', sound: 'default' },
          },
          apns: { payload: { aps: { sound: 'default' } } },
        },
      }),
    },
  );
  if (response.ok) return { ok: true, invalidToken: false };
  const errorBody = await response.text();
  const invalidToken = errorBody.includes('UNREGISTERED') ||
    errorBody.includes('INVALID_ARGUMENT');
  return { ok: false, invalidToken };
}

async function signJwt(
  unsignedJwt: string,
  privateKeyPem: string,
): Promise<string> {
  const pemContents = privateKeyPem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replaceAll('\n', '')
    .trim();
  const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey.buffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(unsignedJwt),
  );
  return base64UrlBytes(new Uint8Array(signature));
}

function base64UrlJson(value: unknown): string {
  return base64UrlBytes(new TextEncoder().encode(JSON.stringify(value)));
}

function base64UrlBytes(bytes: Uint8Array): string {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
}
