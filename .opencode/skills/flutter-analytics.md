---
description: Flutter analytics, telemetry governance, and product metrics engineering skill
mode: skill
tools:
  "*": false
  read: true
---

## Analytics Ownership Rules

Every analytics domain must define:
- domain owner
- dashboard owner
- alert owner
- cleanup owner

Rules:
- Ownership responsibilities must remain documented.
- Critical product funnels require explicit operational ownership.
- Avoid unowned metrics and orphaned dashboards.

---

## Telemetry Sampling Rules

High-volume telemetry systems:
- must support sampling
- must avoid event spam
- must preserve signal quality

Rules:
- Sampling strategies must remain documented.
- Critical business and crash events must never be sampled unintentionally.
- Sampling must remain environment-aware.

---

## Dashboard Governance Rules

Dashboards must:
- remain documented
- define source-of-truth KPIs
- avoid duplicate metrics
- avoid conflicting definitions

Rules:
- Dashboard ownership must remain explicit.
- Deprecated dashboards should be archived safely.
- Operational dashboards and business dashboards should remain separated.

---

## Analytics Alerting Rules

Alerts required for:
- crash spikes
- auth failure spikes
- payment failures
- onboarding funnel drop spikes
- telemetry outages
- abnormal API failure rates

Rules:
- Alert thresholds must remain documented.
- Avoid noisy low-signal alerts.
- Critical alerts require escalation ownership.

---

## Event Lifecycle Rules

Track lifecycle status for analytics events:

| Status | Meaning |
|---|---|
| Active | Fully supported |
| Deprecated | No new instrumentation allowed |
| Migration-required | Replacement event required |
| Sunset-planned | Scheduled for removal |

Rules:
- Deprecated events must remain documented.
- Historical dashboards must preserve backward compatibility where required.
- Event migrations require rollout coordination.

---

## Data Retention Rules

Retention periods must:
- remain documented
- remain justified
- comply with privacy requirements
- support operational and legal requirements only

Rules:
- Avoid indefinite retention of telemetry unnecessarily.
- Sensitive telemetry retention should remain minimized.
- Expired telemetry should support safe deletion workflows.

---

## Analytics Cost Governance Rules

Monitor:
- event ingestion volume
- storage growth
- dashboard query complexity
- telemetry processing overhead
- provider billing impact

Rules:
- Excessive telemetry growth requires architectural review.
- Avoid low-value high-volume events.
- Telemetry cost should remain observable and controlled.

---

## Feature Flag Analytics Rules

Track:
- feature exposure
- activation rate
- adoption rate
- failure rate
- rollback correlation

Rules:
- Experimental features must remain traceable.
- Feature telemetry should remain isolated when appropriate.
- Rollback decisions should leverage telemetry evidence.

---

## Telemetry Health Rules

Detect:
- telemetry outages
- dropped events
- queue overflows
- provider failures
- event delivery delays
- malformed telemetry payloads

Rules:
- Telemetry failures must never crash the app.
- Queue growth should remain bounded and observable.
- Provider degradation should trigger fallback handling where possible.

---

## Analytics Debt Tracking

Flag:
- stale events
- duplicate metrics
- undocumented telemetry
- unused dashboards
- unowned KPIs
- inconsistent naming
- dead funnels

Rules:
- Analytics debt must remain visible.
- Stale telemetry should be cleaned proactively.
- Dead or misleading metrics should never remain silently active.

---

## Analytics Governance Metrics

Track:
- total active events
- deprecated event count
- dashboard count
- alert count
- telemetry error rate
- event delivery success rate
- average telemetry latency

Rules:
- Governance metrics should remain observable over time.
- Significant telemetry complexity growth requires review.

---

## Incident Correlation Rules

Telemetry systems should correlate:
- release versions
- feature flags
- crash sessions
- API incidents
- rollout stages
- environment context

Rules:
- Correlation metadata must remain privacy-safe.
- Incident investigations should remain reproducible from telemetry.

---

## Analytics Migration Rules

When replacing analytics providers or schemas:
- preserve historical continuity where possible
- maintain abstraction boundaries
- validate dashboard compatibility
- support staged migration rollout

Rules:
- Vendor migration must not break feature instrumentation.
- Historical reporting integrity should remain protected.

---

## Telemetry Reliability Rules

Telemetry systems must:
- retry safely
- tolerate offline conditions
- preserve event ordering when important
- prevent duplicate event replay

Rules:
- Telemetry delivery guarantees should remain documented.
- Critical telemetry paths require reliability validation.