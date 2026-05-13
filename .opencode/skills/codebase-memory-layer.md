---
description: Flutter codebase memory layer, architectural knowledge persistence, and governance skill
mode: skill
tools:
  "*": false
  read: true
---

## Architecture Versioning Rules

Track architecture evolution versions:

| Version | Description | Date | Status |
|---|---|---|---|
| v1 | Monolithic architecture | YYYY-MM-DD | Archived |
| v2 | Modular feature architecture | YYYY-MM-DD | Active |

Rules:
- Major architecture shifts require version updates.
- Architecture evolution must remain historically traceable.
- Deprecated architecture versions should remain archived safely.

---

## Memory Freshness Rules

Memory entries should define:
- created_at
- last_verified
- expiration_review_date
- owner
- status

Rules:
- Stale entries require periodic review.
- Unverified historical assumptions should not remain trusted indefinitely.
- Expired temporary context should trigger cleanup review.

---

## Cross-Agent Consistency Rules

All agents must:
- respect established conventions
- preserve shared terminology
- avoid conflicting architectural assumptions
- preserve architecture continuity

Rules:
- Agents must read relevant memory domains before major modifications.
- Convention conflicts require escalation and resolution.
- Cross-agent inconsistency is considered governance drift.

---

## Known Pitfalls Registry

Track:
- repeated regressions
- fragile systems
- risky workflows
- historical production failures
- migration pain points
- scalability bottlenecks

Rules:
- Known pitfalls should influence future engineering decisions automatically.
- Repeated historical failures require architectural review.

---

## Architectural Drift Rules

Detect:
- inconsistent folder structures
- mixed state-management patterns
- duplicated abstractions
- naming divergence
- convention drift
- incompatible architectural layering

Rules:
- Drift detection should occur periodically.
- Unresolved drift requires escalation.
- Architectural consistency has higher priority than short-term convenience.

---

## Temporary System Rules

Temporary systems must define:
- owner
- cleanup deadline
- removal condition
- dependency impact
- migration relationship

Rules:
- Temporary systems must never become permanent silently.
- Expired temporary systems require cleanup escalation.
- Migration bridges should remain explicitly timeboxed.

---

## Engineering Timeline Rules

Track:
- major migrations
- architecture shifts
- release incidents
- dependency transitions
- platform upgrades
- security incidents

Rules:
- Timeline events must remain searchable chronologically.
- Critical historical events should remain linked to decisions and migrations.

---

## Memory Priority Rules

Prioritize preservation of:
- architectural decisions
- migration rationale
- security incidents
- production regressions
- rollback history
- scalability bottlenecks

Rules:
- High-value engineering knowledge has preservation priority.
- Low-value temporary noise should not pollute memory systems.

---

## Multi-Project Memory Rules

Shared conventions across projects should:
- remain standardized
- remain reusable
- remain version-aware
- preserve compatibility guidelines

Rules:
- Shared engineering patterns should remain centrally discoverable.
- Cross-project convention conflicts require explicit resolution.

---

## Knowledge Recovery Rules

Critical engineering knowledge must remain recoverable after:
- agent resets
- migration changes
- repository restructuring
- onboarding new agents
- long inactive periods

Rules:
- Critical architectural rationale must never become unrecoverable.
- Knowledge recovery workflows should remain reproducible.

---

## Convention Evolution Rules

Conventions may evolve when:
- scalability problems emerge
- tooling changes significantly
- architecture modernization requires updates

Rules:
- Convention evolution requires documentation and migration guidance.
- Sudden undocumented convention changes are prohibited.

---

## Historical Decision Linking Rules

Architecture decisions should link to:
- migrations
- incidents
- technical debt
- related conventions
- rollback history

Rules:
- Engineering context should remain interconnected and traceable.
- Isolated undocumented decisions are prohibited.

---

## Institutional Knowledge Rules

The system should preserve:
- organizational engineering patterns
- preferred workflows
- historical tradeoffs
- proven architecture strategies
- operational lessons learned

Rules:
- Institutional engineering knowledge should outlive individual sessions.
- Proven successful patterns should influence future project decisions automatically.

---

## Memory Audit Rules

Periodically audit:
- stale conventions
- unresolved technical debt
- expired migration bridges
- outdated ownership
- deprecated architecture assumptions

Rules:
- Memory audits should remain scheduled and repeatable.
- Critical inconsistencies require escalation and remediation.

---

## Governance Drift Severity Rules

Drift severity levels:

| Severity | Meaning |
|---|---|
| Low | Minor convention inconsistency |
| Medium | Architecture inconsistency risk |
| High | Scalability or maintainability risk |
| Critical | Structural governance failure |

Rules:
- High/Critical drift requires immediate review.
- Drift trends should remain historically visible.