import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../services/face_recognition_service.dart';
import '../services/api_service.dart';

enum CameraMode { checkIn, checkOut }

class CameraScreen extends StatefulWidget {
  final CameraMode mode;
  const CameraScreen({super.key, required this.mode});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _hasSent = false;
  String _status = "Mencari wajah...";
  String? _error;

  late final FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inisialisasi detektor wajah MLKit
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableContours: false,
        enableClassification: true,
      ),
    );

    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // Inisialisasi kamera depan
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = "Tidak ada kamera tersedia");
        return;
      }

      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() => _isInitialized = true);

      _startImageStream();
    } catch (e) {
      setState(() => _error = "Gagal inisialisasi kamera: $e");
    }
  }

  // Mulai membaca frame kamera dan deteksi wajah
  void _startImageStream() {
    if (_cameraController == null) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing || _hasSent) return;
      _isProcessing = true;

      try {
        // Proses gambar dengan MLKit untuk deteksi wajah
        final result = await FaceRecognitionService.processCameraImage(
          image,
          _cameraController!.description.sensorOrientation,
        );

        if (result['success'] == true && result['isValid'] == true) {
          setState(() => _status = "Wajah terdeteksi ✅");

          final embedding = result['embedding'];
          if (embedding != null && embedding.isNotEmpty) {
            _hasSent = true;
            await _sendToServer(List<double>.from(embedding));
          }
        } else {
          setState(() => _status = result['message'] ?? "Mencari wajah...");
        }
      } catch (e) {
        setState(() => _status = "Kesalahan deteksi wajah: $e");
      }

      _isProcessing = false;
    });
  }

  // Kirim embedding ke backend
  Future<void> _sendToServer(List<double> embedding) async {
    try {
      setState(() => _status = "Memverifikasi wajah ke server...");

      final response = await ApiService.verifyFaceEmbedding(
        embedding: embedding,
        mode: widget.mode == CameraMode.checkIn ? "check_in" : "check_out", employeeId: '',
      );

      if (response['success'] == true && response['verified'] == true) {
        setState(() => _status = "Wajah cocok ✅ Absensi berhasil");
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() => _status = "Wajah tidak cocok ❌");
        _hasSent = false; // izinkan ulang
      }
    } catch (e) {
      setState(() => _status = "Gagal kirim ke server: $e");
      _hasSent = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 18)),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.mode == CameraMode.checkIn ? 'Check-In' : 'Check-Out'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: _status.contains("❌")
                        ? Colors.red
                        : _status.contains("✅")
                            ? Colors.greenAccent
                            : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
