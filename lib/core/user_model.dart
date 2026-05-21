class UserModel {
  final int id;
  final String email;
  final String? registerNumber;
  final String role;
  final String? department;

  UserModel({
    required this.id,
    required this.email,
    this.registerNumber,
    required this.role,
    this.department,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      registerNumber: json['register_number'] as String?,
      role: json['role'] as String,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'register_number': registerNumber,
      'role': role,
      'department': department,
    };
  }
}
