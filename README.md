# Loop 🚗📍

*A Social, Community‑Driven Ride‑Sharing Platform*

---

## Table of Contents

1. [Project Vision](#project-vision)
2. [Feature Overview](#feature-overview)
3. [Solution Architecture](#solution-architecture)
4. [Tech Stack & Rationale](#tech-stack--rationale)
5. [Folder Structure](#folder-structure)
6. [Environment Variables](#environment-variables)
7. [Database Schema](#database-schema)
8. [API Contracts](#api-contracts)
9. [Realtime Messaging & Notifications](#realtime-messaging--notifications)
10. [Testing Strategy](#testing-strategy)
11. [CI / CD](#ci--cd)
12. [Roadmap](#roadmap)

---

## Project Vision

Loop merges the discovery mechanics of social media with the utility of ride sharing. **Anyone can post a ride** (origin → destination, date, time, seats, price) and **anyone nearby can book it**. Comments are replaced with **driver reviews**, encouraging transparency and community trust.

---

## Feature Overview

### Implemented 🟢

* **Onboarding Flow** – splash, walkthrough, account setup.
* **Email + Password Authentication** with verification (Clerk).
* **Google OAuth** single‑tap login.
* **Role‑based Authorization** (rider / driver / admin).
* **Home Screen** with live location map & nearby car markers.
* **Recent Rides** list (+ receipts).
* **Google Places Autocomplete** for origin/destination.
* **Find Rides** – search by places or by selecting pins on the map.
* **Ride Detail & Confirmation** – fare, driver profile, ETA.
* **Stripe Payments** – cards, Apple/Google Pay.
* **Ride Creation after Successful Payment** – booking workflow.
* **Profile Management** – user data, avatars, payment methods.
* **History Tab** – all past rides & ratings.
* **Responsive** – polished UX on iOS & Android.

### In Progress 🟠

* **Nearby Rides Feed** (infinite scroll by geo‑radius).
* * **In‑App Messaging** (Supabase Realtime)
* **Push Notifications** (Expo Notifications / FCM).

### Planned 🔜

* Advanced filters (price, seats, departure window).
* Live driver location sharing during trip.
* Multi‑language (i18n).
* Carpool / shared‑ride mode.
* Analytics dashboard for drivers.

---

## Solution Architecture

```
Expo RN App ───► tRPC Gateway ─► Node.js 20 Services
      ▲                        │
      │                        ├─► Neon Postgres (Prisma)
      │                        ├─► Stripe Webhooks
      │                        └─► Supabase Realtime
```

*Every service runs in its own container and is deployed via GitHub Actions to Fly.io.*

---

## Tech Stack & Rationale

| Layer         | Choice                           | Why                                                        |
| ------------- | -------------------------------- | ---------------------------------------------------------- |
| **Mobile**    | Expo + React Native (TypeScript) | OTA updates, single codebase                               |
| **UI**        | Tailwind CSS (NativeWind)        | Utility‑first styling, rapid prototyping                   |
| **State**     | Zustand                          | Tiny, unopinionated, hooks friendly                        |
| **Server**    | Node.js 20 + tRPC                | End‑to‑end type safety, no GraphQL overhead                |
| **DB**        | Neon Postgres (Prisma)           | Branching, serverless, CI snapshots                        |
| **Auth**      | Clerk                            | Social + magic link, GDPR ready                            |
| **Payments**  | Stripe                           | Industry standard, RN SDK                                  |
| **Maps**      | Google Maps Platform             | Routing, Places, Directions APIs                           |
| **Messaging** | Supabase Realtime + Expo Push    | Same Postgres source of truth; realtime chat & device push |
| **CI/CD**     | GitHub Actions + Expo EAS        | Automated builds, test, deploy                             |

---

## Folder Structure

```text
loop/
├─ app/                          # Expo Router (file‑based navigation)
│  ├─ api/                       # Edge‑function routes ("/api/*")
│  │  ├─ stripe/
│  │  │  ├─ create+api.ts        # /api/stripe/create
│  │  │  └─ pay+api.ts           # /api/stripe/pay
│  │  ├─ driver+api.ts           # /api/driver
│  │  ├─ ride/                   # /api/ride/* (RESTish stubs → tRPC soon)
│  │  └─ user+api.ts             # /api/user
│  ├─ auth/                      # Auth stack
│  │  ├─ _layout.tsx             # Nested route layout
│  │  ├─ sign‑in.tsx
│  │  ├─ sign‑up.tsx
│  │  └─ welcome.tsx
│  ├─ root/                      # Main app shell
│  │  ├─ tabs/                   # Bottom‑tab navigator
│  │  │  ├─ _layout.tsx
│  │  │  ├─ chat.tsx
│  │  │  ├─ home.tsx             # Feed (TBD)
│  │  │  ├─ profile.tsx
│  │  │  ├─ rides.tsx
│  │  │  └─ post.tsx             # Create ride (TBD)
│  │  ├─ _layout.tsx             # Root stack layout
│  │  ├─ book‑ride.tsx
│  │  ├─ confirm‑ride.tsx
│  │  └─ find‑ride.tsx
│  ├─ _layout.tsx
│  └─ index.tsx
├─ assets/                       # Fonts, images, animations
├─ components/                   # Shared UI primitives (Tailwind‑styled)
├─ constants/                    # Static config & enums
├─ lib/                          # Helper libs (API client, Stripe, geo utils)
├─ scripts/                      # Dev/CI helper scripts
├─ store/                        # Zustand slices
├─ types/                        # Global TS types & interfaces
└─ README.md
```

---



## Environment Variables

Create a `.env` in the project root (or copy `.env.example`).

```env
# Authentication
EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=

# Payments
EXPO_PUBLIC_STRIPE_PUBLISHABLE_KEY=
STRIPE_SECRET_KEY=

# Google Maps
EXPO_PUBLIC_PLACES_API_KEY=
EXPO_PUBLIC_DIRECTIONS_API_KEY=

# Database
DATABASE_URL="postgresql://loop:password@localhost:5432/loop"

# Server
EXPO_PUBLIC_SERVER_URL=http://localhost:3000

# Messaging / Realtime
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Expo Push – no client secret, server worker uses the service role key
```


---

## Database Schema

<details>
<summary>Click to view condensed Prisma schema</summary>

```prisma
model User {
  id          String   @id @default(cuid())
  clerkId     String   @unique
  name        String?
  avatarUrl   String?
  rides       Ride[]   @relation("DriverRides")
  bookings    Booking[]
  reviews     Review[] @relation("DriverReviews")
}

model Ride {
  id          String   @id @default(cuid())
  driverId    String
  driver      User     @relation("DriverRides", fields: [driverId], references: [id])
  originLat   Float
  originLng   Float
  destLat     Float
  destLng     Float
  departureAt DateTime
  seats       Int
  price       Int      // cents
  bookings    Booking[]
  reviews     Review[]
  createdAt   DateTime @default(now())
}

model Booking {
  id        String   @id @default(cuid())
  rideId    String
  riderId   String
  status    BookingStatus @default(PENDING)
  ride      Ride   @relation(fields: [rideId], references: [id])
  rider     User   @relation(fields: [riderId], references: [id])
  createdAt DateTime @default(now())
}
```

</details>

Run `pnpm db:studio` for a browser GUI to inspect tables.

---

## API Contracts

Endpoints live in `packages/api/src/routers`. Example:

```ts
// POST /ride.create
input: {
  origin: { lat: number; lng: number; address: string };
  destination: { lat: number; lng: number; address: string };
  departureAt: string; // ISO string
  seats: number;
  price: number; // cents
}
```

Client & server share types via tRPC – no manual DTOs.

---

## Realtime Messaging & Notifications

Loop uses **Supabase Realtime** for WebSocket-based in‑app chat and **Expo Push Notifications** (which deliver via APNs/FCM) for device alerts.

### How It Works

1. **Message Table** – `message` rows (`id`, `rideId`, `senderId`, `body`, `sentAt`).
2. **Supabase Publication** – `ALTER PUBLICATION supabase_realtime ADD TABLE public.message;` streams row inserts.
3. **Client Subscribe** – React Native app connects with `@supabase/realtime-js`:

```ts
const channel = supabase.channel(`ride:${rideId}`)
  .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'message', filter: `ride_id=eq.${rideId}` }, handleMsg)
  .subscribe();
```

4. **Push Worker** – A Fly.io job listens on the same channel server‑side; when `INSERT` fires it looks up recipients' `expoPushToken`s and posts to `https://exp.host/--/api/v2/push/send`.

### Keys & Config

| Key                         | Where it lives         | Used by                   |
| --------------------------- | ---------------------- | ------------------------- |
| `SUPABASE_URL`              | `.env`, GitHub Secrets | Mobile, API, Worker       |
| `SUPABASE_ANON_KEY`         | public env             | Mobile client             |
| `SUPABASE_SERVICE_ROLE_KEY` | secret env             | Push worker (read tokens) |
| `EXPO_PUBLIC_SERVER_URL`    | public env             | Mobile client             |

Expo SDK requires no secret on the client; just the device‑specific `expoPushToken`.

\--------------------------------|---------------------------------------|----------------------------------------------|
\| **Firebase (Firestore + FCM)** | RN SDK, battle‑tested push, free tier | Separate data store, vendor lock‑in          |
\| **Supabase Realtime + Expo**   | Same Postgres source of truth         | Requires small relay for push notifications  |

A design spike lives in `/experiments/messaging‑supabase`. Join the discussion in **#architecture**.

---

## Testing Strategy

* **Unit:** Vitest + `@testing-library/react‑native`
* **E2E:** Playwright (Expo in browser) + Mock Service Worker
* **Quality Gates:** ESLint, Prettier, TypeScript `strict`

```bash
pnpm test        # unit
pnpm test:e2e    # end‑to‑end
pnpm lint        # static checks
```

---

## CI / CD

* **PRs:** lint + unit tests + Expo preview comment.
* **Main:** build & publish EAS internal → deploy API to Fly.io → run migrations.
* **Tags `v*`:** EAS build & App Store / Play Store submit.

Workflows are under `.github/workflows/`.

---

## Roadmap

| Milestone | Description                                                  |
| --------- | ------------------------------------------------------------ |
| **v0.9**  | Nearby Feed MVP, messaging tech decision, notification POC   |
| **v1.0**  | GA launch: complete chat, push, analytics, app‑store release |
| **v1.1**  | Advanced search filters, i18n, carpool mode                  |
| **v1.2**  | Live driver tracking, corporate ride accounts                |

---



---

**Happy Looping!** 🎉
