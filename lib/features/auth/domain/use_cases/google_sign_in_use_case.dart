import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInParams {
  final String role;

  const GoogleSignInParams({
    required this.role,
  });
}

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(GoogleSignInParams params) async {
    try {
      print('🔐 [USE_CASE] Starting Google Sign-In use case for role: ${params.role}');
      final result = await repository.googleSignIn(role: params.role);
      print('🔐 [USE_CASE] Repository returned result');
      return result;
    } catch (e, stackTrace) {
      print('❌ [USE_CASE] Error in GoogleSignInUseCase: $e');
      print('❌ [USE_CASE] Stack trace: $stackTrace');
      rethrow;
    }
  }
}