# Fitur Maps - Dokumentasi

## 📍 Fitur Baru: Lihat Lokasi User di Peta

### Perubahan yang Dilakukan

#### 1. **Halaman Demo (`/demo`)** - UPDATED ✅
- Menambahkan button **"📍 Lokasi"** di kolom Aksi untuk setiap user yang memiliki koordinat GPS
- Button hanya muncul jika user memiliki `latitude` dan `longitude` yang valid
- Klik button akan redirect ke `/maps` dengan parameter:
  - `lat` - Latitude user
  - `lng` - Longitude user  
  - `username` - Nama user (untuk display)

**Contoh URL:**
```
/maps?lat=-6.200000&lng=106.816666&username=tetangga_adi
```

#### 2. **Halaman Maps (`/maps`)** - NEW ✅
File: `src/app/maps/page.tsx`

**Fitur:**
- ✅ Menampilkan peta interaktif menggunakan **OpenStreetMap** (tidak perlu API key)
- ✅ Marker otomatis di lokasi user
- ✅ Info cards menampilkan Latitude & Longitude
- ✅ 3 tombol aksi:
  - 🗺️ **Buka di Google Maps** - Membuka Google Maps di tab baru
  - 🌍 **Buka di OpenStreetMap** - Membuka OSM di tab baru
  - 📋 **Salin Koordinat** - Copy koordinat ke clipboard
- ✅ Button "Kembali" ke halaman demo
- ✅ Info card dengan penjelasan fitur

**Design:**
- Menggunakan styling yang sama dengan halaman lain (glassmorphism dark theme)
- Responsive layout
- Smooth animations

---

## 🧪 Cara Testing

### 1. Jalankan Development Server
```bash
npm run dev
```

### 2. Buka Halaman Demo
```
http://localhost:3000/demo
```

### 3. Test Fitur Maps
1. Pastikan ada user dengan lokasi GPS (bisa generate dummy users)
2. Klik button **"📍 Lokasi"** di kolom Aksi
3. Halaman `/maps` akan terbuka dengan peta lokasi user
4. Test semua button:
   - Klik "Buka di Google Maps" → harus membuka Google Maps
   - Klik "Buka di OpenStreetMap" → harus membuka OSM
   - Klik "Salin Koordinat" → harus muncul alert dan koordinat tersalin
   - Klik "Kembali" → kembali ke halaman demo

### 4. Test Edge Cases
- User tanpa lokasi GPS → button "📍 Lokasi" tidak muncul ✅
- Akses `/maps` tanpa parameter → muncul error message + button kembali ✅
- Koordinat invalid → handled by OpenStreetMap

---

## 🗺️ Tentang OpenStreetMap

**Kenapa pakai OpenStreetMap?**
- ✅ **Gratis** - Tidak perlu API key
- ✅ **Open Source** - Bebas digunakan
- ✅ **Reliable** - Data peta dari komunitas global
- ✅ **Privacy** - Tidak tracking user seperti Google Maps

**Alternatif Google Maps:**
Jika ingin pakai Google Maps embed:
1. Dapatkan API key dari [Google Cloud Console](https://console.cloud.google.com/)
2. Enable "Maps Embed API"
3. Tambahkan ke `.env.local`:
   ```
   NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_api_key_here
   ```
4. Uncomment bagian Google Maps di `maps/page.tsx`

---

## 📱 Screenshot Flow

```
┌─────────────────────────────────────┐
│  /demo - Rain Network Demo          │
│                                      │
│  [Table with users]                  │
│  Username | Lat | Lng | Aksi        │
│  ─────────────────────────────────  │
│  bu_sari  | ... | ... | [📍 Lokasi] │  ← Klik ini
│                          [Hapus]     │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│  /maps?lat=...&lng=...&username=... │
│                                      │
│  [Header: Lokasi User - bu_sari]    │
│  [Lat Card] [Lng Card]               │
│  [OpenStreetMap Embed with Marker]  │
│  [🗺️ Google] [🌍 OSM] [📋 Copy]    │
│  [Info Card]                         │
└─────────────────────────────────────┘
```

---

## 🔧 Technical Details

### URL Parameters
- `lat` (required) - Latitude dalam format decimal degrees
- `lng` (required) - Longitude dalam format decimal degrees
- `username` (optional) - Nama user untuk display

### OpenStreetMap Embed URL Format
```
https://www.openstreetmap.org/export/embed.html?
  bbox={lng-0.01},{lat-0.01},{lng+0.01},{lat+0.01}
  &layer=mapnik
  &marker={lat},{lng}
```

### External Links
- Google Maps: `https://www.google.com/maps?q={lat},{lng}`
- OpenStreetMap: `https://www.openstreetmap.org/?mlat={lat}&mlon={lng}&zoom=15`

---

## ✅ Checklist

- [x] Button "Lokasi" di halaman demo
- [x] Conditional rendering (hanya jika ada GPS)
- [x] Halaman `/maps` dengan OpenStreetMap embed
- [x] Display latitude & longitude
- [x] Button "Buka di Google Maps"
- [x] Button "Buka di OpenStreetMap"
- [x] Button "Salin Koordinat"
- [x] Button "Kembali" ke demo
- [x] Error handling untuk koordinat invalid
- [x] Responsive design
- [x] Consistent styling dengan halaman lain
- [x] No TypeScript errors
- [x] Suspense boundary untuk loading state

---

## 🚀 Next Steps (Optional Enhancements)

1. **Multiple Markers** - Tampilkan semua user di satu peta
2. **Radius Circle** - Tampilkan circle 1km radius untuk distributed warning
3. **Real-time Updates** - Auto-refresh marker saat status hujan berubah
4. **Clustering** - Group markers yang berdekatan
5. **Custom Marker Icons** - Icon berbeda untuk hujan vs cerah
6. **Route Planning** - Hitung rute antar user
7. **Weather Overlay** - Tampilkan layer cuaca di peta

---

*Feature completed on 2026-05-10*
