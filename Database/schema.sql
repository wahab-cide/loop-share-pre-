-- ===========================================================
--  ENUM TYPES
-- ===========================================================
CREATE TYPE user_role       AS ENUM ('rider','driver','both');
CREATE TYPE trip_status     AS ENUM ('open','full','cancelled','completed');
CREATE TYPE booking_status  AS ENUM ('pending','confirmed','cancelled');
CREATE TYPE payment_status  AS ENUM ('requires_payment','succeeded','failed','refunded');

-- ===========================================================
--  PROFILES  (1-to-1 with auth.users)
-- ===========================================================
CREATE TABLE profiles (
  id             uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  full_name      text,
  avatar_url     text,
  default_role   user_role NOT NULL DEFAULT 'rider',
  rating_rider   numeric(3,2) DEFAULT 5.0,
  rating_driver  numeric(3,2) DEFAULT 5.0,
  created_at     timestamptz NOT NULL DEFAULT now()
);

-- ===========================================================
--  DRIVER PROFILE  (docs & verification)
-- ===========================================================
CREATE TABLE driver_profile (
  id                uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  license_front_url text,
  license_back_url  text,
  insurance_doc_url text,
  is_verified       boolean      DEFAULT false,
  created_at        timestamptz  DEFAULT now()
);

-- ===========================================================
--  VEHICLES  (driver may have many)
-- ===========================================================
CREATE TABLE vehicles (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id   uuid NOT NULL REFERENCES profiles(id),
  make        text,
  model       text,
  color       text,
  seats_total int  CHECK (seats_total BETWEEN 1 AND 8),
  plate       text,
  created_at  timestamptz DEFAULT now()
);

CREATE INDEX vehicles_driver_idx ON vehicles (driver_id);

-- ===========================================================
--  TRIPS  (future rides posted by drivers)
-- ===========================================================
BEGIN;

/* -----------------------------------------------------------
   1. ENUM: status of a ride
----------------------------------------------------------- */
CREATE TYPE ride_status AS ENUM ('open', 'full', 'completed', 'cancelled');

/* -----------------------------------------------------------
   2. RIDES (one row per posted trip)
----------------------------------------------------------- */
CREATE TABLE rides (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- FK to the driver (must already be a user)
  driver_id        UUID NOT NULL
                       REFERENCES users(id)
                       ON DELETE CASCADE,

  /* ORIGIN & DESTINATION
     - store both human-readable text and geo coords for maps / queries */
  origin_label     TEXT         NOT NULL,   -- “Campus Main Gate”
  origin_lat       NUMERIC(10,6) NOT NULL,  -- 6-dec places ≈ 0.11 m
  origin_lng       NUMERIC(10,6) NOT NULL,

  destination_label TEXT         NOT NULL,  -- “Accra, Circle”
  destination_lat   NUMERIC(10,6) NOT NULL,
  destination_lng   NUMERIC(10,6) NOT NULL,

  /* TIMING */
  departure_time   TIMESTAMPTZ   NOT NULL,
  arrival_time     TIMESTAMPTZ,              -- optional / ETA

  /* CAPACITY */
  seats_total      SMALLINT      NOT NULL CHECK (seats_total > 0),
  seats_available  SMALLINT      NOT NULL
                                 CHECK (seats_available >= 0
                                    AND seats_available <= seats_total),

  /* PRICING */
  price            NUMERIC(8,2)  NOT NULL,   -- total price per seat
  currency         CHAR(3)       NOT NULL DEFAULT 'USD',

  /* STATE */
  status           ride_status   NOT NULL DEFAULT 'open',

  /* AUDIT */
  created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

/* -----------------------------------------------------------
   3. Keep updated_at fresh
----------------------------------------------------------- */
CREATE OR REPLACE FUNCTION trg_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_rides
BEFORE UPDATE ON rides
FOR EACH ROW
EXECUTE PROCEDURE trg_set_updated_at();

/* -----------------------------------------------------------
   4. Helpful indexes
----------------------------------------------------------- */
CREATE INDEX rides_driver_idx     ON rides(driver_id);
CREATE INDEX rides_depart_idx     ON rides(departure_time);
CREATE INDEX rides_status_idx     ON rides(status);

COMMIT;


-- feed/sort index
CREATE INDEX trips_feed_idx ON trips (status, departure_at DESC);

-- ===========================================================
--  BOOKINGS  (rider reserves one or more seats on a trip)
-- ===========================================================
CREATE TABLE bookings (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id     uuid NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  rider_id    uuid NOT NULL REFERENCES profiles(id),
  seat_count  int  CHECK (seat_count > 0),
  status      booking_status DEFAULT 'pending',
  created_at  timestamptz DEFAULT now(),
  UNIQUE (trip_id, rider_id)          -- one booking per rider per trip
);

CREATE INDEX bookings_trip_idx ON bookings (trip_id);
CREATE INDEX bookings_rider_idx ON bookings (rider_id);

-- Keep seats_taken in sync (confirmed ↔ cancelled)  ──────────
CREATE OR REPLACE FUNCTION public.adjust_seats_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'confirmed' THEN
    UPDATE trips SET seats_taken = seats_taken + NEW.seat_count
    WHERE id = NEW.trip_id;
  ELSIF TG_OP = 'UPDATE' THEN
    -- confirmed → cancelled
    IF OLD.status = 'confirmed' AND NEW.status = 'cancelled' THEN
      UPDATE trips SET seats_taken = seats_taken - OLD.seat_count
      WHERE id = NEW.trip_id;
    -- cancelled → confirmed
    ELSIF OLD.status = 'cancelled' AND NEW.status = 'confirmed' THEN
      UPDATE trips SET seats_taken = seats_taken + NEW.seat_count
      WHERE id = NEW.trip_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_adjust_seats
AFTER INSERT OR UPDATE ON bookings
FOR EACH ROW EXECUTE PROCEDURE public.adjust_seats_count();

-- ===========================================================
--  TRIP MESSAGES  (1-to-1 chat: driver ↔ each rider)
-- ===========================================================
CREATE TABLE trip_messages (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id    uuid NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  sender_id  uuid NOT NULL REFERENCES profiles(id),
  body       text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX trip_messages_trip_idx ON trip_messages (trip_id, created_at);

-- ===========================================================
--  PAYMENTS  (Stripe intents & receipts)
-- ===========================================================
CREATE TABLE payments (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id            uuid NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  stripe_payment_intent text,
  amount_cents          int,
  currency              text DEFAULT 'usd',
  status                payment_status,
  created_at            timestamptz DEFAULT now()
);

-- ===========================================================
--  REVIEWS  (rider ↔ driver rating after trip completes)
-- ===========================================================
CREATE TABLE reviews (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id      uuid NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  reviewer_id  uuid NOT NULL REFERENCES profiles(id),
  reviewee_id  uuid NOT NULL REFERENCES profiles(id),
  rating       int CHECK (rating BETWEEN 1 AND 5),
  comment      text,
  created_at   timestamptz DEFAULT now(),
  UNIQUE (trip_id, reviewer_id)   -- one review per reviewer per trip
);

-- ===========================================================
--  PUSH TOKENS  (Expo / FCM notifications)
-- ===========================================================
CREATE TABLE push_tokens (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  token      text,
  platform   text,
  created_at timestamptz DEFAULT now()
);

-- ===========================================================
--  ROW-LEVEL SECURITY (enable only – policies can be applied later)
-- ===========================================================
ALTER TABLE profiles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_profile  ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips           ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings        ENABLE ROW LEVEL SECURITY;
ALTER TABLE trip_messages   ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments        ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews         ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_tokens     ENABLE ROW LEVEL SECURITY;

