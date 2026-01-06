import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';
import '../models/attendance.dart';

class ApiService {
  // ⚙️ Ganti dengan alamat backend kamu
  static const String baseUrl = 'http://localhost:5000/api';

  // Default headers
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // =====================================================
  // ✅ Face Verification (endpoint: /face-recognition/flutter-verify)
  // =====================================================
  static Future<Map<String, dynamic>> verifyFaceEmbedding({
    required String employeeId,
    required List<double> embedding, required String mode,
  }) async {
    final uri = Uri.parse('$baseUrl/face-recognition/flutter-verify');

    try {
      final body = jsonEncode({
        'employee_id': employeeId,
        'embedding': embedding, // dikirim sebagai array
      });

      final response = await http
          .post(uri, headers: _headers, body: body)
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Verifikasi berhasil',
          'data': data['data'],
        };
      } else {
        throw Exception(data['error'] ?? data['message'] ?? 'Verifikasi wajah gagal');
      }
    } catch (e) {
      throw Exception('Gagal verifikasi wajah: $e');
    }
  }

  // =====================================================
  // ✅ Check-in (absen masuk)
  // =====================================================
  static Future<Map<String, dynamic>> checkIn({
    required String employeeId,
    required List<double> embedding,
    String? location,
    String? notes,
  }) async {
    final uri = Uri.parse('$baseUrl/attendance/flutter-check-in');

    try {
      final body = jsonEncode({
        'employee_id': employeeId,
        'embedding': embedding,
        'location': location ?? 'Unknown',
        'notes': notes ?? 'Check-in via Flutter App',
      });

      final response = await http.post(uri, headers: _headers, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Check-in berhasil',
          'data': data['data'],
        };
      } else {
        throw Exception(data['error'] ?? data['message'] ?? 'Check-in gagal');
      }
    } catch (e) {
      throw Exception('Error check-in: $e');
    }
  }

  // =====================================================
  // ✅ Check-out (absen pulang)
  // =====================================================
  static Future<Map<String, dynamic>> checkOut({
    required String employeeId,
    required List<double> embedding,
    String? location,
    String? notes,
  }) async {
    final uri = Uri.parse('$baseUrl/attendance/flutter-check-out');

    try {
      final body = jsonEncode({
        'employee_id': employeeId,
        'embedding': embedding,
        'location': location ?? 'Unknown',
        'notes': notes ?? 'Check-out via Flutter App',
      });

      final response = await http.post(uri, headers: _headers, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Check-out berhasil',
          'data': data['data'],
        };
      } else {
        throw Exception(data['error'] ?? data['message'] ?? 'Check-out gagal');
      }
    } catch (e) {
      throw Exception('Error check-out: $e');
    }
  }

  // =====================================================
  // ✅ Get Employee by ID
  // =====================================================
  static Future<Employee> getEmployeeById(String employeeId) async {
    final uri = Uri.parse('$baseUrl/employees/$employeeId');

    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Employee.fromJson(jsonData['data']);
      } else {
        throw Exception('Gagal mendapatkan data pegawai');
      }
    } catch (e) {
      throw Exception('Error getEmployeeById: $e');
    }
  }

  // =====================================================
  // ✅ Get Attendance History
  // =====================================================
  static Future<List<Attendance>> getAttendanceHistory({
    String? employeeId,
    String? date,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (employeeId != null) queryParams['employee_id'] = employeeId;
    if (date != null) queryParams['date'] = date;

    final uri = Uri.parse('$baseUrl/attendance').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> list = jsonData['data'];
        return list.map((json) => Attendance.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mendapatkan riwayat absensi');
      }
    } catch (e) {
      throw Exception('Error getAttendanceHistory: $e');
    }
  }

  // =====================================================
  // ✅ Health Check
  // =====================================================
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'), headers: _headers);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // ✅ Get Current Attendance Status
  // =====================================================
  static Future<Map<String, dynamic>> getCurrentAttendanceStatus(String employeeId) async {
    final uri = Uri.parse('$baseUrl/attendance/status/$employeeId');
    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mendapatkan status absensi');
      }
    } catch (e) {
      throw Exception('Error getCurrentAttendanceStatus: $e');
    }
  }
}
