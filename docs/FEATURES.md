# Additional Features (v2)

Features added beyond the original spec, ranked by how much they matter for a real launch.

## Shipped in the live prototype (`app/index.html`)
| Feature | What it does |
|---|---|
| **Live video interview** | Camera + mic via WebRTC `getUserMedia`, mirrored self-view, AI interviewer overlay, live captions, REC timer. |
| **Voice in / voice out** | Browser speech recognition (hold-to-answer) and speech synthesis; production swaps in streaming STT/TTS (see ARCHITECTURE §1.4). |
| **Adaptive AI interviewer** | Each turn the AI picks the next probe from the rubric, coverage and time left; probes vague claims, completes STAR answers. Offline fallback keeps the demo usable. |
| **AI rubric generator** | JD → weighted competencies + question bank. |
| **Blind, evidence-cited scoring** | Scored on transcript only; every score quotes turn numbers. |
| **Integrity signals** | Tab switches, paste events, camera-covered/absent seconds. They lower confidence, never auto-reject. |
| **Consent & AI disclosure gate** | Mandatory before joining; text-only mode as an accommodation. |
| **Request-a-human button** | Candidate can escalate at any time (GDPR Art. 22). |
| **Human sign-off queue** | Approve/override in Pipeline before any email or offer. |
| **Recording + report export** | WebM recording download, JSON report export. |
| **Multilingual** | Interview language selector (EN/ES/FR/DE/HI). |

## Roadmap (designed, not yet built)
1. **Candidate practice mode** – free 5-min mock interview with feedback; raises completion rates and reduces anxiety.
2. **ATS integrations** – Greenhouse, Lever, Workday, Ashby: two-way sync of applications and decisions.
3. **Calendar self-scheduling** – Google/Outlook, timezone-aware, reminders by SMS/WhatsApp.
4. **Interview replay** – timeline scrubber jumping from each score's evidence to the matching video moment.
5. **Calibration studio** – hiring managers grade 10 gold transcripts; the system tunes judge prompts until agreement ≥ κ 0.7.
6. **Reasonable-accommodation engine** – extra time, captions-only, screen-reader-optimized coding, async video option.
7. **Async one-way video** – for high-volume roles: record answers on the candidate's own schedule.
8. **Reference-check agent** – AI voice calls to references with consented, structured questions.
9. **Talent rediscovery** – re-match past "Hold" candidates to new openings (with consent).
10. **Interviewer persona builder** – company voice, name, tone and avatar per tenant.
11. **Candidate experience NPS** – post-interview survey feeding into the quality dashboard.
12. **Hiring-manager copilot** – chat with the pipeline ("who's strongest in system design?"), grounded in reports.
13. **Fraud network detection** – the same face or voice showing up across many applications or tenants (privacy-preserving hashes).
14. **Bias audit dashboard** – live impact ratios per job, with automatic auto-dispatch freeze below 0.8.
15. **White-label & custom domain** for agencies hosting many client companies.

## Universal job coverage (v3)
The interviewer covers **every job**: 22 fields and 340+ preset roles, and you can type in any other job title.
Each field maps to an interview format the AI runs:

| Format | Fields (examples) |
|---|---|
| Technical deep-dive + problem solving | Software & IT, Cyber Security, Engineering |
| Clinical case | Doctors, nurses, pharmacists, therapists, veterinarians |
| Legal case analysis | Lawyers, paralegals, compliance, company secretaries |
| Teaching demo | Teachers, lecturers, tutors, trainers |
| Sales role-play (AI = prospect) | Sales executive, salesman, account exec, real estate, insurance |
| Customer role-play (AI = upset customer) | Call centre, support, hospitality |
| Leadership scenarios | Managers, directors, CXOs, HR |
| Analytical case | Finance, banking, science, research |
| **Live audition** (perform on camera/mic, take direction, second take) | Singers, actors, voice artists, dubbing, RJs, anchors, dancers, comedians, musicians, models, athletes |
| Portfolio + live brief | Marketing, design, media, journalism |
| Practical/safety scenarios | Trades, technicians, agriculture, logistics, operations |
| Structured behavioural + situational | Office/white-collar, government, any other job |

Note: for auditions the transcript-based scorer judges direction-taking and craft knowledge;
vocal and visual quality are flagged for human review (production: add an audio-analysis model
for pitch/timing, scored separately and audited for bias).

## v4 additions
| Feature | What it does |
|---|---|
| **Auto ideal-candidate profile** | Type any designation → AI writes purpose, responsibilities, must-have skills, qualifications/licences, experience, soft skills, red flags and assessment method (offline template per field when AI is unavailable). Regenerates on designation/level/field change. |
| **Resume-aware interviewing** | Paste the CV; the interviewer probes specific claims and projects. |
| **Practice mode** | Mock interview with one line of coaching after each answer; kept private and out of the hiring queue. |
| **Invite & scheduling** | Candidate details + date/time zone → calendar invite (.ics) and invite email with AI disclosure and accommodation info. |
| **Email & offer drafts** | From the report: personalised feedback / next-step email, or a conditional offer letter with placeholders. |

## v5 — "nobody else has this" features
| Feature | What it does |
|---|---|
| **Live claim ledger** | While the candidate talks, the AI pulls out every concrete claim ("cut p99 by 40%") and marks it probing → supported/unsupported as it follows up. |
| **Speech analytics** | Live pace (wpm), filler words, talk-time ratio and answer length — coaching in practice mode, context for reviewers (never scored). |
| **Fairness shield** | Mentions of protected traits (age, marital status, religion, pregnancy, nationality, disability…) are stripped out before scoring and from evidence, and the report says how many were removed. |
| **Competency radar** | A spider chart of the candidate's scores for each skill. |
| **Highlight reel** | Click any evidence quote to jump the recorded video to that exact moment. |
| **AI hiring committee** | A Hiring Manager, a Senior Peer and a Skeptic, each an expert in the field, debate the evidence and agree on a verdict plus the one question a human should still ask. |
| **Ask the dossier** | Chat with the interview: "How did they handle the price objection?" Answers cite turn numbers. |
| **Head-to-head comparison** | Select candidates in Pipeline → AI ranking with the deciding factor. |
| **30-60-90 onboarding plan** | A personalised first-90-days plan built from this hire's growth areas. |
| **Reference-check script** | Legally safe questions that check this candidate's specific claims. |
| **First-year growth projection** | A labelled hypothesis covering ramp-up time, where they'll need support and which manager style suits them best. |
