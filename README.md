# Sistem Absensi dengan Face Recognition

Aplikasi Flutter untuk sistem absensi yang menggunakan teknologi face recognition untuk verifikasi identitas pegawai.

## Fitur Utama

- **Face Recognition**: Verifikasi wajah menggunakan Google ML Kit
- **Check-in/Check-out**: Sistem absensi masuk dan pulang
- **Real-time Camera**: Kamera real-time dengan deteksi wajah
- **Employee Management**: Manajemen data pegawai
- **Attendance History**: Riwayat absensi
- **Location Tracking**: Pencatatan lokasi absensi
- **Modern UI**: Interface yang modern dan responsif

## Teknologi yang Digunakan

- **Frontend**: Flutter 3.9+
- **Backend**: Node.js + Express.js
- **Database**: MySQL
- **Face Recognition**: Google ML Kit
- **Camera**: Flutter Camera Plugin
- **State Management**: Provider Pattern
- **HTTP Client**: http package

## Struktur Aplikasi

```
lib/
├── models/           # Data models
├── services/         # API services dan face recognition
├── providers/        # State management
├── screens/          # UI screens
├── widgets/          # Reusable widgets
└── utils/            # Utility functions
```

## Cara Menjalankan

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Setup Backend

Pastikan backend server sudah berjalan di `http://localhost:5000`

```bash
cd ../Absensi-App
npm install
npm run dev
```

### 3. Run Flutter App

```bash
flutter run
```

## Konfigurasi

### Backend URL

Edit file `lib/services/api_service.dart` untuk mengubah URL backend:

```dart
static const String baseUrl = 'http://localhost:5000/api';
```

### Permissions

Aplikasi memerlukan permission berikut:

- **Camera**: Untuk face recognition
- **Location**: Untuk mencatat lokasi absensi
- **Internet**: Untuk komunikasi dengan backend
- **Storage**: Untuk menyimpan gambar sementara

## Alur Kerja Aplikasi

**Aplikasi ini dipasang di satu device sebagai alat absen umum untuk semua karyawan.**

### 1. Check-in
1. Karyawan memilih tombol "Absen Masuk"
2. Langsung buka kamera untuk face recognition
3. Deteksi dan verifikasi wajah
4. Backend mencari data karyawan berdasarkan wajah
5. Jika wajah dikenali, absen masuk berhasil
6. Jika wajah tidak dikenali, minta daftar terlebih dahulu

### 2. Check-out
1. Karyawan memilih tombol "Absen Pulang"
2. Langsung buka kamera untuk face recognition
3. Verifikasi wajah
4. Backend mencari data karyawan berdasarkan wajah
5. Jika wajah dikenali, absen pulang berhasil
6. Jika wajah tidak dikenali, minta daftar terlebih dahulu

## API Endpoints

### Face Recognition
- `POST /api/face-recognition/flutter-verify` - Verifikasi wajah
- `POST /api/face-recognition/find-employee` - Cari karyawan berdasarkan wajah

### Attendance
- `POST /api/attendance/check-in` - Check-in
- `POST /api/attendance/check-out` - Check-out
- `GET /api/attendance` - Riwayat absensi

### Employees
- `GET /api/employees/:id` - Data pegawai

## Database Schema

### Tabel Utama
- `employees` - Data pegawai
- `employee_faces` - Data wajah pegawai
- `attendance` - Data absensi
- `admin_users` - Data admin

## Troubleshooting

### Common Issues

1. **Camera not working**
   - Pastikan permission kamera sudah diberikan
   - Restart aplikasi setelah memberikan permission

2. **Face detection failed**
   - Pastikan pencahayaan cukup
   - Wajah harus terlihat jelas di kamera

3. **Backend connection error**
   - Pastikan backend server berjalan
   - Cek URL backend di `api_service.dart`

### Debug Mode

Untuk debugging, gunakan:

```bash
flutter run --debug
```

## Contributing

1. Fork repository
2. Buat feature branch
3. Commit changes
4. Push ke branch
5. Buat Pull Request

## License

MIT License - lihat file LICENSE untuk detail

## Support

Untuk pertanyaan atau dukungan, silakan buat issue di repository ini.

## Changelog

### v1.0.0
- Initial release
- Face recognition system
- Check-in/check-out functionality
- Employee management
- Modern UI design
