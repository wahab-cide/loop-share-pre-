# 🎨 Loop UI Guidelines (Developer Reference)

This document outlines essential design decisions and UI standards used throughout **Loop’s** mobile app. Follow these principles to ensure consistency, usability, and visual polish.

---

## 🖤 1. Color System

| Color Role     | Token            | Hex        | Usage                               |
| -------------- | ---------------- | ---------- | ----------------------------------- |
| Background     | `bg.page`        | `#0D0D0D`  | Main dark background                |
| Surface        | `bg.surface`     | `#161616`  | Cards, sheets, overlays             |
| Text Primary   | `text.primary`   | `#FFFFFF`  | Headings, body text                 |
| Text Secondary | `text.secondary` | `#B3B3B3`  | Captions, hints                     |
| Brand Blue     | `brand.600`      | `#2563EB`  | Links, active buttons               |
| Success Green  | `green.600`      | `#10B981`  | Booked, available indicators        |
| Danger Red     | `red.600`        | `#F87171`  | Errors, full rides                  |
| Warning Amber  | `amber.600`      | `#FBBF24`  | Low seat warnings                   |
| Borders        | `neutral.200`    | `#353535`  | Light dividers                      |

> **Tailwind Usage:** apply as `bg-bg-surface`, `text-text-secondary`, etc. in NativeWind.

---

## 🔠 2. Typography Scale

| Text Role      | Font Weight    | Size (px) | Tailwind Class                  |
| -------------- | -------------- | --------- | ------------------------------- |
| Screen title   | `Inter-Bold`   | 28        | `text-[28px] font-interBold`    |
| Section title  | `Inter-SemiBold` | 24      | `text-[24px] font-interSemiBold`|
| Card title     | `Inter-Medium` | 20        | `text-[20px] font-interMedium`  |
| Body / input   | `Inter-Regular`| 16        | `text-base font-inter`          |
| Secondary text | `Inter-Regular`| 14        | `text-sm text-text-secondary`   |
| Caption/meta   | `Inter-Regular`| 12        | `text-xs`                       |

Line‑height: use `leading-tight` for headings, `leading-snug` for paragraphs.

---

## 🧩 3. Component Behaviors

### 🔘 Buttons
| Variant | Classes | Notes |
|---------|---------|-------|
| Primary | `bg-white text-black rounded-2xl px-4 py-2` | Use on main CTAs (e.g., **Book Ride**) |
| Secondary | `bg-transparent border border-white text-white rounded-2xl px-4 py-2` | Less‑prominent actions |
| Ghost | `bg-transparent text-text-secondary px-4 py-2` | Toolbar icons, inline actions |
| Disabled | `opacity-40` | Cursor: default |

### 📦 Cards
* Container: `bg-bg-surface rounded-xl p-4 border border-neutral-200`
* Press feedback: `scale-95` on press via `react-native-reanimated`
* Include `Badge` components for status (see Colors)

### 🧭 Tab Bar & Header
* Bottom Tabs: `bg-bg.page`, icon/label `text-text-secondary`
* Active tab: `text-brand-600`
* Header right buttons:
  * `Plus` → post ride `bg-white text-black rounded-full p-2`
  * `Search` → opens modal `bg-transparent border border-white p-2 rounded-full`

---

## 💬 4. Feedback & States

| Type      | Component        | Styling                                    |
|-----------|------------------|--------------------------------------------|
| Loading   | `ActivityIndicator` or 3‑dot Lottie | Centered overlay |
| Success   | Toast (`bg-green-600 text-white`)   | Auto‑dismiss 2s  |
| Error     | Toast (`bg-red-600 text-white`)     | Sticky until user dismiss |
| Warning   | Amber badge `bg-amber-600`          | Use on seat‑count < 2 |
| Empty     | Illustration SVG + `text-text-secondary` message | Centered flex‑1 |

---

## 📱 5. Splash & Branding

| Element | Spec |
|---------|------|
| Background | `bg-page` (`#0D0D0D`) |
| Logo | White car glyph (SVG, 80 × 80) |
| Title | `LOOP` – `Inter-Bold 28px` |
| Subtitle | `Community Rides` – `text-secondary` |
| Loader | 3 green (`green-600`) dots, pulse every 600 ms |

---

## 📐 6. Layout & Spacing

* **Base unit:** 8 px (`gap-2` == 8 px, `p-2` == 8 px).
* **Cards:** `p-4` inside, `space-y-2` between internal rows.
* **Lists / Forms:** `space-y-2` between list items or form fields.
* **BottomSheet:** snap points at **30 %** and **70 %** of screen height.

---

## 7. Dark Mode

Loop defaults to **dark UI**; light mode will ship post‑v1.2. Ensure:
* `bg-bg-surface` stays legible against `bg-page`.
* Shadows replaced by subtle `border` with reduced opacity.

---

## 8. Motion & Interaction

* Use **`moti`** for `FadeIn`, `SlideInRight`, `Scale` micro‑animations.
* Keep animation duration ≤ 300 ms to maintain perceived speed.
* Avoid parallaxes until performance validated on low‑end devices.

---

## 9. Accessibility

* Minimum touch target: **48 × 48 px**.
* Provide `accessibilityLabel` on icons & buttons.
* Ensure color contrast ratios pass WCAG AA (≥ 4.5:1 for text).

---

## 10. Assets & Icons
| Asset type | Location | Notes |
|------------|----------|-------|
| SVG icons  | `/assets/icons/` | Use **Lucide** set, 24 px baseline |
| Animations | `/assets/animations/` | Lottie JSON (splash, success, loader) |
| Illustrations | `/assets/illustrations/` | Empty states |

---

### Need changes?
Open a ticket in **#design‑system** or update this doc via PR.
