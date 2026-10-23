# TalentCore AI — Autonomous Virtual Recruitment Agency

Design package for a multi-tenant platform that ingests employer requirements, generates
interview blueprints, runs real-time multimodal AI interviews, and produces evidence-backed
hiring decisions. Target: 50,000+ interviews/day, ~5,000 concurrent sessions at peak.

| Deliverable | File |
|---|---|
| 1. System architecture & data flow | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| 2. Database schema (PostgreSQL DDL + ClickHouse) | [db/schema.sql](db/schema.sql), [db/analytics.sql](db/analytics.sql) |
| 3. API & event specs | [docs/API_AND_EVENTS.md](docs/API_AND_EVENTS.md) |
| 4. Agent prompt strategy & tools | [prompts/INTERVIEWER_AGENT.md](prompts/INTERVIEWER_AGENT.md) |
| Compliance design | [docs/COMPLIANCE.md](docs/COMPLIANCE.md) |
| Additional features & roadmap | [docs/FEATURES.md](docs/FEATURES.md) |
| **Management audit (23 Oct 2026)** | [docs/AUDIT.md](docs/AUDIT.md) |
| **Live prototype app** (open in Chrome) | [app/index.html](app/index.html) |

> **Design stance on autonomy.** The spec asks for "zero human HR intervention." Under the
> EU AI Act (Annex III, high-risk: employment) Art. 14 human oversight is mandatory, GDPR
> Art. 22 gives candidates a right to human review of solely-automated decisions, and NYC
> LL144 requires bias audits and notice. This design therefore makes everything autonomous
> **up to** final adverse/offer decisions, which are executed automatically only in
> jurisdictions/tenants where that is lawful, and otherwise pass through a lightweight
> one-click human sign-off queue (`decision_policy.require_human_signoff`). Candidates can
> always request human review and an accommodation/alternative assessment.
