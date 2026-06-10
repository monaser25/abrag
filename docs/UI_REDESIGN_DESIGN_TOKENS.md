# UI Redesign — Design Tokens (extracted from `abrag/` prototype)

Source: `abrag/styles.css`, `abrag/frame.css`, `abrag/app.jsx` (TWEAK_DEFAULTS), `abrag/components.jsx`.
Target: `lib/core/theme/` (replace contents of `app_colors.dart`, `app_typography.dart`, `app_theme.dart`; add `app_spacing.dart`, `app_radius.dart`, `app_shadows.dart`) + `lib/shared/widgets/` kit.

## 1. AppColors

```dart
class AppColors {
  // Brand (prototype TWEAK_DEFAULTS)
  static const brand       = Color(0xFF1B5CF0); // royal blue
  static const accent      = Color(0xFFFCBC15); // amber sun
  static const brandInk    = Color(0xFFFFFFFF); // text on brand
  static const accentInk   = Color(0xFF1A1300); // text on amber

  // Dark theme (default)
  static const bg          = Color(0xFF080C24); // deep indigo
  static const bg2         = Color(0xFF0A1030); // gradient lower
  static const surface     = Color(0xFF111A44); // card
  static const surface2    = Color(0xFF18225A); // raised
  static const surface3    = Color(0xFF1F2C6E); // hover / input fill
  static const border      = Color(0xFF283577);
  static const border2     = Color(0xFF34439A);
  static const ink         = Color(0xFFEAF0FF); // primary text
  static const ink2        = Color(0xFFA7B4E6); // secondary
  static const ink3        = Color(0xFF6E7CB8); // tertiary / hints

  // Soft tints = base color at low alpha (prototype uses rgba/color-mix)
  static const brandSoft   = Color(0x291B5CF0); // 16%
  static const accentSoft  = Color(0x24FCBC15); // 14%

  // Seasons
  static const summer      = Color(0xFFFCBC15);
  static const summerSoft  = Color(0x24FCBC15);
  static const winter      = Color(0xFF36C6F0);
  static const winterSoft  = Color(0x2436C6F0);

  // Status
  static const ok          = Color(0xFF34D6A0);
  static const okSoft      = Color(0x2434D6A0);
  static const warn        = Color(0xFFFCBC15);
  static const warnSoft    = Color(0x24FCBC15);
  static const err         = Color(0xFFFB5A66);
  static const errSoft     = Color(0x24FB5A66);
}
```

### Light theme (prototype `.theme-light`) — if approved in scope

| Token | Value |
|---|---|
| bg / bg2 | `#EEF2FE` / `#E4EAFB` |
| surface / 2 / 3 | `#FFFFFF` / `#F5F7FF` / `#ECF0FE` |
| border / 2 | `#DBE2F6` / `#C7D2F0` |
| ink / 2 / 3 | `#0B1437` / `#4A568A` / `#8390BD` |
| summer / winter | `#E89A00` / `#0E9CC8` |
| ok / warn / err | `#0E9E73` / `#C98A00` / `#D63B47` |

Recommended implementation: a `ThemeExtension<AbragColors>` so widgets read semantic tokens (`context.colors.surface2`) and light mode becomes a data swap.

## 2. Typography (AppTextStyles)

Font: **IBM Plex Sans Arabic** (already shipped in `assets/fonts/` — Regular 400, Medium 500, Bold 700; prototype also uses 600 → map SemiBold usages to 700 or add the SemiBold weight file).

| Token | Size | Weight | Notes |
|---|---|---|---|
| display | 30 | 700 | line-height 1.2, letter-spacing −0.01em |
| h1 | 24 | 700 | 1.3 |
| h2 | 20 | 700 | 1.32 |
| h3 | 17 | 600 | 1.4 |
| title | 15.5 | 600 | 1.35 |
| body | 14.5 | 400 | 1.5 |
| bodyS | 13 | 400 | 1.45, color ink2 |
| label | 12 | 600 | 1.3, +0.02em |
| caption | 11 | 500 | 1.4, color ink3, +0.03em |
| num | — | — | tabular figures: `FontFeature.tabularFigures()` — apply to all money/counters |

## 3. Spacing scale (4pt)

`s1=4, s2=8, s3=12, s4=16, s5=20, s6=24, s7=32, s8=40, s9=56`
Screen body padding: `EdgeInsetsDirectional.fromSTEB(16, 0, 16, 28)`. App bar padding 18h.

## 4. Radius scale

Base radius **18** (logo's rounded square): `sm = 9` (base × .5), `md = 18`, `lg = 27` (base × 1.5), `pill = 999`.
Component specifics: icon tile 14, icon button 13, FAB 18, mini-tile 11, skeleton 10, paper/receipt 14, empty-orb 28, segmented control 14 outer / 10 inner.

## 5. Shadows / elevation

| Token | Flutter |
|---|---|
| shadow (card, dark) | `[BoxShadow(0,1,2, black 40%), BoxShadow(0,12,32, spread -12, black 60%)]` |
| shadowSm | `[BoxShadow(0,1,2, black 35%)]` |
| glow (brand) | brand ring 1px @40% + `BoxShadow(0,8,30, spread -8, brand 55%)` |
| btn-primary glow | `BoxShadow(0,6,18, spread -8, accent)` |
| fab glow | `BoxShadow(0,10,26, spread -8, accent)` |

Card styles are tweakable in prototype (elevated / flat / bordered) — ship **elevated** as default.

## 6. Component specs (→ `lib/shared/widgets/`)

| Prototype | Spec | Flutter widget |
|---|---|---|
| `.btn` | h48, radius sm, weight 600, size 15; primary=accent bg + accentInk; royal=brand bg; ghost=surface3; outline=border2 1px; sm=h38/13.5 | `AppButton(variant: primary/royal/ghost/outline, small)` |
| `.field` | h50, surface3 fill, border 1px, radius sm, focus: brand border + 3px brandSoft ring | `InputDecorationTheme` + `AppTextField` |
| `.chip` | h26, pill, 11.5/600, soft bg + colored text, optional 6px dot or 12px icon | `StatusChip(kind: ok/warn/err/summer/winter/neutral/brand)` |
| `StatCard` | card p16, 38px icon tile (15% tint), display-size value, bodyS label | `StatCard` |
| `NavRow` | 40px icon tile, title+caption, chevron (direction-aware), optional badge | `NavRow` |
| `SectionTitle` | label style, dim, uppercase-ish letterspacing, optional trailing action | `SectionTitle` |
| `DetailRow` | label bodyS / value body|title, 11px vertical padding | `DetailRow` |
| `Loading` | 3 skeleton cards (shimmer 1.4s) + spinner caption | `LoadingSkeleton` |
| `EmptyState` | 84px orb (brandSoft, dashed halo) + h3 + bodyS + action + skyline accent | `EmptyState` |
| `ErrorState` | err orb + retry outline button; copy mentions local data safety | `ErrorState` |
| `Fab` | h54, radius 18, accent, label+icon, bottom-end 22/18 | `AppFab` |
| `Avatar` | initials circle, tint 18% bg, weight 700 | `AppAvatar` |
| `MiniMetric` / `MiniNav` | 34/36px tiles, compact metric & nav tiles | `MiniMetric`, `MiniNavCard` |
| `AppBar` | transparent, back = direction-aware chevron, h3 title (h1 when large) + caption sub, trailing 42px icon buttons w/ amber badge | `AbragAppBar` |
| `.segs` | segmented tabs: surface2 track r14, active seg surface + shadowSm r10, h34 | `SegmentedTabs` |
| `.toggle` | 42×25 pill, brand when on | `Switch` themed |
| `.prog` | h7 r5 track surface3, fill accent, animated | `AppProgressBar` |
| `.apt` cell | square, radius sm, surface + border, 22/700 number, 9px status dot | `ApartmentCell` |
| `.tl` timeline | 2px line, 12px nodes: paid=ok filled, due=outline | `PaymentTimeline` |
| `.season-hero` | radius lg, 135° gradient summer/winter tint → surface | `SeasonHero` |
| `.paper` | receipt card r14 + shadow | `StatementPaper` |
| `.actionbar` | bottom bar, top border, bg fade, safe-area padding | `BottomActionBar` |
| `Skyline` | towers silhouette SVG accent (empty states, footers) | `SkylineAccent` (CustomPainter) |
| `.app-field` | page bg: radial brand 16% glow at top + bg→bg2 vertical gradient | `AppBackground` wrapper |
| Icons | 24-box line icons, stroke 2, round caps | Closest Material rounded/outlined icons; custom `CustomPainter` only where no match (skyline, meter) |

## 7. Motion

- Screen enter: translateY 9px → 0, 300ms, cubic-bezier(.22,.61,.36,1); honor `MediaQuery.disableAnimations`.
- Tap feedback: scale .98 (cards) / .92 (icon buttons) — `AnimatedScale` or ink response.
- Skeleton shimmer 1.4s; spinner = rotating sync icon 1s linear.
- Progress fill 500ms with same curve.

## 8. Naming decision

Keep file names `app_colors.dart` / `app_theme.dart`; rename `AppTypography` → keep class but add `AppTextStyles` tokens (request asked for `AppTextStyles`). Old color constants (`navyBackground`, `goldPrimary`, …) are referenced across ~60 screens — they will be **kept temporarily as deprecated aliases** pointing at new tokens during Phases 1–7 and deleted in Phase 8.
