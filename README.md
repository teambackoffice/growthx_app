# GrowthX Partner

Flutter app for TBO GrowthX sales partners: people who refer businesses to
GrowthX and earn commission on every paying customer. Partners track earnings
and payouts, follow their referred customers, share referral links and QR
codes, and add leads.

> **Status:** UI complete on local dummy data. No backend or API integration
> yet; changes (new leads, profile edits, read notifications) reset on restart.

## Getting started

Requires Flutter 3.47+ (Dart 3.13+).

```bash
flutter pub get
flutter run
```

**Demo sign-in:** any well-formed email and a password of 6+ characters.
The password `wrongpass` shows the sign-in error state.

## Screens

| Area | Screens |
| --- | --- |
| Auth | Sign in, Forgot password |
| Tabs (bottom navigation) | Home, Customers, Referrals, Earnings, More |
| Detail | Customer details, Leads, Add lead, Payout details, Notifications, Profile, Edit profile |

## Project structure

```
lib/
  main.dart                 Entry point (ProviderScope)
  app/                      App widget, router, route paths, tab shell + nav bar
  core/
    theme/                  Colours, spacing, motion tokens, Material theme
    widgets/                Shared components (cards, badges, pills, skeletons, motion)
    utils/                  INR/date formatting, validators, snackbars, dialogs, share/call
  features/<feature>/
    data/                   Models, dummy data, Riverpod providers
    presentation/           Screens and feature widgets
assets/fonts/               Inter (OFL licence included)
test/app_smoke_test.dart    Widget tests
```

Features: `auth`, `home`, `customers`, `referrals`, `leads`, `earnings`,
`notifications`, `profile`.

## How it works

- **State:** Riverpod. Read-only lists are `Provider`s; things the user changes
  (auth, leads, notifications, profile, filters) are `Notifier`s; totals and
  filtered lists are derived providers, so every screen shows the same numbers.
- **Navigation:** GoRouter. Signed-out users are redirected to Sign in. The five
  tabs use a `StatefulShellRoute`, so each keeps its own state; Android Back on
  a tab returns to Home. Detail screens are top-level routes
  (`/customer/:id`, `/payout/:id`, ...). Paths live in `lib/app/routes.dart`.
- **Dummy data:** each feature's `data/*_dummy_data.dart`. Dates are computed
  relative to today so labels like "trial ends tomorrow" stay correct.
- **Design:** tokens in `lib/core/theme/`. Animations are 150–350 ms and switch
  off when the OS reduce-motion setting is on.

### Business rules (placeholders, to be confirmed)

Commission is 50% of a customer's first monthly payment and 20% of each
payment after that. Commissions are under review for 30 days, then approved,
then paid on the 15th of the month after 2% TDS.

## Connecting a backend

Replace the dummy data behind each feature's providers with API calls and keep
the provider names and types. Screens read only from providers, so they should
not need changes. Real auth and session storage go in
`lib/features/auth/data/auth_providers.dart`.

## Checks

```bash
dart format .
flutter analyze
flutter test
```

The tests run on a 320 × 568 screen, so any overflowing or clipped layout
fails. They cover sign-in, every tab and detail screen, filters, forms,
notifications, logout, reduced motion and Android Back.

## Packages

`flutter_riverpod`, `go_router`, `intl`, `qr_flutter`, `share_plus`,
`url_launcher`.
