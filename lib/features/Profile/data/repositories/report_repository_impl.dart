import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORT REPOSITORY IMPLEMENTATION
// 
// Implements the domain repository interface.
// Handles network connectivity checks and error mapping.
// ─────────────────────────────────────────────────────────────────────────────

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ── Submit Customer Report ─────────────────────────────────────────────────
  @override
  Future<Either<Failure, String>> submitCustomerReport({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    // Check network connectivity
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final serverMessage = await remoteDataSource.submitCustomerReport(
        name: name,
        email: email,
        phone: phone,
        subject: subject,
        message: message,
      );
      return Right(serverMessage);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Submit Seller Report ───────────────────────────────────────────────────
  @override
  Future<Either<Failure, String>> submitSellerReport({
    required String name,
    required String email,
    required String phone,
    required String company,
    required String message,
  }) async {
    // Check network connectivity
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final serverMessage = await remoteDataSource.submitSellerReport(
        name: name,
        email: email,
        phone: phone,
        company: company,
        message: message,
      );
      return Right(serverMessage);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
