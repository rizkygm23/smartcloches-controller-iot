-- ============================================
-- SmartClothesline - Distributed Rain Warning
-- Jalankan di Supabase SQL Editor
-- ============================================

-- Tabel utama: rain_users
CREATE TABLE IF NOT EXISTS rain_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_raining BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS: izinkan semua operasi (demo/prototype)
ALTER TABLE rain_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all_select" ON rain_users FOR SELECT USING (true);
CREATE POLICY "allow_all_insert" ON rain_users FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_all_update" ON rain_users FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_delete" ON rain_users FOR DELETE USING (true);

-- Fungsi: cari user dalam radius tertentu (Haversine formula)
CREATE OR REPLACE FUNCTION nearby_users(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_km DOUBLE PRECISION DEFAULT 1.0,
  exclude_username TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  username TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_raining BOOLEAN,
  distance_km DOUBLE PRECISION,
  updated_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.username,
    r.latitude,
    r.longitude,
    r.is_raining,
    (6371.0 * acos(
      LEAST(1.0,
        cos(radians(user_lat)) * cos(radians(r.latitude)) *
        cos(radians(r.longitude) - radians(user_lng)) +
        sin(radians(user_lat)) * sin(radians(r.latitude))
      )
    )) AS distance_km,
    r.updated_at
  FROM rain_users r
  WHERE r.latitude IS NOT NULL
    AND r.longitude IS NOT NULL
    AND (exclude_username IS NULL OR r.username != exclude_username)
    AND (6371.0 * acos(
      LEAST(1.0,
        cos(radians(user_lat)) * cos(radians(r.latitude)) *
        cos(radians(r.longitude) - radians(user_lng)) +
        sin(radians(user_lat)) * sin(radians(r.latitude))
      )
    )) <= radius_km;
END;
$$ LANGUAGE plpgsql;
