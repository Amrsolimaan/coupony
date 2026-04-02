import 'dart:io';

import 'package:equatable/equatable.dart';

class VerificationDocsEntity extends Equatable {
  final File? commercialRegister;
  final File? taxCard;
  final File? idCardFront;
  final File? idCardBack;

  const VerificationDocsEntity({
    this.commercialRegister,
    this.taxCard,
    this.idCardFront,
    this.idCardBack,
  });

  bool get hasAny =>
      commercialRegister != null ||
      taxCard != null ||
      idCardFront != null ||
      idCardBack != null;

  @override
  List<Object?> get props => [
        commercialRegister?.path,
        taxCard?.path,
        idCardFront?.path,
        idCardBack?.path,
      ];
}
