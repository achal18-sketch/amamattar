# Compliance, Ethics & Security

| Requirement | Implementation |
|---|---|
| **NYC LL144** (AEDT) | Annual independent bias audit using `analytics.sql` impact ratios by sex, race/ethnicity and intersections; public summary page per tenant; candidate notice ≥10 business days before use with alternative-process instructions. |
| **EU AI Act** (Annex III §4, high-risk) | Risk management file, data governance docs, technical documentation, automatic logging (`audit_log`, event log), Art. 13 transparency notice, **Art. 14 human oversight** via sign-off queue, accuracy/robustness monitoring, post-market monitoring, conformity assessment + EU database registration. **No emotion recognition** (Art. 5(1)(f) prohibits it in the workplace context) — proctoring analyzes presence/gaze only, never affect. |
| **GDPR** | Lawful basis + explicit consent for biometrics (Art. 9); DPIA; Art. 22 right to human review; data subject rights API (access/erasure); EU data residency via regional cells; DPA/SCCs with subprocessors. |
| **EEOC / ADA / Title VII** | Accommodations (extra time, text-only mode, no-video mode, human interviewer alternative); disparate-impact monitoring (4/5ths rule); rubrics restricted to job-related criteria; no use of protected attributes, voice accent, appearance or facial expression in scoring. |
| **Illinois AIVIA, Maryland HB1202, Colorado AI Act** | Jurisdiction flags on job posting drive notice/consent text and facial-analysis restrictions. |
| **SOC 2 Type II / ISO 27001** | SSO/SCIM, least-privilege IAM, KMS envelope encryption (per-tenant keys), TLS 1.3, SRTP, quarterly access reviews, vuln mgmt, pentests, change management, immutable audit log. |

## Bias prevention in the pipeline
1. **Rubric lint:** LLM + rules flag questions on age, family, nationality, health, religion, etc.
2. **Blind scoring:** scorer sees transcript + code only — no video, name, photo, or voice;
   names and self-identifying details are redacted from transcript before judging.
3. **Ensemble + calibration:** 3 judges; per-rubric calibration set of gold-labeled
   transcripts; drift alerts when agreement or score distribution shifts.
4. **Continuous adverse-impact monitoring:** weekly per job; impact ratio <0.8 freezes auto-
   dispatch for that job and alerts the tenant.
5. **Proctoring signals never auto-reject**; they only route to human review.

## Data lifecycle
- Raw biometrics (ID image, selfie): deleted ≤24h after verification.
- Recordings: tenant retention (default 180d), then hard delete (S3 lifecycle + key shred).
- Reviewers see redacted derivatives (face blur, PII masking via NER) by default.
- Erasure request → tombstone candidate, delete media/transcripts, keep only anonymized
  aggregates required for bias audit.
