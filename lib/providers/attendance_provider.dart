import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';
import '../services/face_recognition_service.dart';

class AttendanceProvider with ChangeNotifier {
  Employee? _currentEmployee;
  Attendance? _todayAttendance;
  bool _isLoading = false;
  String? _errorMessage;
  List<Attendance> _attendanceHistory = [];

  // Getters
  Employee? get currentEmployee => _currentEmployee;
  Attendance? get todayAttendance => _todayAttendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Attendance> get attendanceHistory => _attendanceHistory;

  void setCurrentEmployee(Employee employee) {
    _currentEmployee = employee;
    notifyListeners();
  }

  void clearCurrentEmployee() {
    _currentEmployee = null;
    _todayAttendance = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =======================================================
  // ✅ CHECK-IN DENGAN VERIFIKASI WAJAH (ML Kit + Backend)
  // =======================================================
  Future<bool> checkInWithFace({
    required String employeeId,
    required dynamic cameraImage,
    String? location,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // 1️⃣ Simulasi hasil untuk kompatibilitas sementara
      final result = <String, dynamic>{
        'success': false,
        'isValid': false,
        'message': 'Gunakan FaceRecognitionWidget untuk face recognition',
        'embedding': <double>[],
      };
      
      if (!(result['success'] as bool) || !(result['isValid'] as bool)) {
        _setError((result['message'] as String?) ?? 'Wajah tidak valid');
        return false;
      }

      // 2️⃣ Ambil embedding dari hasil deteksi
      final embedding = result['embedding'] as List<double>;

      // 3️⃣ Verifikasi wajah ke backend
      final verification = await ApiService.verifyFaceEmbedding(
        employeeId: employeeId,
        embedding: embedding,
        mode: 'check_in', // or the appropriate mode value
      );

      if (verification['verified'] != true) {
        _setError('Verifikasi wajah gagal: ${verification['error'] ?? 'Tidak cocok'}');
        return false;
      }

      // 4️⃣ Lakukan check-in ke backend
      final checkInResult = await ApiService.checkIn(
        employeeId: employeeId,
        location: location,
        notes: notes,
        embedding: embedding, // ← wajib dikirim
      );

      if (checkInResult['success']) {
        _todayAttendance = Attendance(
          id: checkInResult['data']['id'],
          employeeId: _currentEmployee?.id ?? 0,
          checkIn: DateTime.now(),
          status: checkInResult['data']['status'],
          createdAt: DateTime.now(),
          employeeName: _currentEmployee?.fullName,
          position: _currentEmployee?.position,
          department: _currentEmployee?.department,
        );
        notifyListeners();
        return true;
      } else {
        _setError('Check-in gagal: ${checkInResult['error']}');
        return false;
      }
    } catch (e) {
      _setError('Error check-in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =======================================================
  // ✅ CHECK-OUT DENGAN VERIFIKASI WAJAH (ML Kit + Backend)
  // =======================================================
  Future<bool> checkOutWithFace({
    required String employeeId,
    required dynamic cameraImage,
    String? location,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // 1️⃣ Simulasi hasil untuk kompatibilitas sementara
      final result = <String, dynamic>{
        'success': false,
        'isValid': false,
        'message': 'Gunakan FaceRecognitionWidget untuk face recognition',
        'embedding': <double>[],
      };
      
      if (!(result['success'] as bool) || !(result['isValid'] as bool)) {
        _setError((result['message'] as String?) ?? 'Wajah tidak valid');
        return false;
      }

      // 2️⃣ Ambil embedding wajah
      final embedding = result['embedding'] as List<double>;

      // 3️⃣ Verifikasi ke backend
      final verification = await ApiService.verifyFaceEmbedding(
        employeeId: employeeId,
        embedding: embedding,
        mode: 'check_out', // or the appropriate mode value
      );

      if (verification['verified'] != true) {
        _setError('Verifikasi wajah gagal: ${verification['error'] ?? 'Tidak cocok'}');
        return false;
      }

      // 4️⃣ Lakukan check-out ke backend
      final checkOutResult = await ApiService.checkOut(
        employeeId: employeeId,
        location: location,
        notes: notes,
        embedding: embedding, // ← wajib dikirim
      );

      if (checkOutResult['success']) {
        if (_todayAttendance != null) {
          _todayAttendance = Attendance(
            id: _todayAttendance!.id,
            employeeId: _todayAttendance!.employeeId,
            checkIn: _todayAttendance!.checkIn,
            checkOut: DateTime.now(),
            checkInImage: _todayAttendance!.checkInImage,
            checkOutImage: checkOutResult['data']['check_out_image'],
            checkInLocation: _todayAttendance!.checkInLocation,
            checkOutLocation: checkOutResult['data']['check_out_location'],
            status: _todayAttendance!.status,
            notes: notes,
            createdAt: _todayAttendance!.createdAt,
            employeeName: _todayAttendance!.employeeName,
            position: _todayAttendance!.position,
            department: _todayAttendance!.department,
          );
        }
        notifyListeners();
        return true;
      } else {
        _setError('Check-out gagal: ${checkOutResult['error']}');
        return false;
      }
    } catch (e) {
      _setError('Error check-out: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =======================================================
  // LOAD HISTORY & DATA PEGAWAI
  // =======================================================
  Future<void> loadAttendanceHistory({
    String? employeeId,
    String? date,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final history = await ApiService.getAttendanceHistory(
        employeeId: employeeId,
        date: date,
        page: page,
        limit: limit,
      );
      _attendanceHistory = history;
      notifyListeners();
    } catch (e) {
      _setError('Error loading attendance history: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadEmployee(String employeeId) async {
    try {
      _setLoading(true);
      _setError(null);
      final employee = await ApiService.getEmployeeById(employeeId);
      _currentEmployee = employee;
      notifyListeners();
    } catch (e) {
      _setError('Error loading employee: $e');
    } finally {
      _setLoading(false);
    }
  }

  bool get isCheckedInToday {
    if (_todayAttendance == null) return false;
    final today = DateTime.now();
    final checkInDate = _todayAttendance!.checkIn;
    return checkInDate != null &&
        checkInDate.year == today.year &&
        checkInDate.month == today.month &&
        checkInDate.day == today.day;
  }

  bool get isCheckedOutToday {
    if (_todayAttendance == null) return false;
    return _todayAttendance!.checkOut != null;
  }

  String get todayDate {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String get currentTime {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void setCheckedInToday(bool value) {
    if (value && _todayAttendance == null) {
      _todayAttendance = Attendance(
        id: DateTime.now().millisecondsSinceEpoch,
        employeeId: _currentEmployee?.id ?? 0,
        checkIn: DateTime.now(),
        status: 'checked_in',
        createdAt: DateTime.now(),
        employeeName: _currentEmployee?.fullName,
        position: _currentEmployee?.position,
        department: _currentEmployee?.department,
      );
    }
    notifyListeners();
  }

  void setCheckedOutToday(bool value) {
    if (value && _todayAttendance != null) {
      _todayAttendance = Attendance(
        id: _todayAttendance!.id,
        employeeId: _todayAttendance!.employeeId,
        checkIn: _todayAttendance!.checkIn,
        checkOut: DateTime.now(),
        checkInImage: _todayAttendance!.checkInImage,
        checkOutImage: _todayAttendance!.checkOutImage,
        checkInLocation: _todayAttendance!.checkInLocation,
        checkOutLocation: _todayAttendance!.checkOutLocation,
        status: 'checked_out',
        notes: _todayAttendance!.notes,
        createdAt: _todayAttendance!.createdAt,
        employeeName: _todayAttendance!.employeeName,
        position: _todayAttendance!.position,
        department: _todayAttendance!.department,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
