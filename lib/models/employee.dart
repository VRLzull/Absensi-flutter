class Employee {
  final int id;
  final String employeeId;
  final String fullName;
  final String? email;
  final String? phone;
  final String? position;
  final String? department;
  final String? gender;
  final String? address;
  final DateTime? hireDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.employeeId,
    required this.fullName,
    this.email,
    this.phone,
    this.position,
    this.department,
    this.gender,
    this.address,
    this.hireDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeId: json['employee_id'] ?? json['emp_id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      department: json['department'],
      gender: json['gender'],
      address: json['address'],
      hireDate: json['hire_date'] != null 
          ? DateTime.parse(json['hire_date']) 
          : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'gender': gender,
      'address': address,
      'hire_date': hireDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Employee(id: $id, employeeId: $employeeId, fullName: $fullName, position: $position, department: $department)';
  }
}
