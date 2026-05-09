# SmartCloches — Logo Aplikasi

---

## Logo Utama

![SmartCloches Logo](c:/Users/HP/codingan/smartcloches-controller-iot/logo_iot.png)

---

## Spesifikasi Desain

| Aspek | Detail |
|:---|:---|
| **Gaya** | Modern, Flat Design |
| **Bentuk** | Ikon persegi, cocok untuk app launcher |
| **Elemen Utama** | Rumah/atap jemuran + sinyal WiFi + elemen cuaca (matahari & hujan) + pakaian |
| **Konsep** | Jemuran otomatis berbasis IoT — atap pintar yang menutup saat hujan dan membuka saat cerah |

---

## Color Palette

| Warna | Hex | Penggunaan |
|:---|:---|:---|
| `#2563EB` | Primary Blue | Struktur rumah, sinyal WiFi |
| `#06B6D4` | Cyan | Elemen cuaca, awan hujan |
| `#FFFFFF` | White | Background |

---

## Panduan Penggunaan

### Ukuran Minimum
- **App Icon Android:** 192x192 px (xxxhdpi)
- **Adaptive Icon:** 108x108 dp (safe zone 66x66 dp)
- **Splash Screen:** 288x288 px
- **Favicon:** 32x32 px

### Safe Zone
Padding minimal **15%** dari setiap sisi saat digunakan sebagai app icon agar tidak terpotong pada berbagai bentuk launcher.

---

## File Assets

```
logo_iot.png                                    <- Logo source (root)
smartcloches-mobile/assets/images/logo.png      <- Copy untuk Flutter app
```

### Implementasi di Flutter

```dart
Image.asset(
  'assets/images/logo.png',
  width: 120,
  height: 120,
)
```

---

*Terakhir diperbarui: Mei 2026*
