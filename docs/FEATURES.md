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
