import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../screens/face_recognition_screen.dart';

class AttendanceButtons extends StatelessWidget {
  const AttendanceButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Row(
            children: [
              // Check-in button
              Expanded(
                child: _AttendanceButton(
                  text: 'Absen Masuk',
                  icon: Icons.login,
                  color: Colors.green,
                  onTap: () => _handleCheckIn(context, provider),
                  isEnabled: true, // Kiosk mode: selalu aktif untuk pegawai berikutnya
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Check-out button
              Expanded(
                child: _AttendanceButton(
                  text: 'Absen Pulang',
                  icon: Icons.logout,
                  color: Colors.red,
                  onTap: () => _handleCheckOut(context, provider),
                  isEnabled: true, // Kiosk mode: selalu aktif
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleCheckIn(BuildContext context, AttendanceProvider provider) async {
    // Navigate to face recognition for check-in
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FaceRecognitionScreen(
          title: 'Absen Masuk',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final success = result['success'] ?? false;
      final message = result['message'] ?? '';
      if (success) {
        _showSuccessDialog(context, 'Absen Masuk Berhasil', message.isNotEmpty ? message : 'Berhasil mencatat kehadiran.');
        // Kiosk mode: jangan kunci tombol, biarkan pegawai berikutnya bisa absen
      } else {
        _showErrorDialog(context, 'Absen Masuk Gagal', message.isNotEmpty ? message : 'Gagal mencatat kehadiran.');
      }
    }
  }

  Future<void> _handleCheckOut(BuildContext context, AttendanceProvider provider) async {
    // Navigate to face recognition for check-out
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FaceRecognitionScreen(
          title: 'Absen Pulang',
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final success = result['success'] ?? false;
      final message = result['message'] ?? '';
      if (success) {
        _showSuccessDialog(context, 'Absen Pulang Berhasil', message.isNotEmpty ? message : 'Berhasil mencatat pulang.');
        // Kiosk mode: jangan kunci tombol, biarkan pegawai berikutnya bisa absen
      } else {
        _showErrorDialog(context, 'Absen Pulang Gagal', message.isNotEmpty ? message : 'Gagal mencatat pulang.');
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        backgroundColor: Colors.red[50],
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;

  const _AttendanceButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? color : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isEnabled ? color : Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled ? color : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
