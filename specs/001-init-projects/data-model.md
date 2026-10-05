# Data Model: Project Foundation (Init Projects)

**Feature**: [spec.md](./spec.md) | **Date**: 2026-10-06

No database tables are added. Prisma starts from an empty initial migration. The entities below
are API response shapes and client-side state. Endpoints are described in
[contracts/api.md](./contracts/api.md).

## HealthStatus (`GET /v1/health`)

| Field | Type | Rules |
|-------|------|-------|
| `status` | `"ok"` \| `"degraded"` | `degraded` when any check is down |
| `version` | string | API package version |
| `uptimeSeconds` | integer ≥ 0 | |
| `checks.database` | `"ok"` \| `"down"` | |
| `timestamp` | ISO-8601 UTC string | |

The HTTP status is 200 when `ok` and 503 when `degraded`.

## VersionInfo (`GET /v1/version`)

| Field | Type | Rules |
|-------|------|-------|
| `serverVersion` | semver string | API package version |
| `minMobileVersion` | semver string | from `MIN_MOBILE_VERSION` |
| `minAdminWebVersion` | semver string | from `MIN_ADMIN_WEB_VERSION` |
| `environment` | `"development"` \| `"staging"` \| `"production"` | from `APP_ENV` |

## ApiError (every error response)

```json
{ "error": { "code": "NOT_FOUND", "message": "…", "details": [] }, "requestId": "…" }
```

`code` is uppercase snake case. Initial codes: `VALIDATION_FAILED` (400), `NOT_FOUND` (404),
`INTERNAL_ERROR` (500).

## Role (mobile)

`agent` | `admin`. It drives which navigation shell is shown.

## Session (mobile, in-memory for now)

| Field | Type | Rules |
|-------|------|-------|
| `userId` | string | `dev-agent` / `dev-admin` from the debug picker |
| `role` | Role | |

Transitions: `null → Session` (sign in) and `Session → null` (sign out). The authentication
feature replaces the debug picker as the source of the session.

## Compatibility (both clients)

`checking → compatible | updateRequired | unreachable`. The client compares its own version
with `minMobileVersion` or `minAdminWebVersion`. If the backend can't be reached, it shows
`unreachable` with a retry action.
