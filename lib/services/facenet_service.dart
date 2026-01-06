import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';

class FaceNetService {
  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _modelAvailable = false;

  // Konfigurasi model FaceNet - sesuai dengan web app (face-api.js)
  static const int embeddingSize = 128; // Standar FaceNet descriptor size
  static const int inputSize = 160; // Standard FaceNet input size
  static const String modelPath = 'assets/models/facenet.tflite';

  /// Inisialisasi model FaceNet TFLite
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🔄 Loading FaceNet model...');
      
      // Untuk sekarang, skip cek file karena asset loading berbeda
      print('📁 Loading model from assets: $modelPath');
      
      // Coba load model dengan error handling yang lebih detail
      try {
        _interpreter = await Interpreter.fromAsset(modelPath);
        
        // Validasi model dengan cek input/output shapes
        var inputTensors = _interpreter?.getInputTensors();
        var outputTensors = _interpreter?.getOutputTensors();
        
        print('📊 Model loaded - Input tensors: ${inputTensors?.length}, Output tensors: ${outputTensors?.length}');
        
        _isInitialized = true;
        _modelAvailable = true;
        print('✅ FaceNet model loaded successfully');
      } catch (modelError) {
        print('❌ Model loading error: $modelError');
        // Fallback: lanjut tanpa model, akan menggunakan server-side processing
        _isInitialized = true;
        _modelAvailable = false;
        print('⚠️ Continuing without local model, will use server processing');
      }
    } catch (e) {
      print('❌ Error loading FaceNet model: $e');
      throw Exception('Gagal memuat model FaceNet: $e');
    }
  }

  /// Ekstrak face embedding dari gambar
  Future<List<double>> extractFaceEmbedding(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Jika model tidak tersedia, return dummy embedding untuk testing
    if (!_modelAvailable || _interpreter == null) {
      print('⚠️ Model not available, returning dummy embedding');
      // Return consistent dummy embedding untuk testing
      // Nilai ini akan selalu sama untuk testing consistency
      return List.generate(embeddingSize, (index) {
        // Generate consistent values based on index untuk testing
        return math.sin(index * 0.1) * 0.5;
      });
    }

    try {
      // Baca dan decode gambar
      final bytes = await File(imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw Exception('Gagal decode gambar');
      }

      // Resize gambar ke ukuran input model (160x160)
      final resized = img.copyResize(
        decoded,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.cubic,
      );

      // Preprocess gambar untuk FaceNet
      final input = _preprocessImage(resized);

      // Siapkan output tensor
      final output = List.filled(embeddingSize, 0.0).reshape([1, embeddingSize]);

      // Jalankan inference
      _interpreter!.run(input, output);

      // Ambil embedding dan normalisasi
      final rawEmbedding = List<double>.from(output[0].map((e) => (e as num).toDouble()));

      return _l2Normalize(rawEmbedding);
    } catch (e) {
      print('❌ Error extracting face embedding: $e');
      // Fallback: kembalikan vektor nol agar aplikasi tetap berjalan
      return List<double>.filled(embeddingSize, 0.0);
    }
  }

  /// Preprocess gambar untuk FaceNet: hasil [1, H, W, 3]
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final hwc = List<List<List<double>>>.generate(
      inputSize,
      (_) => List<List<double>>.generate(
        inputSize,
        (_) => List<double>.filled(3, 0.0),
      ),
    );

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        // Gunakan API image v4 untuk akses channel warna
        final r = (pixel.r / 127.5) - 1.0;
        final g = (pixel.g / 127.5) - 1.0;
        final b = (pixel.b / 127.5) - 1.0;
        hwc[y][x][0] = r;
        hwc[y][x][1] = g;
        hwc[y][x][2] = b;
      }
    }

    return [hwc];
  }

  /// L2 Normalization untuk embedding
  List<double> _l2Normalize(List<double> vector) {
    double norm = 0.0;
    for (final value in vector) {
      norm += value * value;
    }
    norm = math.sqrt(norm);
    
    if (norm == 0) return vector;
    
    return vector.map((value) => value / norm).toList();
  }

  /// Verifikasi wajah dengan server
  Future<Map<String, dynamic>> verifyFace(String employeeCode, List<double> embedding) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/flutter-verify-embedding'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'employee_id': employeeCode,
          'face_embedding': embedding,
        }),
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error verifying face: $e');
      throw Exception('Gagal verifikasi wajah: $e');
    }
  }

  /// Cari karyawan berdasarkan wajah
  Future<Map<String, dynamic>> findEmployeeByFace(List<double> embedding) async {
    try {
      // Jika model tidak tersedia, kirim pesan error yang lebih informatif
      if (!_modelAvailable) {
        return {
          'success': false,
          'message': 'Model tidak tersedia. Silakan hubungi administrator untuk mengatur model FaceNet.',
          'verified': false
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/flutter-find-employee-embedding'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'face_embedding': embedding,
        }),
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error finding employee: $e');
      throw Exception('Gagal mencari karyawan: $e');
    }
  }

  /// Daftarkan wajah karyawan
  Future<Map<String, dynamic>> registerFace(String employeeCode, List<double> embedding) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/flutter-register-embedding'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'employee_id': employeeCode,
          'face_embedding': embedding,
        }),
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error registering face: $e');
      throw Exception('Gagal mendaftarkan wajah: $e');
    }
  }

  /// Cek status koneksi ke server
  Future<bool> checkServerConnection() async {
    try {
      print('🔗 Checking server connection to: ${ApiConfig.baseUrl}/status');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/status'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      print('📡 Server response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server connection error to ${ApiConfig.baseUrl}/status: $e');
      return false;
    }
  }

  /// Cari karyawan menggunakan upload gambar langsung (fallback)
  Future<Map<String, dynamic>> findEmployeeByImage(String imagePath) async {
    try {
      // Cek file yang akan di-upload
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('File gambar tidak ditemukan: $imagePath');
      }

      final fileSize = await file.length();
      print('📎 Uploading file: $imagePath');
      print('📎 File size: $fileSize bytes');
      print('📎 File extension: ${imagePath.split('.').last}');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/find-employee')
      );
      
      // Remove Content-Type header to let multipart handle it properly
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      
      // Buat multipart file dengan MIME type yang eksplisit
      final multipartFile = await http.MultipartFile.fromPath(
        'face_image', 
        imagePath,
        filename: 'face_image.jpg',
        contentType: MediaType('image', 'jpeg') // Explicit MIME type
      );
      request.files.add(multipartFile);

      print('📤 Sending request to: ${ApiConfig.baseUrl}/find-employee');
      final streamedResponse = await request.send().timeout(
        Duration(seconds: ApiConfig.timeoutSeconds),
        onTimeout: () {
          throw Exception('Request timeout after ${ApiConfig.timeoutSeconds} seconds');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Server response: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Server returned error: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error finding employee by image: $e');
      throw Exception('Gagal mencari karyawan: $e');
    }
  }

  /// Kirim foto untuk otomatis check-in
  Future<Map<String, dynamic>> checkInWithImage(String imagePath, {String? location, String? notes}) async {
    return _submitAttendanceWithImage(
      imagePath,
      endpoint: '${ApiConfig.baseUrl.replaceAll('/api/face-recognition', '/api/attendance')}/check-in',
      location: location,
      notes: notes,
    );
  }

  /// Kirim foto untuk otomatis check-out
  Future<Map<String, dynamic>> checkOutWithImage(String imagePath, {String? location, String? notes}) async {
    return _submitAttendanceWithImage(
      imagePath,
      endpoint: '${ApiConfig.baseUrl.replaceAll('/api/face-recognition', '/api/attendance')}/check-out',
      location: location,
      notes: notes,
    );
  }

  Future<Map<String, dynamic>> _submitAttendanceWithImage(
    String imagePath, {
    required String endpoint,
    String? location,
    String? notes,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('File gambar tidak ditemukan: $imagePath');
      }

      final request = http.MultipartRequest('POST', Uri.parse(endpoint));

      final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      final multipartFile = await http.MultipartFile.fromPath(
        'face_image',
        imagePath,
        filename: 'face_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      if (location != null) request.fields['location'] = location;
      if (notes != null) request.fields['notes'] = notes;

      final streamed = await request.send().timeout(
        Duration(seconds: ApiConfig.timeoutSeconds),
        onTimeout: () => throw Exception('Request timeout after ${ApiConfig.timeoutSeconds} seconds'),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Server error: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ Error submitting attendance: $e');
      rethrow;
    }
  }

  /// Getter untuk cek apakah model tersedia
  bool get modelAvailable => _modelAvailable;

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}
