# إعداد دوال إنشاء وحذف المستخدمين

المشكلة أن تطبيق Flutter لا يمكنه استخدام `service_role` مباشرة لأسباب أمان، لذلك إنشاء وحذف مستخدمي Supabase Auth يتم عبر Edge Functions آمنة.

## المطلوب مرة واحدة

من Supabase CLI أو Dashboard Functions انشر الدوال:

```bash
supabase functions deploy create-app-user
supabase functions deploy update-app-user
supabase functions deploy delete-app-user
```

ثم أضف Secret باسم:

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY
```

مكان المفتاح:
Supabase Dashboard → Project Settings → API → service_role key

⚠️ لا تضع هذا المفتاح داخل Flutter أو داخل `.env` الخاص بالتطبيق.

## بعد النشر

- إنشاء المستخدم من شاشة المستخدمين سيعمل كحساب Login فعلي.
- تعديل البريد الإلكتروني أو كلمة المرور أو الاسم يتم من خلال دالة `update-app-user`.
- الحساب الجديد لن يحتاج تأكيد إيميل لأن الدالة تنشئه `email_confirm: true`.
- حذف المستخدم سيحذف من Auth ومن جدول `user_profiles`.
