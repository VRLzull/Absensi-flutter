import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_buttons.dart';
import '../widgets/time_date_card.dart';
import '../widgets/employee_info_card.dart';
import '../screens/camera_screen.dart';
import '../screens/face_recognition_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      _currentDate = _getIndonesianDate(now);
    });
  }

  String _getIndonesianDate(DateTime date) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Light orange background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with calendar icon and profile
              _buildHeader(),
              
              // Welcome message
              _buildWelcomeMessage(),
              
              // Time and date card
              TimeDateCard(
                time: _currentTime,
                date: _currentDate,
              ),
              
              const SizedBox(height: 30),
              
              // Attendance buttons
              const AttendanceButtons(),
              
              const SizedBox(height: 20),
              
              // Info untuk karyawan
              _buildEmployeeInfo(),
              
              const SizedBox(height: 20),
              
              // Employee info card (if employee is loaded)
              Consumer<AttendanceProvider>(
                builder: (context, provider, child) {
                  if (provider.currentEmployee != null) {
                    return EmployeeInfoCard(employee: provider.currentEmployee!);
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Calendar icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Profile icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.grey,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        String welcomeText = 'Selamat Datang!';
        
        if (provider.currentEmployee != null) {
          welcomeText = 'Selamat Datang, ${provider.currentEmployee!.fullName}!';
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            welcomeText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildEmployeeInfo() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 40,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 15),
              Text(
                'Sistem Absensi Digital',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Gunakan tombol "Absen Masuk" untuk memulai hari kerja\n'
                'dan "Absen Pulang" untuk mengakhiri hari kerja.\n'
                'Sistem akan mengenali wajah Anda secara otomatis.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.face_retouching_natural, 
                         color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pendaftaran wajah dilakukan melalui web admin',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
