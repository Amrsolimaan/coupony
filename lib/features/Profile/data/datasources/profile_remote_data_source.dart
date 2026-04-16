import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/storage/secure_storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_persona.dart';
import '../../../auth/presentation/cubit/persona_cubit.dart';
import '../../domain/use_cases/update_profile_params.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE REMOTE DATA SOURCE
// ═══════════════════════════════════════════════════════════════════════════

abstract class ProfileRemoteDataSource {
  /// GET /auth/me — returns the authenticated user's full profile.
  Future<UserModel> getProfile();

  /// PATCH /auth/me — updates profile fields; supports avatar file upload
  /// via multipart/form-data and the [removeAvatar] flag.
  Future<UserModel> updateProfile(UpdateProfileParams params);

  /// DELETE /auth/me — permanently destroys the account.
  /// Requires [currentPassword] for confirmation.
  Future<void> deleteAccount(String currentPassword);
}

// ═══════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION
// ═══════════════════════════════════════════════════════════════════════════

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient client;
  final Logger logger;
  final SecureStorageService secureStorage;
  final PersonaCubit personaCubit;

  ProfileRemoteDataSourceImpl({
    required this.client,
    required this.logger,
    required this.secureStorage,
    required this.personaCubit,
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GET PROFILE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> getProfile() async {
    try {
      logger.i('📥 GET PROFILE REQUEST — ${ApiConstants.profile}');

      // X-User-Role is read from PersonaCubit (already resolved) — NOT from
      // SecureStorage. This breaks the circular feedback loop where a stale
      // 'seller' in storage caused the backend to return a seller-shaped
      // profile, which then prevented the role from being corrected.
      final currentRole = personaCubit.state is SellerPersona ? 'seller' : 'customer';
      logger.i('📤 Sending X-User-Role header: $currentRole (from PersonaCubit)');

      final response = await client.get(
        ApiConstants.profile,
        options: Options(
          headers: {
            'X-User-Role': currentRole,
          },
        ),
      );
      final data = response.data as Map<String, dynamic>? ?? {};

      logger.i('✅ GET PROFILE RESPONSE: $data');

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      logger.e('❌ GET PROFILE ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ GET PROFILE UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> updateProfile(UpdateProfileParams params) async {
    try {
      logger.i('📤 POST PROFILE REQUEST (with _method: PATCH) — ${ApiConstants.profile}');

      final formData = FormData();

      formData.fields.add(const MapEntry('_method', 'PATCH'));

      if (params.firstName   != null) formData.fields.add(MapEntry('first_name',    params.firstName!));
      if (params.lastName    != null) formData.fields.add(MapEntry('last_name',     params.lastName!));
      if (params.email       != null) formData.fields.add(MapEntry('email',         params.email!));
      if (params.phoneNumber != null) formData.fields.add(MapEntry('phone_number',  params.phoneNumber!));
      if (params.gender      != null) formData.fields.add(MapEntry('gender',        params.gender!));
      if (params.bio         != null) formData.fields.add(MapEntry('bio',           params.bio!));
      if (params.language    != null) formData.fields.add(MapEntry('language',      params.language!));

      if (params.removeAvatar != null) {
        formData.fields.add(MapEntry('remove_avatar', params.removeAvatar!.toString()));
      }

      if (params.avatar != null) {
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            params.avatar!.path,
            filename: params.avatar!.path.split('/').last,
          ),
        ));
      }

      // ── LOG: Print FormData fields for verification ──
      logger.i('📋 FormData Fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}');
      logger.i('📋 FormData Files: ${formData.files.map((e) => '${e.key}: ${e.value.filename}').join(', ')}');

      final response = await client.post(
        ApiConstants.profile,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      logger.i('✅ POST PROFILE RESPONSE: $data');

      return UserModel.fromJson(data);
    } on DioException catch (e) {
      logger.e('❌ POST PROFILE ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ POST PROFILE UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DELETE ACCOUNT
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteAccount(String currentPassword) async {
    try {
      logger.i('🗑️ DELETE ACCOUNT REQUEST — ${ApiConstants.profile}');

      await client.delete(
        ApiConstants.profile,
        data: {'current_password': currentPassword},
      );

      logger.i('✅ DELETE ACCOUNT — account destroyed');
    } on DioException catch (e) {
      logger.e('❌ DELETE ACCOUNT ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ DELETE ACCOUNT UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Never _rethrow(DioException e) {
    if (e.error is ValidationException)   throw e.error as ValidationException;
    if (e.error is UnauthorizedException) throw e.error as UnauthorizedException;
    if (e.error is NotFoundException)     throw e.error as NotFoundException;
    if (e.error is ServerException)       throw e.error as ServerException;

    final data    = e.response?.data;
    final message = (data is Map<String, dynamic>)
        ? data['message'] as String? ?? e.message ?? 'Network error'
        : e.message ?? 'Network error';

    throw ServerException(message);
  }
}
