import 'dart:io';

import 'package:equatable/equatable.dart';

/// Parameters for PATCH /auth/me
class UpdateProfileParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final String? bio;
  final String? language;

  /// Local image file to upload as the new avatar.
  final File? avatar;

  /// Pass 1 to instruct the backend to remove the current avatar.
  /// Ignored when [avatar] is also provided.
  final int? removeAvatar;

  const UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.gender,
    this.bio,
    this.language,
    this.avatar,
    this.removeAvatar,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        phoneNumber,
        gender,
        bio,
        language,
        avatar?.path,
        removeAvatar,
      ];
}
