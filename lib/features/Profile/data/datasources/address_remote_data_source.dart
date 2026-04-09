import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/saved_address_model.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ADDRESS REMOTE DATA SOURCE
// ═══════════════════════════════════════════════════════════════════════════

abstract class AddressRemoteDataSource {
  /// GET /me/addresses — fetch all addresses for the authenticated user.
  Future<List<SavedAddressModel>> fetchAddresses();

  /// GET /me/addresses?search=query — server-side address search.
  Future<List<SavedAddressModel>> searchAddresses(String query);

  /// POST /me/addresses — create a new address.
  Future<SavedAddressModel> createAddress(Map<String, dynamic> data);

  /// POST /me/addresses/{id} with _method: PATCH — update an existing address.
  /// Uses POST + _method spoofing for Laravel multipart/form-data compatibility.
  Future<SavedAddressModel> updateAddress(String id, Map<String, dynamic> data);

  /// DELETE /me/addresses/{id} — delete an address.
  Future<void> deleteAddress(String id);
}

// ═══════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION
// ═══════════════════════════════════════════════════════════════════════════

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final DioClient client;
  final Logger logger;

  AddressRemoteDataSourceImpl({
    required this.client,
    required this.logger,
  });

  // ──────────────────────────────────────────────────────────────────────────
  // FETCH ADDRESSES
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<List<SavedAddressModel>> fetchAddresses() async {
    try {
      logger.i('📥 GET ADDRESSES REQUEST — ${ApiConstants.addresses}');

      final response = await client.get(ApiConstants.addresses);
      final responseData = response.data;

      logger.i('✅ GET ADDRESSES RESPONSE: $responseData');

      // Handle both { "data": [...] } wrapper and direct array
      List<dynamic> addressList;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        addressList = responseData['data'] as List<dynamic>? ?? [];
      } else if (responseData is List) {
        addressList = responseData;
      } else {
        addressList = [];
      }

      return addressList
          .map((json) => SavedAddressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ GET ADDRESSES ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ GET ADDRESSES UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CREATE ADDRESS
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<SavedAddressModel> createAddress(Map<String, dynamic> data) async {
    try {
      logger.i('📤 POST ADDRESS REQUEST — ${ApiConstants.addresses}');
      logger.i('📋 Request Body: $data');

      final response = await client.post(
        ApiConstants.addresses,
        data: data,
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};

      logger.i('✅ POST ADDRESS RESPONSE: $responseData');

      // Handle { "data": { ... } } wrapper
      final addressJson = responseData.containsKey('data')
          ? responseData['data'] as Map<String, dynamic>
          : responseData;

      return SavedAddressModel.fromJson(addressJson);
    } on DioException catch (e) {
      logger.e('❌ POST ADDRESS ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ POST ADDRESS UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UPDATE ADDRESS (POST + _method: PATCH for Laravel compatibility)
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<SavedAddressModel> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      final endpoint = ApiConstants.addressById(id);
      logger.i('📤 POST ADDRESS REQUEST (with _method: PATCH) — $endpoint');

      // Build FormData with _method spoofing for Laravel
      final formData = FormData();
      formData.fields.add(const MapEntry('_method', 'PATCH'));

      data.forEach((key, value) {
        if (value != null) {
          // Handle boolean values properly for Laravel validation
          if (value is bool) {
            formData.fields.add(MapEntry(key, value ? '1' : '0'));
          } else {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        }
      });

      // ── LOG: Print FormData fields for verification ──
      logger.i('📋 FormData Fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}');

      final response = await client.post(
        endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final responseData = response.data as Map<String, dynamic>? ?? {};

      logger.i('✅ PATCH ADDRESS RESPONSE: $responseData');

      // Handle { "data": { ... } } wrapper
      final addressJson = responseData.containsKey('data')
          ? responseData['data'] as Map<String, dynamic>
          : responseData;

      return SavedAddressModel.fromJson(addressJson);
    } on DioException catch (e) {
      logger.e('❌ PATCH ADDRESS ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ PATCH ADDRESS UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DELETE ADDRESS
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteAddress(String id) async {
    try {
      final endpoint = ApiConstants.addressById(id);
      logger.i('🗑️ DELETE ADDRESS REQUEST — $endpoint');

      await client.delete(endpoint);

      logger.i('✅ DELETE ADDRESS — address $id destroyed');
    } on DioException catch (e) {
      logger.e('❌ DELETE ADDRESS ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ DELETE ADDRESS UNEXPECTED ERROR: $e');
      throw ServerException(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SEARCH ADDRESSES
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<List<SavedAddressModel>> searchAddresses(String query) async {
    try {
      logger.i('🔍 GET SEARCH ADDRESSES — query: "$query"');

      final response = await client.get(
        ApiConstants.addresses,
        queryParameters: {'search': query},
      );
      final responseData = response.data;

      logger.i('✅ SEARCH ADDRESSES RESPONSE: $responseData');

      // Handle both { "data": [...] } wrapper and direct array
      List<dynamic> addressList;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        addressList = responseData['data'] as List<dynamic>? ?? [];
      } else if (responseData is List) {
        addressList = responseData;
      } else {
        addressList = [];
      }

      return addressList
          .map((json) => SavedAddressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ SEARCH ADDRESSES ERROR: ${e.response?.statusCode} — ${e.response?.data}');
      _rethrow(e);
    } catch (e) {
      logger.e('❌ SEARCH ADDRESSES UNEXPECTED ERROR: $e');
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
