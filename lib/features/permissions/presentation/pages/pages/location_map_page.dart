import 'package:coupon/config/routes/app_router.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_cubit.dart';
import 'package:coupon/features/permissions/presentation/cubit/permission_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../../../core/widgets/buttons/buttons.dart';

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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    // Load user position from state when widget builds
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'لم يتم العثور على نتائج',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Search error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ في البحث',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'البحث الصوتي غير متاح',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.orange,
            ),
          );
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
      backgroundColor: Colors.white,
      body: Stack(
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
                  _isMapReady = true;

                  debugPrint('✅ Google Map Controller created');

                  // Move to user position if we have it
                  if (_currentLocation != null) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _moveCameraToPosition(_currentLocation!);
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
                    infoWindow: const InfoWindow(title: 'موقعك الحالي'),
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

          // ✅ Top Search Bar - Exact Original Design
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            left: 16.w,
            right: 16.w,
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
                    color: Colors.white,
                    size: 22.w,
                  ),
                ),

                SizedBox(width: 12.w),

                // 2. Search Box (Center - Full Width)
                Expanded(
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        // Search Icon (Left inside box)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: 22.w,
                          ),
                        ),

                        // Search TextField (Center)
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Cairo',
                              color: Colors.grey[800],
                            ),
                            decoration: InputDecoration(
                              hintText: 'البحث في المنطقة، اسم الشارع...',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[400],
                                fontFamily: 'Cairo',
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 14.h,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _searchLocation(value.trim());
                              }
                            },
                          ),
                        ),

                        // Microphone Icon (Right inside box)
                        GestureDetector(
                          onTap: () {
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400],
                              size: 22.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // 3. Close/Exit Arrow (Right Side)
                GestureDetector(
                  onTap: () {
                    // Clear search and exit search mode
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                    // Or navigate back if needed
                    // Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[800],
                      size: 18.w,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ My Location Button (Green Circle on Right)
          Positioned(
            right: 16.w,
            top: MediaQuery.of(context).padding.top + 80.h,
            child: BlocBuilder<PermissionFlowCubit, PermissionFlowState>(
              builder: (context, state) {
                return Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7ED957), // Green color from design
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: state.isRequestingLocation
                      ? Padding(
                          padding: EdgeInsets.all(16.w),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            // ✅ FIX: Capture cubit before async gap
                            final cubit = context.read<PermissionFlowCubit>();
                            
                            // Get fresh current location
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
                          icon: Icon(
                            Icons.navigation,
                            color: Colors.white,
                            size: 28.w,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                );
              },
            ),
          ),

          // ✅ Use Current Location Button (Orange - On Map)
          Positioned(
            bottom: 240.h, // Above bottom sheet
            left: 0,
            right: 0,
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
                            'استخدم موقعك الحالي',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Cairo',
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
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.my_location,
                              color: Colors.white,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(10.w, 20.h, 20.w, 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                              'موقعك',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Address
                        Padding(
                          padding: EdgeInsets.only(right: 30.w),
                          child: Text(
                            state.currentAddress ??
                                (displayLocation != null
                                    ? 'خط العرض: ${displayLocation.latitude.toStringAsFixed(4)}, خط الطول: ${displayLocation.longitude.toStringAsFixed(4)}'
                                    : 'اضغط على الخريطة لتحديد موقعك'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                              fontFamily: 'Cairo',
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Confirm Button
                        AppPrimaryButton(
                          text: 'تحديد الموقع',
                          onPressed: hasPosition
                              ? () {
                                  // ✅ Confirm location - Wrapper handles navigation
                                  context
                                      .read<PermissionFlowCubit>()
                                      .confirmLocation();

                                  debugPrint('✅ Location confirmed');
                                  context.go(
                                    AppRouter.permissionNotificationIntro,
                                  );
                                }
                              : null,
                          size: AppButtonSize.medium,
                          borderRadius: 12.r,
                          disabledBackgroundColor: Colors.grey.withValues(
                            alpha: 0.3,
                          ),
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
    );
  }
}
