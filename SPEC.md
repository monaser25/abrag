---
description: Project specification and single source of truth for this Flutter application
mode: memory
---

# SPEC.md — Project Specification

> This file is the single source of truth for this project.
> All agents must read this file before making any architectural decision.
> Never contradict this file without explicit user confirmation.

---

## App Identity

**App Name:** Abrag
**App Category:** SaaS / Dashboard / Property Management
**Platform:** Mobile (iOS/Android) + Web UI (Simplified views for certain roles)
**Target Users:** 
- Admin (Full access)
- Staff (Limited management access)
- Cleaner (Simplified Web UI)
- Broker (Simplified Web UI with Admin-controlled visibility)
- Viewer / Parent (Read-only Web UI)
**Core Purpose:** Comprehensive, offline-first real estate management application designed for a 15-apartment residential building supporting dual seasonal business models.
**App Language:** Arabic
**RTL Layout:** yes — required for Arabic

---

## UI Assets

**App Icon:** ✅ provided
**Feature Graphic:** ⬜ not provided
**Exported UI Screens:** ⬜ none

---

## Core Features

1. **Dual-Season Booking System:** Summer (daily, cash only, 7 AM checkout, early checkout/overstay rules) and Winter (monthly student rentals).
2. **Financial & Utility Management:** Individual electricity meters, shared building utilities (water/electricity), expenses tracking, and 4-installment building rent.
3. **Broker Management System:** Commission tracking (10% default), Admin-controlled visibility of available apartments.
4. **Operational Management:** Cleaning status, maintenance requests, global search, and calendar views.
5. **Advanced Reporting:** Annual comparisons, PDF statement exports, winter payment history.

---

## Backend

**Selected Backend:** Supabase
**Reason:** PostgreSQL with strict Row Level Security (RBAC), Storage for PDFs/receipts, Realtime for booking updates, offline sync capabilities.

**Services Used:**
- Auth: yes (Email/Password with strict RBAC)
- Database: yes (PostgreSQL)
- Storage: yes (PDFs/receipts)
- Realtime: yes (booking updates)

---

## Required Credentials

| Key | Status | Where to Get |
|---|---|---|
| SUPABASE_URL | ✅ provided | supabase.com → Project Settings → API |
| SUPABASE_ANON_KEY | ✅ provided | supabase.com → Project Settings → API → anon key |
| FIREBASE_PROJECT_ID | ✅ provided | Firebase Console → Project Settings |
| FIREBASE_SERVICE_ACCOUNT_JSON | ✅ provided | Firebase Console → Project Settings → Service accounts |

---

## Architecture Decisions

**State Management:** Riverpod
**Navigation:** GoRouter
**HTTP Client:** Dio / Supabase SDK
**Serialization:** json_serializable + freezed
**Local Storage:** Drift (SQLite) for strict offline-first architecture
**Secure Storage:** flutter_secure_storage
**Testing:** flutter_test + mocktail

---

## UI/UX Requirements

**Design Style:** Professional Dashboard
**Theme:** Navy Background (#0D1B2A), Gold Primary (#F4A225), Card (#1B263B)
**Font:** IBM Plex Sans Arabic
**Currency/Region:** EGP (ج.م) | Country Code: +20
**Dark Mode:** required
**RTL Support:** required
**Responsive:** mobile-first, tablet-aware, specific Web UIs

---

## App Screens

1. Login / Splash Screen
2. Admin Dashboard (Overview, Quick Actions)
3. Calendar / Booking View
4. Financials / Utility Management
5. Broker / Commission Panel
6. Operations (Cleaning / Maintenance)
7. Reports & Exports

---

## Quality Gates

- [ ] flutter analyze → zero warnings
- [ ] All features handle: loading, error, empty, offline states
- [ ] Responsive on mobile, tablet, and specific web views
- [ ] RTL layout verified
- [ ] Offline-first architecture strictly enforced (Drift + Supabase Sync)
- [ ] Supabase conflict detection surfaced to Admin

---

## Known Constraints

- Strict offline-first architecture required. App must function entirely offline and sync with Supabase upon reconnection.
- Strict Role-Based Access Control (RBAC) mapped to 5 user types via Supabase RLS.

---

## Implementation Progress

| Stage | Status | Agent | Notes |
|---|---|---|---|
| Spec Creation | ✅ done | orchestrator | Specifics added for Abrag |
| Database Bootstrap | ✅ done | backend-platform-specialist | Generated Supabase SQL schema |
| Bootstrap | ✅ done | bootstrap-agent | Initialized Flutter project and connected Supabase |
| Design System | ✅ done | flutter-design-system | Configured typography, color tokens, and global theme |
| Auth | ✅ done | flutter-auto | Implemented Login screen, Supabase integration, GoRouter redirects |
| Localization | ✅ done | flutter-auto | Added English support (i18n) via flutter_localizations |
| Database Sync & Drift Setup | ✅ done | flutter-auto | Established SQLite local architecture mapped to Supabase models |
| Core Features | ✅ done | flutter-auto | Implemented Bookings & Contracts UI, Financials & Operations Domain, Reports & PDF Domain, Role-Specific Web Views & Permissions Domain |
| Form Validation | ✅ done | flutter-auto | Implemented Business Logic Forms with Offline Insert |
| Quality Gates | ✅ done | flutter-testing | Wrote Unit and Widget Tests, all passing |
| Testing | ✅ done | flutter-testing | Completed |
| Play Store Prep | ✅ done | flutter-release | Configured Android permissions. Awaiting final assets and signing. |

---

## Remaining Phases (45 Screens Target)

| Phase | Status | Agent | Notes |
|---|---|---|---|
| Phase 1: Structural Screens | ✅ done | flutter-auto | Splash, Forgot Password, Onboarding, Global Search |
| Phase 2: Booking Details & Lifecycle | ✅ done | flutter-auto | Booking Details + Checkout, Early Checkout + Refund, Overstay/Extension, Guest Profile |
| Phase 3: Apartment & Building Lifecycle | ✅ done | flutter-auto | Apartment Management, Apartment Profile |
| Phase 4: Administrative Settings | ✅ done | flutter-auto | Pricing Management, Notifications, Season Transition, Users & Permissions, Admin Profile, Settings |
