# Integrasi FaceNet TFLite dengan Flutter

## 🎯 Arsitektur Sistem

```
Flutter App (Kamera + FaceNet TFLite)
    ↓ kirim JSON embedding (array angka)
Express.js (API utama)
    ↓ panggil Python service
Python (face_recognition / OpenCV)
    ↓ bandingkan embedding dgn data wajah di DB
Express.js → kirim hasil ke Flutter
```

## 📁 Struktur File yang Dibuat

### 1. Konfigurasi API
- `lib/config/api_config.dart` - Konfigurasi URL server dan timeout

### 2. Services
- `lib/services/facenet_service.dart` - Service FaceNet TFLite untuk ekstraksi embedding
- `lib/services/camera_service.dart` - Service kamera untuk capture foto
- `lib/services/face_recognition_service.dart` - Legacy compatibility

### 3. Widgets
- `lib/widgets/face_recognition_widget.dart` - Widget utama untuk face recognition

### 4. Screens
- `lib/screens/face_recognition_screen.dart` - Screen wrapper dengan dialog hasil

### 5. Assets
- `assets/models/facenet.tflite` - Model FaceNet TFLite

## 🚀 Cara Menggunakan

### 1. Jalankan Server Express.js
```bash
cd C:\laragon\www\Absensi-App
node server.js
```

### 2. Jalankan Flutter App
```bash
cd C:\laragon\www\absen_flutter
flutter run
```

### 3. Fitur yang Tersedia

#### A. Cari Karyawan dengan Wajah
- Klik tombol "Cari Karyawan dengan Wajah"
- Ambil foto wajah
- Sistem akan mencari di database dan menampilkan hasil

#### B. Daftarkan Wajah Karyawan
- Klik tombol "Daftarkan Wajah Karyawan"
- Masukkan kode karyawan (contoh: EMP001)
- Ambil foto wajah
- Sistem akan menyimpan embedding ke database

## 🔧 Konfigurasi

### 1. URL Server
Edit `lib/config/api_config.dart`:
```dart
// Untuk Android emulator
static const String baseUrl = 'http://10.0.2.2:5000/api/face-recognition';

// Untuk device fisik, ganti dengan IP LAN PC Anda
// static const String baseUrl = 'http://192.168.1.100:5000/api/face-recognition';
```

### 2. Model FaceNet
- Model sudah tersedia di `assets/models/facenet.tflite`
- Jika ingin menggunakan model lain, ganti file tersebut
- Pastikan ukuran embedding sesuai (default: 512 dimensi)

## 📱 API Endpoints

### 1. Verifikasi Wajah
```
POST /api/face-recognition/flutter-verify-embedding
{
  "employee_id": "EMP001",
  "face_embedding": [0.1, 0.2, 0.3, ...]
}
```

### 2. Cari Karyawan
```
POST /api/face-recognition/flutter-find-employee-embedding
{
  "face_embedding": [0.1, 0.2, 0.3, ...]
}
```

### 3. Daftarkan Wajah
```
POST /api/face-recognition/flutter-register-embedding
{
  "employee_id": "EMP001",
  "face_embedding": [0.1, 0.2, 0.3, ...]
}
```

## 🐛 Troubleshooting

### 1. Model Tidak Load
- Pastikan file `facenet.tflite` ada di `assets/models/`
- Check pubspec.yaml sudah include assets
- Restart aplikasi setelah menambah assets

### 2. Kamera Tidak Bekerja
- Pastikan permission kamera sudah diberikan
- Check AndroidManifest.xml sudah ada permission
- Restart aplikasi setelah install

### 3. Server Connection Error
- Pastikan server Express.js berjalan di port 5000
- Check URL di `api_config.dart` sesuai dengan setup
- Pastikan firewall tidak memblokir koneksi

### 4. Face Recognition Tidak Akurat
- Pastikan pencahayaan cukup
- Posisikan wajah di tengah frame
- Jaga jarak yang tepat dari kamera
- Pastikan wajah menghadap kamera

## 📊 Performance Tips

### 1. Optimasi Model
- Gunakan model yang sudah dioptimasi untuk mobile
- Consider quantization untuk mengurangi ukuran
- Cache model interpreter untuk performa lebih baik

### 2. Image Processing
- Resize image sebelum inference
- Normalize pixel values dengan benar
- Gunakan format JPEG untuk kompresi

### 3. Network
- Implement timeout yang sesuai
- Handle network errors dengan baik
- Cache hasil jika memungkinkan

## 🔒 Security Considerations

### 1. Data Privacy
- Jangan simpan gambar di device
- Hanya kirim embedding ke server
- Implement proper authentication

### 2. Network Security
- Gunakan HTTPS untuk production
- Implement certificate pinning
- Validate input dari server

## 📈 Monitoring & Logging

### 1. Debug Logs
- Check console untuk error messages
- Monitor network requests
- Track model loading time

### 2. Performance Metrics
- Monitor inference time
- Track accuracy rate
- Measure network latency

## 🎯 Next Steps

1. **Testing dengan Real Data**
   - Test dengan wajah asli
   - Register beberapa karyawan
   - Optimize threshold untuk akurasi terbaik

2. **UI/UX Improvements**
   - Tambahkan loading indicators
   - Improve error handling
   - Add success animations

3. **Performance Optimization**
   - Implement caching
   - Optimize model size
   - Reduce inference time

4. **Production Deployment**
   - Setup HTTPS
   - Implement proper authentication
   - Add monitoring dan logging

## 📞 Support

Jika mengalami masalah:
1. Check console logs untuk error messages
2. Pastikan semua dependencies terinstall
3. Verify server dan database berjalan dengan baik
4. Test dengan data sample terlebih dahulu

---

**Selamat menggunakan sistem Face Recognition dengan FaceNet TFLite! 🎉**
