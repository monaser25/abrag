# إعداد إشعارات Firebase FCM مع Supabase

تم تجهيز التطبيق لاستقبال Push Notifications حتى لو التطبيق مقفول.

## المطلوب على Supabase مرة واحدة

1. افتح Supabase SQL Editor وشغّل الملف:

```sql
supabase/07_push_notifications_fcm.sql
```

2. انشر دالة Edge Function:

```bash
supabase functions deploy send-push-notification
```

3. أضف Secret باسم `FIREBASE_SERVICE_ACCOUNT_JSON` داخل Supabase Functions Secrets.

⚠️ لا تضع قيمة الـ JSON داخل كود Flutter أو داخل Git.

## بعد الإعداد

- التطبيق يسجل FCM token للمستخدم بعد تسجيل الدخول.
- عند إضافة/تعديل بيانات مهمة، Supabase يرسل Push Notification لموبايلات المديرين.
- الإشعار يصل حتى لو التطبيق مقفول تمامًا، بشرط أن صلاحية الإشعارات مفعلة على الموبايل.
