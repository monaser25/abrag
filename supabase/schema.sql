-- Enums
CREATE TYPE user_role AS ENUM ('admin', 'staff', 'cleaner', 'broker', 'viewer');
CREATE TYPE season_type AS ENUM ('summer', 'winter');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled');
CREATE TYPE cleaning_status AS ENUM ('clean', 'needs_cleaning', 'cleaning_in_progress');
CREATE TYPE maintenance_status AS ENUM ('open', 'in_progress', 'resolved');

-- 1. Users and Roles (Extended from auth.users)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    phone_number TEXT,
    role user_role NOT NULL DEFAULT 'viewer',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Buildings and Apartments
CREATE TABLE public.buildings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    address TEXT,
    annual_rent_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    rent_installments_dates TEXT,
    total_apartments INT NOT NULL DEFAULT 15,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.apartments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID NOT NULL REFERENCES public.buildings(id) ON DELETE CASCADE,
    apartment_number TEXT NOT NULL,
    floor_number INT,
    cleaning_status TEXT NOT NULL DEFAULT 'clean',
    broker_visibility BOOLEAN NOT NULL DEFAULT FALSE,
    inventory TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Summer Bookings (Daily)
CREATE TABLE public.summer_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID NOT NULL REFERENCES public.apartments(id),
    guest_name TEXT NOT NULL,
    guest_phone TEXT,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    status booking_status NOT NULL DEFAULT 'pending',
    total_price_egp NUMERIC(10,2) NOT NULL,
    amount_paid_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    broker_id UUID REFERENCES public.user_profiles(id), -- Only if role is 'broker'
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

-- 4. Winter Contracts (Monthly/Students)
CREATE TABLE public.winter_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID NOT NULL REFERENCES public.apartments(id),
    student_name TEXT NOT NULL,
    university TEXT,
    parent_name TEXT,
    parent_phone TEXT,
    viewer_user_id UUID REFERENCES public.user_profiles(id), -- Parent/Viewer account
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    monthly_rent_egp NUMERIC(10,2) NOT NULL,
    deposit_egp NUMERIC(10,2) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.winter_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES public.winter_contracts(id) ON DELETE CASCADE,
    amount_egp NUMERIC(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    receipt_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Meter Readings & Utilities
CREATE TABLE public.meter_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID REFERENCES public.apartments(id), -- NULL means shared building meter
    building_id UUID REFERENCES public.buildings(id),
    reading_date DATE NOT NULL,
    previous_reading NUMERIC(10,2) NOT NULL,
    current_reading NUMERIC(10,2) NOT NULL,
    consumption NUMERIC(10,2) GENERATED ALWAYS AS (current_reading - previous_reading) STORED,
    amount_egp NUMERIC(10,2) NOT NULL,
    is_shared_expense BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Expenses and Maintenance
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID REFERENCES public.buildings(id),
    apartment_id UUID REFERENCES public.apartments(id), -- Optional, if specific to an apartment
    expense_type TEXT NOT NULL, -- e.g., 'building_rent', 'water', 'repairs'
    amount_egp NUMERIC(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    installment_number INT, -- For 4-installment building rent
    description TEXT,
    receipt_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.maintenance_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    apartment_id UUID NOT NULL REFERENCES public.apartments(id),
    reported_by UUID NOT NULL REFERENCES public.user_profiles(id),
    issue_description TEXT NOT NULL,
    status maintenance_status NOT NULL DEFAULT 'open',
    cost_egp NUMERIC(10,2) DEFAULT 0,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS POLICIES

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buildings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.apartments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.summer_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.winter_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.winter_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meter_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_requests ENABLE ROW LEVEL SECURITY;

-- Helper functions for RLS
CREATE OR REPLACE FUNCTION public.get_user_role() RETURNS user_role AS $$
  SELECT role FROM public.user_profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- 1. user_profiles Policies
CREATE POLICY "Admins have full access to profiles" ON public.user_profiles FOR ALL USING (get_user_role() = 'admin');
CREATE POLICY "Users can read their own profile" ON public.user_profiles FOR SELECT USING (id = auth.uid());

-- 2. buildings Policies
CREATE POLICY "Admins and Staff have full access to buildings" ON public.buildings FOR ALL USING (get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Others can read buildings" ON public.buildings FOR SELECT USING (true);

-- 3. apartments Policies
CREATE POLICY "Admins and Staff full access" ON public.apartments FOR ALL USING (get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Cleaners can view apartments to clean" ON public.apartments FOR SELECT USING (get_user_role() = 'cleaner');
CREATE POLICY "Cleaners can update cleaning status" ON public.apartments FOR UPDATE USING (get_user_role() = 'cleaner') WITH CHECK (get_user_role() = 'cleaner');
CREATE POLICY "Brokers can view visible apartments" ON public.apartments FOR SELECT USING (get_user_role() = 'broker' AND broker_visibility = true);
CREATE POLICY "Viewers can view their assigned winter apartments" ON public.apartments FOR SELECT USING (
    id IN (SELECT apartment_id FROM public.winter_contracts WHERE viewer_user_id = auth.uid())
);

-- 4. summer_bookings Policies
CREATE POLICY "Admins and Staff full access to summer bookings" ON public.summer_bookings FOR ALL USING (get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Brokers can see and create their own bookings" ON public.summer_bookings FOR ALL USING (get_user_role() = 'broker' AND broker_id = auth.uid());

-- 5. winter_contracts Policies
CREATE POLICY "Admins and Staff full access to winter contracts" ON public.winter_contracts FOR ALL USING (get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Viewers can see their own contracts" ON public.winter_contracts FOR SELECT USING (viewer_user_id = auth.uid());

-- 6. winter_payments Policies
CREATE POLICY "Admins and Staff full access to winter payments" ON public.winter_payments FOR ALL USING (get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Viewers can see their own payments" ON public.winter_payments FOR SELECT USING (
    contract_id IN (SELECT id FROM public.winter_contracts WHERE viewer_user_id = auth.uid())
);

-- 7. meter_readings Policies
CREATE POLICY "Admins and Staff full access to meters" ON public.meter_readings FOR ALL USING (get_user_role() IN ('admin', 'staff'));

-- 8. expenses Policies
CREATE POLICY "Admins full access to expenses" ON public.expenses FOR ALL USING (get_user_role() = 'admin');
CREATE POLICY "Staff can view expenses" ON public.expenses FOR SELECT USING (get_user_role() = 'staff');

-- 9. maintenance_requests Policies
CREATE POLICY "Admins and Staff full access to maintenance" ON public.maintenance_requests FOR ALL USING (get_user_role() IN ('admin', 'staff'));
CREATE POLICY "Cleaners can view maintenance" ON public.maintenance_requests FOR SELECT USING (get_user_role() = 'cleaner');
CREATE POLICY "Anyone can insert maintenance for their apartments" ON public.maintenance_requests FOR INSERT WITH CHECK (reported_by = auth.uid());

-- Functions & Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_apartments_updated_at BEFORE UPDATE ON public.apartments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_summer_bookings_updated_at BEFORE UPDATE ON public.summer_bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_winter_contracts_updated_at BEFORE UPDATE ON public.winter_contracts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_maintenance_requests_updated_at BEFORE UPDATE ON public.maintenance_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Offline Sync Metadata Table
-- Used for tracking deletions and sync timestamps for Drift
CREATE TABLE public.sync_metadata (
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    operation TEXT NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (table_name, record_id)
);
