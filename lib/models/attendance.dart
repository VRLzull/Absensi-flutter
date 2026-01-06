class Attendance {
  final int id;
  final int employeeId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? checkInImage;
  final String? checkOutImage;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final String? employeeName;
  final String? position;
  final String? department;

  Attendance({
    required this.id,
    required this.employeeId,
    this.checkIn,
    this.checkOut,
    this.checkInImage,
    this.checkOutImage,
    this.checkInLocation,
    this.checkOutLocation,
    required this.status,
    this.notes,
    required this.createdAt,
    this.employeeName,
    this.position,
    this.department,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      employeeId: json['employee_id'],
      checkIn: json['check_in'] != null 
          ? DateTime.parse(json['check_in']) 
          : null,
      checkOut: json['check_out'] != null 
          ? DateTime.parse(json['check_out']) 
          : null,
      checkInImage: json['check_in_image'],
      checkOutImage: json['check_out_image'],
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      employeeName: json['full_name'],
      position: json['position'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'check_in': checkIn?.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'check_in_image': checkInImage,
      'check_out_image': checkOutImage,
      'check_in_location': checkInLocation,
      'check_out_location': checkOutLocation,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'full_name': employeeName,
      'position': position,
      'department': department,
    };
  }

  bool get isCheckedIn => checkIn != null;
  bool get isCheckedOut => checkOut != null;
  bool get isPresent => status == 'present';
  bool get isLate => status == 'late';
  bool get isAbsent => status == 'absent';
  bool get isHalfDay => status == 'half_day';

  @override
  String toString() {
    return 'Attendance(id: $id, employeeId: $employeeId, checkIn: $checkIn, checkOut: $checkOut, status: $status)';
  }
}
