# Contract: API v1 (foundation)

The OpenAPI document is generated from the Fastify route schemas by `@fastify/swagger` and
served at `GET /docs` (JSON at `/docs/json`). This file lists only what the foundation adds.

All responses include an `X-Request-Id` header, echoed from the request or generated. Errors use
the `ApiError` shape in [data-model.md](../data-model.md).

| Method | Path | Success | Failure |
|--------|------|---------|---------|
| GET | `/v1/health` | 200 `HealthStatus` (`status: "ok"`) | 503 `HealthStatus` (`status: "degraded"`, `checks.database: "down"`) |
| GET | `/v1/version` | 200 `VersionInfo` | 500 `ApiError` |
| GET | any unknown path | — | 404 `ApiError` (`NOT_FOUND`) |

Behavior guarantees:

- The API starts and serves `/v1/health` while the database is unreachable, and reports `ok`
  again without a restart once the database is back.
- The API refuses to start when a required environment variable is missing, and the error names
  the variable.
