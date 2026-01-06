import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  // Rename to avoid name clash with camera.availableCameras() function
  List<CameraDescription>? get cameraList => _cameras;

  /// Inisialisasi kamera
  Future<void> initialize() async {
    try {
      // Request permission kamera
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Exception('Izin kamera ditolak. Silakan aktifkan di pengaturan.');
      }

      // Dapatkan daftar kamera yang tersedia
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('Tidak ada kamera yang tersedia di device ini');
      }

      // Pilih kamera depan (front camera) untuk face recognition
      CameraDescription? selectedCamera;
      try {
        selectedCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
      } catch (e) {
        // Jika tidak ada kamera depan, gunakan kamera pertama
        selectedCamera = _cameras!.first;
      }

      // Inisialisasi controller kamera
      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium, // Balance antara kualitas dan performa
        enableAudio: false, // Tidak perlu audio untuk face recognition
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;

      print('✅ Camera initialized successfully');
      print('📷 Using camera: ${selectedCamera.name}');
      print('📐 Resolution: ${_controller!.value.previewSize}');
    } catch (e) {
      print('❌ Error initializing camera: $e');
      _isInitialized = false;
      throw Exception('Gagal menginisialisasi kamera: $e');
    }
  }

  /// Ambil foto dari kamera
  Future<String> capturePhoto() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Kamera belum diinisialisasi');
    }

    if (!_controller!.value.isInitialized) {
      throw Exception('Kamera belum siap');
    }

    try {
      // Ambil foto
      final picture = await _controller!.takePicture();
      
      // Simpan ke temporary directory untuk diproses
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'captured_face_$timestamp.jpg';
      final tempPath = '${tempDir.path}/$fileName';
      
      // Copy file ke temporary directory
      await File(picture.path).copy(tempPath);
      
      print('📸 Photo captured: $tempPath');
      return tempPath;
    } catch (e) {
      print('❌ Error capturing photo: $e');
      throw Exception('Gagal mengambil foto: $e');
    }
  }

  /// Mulai preview kamera
  Future<void> startPreview() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Kamera belum diinisialisasi');
    }

    try {
      await _controller!.startImageStream((CameraImage image) {
        // Stream processing bisa ditambahkan di sini jika diperlukan
        // untuk real-time face detection
      });
    } catch (e) {
      print('❌ Error starting preview: $e');
      throw Exception('Gagal memulai preview kamera: $e');
    }
  }

  /// Hentikan preview kamera
  Future<void> stopPreview() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      try {
        await _controller!.stopImageStream();
      } catch (e) {
        print('❌ Error stopping preview: $e');
      }
    }
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.setFlashMode(mode);
      } catch (e) {
        print('❌ Error setting flash mode: $e');
      }
    }
  }

  /// Set focus mode
  Future<void> setFocusMode(FocusMode mode) async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.setFocusMode(mode);
      } catch (e) {
        print('❌ Error setting focus mode: $e');
      }
    }
  }

  /// Set exposure mode
  Future<void> setExposureMode(ExposureMode mode) async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.setExposureMode(mode);
      } catch (e) {
        print('❌ Error setting exposure mode: $e');
      }
    }
  }

  /// Set focus point
  Future<void> setFocusPoint(Offset point) async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.setFocusPoint(point);
      } catch (e) {
        print('❌ Error setting focus point: $e');
      }
    }
  }

  /// Set exposure point
  Future<void> setExposurePoint(Offset point) async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.setExposurePoint(point);
      } catch (e) {
        print('❌ Error setting exposure point: $e');
      }
    }
  }

  /// Hapus file temporary
  Future<void> deleteTempFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Temp file deleted: $filePath');
      }
    } catch (e) {
      print('❌ Error deleting temp file: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await stopPreview();
      await _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      print('✅ Camera service disposed');
    } catch (e) {
      print('❌ Error disposing camera: $e');
    }
  }
}
