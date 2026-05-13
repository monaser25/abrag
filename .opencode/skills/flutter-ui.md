---
description: Flutter UI engineering rules, widget architecture, and responsive design skill
mode: skill
tools:
  "*": false
  read: true
---

# Flutter UI Engineering Rules

## Design System Rules

- Always reuse existing theme tokens and shared widgets.
- Never hardcode colors, spacing, typography, or border radius.
- Prefer Theme.of(context).colorScheme and textTheme.
- Preserve dark/light theme compatibility automatically.

---

## RTL/LTR Rules

- Prefer directional APIs:
  - EdgeInsetsDirectional
  - AlignmentDirectional
  - Positioned.directional
- Ensure layouts work correctly in both RTL and LTR.

---

## Responsive Layout Rules

- Support mobile, tablet, desktop, and web layouts.
- Use LayoutBuilder for local responsiveness.
- Use MediaQuery only for screen-level decisions.
- Avoid fixed-width responsive layouts.

---

## Widget Architecture Rules

- Prefer stateless widgets whenever possible.
- Prefer composition over inheritance.
- Extract reusable widgets aggressively.
- Avoid giant build methods and deep widget nesting.
- Split widgets when readability decreases.

---

## Rebuild Optimization Rules

- Minimize unnecessary widget rebuilds.
- Scope rebuilds to the smallest subtree possible.
- Prefer const constructors aggressively.
- Avoid expensive synchronous work inside build().

---

## Animation Rules

- Prefer implicit animations for simple transitions.
- Use AnimationController only when necessary.
- Dispose animation controllers correctly.
- Never create controllers inside build().

---

## Accessibility Rules

- Ensure tappable areas are accessible.
- Use Semantics where appropriate.
- Avoid relying only on color for meaning.
- Preserve keyboard accessibility on desktop/web.

---

## Design Translation Rules

- Preserve visual hierarchy before pixel perfection.
- Normalize HTML/Tailwind layouts into Flutter-native patterns.
- Avoid DOM-like widget trees.
- Prefer Flutter-native UX patterns over direct HTML recreation.

---

## Code Quality Rules

- Maintain analyzer-clean code.
- Avoid magic numbers.
- Reuse shared abstractions.
- Preserve existing project architecture.