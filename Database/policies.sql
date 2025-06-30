/* ============================================================
   PROFILES  ──────────────────────────────────────────────────
============================================================ */
CREATE POLICY "profiles: owner read / update"
ON profiles
FOR SELECT, UPDATE
USING  ( auth.uid() = id );

-- If you create the profile row client-side (Variant A)
CREATE POLICY "profiles: owner insert"
ON profiles
FOR INSERT
WITH CHECK ( auth.uid() = id );

/* ============================================================
   DRIVER_PROFILE  (verification docs)
============================================================ */
CREATE POLICY "driver_profile: owner CRUD"
ON driver_profile
FOR SELECT, INSERT, UPDATE
USING  ( auth.uid() = id )
WITH CHECK ( auth.uid() = id );

/* ============================================================
   VEHICLES  (1 driver → many vehicles)
============================================================ */
CREATE POLICY "vehicles: driver CRUD"
ON vehicles
FOR ALL
USING  ( auth.uid() = driver_id )
WITH CHECK ( auth.uid() = driver_id );

/* Optional – allow INSERT only for verified drivers */
CREATE POLICY "vehicles: only verified drivers insert"
ON vehicles
FOR INSERT
WITH CHECK (
  auth.uid() = driver_id
  AND EXISTS (
        SELECT 1
        FROM driver_profile dp
        WHERE dp.id = auth.uid()
          AND dp.is_verified = TRUE
      )
);

/* ============================================================
   TRIPS  (future rides)
============================================================ */
-- Anyone (logged-in) may browse OPEN trips
CREATE POLICY "trips: public read open trips"
ON trips
FOR SELECT
USING ( status = 'open' );

-- Drivers read / manage their own trips
CREATE POLICY "trips: driver read / update / delete"
ON trips
FOR SELECT, UPDATE, DELETE
USING ( auth.uid() = driver_id );

-- Drivers post trips  (only if verified)
CREATE POLICY "trips: verified driver insert"
ON trips
FOR INSERT
WITH CHECK (
  auth.uid() = driver_id
  AND EXISTS (
        SELECT 1
        FROM driver_profile dp
        WHERE dp.id = auth.uid()
          AND dp.is_verified = TRUE
      )
);

/* ============================================================
   BOOKINGS  (seats reserved by riders)
============================================================ */
-- Rider may read / cancel their own booking
CREATE POLICY "bookings: rider owns row"
ON bookings
FOR SELECT, UPDATE, DELETE
USING ( auth.uid() = rider_id );

-- Driver may read & confirm bookings on their trip
CREATE POLICY "bookings: driver manages bookings"
ON bookings
FOR SELECT, UPDATE
USING (
  auth.uid() = (
    SELECT driver_id FROM trips t
    WHERE t.id = bookings.trip_id
  )
);

-- Rider creates a booking (only if trip is OPEN and seats available)
CREATE POLICY "bookings: rider inserts booking"
ON bookings
FOR INSERT
WITH CHECK (
  auth.uid()   = rider_id
  AND seat_count > 0
  AND EXISTS (
        SELECT 1
        FROM trips t
        WHERE t.id = bookings.trip_id
          AND t.status       = 'open'
          AND t.seats_total - t.seats_taken >= seat_count
      )
);

/* ============================================================
   TRIP_MESSAGES  (chat)
============================================================ */
-- Participants (driver OR any booked rider) may read / send
CREATE POLICY "trip_messages: participants read"
ON trip_messages
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM trips t
    WHERE t.id = trip_messages.trip_id
      AND (
        auth.uid() = t.driver_id
        OR EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.trip_id = t.id
              AND b.rider_id = auth.uid()
              AND b.status   = 'confirmed'
        )
      )
  )
);

CREATE POLICY "trip_messages: participants insert"
ON trip_messages
FOR INSERT
WITH CHECK (  -- same participant check
  EXISTS (
    SELECT 1
    FROM trips t
    WHERE t.id = trip_messages.trip_id
      AND (
        auth.uid() = t.driver_id
        OR EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.trip_id = t.id
              AND b.rider_id = auth.uid()
              AND b.status   = 'confirmed'
        )
      )
  )
  AND sender_id = auth.uid()
);

/* ============================================================
   PAYMENTS  (Stripe)
   – usually written by edge-function with service-role key
============================================================ */
CREATE POLICY "payments: participant read"
ON payments
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM bookings b
    JOIN trips t ON t.id = b.trip_id
    WHERE b.id = payments.booking_id
      AND (
        auth.uid() = b.rider_id
        OR auth.uid() = t.driver_id
      )
  )
);

/* ============================================================
   REVIEWS  (post-trip ratings)
============================================================ */
CREATE POLICY "reviews: participants read"
ON reviews
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM trips t
    WHERE t.id = reviews.trip_id
      AND (
        auth.uid() = t.driver_id
        OR EXISTS (
            SELECT 1 FROM bookings b
            WHERE b.trip_id = t.id
              AND b.rider_id = auth.uid()
              AND b.status   = 'confirmed'
        )
      )
  )
);

CREATE POLICY "reviews: reviewer inserts"
ON reviews
FOR INSERT
WITH CHECK ( reviewer_id = auth.uid() );

/* ============================================================
   PUSH_TOKENS  (Expo / FCM)
============================================================ */
CREATE POLICY "push_tokens: owner CRUD"
ON push_tokens
FOR SELECT, INSERT, UPDATE, DELETE
USING  ( auth.uid() = user_id )
WITH CHECK ( auth.uid() = user_id );
