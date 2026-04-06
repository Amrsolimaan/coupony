import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../../core/config/app_config.dart';

/// Converts lat/lng coordinates to a human-readable address.
/// Never throws — returns a formatted coordinate string as a last resort.
abstract class LocationGeocodingDataSource {
  Future<String> getAddressFromCoordinates(double lat, double lng);
}

class LocationGeocodingDataSourceImpl implements LocationGeocodingDataSource {
  final Logger logger;
  final http.Client _httpClient;

  LocationGeocodingDataSourceImpl({
    required this.logger,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    // 1. Google Geocoding API (primary — Arabic, strips Plus Codes)
    final apiResult = await _fetchFromGoogleApi(lat, lng);
    if (apiResult != null) return apiResult;

    // 2. Native geocoding package (fallback)
    final nativeResult = await _fetchFromNative(lat, lng);
    if (nativeResult != null) return nativeResult;

    // 3. Formatted coordinates (last resort — never null)
    final latDir = lat >= 0 ? 'شمالاً' : 'جنوباً';
    final lngDir = lng >= 0 ? 'شرقاً' : 'غرباً';
    return 'الموقع: ${lat.abs().toStringAsFixed(4)}° $latDir، '
        '${lng.abs().toStringAsFixed(4)}° $lngDir';
  }

  Future<String?> _fetchFromGoogleApi(double lat, double lng) async {
    final key = AppConfig.googleMapsApiKey;
    if (key.isEmpty) {
      logger.w('MAPS_API_KEY_ANDROID/IOS not set — skipping Google Geocoding API');
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$lat,$lng'
        '&key=$key'
        '&language=ar'
        '&result_type=street_address|route|neighborhood|locality',
      );

      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results[0] as Map<String, dynamic>;
      final raw = (first['formatted_address'] as String?) ?? '';

      return _buildCustomAddress(first) ?? _removePlusCode(raw);
    } catch (e) {
      logger.e('Google Geocoding API error: $e');
      return null;
    }
  }

  Future<String?> _fetchFromNative(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 5));
      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      final parts = [
        p.street,
        p.subLocality,
        p.locality,
        p.administrativeArea,
      ].whereType<String>().where((s) => s.isNotEmpty).toList();

      return parts.isNotEmpty ? parts.join('، ') : null;
    } catch (e) {
      logger.e('Native geocoding error: $e');
      return null;
    }
  }

  String _removePlusCode(String address) {
    final cleaned = address
        .replaceFirst(RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,3}[،,]\s*'), '')
        .trim();
    return cleaned.isNotEmpty ? cleaned : address;
  }

  String? _buildCustomAddress(Map<String, dynamic> result) {
    try {
      final components = result['address_components'] as List<dynamic>?;
      if (components == null) return null;

      String? neighborhood, route, locality, adminLevel1, adminLevel2;

      for (final comp in components) {
        final types =
            List<String>.from((comp['types'] as List<dynamic>?) ?? []);
        final name = comp['long_name'] as String?;
        if (name == null || name.isEmpty) continue;

        if (types.contains('neighborhood')) {
          neighborhood = name;
        } else if (types.contains('route')) {
          route = name;
        } else if (types.contains('locality')) {
          locality = name;
        } else if (types.contains('administrative_area_level_1')) {
          adminLevel1 = name;
        } else if (types.contains('administrative_area_level_2')) {
          adminLevel2 = name;
        }
      }

      final parts = [
        neighborhood ?? route,
        locality ?? adminLevel2,
        adminLevel1,
      ].whereType<String>().where((s) => s.isNotEmpty).toList();

      return parts.isNotEmpty ? parts.join('، ') : null;
    } catch (_) {
      return null;
    }
  }
}
