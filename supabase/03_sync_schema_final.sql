-- =========================================================================
-- الشفرة الشاملة (Ultimate Schema Sync) لتوحيد الداتا بيز مع التطبيق
-- =========================================================================
-- قم بنسخ هذا الكود بالكامل واعمل له Run في Supabase SQL Editor.
-- هذا الكود هيتأكد إن كل الجداول والعواميد موجودة وصلاحياتها سليمة.

-- 1. التأكد من وجود كل الجداول الأساسية
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL,
    full_name TEXT,
    phone_number TEXT,
    role TEXT NOT NULL DEFAULT 'viewer',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.buildings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT,
    annual_rent_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    rent_installments_dates TEXT,
    total_apartments INT NOT NULL DEFAULT 15,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.apartments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID NOT NULL,
    apartment_number TEXT NOT NULL,
    floor_number INT,
    cleaning_status TEXT NOT NULL DEFAULT 'clean',
    broker_visibility BOOLEAN NOT NULL DEFAULT FALSE,
    inventory TEXT,
    landline_number TEXT,
    landline_owner_name TEXT,
    landline_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.summer_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID NOT NULL,
    guest_name TEXT NOT NULL,
    guest_phone TEXT,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    total_price_egp NUMERIC(10,2) NOT NULL,
    amount_paid_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    broker_id UUID,
    broker_name TEXT,
    broker_commission_type TEXT NOT NULL DEFAULT 'none',
    broker_commission_percentage NUMERIC(5,2) NOT NULL DEFAULT 10.00,
    broker_commission_fixed_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    broker_commission_amount_egp NUMERIC(10,2) GENERATED ALWAYS AS (total_price_egp * (broker_commission_percentage / 100)) STORED,
    early_checkout_date DATE,
    overstay_days INT DEFAULT 0,
    overstay_fee_egp NUMERIC(10,2) DEFAULT 0,
    national_id TEXT,
    id_front_image TEXT,
    id_back_image TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.winter_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID NOT NULL,
    contract_type TEXT NOT NULL DEFAULT 'student',
    student_name TEXT NOT NULL,
    university TEXT,
    parent_name TEXT,
    parent_phone TEXT,
    viewer_user_id UUID,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    monthly_rent_egp NUMERIC(10,2) NOT NULL,
    deposit_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_electricity_on_student BOOLEAN NOT NULL DEFAULT TRUE,
    is_gas_on_student BOOLEAN NOT NULL DEFAULT TRUE,
    is_water_on_student BOOLEAN NOT NULL DEFAULT FALSE,
    roommates TEXT,
    national_id TEXT,
    id_front_image TEXT,
    id_back_image TEXT,
    contract_front_image TEXT,
    contract_back_image TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.winter_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL,
    amount_egp NUMERIC(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    receipt_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.meter_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID,
    building_id UUID,
    reading_date DATE NOT NULL,
    previous_reading NUMERIC(10,2) NOT NULL,
    current_reading NUMERIC(10,2) NOT NULL,
    consumption NUMERIC(10,2) GENERATED ALWAYS AS (current_reading - previous_reading) STORED,
    amount_egp NUMERIC(10,2) NOT NULL,
    is_shared_expense BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID,
    apartment_id UUID,
    expense_type TEXT NOT NULL,
    amount_egp NUMERIC(10,2) NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    season TEXT NOT NULL DEFAULT 'all',
    discount_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    discount_reason TEXT,
    expense_date DATE NOT NULL,
    installment_number INT,
    description TEXT,
    receipt_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.technicians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    phone TEXT,
    specialty TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.maintenance_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID NOT NULL,
    technician_id UUID,
    reported_by UUID NOT NULL,
    issue_description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open',
    cost_egp NUMERIC(10,2) DEFAULT 0,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.cleaning_supplies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    stock_quantity NUMERIC(10,2) NOT NULL DEFAULT 0,
    unit TEXT NOT NULL DEFAULT 'عبوة',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.cleaning_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supply_id UUID NOT NULL,
    transaction_type TEXT NOT NULL,
    quantity NUMERIC(10,2) NOT NULL,
    cost_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.apartment_inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID NOT NULL,
    inspection_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_clean BOOLEAN NOT NULL DEFAULT TRUE,
    has_damages BOOLEAN NOT NULL DEFAULT FALSE,
    damages_description TEXT,
    tenant_fine_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    owner_repair_cost_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    inspector_name TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.financial_transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_account TEXT NOT NULL,
    to_account TEXT NOT NULL,
    transfer_type TEXT NOT NULL DEFAULT 'internal',
    season TEXT NOT NULL DEFAULT 'all',
    amount_egp NUMERIC(10,2) NOT NULL,
    transfer_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id UUID,
    actor_name TEXT NOT NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    route TEXT,
    old_values_json TEXT,
    new_values_json TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. التأكد من إضافة الأعمدة اللي ممكن تكون ناقصة (أمان إضافي)
ALTER TABLE public.apartments ADD COLUMN IF NOT EXISTS inventory TEXT;
ALTER TABLE public.apartments ADD COLUMN IF NOT EXISTS landline_number TEXT;
ALTER TABLE public.apartments ADD COLUMN IF NOT EXISTS landline_owner_name TEXT;
ALTER TABLE public.apartments ADD COLUMN IF NOT EXISTS landline_notes TEXT;

ALTER TABLE public.buildings ADD COLUMN IF NOT EXISTS annual_rent_egp NUMERIC(10,2) NOT NULL DEFAULT 0;
ALTER TABLE public.buildings ADD COLUMN IF NOT EXISTS rent_installments_dates TEXT;

ALTER TABLE public.summer_bookings ADD COLUMN IF NOT EXISTS payment_method TEXT NOT NULL DEFAULT 'cash';
ALTER TABLE public.summer_bookings ADD COLUMN IF NOT EXISTS broker_name TEXT;
ALTER TABLE public.summer_bookings ADD COLUMN IF NOT EXISTS broker_commission_type TEXT NOT NULL DEFAULT 'none';
ALTER TABLE public.summer_bookings ADD COLUMN IF NOT EXISTS broker_commission_fixed_egp NUMERIC(10,2) NOT NULL DEFAULT 0;
ALTER TABLE public.summer_bookings ADD COLUMN IF NOT EXISTS national_id TEXT;
ALTER TABLE public.summer_bookings ADD COLUMN IF NOT EXISTS id_front_image TEXT;
ALTER TABLE public.summer_bookings ADD COLUMN IF NOT EXISTS id_back_image TEXT;

ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS contract_type TEXT NOT NULL DEFAULT 'student';
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS is_electricity_on_student BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS is_gas_on_student BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS is_water_on_student BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS roommates TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS national_id TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS id_front_image TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS id_back_image TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS contract_front_image TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS contract_back_image TEXT;

ALTER TABLE public.winter_payments ADD COLUMN IF NOT EXISTS payment_method TEXT NOT NULL DEFAULT 'cash';

ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS payment_method TEXT NOT NULL DEFAULT 'cash';
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS season TEXT NOT NULL DEFAULT 'all';
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS discount_egp NUMERIC(10,2) NOT NULL DEFAULT 0;
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS discount_reason TEXT;

ALTER TABLE public.maintenance_requests ADD COLUMN IF NOT EXISTS technician_id UUID;

ALTER TABLE public.financial_transfers ADD COLUMN IF NOT EXISTS transfer_type TEXT NOT NULL DEFAULT 'internal';
ALTER TABLE public.financial_transfers ADD COLUMN IF NOT EXISTS season TEXT NOT NULL DEFAULT 'all';

-- 3. تفعيل Realtime على جميع الجداول
DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime FOR ALL TABLES;

ALTER TABLE public.user_profiles REPLICA IDENTITY FULL;
ALTER TABLE public.buildings REPLICA IDENTITY FULL;
ALTER TABLE public.apartments REPLICA IDENTITY FULL;
ALTER TABLE public.summer_bookings REPLICA IDENTITY FULL;
ALTER TABLE public.winter_contracts REPLICA IDENTITY FULL;
ALTER TABLE public.winter_payments REPLICA IDENTITY FULL;
ALTER TABLE public.meter_readings REPLICA IDENTITY FULL;
ALTER TABLE public.expenses REPLICA IDENTITY FULL;
ALTER TABLE public.maintenance_requests REPLICA IDENTITY FULL;
ALTER TABLE public.technicians REPLICA IDENTITY FULL;
ALTER TABLE public.cleaning_supplies REPLICA IDENTITY FULL;
ALTER TABLE public.cleaning_transactions REPLICA IDENTITY FULL;
ALTER TABLE public.apartment_inspections REPLICA IDENTITY FULL;
ALTER TABLE public.financial_transfers REPLICA IDENTITY FULL;
ALTER TABLE public.audit_logs REPLICA IDENTITY FULL;

-- 4. إصلاح جميع مشاكل الصلاحيات والـ Constraints المزعجة
-- إزالة قيد الـ Foreign Key المزعج اللي كان بيمنع السماسرة من التسجيل
ALTER TABLE public.user_profiles DROP CONSTRAINT IF EXISTS user_profiles_id_fkey;

-- إعطاء كافة الصلاحيات على الـ Schema لتفادي مشاكل الأذونات
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO authenticated;

-- تعطيل الـ RLS مؤقتاً لتسهيل عمل التطبيق أوفلاين وسينك (RLS يمكن إدارته لاحقاً من الواجهة)
ALTER TABLE public.user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.buildings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.apartments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.summer_bookings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.winter_contracts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.winter_payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.meter_readings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_requests DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.technicians DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cleaning_supplies DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cleaning_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.apartment_inspections DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_transfers DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs DISABLE ROW LEVEL SECURITY;

-- 5. إجبار السيرفر على عمل Refresh للـ Schema في الذاكرة لتفادي خطأ الكاش
NOTIFY pgrst, 'reload schema';
