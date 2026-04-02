import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/network/network_info.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupony/features/permissions/presentation/cubit/permission_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../../config/dependency_injection/injection_container.dart';

/// Location Map Page
/// Shows map with user's current location
/// Allows confirming or updating location
///
/// ✅ Works with PermissionFlowWrapper for navigation
/// ✅ No manual navigation - Wrapper handles it
/// ✅ Properly loads and displays user position
class LocationMapPage extends StatefulWidget {
  const LocationMapPage({super.key});

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Default location (Cairo - will be replaced with actual location)
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  LatLng? _currentLocation;
  bool _isMapReady = false;
  bool _isMapLoading = true;
  bool _hasNetwork = true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _checkNetworkAndLoad();
  }

  Future<void> _checkNetworkAndLoad() async {
    final networkInfo = sl<NetworkInfo>();
    final connected = await networkInfo.isConnected;
    if (mounted) {
      setState(() {
        _hasNetwork = connected;
        // No network → no tiles → no onCameraIdle → stop loading immediately
        if (!connected) _isMapLoading = false;
      });
    }
    // Load user position regardless of network
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPosition();
    });
  }

  /// Load user's actual position from Cubit state
  void _loadUserPosition() {
    final state = context.read<PermissionFlowCubit>().state;

    if (state.userPosition != null) {
      final position = state.userPosition!;

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Move camera to user's location when map is ready
      if (_isMapReady && _mapController != null) {
        _moveCameraToPosition(_currentLocation!);
      }

      debugPrint(
        '📍 User position loaded: ${position.latitude}, ${position.longitude}',
      );
    } else {
      debugPrint('⚠️ No user position in state - using default location');
      // Try to fetch position
      context.read<PermissionFlowCubit>().useCurrentLocation();
    }
  }

  /// Move camera to specific position
  void _moveCameraToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
  }

  /// ✅ NEW: Search for location using geocoding
  Future<void> _searchLocation(String query) async {
    try {
      debugPrint('🔍 Searching for: $query');

      // Use geocoding package to search
      final locations = await locationFromAddress(query);

      if (!mounted) return;

      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _currentLocation = newPosition;
        });

        _moveCameraToPosition(newPosition);

        // Get address for this position and update cubit
        context.read<PermissionFlowCubit>().getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );

        debugPrint(
          '✅ Found location: ${location.latitude}, ${location.longitude}',
        );
      } else {
        debugPrint('⚠️ No results found for: $query');
        // Show snackbar
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          context.showErrorSnackBar(l10n.location_map_no_results);
        }
      }
    } catch (e) {
      debugPrint('❌ Search error: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        // ✅ IMPROVED ERROR HANDLING: Show user-friendly error message
        context.showErrorSnackBar(
          l10n.location_map_search_error,
        );
      }
    }
  }

  /// ✅ Voice Search using Speech to Text
  Future<void> _startListening() async {
    try {
      bool available = await _speech.initialize(
        onError: (error) {
          debugPrint('❌ Speech error: $error');
          setState(() => _isListening = false);
        },
        onStatus: (status) {
          debugPrint('🎤 Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);

        await _speech.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
            });

            // If speech is finalized, search automatically
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _searchLocation(result.recognizedWords);
              _speech.stop();
              setState(() => _isListening = false);
            }
          },
          localeId: 'ar_EG', // Arabic locale
        );
      } else {
        debugPrint('⚠️ Speech recognition not available');
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          context.showWarningSnackBar(l10n.location_map_voice_unavailable);
        }
      }
    } catch (e) {
      debugPrint('❌ Voice search error: $e');
      setState(() => _isListening = false);
    }
  }

  /// Stop listening
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocListener<PermissionFlowCubit, PermissionFlowState>(
        listener: (context, state) {
          // ✅ Phase 1 Fix: All navigation driven by navSignal only.
          // Never call context.go() inline after cubit calls — that causes
          // the "route._navigator == navigator" assertion crash.
          if (state.navSignal ==
              PermissionNavigationSignal.toNotificationIntro) {
            context.go(AppRouter.permissionNotificationIntro);
            context.read<PermissionFlowCubit>().clearNavigationSignal();
          } else if (state.navSignal ==
              PermissionNavigationSignal.toLocationIntro) {
            context.go(AppRouter.permissionLocationIntro);
            context.read<PermissionFlowCubit>().clearNavigationSignal();
          } else if (state.navSignal ==
              PermissionNavigationSignal.toOnboarding) {
            context.go(AppRouter.onboarding);
            context.read<PermissionFlowCubit>().clearNavigationSignal();
          }
        },
        child: Stack(
          children: [
          // ✅ Google Map
          BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
            builder: (context, state) {
              // Get location from state or use current/default
              final position = state.userPosition;
              final LatLng mapCenter =
                  _currentLocation ??
                  (position != null
                      ? LatLng(position.latitude, position.longitude)
                      : _defaultLocation);

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: mapCenter,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  
                  // ✅ PERFORMANCE FIX: Hide loading immediately when map is ready
                  // Using onMapCreated instead of onCameraIdle eliminates 5+ second delay
                  setState(() {
                    _isMapReady = true;
                    _isMapLoading = false; // Hide loading overlay immediately
                  });

                  debugPrint('✅ Google Map Controller created - Loading complete');

                  // Move to user position if we have it
                  if (_currentLocation != null) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) _moveCameraToPosition(_currentLocation!);
                    });
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: {
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: mapCenter,
                    infoWindow: InfoWindow(
                      title: AppLocalizations.of(context)!.location_map_current_location_marker,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange,
                    ),
                  ),
                },
                onTap: (position) {
                  // Allow user to tap and change location
                  setState(() {
                    _currentLocation = position;
                  });

                  // Fetch address for tapped position
                  context.read<PermissionFlowCubit>().getAddressFromCoordinates(
                    position.latitude,
                    position.longitude,
                  );

                  debugPrint(
                    '📍 User tapped new location: ${position.latitude}, ${position.longitude}',
                  );
                },
              );
            },
          ),

          // ✅ Map Loading Indicator - shown until map is fully rendered
          if (_isMapLoading)
            Positioned.fill(
              child: Container(
                color: AppColors.surface,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          // ✅ No Network Banner
          if (!_hasNetwork)
            PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 80.h,
              start: 16.w,
              end: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off, color: AppColors.surface, size: 18.w),
                    SizedBox(width: 8.w),
                    Text(
                      AppLocalizations.of(context)!.networkError,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ✅ Top Search Bar - Exact Original Design
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 16.h,
            start: 16.w,
            end: 16.w,
            child: Row(
              children: [
                // 1. Orange Location Icon (Left Side)
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.surface,
                    size: 22.w,
                  ),
                ),

                SizedBox(width: 12.w),

                // 2. Search Box (Center - Full Width) - LAYERED STRUCTURE
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 55.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.grey200,
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Search Icon (Left - Functional) - ON TOP LAYER
                        GestureDetector(
                          onTap: () {
                            if (_searchController.text.trim().isNotEmpty) {
                              _searchLocation(_searchController.text.trim());
                              FocusScope.of(context).unfocus();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Icon(
                              Icons.search,
                              color: AppColors.grey600,
                              size: 22.w,
                            ),
                          ),
                        ),

                        // Search TextField (Center) - EXPANDED TO PREVENT ICON OVERFLOW
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey800,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.location_map_search_placeholder,
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey600,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 16.h,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _searchLocation(value.trim());
                              }
                            },
                          ),
                        ),

                        // Microphone Icon (Right - Functional) - ON TOP LAYER
                        GestureDetector(
                          onTap: () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? Theme.of(context).primaryColor
                                  : AppColors.grey600,
                              size: 22.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // 3. Back Button (Right Side)
                GestureDetector(
                  onTap: () {
                    // Navigate back to previous screen
                    context.go(AppRouter.permissionLocationIntro);
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.grey800,
                      size: 18.w,
                    ),
                  ),
                ),
              ],
            ),
          ),



          // ✅ Use Current Location Button (Orange - On Map)
          PositionedDirectional(
            bottom: 240.h, // Above bottom sheet
            start: 0,
            end: 0,
            child: Center(
              child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: state.isRequestingLocation
                        ? null
                        : () async {
                            // ✅ FIX: Capture cubit before async gap
                            final cubit = context.read<PermissionFlowCubit>();
                            
                            await cubit.useCurrentLocation();

                            if (!mounted) return;

                            // Move camera to updated position
                            final updatedState = cubit.state;
                            if (updatedState.userPosition != null) {
                              final pos = updatedState.userPosition!;
                              final newLocation = LatLng(
                                pos.latitude,
                                pos.longitude,
                              );

                              setState(() {
                                _currentLocation = newLocation;
                              });

                              _moveCameraToPosition(newLocation);
                            }
                          },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.location_map_use_current,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.surface,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (state.isRequestingLocation)
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.surface,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.my_location,
                              color: AppColors.surface,
                              size: 20.w,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ✅ Bottom Sheet
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(10.w, 20.h, 20.w, 10.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, -4.h),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
                  builder: (context, state) {
                    final position = state.userPosition;
                    final hasPosition =
                        position != null || _currentLocation != null;
                    final displayLocation =
                        _currentLocation ??
                        (position != null
                            ? LatLng(position.latitude, position.longitude)
                            : null);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Label with Icon
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                              size: 22.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              AppLocalizations.of(context)!.location_map_your_location,
                              style: AppTextStyles.h4.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Address
                        Padding(
                          padding: EdgeInsetsDirectional.only(end: 30.w),
                          child: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                state.currentAddress ??
                                    (displayLocation != null
                                        ? l10n.location_map_coordinates_format(
                                            displayLocation.latitude.toStringAsFixed(4),
                                            displayLocation.longitude.toStringAsFixed(4),
                                          )
                                        : l10n.location_map_tap_to_select),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Confirm Button
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return AppPrimaryButton(
                              text: l10n.location_map_confirm_button,
                              onPressed: hasPosition
                                  ? () {
                                      // ✅ FIX: Let the cubit emit the navSignal.
                                      // The BlocListener below handles navigation.
                                      // Do NOT call context.go() here — that causes
                                      // the "route._navigator == navigator" assertion crash.
                                      debugPrint('✅ Location confirmed');
                                      context
                                          .read<PermissionFlowCubit>()
                                          .confirmLocation();
                                    }
                                  : null,
                              size: AppButtonSize.medium,
                              borderRadius: 12.r,
                              disabledBackgroundColor: AppColors.textDisabled,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
