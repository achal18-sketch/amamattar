# Management audit — TalentCore (as of 23 Oct 2026)

Scope: the whole project. That means the app (`app/index.html`), the business model and pricing, legal and compliance, technology, operations, and the documents. Ratings: 🔴 must fix before launch · 🟠 fix in the first 3 months · 🟢 fine or minor.

## 1. Executive summary
- **Product:** a rich, working **demo**, not a launchable product. Accounts, a database, payments and verification are all simulated, and every piece of data lives only in one browser.
- **Business model:** sound and differentiated (mutual interest, confidential search, pay-on-hire, tutors and household help). But it is spread across too many segments and 49+ plans for a small team.
- **Biggest commercial risk:** **companies hiring off-platform** after contact details are shared. That loses the hiring fee, which is the largest revenue line.
- **Biggest legal risks:** (a) the **Digital Personal Data Protection Act 2023**, which requires consent and a privacy notice for candidate data; (b) **overseas cities** in the app, since recruiting for jobs abroad needs a recruiting-agent licence under the Emigration Act 1983; (c) **child safety** for tutors and household help, plus no age checks for workers.
- **₹1 Cr/month after tax** is possible only at roughly 25× the launch-stage volumes. Plan for 3–5 years and outside funding.

## 2. Findings

### A. Product & technology
| # | Finding | Severity | Recommendation |
|---|---|---|---|
| A1 | No backend: no logins, database, payments or real messaging. Everything is in `localStorage` (one browser). | 🔴 | Build an MVP backend with phone OTP login and a database (e.g. Supabase or Firebase). Add Razorpay for payments and a WhatsApp Business API provider. |
| A2 | The Admin tab, plan visibility switch and investor numbers are open to every user. | 🔴 | Admin login with roles; remove admin features from the public app. |
| A3 | "Verified company" checks only the GSTIN/CIN *format*. Police verification and background checks are labels only. | 🔴 | Integrate GST, MCA and KYC verification APIs and a background-check partner. Don't show "verified" until the check is real. |
| A4 | Free-first-hire, credits and plan limits can be reset by clearing the browser. | 🟠 | Enforce on the server, tied to a verified company account. |
| A5 | A single 1.8 MB HTML file with ~850 lines of dense script and 72k job titles inline. Hard to maintain or test. Automated tests exist only outside the repo. | 🟠 | Split into a proper app (React or Next.js), load titles on demand, and commit the Playwright tests and run them on every change. |
| A6 | XSS check: user text is escaped (`esc()`) in rendered HTML. A few values go into prompts or text boxes, which is safe. Device voice language isn't escaped (low risk). | 🟢 | Keep the escape rule. Add a content-security policy when hosting. |
| A7 | Hidden AI-interviewer code (~40% of the script) is still shipped behind `AI_INTERVIEWER=false`. | 🟢 | Fine for now. Move it into its own module before the code is split up. |
| A8 | Resume upload accepts only text files. "3 upgrades a month" never resets. | 🟠 | PDF/DOCX parsing on the server; monthly counters on the server. |

### B. Business model & pricing
| # | Finding | Severity | Recommendation |
|---|---|---|---|
| B1 | **Disintermediation:** once contact is shared, a company can hire off-platform and skip the 8.33% fee. | 🔴 | Terms of service with a fee if the candidate is hired within 12 months of introduction. Keep chat and calls in the app. Offer cheap "pay on hire" (first hire free, ₹4,999 for junior hires) so honesty is easy. Follow up with candidates ("Did you join?"). |
| B2 | 49 plans across 7 audiences. Too much to sell and support at launch. | 🟠 | Launch with 1 city + 2 segments: e.g. SMB hiring (Basic/Starter/Pro + pay-on-hire) **and** tutors. Keep the rest switched off. |
| B3 | Prices are inconsistent across materials. The design mock-up shows old yearly prices (Starter ₹64,999, Pro ₹1,94,999); the app shows Starter ₹29,999/yr and Pro ₹99,999/yr. The investor calculator uses a flat ₹3,000 average plan and ₹5,500 per junior hire. | 🟠 | One price sheet as the source of truth; update the mock-up and calculator from it. |
| B4 | Job-seeker revenue (~20–25% of the ₹1 Cr model) depends on people paying in a market used to free job sites. | 🟠 | Treat it as upside. Base the plan on company revenue and hiring fees. |
| B5 | Cost of winning customers, cancellations and refunds aren't modelled. | 🟠 | Add CAC per channel, monthly churn and payback period to the investor dashboard before fundraising. |
| B6 | Collecting hiring fees means invoices, payment follow-ups and disputes. | 🟠 | Fee agreement signed at hire, auto-invoice, 15-day payment terms, and a replacement-guarantee policy in writing. |

### C. Legal & compliance (India) — get a lawyer and a CA to confirm
| # | Finding | Severity | Recommendation |
|---|---|---|---|
| C1 | **DPDP Act 2023:** no privacy notice, consent record, data-deletion option or grievance officer. | 🔴 | Privacy policy, consent on sign-up, "delete my data", a named grievance officer, data stored in India. |
| C2 | **Terms of service, refund and cancellation policy:** missing. Payment gateways require them before going live. | 🔴 | Publish Terms, Refund/Cancellation, Fee agreement and Community rules. |
| C3 | **Overseas jobs:** Dubai, Doha, Riyadh, Muscat, Kuwait City and others can be chosen as job cities. Recruiting Indians for jobs abroad needs an MEA recruiting-agent licence (Emigration Act 1983). | 🔴 | Remove overseas job locations, or limit them to "candidate can work in" until you hold the licence. |
| C4 | **Child safety:** tutors and household workers enter homes with children; no age, police or ID enforcement. | 🔴 | Mandatory 18+ age check for workers and tutors, ID KYC, and police verification before a "verified" badge. Clear safety guidance for parents. |
| C5 | **Placement-agency rules and labour laws:** some states regulate private placement agencies and domestic workers, and minimum wages apply. | 🟠 | Legal check for each launch state. Show the minimum wage when families post household jobs. |
| C6 | **IT Rules 2021 / Consumer Protection (E-Commerce) Rules 2020:** need a grievance officer, a complaint-handling time limit and seller/platform disclosures. | 🟠 | Add a grievance contact and complaint tracking. |
| C7 | **GST:** displayed correctly (18%, CGST+SGST/IGST). Not yet registered; SAC codes unconfirmed; the seller state is a placeholder. | 🟠 | Register (compulsory once turnover passes ₹20 lakh, and usually needed for online services from day one); a CA confirms the SAC codes; issue invoices through Razorpay or Zoho. |
| C8 | Ratings of people (employees, tutors, parents) carry defamation and fairness risk. | 🟠 | Rate only after a verified hire or class, with a moderation and appeal process. No free-text attacks. |
| C9 | Fairness: no photos, age, religion or caste fields, and current salary is never shown. | 🟢 | Keep this. It is a strength and a selling point. |

### D. Operations
| # | Finding | Severity | Recommendation |
|---|---|---|---|
| D1 | No support, fraud-review or verification process behind ⚑ Report. | 🔴 | A moderation queue, a 24-hour review service level, and ban rules. |
| D2 | The hiring-fee model needs people: a sales person per city plus hiring assistants. | 🟠 | Budget 1 salesperson and 1 operations person per city from day one. |
| D3 | No measurements yet for hires, response rate or activation. | 🟠 | Weekly dashboard of hires, paying companies, 100-hour reply rate, and fraud reports. |

### E. Documentation
| # | Finding | Severity | Recommendation |
|---|---|---|---|
| E1 | `README.md`, `ARCHITECTURE.md`, `API_AND_EVENTS.md` and `prompts/` still describe the AI-interviewer agency ("50,000 interviews/day"), not the current marketplace. | 🟠 | Rewrite the README for the marketplace; mark the AI documents as "Phase 2". |
| E2 | `FEATURES.md` is a 23-version change log with old prices mixed in. | 🟢 | Add a one-page "Current product & prices" sheet. |
| E3 | `db/schema.sql` covers AI interviews, not marketplace items (interests, credits, hires, invoices, tutors, household workers, campus). | 🟠 | Extend the schema for the marketplace before building the backend. |

## 3. Priority plan
**Before any real user (4–8 weeks):** A1, A2, A3, B1, C1, C2, C3, C4, D1.
**First 3 months:** B2, B3, B5, B6, C5–C8, A4, A5, A8, D2, D3, E1, E3.
**Later:** A7, E2, bring back the AI interviewer as a paid add-on.

## 4. What is strong
- **Positioning:** mutual interest, confidential search, the 100-hour reply promise, salary on every job, first hire free, and scam reporting answer real problems with the big job sites.
- **Reach:** 72k searchable roles, "describe who you need", 14 app languages, and support-staff, tutor, household and campus segments.
- **Pricing:** revenue streams with high margins (hiring fees, unlocks, verification add-ons) and transparent GST pricing.
- **Fairness by design:** no photos, age, caste or religion fields.
