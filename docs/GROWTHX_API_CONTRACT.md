# GrowthX Partner App — Proposed API Contract

**Status:** Draft for backend alignment  
**Frontend reviewed:** `teambackoffice/growthx_app` branch `main`  
**Important:** The current repository is a UI-only Flutter app built on dummy/in-memory data. No backend API integration, service layer, OpenAPI spec, or concrete API base URL is present. This contract is proposed from the app's screens and Dart models; route paths, authentication mechanism, exact field names, pagination, and business rules must be confirmed with the backend team.

## 1. API conventions

- Base URL: environment-specific, e.g. `https://<api-host>/api/v1` (placeholder; do not ship as-is).
- Transport: HTTPS + JSON, UTF-8.
- Auth: Bearer access token for all partner endpoints except login, password reset request, and refresh.
- Timestamps: ISO-8601 UTC; dates without time use `YYYY-MM-DD`.
- Currency: INR; amounts are decimal numbers, not formatted strings.
- IDs: opaque strings; clients must not infer IDs from display labels.
- List endpoints should support `page`, `page_size`, optional filters, and return pagination metadata.
- Mutations should return the persisted resource and validation errors, not a UI-only success flag.

### Standard response envelope (recommended)

```json
{
  "data": {},
  "meta": {
    "request_id": "req_123",
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total": 82,
      "has_more": true
    }
  },
  "error": null
}
```

For errors:

```json
{
  "data": null,
  "meta": { "request_id": "req_123" },
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Please check the highlighted fields.",
    "fields": { "email": "Enter a valid email address." }
  }
}
```

Use appropriate HTTP codes: 400 malformed request, 401 unauthenticated/expired token, 403 forbidden, 404 missing resource, 409 conflict/duplicate, 422 validation/business rule failure, 429 rate-limited, 500 unexpected server error.

## 2. Endpoint inventory

All paths below are **proposed**, not found in the repository.

| Area | Method | Proposed endpoint | Purpose |
|---|---|---|---|
| Auth | POST | `/auth/login` | Sign in and issue tokens |
| Auth | POST | `/auth/refresh` | Refresh access token |
| Auth | POST | `/auth/logout` | Revoke refresh/session token |
| Auth | POST | `/auth/password/forgot` | Request reset email |
| Auth | POST | `/auth/password/reset` | Apply reset token + new password |
| Home | GET | `/partner/dashboard` | Aggregated home metrics/activity |
| Customers | GET | `/partner/customers` | Search/filter/paginate customers |
| Customers | GET | `/partner/customers/{customerId}` | Customer detail |
| Referrals | GET | `/partner/referrals/summary` | Clicks, sign-ups, conversions |
| Referrals | GET | `/partner/campaigns` | Campaigns and performance |
| Referrals | GET | `/partner/referral-link` | Partner referral code/link/QR payload |
| Leads | GET | `/partner/leads` | List/filter leads |
| Leads | POST | `/partner/leads` | Create lead |
| Leads | PATCH | `/partner/leads/{leadId}` | Update lead fields/status |
| Earnings | GET | `/partner/earnings/summary` | Current/previous month and balances |
| Earnings | GET | `/partner/commissions` | Commission ledger/filter |
| Earnings | GET | `/partner/payouts` | Payout history |
| Earnings | GET | `/partner/payouts/{payoutId}` | Payout detail with commission lines |
| Notifications | GET | `/partner/notifications` | List notifications/filter unread |
| Notifications | PATCH | `/partner/notifications/{notificationId}` | Mark one read |
| Notifications | POST | `/partner/notifications/read-all` | Mark all read |
| Notifications | DELETE | `/partner/notifications/{notificationId}` | Dismiss notification (optional) |
| Profile | GET | `/partner/profile` | Current partner profile |
| Profile | PATCH | `/partner/profile` | Edit editable contact fields |
| Profile | GET | `/partner/notification-preferences` | Read preferences |
| Profile | PATCH | `/partner/notification-preferences` | Save preferences |
| Profile | PATCH | `/partner/payout-method` | Update bank/UPI details; protected flow |

## 3. Proposed schemas

### 3.1 Authentication

**POST `/auth/login` request**
```json
{ "email": "partner@example.com", "password": "user-entered-password", "device": { "platform": "android", "app_version": "1.0.0" } }
```

**Response data**
```json
{
  "access_token": "<token>",
  "refresh_token": "<token>",
  "token_type": "Bearer",
  "expires_in": 3600,
  "partner": {
    "id": "partner_1042",
    "name": "Partner Name",
    "email": "partner@example.com",
    "status": "active"
  }
}
```

Password reset request: `POST /auth/password/forgot` with `{"email":"partner@example.com"}`. Return a generic accepted message whether or not the email is registered to avoid account enumeration. Reset confirmation: `POST /auth/password/reset` with `{"token":"...","new_password":"..." }`.

### 3.2 Dashboard

**GET `/partner/dashboard?activity_limit=4&commission_limit=3`**

```json
{
  "data": {
    "partner": { "id": "partner_1042", "name": "Partner Name" },
    "earnings": {
      "this_month": 4250.0,
      "last_month": 3700.0,
      "pending": 6250.0,
      "approved": 4200.0,
      "paid_lifetime": 18200.0,
      "next_payout_date": "2026-11-15",
      "currency": "INR"
    },
    "new_customers_this_month": 3,
    "trials_ending_next_7_days": 2,
    "recent_customers": [],
    "recent_commissions": [],
    "unread_notifications": 2
  }
}
```

The app currently derives many of these values client-side from all commissions and customers. A single dashboard aggregate is recommended to avoid inconsistent totals and excessive requests.

### 3.3 Customers

**GET `/partner/customers?page=1&page_size=20&search=clinic&status=trial&segment=trials_ending_soon`**

Allowed `status`: `trial | active | past_due | cancelled`.  
Allowed `segment`: `trials_ending_soon | joined_this_month`.

Customer object:
```json
{
  "id": "cus_123",
  "business_name": "Example Clinic",
  "contact_name": "Contact Person",
  "phone": "+91XXXXXXXXXX",
  "email": "contact@example.com",
  "city": "Kochi",
  "plan": { "code": "growth", "name": "Growth", "monthly_price": 2499, "currency": "INR" },
  "subscription_status": "trial",
  "joined_at": "2026-10-02T09:30:00Z",
  "trial_ends_on": "2026-10-20",
  "renews_on": null,
  "source": { "type": "referral_link", "label": "Referral link", "campaign_id": null }
}
```

**GET `/partner/customers/{customerId}`** returns the same customer schema plus agreed subscription/payment timeline and commissions attributable to that customer (if authorized).

### 3.4 Referrals and campaigns

**GET `/partner/referrals/summary`**
```json
{
  "data": {
    "clicks": 342,
    "signups": 18,
    "conversions": 7,
    "conversion_rate": 0.3889,
    "period": { "from": "2026-10-01", "to": "2026-10-31" }
  }
}
```

**GET `/partner/referral-link`**
```json
{
  "data": {
    "referral_code": "PARTNER42",
    "url": "https://growthx.teambackoffice.com/r/PARTNER42",
    "qr_payload": "https://growthx.teambackoffice.com/r/PARTNER42"
  }
}
```

**GET `/partner/campaigns?page=1&page_size=20&status=active`** item schema:
```json
{
  "id": "campaign_123",
  "name": "Campaign Name",
  "description": "Campaign description",
  "code": "OFFER25",
  "offer": "Offer details",
  "starts_on": "2026-10-01",
  "ends_on": "2026-11-30",
  "status": "active",
  "stats": { "clicks": 186, "signups": 9, "conversions": 3 }
}
```

Note: current app creates campaign links as `/r/{partnerCode}?c={campaignCode}`; confirm this URL contract with web/backend tracking.

### 3.5 Leads

**POST `/partner/leads`**
```json
{
  "contact_name": "Priya Krishnan",
  "business_name": "Krishna Silks",
  "phone": "+919846033412",
  "email": "priya@example.com",
  "city": "Thrissur",
  "interested_plan": "growth",
  "notes": "Interested in inventory and billing"
}
```

Response `201` returns the persisted lead:
```json
{
  "data": {
    "id": "lead_123",
    "contact_name": "Priya Krishnan",
    "business_name": "Krishna Silks",
    "phone": "+919846033412",
    "email": "priya@example.com",
    "city": "Thrissur",
    "interested_plan": "growth",
    "notes": "Interested in inventory and billing",
    "status": "new",
    "created_at": "2026-10-14T06:00:00Z",
    "updated_at": "2026-10-14T06:00:00Z"
  }
}
```

**PATCH `/partner/leads/{leadId}`** request may update only fields that the partner is allowed to edit; for status use `{"status":"contacted"}`. Suggested statuses: `new | contacted | demo_scheduled | converted | lost`. Keep API enums stable and map them to display labels in Flutter. The backend should validate phone/email and enforce duplicate rules.

### 3.6 Earnings, commissions, payouts

**GET `/partner/earnings/summary`**
```json
{
  "data": {
    "currency": "INR",
    "this_month": 4250.0,
    "last_month": 3700.0,
    "pending": 6250.0,
    "approved": 4200.0,
    "paid_lifetime": 18200.0,
    "lifetime_total": 28650.0,
    "next_payout_date": "2026-11-15",
    "tds_rate": 0.02
  }
}
```

**GET `/partner/commissions?page=1&page_size=20&status=pending&type=recurring&customer_id=cus_123&from=2026-10-01&to=2026-10-31`**

Commission item:
```json
{
  "id": "com_123",
  "title": "Example Clinic",
  "type": "first_month",
  "amount": 1250.0,
  "currency": "INR",
  "status": "pending",
  "earned_at": "2026-10-06T12:00:00Z",
  "customer_id": "cus_123",
  "payout_id": null,
  "review_until": "2026-11-05T12:00:00Z"
}
```

Types represented in UI: `first_month | recurring | bonus`. Statuses: `pending | approved | paid`. Prefer `earned_at` over ambiguous `date`.

**GET `/partner/payouts`** payout item:
```json
{
  "id": "pay_123",
  "reference": "GXP-2026-0318",
  "period": "2026-09",
  "paid_at": "2026-10-15T10:00:00Z",
  "status": "paid",
  "method": { "type": "bank", "bank_name": "HDFC Bank", "account_last4": "7812" },
  "gross_amount": 5000.0,
  "tds_amount": 100.0,
  "net_amount": 4900.0,
  "currency": "INR",
  "commissions": []
}
```

**GET `/partner/payouts/{payoutId}`** returns payout plus commission line items. Never return full bank account numbers in normal profile/payout responses; expose masked account details only. TDS rules and payout date/status are financial business rules and must be confirmed with finance/backend—not hard-coded only in the app.

### 3.7 Notifications

**GET `/partner/notifications?page=1&page_size=20&unread_only=false&category=commission`**

```json
{
  "data": [{
    "id": "ntf_123",
    "category": "commission",
    "title": "Commission earned",
    "body": "Your commission is under review.",
    "created_at": "2026-10-14T08:00:00Z",
    "read_at": null,
    "deep_link": { "type": "earnings", "id": null }
  }]
}
```

**PATCH `/partner/notifications/{notificationId}`** body `{"read":true}`; **POST `/partner/notifications/read-all`** marks all current partner notifications read. Use a typed `deep_link` rather than exposing Flutter route strings from the server. `DELETE` dismissal is optional because the current app has a local remove action but no persistent backend behavior.

Categories shown in the UI: `commission | payout | customer | trial | account`.

### 3.8 Profile and preferences

**GET `/partner/profile`**
```json
{
  "data": {
    "id": "partner_1042",
    "name": "Partner Name",
    "tier": "Silver Partner",
    "email": "partner@example.com",
    "phone": "+91XXXXXXXXXX",
    "city": "Kochi, Kerala",
    "company": "Example Business",
    "gstin": null,
    "pan_masked": "ABCDE****F",
    "bank": { "name": "HDFC Bank", "account_last4": "7812", "ifsc": "HDFC0001234" },
    "upi_id": "partner@upi",
    "member_since": "2025-03-14",
    "referral_code": "PARTNER42"
  }
}
```

**PATCH `/partner/profile`** editable fields: `name, phone, city, company` unless business requirements specify otherwise. Do not allow changing tier, partner ID, referral code, verification status, or commission rate from the profile update endpoint.

**GET/PATCH `/partner/notification-preferences`**
```json
{
  "data": {
    "commissions": true,
    "trial_reminders": true,
    "product_updates": false
  }
}
```

**PATCH `/partner/payout-method`** is recommended as a separately authorized/verified operation. It must not accept changes without server-side verification (e.g. OTP/re-authentication); audit all changes. Mask PAN and account number on read.

## 4. Enums and mapping

| UI concept | Suggested API values |
|---|---|
| Customer status | `trial, active, past_due, cancelled` |
| Plan | `starter, growth, pro` |
| Lead status | `new, contacted, demo_scheduled, converted, lost` |
| Commission status | `pending, approved, paid` |
| Commission type | `first_month, recurring, bonus` |
| Payout status | `processing, paid, failed` (confirm if `failed` is needed) |
| Notification category | `commission, payout, customer, trial, account` |
| Campaign status | `active, scheduled, ended, paused` |

The Flutter app uses labels such as “Not interested” for a lead with status `lost`, and “Under review” for commission `pending`. Treat these as presentation labels, not API enums.

## 5. Backend decisions required before implementation

1. Confirm base URL, API version, auth provider, access/refresh token policy and session revocation.
2. Confirm canonical field names, IDs, nullable fields, date/time formats, pagination and sort order.
3. Confirm partner scoping and authorization on every endpoint; a partner must never retrieve another partner's customers, commissions, leads, payout or profile.
4. Confirm lead duplicate rules, editable statuses, conversion ownership and whether partners may update status.
5. Confirm commission policy: current README mentions 50% of first monthly payment and 20% of later payments, 30-day review, 2% TDS and payout on the 15th. These are documented as placeholders and require business/finance approval.
6. Confirm campaigns are global or partner-targeted, and attribution rules for referral code + campaign code.
7. Confirm how password reset, push-notification delivery, deep links, profile verification and payout-method changes are handled.
8. Provide sample success/error responses or Swagger/OpenAPI from the actual backend.

## 6. Frontend review notes relevant to API integration

- Current auth accepts any valid-looking email and a password of at least six characters; the literal password `wrongpass` only simulates an error. Replace with real API authentication.
- The app has no HTTP client or API service package in `pubspec.yaml`; implement a centralized client (e.g. Dio or the existing preferred HTTP stack), token/session storage, interceptors, timeout and typed error handling.
- Providers currently read dummy lists / notifiers. Replace data sources behind existing Riverpod providers so screens remain mostly unchanged, as README recommends.
- Persist lead creation/status changes, profile edits, notification read state and preferences through API calls; currently these changes are in-memory and reset on restart.
- Keep money calculations, authorization, commission approval, TDS and payout state authoritative on the backend. The client should display server-calculated values.
- Add tests for serialization, 401 refresh/logout, pagination, empty/loading/error states, duplicate submission, and stale/offline responses.

## 7. Suggested delivery sequence

1. Backend publishes OpenAPI/Swagger + auth and common response/error contract.
2. Implement auth/session and profile.
3. Implement dashboard + customers.
4. Implement leads, referral links, campaigns.
5. Implement commissions + payouts.
6. Implement notifications/preferences.
7. Run integration tests against development/UAT and validate business rules.

