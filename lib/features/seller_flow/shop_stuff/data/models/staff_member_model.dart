import '../../domain/entities/staff_member_entity.dart';

class StaffMemberModel extends StaffMemberEntity {
  const StaffMemberModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    required super.branchName,
    required super.joinedDate,
    required super.status,
  });

  StaffMemberModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? branchName,
    DateTime? joinedDate,
    StaffStatus? status,
  }) {
    return StaffMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branchName: branchName ?? this.branchName,
      joinedDate: joinedDate ?? this.joinedDate,
      status: status ?? this.status,
    );
  }

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    return StaffMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      branchName: json['branchName'] as String,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      status: json['status'] == 'active'
          ? StaffStatus.active
          : StaffStatus.stopped,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'branchName': branchName,
      'joinedDate': joinedDate.toIso8601String(),
      'status': status == StaffStatus.active ? 'active' : 'stopped',
    };
  }
}
