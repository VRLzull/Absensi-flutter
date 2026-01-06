# Alur Aplikasi Absensi Flutter - Sesuai Flowchart

## Overview
Aplikasi Flutter ini mengimplementasikan sistem absensi dengan face recognition sesuai flowchart yang telah dibuat. Aplikasi ini berfungsi sebagai client yang terhubung ke backend PHP di `C:\laragon\www\Absensi-App`.

## Alur Lengkap Aplikasi (Dari Sisi Pegawai)

### 1. Pegawai Buka App Flutter
- **Lokasi**: `lib/screens/home_screen.dart`
- **Fitur**: 
  - Tampilan utama dengan waktu dan tanggal real-time
  - Tombol Check-in (Absen Masuk) dan Check-out (Absen Pulang)
  - Informasi pegawai yang sedang login

### 2. Ambil Foto Wajah
- **Lokasi**: `lib/screens/camera_screen.dart`
- **Fitur**:
  - Kamera depan untuk face recognition
  - Real-time face detection dengan Google ML Kit
  - Validasi posisi dan ukuran wajah
  - Overlay visual untuk panduan posisi wajah

### 3. Upload ke Server
- **Lokasi**: `lib/services/api_service.dart`
- **Endpoint**: `POST /api/face-recognition/find-employee`
- **Fitur**:
  - Upload foto wajah ke backend
  - Pengiriman face descriptor
  - Pencarian pegawai berdasarkan wajah

### 4. Face Verification
- **Lokasi**: `lib/services/face_recognition_service.dart`
- **Fitur**:
  - Face detection dan landmark detection
  - Face descriptor generation
  - Quality scoring untuk wajah
  - Validasi posisi wajah

### 5. Database Update
- **Lokasi**: `lib/services/api_service.dart`
- **Endpoint Check-in**: `POST /api/attendance/check-in`
- **Endpoint Check-out**: `POST /api/attendance/check-out`
- **Fitur**:
  - Update status absensi di database
  - Penyimpanan foto wajah
  - Timestamp dan metadata absensi

### 6. Success (Check-in/Check-out)
- **Lokasi**: `lib/widgets/attendance_buttons.dart`
- **Fitur**:
  - Notifikasi sukses
  - Update state aplikasi
  - Feedback visual untuk user

## Fitur Tambahan

### Flow Visualization Screen
- **Lokasi**: `lib/screens/attendance_flow_screen.dart`
- **Fitur**:
  - Tampilan visual semua langkah proses
  - Progress indicator untuk setiap step
  - Status real-time untuk setiap proses
  - Demo mode untuk testing

### State Management
- **Lokasi**: `lib/providers/attendance_provider.dart`
- **Fitur**:
  - Status absensi hari ini
  - Data pegawai yang sedang login
  - State check-in dan check-out

## Struktur File Utama

```
lib/
├── main.dart                          # Entry point aplikasi
├── screens/
│   ├── home_screen.dart              # Screen utama
│   ├── camera_screen.dart            # Screen kamera untuk absen
│   └── attendance_flow_screen.dart   # Screen flow lengkap
├── services/
│   ├── api_service.dart              # Service untuk API calls
│   └── face_recognition_service.dart # Service face recognition
├── providers/
│   └── attendance_provider.dart      # State management
└── widgets/
    ├── attendance_buttons.dart       # Tombol check-in/out
    ├── time_date_card.dart           # Card waktu dan tanggal
    └── employee_info_card.dart       # Card info pegawai
```

## Konfigurasi Backend

### Base URL
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost/Absensi-App/api';
```

### Endpoint yang Digunakan
1. **Find Employee by Face**: `POST /api/face-recognition/find-employee`
2. **Face Verification**: `POST /api/face-recognition/verify`
3. **Check-in**: `POST /api/attendance/check-in`
4. **Check-out**: `POST /api/attendance/check-out`
5. **Employee Info**: `GET /api/employees/{id}`
6. **Attendance History**: `GET /api/attendance`

## Cara Penggunaan

### 1. Check-in
1. Buka aplikasi Flutter
2. Klik tombol "Absen Masuk" (hijau)
3. Pilih "Flow Lengkap" atau "Kamera Langsung"
4. Jika pilih Flow Lengkap: lihat semua langkah proses
5. Jika pilih Kamera Langsung: langsung ke kamera
6. Posisikan wajah di dalam kotak
7. Klik tombol kamera untuk mengambil foto
8. Tunggu proses verifikasi dan update database
9. Lihat notifikasi sukses

### 2. Check-out
1. Pastikan sudah check-in hari ini
2. Klik tombol "Absen Pulang" (merah)
3. Ikuti langkah yang sama seperti check-in

## Dependencies

### Flutter Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+5
  google_mlkit_face_detection: ^0.9.0
  provider: ^6.1.1
  http: ^1.1.0
  image: ^4.1.3
```

### Android Permissions
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Testing

### Demo Mode
- Gunakan "Flow Lengkap" untuk melihat semua langkah
- Setiap langkah akan di-simulate dengan delay 2 detik
- Data dummy akan digunakan untuk testing

### Real Mode
- Gunakan "Kamera Langsung" untuk testing dengan kamera asli
- Pastikan backend sudah running di `localhost/Absensi-App`
- Pastikan ada data pegawai dengan foto wajah di database

## Troubleshooting

### Kamera Tidak Bekerja
1. Pastikan permission kamera sudah diberikan
2. Restart aplikasi setelah memberikan permission
3. Pastikan device memiliki kamera depan

### Koneksi ke Backend Gagal
1. Pastikan backend running di `localhost/Absensi-App`
2. Check URL di `api_service.dart`
3. Pastikan tidak ada firewall yang memblokir

### Face Recognition Tidak Akurat
1. Pastikan pencahayaan cukup
2. Posisikan wajah di tengah dan tidak terlalu jauh
3. Pastikan wajah menghadap kamera dengan lurus

## Pengembangan Selanjutnya

### Fitur yang Bisa Ditambahkan
1. **GPS Location**: Tambahkan lokasi absensi
2. **Offline Mode**: Cache data untuk penggunaan offline
3. **Push Notification**: Notifikasi reminder absensi
4. **Biometric Auth**: Tambahan fingerprint/face ID
5. **Dark Mode**: Tema gelap untuk aplikasi
6. **Multi-language**: Support bahasa Indonesia dan Inggris

### Optimisasi
1. **Performance**: Optimasi face detection untuk device low-end
2. **Memory**: Optimasi penggunaan memory untuk foto
3. **Battery**: Optimasi penggunaan baterai
4. **Network**: Implementasi retry mechanism untuk API calls

## Support

Untuk pertanyaan atau masalah teknis, silakan buat issue di repository ini atau hubungi tim development.
