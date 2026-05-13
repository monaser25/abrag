---
description: Flutter dependency governance, package management, and upgrade safety skill
mode: skill
tools:
  "*": false
  read: true
---

## Package Replacement Rules

When replacing dependencies:
- preserve existing API boundaries whenever possible
- minimize migration blast radius
- support incremental migration strategies
- avoid rewriting unrelated systems

Rules:
- Prefer adapter layers during migrations.
- Preserve backward compatibility during staged replacements.
- Large package replacements require rollback strategy.

---

## Dependency Ownership Rules

Critical dependencies must define:
- responsible owner
- upgrade owner
- migration owner
- security review owner

Rules:
- Ownership responsibilities must remain documented.
- High-risk packages require explicit escalation paths.
- Avoid ambiguous dependency accountability.

---

## Runtime Dependency Monitoring Rules

Monitor after dependency upgrades:
- crash spikes
- startup regressions
- memory regressions
- ANR increases
- rendering instability
- unexpected permission usage

Rules:
- High-risk upgrades require post-release monitoring.
- Significant regressions trigger rollback evaluation immediately.

---

## Forked Dependency Rules

Avoid maintaining custom forks unless:
- critical blocker exists
- upstream inactive
- security patch required
- compliance issue unresolved upstream

Rules:
- Forks must remain documented and traceable.
- Prefer contributing fixes upstream first.
- Fork maintenance cost must remain visible.
- Forks require periodic reevaluation for upstream reintegration.

---

## Dependency Sunset Rules

Dependencies should be removed when:
- abandoned
- deprecated
- superseded
- incompatible with platform direction
- security-risk prone
- maintenance burden exceeds value

Rules:
- Sunset planning should begin before forced migrations.
- Critical deprecated dependencies require migration roadmap.
- Avoid indefinite dependency stagnation.

---

## Native SDK Governance Rules

Audit:
- Android SDK requirements
- iOS deployment target changes
- Gradle compatibility
- CocoaPods compatibility
- Kotlin compatibility
- Swift compatibility

Rules:
- Native SDK upgrades must remain reproducible in CI.
- Avoid plugin additions that force unnecessary platform-version increases.
- Native toolchain drift must remain controlled.

---

## CI Dependency Cache Rules

- Cache dependencies safely in CI.
- Invalidate cache predictably after:
  - lockfile changes
  - Flutter SDK upgrades
  - generated-code changes

Rules:
- Avoid stale generated artifacts across builds.
- Cache corruption should fail safely and recover automatically.
- Preserve deterministic CI behavior.

---

## Experimental Dependency Rules

Experimental packages:
- require explicit approval
- must remain isolated
- must not power critical production flows
- require fallback/removal strategy

Rules:
- Experimental dependencies must remain clearly labeled.
- Avoid spreading experimental APIs across the architecture.
- Experimental adoption must remain reversible.

---

## Vendor Lock-In Rules

Prefer abstraction layers around:
- analytics
- crash reporting
- push notifications
- backend SDKs
- feature flag providers
- payment providers

Rules:
- Avoid tightly coupling business logic to vendor SDK APIs.
- Preserve migration flexibility between providers.
- Third-party outages must not collapse core app functionality.

---

## Dependency Lifecycle Rules

Track lifecycle status for critical dependencies:

| Status | Meaning |
|---|---|
| Active | Fully supported and maintained |
| Maintenance-only | Security/bugfixes only |
| Deprecated | Migration recommended |
| Migration-required | High urgency migration needed |
| Sunset-planned | Scheduled for removal |

Rules:
- Lifecycle status must remain documented.
- Deprecated critical packages require migration timelines.
- Lifecycle drift must be reviewed periodically.

---

## Dependency Governance Metrics

Track:
- total direct dependency count
- transitive dependency count
- vulnerable package count
- deprecated package count
- average package update latency
- binary-size contribution
- startup impact

Rules:
- Dependency metrics should remain observable over time.
- Significant dependency growth requires architectural review.

---

## Dependency Incident Response Rules

When a dependency vulnerability or breaking issue is discovered:
1. Assess severity immediately
2. Identify affected systems
3. Determine rollback or mitigation options
4. Patch or replace dependency safely
5. Validate CI/CD and runtime stability
6. Monitor production impact after deployment

Rules:
- Security-critical dependency incidents are release blockers.
- Incident response actions must remain documented and traceable.