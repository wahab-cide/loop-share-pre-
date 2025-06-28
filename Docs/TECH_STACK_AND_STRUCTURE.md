# Loop – Tech Stack & Project Structure (June 2025)

This document gives incoming contributors a quick reference to the **current agreed‑upon stack** and where everything lives in the repo.

---

## 1 · Tech Stack Overview

| Layer | Choice | Role in Loop |
|-------|--------|--------------|
| **Mobile shell** | Expo + React Native (TypeScript) | Single iOS/Android codebase, OTA via EAS |
| **UI / Styling** | NativeWind (Tailwind‑style RN) | Utility‑first styling, zero runtime cost |
| **Client state & data** | React Query | Server‑state cache, mutations, background refetch |
| **Authentication** | Clerk | Email/password, magic links, Google/Apple OAuth |
| **Database** | PostgreSQL (Supabase) | Source of truth for users, rides, bookings; RLS policies |
| **Backend‑as‑a‑Service** | Supabase | Hosts Postgres, Realtime WS, Edge Functions, admin console |
| **Realtime chat / ride status** | Supabase Realtime | Streams chat messages & booking updates |
| **Payments** | Stripe (Checkout / PaymentSheet) | PCI‑safe fare collection, Apple/Google Pay, Connect payouts |
| **Maps & Geocoding** | Google Maps SDK + Places/Directions API | Map canvas, autocomplete, routing, ETA |
| **Push notifications** | Expo Push | Unified bridge to APNs & FCM |
| **Hosting / CI & CD** | GitHub Actions + Expo EAS | Lint/tests, native builds, OTA “rolling” channel |
| **Monitoring / Logs** | Expo Updates dash + Supabase Logs | Crash & query visibility, edge‑function logs |

---

## 2 · Repo Structure

```text
loop/                           # root Expo/TypeScript monorepo
├─ app/                         # Expo Router (file‑based navigation)
│  ├─ _layout.tsx               # global stack layout
│  ├─ index.tsx                 # splash / onboarding entry
│  ├─ auth/                     # Clerk-driven auth flows
│  │  ├─ sign-in.tsx
│  │  ├─ sign-up.tsx
│  │  └─ welcome.tsx
│  ├─ root/                     # protected area once logged-in
│  │  ├─ _layout.tsx
│  │  └─ tabs/                  # bottom‑tab navigator
│  │     ├─ home.tsx            # map + nearby rides feed
│  │     ├─ post-ride.tsx
│  │     ├─ rides.tsx           # bookings & history
│  │     ├─ chat.tsx
│  │     └─ profile.tsx
│  └─ api/                      # Expo edge routes proxying to Supabase
│     ├─ stripe/                # Stripe webhooks
│     │  └─ webhook+api.ts
│     └─ clerk/                 # Clerk webhook proxy
│        └─ webhook+api.ts
├─ components/                  # shared UI primitives (NativeWind‑styled)
│  ├─ Button.tsx
│  ├─ Card.tsx
│  └─ MapView.tsx               # RN Google Maps wrapper
├─ hooks/                       # React‑Query & auth helpers
│  ├─ useUser.ts
│  └─ useRideFeed.ts
├─ lib/                         # third‑party SDK wrappers
│  ├─ clerk.ts                  # Clerk Expo helper
│  ├─ supabase.ts               # Supabase client
│  ├─ queries/                  # typed React‑Query fetchers
│  │  ├─ rides.ts
│  │  └─ payments.ts
│  └─ maps.ts                   # Google Maps / Places adapter
├─ constants/                   # static config & tokens
│  └─ index.ts
├─ sql/                         # Supabase CLI migrations
│  ├─ 001_init.sql
│  └─ 002_add_bookings.sql
├─ scripts/                     # dev & CI helpers
│  ├─ dev.sh
│  └─ expo-eas-promote.mjs
├─ .github/
│  └─ workflows/
│     ├─ lint-test.yml
│     └─ eas-build.yml
├─ tailwind.config.js           # NativeWind tokens
├─ app.json                     # Expo config (incl. Clerk redirect scheme)
├─ .env.example
└─ README.md
```

> **Tip 🚀**  
> Keep anything vendor‑specific behind wrappers in **`lib/`** so swapping providers later (e.g., Mapbox for maps, Ably for chat) only touches a single file.

---
