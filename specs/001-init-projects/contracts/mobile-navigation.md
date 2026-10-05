# Contract: Mobile Role-Based Navigation

| Path | Role | Screen |
|------|------|--------|
| `/role-picker` | none (debug builds only) | Debug role picker |
| `/sign-in` | none (release builds) | Sign-in placeholder (replaced by the auth feature) |
| `/update-required` | any | Update required |
| `/agent/home`, `/agent/shops`, `/agent/map`, `/agent/gallery` | agent | Agent tab shell |
| `/admin/home`, `/admin/shops`, `/admin/agents`, `/admin/map`, `/admin/gallery` | admin | Admin tab shell |

Tab sets come from `mobile-agent-design-png/` and `mobile-admin-design-png/`. Shops, Map and
Gallery are shared screens built once and reused by both shells.

## Redirect rules (one `redirect` function, evaluated in order)

1. If compatibility is `updateRequired`, go to `/update-required`.
2. If there is no session, go to `/role-picker` in a debug build or `/sign-in` in a release
   build.
3. A path under the other role's prefix goes to the current role's `/<role>/home`.
4. `/`, `/role-picker` or `/sign-in` with a session goes to `/<role>/home`.

Every shell shows the active role in its app bar.

## Required tests

- Redirect function unit test covering rules 1–4.
- Widget test: each role sees exactly its own tabs.
- Release-mode routing: `/role-picker` is not registered when `isDebug` is false. The router
  factory takes `isDebug` as a parameter so this can be tested.
