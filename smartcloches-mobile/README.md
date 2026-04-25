# Smart Cloches Mobile App 📱

Aplikasi Flutter Android untuk mengontrol Smart Cloches IoT Servo Motor via Blynk Cloud API.

## Fitur
- 🔄 Toggle Switch untuk ON/OFF servo (V4)
- ⚡ Speed slider dengan visualisasi Step 1-10 (V5)
- 📡 Real-time status monitoring (polling setiap 5 detik)
- 📳 Haptic feedback saat interaksi
- 🎨 Dark theme premium (glassmorphism design)

## Prasyarat

1. **Install Flutter SDK**
   ```
   https://docs.flutter.dev/get-started/install/windows/mobile
   ```

2. **Install Android Studio** (untuk Android SDK & emulator)
   ```
   https://developer.android.com/studio
   ```

3. **Verifikasi instalasi**
   ```bash
   flutter doctor
   ```

## Setup & Run

```bash
# 1. Masuk ke folder project
cd smartcloches-mobile

# 2. Buat project Flutter (generate file Android native)
flutter create --project-name smartcloches_mobile --org com.smartcloches .

# 3. Install dependencies
flutter pub get

# 4. Jalankan di emulator atau HP Android (USB Debugging ON)
flutter run
```

## Build APK

```bash
# Build APK release
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Struktur Project

```
smartcloches-mobile/
├── lib/
│   ├── main.dart              # Entry point
│   ├── screens/
│   │   └── home_page.dart     # Halaman utama
│   ├── services/
│   │   └── blynk_service.dart # Komunikasi API Blynk
│   ├── theme/
│   │   └── app_theme.dart     # Tema & warna
│   └── widgets/
│       ├── glass_card.dart    # Card glassmorphism
│       ├── servo_toggle.dart  # Toggle switch servo
│       └── speed_control.dart # Slider kecepatan
├── android/                   # Konfigurasi Android native
├── pubspec.yaml               # Dependencies
└── README.md
```

## API Blynk yang Digunakan

| Fungsi          | Endpoint                                         |
|-----------------|--------------------------------------------------|
| Nyalain Servo   | `GET /update?token=TOKEN&V4=1`                  |
| Matiin Servo    | `GET /update?token=TOKEN&V4=0`                  |
| Atur Speed      | `GET /update?token=TOKEN&V5={0-100}`            |
| Cek Status      | `GET /get?token=TOKEN&V4`                       |
