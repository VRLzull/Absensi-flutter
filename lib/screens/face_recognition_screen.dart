import 'package:flutter/material.dart';
import '../widgets/face_recognition_widget.dart';

class FaceRecognitionScreen extends StatelessWidget {
  final String? employeeCode;
  final bool registerMode;
  final String title;

  const FaceRecognitionScreen({
    super.key,
    this.employeeCode,
    this.registerMode = false,
    this.title = 'Face Recognition',
  });

  @override
  Widget build(BuildContext context) {
    return FaceRecognitionWidget(
      employeeCode: employeeCode,
      registerMode: registerMode,
      title: title,
      onResult: (result) {
        // Kembalikan hasil ke halaman sebelumnya agar penanganan dialog/state dilakukan di caller
        Navigator.of(context).pop(result);
      },
      onError: (error) {
        _showErrorDialog(context, 'Error', error);
      },
    );
  }

  void _handleResult(BuildContext context, Map<String, dynamic> result) {
    if (result['success'] == true) {
      if (registerMode) {
        _showSuccessDialog(
          context,
          'Pendaftaran Berhasil',
          'Wajah berhasil didaftarkan untuk ${result['data']?['employee_name'] ?? 'karyawan'}',
        );
      } else if (employeeCode != null) {
        // Verifikasi mode
        if (result['verified'] == true) {
          _showSuccessDialog(
            context,
            'Verifikasi Berhasil',
            'Selamat datang, ${result['data']?['employee_name'] ?? 'karyawan'}!\n'
            'Confidence: ${(result['data']?['confidence'] ?? 0.0).toStringAsFixed(2)}',
          );
        } else {
          _showErrorDialog(
            context,
            'Verifikasi Gagal',
            'Wajah tidak dikenali. Silakan coba lagi.',
          );
        }
      } else {
        // Find employee mode
        _showSuccessDialog(
          context,
          'Karyawan Ditemukan',
          'Nama: ${result['data']?['employee_name'] ?? 'Tidak diketahui'}\n'
          'Posisi: ${result['data']?['position'] ?? 'Tidak diketahui'}\n'
          'Departemen: ${result['data']?['department'] ?? 'Tidak diketahui'}\n'
          'Confidence: ${(result['data']?['confidence'] ?? 0.0).toStringAsFixed(2)}',
        );
      }
    } else {
      _showErrorDialog(
        context,
        'Gagal',
        result['message'] ?? 'Terjadi kesalahan yang tidak diketahui',
      );
    }
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
