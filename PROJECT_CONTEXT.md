# PROJECT_CONTEXT.md

## Project Identity

**Project Name:** Flutter AI Agent System
**Project Type:** AI-powered Flutter project generation framework
**Platform Targets:** iOS, Android
**Stage:** Greenfield
**Team Size:** Solo
**Last Updated:** 2026-05-10

---

## Project Vision

Enable any individual — regardless of Flutter expertise — to generate a
production-grade Flutter application by describing their idea in natural
language to an AI, which produces a structured prompt fed into OpenCode
using this agent system.

The user never needs to write Flutter code manually.
The agent system handles architecture, implementation, review, debugging,
performance, security, and release readiness autonomously.

---

## How the System Works

```
User describes app idea (natural language)
        ↓
AI generates structured OpenCode prompt
        ↓
User pastes prompt into OpenCode + selects Flutter agent
        ↓
Primary Orchestrator (flutter.md) coordinates all sub-agents
        ↓
Production-grade Flutter app is generated autonomously
```

---

## Agent Registry

| Agent | File | Role |
|---|---|---|
| Primary Orchestrator | flutter.md | Coordinates all agents, enforces governance |
| Explore | explore.md | Codebase discovery and architecture analysis |
| Planner | planner.md | Architecture planning and implementation strategy |
| Flutter Auto | flutter-auto.md | Core Flutter implementation |
| Flutter Debugger | flutter-debugger.md | Runtime and analyzer issue fixing |
| Flutter Reviewer | flutter-reviewer.md | Code quality and architecture review |
| Backend Platform Specialist | backend-platform-specialist.md | Backend infrastructure |
| Performance Profiler | performance-profiler.md | Rendering and performance optimization |
| Migration Agent | migration-agent.md | Migrations, upgrades, and rollout |
| Bootstrap Agent | bootstrap-agent.md | Project initialization and setup |
| HTML to Flutter | html-to-flutter.md | Convert exported HTML/CSS/Tailwind screens to Flutter |
| Flutter Design System | flutter-design-system.md | Design tokens, theme architecture, component standards |
| Flutter Testing | flutter-testing.md | Unit, widget, integration, and golden tests |
| Flutter Production | flutter-production.md | Non-negotiable production standards enforcement |
| Flutter Product Thinking | flutter-product-thinking.md | UX review, flow validation, dark pattern prevention |

---

## Skill Registry

| Skill | File | Domain |
|---|---|---|
| Design System | flutter-design-system.md | Tokens, theme, components |
| Networking | flutter-networking.md | HTTP, repositories, data layer |
| Performance | flutter-performance.md | Rebuilds, rendering, profiling |
| Production Standards | flutter-production.md | Non-negotiable engineering standards |
| Product Thinking | flutter-product-thinking.md | UX, flows, trust |
| Release | flutter-release.md | CI/CD, store submission, rollout |
| Security | flutter-security.md | Auth, storage, privacy |
| Testing | flutter-testing.md | Unit, widget, integration, golden |
| UI Engineering | flutter-ui.md | Widget architecture, responsive design |
| HTML to Flutter | html-to-flutter.md | Design conversion |
| Dependency Governance | flutter-dependency-governance.md | Package management |
| Codebase Memory Layer | codebase-memory-layer.md | Architectural knowledge persistence |
| Accessibility | flutter-accessibility.md | WCAG, semantics, screen readers |
| Analytics | flutter-analytics.md | Events, funnels, telemetry |

---

## Backend Decision Framework

Backend selection is determined per project based on requirements.
This system is backend-agnostic but has preferred defaults.

### Decision Logic

| Requirement | Recommended Backend |
|---|---|
| File storage needed (free tier) | Supabase |
| Real-time + auth + storage (free tier) | Supabase |
| Simple auth only | Supabase Auth or Firebase Auth |
| Complex real-time (chat, live) | Supabase Realtime or Firebase |
| Fully local / offline-first | SQLite + Drift (no backend) |
| Heavy server-side logic | Custom REST API |

### Why Supabase is the Default

- Provides free-tier file storage (Firebase does not on free plan)
- Provides PostgreSQL database with real-time subscriptions
- Provides built-in authentication
- Open-source and self-hostable if needed
- Cost-efficient for solo and indie projects

### Why Firebase May Be Selected

- When project requires advanced push notifications (FCM)
- When project already uses Google ecosystem
- When Crashlytics or Analytics integration is prioritized

### Fully Local (No Backend)

Selected when:
- App is fully offline-first
- No user accounts required
- No shared data between users
- Privacy-critical apps

---

## Architecture Principles

### Mandatory for Every Generated Project

- Feature-first folder structure
- Strict layer separation (Presentation → Domain → Data)
- No hardcoded colors, spacing, strings, or API keys
- Localization-ready from day one
- RTL/LTR compatible by default
- Responsive: mobile-first, tablet-aware
- Accessibility: WCAG AA minimum
- Analyzer-clean: zero warnings
- Dark/light theme supported via ThemeExtension
- Error, loading, empty, and offline states handled in every feature

### State Management Default

- **Riverpod** (preferred for greenfield solo projects)
- Reason: compile-safe, testable, scalable, no context dependency

### Navigation Default

- **GoRouter**
- Reason: declarative, deep-link ready, web-compatible

### Networking Default

- **Dio** with centralized interceptors
- Repositories return typed domain models only
- Never expose raw API responses to UI

### Local Storage Default

- **Hive** or **Drift** depending on complexity
- **flutter_secure_storage** for sensitive data

---

## Project Generation Rules

When generating a new Flutter project from a user prompt:

1. Identify app category (social, productivity, e-commerce, etc.)
2. Determine backend need (local / Supabase / Firebase / custom)
3. Determine required features (auth, storage, real-time, notifications)
4. Select appropriate agents for the task
5. Generate feature-first folder structure
6. Apply all production standards from flutter-production.md
7. Never skip: error states, loading states, offline handling
8. Always include: accessibility, localization scaffold, theme system

---

## Folder Structure Standard

```
lib/
  core/
    constants/
    errors/
    extensions/
    router/
    theme/
    utils/
  features/
    <feature_name>/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        pages/
        widgets/
        providers/
  shared/
    widgets/
    services/
    assets/
test/
  unit/
  widget/
  integration/
assets/
  icons/
    app_icon.png          ← 512x512 PNG (Play Store)
    feature_graphic.png   ← 1024x500 PNG (Play Store)
  images/
  fonts/
screens/                  ← exported HTML/Tailwind designs (input only — deleted after conversion)
  *.html
```

---

## Quality Gates

Every generated project must pass:

- `flutter analyze` with zero warnings
- All loading / error / empty states implemented
- No hardcoded values anywhere
- Responsive on mobile and tablet
- RTL layout verified
- Accessibility semantics present
- Security: no secrets in code, secure storage used
- At least unit tests for business logic
- At least widget tests for critical UI

---

## Severity Reference

| Severity | Examples | Action |
|---|---|---|
| Critical | Hardcoded secrets, dark patterns, auth bypass | Block release |
| High | Architecture leaks, broken tests, missing states | Must fix before review |
| Medium | Hardcoded colors, missing localization | Fix in current cycle |
| Low | Naming inconsistency, readability | Track and fix gradually |

---

## Target Users

Individual developers and non-technical users who want to build
production-grade Flutter applications without deep Flutter expertise.

The system abstracts all engineering complexity behind the agent layer.
The user only needs to describe what they want to build.

---

## Solo Developer Optimizations

Since this is a solo project system:
- Prefer simplicity over over-engineering
- Avoid premature monorepo complexity
- Prefer Supabase free tier to minimize cost
- Prefer Riverpod over Bloc for less boilerplate
- Prefer GoRouter for built-in deep link support
- Prefer code generation (json_serializable, freezed, riverpod_generator)
  to reduce manual work
- Bootstrap crash reporting from day one (free tier)

---

## Git Workflow Standard

All implementation work must follow controlled Git workflows.

### Branching Rules

- Never work directly on `main`
- Never commit directly to production branches
- Always create a feature branch before implementation

### Branch Naming Convention

```
feature/<feature-name>
fix/<bug-name>
refactor/<scope>
migration/<scope>
release/<version>
hotfix/<issue>
```

### Commit Convention (Conventional Commits)

```
feat: add user authentication screen
fix: resolve token refresh race condition
refactor: extract shared button widget
chore: update dependencies
test: add unit tests for auth repository
docs: update PROJECT_CONTEXT.md
```

### Rollback Safety Rules

- Every feature branch must remain independently revertable
- Avoid mixing unrelated changes in one commit
- Destructive migrations require rollback strategy before merge
- Release branches contain stabilization fixes only

---

## Autonomous Workflow Lifecycle

Every project generated by this system follows this lifecycle:

```
User describes app idea (natural language)
        ↓
AI Prompt Translation
  └─ Infer requirements, select backend, define features
        ↓
Architecture Planning (@planner)
  └─ Define structure, stages, delegation map
        ↓
Bootstrap (@bootstrap-agent)
  └─ Git init → initial commit on main → create develop branch
  └─ Initialize project, folder structure, configs
        ↓
HTML Screen Conversion (@html-to-flutter) [if screens/ folder exists]
  └─ Convert exported HTML/Tailwind designs before feature implementation
        ↓
Implementation (@flutter-auto)
  └─ Features built incrementally, stage by stage
        ↓
Design System Enforcement (@flutter-design-system)
  └─ Tokens, theme, components validated
        ↓
Code Review (@flutter-reviewer)
  └─ Architecture, quality, scalability verified
        ↓
Debugging (@flutter-debugger)
  └─ Runtime errors, analyzer issues resolved
        ↓
Performance Validation (@performance-profiler)
  └─ Rebuilds, rendering, memory verified
        ↓
UX Review (@flutter-product-thinking)
  └─ Flows, accessibility, trust validated
        ↓
Release Validation (@flutter-release + @flutter-security)
  └─ Store readiness, security, compliance checked
```

No stage may be skipped for production-bound projects.

---

## App Blueprint Categories

The system supports the following application categories.
Each category has implied default features and architecture patterns.

| Category | Default Features | Preferred Backend |
|---|---|---|
| SaaS | Auth, subscription, dashboard, multi-tenant | Supabase |
| Social | Auth, profiles, feed, real-time, storage | Supabase |
| AI Apps | Prompt UI, streaming responses, history | REST API / Custom |
| Marketplace | Listings, search, payments, auth, storage | Supabase |
| Productivity | Local-first, sync, auth optional, offline | Drift + Supabase |
| Dashboards | Data visualization, auth, real-time updates | Supabase / REST |
| E-commerce | Product catalog, cart, payments, auth | Supabase + Custom |

### Blueprint Rules

- Category is inferred from user description if not stated explicitly
- Missing features are inferred from category defaults
- Backend is selected based on category + storage + real-time needs
- Architecture patterns are pre-configured per category

---

## Memory Layer Integration

All projects generated by this system must preserve engineering knowledge
using the `codebase-memory-layer.md` skill.

### What Must Be Preserved

- Architecture decisions and rationale
- Backend selection reasoning
- Migration history and rollback records
- Technical debt tracking
- Release incidents and postmortems
- Known pitfalls and fragile systems
- Convention evolution history

### Memory Rules

- Agents must read relevant memory before major architectural changes
- Convention conflicts require escalation and documented resolution
- Stale memory entries require periodic review and cleanup
- Critical knowledge must remain recoverable after agent resets
- Temporary systems must define expiration and cleanup owner

### Memory Priority

Highest preservation priority:
1. Security incidents
2. Architecture decisions
3. Production regressions
4. Rollback history
5. Scalability bottlenecks

---

## User Experience Philosophy

This system targets individuals — including non-technical users — who want
to build production-grade Flutter applications without deep engineering expertise.

### Core Principles

- **Minimize complexity exposure** — Users describe what they want, not how to build it
- **Sensible defaults always** — No unnecessary decision fatigue for standard choices
- **Infer before asking** — The system infers requirements intelligently from context
- **Progressive disclosure** — Advanced options surface only when needed
- **Fail gracefully** — Ambiguous prompts produce safe reasonable outputs, not errors

### Default Decisions Made Automatically

| Decision | Default |
|---|---|
| State management | Riverpod |
| Navigation | GoRouter |
| HTTP client | Dio |
| Backend (with storage) | Supabase |
| Backend (auth only) | Supabase Auth |
| Local storage | Hive / Drift |
| Secure storage | flutter_secure_storage |
| Serialization | json_serializable + freezed |
| Testing | flutter_test + mocktail |

Users are never asked to make these decisions unless they conflict with
explicit requirements.

---

## Scalability Lifecycle Rules

Applications must be designed to scale safely across lifecycle stages
without requiring architectural rewrites.

### Lifecycle Stages

```
MVP
  └─ Core feature, single user flow, minimal backend
        ↓
Production
  └─ Auth, error handling, offline resilience, analytics
        ↓
Multi-Feature
  └─ Feature modules, shared systems, design tokens
        ↓
Scale
  └─ Performance optimization, caching, background sync
        ↓
Enterprise (if applicable)
  └─ Multi-tenant, advanced auth, compliance, monitoring
```

### Scalability Rules

- Feature-first architecture from day one — no monolithic restructuring later
- Shared systems (core/, shared/) must support expansion without rewrites
- No feature may import directly from another feature's internals
- State management must remain predictable as feature count grows
- Navigation must support deep links and complex flows from the start
- Backend abstraction must allow provider switching without UI changes

---

## AI Prompt Translation Rules

When an external AI system translates a user's natural language idea into
a structured OpenCode execution prompt, it must follow these rules.

### Translation Principles

- **Infer requirements** — Don't ask what can be reasonably inferred from context
- **Infer backend** — Select backend based on feature requirements, not preference
- **Infer category** — Identify app category from description automatically
- **Avoid over-questioning** — Non-technical users should not be interrogated
- **Prefer completeness** — A slightly over-specified prompt is better than an under-specified one

### Required Prompt Sections

Every translated prompt must include:

```
## App Description
## Target Users
## Core Features
## App Category
## Backend Selection + Reasoning
## Authentication Required (yes/no)
## Real-time Features (yes/no + which)
## File Storage Required (yes/no)
## Offline Support Required (yes/no)
## Suggested Agents
## Quality Requirements
```

### Inference Rules

| Missing Info | Inference Strategy |
|---|---|
| No backend specified | Select based on storage + real-time needs |
| No auth specified | Assume required if multi-user app |
| No storage specified | Assume not required unless media mentioned |
| No real-time specified | Assume not required unless social/chat |
| No category specified | Infer from feature description |
| No target user specified | Assume individual end-users |

### Forbidden Behaviors

- Never ask users for technical implementation details
- Never expose agent names or system internals to non-technical users
- Never require users to understand Flutter architecture
- Never generate incomplete prompts missing critical sections

---

## Context Efficiency Rules

Agents in this system must operate efficiently to preserve token budgets
and minimize unnecessary processing.

### Loading Rules

- Load only skills relevant to the current task
- Read memory layer before major architectural decisions only
- Avoid loading all skills simultaneously unless orchestrating full project
- Prefer targeted grep/glob over full codebase reads

### Execution Rules

- Prefer incremental feature-by-feature execution over single-pass implementation
- Split large tasks into independently verifiable stages
- Validate each stage before proceeding to the next
- Avoid speculative work not backed by requirements or profiling evidence

### Communication Rules

- Agents report output in structured format only (see individual agent Output Format)
- Avoid verbose explanations of obvious decisions
- Flag conflicts and risks concisely
- Escalate blockers immediately rather than speculating

---

## Release Ready Definition

A project is considered release-ready only when ALL of the following pass:

### Technical Gates

- `flutter analyze` passes with zero warnings
- All unit tests pass
- All widget tests pass
- Critical integration tests pass
- No hardcoded secrets, colors, spacing, or strings
- No debug-only code in release build

### Quality Gates

- All features handle: loading, error, empty, offline states
- Responsive layout verified on mobile and tablet
- RTL/LTR layout verified
- Dark and light theme verified

### Accessibility Gates

- WCAG AA contrast minimum met
- All tappable elements meet touch target size
- Screen reader semantics present on critical flows
- Keyboard navigation works on desktop/web

### Security Gates

- No secrets in source code
- Secure storage used for sensitive data
- HTTPS enforced
- Auth token handling is safe
- No PII in logs or crash reports

### Store Readiness Gates

- Privacy policy integrated
- Permissions declared with rationale
- App icons and splash screens present
- Localization scaffold in place
- Analytics and crash reporting bootstrapped

---

## System Philosophy

This system exists to democratize professional Flutter engineering.

### Core Values

| Value | Meaning |
|---|---|
| Long-term maintainability | Every decision must remain defensible 2 years from now |
| Production stability | No shortcuts that create future instability |
| Scalability | Architecture must grow with the product |
| Developer velocity | Sensible defaults and automation reduce friction |
| Autonomous engineering | Agents handle complexity so users focus on product |

### Design Principles

- **Correctness over speed** — A slower correct implementation beats a fast broken one
- **Defaults over decisions** — Remove choice where choice adds no value
- **Incremental over big-bang** — Small verifiable stages over massive single-pass builds
- **Evidence over intuition** — Profiling before optimization, requirements before implementation
- **Accessibility is not optional** — Every user deserves a usable product
- **Security is not a phase** — Security is built in from day one, not added later

### What This System Is Not

- Not a low-code tool that generates throwaway code
- Not a code snippet generator
- Not a prototype-only system
- Not a replacement for product thinking

This system generates production-grade Flutter applications that a
senior Flutter engineer would be proud to maintain.

---

## Language & RTL Rules

- App language is determined from SPEC.md `App Language` field.
- If Arabic (or any RTL language) is the primary language:
  - `@flutter-design-system` must configure RTL as default from bootstrap
  - All layout uses `EdgeInsetsDirectional`, `AlignmentDirectional`, `Positioned.directional`
  - GoRouter locale handling must be configured from day one
  - Never use `EdgeInsets.only(left:...)` — always use directional equivalents
- If both Arabic and English are needed:
  - `flutter_localizations` + `intl` must be set up in bootstrap stage
  - Language toggle must be part of Settings screen

---

## Model Switching Protocol

The orchestrator MUST request a model switch at every stage transition.
This is mandatory — not optional.

### Why This Matters

- Tier 1 models (Opus) have limited quota — wasting them on tests burns budget
- Tier 3 models (Flash) are near-unlimited — use them for repetitive work
- Wrong model = wasted quota OR poor quality output

### Required Switch Points

| Stage Starting | Request Switch To | Why |
|---|---|---|
| @planner | Tier 1 (Opus / Gemini Pro High) | Deep architecture reasoning |
| @bootstrap-agent | Tier 2 (Sonnet / Kimi) | Standard setup work |
| @html-to-flutter | Tier 2 (Sonnet) | Conversion work |
| @flutter-auto (features) | Tier 2 (Sonnet / Kimi) | Most work happens here |
| @flutter-debugger (hard bug) | Tier 1 (Opus) | Complex diagnosis |
| @flutter-testing | Tier 3 (Flash) | Repetitive, saves quota |
| @flutter-reviewer | Tier 2 (Sonnet) | Balanced analysis |
| @performance-profiler | Tier 1 (Opus) | Deep profiling |
| @flutter-release | Tier 1 (Opus) | Final quality gate |

### Enforcement Rule

The orchestrator must STOP before each stage and output the switch request.
If user says "skip" → log it, note the risk, continue.
Never silently proceed without asking.

---

## Non-Negotiables (from flutter-production.md)

These apply to every project regardless of size or deadline:

- No hardcoded secrets
- No raw backend responses in UI
- No silent exception swallowing
- No missing error/loading/empty states
- No accessibility shortcuts
- No debug code in release builds
- No abandoned TODO comments without tracking references
- Localization infrastructure from day one
