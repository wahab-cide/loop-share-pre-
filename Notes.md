# Loop @ Williams College — Reality-Check & Launch Blueprint

> **TL;DR:** Williams is a textbook *beach-head* for Loop. The biggest hurdles are (1) clearing Massachusetts TNC regulations and (2) making the unit economics work on very short hops. Solve those, and the campus can supply the traction metrics needed for a seed round.

---

## 1 | Regulatory Gatekeeping in Massachusetts

| Requirement | Notes |
|-------------|-------|
| **Register as a Transportation Network Company (TNC)** | • File with the MA Dept. of Public Utilities (DPU).<br>• $30 application fee **plus** a \$0.20 state surcharge on *every* completed ride (remitted quarterly).<br>• A proposal is on the table to raise that fee to **\$1** — stress-test your model accordingly. |
| **Driver eligibility** | • 21 + years old.<br>• U.S. driver’s licence **≥ 1 year** (≥ 3 years if driver is < 23).<br>• DMV + CORI background checks (run twice: by Loop *and* the DPU).<br>• Freshmen & sophomores generally **cannot** drive legally. |
| **Tightening labour rules** | MA has granted ride-hail drivers collective-bargaining rights and imposed a \$32.50/hr earnings floor on incumbents. Expect regulators to scrutinise newcomers. |
| **Insurance** | Secure a fleet-level policy (e.g., Mobilitas, Buckle) that bundles \$1 M liability per ride; individual drivers will balk at higher personal premiums. |

---

## 2 | Market Reality Around Williams College

| Signal | Implication for Loop |
|--------|----------------------|
| **Sparse Uber/Lyft supply** | Students currently rely on shuttles or informal ride boards — clear pain-point. |
| **Active WSO ride-share board** | Validates latent P2P demand; Loop offers a markedly better UX (instant pay, reviews). |
| **Small population (~2 500 undergrads) + rural setting** | Liquidity will be low on weekdays — concentrate on high-demand corridors (Albany-Rensselaer rail, Boston Logan, holiday breaks). |

---

## 3 | Launch Playbook (Semester 1)

| Phase | Key Activities | Success KPI |
|-------|----------------|-------------|
| **0. Prep (Jul–Aug)** | • Bind insurance.<br>• Obtain DPU TNC certificate.<br>• Set up weekly batched Stripe payouts to cut per-ride fees. | Licence & insurance in hand |
| **1. Seeding (Orientation)** | • Hire **8–10 “Loop Ambassadors”** (upper-class students with cars): \$200 stipend + guaranteed first-month earnings.<br>• Require `.edu` login for all users. | ≥ 50 active riders & ≥ 100 posted seats by end of orientation week |
| **2. Peak-Travel Blitz (Oct–Nov breaks)** | • Promo “Loop to Logan” flat \$45 seat (vs. \$67 shuttle).<br>• Show Williams Motorcoach schedules alongside Loop rides. | 70 % seat-fill rate on break-day listings |
| **3. Retention & Expansion (Jan)** | • Add Bennington College & MCLA to expand radius.<br>• Launch *Campus SafeRide* (10 pm–2 am) subsidised by the Dean’s Office. | MAU > 400 & repeat-ride rate ≥ 30 % |

---

## 4 | Unit-Economics Sanity Check

| Corridor (one-way) | Fare | Stripe Fee (2.9 % + \$0.30) | DPU Fee | Loop 8 % | Driver Net |
|--------------------|------|-----------------------------|---------|----------|-----------|
| **Albany Airport** (45 mi, 1 h) | \$45 | \$1.61 | \$0.20 | \$3.60 | **\$39.59** |
| **Local shuttle** (5 mi) | \$6 | \$0.47 | \$0.20 | \$0.48 | **\$4.85** |

*Key takeaway:* long-ish inter-city seats cover the fixed fees comfortably. Sub-\$10 hops leave < \$5 to the driver — consider a \$0.99 rider service fee or bundling micro-shuttle runs into punch-cards.

---

## 5 | Tech Tweaks for Rural Scale

* Keep Supabase Realtime for chat until ~1 k concurrent users; prototype a NATS-based event bus behind a feature flag.  
* Add SMS passcode-less auth for riders with weak cell data in the Berkshires.  
* Implement a **“Get home now”** quick-request that alerts all online drivers within 10 mi — crucial when density is thin.

---

### Bottom Line

Williams offers a controlled, high-signal environment to prove Loop’s thesis. Nail compliance and margins, run disciplined pilots, and you’ll gather the metrics needed for a compelling seed-stage story.

---

**Next Step →** Start the DPU filing and insurance quote **now** (4–6 week lead-time) to stay on track for a Fall-semester launch.
