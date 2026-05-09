-- =============================================
-- JALANKAN INI DI SUPABASE SQL EDITOR
-- Tambah kolom blynk_token ke rain_users
-- =============================================

ALTER TABLE rain_users
ADD COLUMN IF NOT EXISTS blynk_token TEXT DEFAULT NULL;
