---
description: Flutter release engineering, CI/CD, store submission, and rollout governance skill
mode: skill
tools:
  "*": false
  read: true
---

## Branch Strategy Rules

Recommended branch model:

| Branch | Purpose |
|---|---|
| main | Production-ready stable code |
| develop | Active feature integration |
| release/* | Release stabilization and QA |
| hotfix/* | Emergency production fixes |

Rules:
- Never develop directly on release branches.
- Hotfixes must merge back into:
  - main
  - develop
- Release branches should contain stabilization fixes only.
- Avoid long-lived divergent branches.

---

## Feature Flag Release Rules

- High-risk features should support remote disable capability.
- Feature flags must remain:
  - environment-aware
  - documented
  - removable

Rules:
- Never leave stale experimental flags indefinitely.
- Feature flags must not contain business logic directly.
- Preserve safe rollback paths through flags when feasible.

---

## Migration Safety Rules

- Database and backend migrations must remain backward compatible for at least one release cycle.
- Avoid destructive migrations during staged rollout windows.
- Preserve rollback compatibility whenever possible.

Rules:
- Validate migration safety in staging before production rollout.
- High-risk migrations require staged rollout expansion gradually.

---

## Supply Chain Security Rules

- Audit third-party dependencies for known vulnerabilities.
- Prefer signed and trusted package sources.
- Avoid unmaintained CI actions and release tooling.
- Validate integrity of external build dependencies.

Rules:
- Security-sensitive packages require explicit review.
- Remove abandoned dependencies proactively.

---

## Release Observability Rules

Monitor during rollout:
- crash rate
- ANR rate
- startup regressions
- auth failures
- API error spikes
- memory regressions
- negative review velocity

Rules:
- Observability must remain active before 1% rollout begins.
- Rollout expansion depends on stable telemetry metrics.
- Preserve release traceability across monitoring systems.

---

## Emergency Release Rules

- Emergency releases must minimize scope aggressively.
- Disable non-critical risky functionality when necessary.
- Preserve rollback readiness even during emergency response.

Rules:
- Emergency patches must avoid unrelated refactors.
- Emergency releases require postmortem documentation afterward.

---

## Release Freeze Rules

During stabilization windows avoid:
- major dependency upgrades
- architectural rewrites
- large-scale refactors
- risky migrations

Rules:
- Only release-critical fixes allowed during freeze periods.
- Freeze exceptions require explicit justification.

---

## Compliance Audit Rules

Validate before production release:
- privacy disclosures
- permission transparency
- analytics consent handling
- third-party SDK compliance
- App Store policy alignment
- Play Store policy alignment

Rules:
- Compliance regressions are High severity minimum.
- Privacy-sensitive SDKs require explicit approval.

---

## Artifact Retention Rules

- Preserve previous release artifacts securely.
- Retain symbol/debug files for crash deobfuscation.
- Preserve release traceability for auditing and rollback.

Rules:
- Artifacts should remain reproducible and discoverable.
- Retention duration should support long-term crash analysis.

---

## Release Ownership Rules

Every release must define:
- release owner
- rollback owner
- monitoring owner
- escalation path

Rules:
- Ownership responsibilities must remain explicit.
- Critical production issues must have defined escalation flow.
- Avoid ambiguous deployment accountability.

---

## Post-Release Review Rules

After release validate:
- crash stability
- rollout health
- analytics integrity
- auth reliability
- backend compatibility
- user feedback trends

Rules:
- Significant regressions require rollout pause or rollback.
- Major incidents require documented postmortem analysis.

---

## Release Documentation Rules

Maintain documentation for:
- deployment process
- rollback process
- signing procedures
- environment setup
- CI/CD architecture
- release responsibilities

Rules:
- Documentation must remain reproducible by new team members.
- Avoid undocumented release-only tribal knowledge.