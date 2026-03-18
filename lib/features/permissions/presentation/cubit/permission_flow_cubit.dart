import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/repositories/permission_repository.dart';
import 'permission_flow_state.dart';

/// Permission Flow Cubit
/// Manages the permission flow for location and notifications
///
/// PRIVACY COMPLIANCE:
/// - Follows Google Play & App Store guidelines
/// - Shows rationale BEFORE requesting permissions
/// - Handles graceful degradation on denial
/// - Never batches permission requests
/// - Each permission tied to user action
///
/// ✅ FIXED ISSUES:
/// - Proper position fetch error handling
/// - Clear navigation flow on failures
/// - Retry mechanism for position fetching
/// - Better error states and user feedback
class PermissionFlowCubit extends Cubit<PermissionFlowState> {
  final PermissionRepository repository;
  final NotificationService notificationService;
  final Logger logger;

  PermissionFlowCubit({
    required this.repository,
    required this.logger,
    required this.notificationService,
  }) : super(const PermissionFlowState());

  // ════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════

  /// Initialize the permission flow
  /// Called from UI when wrapper loads
  Future<void> initializeFlow() async {
    logger.i('🚀 Initializing Permission Flow...');
    await _loadExistingPermissions();
  }

  /// Load existing permissions (if user has gone through flow before)
  Future<void> _loadExistingPermissions() async {
    final result = await repository.getPermissionStatus();

    result.fold(
      (failure) {
        logger.d('No existing permissions found - starting fresh');
        // First time user - start from location intro
        emit(
          state.copyWith(
            currentStep: 1,
            navSignal: PermissionNavigationSignal.toLocationIntro,
          ),
        );
      },
      (status) {
        if (status != null && status.hasCompletedFlow) {
          // User has completed flow before - go directly to home
          emit(
            state.copyWith(
              locationStatus: _mapStringToLocationStatus(status.locationStatus),
              notificationStatus: _mapStringToNotificationStatus(
                status.notificationStatus,
              ),
              fcmToken: status.fcmToken,
              hasCompletedFlow: status.hasCompletedFlow,
              userPosition: status.hasLocation
                  ? _createPosition(status.latitude!, status.longitude!)
                  : null,
              currentStep: 4,
              isCompleted: true,
              navSignal: PermissionNavigationSignal.toHome,
            ),
          );
          logger.i('User has completed flow before - skipping to home');
        } else {
          // User exists but hasn't completed - start from beginning
          emit(
            state.copyWith(
              currentStep: 1,
              navSignal: PermissionNavigationSignal.toLocationIntro,
            ),
          );
          logger.i(
            'Loaded existing permissions but not completed - starting fresh',
          );
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // LOCATION PERMISSION FLOW
  // ════════════════════════════════════════════════════════

  /// User clicked "Allow" on Location Intro screen
  /// This shows rationale has been displayed
  Future<void> requestLocationPermission() async {
    logger.i('User requested location permission (rationale shown)');

    emit(state.copyWith(isRequestingLocation: true, errorMessage: null));

    try {
      // Request permission
      final statusResult = await repository.requestLocationPermission();

      await statusResult.fold(
        (failure) {
          logger.e('Location permission request failed: ${failure.message}');
          emit(
            state.copyWith(
              isRequestingLocation: false,
              locationStatus: LocationPermissionStatus.error,
              errorMessage: failure.message,
              navSignal: PermissionNavigationSignal.toLocationError,
            ),
          );
        },
        (status) async {
          logger.i('Location permission status: $status');

          // Update state with permission status
          emit(
            state.copyWith(isRequestingLocation: false, locationStatus: status),
          );

          // Handle different permission statuses
          if (status == LocationPermissionStatus.granted ||
              status == LocationPermissionStatus.grantedLimited) {
            // ✅ FIXED: Try to fetch position with proper error handling
            final positionFetched = await _fetchCurrentPositionWithValidation();

            if (positionFetched) {
              // Success! Go to map screen
              logger.i('✅ Position fetched successfully, navigating to map');
              emit(
                state.copyWith(
                  currentStep: 2,
                  navSignal: PermissionNavigationSignal.toLocationMap,
                ),
              );
            } else {
              // ⚠️ Permission granted but position fetch failed
              logger.w('⚠️ Permission granted but failed to get position');
              emit(
                state.copyWith(
                  errorMessage: 'تعذر تحديد موقعك الحالي. تأكد من تفعيل GPS',
                  navSignal: PermissionNavigationSignal.toLocationError,
                ),
              );
            }
          } else if (status == LocationPermissionStatus.serviceDisabled) {
            // GPS is turned off
            logger.w('Location service disabled');
            emit(
              state.copyWith(
                errorMessage: 'يرجى تفعيل خدمة الموقع (GPS) من إعدادات الجهاز',
                navSignal: PermissionNavigationSignal.toLocationError,
              ),
            );
          } else {
            // Permission denied (temporary or permanent), skip to notification
            logger.w('Location denied, skipping to notification');
            emit(
              state.copyWith(
                currentStep: 3,
                navSignal: PermissionNavigationSignal.toNotificationIntro,
              ),
            );
          }
        },
      );
    } catch (e) {
      logger.e('Unexpected error requesting location: $e');
      emit(
        state.copyWith(
          isRequestingLocation: false,
          locationStatus: LocationPermissionStatus.error,
          errorMessage: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
          navSignal: PermissionNavigationSignal.toLocationError,
        ),
      );
    }
  }

  /// ✅ NEW: Fetch current position with proper validation
  /// Returns true if position was successfully fetched, false otherwise
  Future<bool> _fetchCurrentPositionWithValidation() async {
    logger.d('Fetching current position with validation...');

    // First check if location service is enabled
    final serviceResult = await repository.checkLocationServiceEnabled();
    final serviceEnabled = serviceResult.fold((failure) {
      logger.e('Failed to check location service: ${failure.message}');
      return false;
    }, (enabled) => enabled);

    if (!serviceEnabled) {
      logger.w('Location service is disabled');
      return false;
    }

    // Try to get current position
    final positionResult = await repository.getCurrentPosition();

    return positionResult.fold(
      (failure) {
        logger.e('Failed to get position: ${failure.message}');
        return false;
      },
      (position) {
        logger.i(
          '✅ Position fetched: ${position.latitude}, ${position.longitude}',
        );
        emit(state.copyWith(userPosition: position));
        // Fetch address for this position
        getAddressFromCoordinates(position.latitude, position.longitude);
        return true;
      },
    );
  }

  /// ✅ NEW: Check status when returning from settings
  /// Logic:
  /// 1. Check GPS -> If OFF, do nothing (stay on error page)
  /// 2. If GPS ON -> Check Permission
  /// 3. If Permission GRANTED -> Go to Map
  /// 4. If Permission DENIED -> Request it (or stay on error page)
  Future<void> checkLocationStatusOnResume() async {
    logger.d('Checking location status on app resume...');

    // 1. Show loading indicator immediately
    emit(state.copyWith(isRequestingLocation: true, errorMessage: null));

    // Add artificial delay for better UX (so user sees the checking process)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 2. Check GPS Service
    final serviceResult = await repository.checkLocationServiceEnabled();

    bool isGpsEnabled = false;
    serviceResult.fold(
      (failure) => logger.w('Failed to check GPS: ${failure.message}'),
      (enabled) => isGpsEnabled = enabled,
    );

    if (!isGpsEnabled) {
      logger.d('GPS still disabled on resume');
      // Stop loading, show error again
      emit(state.copyWith(isRequestingLocation: false));
      return;
    }

    // 3. GPS is ON - Check Permission Status
    final permissionResult = await repository.getPermissionStatus();

    permissionResult.fold(
      (failure) {
        logger.w('Failed to check permission on resume');
        emit(state.copyWith(isRequestingLocation: false));
      },
      (status) async {
        final locStatus = _mapStringToLocationStatus(status?.locationStatus);

        if (locStatus == LocationPermissionStatus.granted ||
            locStatus == LocationPermissionStatus.grantedLimited) {
          logger.i('✅ GPS ON + Permission GRANTED on resume');

          // Try to get position
          final positionFetched = await _fetchCurrentPositionWithValidation();

          if (positionFetched) {
            emit(
              state.copyWith(
                isRequestingLocation: false, // Stop loading
                currentStep: 2,
                navSignal: PermissionNavigationSignal.toLocationMap,
                errorMessage: null,
              ),
            );
          } else {
            emit(state.copyWith(isRequestingLocation: false));
          }
        } else {
          // GPS Enabled but Permission Missing
          if (state.locationStatus ==
              LocationPermissionStatus.serviceDisabled) {
            logger.i('GPS enabled, retrying permission...');
            // Retry handles its own loading state
            retryLocationPermission();
          } else {
            emit(state.copyWith(isRequestingLocation: false));
          }
        }
      },
    );
  }

  /// User confirmed location on map (clicked "تحديد الموقع")
  void confirmLocation() {
    logger.i('User confirmed location');
    // Ensure we have a valid signal to navigate
    emit(
      state.copyWith(
        currentStep: 3,
        navSignal: PermissionNavigationSignal.toNotificationIntro,
      ),
    );
  }

  /// ✅ BEST SOLUTION: Direct Google Geocoding API call
  /// Uses HTTP request to guarantee API Key usage
  /// Falls back to native geocoding if API fails
  /// ✅ ENHANCED: Get clean Arabic address without Plus Codes
  /// This method should REPLACE the existing getAddressFromCoordinates method
  Future<void> getAddressFromCoordinates(double lat, double lng) async {
    const String apiKey = 'AIzaSyDASWTQo7hITM4HU58rRzRw4ha3Mma1qAE';

    try {
      logger.d('🔍 Getting clean address via Google API for: $lat, $lng');

      // ✅ FIX: Add result_type to exclude Plus Codes
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$lat,$lng'
          '&key=$apiKey'
          '&language=ar' // Request Arabic address
          '&result_type=street_address|route|neighborhood|locality'; // ✅ Skip Plus Codes

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        logger.d('📡 API Response Status: ${data['status']}');

        if (data['status'] == 'OK' &&
            data['results'] != null &&
            data['results'].isNotEmpty) {
          String rawAddress = data['results'][0]['formatted_address'];

          // ✅ FIX: Remove Plus Code if it still appears
          String cleanAddress = _removeGooglePlusCode(rawAddress);

          // ✅ FIX: Try to build custom formatted address
          String? customAddress = _buildCustomAddress(data['results'][0]);

          // Use custom address if available, otherwise cleaned address
          final finalAddress = customAddress ?? cleanAddress;

          logger.i('✅ Clean address: $finalAddress');
          emit(state.copyWith(currentAddress: finalAddress));
          return; // Success! Exit early
        } else if (data['status'] == 'ZERO_RESULTS') {
          logger.w('⚠️ No address found for coordinates');
        } else {
          logger.w('⚠️ Geocoding API returned: ${data['status']}');
          if (data['error_message'] != null) {
            logger.e('Error message: ${data['error_message']}');
          }
        }
      } else {
        logger.e('❌ HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('❌ Google API request failed: $e');
    }

    // Method 2: Fallback to native geocoding package
    try {
      logger.d('🔄 Trying native geocoding as fallback...');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Build address from placemark
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        if (addressParts.isNotEmpty) {
          final String address = addressParts.join('، ');
          logger.i('✅ Address found via native geocoding: $address');
          emit(state.copyWith(currentAddress: address));
          return;
        }
      }
    } catch (e) {
      logger.e('❌ Native geocoding also failed: $e');
    }

    // Method 3: Last resort - show coordinates
    logger.w('⚠️ All geocoding methods failed, showing coordinates');
    emit(
      state.copyWith(
        currentAddress:
            'الموقع: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ✅ NEW HELPER METHODS: For Cleaning Addresses
  // ════════════════════════════════════════════════════════

  /// Remove Google Plus Codes from address string
  /// Examples to remove:
  /// - "8RJR+2M7، منشأة عبد الله، الفيوم" → "منشأة عبد الله، الفيوم"
  /// - "GFR2+XYZ، القاهرة" → "القاهرة"
  String _removeGooglePlusCode(String address) {
    // Plus Code pattern: 4-8 characters + "+" + 2-3 characters
    // Examples: 8RJR+2M7, GFR2+XYZ, P27Q+R2
    final plusCodeRegex = RegExp(
      r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,3}[،,]\s*',
      caseSensitive: true,
    );

    String cleaned = address.replaceFirst(plusCodeRegex, '').trim();

    // If nothing was removed, return original
    return cleaned.isNotEmpty ? cleaned : address;
  }

  /// Build a clean address from address components
  /// Priority: [neighborhood/route] - [city] - [governorate]
  String? _buildCustomAddress(Map<String, dynamic> result) {
    try {
      if (result['address_components'] == null) return null;

      String? neighborhood;
      String? route;
      String? locality; // City
      String? adminLevel1; // Governorate
      String? adminLevel2; // Sub-governorate/Markaz

      for (var component in result['address_components']) {
        final types = List<String>.from(component['types'] ?? []);
        final name = component['long_name'] as String?;

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

      // Build address parts
      List<String> parts = [];

      // Add street/neighborhood (most specific)
      if (neighborhood != null && neighborhood.isNotEmpty) {
        parts.add(neighborhood);
      } else if (route != null && route.isNotEmpty) {
        parts.add(route);
      }

      // Add city
      if (locality != null && locality.isNotEmpty) {
        parts.add(locality);
      } else if (adminLevel2 != null && adminLevel2.isNotEmpty) {
        parts.add(adminLevel2);
      }

      // Add governorate (least specific)
      if (adminLevel1 != null && adminLevel1.isNotEmpty) {
        parts.add(adminLevel1);
      }

      // Join with Arabic comma
      if (parts.isNotEmpty) {
        return parts.join('، ');
      }

      return null;
    } catch (e) {
      logger.w('Failed to build custom address: $e');
      return null;
    }
  }

  /// User clicked "استخدم موقعك الحالي" on map
  /// ✅ FIXED: Better error handling
  Future<void> useCurrentLocation() async {
    logger.i('User wants to use current location');

    emit(state.copyWith(isRequestingLocation: true, errorMessage: null));

    final success = await _fetchCurrentPositionWithValidation();

    emit(state.copyWith(isRequestingLocation: false));

    if (success) {
      logger.i('✅ Current location updated successfully');
    } else {
      logger.w('⚠️ Failed to get current location');
      emit(
        state.copyWith(
          errorMessage: 'تعذر تحديد موقعك. تأكد من تفعيل GPS وحاول مرة أخرى',
        ),
      );
    }
  }

  /// User clicked "Try Again" on location error screen
  /// ✅ FIXED: Better logic for retry
  Future<void> retryLocationPermission() async {
    logger.i('User retrying location permission');

    // Clear previous error
    emit(state.copyWith(errorMessage: null));

    // First check if location service (GPS) is enabled
    final serviceResult = await repository.checkLocationServiceEnabled();
    await serviceResult.fold(
      (failure) {
        logger.e('Failed to check location service: ${failure.message}');
        emit(
          state.copyWith(
            errorMessage: 'تعذر التحقق من حالة GPS',
            navSignal: PermissionNavigationSignal.toLocationError,
          ),
        );
      },
      (serviceEnabled) async {
        if (!serviceEnabled) {
          logger.w('Location service is disabled, opening location settings');
          // First show error page
          emit(
            state.copyWith(
              locationStatus: LocationPermissionStatus.serviceDisabled,
              errorMessage:
                  'يرجى تفعيل خدمة الموقع (GPS) من إعدادات الجهاز ثم ارجع للتطبيق',
              navSignal: PermissionNavigationSignal.toLocationError,
            ),
          );
          // Then open settings after a short delay (so error page shows first)
          await Future.delayed(const Duration(milliseconds: 500));
          await _openLocationSettings();
          return;
        }

        // GPS is enabled, check permission status
        final currentStatus = state.locationStatus;

        if (currentStatus == LocationPermissionStatus.permanentlyDenied) {
          // Permanently denied - must open settings
          logger.w('Location permanently denied, opening app settings');
          await _openLocationSettings();
        } else if (currentStatus == LocationPermissionStatus.granted ||
            currentStatus == LocationPermissionStatus.grantedLimited) {
          // Permission already granted, just retry fetching position
          logger.i('Permission already granted, retrying position fetch');
          emit(state.copyWith(isRequestingLocation: true));

          final success = await _fetchCurrentPositionWithValidation();

          emit(state.copyWith(isRequestingLocation: false));

          if (success) {
            // Success! Go to map
            emit(
              state.copyWith(
                currentStep: 2,
                navSignal: PermissionNavigationSignal.toLocationMap,
              ),
            );
          } else {
            // Still failed
            emit(
              state.copyWith(
                errorMessage: 'تعذر تحديد موقعك. تأكد من وجود إشارة GPS قوية',
                navSignal: PermissionNavigationSignal.toLocationError,
              ),
            );
          }
        } else {
          // Permission not granted or denied - request again
          logger.i('Requesting permission again directly (skip intro)');
          // Request permission directly instead of going back to intro
          // This keeps the user on the error page (loading state) until decision
          await requestLocationPermission();
        }
      },
    );
  }

  /// Open location settings (for GPS disabled or permanently denied)
  /// ✅ FIXED: Use correct settings based on issue type
  Future<void> _openLocationSettings() async {
    // Check what type of issue we have
    final isPermanentlyDenied = state.isLocationPermanentlyDenied;
    final isServiceDisabled =
        state.locationStatus == LocationPermissionStatus.serviceDisabled;

    if (isServiceDisabled) {
      // GPS is off - open device location settings
      logger.i('Opening device location settings (GPS settings)');
      final result = await repository.openLocationSettings();

      result.fold(
        (failure) {
          logger.e('Failed to open location settings: ${failure.message}');
          emit(state.copyWith(errorMessage: 'تعذر فتح الإعدادات'));
        },
        (opened) {
          if (opened) {
            logger.i('Opened location settings successfully');
            emit(
              state.copyWith(
                errorMessage:
                    'بعد تفعيل GPS، ارجع للتطبيق واضغط محاولة مرة أخرى',
              ),
            );
          } else {
            logger.w('Could not open location settings');
            emit(
              state.copyWith(
                errorMessage:
                    'تعذر فتح الإعدادات. افتح إعدادات الجهاز يدوياً وفعّل الموقع',
              ),
            );
          }
        },
      );
    } else if (isPermanentlyDenied) {
      // Permission permanently denied - open app settings
      logger.i('Opening app settings for location permission');
      final result = await repository.openAppSettings();

      result.fold(
        (failure) {
          logger.e('Failed to open app settings: ${failure.message}');
          emit(state.copyWith(errorMessage: 'تعذر فتح إعدادات التطبيق'));
        },
        (opened) {
          if (opened) {
            logger.i('Opened app settings successfully');
            emit(
              state.copyWith(
                errorMessage:
                    'بعد السماح بالموقع، ارجع للتطبيق واضغط محاولة مرة أخرى',
              ),
            );
          } else {
            logger.w('Could not open app settings');
            emit(
              state.copyWith(
                errorMessage:
                    'تعذر فتح الإعدادات. افتح إعدادات الجهاز يدوياً وامنح التطبيق إذن الموقع',
              ),
            );
          }
        },
      );
    }
  }

  // ════════════════════════════════════════════════════════
  // NOTIFICATION PERMISSION FLOW
  // ════════════════════════════════════════════════════════

  /// User clicked "Allow" on Notification Intro screen
  /// This shows rationale has been displayed
  Future<void> requestNotificationPermission() async {
    logger.i('User requested notification permission (rationale shown)');

    emit(state.copyWith(isRequestingNotification: true, errorMessage: null));

    try {
      // Request permission
      final statusResult = await repository.requestNotificationPermission();

      await statusResult.fold(
        (failure) {
          logger.e(
            'Notification permission request failed: ${failure.message}',
          );
          emit(
            state.copyWith(
              isRequestingNotification: false,
              notificationStatus: NotificationPermissionStatus.error,
              errorMessage: failure.message,
            ),
          );
        },
        (status) async {
          logger.i('Notification permission status: $status');

          // Get FCM token if granted
          String? fcmToken;
          if (status == NotificationPermissionStatus.granted ||
              status == NotificationPermissionStatus.provisional) {
            // Initialize listeners for foreground/background messages
            notificationService.initializeListeners();

            final tokenResult = await repository.getFCMToken();
            tokenResult.fold((failure) => logger.w('Failed to get FCM token'), (
              token,
            ) {
              fcmToken = token;
              logger.i('FCM Token: ${token?.substring(0, 20)}...');
            });
          }

          // Update state
          emit(
            state.copyWith(
              isRequestingNotification: false,
              notificationStatus: status,
              fcmToken: fcmToken,
            ),
          );

          // Always proceed to loading, regardless of grant/deny
          await _completeFlow();
        },
      );
    } catch (e) {
      logger.e('Unexpected error requesting notification: $e');
      emit(
        state.copyWith(
          isRequestingNotification: false,
          notificationStatus: NotificationPermissionStatus.error,
          errorMessage: 'حدث خطأ غير متوقع',
        ),
      );
    }
  }

  /// User clicked "Try Again" on notification error screen
  Future<void> retryNotificationPermission() async {
    logger.i('User retrying notification permission');

    // Check if permanently denied
    if (state.isNotificationPermanentlyDenied) {
      logger.w('Notification permanently denied, opening settings');
      await _openNotificationSettings();
    } else {
      // Try again
      await requestNotificationPermission();
    }
  }

  /// Open notification settings (last resort)
  Future<void> _openNotificationSettings() async {
    final result = await repository.openNotificationSettings();

    result.fold(
      (failure) {
        logger.e('Failed to open notification settings: ${failure.message}');
        emit(state.copyWith(errorMessage: 'تعذر فتح الإعدادات'));
      },
      (opened) {
        if (opened) {
          logger.i('Opened notification settings');
        } else {
          logger.w('Could not open notification settings');
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // SKIP FUNCTIONALITY
  // ════════════════════════════════════════════════════════

  /// Skip current step (location or notification)
  void skipCurrentStep() {
    logger.i('User skipped step ${state.currentStep}');

    if (state.currentStep == 1 || state.currentStep == 2) {
      // Skip location → go to notification
      emit(
        state.copyWith(
          currentStep: 3,
          navSignal: PermissionNavigationSignal.toNotificationIntro,
        ),
      );
    } else if (state.currentStep == 3) {
      // Skip notification → complete flow
      _completeFlow();
    }
  }

  /// Skip entire flow (from any step)
  void skipEntireFlow() {
    logger.i('User skipped entire permission flow');
    emit(
      state.copyWith(
        isSkipped: true,
        isCompleted: true,
        navSignal: PermissionNavigationSignal.toHome,
      ),
    );

    // Mark as completed to avoid showing again
    repository.savePermissionStatus(hasCompletedFlow: true);
  }

  // ════════════════════════════════════════════════════════
  // FLOW COMPLETION
  // ════════════════════════════════════════════════════════

  /// Complete the permission flow
  Future<void> _completeFlow() async {
    logger.i('Completing permission flow...');

    // Go to loading screen
    emit(
      state.copyWith(
        currentStep: 4,
        navSignal: PermissionNavigationSignal.toLoading,
      ),
    );

    // Simulate loading progress (for nice UX)
    await _simulateLoading();

    // Mark as completed
    await repository.savePermissionStatus(hasCompletedFlow: true);

    emit(
      state.copyWith(
        isCompleted: true,
        hasCompletedFlow: true,
        navSignal: PermissionNavigationSignal.toHome,
      ),
    );

    logger.i('Permission flow completed');
  }

  /// Simulate loading progress for better UX
  Future<void> _simulateLoading() async {
    // Step 1: Checking permissions (33%)
    emit(state.copyWith(loadingProgress: 0.33));
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 2: Loading data (66%)
    emit(state.copyWith(loadingProgress: 0.66));
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 3: Almost there (100%)
    emit(state.copyWith(loadingProgress: 1.0));
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION HELPERS
  // ════════════════════════════════════════════════════════

  /// Go to specific step manually (if needed)
  void goToStep(int step) {
    if (step >= 1 && step <= 4) {
      PermissionNavigationSignal signal = PermissionNavigationSignal.none;
      switch (step) {
        case 1:
          signal = PermissionNavigationSignal.toLocationIntro;
          break;
        case 2:
          signal = PermissionNavigationSignal.toLocationMap;
          break;
        case 3:
          signal = PermissionNavigationSignal.toNotificationIntro;
          break;
        case 4:
          signal = PermissionNavigationSignal.toLoading;
          break;
      }

      emit(state.copyWith(currentStep: step, navSignal: signal));
      logger.d('Navigated to step $step with signal $signal');
    }
  }

  /// Clear the navigation signal after it has been handled by UI
  void clearNavigationSignal() {
    emit(state.copyWith(navSignal: PermissionNavigationSignal.none));
  }

  /// Reset the entire flow (for testing)
  Future<void> resetFlow() async {
    await repository.clearPermissionStatus();
    emit(const PermissionFlowState());
    logger.i('Permission flow reset');
  }

  // ════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════

  /// Create Position object from lat/lng (for loading from Hive)
  dynamic _createPosition(double latitude, double longitude) {
    // Note: Geolocator Position requires more fields
    // This is simplified for state management
    // In real usage, we just store lat/lng separately
    return null; // We'll handle this in UI layer
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  // ════════════════════════════════════════════════════════
  // MAPPING HELPERS
  // ════════════════════════════════════════════════════════

  LocationPermissionStatus _mapStringToLocationStatus(String? status) {
    if (status == null) return LocationPermissionStatus.notRequested;
    switch (status) {
      case 'granted':
        return LocationPermissionStatus.granted;
      case 'limited':
        return LocationPermissionStatus.grantedLimited;
      case 'denied':
        return LocationPermissionStatus.denied;
      case 'permanently_denied':
        return LocationPermissionStatus.permanentlyDenied;
      case 'service_disabled':
        return LocationPermissionStatus.serviceDisabled;
      default:
        return LocationPermissionStatus.error;
    }
  }

  NotificationPermissionStatus _mapStringToNotificationStatus(String? status) {
    if (status == null) return NotificationPermissionStatus.notRequested;
    switch (status) {
      case 'granted':
        return NotificationPermissionStatus.granted;
      case 'provisional':
        return NotificationPermissionStatus.provisional;
      case 'denied':
        return NotificationPermissionStatus.denied;
      case 'not_requested':
        return NotificationPermissionStatus.notRequested;
      default:
        return NotificationPermissionStatus.error;
    }
  }
}
