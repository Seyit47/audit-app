# Quickstart & Validation: Project Foundation

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Prerequisites

- Node 24, pnpm (pinned in the root `package.json`), and Flutter stable (3.47+).
- PostgreSQL with two databases, one for development and one for tests. To create them on the
  local server once:

  ```bash
  sudo -u postgres psql -c "CREATE ROLE audit LOGIN CREATEDB PASSWORD '<choose one>';" \
    -c "CREATE DATABASE audit_dev OWNER audit;" -c "CREATE DATABASE audit_test OWNER audit;"
  ```

  Alternatively, run `docker compose up -d` if Docker is available.
- An Android emulator or device for the mobile app.

## 1. Run everything (US1)

```bash
cp .env.example .env                      # set DATABASE_URL and DATABASE_URL_TEST
pnpm install
pnpm --filter api prisma:migrate
pnpm dev                                  # API on :3000, admin web on :3001
adb reverse tcp:3000 tcp:3000          # phone/emulator localhost:3000 -> this machine
cd apps/mobile && flutter run --dart-define-from-file=env/dev.json
```

Expected:

- `curl -i localhost:3000/v1/health` returns 200 with `status: "ok"` and an `X-Request-Id`
  header.
- `localhost:3000/docs` shows the generated API docs.
- The admin web app at `localhost:3001` shows the sidebar layout from the design and
  "Backend connected · v0.1.0".
- The mobile app (debug build) opens the role picker.

## 2. Failure states (US1 edge cases)

| Action | Expected |
|--------|----------|
| Stop PostgreSQL, call `/v1/health` | 503 `degraded`, and the API keeps running |
| Start PostgreSQL again | `/v1/health` returns 200 again without restarting the API |
| Stop the API | Both clients show a translated "service unavailable" message with a retry action |
| Set `MIN_MOBILE_VERSION=99.0.0` and restart the API | The mobile app shows "Update required" |
| Remove `DATABASE_URL` and start the API | Startup fails with an error naming `DATABASE_URL` |

## 3. Role shells (US3)

1. Pick **Agent**. The tabs are Home, Shops, Map and Gallery, and the app bar shows the role.
2. Use "Switch role" and pick **Admin**. The tabs are Home, Shops, Agents, Map and Gallery.
3. `flutter test` passes the tests listed in
   [contracts/mobile-navigation.md](./contracts/mobile-navigation.md).

## 4. Language and theme (US4)

- Switch the admin web between RU and EN. All shell text changes.
- Set the device language to an unsupported one. The mobile app shows Russian.
- Turn on dark mode on the device. The mobile app uses the dark theme.

## 5. Quality gates (US2)

```bash
pnpm lint && pnpm typecheck && pnpm test         # api + admin-web
cd apps/mobile && dart format --set-exit-if-changed . && flutter analyze && flutter test
```

On a pull request, CI runs the same commands. A deliberately failing test makes the pull request
fail.

## Validation results (2026-10-06)

- API: 19/19 tests pass against the real `audit_test` database. `/v1/health` returns 200 with the
  database up, 503 with it down, and recovers without a restart. `/docs` is served.
- Admin web: lint, type check, 6/6 tests and the production build pass. RU and EN render, and the
  status check reaches the API through CORS.
- Mobile: 21/21 tests pass. Profile build on a Samsung A52 (Android 14):

  | Launch | First frame built | First frame on screen |
  |--------|-------------------|-----------------------|
  | First launch after install | 0.52 s | 2.20 s |
  | Cold start | 0.18 s | **0.43 s** |

  SC-007 (under 2 s) is met for normal cold starts. The release-mode app opens the sign-in
  placeholder, in dark theme following the system, in the device language.
- Notes: running on a phone needs `adb reverse tcp:3000 tcp:3000`. On a network that requires a
  proxy, Gradle needs `JAVA_TOOL_OPTIONS="-Dhttps.proxyHost=… -Dhttps.proxyPort=…"`.
