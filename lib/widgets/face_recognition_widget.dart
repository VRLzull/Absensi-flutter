import 'dart:io';
import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import '../services/facenet_service.dart';
import '../config/api_config.dart';
import 'package:camera/camera.dart';

class FaceRecognitionWidget extends StatefulWidget {
  final String? employeeCode; // Isi untuk verifikasi, kosong untuk find
  final bool registerMode;    // true untuk daftar embedding
  final String title;         // Judul halaman
  final void Function(Map<String, dynamic>)? onResult;
  final void Function(String)? onError;

  const FaceRecognitionWidget({
    super.key,
    this.employeeCode,
    this.registerMode = false,
    this.title = 'Face Recognition',
    this.onResult,
    this.onError,
  });

  @override
  State<FaceRecognitionWidget> createState() => _FaceRecognitionWidgetState();
}

class _FaceRecognitionWidgetState extends State<FaceRecognitionWidget> {
  final CameraService _cameraService = CameraService();
  final FaceNetService _faceNetService = FaceNetService();

  bool _isLoading = false;
  bool _isInitialized = false;
  String _statusMessage = 'Menginisialisasi...';
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    
    // Auto-capture after a short delay to allow camera to initialize
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isInitialized && !_isLoading) {
        _processFaceRecognition();
      }
    });
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Menginisialisasi kamera...';
    });

    try {
      // Inisialisasi kamera
      await _cameraService.initialize();
      
      setState(() {
        _statusMessage = 'Menginisialisasi FaceNet...';
      });

      // Inisialisasi FaceNet dengan error handling
      try {
        await _faceNetService.initialize();
      } catch (modelError) {
        print('❌ FaceNet initialization failed: $modelError');
        // Untuk sementara, skip model loading dan langsung ke server check
        setState(() {
          _statusMessage = 'Model FaceNet tidak tersedia, menggunakan server...';
        });
        await Future.delayed(const Duration(seconds: 2));
      }

      // Cek koneksi server
      if (mounted) {
        setState(() {
          _statusMessage = 'Mengecek koneksi server...';
        });
      }

      final isConnected = await _faceNetService.checkServerConnection();
      if (!isConnected) {
        throw Exception('Tidak dapat terhubung ke server di ${ApiConfig.baseUrl}. Pastikan:\n1. Server Express.js berjalan di port 5000\n2. Device dan PC dalam jaringan yang sama\n3. Firewall tidak memblokir koneksi');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
          _statusMessage = _getReadyMessage();
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
          _statusMessage = 'Error: $e';
        });
      }
      
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    }
  }

  String _getReadyMessage() {
    if (widget.registerMode) {
      return 'Siap untuk mendaftarkan wajah';
    } else if (widget.employeeCode != null) {
      return 'Siap untuk verifikasi wajah';
    } else {
      return 'Siap untuk mencari karyawan';
    }
  }

  Future<void> _processFaceRecognition() async {
    if (_isLoading || !_isInitialized) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengambil foto...';
    });

    try {
      // Ambil foto
      final imagePath = await _cameraService.capturePhoto();
      _capturedImagePath = imagePath;

      setState(() {
        _statusMessage = 'Mengekstrak embedding wajah...';
      });

      // Proses dengan server
      Map<String, dynamic> result;
      
      // Check if model is available, if not use image upload fallback
      if (!_faceNetService.modelAvailable && !widget.registerMode && widget.employeeCode == null) {
        setState(() {
          _statusMessage = 'Mengirim gambar ke server...';
        });
        
        // Gunakan server-side processing dengan upload gambar
        final findResult = await _faceNetService.findEmployeeByImage(imagePath);

        // Jika mode dari layar adalah Absen Masuk/Pulang, otomatis catat absensi
        if (findResult['success'] == true) {
          final isCheckIn = widget.title.toLowerCase().contains('masuk');
          final isCheckOut = widget.title.toLowerCase().contains('pulang');
          if (isCheckIn || isCheckOut) {
            setState(() { _statusMessage = isCheckIn ? 'Mencatat absen masuk...' : 'Mencatat absen pulang...'; });
            try {
              result = isCheckIn
                  ? await _faceNetService.checkInWithImage(imagePath)
                  : await _faceNetService.checkOutWithImage(imagePath);
            } catch (e) {
              result = {
                'success': false,
                'message': e.toString(),
              };
            }
          } else {
            result = findResult;
          }
        } else {
          result = findResult;
        }
      } else {
        setState(() {
          _statusMessage = 'Mengekstrak fitur wajah...';
        });
        // Use embedding-based processing
        final embedding = await _faceNetService.extractFaceEmbedding(imagePath);

        setState(() {
          _statusMessage = 'Mengirim ke server...';
        });

        if (widget.registerMode) {
          if (widget.employeeCode == null) {
            throw Exception('Employee code harus diisi untuk mode register');
          }
          result = await _faceNetService.registerFace(widget.employeeCode!, embedding);
        } else if (widget.employeeCode != null) {
          result = await _faceNetService.verifyFace(widget.employeeCode!, embedding);
        } else {
          // Default: find employee by embedding
          final findResult = await _faceNetService.findEmployeeByFace(embedding);
          // Jika dari layar Absen, catat otomatis (gunakan endpoint Flutter jika tersedia)
          if (findResult['success'] == true) {
            final isCheckIn = widget.title.toLowerCase().contains('masuk');
            final isCheckOut = widget.title.toLowerCase().contains('pulang');
            if (isCheckIn || isCheckOut) {
              setState(() { _statusMessage = isCheckIn ? 'Mencatat absen masuk...' : 'Mencatat absen pulang...'; });
              // Untuk embedding mode, idealnya kirim descriptor; namun saat ini prioritas menggunakan upload gambar
              // sehingga blok ini jarang terpakai karena model lokal tidak tersedia.
            }
          }
          result = findResult;
        }
      }

      setState(() {
        _isLoading = false;
        _statusMessage = result['success'] == true ? 'Berhasil!' : 'Gagal';
      });

      // Panggil callback
      widget.onResult?.call(result);

      // Hapus file temporary
      await _cameraService.deleteTempFile(imagePath);
      _capturedImagePath = null;

    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e';
      });
      
      widget.onError?.call(e.toString());
      
      // Hapus file temporary jika ada
      if (_capturedImagePath != null) {
        await _cameraService.deleteTempFile(_capturedImagePath!);
        _capturedImagePath = null;
      }
    }
  }

  Future<void> _retryInitialization() async {
    await _initializeServices();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceNetService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isInitialized)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryInitialization,
              tooltip: 'Coba lagi',
            ),
        ],
      ),
      body: Column(
        children: [
          // Camera preview
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _isInitialized && _cameraService.controller != null
                  ? CameraPreview(_cameraService.controller!)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Menginisialisasi kamera...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Status message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_isLoading) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main action button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || !_isInitialized 
                        ? null 
                        : _processFaceRecognition,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.face_retouching_natural),
                    label: Text(
                      _isLoading 
                          ? 'Memproses...' 
                          : _getButtonText(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, 
                               color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Petunjuk:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Posisikan wajah di tengah frame\n'
                        '• Pastikan pencahayaan cukup\n'
                        '• Jaga jarak yang tepat dari kamera\n'
                        '• Tunggu hingga status "Siap"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (widget.registerMode) {
      return 'Daftarkan Wajah';
    } else if (widget.employeeCode != null) {
      return 'Verifikasi Wajah';
    } else {
      return 'Cari Karyawan';
    }
  }
}
