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

## v6 — 585+ roles, confidence & experience, anti-cheat engine
**Catalog:** 38 fields, 585 preset roles (plus any typed title). The interviewer and scorer work as experts in the chosen field.

**Confidence & experience (live):** worked out each answer from the *content*: specificity, ownership ("I led/decided"), concrete numbers and decisiveness vs. hedging. It shows answer confidence, a running average and an experience estimate. It deliberately does **not** read emotion from the face or voice, because that is banned for hiring under EU AI Act Art. 5(1)(f) and is scientifically unreliable.

**Anti-cheat engine: detecting external AI helpers**
| Signal | How |
|---|---|
| Hidden AI listening & whispering answers | Background-voice detector: speech energy on the mic while the candidate isn't answering and Ava isn't speaking |
| Audio piped to another app/AI | Virtual audio device detection (VB-Cable, Voicemeeter, BlackHole, Loopback…) |
| Fake/overlay camera | Virtual camera detection (OBS, ManyCam, Snap Camera, DroidCam, mmhmm…) |
| Copilot window on another screen | Second-monitor detection (`screen.isExtended`), focus-loss/overlay detection, tab switches |
| Secure mode | Required full-screen + entire-screen share; exiting or stopping the share is flagged |
| Answers typed by a tool or pasted from chat | Keystroke forensics: text appearing without keystrokes, machine-uniform key rhythm, paste events |
| AI-written answers | Style detector (AI phrases, list structure, filler-free polish) + interviewer AI judgement |
| Relay pattern | Long silent pause, then a long polished answer with zero fillers (typical of reading an AI reply) |
| Consistency traps | The interviewer asks personal follow-ups only the real person could answer instantly; contradictions are flagged |

All signals feed a 0–100 risk meter and a clickable integrity timeline in the report (jumps to the recording). **They never auto-reject**; high risk sends the case to a human. A browser can't see a phone or second laptop held off camera. The background-voice detector and consistency traps are the main defence there, and production should add server-side gaze/face models and a proctoring desktop agent.

## v7 — Talent Match marketplace (a profile marketplace, like matrimonial sites)
- **Two sides, separate plans.** Companies: Free / Starter ₹4,999 / Pro ₹14,999 / Enterprise. Job seekers: Free / Gold ₹499 / Platinum ₹1,299. Prices are placeholders, and payment isn't wired up yet (it would need Razorpay or Stripe).
- **Gated profiles.** Free companies see only match cards with details blurred. Paid plans unlock full profiles (Starter 25/month, Pro unlimited) and show AI-verified interview scores.
- **Mutual-interest contact.** A company sends an interest → the candidate accepts → contact is shared → the company can invite them to an AI interview with one click.
- **Confidential job search for employed people.** Post expected salary, notice period and work mode, hide your name and employer behind an alias, and block specific companies (e.g. your current employer) from seeing you. Current salary is used for matching only, never shown.
- **Anonymous companies.** Company name is optional; "Hide our identity" makes the interviewer say "a confidential company".
- **Simple AI interviewer name.** Default "Ava"; pick Maya, Sam, Riya, Leo or Mia, or type any name.
- **Job-seeker extras.** Matched jobs, practice for each one, see who viewed you (Gold+), AI profile coach with salary benchmark (Platinum).
- **No photos, age, religion or caste fields.** Unlike matrimonial sites, profiles hold only job-related data, to avoid discrimination.

## v8 — 72,000+ jobs worldwide, yearly company pricing
- Job search across **72,007 titles** (from the MIT-licensed list in `data/`, plus the presets). Results appear as you type, each tagged with its auto-detected field; picking one sets the interview format.
- Company plans are now **billed yearly** and cost about 8–9% more: Starter ₹64,999/yr, Pro ₹1,94,999/yr, Enterprise from ₹9,99,999/yr. Job-seeker plans stay monthly.

## v9 — Human-like interviewer, music & audition studio
- **Animated interviewer:** 5 looks (Ava, Sam, Riya, Leo, Mia) that blink, lip-sync to the voice, move slightly while talking and nod after each answer. An **"AI" badge always stays visible**: disclosure is required by EU AI Act Art. 50 and US state laws, and pretending to be human would expose the platform to fraud claims.
- **Expressive voice:** pick any voice installed on the device; warm / neutral / energetic styles change pace and pitch.
- **Empathy:** the interviewer acknowledges feelings the candidate *says out loud* ("I'm nervous"), uses their own words back and keeps a natural, human manner. "I need a moment" pauses kindly. It never reads emotion from face or voice: that is banned in hiring (EU AI Act Art. 5(1)(f)) and unreliable.
- **Calm music:** optional ambient music generated live, which fades down automatically while the interviewer speaks.
- **Audition studio** (performing-arts roles): backing tracks in any key and tempo (ballad, pop, metronome, tanpura drone) plus a live pitch meter showing note, cents off and % in tune. The report adds a pitch analysis; artistry and expression are left to a human judge.

## v10 — More realistic interviewer
- **Shaded portraits:** realistic proportions, skin shading, iris detail, hair highlights, blazer and shirt, gentle breathing, blinking, and lips that open with the voice. Five distinct looks.
- **Real human presenter (most realistic):** upload a **photo** (shown with subtle breathing motion and a speaking glow), or an **idle video + talking video** of a real presenter. The app plays the talking clip whenever the interviewer speaks. Use only people who consented, or faces from an AI-avatar provider. The "AI" badge stays on.
- **Fully photoreal, lip-synced live human:** needs a streaming avatar provider (Tavus, HeyGen Interactive Avatar, D-ID Agents). Plug it in at the avatar tile; see ARCHITECTURE §1.6.

## v11 — Browse roles, field levels, work types, multiple languages
- **☰ Browse all** next to Role title: every role grouped under its field (38 fields, 72,000+ roles), with search that filters across all of them. Click a role to pick it.
- **Levels change with the field, and you can tick several:** Software → Intern, SDE I–III, Staff, Principal, Tech lead, EM… CTO. Education → Pre-school, LKG, UKG, **Class 1–12**, Diploma, UG, PG, PhD, competitive exams, adult & special-needs learners, plus teacher seniority. Medicine, Law, Sales, Call centre, Finance, Arts, Sports, Trades, Hospitality and Operations each have their own ladders.
- **Work type (multi-select):** Full-time, Part-time, **Hourly basis**, Daily wage, Contract, Freelance, Internship, Apprenticeship, **Private tutor (home tuition)**, Online tutor, Remote, Shift work, Temporary, Volunteer.
- **Interview languages (multi-select, 25 languages including 12 Indian):** the first ticked is spoken; the candidate may answer in any ticked language and the AI continues in theirs.
- The levels, work types and languages all go to the AI's rubric, questions and scoring.

## v12 — Full plan catalog (49 plans & add-ons)
Grouped tabs, a Monthly/Yearly toggle and an **⚙ Admin: show/hide plans** switch. The launch set is visible by default (Company Free/Basic/Starter/Pro; single unlock, 6-credit pack, job post, hiring fee; job-seeker Free/Verified/Boost/Gold; parent contact, match pack, Tutor Pro). Everything else is built and hidden until an admin ticks it.
- **Companies (9):** Free, Trial ₹499/7 days, Basic ₹1,499/mo or ₹14,999/yr, Starter ₹2,999/mo or ₹29,999/yr, Growth ₹5,999/mo, Pro ₹9,999/mo or ₹99,999/yr, Enterprise from ₹4,99,999/yr, Agency ₹7,999/mo, Campus ₹19,999 per season.
- **Pay as you go (12):** unlock ₹199, credit packs (₹999 for 6 / ₹4,999 for 35 / ₹9,999 for 80), job post ₹499 (+Urgent/Featured), hiring fee 8.33% (min ₹10,000), junior hire ₹4,999, hiring drive ₹25,000, background check ₹299, reference check ₹499, featured company page ₹1,999/mo, job alert blast ₹999.
- **Job seekers (10):** Free, Verified ₹99, Boost ₹49/₹99, Gold ₹199/mo, Platinum ₹499/mo, Fresher pack ₹299, coaching ₹999, resume ₹499/₹1,499, human mock interview ₹299, skill certificate ₹199.
- **Tutors & parents (8):** parent contact ₹299, match pack ₹799, demo class ₹99; Tutor Free/Pro ₹199/Premium ₹499/commission 10% of the first month; School/coaching centre ₹2,999/mo. Includes a **Find a home tutor** page.
- **Freelance & gig (4)** and **Extras (6)**, including the AI interviewer add-on marked *coming soon*.
- **Credits wallet:** unlocks come from the plan quota first, then credits.
- **Hiring-fee tracker:** "Mark hired" → enter the salary → the fee is calculated (₹4,999 fixed below ₹3 L/yr).
All purchases are demo-only. Real payments need a gateway such as Razorpay.

## v13 — Locations, app languages, safety & convenience
- **Locations:** companies set a head-office city, **multiple job cities** and a work mode (on-site/hybrid/remote). Candidates set their current city, **all the cities they can work in**, and whether they'll relocate. Matching scores each profile as Same city / Open to your city / Willing to relocate / Remote fit / Different city, and every card shows "📍 city · can work in … · ✈ relocate". 150+ Indian and international cities, and any city can be typed.
- **App in 14 languages:** English, Hindi, Bengali, Tamil, Telugu, Marathi, Gujarati, Kannada, Malayalam, Punjabi, Urdu, Spanish, French, Arabic (right-to-left for Urdu and Arabic). Covers the main menus and buttons; the rest of the text is still English. The translations need a native-speaker review before launch.
- **Shortlist (★)** and a "Shortlist only" filter.
- **Report profile (⚑):** hides the profile and logs it for moderation.
- **Saved searches & alerts (🔔):** save a role + cities + mode and re-run it in one click.
- **Chat after a mutual match (💬),** with an anti-scam warning.
- **Dark mode (◐)** and a **larger text (A+)** option for accessibility.

## v14 — "Describe who you need", tutor price update, more features
- **Describe who you need:** at the top of Job setup and in Talent Match. Employers write a sentence ("maths tutor for my Class 9 and 10 kids at home in Pune, Hindi or English") and the app picks the **role, field, levels/classes, work type, cities, languages, experience and budget**. It uses the AI when connected, otherwise built-in keyword rules plus a search of all 72,000 titles. The long role list is now folded away under "Selected role — change it manually".
- **Tutor plans up ~15–25%:** parent contact ₹349 (was ₹299), match pack ₹899 (₹799), demo class ₹129 (₹99), Tutor Pro ₹249/mo or ₹2,499/yr (₹199 / ₹1,999), Premium ₹599/mo or ₹5,999/yr (₹499 / ₹4,999), commission 12% (10%), school/coaching ₹3,499/mo or ₹34,999/yr (₹2,999 / ₹29,999).
- **🔔 Notifications centre:** interest accepted, chat replies, referral rewards, ratings.
- **🎁 Refer & earn:** a personal code and link; 5 credits for each paying referral.
- **⬇ Export shortlist to CSV.**
- **★ Tutor ratings** from parents after a contact.
