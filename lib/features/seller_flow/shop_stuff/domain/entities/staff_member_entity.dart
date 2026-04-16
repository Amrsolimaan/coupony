import 'package:equatable/equatable.dart';

enum StaffStatus { active, stopped }

class StaffMemberEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String branchName;
  final DateTime joinedDate;
  final StaffStatus status;

  const StaffMemberEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.branchName,
    required this.joinedDate,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        branchName,
        joinedDate,
        status,
      ];
}
