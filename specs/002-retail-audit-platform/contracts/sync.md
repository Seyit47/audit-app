# Contract: Mobile Offline Sync (Agent role)

This implements FR-015 and Principle VI. Research decision R-10.

## Principles

1. Every agent write is saved locally first and gets a **client-generated UUID**. The server
   treats a repeated `POST` with a known id as success, returning the existing record. Retries
   therefore never duplicate (SC-002).
2. Photo files are written to the app's documents directory **before** anything else. They are
   deleted locally only after the server confirms the upload is `READY`, and after 7 days.
3. Screens read only from the local store, so online and offline behave the same.

## Outbox

Items are processed in FIFO order. Each item type has dependencies that must succeed first:

| Kind | Steps (each idempotent) | Depends on |
|------|-------------------------|------------|
| `PHOTO` | `POST /uploads` → PUT the file to `uploadUrl` → `POST /uploads/:id/complete` | — |
| `SHOP_CREATE` | `POST /shops` (`PENDING_REVIEW`) | its facade `PHOTO` |
| `AUDIT_CREATE` | `POST /audits` with `photoIds` (the server links the photos to the audit) | all of its `PHOTO`s (READY) |
| `PINGS` | `POST /tracking/pings` (batch ≤ 200) | — (only collected while the agent is working) |

**Retries**: exponential backoff from 5 s to 10 min, with jitter.
- Network errors and 5xx responses are retried indefinitely.
- A repeated create returns the existing record, which counts as success.
- Other 4xx responses mark the item `FAILED`. It is kept, retried on each sync, and Home keeps
  showing "Синхронизация…" (the only sync state designed in Figma) until it succeeds. It is never
  dropped.

## Pull

The pull runs in this order: `/me` (includes the config subset) → `/routes/today` → `/shops?updatedAfter=<cursor>`
(including contacts and the latest visits) → `/photos?mine&updatedAfter=`. The cursors are stored
in `sync_cursors`. Deleted and unassigned shops arrive as tombstones and are removed locally,
unless they have unsynced outbox items.

## Triggers

The sync runs on app start, on resume, on regaining connectivity, every 15 min in the
background (Android `workmanager`), immediately after "Finish audit" and "Save shop", and on
pull-to-refresh.

## Status shown in the UI

| State | Condition | Copy (RU) |
|-------|-----------|-----------|
| Synced | outbox empty, last pull < 15 min ago | "Данные синхронизированы" |
| Syncing | a sync is running or the outbox has items | "Синхронизация…" |
| Offline save | an audit finished without network | "Офлайн-режим сохранён" (audit header) |

## Session end

On sign-out or a 401 that the refresh token can't fix, the app first tries to flush the outbox
(10 s timeout). It then wipes the drift database, the photo files and the secure storage, keeping
only the theme and locale. Deactivated agents keep syncing previously recorded data for 72 h
(api.md "Deactivated agents") before the wipe.
