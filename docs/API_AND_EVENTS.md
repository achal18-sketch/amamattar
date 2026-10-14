# 3. API & Event Specs

Base URL `https://api.talentcore.ai/v1`. Auth: OAuth2 client-credentials or API key
(`Authorization: Bearer`), tenant resolved from token — never from the request body.
All writes accept `Idempotency-Key`. Errors follow RFC 9457 (`application/problem+json`).
Pagination: cursor (`?cursor=&limit=`).

## 3.1 Tenant configuration

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/tenants` | (platform admin) create tenant `{name, slug, data_region, plan}` |
| `GET/PATCH` | `/tenant` | read/update settings: retention_days, decision_policy, branding |
| `PUT` | `/tenant/company-profile` | new Company DNA version |
| `POST/GET` | `/tenant/users` | invite/list users, roles |
| `POST/DELETE` | `/tenant/webhooks` | manage webhook subscriptions |

`decision_policy` example:
```json
{
  "require_human_signoff": true,
  "auto_dispatch": {"reject": false, "hold": true, "hire": false, "strong_hire": false},
  "min_confidence_for_auto": 0.8,
  "integrity_review_threshold": 0.6,
  "feedback_emails": true,
  "offer_automation": {"enabled": true, "tier_by_score": [{"min": 4.5, "tier": "T3"}, {"min": 3.6, "tier": "T2"}]}
}
```

## 3.2 Jobs & blueprints

```http
POST /jobs
Content-Type: multipart/form-data   # or application/json
{
  "title": "Senior Backend Engineer",
  "level": "senior",
  "jurisdictions": ["US-NYC"],
  "source": {"kind": "file", "upload_id": "upl_123"},   // or {"kind":"text","text":"..."} / {"kind":"url","url":"..."}
  "comp_band": {"currency": "USD", "min": 170000, "max": 215000, "tiers": {"T1":175000,"T2":190000,"T3":210000}},
  "modules": ["conversation", "coding"],
  "duration_min": 45
}
→ 202 {"id": "job_…", "status": "draft", "blueprint_job": "op_…"}
```

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/jobs/{id}` | job + normalized `job_spec` |
| `POST` | `/jobs/{id}/rubrics:generate` | (re)generate rubric draft → async op |
| `GET` | `/jobs/{id}/rubrics/{ver}` | rubric with competencies, anchors, question bank |
| `PATCH` | `/jobs/{id}/rubrics/{ver}` | employer edits weights/questions (draft only) |
| `POST` | `/jobs/{id}/rubrics/{ver}:freeze` | lock rubric; runs bias lint; required before activation |
| `POST` | `/jobs/{id}:activate` / `:pause` / `:close` | lifecycle |
| `GET` | `/operations/{id}` | async op status |

## 3.3 Candidates & scheduling

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/jobs/{id}/applications` | `{candidate:{email, full_name, resume_upload_id}, external_ref}` |
| `POST` | `/applications/{id}/invitations` | send interview invite with self-scheduling link |
| `GET` | `/availability?job_id=&from=&to=` | bookable slots (capacity-aware) |
| `POST` | `/applications/{id}/sessions` | book `{scheduled_start, accommodations}` |
| `DELETE` | `/sessions/{id}` | cancel |

## 3.4 Session initialization (candidate-facing, WebRTC)

Candidate authenticates with a single-use magic-link token (scoped to one session).

```http
POST /candidate/sessions/{id}/consent
{"disclosure_version": "ai-disclosure-2026-09", "consents": {"ai_interview": true, "recording": true, "biometric": true}}

POST /candidate/sessions/{id}/identity     # ID doc + liveness selfie upload ids
→ {"verified": true, "match_score": 0.97}  # or {"verified": false, "fallback": "human_proctor_review"}

POST /candidate/sessions/{id}/join
→ 200
{
  "session_id": "ses_…",
  "media": {
    "provider": "livekit",
    "url": "wss://media-use1.talentcore.ai",
    "token": "<JWT: room=ses_…, identity=cand_…, ttl=75m, canPublish, canSubscribe>",
    "ice_servers": [{"urls": ["turns:turn-use1.talentcore.ai:443"], "username": "…", "credential": "…"}]
  },
  "telemetry_ws": "wss://rt-use1.talentcore.ai/sessions/ses_…/telemetry",   // keystroke/focus/clipboard
  "code_ws": "wss://rt-use1.talentcore.ai/sessions/ses_…/editor",           // Yjs CRDT doc
  "limits": {"duration_min": 45, "extra_time_min": 0},
  "agent": {"display_name": "Ava (AI interviewer)", "is_ai": true}
}

POST /candidate/sessions/{id}/human-review-request   # GDPR Art.22 / accommodation path
```

GraphQL (employer dashboard) exposes the same model read-side:
```graphql
type Query {
  job(id: ID!): Job
  session(id: ID!): CandidateSession
  pipeline(jobId: ID!, recommendation: Recommendation, first: Int, after: String): SessionConnection!
}
type Mutation {
  signOffDecision(id: ID!, final: Recommendation!, reason: String): HiringDecision!
}
type Subscription { liveSessions(jobId: ID): SessionStatusEvent! }
```

## 3.5 Results

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/sessions/{id}/report` | ScoringReport (scores, rationale, evidence links) |
| `GET` | `/sessions/{id}/evidence/{eid}` | signed URL to redacted clip/snippet |
| `GET` | `/decisions?status=awaiting_signoff` | sign-off queue |
| `POST` | `/decisions/{id}:approve` / `:override` | human oversight action |
| `GET` | `/audits/bias?job_id=&period=` | impact-ratio report |

## 3.6 Internal Kafka topics (Avro, keyed by `session_id`)

| Topic | Producer → Consumer | Payload highlights |
|---|---|---|
| `job.ingested` | ingestion → blueprint | job_id, job_spec |
| `rubric.frozen` | api → scheduling, analytics | rubric_id, version |
| `session.state` | orchestrator → all | status transitions |
| `session.turn` | agent → transcript, analytics | seq, speaker, text, timings, competency_key |
| `session.agent_action` | agent → audit | tool name, args (e.g. `record_signal`) |
| `sandbox.run` | sandbox → scoring | code hash, tests passed/total, runtime |
| `proctor.event` | proctoring → integrity scorer | type, severity, confidence, at_ms |
| `session.completed` | orchestrator → scoring, archiver, redaction | session_id, recording_uri |
| `report.created` | scoring → decision | report_id, overall, confidence |
| `decision.finalized` | decision → comms, webhooks, analytics | decision_id, final |

## 3.7 Webhooks

Delivered with `TalentCore-Signature: t=<unix>,v1=<HMAC-SHA256(secret, t + "." + body)>`;
retries with exponential backoff for 24h; receivers must dedupe on `id`.

Events: `session.scheduled`, `session.completed`, `report.ready`,
`decision.awaiting_signoff`, `candidate.recommendation`, `offer.sent`, `offer.accepted`,
`candidate.review_requested`.

```json
{
  "id": "evt_01JA9…",
  "type": "candidate.recommendation",
  "created_at": "2026-10-14T15:42:07Z",
  "tenant_id": "ten_…",
  "data": {
    "decision_id": "dec_…",
    "application_id": "app_…",
    "job": {"id": "job_…", "title": "Senior Backend Engineer", "rubric_version": 3},
    "candidate": {"id": "cand_…", "external_ref": "greenhouse:88123"},
    "recommendation": "hire",
    "status": "approved",
    "decided_by": {"type": "human", "user_id": "usr_…"},
    "overall_score": 3.94,
    "scale_max": 5,
    "confidence": 0.86,
    "integrity": {"score": 0.93, "flags": []},
    "competencies": [
      {"key": "system_design", "weight": 0.30, "score": 4.2,
       "evidence": [{"id": "ev_…", "type": "transcript_span", "start_ms": 812000, "quote": "We sharded by tenant…"}]},
      {"key": "coding", "weight": 0.35, "score": 3.8,
       "evidence": [{"id": "ev_…", "type": "test_run", "tests_passed": 8, "tests_total": 9}]}
    ],
    "summary": "Strong distributed-systems depth; minor gaps in testing discipline.",
    "report_url": "https://app.talentcore.ai/r/rep_…",
    "next_action": {"type": "offer", "comp_tier": "T2"}
  }
}
```
