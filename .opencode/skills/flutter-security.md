---
description: Flutter security engineering, auth safety, and data protection governance skill
mode: skill
tools:
  "*": false
  read: true
---

## Security Severity Levels

| Severity | Meaning |
|---|---|
| Low | Minor security hygiene issue |
| Medium | Potential misuse or privacy risk |
| High | Exploitable vulnerability or privilege risk |
| Critical | Sensitive-data, auth, or infrastructure compromise |

Rules:
- High and Critical findings require escalation.
- Critical findings block production release approval.
- Severity classification must remain consistent across audits.

---

## Session Security Rules

Sessions should support:
- inactivity expiration
- forced logout
- multi-device awareness
- suspicious-session invalidation
- session revocation

Rules:
- Sessions must fail safely after expiration.
- Sensitive actions may require session revalidation.
- Session lifecycle events should remain observable.

---

## Biometric Security Rules

Biometric authentication should:
- remain optional
- never replace backend authorization
- support secure fallback handling
- preserve device-level trust boundaries

Rules:
- Biometrics must remain device-scoped.
- Sensitive operations may require additional verification layers.
- Biometric fallback flows must remain secure.

---

## Device Trust Rules

High-risk actions may require:
- device validation
- re-authentication
- elevated trust verification
- suspicious-device detection

Rules:
- Device trust state should remain observable.
- Untrusted devices require stricter auth posture.
- Device validation should remain privacy-aware.

---

## Offline Security Rules

Offline data must:
- remain encrypted when sensitive
- support secure expiration
- avoid insecure cache persistence
- preserve integrity during sync recovery

Rules:
- Sensitive offline queues require additional protection.
- Offline security posture must remain auditable.
- Expired sensitive offline data should support cleanup workflows.

---

## Crash Reporting Rules

Crash reports must:
- avoid PII leakage
- sanitize auth/session tokens
- preserve privacy boundaries
- avoid sensitive payload persistence

Rules:
- Production crash reporting requires stricter sanitization.
- Sensitive user context must remain minimized.

---

## Abuse Detection Rules

Monitor:
- auth abuse
- OTP abuse
- automation behavior
- suspicious request spikes
- brute-force attempts
- replay attempts

Rules:
- Abuse telemetry should remain observable.
- High-risk abuse patterns require escalation workflows.
- Abuse mitigation must preserve legitimate user experience when possible.

---

## Environment Isolation Rules

Strictly isolate:
- development
- staging
- production
- testing secrets and configs

Rules:
- Production credentials must never appear in lower environments.
- Environment leakage is Critical severity.
- Environment configuration should remain traceable and auditable.

---

## Secure Feature Flag Rules

Feature flags must:
- avoid exposing hidden admin functionality
- remain environment-aware
- support rollback safely
- preserve authorization boundaries

Rules:
- Security-sensitive flags require stricter governance.
- Expired feature flags should trigger cleanup workflows.

---

## Security Metrics Rules

Track:
- auth failures
- abuse attempts
- permission usage
- security incidents
- dependency vulnerabilities
- token refresh anomalies

Rules:
- Security metrics should remain historically visible.
- Significant anomaly spikes require investigation.
- Security telemetry must remain privacy-safe.

---

## Secure Build Rules

Production builds must:
- disable debug tooling
- disable verbose logs
- isolate secrets
- preserve signing integrity

Rules:
- Debug capabilities must never leak into release builds.
- Release artifacts should remain reproducible and auditable.

---

## Runtime Protection Rules

Applications should detect:
- runtime tampering
- suspicious debugging
- unsafe environments
- unauthorized modification attempts

Rules:
- Runtime protection should fail gracefully.
- Security-sensitive apps require stronger runtime posture.

---

## Data Retention Security Rules

Sensitive data retention must define:
- retention duration
- deletion policy
- encryption posture
- recovery policy

Rules:
- Excessive sensitive-data retention is prohibited.
- Sensitive deletion workflows should remain auditable.

---

## Security Audit Frequency Rules

Perform audits:
- before production releases
- after major migrations
- after dependency upgrades
- after auth or backend changes

Rules:
- Security audits must remain repeatable.
- Unreviewed security-sensitive changes block release approval.

---

## Incident Recovery Rules

Security incidents must support:
- rapid containment
- rollback readiness
- credential rotation
- forensic analysis
- communication workflows

Rules:
- Incident recovery procedures must remain documented.
- Post-incident reviews should update security governance memory.