// File ini sudah digantikan dengan FaceNetService
// Silakan gunakan lib/services/facenet_service.dart untuk FaceNet TFLite integration

import 'facenet_service.dart';

// Re-export untuk backward compatibility
class FaceRecognitionService extends FaceNetService {
  // Legacy compatibility methods
  // Tambahkan stub agar pemanggilan lama tidak error saat build
  static Future<Map<String, dynamic>> processCameraImage(
    dynamic cameraImage,
    int employeeId,
  ) async {
    throw UnsupportedError(
      'processCameraImage tidak didukung. Gunakan FaceRecognitionWidget.',
    );
  }

  static Future<Map<String, dynamic>> processAndVerifyFace(
    dynamic cameraImage, {
    required String employeeId,
    dynamic rotation,
  }) async {
    throw UnsupportedError(
      'Method ini sudah tidak didukung. '
      'Gunakan FaceRecognitionWidget untuk integrasi FaceNet TFLite.'
    );
  }

  // Hapus static dispose yang konflik dengan instance method
}
