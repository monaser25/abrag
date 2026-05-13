---
description: Flutter Play Store and App Store release readiness validation skill
mode: skill
tools:
  "*": false
  read: true
---

# Flutter Play Store Readiness Skill

This skill defines the complete checklist and validation rules for releasing a Flutter application to Google Play Store and Apple App Store.

All agents must apply these standards before a project is declared release-ready.

---

## Release Readiness Philosophy

A production release is not just working code.
It is a complete, signed, accessible, secure, policy-compliant application that real users can install and trust.

Never declare a project complete without passing every gate below.

---

## Technical Release Gates

### Build and Compilation

- [ ] `flutter analyze` passes with zero warnings
- [ ] `flutter build apk --release` compiles successfully
- [ ] `flutter build appbundle --release` compiles successfully
- [ ] `flutter build ios --release` compiles successfully (if iOS target)
- [ ] No debug-only code in release build
- [ ] No `print()` statements in production code
- [ ] No `debugPrint()` in production code
- [ ] ProGuard / R8 rules configured for Android
- [ ] Bitcode settings correct for iOS

### Signing and Identity

- [ ] Android signing keystore generated and configured
- [ ] keystore file excluded from version control
- [ ] `key.properties` excluded from version control
- [ ] iOS signing configured (certificates and provisioning profiles)
- [ ] Bundle ID / Application ID finalized and unique
- [ ] App version name and version code set correctly

### Security

- [ ] No API keys or secrets in source code
- [ ] No credentials in version control
- [ ] `.env` files in `.gitignore`
- [ ] `google-services.json` handling reviewed
- [ ] Secure storage used for all sensitive local data
- [ ] HTTPS enforced — no plain HTTP calls
- [ ] Certificate pinning applied where required

---

## Quality Release Gates

### State Handling

Every screen and feature must handle:
- [ ] Loading state (skeleton or spinner)
- [ ] Error state (actionable message with retry)
- [ ] Empty state (helpful guidance)
- [ ] Offline state (graceful degradation)

### Responsiveness

- [ ] Layout verified on small phone (360dp)
- [ ] Layout verified on standard phone (390dp)
- [ ] Layout verified on large phone (430dp)
- [ ] Layout verified on tablet (768dp+)
- [ ] No overflow errors on any screen size
- [ ] No fixed-width layouts that break on small screens

### Theme

- [ ] Dark mode fully implemented and tested
- [ ] Light mode fully implemented and tested
- [ ] No hardcoded colors anywhere
- [ ] No hardcoded spacing anywhere
- [ ] All text scales correctly under accessibility font sizes

### Localization and RTL

- [ ] Localization scaffold in place (even if only one language)
- [ ] No hardcoded user-facing strings
- [ ] RTL layout verified for Arabic/Hebrew support
- [ ] `EdgeInsetsDirectional` used throughout
- [ ] `AlignmentDirectional` used throughout

---

## Accessibility Release Gates

- [ ] All tappable elements meet 48x48dp minimum touch target
- [ ] WCAG AA contrast ratio met (4.5:1 for text)
- [ ] Semantic labels present on icons and images
- [ ] Screen reader navigation verified
- [ ] No content communicated by color alone
- [ ] Focus order is logical and predictable
- [ ] Reduced motion preference respected

---

## Performance Release Gates

- [ ] App startup time acceptable (< 3 seconds cold start)
- [ ] No jank on main scrolling screens
- [ ] No memory leaks in long-lived screens
- [ ] Images optimized and cached
- [ ] No unnecessary rebuilds on hot paths
- [ ] Background processes battery-efficient

---

## Crash Reporting and Analytics Gates

- [ ] Crash reporting integrated and tested (Firebase Crashlytics or Sentry)
- [ ] `FlutterError.onError` hooked into crash reporting
- [ ] `PlatformDispatcher.instance.onError` hooked
- [ ] Zone-level error capture configured
- [ ] Analytics initialized and first events firing
- [ ] No PII logged in analytics or crash reports
- [ ] Analytics events verified in dashboard before release

---

## Google Play Store Requirements

### App Content

- [ ] App icon: 512x512 PNG, no alpha, no rounded corners (Play applies them)
- [ ] Feature graphic: 1024x500 PNG
- [ ] Screenshots: minimum 2, maximum 8 per device type
  - Phone screenshots: 1080x1920 minimum
  - 7-inch tablet (optional but recommended)
  - 10-inch tablet (optional but recommended)
- [ ] Short description: max 80 characters
- [ ] Full description: max 4000 characters
- [ ] Content rating questionnaire completed

### Policy Compliance

- [ ] Privacy policy URL provided and accessible
- [ ] Privacy policy covers all data collected
- [ ] Permissions declared with rationale
- [ ] No permissions requested unnecessarily
- [ ] Data safety section completed in Play Console
- [ ] Target SDK version meets current Play requirements (API 34+)
- [ ] App does not violate Google Play Developer Program Policies

### Technical Play Requirements

- [ ] AAB (Android App Bundle) used — not APK
- [ ] Target API level meets Play requirements
- [ ] 64-bit support included
- [ ] App size reasonable (< 150MB recommended for AAB)
- [ ] Adaptive icons configured for Android 8.0+
- [ ] Splash screen follows Android 12+ guidelines

---

## Apple App Store Requirements (if applicable)

### App Content

- [ ] App icon: 1024x1024 PNG (no alpha)
- [ ] Screenshots for all required device sizes
- [ ] App Store description written
- [ ] Keywords researched and added
- [ ] Support URL provided
- [ ] Privacy policy URL provided

### Policy Compliance

- [ ] Privacy nutrition labels completed accurately
- [ ] No private API usage
- [ ] All permissions have usage description strings in Info.plist
- [ ] App follows App Store Review Guidelines
- [ ] In-app purchases configured correctly (if applicable)

---

## Pre-Release Testing Gate

- [ ] App tested on physical Android device (not just emulator)
- [ ] App tested on physical iOS device (if iOS target)
- [ ] App tested on slow network (3G simulation)
- [ ] App tested with no network (airplane mode)
- [ ] App tested with low storage
- [ ] App tested from fresh install (no cached data)
- [ ] App tested after force-close and reopen
- [ ] App tested after system language change
- [ ] App tested with large accessibility font size

---

## Final Declaration

A project is declared **release-ready** only when:

1. All Technical Release Gates pass ✅
2. All Quality Release Gates pass ✅
3. All Accessibility Gates pass ✅
4. All Performance Gates pass ✅
5. All Crash Reporting Gates pass ✅
6. All Store Requirements pass ✅
7. Pre-Release Testing complete ✅

Any failing gate must be resolved before release approval.
Critical and High severity issues block release unconditionally.
