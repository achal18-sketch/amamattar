-- TalentCore AI — OLTP schema (PostgreSQL 15 / Aurora)
-- Every tenant-scoped table carries tenant_id and is protected by row-level security.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TYPE job_level        AS ENUM ('intern','junior','mid','senior','staff','principal','manager','director','vp','c_level');
CREATE TYPE competency_kind  AS ENUM ('hard_skill','behavioral','cultural');
CREATE TYPE session_status   AS ENUM ('scheduled','preflight','live','interrupted','completed','abandoned','cancelled','failed');
CREATE TYPE module_kind      AS ENUM ('conversation','coding','roleplay','case_study');
CREATE TYPE evidence_kind    AS ENUM ('transcript_span','audio_clip','video_clip','code_snapshot','test_run','proctor_event');
CREATE TYPE recommendation   AS ENUM ('strong_hire','hire','hold','reject');
CREATE TYPE decision_status  AS ENUM ('proposed','awaiting_signoff','approved','overridden','dispatched');

-- ---------- Tenancy & identity ----------
CREATE TABLE tenants (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name             text NOT NULL,
  slug             citext UNIQUE NOT NULL,
  data_region      text NOT NULL CHECK (data_region IN ('us','eu','apac')),
  plan             text NOT NULL DEFAULT 'standard',
  retention_days   int  NOT NULL DEFAULT 180,
  decision_policy  jsonb NOT NULL DEFAULT '{"require_human_signoff": true}',
  created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE company_profiles (          -- "Company DNA", versioned
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL REFERENCES tenants(id),
  version          int  NOT NULL,
  mission          text,
  culture_values   jsonb NOT NULL DEFAULT '[]',   -- [{name, description, weight}]
  communication_style text,
  tech_stack       text[],
  dealbreakers     jsonb NOT NULL DEFAULT '[]',
  interviewer_persona jsonb NOT NULL DEFAULT '{}', -- name, tone, voice_id
  created_at       timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, version)
);

CREATE TABLE users (                       -- employer-side users
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id),
  email      citext NOT NULL,
  role       text NOT NULL CHECK (role IN ('owner','admin','hiring_manager','reviewer','auditor')),
  sso_subject text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, email)
);

CREATE TABLE api_keys (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id   uuid NOT NULL REFERENCES tenants(id),
  key_hash    bytea NOT NULL UNIQUE,
  scopes      text[] NOT NULL,
  revoked_at  timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------- Jobs & rubrics ----------
CREATE TABLE job_postings (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL REFERENCES tenants(id),
  company_profile_id uuid NOT NULL REFERENCES company_profiles(id),
  title            text NOT NULL,
  level            job_level NOT NULL,
  department       text,
  location_policy  text,           -- remote / hybrid / onsite + locations
  jurisdictions    text[] NOT NULL, -- drives compliance (e.g. {'US-NYC','EU-DE'})
  source_kind      text NOT NULL CHECK (source_kind IN ('text','file','url','questionnaire')),
  source_uri       text,
  raw_text         text,
  job_spec         jsonb NOT NULL,  -- normalized structured JobSpec
  comp_band        jsonb,           -- {currency, min, mid, max, equity, tiers:[...]}
  status           text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','active','paused','closed')),
  active_rubric_id uuid,
  created_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON job_postings (tenant_id, status);

CREATE TABLE evaluation_rubrics (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants(id),
  job_posting_id  uuid NOT NULL REFERENCES job_postings(id),
  version         int NOT NULL,
  scale_max       int NOT NULL DEFAULT 5 CHECK (scale_max IN (5,100)),
  benchmark_ref   text,            -- e.g. 'swe-ladder-v4:L5'
  duration_min    int NOT NULL DEFAULT 45,
  modules         module_kind[] NOT NULL DEFAULT '{conversation}',
  thresholds      jsonb NOT NULL,  -- {strong_hire:4.3, hire:3.6, hold:3.0}
  frozen_at       timestamptz,     -- immutable once interviews start
  generated_by    text NOT NULL,   -- model + prompt version
  bias_lint       jsonb,           -- result of protected-attribute lint
  created_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE (job_posting_id, version)
);
ALTER TABLE job_postings ADD FOREIGN KEY (active_rubric_id) REFERENCES evaluation_rubrics(id);

CREATE TABLE rubric_competencies (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES tenants(id),
  rubric_id      uuid NOT NULL REFERENCES evaluation_rubrics(id) ON DELETE CASCADE,
  key            text NOT NULL,          -- 'system_design'
  name           text NOT NULL,
  kind           competency_kind NOT NULL,
  weight         numeric(5,4) NOT NULL CHECK (weight > 0 AND weight <= 1),
  is_knockout    boolean NOT NULL DEFAULT false,
  min_score      numeric(5,2),           -- knockout floor
  anchors        jsonb NOT NULL,         -- {"1":"...", "3":"...", "5":"..."} behavioral anchors
  positive_signals text[] NOT NULL DEFAULT '{}',
  red_flags      text[] NOT NULL DEFAULT '{}',
  UNIQUE (rubric_id, key)
);

CREATE TABLE question_bank (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants(id),
  competency_id   uuid NOT NULL REFERENCES rubric_competencies(id) ON DELETE CASCADE,
  module          module_kind NOT NULL DEFAULT 'conversation',
  difficulty      smallint NOT NULL CHECK (difficulty BETWEEN 1 AND 5),
  prompt          text NOT NULL,
  follow_ups      jsonb NOT NULL DEFAULT '[]', -- [{trigger:"vague_metric", probe:"..."}]
  expected_signals text[] NOT NULL DEFAULT '{}',
  noise_indicators text[] NOT NULL DEFAULT '{}',
  assets          jsonb,                       -- coding: {starter_code, hidden_tests_ref}; roleplay: {persona}
  active          boolean NOT NULL DEFAULT true
);
CREATE INDEX ON question_bank (competency_id, difficulty) WHERE active;

-- ---------- Candidates & sessions ----------
CREATE TABLE candidates (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid NOT NULL REFERENCES tenants(id),
  email         citext NOT NULL,
  full_name     text NOT NULL,
  phone         text,
  resume_uri    text,
  resume_parsed jsonb,
  locale        text DEFAULT 'en-US',
  external_ref  text,                 -- ATS id
  erased_at     timestamptz,          -- GDPR erasure tombstone
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, email)
);

CREATE TABLE applications (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES tenants(id),
  candidate_id   uuid NOT NULL REFERENCES candidates(id),
  job_posting_id uuid NOT NULL REFERENCES job_postings(id),
  stage          text NOT NULL DEFAULT 'applied',
  created_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (candidate_id, job_posting_id)
);

CREATE TABLE consents (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL REFERENCES tenants(id),
  candidate_id     uuid NOT NULL REFERENCES candidates(id),
  kind             text NOT NULL,   -- 'ai_interview','recording','biometric','data_processing'
  disclosure_version text NOT NULL,
  granted          boolean NOT NULL,
  ip inet, user_agent text,
  recorded_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE candidate_sessions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id        uuid NOT NULL REFERENCES tenants(id),
  application_id   uuid NOT NULL REFERENCES applications(id),
  rubric_id        uuid NOT NULL REFERENCES evaluation_rubrics(id),
  status           session_status NOT NULL DEFAULT 'scheduled',
  scheduled_start  timestamptz NOT NULL,
  started_at       timestamptz,
  ended_at         timestamptz,
  region           text NOT NULL,
  media_room       text,            -- LiveKit room name
  agent_version    text,            -- prompt + model bundle hash
  identity_verified boolean,
  identity_match_score numeric(4,3),
  accommodations   jsonb NOT NULL DEFAULT '{}', -- extra time, text-only, etc.
  integrity_score  numeric(4,3),    -- 0..1, from proctoring
  recording_uri    text,
  transcript_uri   text,
  delete_after     date NOT NULL,
  created_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON candidate_sessions (tenant_id, status, scheduled_start);
CREATE INDEX ON candidate_sessions (delete_after);

CREATE TABLE session_turns (               -- canonical transcript, word timings in object store
  id           bigserial PRIMARY KEY,
  tenant_id    uuid NOT NULL,
  session_id   uuid NOT NULL REFERENCES candidate_sessions(id) ON DELETE CASCADE,
  seq          int NOT NULL,
  speaker      text NOT NULL CHECK (speaker IN ('agent','candidate','system')),
  text         text NOT NULL,
  start_ms     int NOT NULL,
  end_ms       int NOT NULL,
  competency_key text,
  question_id  uuid REFERENCES question_bank(id),
  UNIQUE (session_id, seq)
);

CREATE TABLE audio_visual_evidence (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id      uuid NOT NULL REFERENCES tenants(id),
  session_id     uuid NOT NULL REFERENCES candidate_sessions(id) ON DELETE CASCADE,
  kind           evidence_kind NOT NULL,
  start_ms       int,
  end_ms         int,
  turn_seq_from  int,
  turn_seq_to    int,
  storage_uri    text,              -- clip / snapshot in object store
  redacted_uri   text,              -- PII/face-blurred derivative
  content_hash   bytea NOT NULL,    -- tamper evidence
  payload        jsonb NOT NULL DEFAULT '{}', -- e.g. {commit:"…", tests_passed:7, tests_total:9}
  created_at     timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON audio_visual_evidence (session_id, kind);

CREATE TABLE proctoring_events (
  id          bigserial PRIMARY KEY,
  tenant_id   uuid NOT NULL,
  session_id  uuid NOT NULL REFERENCES candidate_sessions(id) ON DELETE CASCADE,
  at_ms       int NOT NULL,
  type        text NOT NULL,   -- 'multi_face','gaze_away','tab_blur','paste','second_voice','id_mismatch','latency_anomaly'
  severity    smallint NOT NULL CHECK (severity BETWEEN 1 AND 3),
  confidence  numeric(4,3) NOT NULL,
  evidence_id uuid REFERENCES audio_visual_evidence(id)
);

-- ---------- Scoring & decisions ----------
CREATE TABLE scoring_reports (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants(id),
  session_id      uuid NOT NULL UNIQUE REFERENCES candidate_sessions(id),
  rubric_id       uuid NOT NULL REFERENCES evaluation_rubrics(id),
  overall_score   numeric(6,3) NOT NULL,
  confidence      numeric(4,3) NOT NULL,       -- judge agreement × integrity × coverage
  coverage        numeric(4,3) NOT NULL,       -- fraction of competencies with sufficient evidence
  recommendation  recommendation NOT NULL,
  summary         text NOT NULL,
  strengths       jsonb NOT NULL DEFAULT '[]',
  concerns        jsonb NOT NULL DEFAULT '[]',
  scorer_version  text NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE competency_scores (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL,
  report_id       uuid NOT NULL REFERENCES scoring_reports(id) ON DELETE CASCADE,
  competency_id   uuid NOT NULL REFERENCES rubric_competencies(id),
  score           numeric(6,3) NOT NULL,
  judge_scores    numeric(6,3)[] NOT NULL,     -- individual ensemble votes
  rationale       text NOT NULL,
  insufficient_evidence boolean NOT NULL DEFAULT false,
  UNIQUE (report_id, competency_id)
);

CREATE TABLE score_evidence_links (           -- every score cites evidence
  competency_score_id uuid NOT NULL REFERENCES competency_scores(id) ON DELETE CASCADE,
  evidence_id         uuid NOT NULL REFERENCES audio_visual_evidence(id) ON DELETE CASCADE,
  polarity            smallint NOT NULL CHECK (polarity IN (-1,1)),
  quote               text,
  PRIMARY KEY (competency_score_id, evidence_id)
);

CREATE TABLE hiring_decisions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid NOT NULL REFERENCES tenants(id),
  application_id  uuid NOT NULL REFERENCES applications(id),
  report_id       uuid NOT NULL REFERENCES scoring_reports(id),
  proposed        recommendation NOT NULL,
  final           recommendation,
  status          decision_status NOT NULL DEFAULT 'proposed',
  policy_trace    jsonb NOT NULL,   -- which rules fired, thresholds used
  signed_off_by   uuid REFERENCES users(id),
  signed_off_at   timestamptz,
  override_reason text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE offers (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL REFERENCES tenants(id),
  decision_id  uuid NOT NULL REFERENCES hiring_decisions(id),
  comp_tier    text NOT NULL,
  package      jsonb NOT NULL,      -- base, bonus, equity, start_date, conditions[]
  document_uri text,
  status       text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','sent','accepted','declined','expired','rescinded')),
  sent_at      timestamptz
);

CREATE TABLE candidate_communications (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid NOT NULL,
  candidate_id uuid NOT NULL REFERENCES candidates(id),
  kind         text NOT NULL,       -- invite, reminder, feedback, offer, review_request_ack
  body_uri     text NOT NULL,
  sent_at      timestamptz
);

CREATE TABLE webhook_subscriptions (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id  uuid NOT NULL REFERENCES tenants(id),
  url        text NOT NULL,
  events     text[] NOT NULL,
  secret_enc bytea NOT NULL,
  active     boolean NOT NULL DEFAULT true
);

CREATE TABLE audit_log (                       -- append-only, hash-chained
  id          bigserial PRIMARY KEY,
  tenant_id   uuid NOT NULL,
  actor       text NOT NULL,          -- user:<id> | system:<svc> | agent:<session>
  action      text NOT NULL,
  target      text NOT NULL,
  detail      jsonb,
  prev_hash   bytea,
  hash        bytea NOT NULL,
  at          timestamptz NOT NULL DEFAULT now()
);

-- ---------- Row-level security ----------
DO $$
DECLARE t text;
BEGIN
  FOR t IN SELECT unnest(ARRAY['company_profiles','users','api_keys','job_postings','evaluation_rubrics',
    'rubric_competencies','question_bank','candidates','applications','consents','candidate_sessions',
    'session_turns','audio_visual_evidence','proctoring_events','scoring_reports','competency_scores',
    'hiring_decisions','offers','candidate_communications','webhook_subscriptions','audit_log'])
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format($p$CREATE POLICY tenant_isolation ON %I
                     USING (tenant_id = current_setting('app.tenant_id')::uuid)$p$, t);
  END LOOP;
END $$;
