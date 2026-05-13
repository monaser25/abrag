---
description: Flutter accessibility engineering, WCAG compliance, and inclusive UX governance skill
mode: skill
tools:
  "*": false
  read: true
---

## Accessibility Severity Levels

| Severity | Meaning |
|---|---|
| Low | Minor usability friction |
| Medium | Reduced accessibility usability |
| High | Critical workflow accessibility issue |
| Critical | Inaccessible core functionality |

Rules:
- High and Critical accessibility issues require escalation.
- Critical accessibility blockers prevent production approval.
- Severity classification must remain consistent across audits.

---

## Accessibility Preference Rules

Applications should respect:
- reduced motion
- text scaling
- platform accessibility settings
- contrast preferences
- screen-reader settings

Rules:
- Accessibility preferences should remain reactive and adaptive.
- User accessibility preferences must never be ignored silently.
- Accessibility behavior should remain consistent across platforms.

---

## Dynamic Content Announcement Rules

Important dynamic updates should:
- announce appropriately to screen readers
- avoid excessive interruption
- preserve understandable context

Examples:
- form validation changes
- async loading completion
- navigation state changes
- critical alerts

Rules:
- Excessive accessibility announcements should be avoided.
- Important state changes must remain perceivable non-visually.

---

## Accessible Error Recovery Rules

Users must:
- understand errors clearly
- recover without hidden interaction patterns
- receive accessible guidance
- maintain navigation continuity

Rules:
- Error recovery should remain keyboard and screen-reader accessible.
- Accessibility users must never become trapped in failed flows.
- Error messaging should remain actionable and understandable.

---

## Accessible Loading Rules

Loading states should:
- expose progress meaningfully
- avoid inaccessible indefinite ambiguity
- remain screen-reader aware
- preserve context continuity

Rules:
- Critical loading states require accessible feedback.
- Endless inaccessible loading indicators are prohibited.
- Loading transitions should remain understandable for assistive technologies.

---

## Accessibility Metrics Rules

Track:
- screen-reader issues
- focus failures
- contrast violations
- text-scaling regressions
- inaccessible flows
- semantic violations

Rules:
- Accessibility metrics should remain historically visible.
- Regression spikes require accessibility review.
- Accessibility telemetry should remain privacy-safe.

---

## Accessible Authentication Rules

Authentication flows must:
- remain keyboard accessible
- remain screen-reader compatible
- avoid inaccessible OTP flows
- preserve understandable validation feedback

Rules:
- Authentication barriers are High severity minimum.
- MFA and OTP flows must remain accessibility-aware.
- Auth recovery flows should remain inclusive and discoverable.

---

## Accessibility Incident Recovery Rules

Critical accessibility regressions require:
- rapid remediation
- rollback readiness
- regression tracking
- escalation workflows

Rules:
- Accessibility incidents should remain historically traceable.
- High-impact accessibility regressions require priority remediation.

---

## Cognitive Accessibility Rules

Avoid:
- overwhelming UI density
- inconsistent navigation
- unclear interaction feedback
- excessive cognitive load
- unpredictable flows

Rules:
- Interaction patterns should remain predictable and understandable.
- Complex flows require progressive disclosure where appropriate.
- Cognitive accessibility should remain part of UX review workflows.

---

## Accessibility Governance Rules

Track:
- unresolved accessibility debt
- accessibility audit frequency
- accessibility regression trends
- unresolved semantic violations
- accessibility testing coverage

Rules:
- Accessibility governance should remain measurable.
- Persistent accessibility regressions require escalation.
- Accessibility debt trends should remain observable over time.

---

## Accessible Navigation Transition Rules

Navigation transitions should:
- preserve focus continuity
- avoid disorienting animations
- maintain semantic context

Rules:
- Accessibility users should always understand current navigation state.
- Route transitions must remain screen-reader aware.

---

## Accessibility Consistency Rules

Accessibility behavior should remain consistent across:
- mobile
- tablet
- desktop
- web
- RTL/LTR environments

Rules:
- Platform accessibility parity should remain a governance objective.
- Accessibility fragmentation across platforms is discouraged.

---

## Accessible Empty State Rules

Empty states should:
- remain understandable
- provide accessible guidance
- expose actionable next steps

Rules:
- Empty states should avoid vague messaging.
- Accessibility users must understand system state clearly.

---

## Accessibility Audit Frequency Rules

Perform accessibility audits:
- before production releases
- after major UI redesigns
- after navigation changes
- after localization changes
- after animation-system changes

Rules:
- Accessibility audits must remain repeatable.
- High-risk UI changes require accessibility validation before release.