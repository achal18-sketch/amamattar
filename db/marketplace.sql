-- TalentCore marketplace schema (PostgreSQL). Backend for the current prototype.
-- Data residency: host in an Indian region (DPDP Act 2023).
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (                     -- one login per person (phone OTP)
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text UNIQUE NOT NULL, email text, role text NOT NULL
    CHECK (role IN ('company_admin','company_hr','job_seeker','tutor','parent','household_worker','household_employer','college','staff_admin','staff_moderator')),
  is_adult boolean NOT NULL DEFAULT false,         -- 18+ declaration / KYC
  consent_at timestamptz, consent_version text,    -- DPDP consent record
  ui_lang text DEFAULT 'en', whatsapp_opt_in boolean DEFAULT false,
  deleted_at timestamptz, created_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), display_name text, legal_name text,
  hide_identity boolean NOT NULL DEFAULT false, gstin text, cin text,
  verification_status text NOT NULL DEFAULT 'pending' CHECK (verification_status IN ('pending','verified','rejected')),
  hq_city text, terms_accepted_at timestamptz, first_hire_used boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE company_members (company_id uuid REFERENCES companies(id), user_id uuid REFERENCES users(id), PRIMARY KEY(company_id,user_id));

CREATE TABLE profiles (                  -- job seekers, tutors, household workers, support staff
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL REFERENCES users(id),
  kind text NOT NULL CHECK (kind IN ('job_seeker','tutor','household_worker','student')),
  alias text NOT NULL, headline text, field text, role_title text, levels text[], work_types text[], languages text[],
  experience_years numeric(4,1), skills text[], current_city text, can_work_in text[], willing_to_relocate boolean,
  expected_salary_lpa numeric(6,2), current_salary_lpa numeric(6,2), -- never exposed to companies
  notice text, confidential boolean NOT NULL DEFAULT true, blocked_companies text[],
  resume_text text, resume_score smallint, kyc_status text NOT NULL DEFAULT 'pending', police_status text NOT NULL DEFAULT 'not_requested',
  created_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), company_id uuid REFERENCES companies(id), employer_user_id uuid REFERENCES users(id),
  title text NOT NULL, field text, levels text[], work_types text[], languages text[],
  cities text[] NOT NULL CHECK (array_length(cities,1) >= 1), work_mode text,
  salary_min_lpa numeric(6,2) NOT NULL CHECK (salary_min_lpa > 0), salary_max_lpa numeric(6,2) NOT NULL, -- salary required
  min_experience numeric(4,1), description text, status text NOT NULL DEFAULT 'open', urgent_until timestamptz,
  created_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE interests (                 -- mutual-interest flow
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), job_id uuid REFERENCES jobs(id), company_id uuid REFERENCES companies(id), profile_id uuid NOT NULL REFERENCES profiles(id),
  state text NOT NULL DEFAULT 'pending' CHECK (state IN ('pending','accepted','declined','expired')),
  stage text CHECK (stage IN ('Contacted','Interview scheduled','Interviewed','Offer made','Offer accepted','Joined')),
  accepted_at timestamptz, last_update_at timestamptz, -- 100-hour reply promise is measured from accepted_at
  created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(company_id,profile_id));

CREATE TABLE messages (id bigserial PRIMARY KEY, interest_id uuid REFERENCES interests(id), sender uuid REFERENCES users(id), body text NOT NULL, created_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE interviews (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), interest_id uuid REFERENCES interests(id), starts_at timestamptz NOT NULL, meet_link text, created_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE hires (                     -- hiring-fee ledger
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), interest_id uuid UNIQUE REFERENCES interests(id),
  annual_salary_inr bigint NOT NULL, fee_inr bigint NOT NULL, gst_inr bigint NOT NULL, first_hire_free boolean NOT NULL DEFAULT false,
  joined_on date, invoice_id uuid, replacement_due_until date, created_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE plans (id text PRIMARY KEY, audience text NOT NULL, name text NOT NULL, monthly_inr int, yearly_inr int, one_time_inr int, visible boolean NOT NULL DEFAULT false, features jsonb NOT NULL DEFAULT '[]');
CREATE TABLE subscriptions (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid REFERENCES users(id), company_id uuid REFERENCES companies(id), plan_id text REFERENCES plans(id), billing text CHECK (billing IN ('monthly','yearly')), period_start date, period_end date, status text NOT NULL DEFAULT 'active', razorpay_subscription_id text);
CREATE TABLE credit_ledger (id bigserial PRIMARY KEY, company_id uuid REFERENCES companies(id), delta int NOT NULL, reason text NOT NULL, expires_on date, created_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE usage_counters (user_id uuid REFERENCES users(id), feature text, period text, used int NOT NULL DEFAULT 0, PRIMARY KEY(user_id,feature,period)); -- e.g. AI resume upgrades per month

CREATE TABLE invoices (                  -- GST tax invoices (issued via Razorpay/Zoho)
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), number text UNIQUE NOT NULL, buyer_user_id uuid, buyer_gstin text, place_of_supply text NOT NULL,
  taxable_inr bigint NOT NULL, cgst_inr bigint NOT NULL DEFAULT 0, sgst_inr bigint NOT NULL DEFAULT 0, igst_inr bigint NOT NULL DEFAULT 0,
  sac_code text, lines jsonb NOT NULL, issued_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE ratings (                   -- only employees, tutors, parents; only after a real interaction
  id bigserial PRIMARY KEY, kind text NOT NULL CHECK (kind IN ('employee','tutor','parent')), subject_id uuid NOT NULL, rater_user_id uuid NOT NULL REFERENCES users(id),
  interaction_ref uuid NOT NULL, stars smallint NOT NULL CHECK (stars BETWEEN 1 AND 5), review text, status text NOT NULL DEFAULT 'published',
  created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(kind,subject_id,rater_user_id,interaction_ref));

CREATE TABLE reports (                   -- moderation queue, 24 h review target
  id bigserial PRIMARY KEY, kind text NOT NULL CHECK (kind IN ('profile','job','chat','complaint','review')), target_id text, reporter_user_id uuid, reason text NOT NULL,
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open','resolved','removed')), handled_by uuid, handled_at timestamptz, created_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE tutor_requests (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), parent_user_id uuid REFERENCES users(id), class_level text, subject text, city text, area text, mode text, created_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE household_requests (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), employer_user_id uuid REFERENCES users(id), worker_type text, city text, shift text, language text, offered_wage_inr int, created_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE campus_students (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), college_user_id uuid REFERENCES users(id), name text, course text, score text, city text, grad_year int, consent_at timestamptz NOT NULL);
CREATE TABLE campus_drives (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), company_id uuid REFERENCES companies(id), roles text, courses text, drive_date date, mode text, created_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE referrals (code text PRIMARY KEY, owner_user_id uuid REFERENCES users(id), signups int NOT NULL DEFAULT 0, credits_earned int NOT NULL DEFAULT 0);
CREATE TABLE audit_log (id bigserial PRIMARY KEY, actor uuid, action text NOT NULL, target text, detail jsonb, at timestamptz NOT NULL DEFAULT now());
