-- 1. Create missing tables if they don't exist
CREATE TABLE IF NOT EXISTS public.technicians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    phone TEXT,
    specialty TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
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
    supply_id UUID NOT NULL REFERENCES public.cleaning_supplies(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL,
    quantity NUMERIC(10,2) NOT NULL,
    cost_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.apartment_inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID NOT NULL REFERENCES public.apartments(id) ON DELETE CASCADE,
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

-- 2. Add missing columns to existing tables
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS payment_method TEXT NOT NULL DEFAULT 'cash';
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS discount_egp NUMERIC(10,2) NOT NULL DEFAULT 0;
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS discount_reason TEXT;
ALTER TABLE public.expenses ADD COLUMN IF NOT EXISTS season TEXT NOT NULL DEFAULT 'all';

ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS contract_type TEXT NOT NULL DEFAULT 'student';
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS roommates TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS is_electricity_on_student BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS is_gas_on_student BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS is_water_on_student BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS national_id TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS id_front_image TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS id_back_image TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS contract_front_image TEXT;
ALTER TABLE public.winter_contracts ADD COLUMN IF NOT EXISTS contract_back_image TEXT;

ALTER TABLE public.winter_payments ADD COLUMN IF NOT EXISTS payment_method TEXT NOT NULL DEFAULT 'cash';

ALTER TABLE public.buildings ADD COLUMN IF NOT EXISTS annual_rent_egp NUMERIC(10,2) NOT NULL DEFAULT 0;
ALTER TABLE public.buildings ADD COLUMN IF NOT EXISTS rent_installments_dates TEXT;

ALTER TABLE public.apartments ADD COLUMN IF NOT EXISTS landline_number TEXT;
ALTER TABLE public.apartments ADD COLUMN IF NOT EXISTS landline_owner_name TEXT;
ALTER TABLE public.apartments ADD COLUMN IF NOT EXISTS landline_notes TEXT;

ALTER TABLE public.maintenance_requests ADD COLUMN IF NOT EXISTS technician_id UUID REFERENCES public.technicians(id) ON DELETE SET NULL;


-- 3. ENABLE REALTIME
-- Drop publication if exists and create for all tables
DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime FOR ALL TABLES;

-- Make sure all tables have REPLICA IDENTITY FULL so updates/deletes send full row data
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

-- 4. Enable RLS on new tables and add basic policies (Admins have access to all)
ALTER TABLE public.technicians ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cleaning_supplies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cleaning_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.apartment_inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins have full access to all" ON public.technicians FOR ALL USING (public.get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Admins have full access to all" ON public.cleaning_supplies FOR ALL USING (public.get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Admins have full access to all" ON public.cleaning_transactions FOR ALL USING (public.get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Admins have full access to all" ON public.apartment_inspections FOR ALL USING (public.get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Admins have full access to all" ON public.financial_transfers FOR ALL USING (public.get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Admins have full access to all" ON public.audit_logs FOR ALL USING (public.get_user_role() IN ('admin', 'staff'));

-- Trigger updated_at on new tables
CREATE TRIGGER update_cleaning_supplies_updated_at BEFORE UPDATE ON public.cleaning_supplies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_apartment_inspections_updated_at BEFORE UPDATE ON public.apartment_inspections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
