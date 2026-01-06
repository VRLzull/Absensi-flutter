class ApiConfig {
  // Konfigurasi URL API server Express.js
  // Untuk Android emulator, gunakan 10.0.2.2 untuk mengakses host machine
  // static const String baseUrl = 'http://10.0.2.2:5000/api/face-recognition';
  
  // Untuk device fisik, gunakan IP LAN PC Anda
  static const String baseUrl = 'http://192.168.1.60:5000/api/face-recognition';
  
  // Timeout untuk HTTP requests (dalam detik) - tingkatkan untuk face detection
  static const int timeoutSeconds = 60;
  
  // Headers default untuk semua request
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
