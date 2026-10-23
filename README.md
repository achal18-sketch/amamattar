# TalentCore — trusted hiring marketplace for India

A matrimonial-style hiring marketplace. **Companies** (they can stay anonymous) and **job seekers** (they can search confidentially) connect only when both sides accept. It also covers **home tutors & parents**, **household help**, **facility & support staff** (office boy, sweeper, school ayah…), and **campus hiring**.

**Status:** a working single-page **prototype** (`app/index.html`). Logins, payments, verification and WhatsApp are simulated, and data is stored only in the browser. See [docs/AUDIT.md](docs/AUDIT.md) for what is needed before launch.

| What | Where |
|---|---|
| **Prototype app** (open in Chrome) | [app/index.html](app/index.html) |
| Management audit & fix status | [docs/AUDIT.md](docs/AUDIT.md) |
| Feature history (v1–v24) | [docs/FEATURES.md](docs/FEATURES.md) |
| Current price sheet | Admin tab → "Download price sheet", or [docs/PRICES.md](docs/PRICES.md) |
| Marketplace database schema (for the backend) | [db/marketplace.sql](db/marketplace.sql) |
| 72,007 job titles (MIT-licensed source) | [data/](data/) |
| Browser tests (Playwright) | [tests/](tests/) |
| **Phase 2 — AI interviewer** (switched off in the app: `AI_INTERVIEWER=false`) | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/API_AND_EVENTS.md](docs/API_AND_EVENTS.md), [prompts/](prompts/), [db/schema.sql](db/schema.sql), [docs/COMPLIANCE.md](docs/COMPLIANCE.md) |

## Switches in `app/index.html`
- `AI_INTERVIEWER=false`: set to `true` to bring back the AI video interviewer, report and pipeline.
- `VERIF_LIVE=false`: set to `true` **only** once real GST/KYC/police-verification checks are live. Until then badges say "check pending".
- Admin tab → **Pilot mode**: shows only SMB hiring + tutors, for a one-city launch.
