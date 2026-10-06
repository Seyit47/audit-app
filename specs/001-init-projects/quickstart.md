# Quickstart & Validation: Fresh Apps With Pixel-Perfect Designed Screens

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Prerequisites

- Node 24 with pnpm, and Flutter stable (3.47+).
- An Android phone or emulator for mobile checks, with `adb` available. On a real phone, run
  `adb reverse tcp:3000 tcp:3000` only once screens call the API (not needed in this feature).
- Google Chrome, for headless screenshots of the admin web.

## 1. Run the apps (US4)

```bash
pnpm install
pnpm --filter admin-web dev        # http://localhost:3000 (Next default)
cd apps/mobile && flutter run      # debug build opens the role picker
pnpm --filter api dev              # Fastify starter (not used by screens yet)
```

If port 3000 is taken on this machine, run `pnpm --filter admin-web dev -- -p 3002`.

## 2. Admin web pixel check (US1)

For each row W1–W11 in [contracts/screens.md](./contracts/screens.md):

```bash
google-chrome --headless --hide-scrollbars --force-device-scale-factor=2 \
  --window-size=1440,900 --screenshot=/tmp/w3.png "http://localhost:3000/en/shops"
```

Compare the capture side by side with the design PNG (both 2×). For interaction states (W2, W3,
W4, W6, W11), open the state in the browser and capture it at 1440 × 900.

**Expected**: no visible difference in layout, spacing, size, color, typography, icons or copy.

## 3. Mobile pixel check (US2, US3)

```bash
cd apps/mobile && flutter run          # pick Agent (then Admin) in the role picker
adb exec-out screencap -p > /tmp/a1.png
```

Compare each A- and M-frame at the same scale. For the agent screens, toggle dark mode on Home
and compare with the dark design (`mobile-agent-dark-design.css`).

**Expected**: the screenshots match. The OS status bar is excluded from the comparison.

## 4. Repository check (US4)

```bash
git ls-files | grep -vE '^(apps|specs|\.specify|\.claude)/|design'
```

**Expected**: only `package.json`, `pnpm-workspace.yaml`, `pnpm-lock.yaml`, `.gitignore`,
`README.md` and `.github/workflows/ci.yml`. Inside `apps/*`, every file is either from the
starter or feature code (see the justified additions in plan.md).

## 5. Tests

```bash
pnpm --filter admin-web test && pnpm --filter api test
cd apps/mobile && flutter analyze && flutter test
```
