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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../../config/dependency_injection/injection_container.dart';

/// Location Map Page — Center-Pin / Crosshair UX
///
/// Architecture guarantees:
///   • GoogleMap is NOT inside any BlocBuilder — platform view never recreates.
///   • Camera movements drive geocoding via onCameraIdle.
///   • A static center-pin overlay replaces tap-to-place markers.
///   • Bottom sheet and "use location" button use tight buildWhen predicates.
///   • Navigation to map is immediate after permission grant (async gate fix).
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

  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357); // Cairo

  bool _isMapReady = false;
  bool _isMapLoading = true;
  bool _hasNetwork = true;

  /// Tracks the camera's current center — updated on every onCameraMove.
  LatLng _lastCameraCenter = _defaultLocation;

  /// The confirmed camera-center when the camera becomes idle.
  LatLng? _selectedLatLng;

  /// True while the camera is moving OR while a geocoding request is in-flight.
  /// Used to show an address-loading shimmer in the bottom sheet.
  bool _isAddressLoading = false;

  /// Prevents animating to GPS position more than once on first arrival.
  bool _hasCenteredOnGps = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialPosition();
    });
  }

  Future<void> _loadInitialPosition() async {
    // Start with loading state
    setState(() => _isMapLoading = true);

    // Check network first
    final networkInfo = sl<NetworkInfo>();
    final connected = await networkInfo.isConnected;
    
    if (!mounted) return;
    
    setState(() => _hasNetwork = connected);
    
    if (!connected) {
      setState(() => _isMapLoading = false);
      return;
    }

    try {
      // Check if position already exists in cubit
      final position = context.read<PermissionFlowCubit>().state.userPosition;
      
      if (position != null) {
        // Position already available
        if (mounted) {
          final newLocation = LatLng(position.latitude, position.longitude);
          setState(() {
            _lastCameraCenter = newLocation;
            _isMapLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      print('❌ Error loading initial position: $e');
    }

    // Fallback: use default location
    if (mounted) {
      setState(() => _isMapLoading = false);
    }
  }

  void _moveCameraToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (!mounted) return;

      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);
        _moveCameraToPosition(newPosition);
      } else {
        context.showErrorSnackBar(
          AppLocalizations.of(context)!.location_map_no_results,
        );
      }
    } catch (_) {
      if (mounted) {
        context.showErrorSnackBar(
          AppLocalizations.of(context)!.location_map_search_error,
        );
      }
    }
  }

  Future<void> _startListening() async {
    try {
      final available = await _speech.initialize(
        onError: (_) => setState(() => _isListening = false),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() => _searchController.text = result.recognizedWords);
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _searchLocation(result.recognizedWords);
              _speech.stop();
              setState(() => _isListening = false);
            }
          },
          localeId: 'ar_EG',
        );
      } else {
        if (mounted) {
          context.showWarningSnackBar(
            AppLocalizations.of(context)!.location_map_voice_unavailable,
          );
        }
      }
    } catch (_) {
      setState(() => _isListening = false);
    }
  }

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
        // Only listen to events we actually act on — avoids unnecessary listener calls.
        listenWhen: (prev, curr) {
          if (prev.navSignal != curr.navSignal) return true;
          // First GPS position arrival → animate camera
          if (prev.userPosition == null && curr.userPosition != null) return true;
          // Address updated → dismiss shimmer
          if (prev.currentAddress != curr.currentAddress) return true;
          return false;
        },
        listener: (context, state) {
          // ── Navigation signals ──────────────────────────────
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

          // ── GPS position arrived for the first time ─────────
          if (state.userPosition != null &&
              _isMapReady &&
              !_hasCenteredOnGps) {
            _hasCenteredOnGps = true;
            final pos = state.userPosition!;
            final initialPosition = LatLng(pos.latitude, pos.longitude);
            _moveCameraToPosition(initialPosition);
            
            // Explicitly fetch address for initial position
            setState(() {
              _selectedLatLng = initialPosition;
              _isAddressLoading = true;
            });
            context.read<PermissionFlowCubit>().getAddressFromCoordinates(
              pos.latitude,
              pos.longitude,
            );
            
            // Safety timeout: stop loading after 10 seconds if no response
            Future.delayed(const Duration(seconds: 10), () {
              if (mounted && _isAddressLoading) {
                setState(() => _isAddressLoading = false);
              }
            });
          }

          // ── Address result arrived → dismiss shimmer ────────
          if (state.currentAddress != null && _isAddressLoading) {
            setState(() => _isAddressLoading = false);
          }
        },
        child: Stack(
          children: [
            // ── Google Map (Hidden while loading) ─────────────
            // Not wrapped in any BlocBuilder: its params are static after
            // construction. Camera is moved imperatively via _mapController.
            if (!_isMapLoading)
              GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _lastCameraCenter,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() {
                  _isMapReady = true;
                  _isMapLoading = false;
                });

                // If GPS position already arrived before map was ready, jump to it.
                if (!_hasCenteredOnGps) {
                  final pos = context
                      .read<PermissionFlowCubit>()
                      .state
                      .userPosition;
                  if (pos != null) {
                    _hasCenteredOnGps = true;
                    final initialPosition = LatLng(pos.latitude, pos.longitude);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) {
                        _moveCameraToPosition(initialPosition);
                        
                        // Explicitly fetch address for initial position
                        setState(() {
                          _selectedLatLng = initialPosition;
                          _isAddressLoading = true;
                        });
                        context.read<PermissionFlowCubit>().getAddressFromCoordinates(
                          pos.latitude,
                          pos.longitude,
                        );
                        
                        // Safety timeout: stop loading after 10 seconds if no response
                        Future.delayed(const Duration(seconds: 10), () {
                          if (mounted && _isAddressLoading) {
                            setState(() => _isAddressLoading = false);
                          }
                        });
                      }
                    });
                  }
                }
              },
              // ── Center-Pin pattern: track camera center instead of taps ──
              onCameraMove: (CameraPosition pos) {
                _lastCameraCenter = pos.target;
                if (!_isAddressLoading) {
                  setState(() => _isAddressLoading = true);
                }
              },
              onCameraIdle: () {
                setState(() {
                  _selectedLatLng = _lastCameraCenter;
                  // Keep _isAddressLoading = true until geocoding completes
                });
                context.read<PermissionFlowCubit>().getAddressFromCoordinates(
                  _lastCameraCenter.latitude,
                  _lastCameraCenter.longitude,
                );
                
                // Safety timeout: stop loading after 10 seconds if no response
                Future.delayed(const Duration(seconds: 10), () {
                  if (mounted && _isAddressLoading) {
                    setState(() => _isAddressLoading = false);
                  }
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              // No markers — the static crosshair overlay is the pin.
            ),

            // ── Static Center-Pin (crosshair overlay) ─────────
            // Always at the exact screen center regardless of map movements.
            if (_isMapReady && !_isMapLoading)
              Align(
                alignment: Alignment.center,
                child: Padding(
                  // Offset upward by half the icon height so the pin tip
                  // points at the exact center pixel.
                  padding: EdgeInsets.only(bottom: 36.h),
                  child: Icon(
                    Icons.location_pin,
                    color: Theme.of(context).primaryColor,
                    size: 48.w,
                    shadows: [
                      Shadow(
                        color: AppColors.shadow.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Map Loading Overlay ───────────────────────────
            if (_isMapLoading)
              Positioned.fill(
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading Icon
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.locationCrosshairs,
                            size: 36.w,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      
                      // Loading Indicator
                      SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3.w,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // Loading Text
                      Text(
                        AppLocalizations.of(context)!.permissions_location_checking,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalizations.of(context)!.permissions_please_wait,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── No Network Banner ─────────────────────────────
            if (!_hasNetwork)
              PositionedDirectional(
                top: MediaQuery.of(context).padding.top + 80.h,
                start: 16.w,
                end: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.wifi, color: AppColors.surface, size: 18.w),
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

            // ── Top Search Bar (Hidden while loading) ─────────
            if (!_isMapLoading)
              PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 16.h,
              start: 16.w,
              end: 16.w,
              child: Row(
                children: [
                  // Orange location icon (with tap functionality)
                  BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
                    buildWhen: (prev, curr) =>
                        prev.isRequestingLocation != curr.isRequestingLocation,
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: state.isRequestingLocation
                            ? null
                            : () async {
                                final cubit = context.read<PermissionFlowCubit>();
                                await cubit.useCurrentLocation();

                                if (!mounted) return;

                                final pos = cubit.state.userPosition;
                                if (pos != null) {
                                  _moveCameraToPosition(
                                    LatLng(pos.latitude, pos.longitude),
                                  );
                                }
                              },
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: state.isRequestingLocation
                              ? Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.surface,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.locationDot,
                                    color: AppColors.surface,
                                    size: 20.w,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  SizedBox(width: 12.w),

                  // Search box
                  Expanded(
                    child: Container(
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
                          // Search icon
                          GestureDetector(
                            onTap: () {
                              if (_searchController.text.trim().isNotEmpty) {
                                _searchLocation(_searchController.text.trim());
                                FocusScope.of(context).unfocus();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  color: AppColors.grey600,
                                  size: 20.w,
                                ),
                              ),
                            ),
                          ),

                          // Search text field
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey800,
                              ),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                )!.location_map_search_placeholder,
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

                          // Microphone icon
                          GestureDetector(
                            onTap: _isListening
                                ? _stopListening
                                : _startListening,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Center(
                                child: FaIcon(
                                  _isListening ? FontAwesomeIcons.microphone : FontAwesomeIcons.microphoneLines,
                                  color: _isListening
                                      ? Theme.of(context).primaryColor
                                      : AppColors.grey600,
                                  size: 20.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Back button
                  GestureDetector(
                    onTap: () => context.go(AppRouter.permissionLocationIntro),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.chevronLeft,
                          color: AppColors.grey800,
                          size: 18.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Sheet ───────────────────────────────────
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
                  // buildWhen: only rebuild when address or position changes.
                  child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
                    buildWhen: (prev, curr) =>
                        prev.currentAddress != curr.currentAddress ||
                        prev.userPosition != curr.userPosition,
                    builder: (context, state) {
                      final hasPosition = _selectedLatLng != null ||
                          state.userPosition != null;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location label
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                color: Theme.of(context).primaryColor,
                                size: 22.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.location_map_your_location,
                                style: AppTextStyles.h4.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Address / shimmer
                          Padding(
                            padding:
                                EdgeInsetsDirectional.only(end: 30.w),
                            child: _isAddressLoading
                                ? _AddressShimmer()
                                : _AddressText(
                                    address: state.currentAddress,
                                    selectedLatLng: _selectedLatLng,
                                  ),
                          ),

                          SizedBox(height: 24.h),

                          // Confirm button
                          AppPrimaryButton(
                            text: AppLocalizations.of(
                              context,
                            )!.location_map_confirm_button,
                            onPressed: hasPosition
                                ? () {
                                    context
                                        .read<PermissionFlowCubit>()
                                        .confirmLocation();
                                  }
                                : null,
                            size: AppButtonSize.medium,
                            borderRadius: 12.r,
                            disabledBackgroundColor: AppColors.textDisabled,
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

// ── Sub-widgets ────────────────────────────────────────────────────────────────

/// Pulsing shimmer shown while geocoding is in-flight.
class _AddressShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16.w,
          height: 16.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Displays the resolved address, or a fallback coordinate string.
class _AddressText extends StatelessWidget {
  final String? address;
  final LatLng? selectedLatLng;

  const _AddressText({this.address, this.selectedLatLng});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final displayText = address ??
        (selectedLatLng != null
            ? l10n.location_map_coordinates_format(
                selectedLatLng!.latitude.toStringAsFixed(4),
                selectedLatLng!.longitude.toStringAsFixed(4),
              )
            : l10n.location_map_tap_to_select);

    return Text(
      displayText,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
