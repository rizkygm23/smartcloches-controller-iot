const { createClient } = require("@supabase/supabase-js");
require("dotenv").config();

// ── Config ──
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
const BLYNK_TOKEN = process.env.BLYNK_TOKEN;
const BLYNK_BASE = "https://blynk.cloud/external/api";
const CHECK_INTERVAL_MS = 10_000; // 10 detik
const RADIUS_KM = 1.0;

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// In-memory state: track last servo action per user to avoid spamming Blynk
// key = username, value = 'open' | 'closed' | null
const lastAction = {};

// ── Blynk API ──

async function setServo(value) {
  // value: 0 = tutup, 1 = buka
  try {
    const res = await fetch(`${BLYNK_BASE}/update?token=${BLYNK_TOKEN}&V4=${value}`);
    return res.ok;
  } catch (e) {
    console.error(`  [BLYNK ERROR] ${e.message}`);
    return false;
  }
}

async function getRainStatus() {
  try {
    const res = await fetch(`${BLYNK_BASE}/get?token=${BLYNK_TOKEN}&V8`);
    if (!res.ok) return null;
    const data = await res.json();
    return Array.isArray(data) ? parseInt(data[0]) : null;
  } catch {
    return null;
  }
}

// ── Main Loop ──

async function checkAllUsers() {
  // 1. Get all users that have location AND blynk_token
  const { data: users, error } = await supabase
    .from("rain_users")
    .select("*")
    .not("latitude", "is", null)
    .not("longitude", "is", null);

  if (error) {
    console.error("[DB ERROR]", error.message);
    return;
  }

  if (!users || users.length === 0) {
    console.log("[INFO] Tidak ada user dengan lokasi. Menunggu...");
    return;
  }

  console.log(`\n[CHECK] ${new Date().toLocaleTimeString("id-ID")} — ${users.length} user aktif`);

  for (const user of users) {
    const { username, latitude, longitude } = user;

    // 2. Baca rain status dari sensor ESP32 via Blynk
    const sensorRain = await getRainStatus();
    const isOwnRaining = sensorRain === 1;

    // Update own rain status ke Supabase
    if (sensorRain !== null) {
      await supabase
        .from("rain_users")
        .update({
          is_raining: isOwnRaining,
          updated_at: new Date().toISOString(),
        })
        .eq("username", username);
    }

    // 3. Query nearby raining users (exclude self)
    const { data: nearby, error: nearbyErr } = await supabase.rpc(
      "nearby_users",
      {
        user_lat: latitude,
        user_lng: longitude,
        radius_km: RADIUS_KM,
        exclude_username: username,
      }
    );

    if (nearbyErr) {
      console.error(`  [${username}] nearby query error:`, nearbyErr.message);
      continue;
    }

    const nearbyRaining = (nearby || []).filter((u) => u.is_raining);
    const hasNearbyRain = nearbyRaining.length > 0;

    // 4. Decision logic (sama seperti mobile app)
    const prev = lastAction[username] || null;

    if (isOwnRaining || hasNearbyRain) {
      // Harus tutup
      if (prev !== "closed") {
        const reason = isOwnRaining
          ? "sensor hujan"
          : `${nearbyRaining.length} tetangga hujan (${nearbyRaining.map((u) => u.username).join(", ")})`;
        console.log(`  [${username}] TUTUP ATAP — ${reason}`);
        const ok = await setServo(0);
        if (ok) lastAction[username] = "closed";
      }
    } else {
      // Semua cerah: own sensor dry + no nearby rain
      if (prev === "closed") {
        console.log(`  [${username}] BUKA ATAP — semua cerah (lokal + ${(nearby || []).length} tetangga)`);
        const ok = await setServo(1);
        if (ok) lastAction[username] = "open";
      }
    }
  }
}

// ── Start ──

async function main() {
  console.log("========================================");
  console.log(" Smart Clothesline — Rain Warning Server");
  console.log("========================================");
  console.log(`Interval  : ${CHECK_INTERVAL_MS / 1000}s`);
  console.log(`Radius    : ${RADIUS_KM} km`);
  console.log(`Blynk API : ${BLYNK_BASE}`);
  console.log(`Supabase  : ${SUPABASE_URL}`);
  console.log("----------------------------------------\n");

  // Initial check
  await checkAllUsers();

  // Infinite loop
  setInterval(checkAllUsers, CHECK_INTERVAL_MS);
}

main().catch(console.error);
