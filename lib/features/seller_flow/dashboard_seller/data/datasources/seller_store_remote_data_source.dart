import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../domain/use_cases/update_store_profile_use_case.dart';
import '../models/shop_display_model.dart';

// ════════════════════════════════════════════════════════
// SELLER STORE REMOTE DATA SOURCE
// ════════════════════════════════════════════════════════

abstract class SellerStoreRemoteDataSource {
  /// GET /api/v1/stores
  Future<List<StoreDisplayModel>> getStores();

  /// POST /api/v1/stores/{id}/profile  (_method: PATCH)
  Future<StoreDisplayModel> updateStoreProfile(UpdateStoreProfileParams params);
}

// ════════════════════════════════════════════════════════
// IMPLEMENTATION
// ════════════════════════════════════════════════════════

class SellerStoreRemoteDataSourceImpl implements SellerStoreRemoteDataSource {
  final DioClient client;
  final Logger logger;

  const SellerStoreRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  @override
  Future<List<StoreDisplayModel>> getStores() async {
    try {
      logger.i('📥 GET STORES REQUEST — ${ApiConstants.stores}');

      final response = await client.get(ApiConstants.stores);
      final data = response.data as Map<String, dynamic>? ?? {};

      logger.i('✅ GET STORES RESPONSE: $data');

      if (data['success'] != true) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to fetch stores',
        );
      }

      final storesData = data['data'] as Map<String, dynamic>? ?? {};
      final storesList = storesData['data'] as List<dynamic>? ?? [];

      logger.i('📦 Parsed ${storesList.length} store(s)');

      return storesList
          .map((json) => StoreDisplayModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.e('❌ GET STORES ERROR: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch stores: ${e.toString()}');
    }
  }

  @override
  Future<StoreDisplayModel> updateStoreProfile(
    UpdateStoreProfileParams params,
  ) async {
    final endpoint = ApiConstants.storeProfile(params.storeId);
    try {
      logger.i('📤 UPDATE STORE PROFILE REQUEST — $endpoint');

      // Build multipart form data (Laravel _method spoofing: POST → PATCH)
      final formData = FormData();
      formData.fields.add(MapEntry('_method', 'PATCH'));
      formData.fields.add(MapEntry('name', params.name));

      // Add email if provided
      if (params.email != null && params.email!.isNotEmpty) {
        formData.fields.add(MapEntry('email', params.email!));
      }
      
      // Add description if provided
      if (params.description != null && params.description!.isNotEmpty) {
        formData.fields.add(MapEntry('description', params.description!));
      }
      
      // Add phone if provided
      if (params.phone != null && params.phone!.isNotEmpty) {
        formData.fields.add(MapEntry('phone', params.phone!));
      }

      // Add hours - ensure all 7 days are sent
      for (var i = 0; i < params.hours.length; i++) {
        final h = params.hours[i];
        
        // When a day is closed, use default times to avoid validation errors
        final openTime = h.isClosed ? '09:00' : h.openTime;
        final closeTime = h.isClosed ? '17:00' : h.closeTime;
        
        formData.fields.addAll([
          MapEntry('hours[$i][day_of_week]', h.dayOfWeek.toString()),
          MapEntry('hours[$i][open_time]', openTime),
          MapEntry('hours[$i][close_time]', closeTime),
          MapEntry('hours[$i][is_closed]', h.isClosed ? '1' : '0'),
        ]);
      }

      logger.i('📋 Form Data Fields: ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}');

      final response = await client.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      logger.i('✅ UPDATE STORE PROFILE RESPONSE: $data');

      if (data['success'] != true) {
        throw ServerException(
          data['message'] as String? ?? 'Failed to update store profile',
        );
      }

      final storeJson = data['data'] as Map<String, dynamic>? ?? {};
      return StoreDisplayModel.fromJson(storeJson);
    } on DioException catch (e) {
      logger.e('❌ UPDATE STORE PROFILE DIO ERROR: $e');
      logger.e('❌ Response Status: ${e.response?.statusCode}');
      logger.e('❌ Response Data: ${e.response?.data}');
      
      // If it's a validation error, extract the detailed message
      if (e.error is ValidationException) {
        final validationError = e.error as ValidationException;
        logger.e('❌ Validation Error Message: ${validationError.message}');
        throw ServerException(validationError.message);
      }
      
      if (e.error is ServerException) {
        throw e.error as ServerException;
      }
      
      throw ServerException('Failed to update store profile: ${e.toString()}');
    } catch (e) {
      logger.e('❌ UPDATE STORE PROFILE ERROR: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update store profile: ${e.toString()}');
    }
  }
}
