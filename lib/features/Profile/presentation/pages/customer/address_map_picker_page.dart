import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../permissions/presentation/cubit/permission_flow_cubit.dart';
import '../../../domain/entities/saved_address.dart';
import '../../cubit/address_cubit.dart';
import '../../cubit/address_state.dart';
import '../../cubit/Customer_Profile_cubit.dart';
import '../../cubit/Customer_Profile_state.dart';
import '../../widgets/address_label_dialog.dart';

/// Address Map Picker Page
/// Allows user to pick a location on the map and save it as an address.
/// Supports both CREATE (new address) and EDIT (update existing) modes.
class AddressMapPickerPage extends StatefulWidget {
  const AddressMapPickerPage({super.key});

  @override
  State<AddressMapPickerPage> createState() => _AddressMapPickerPageState();
}

class _AddressMapPickerPageState extends State<AddressMapPickerPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357); // Cairo

  bool _isMapReady = false;
  bool _isMapLoading = true;

  LatLng _lastCameraCenter = _defaultLocation;
  LatLng? _selectedLatLng;
  bool _isAddressLoading = false;
  String? _currentAddress;

  /// The address being edited (null = create mode)
  SavedAddress? _editingAddress;
  bool _isEditMode = false;

  // ── Geocoded components for API fields ──
  String _city = '';
  String _stateProvince = '';
  String _postalCode = '';
  String _countryCode = 'EG';
  String _street = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Check if we're in edit mode via GoRouter extra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is SavedAddress) {
        setState(() {
          _editingAddress = extra;
          _isEditMode = true;
          _lastCameraCenter = LatLng(extra.latitude, extra.longitude);
          _currentAddress = extra.address;
          _selectedLatLng = LatLng(extra.latitude, extra.longitude);
          _city = extra.city;
          _stateProvince = extra.stateProvince;
          _postalCode = extra.postalCode;
          _countryCode = extra.countryCode;
        });
      }
      _loadInitialPosition();
    });
  }

  Future<void> _loadInitialPosition() async {
    // If in edit mode, use the editing address position
    if (_isEditMode && _editingAddress != null) {
      setState(() => _isMapLoading = false);
      return;
    }

    // Start with loading state
    setState(() => _isMapLoading = true);

    try {
      // Check if location permission is granted
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        // Get current position
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

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
      print('❌ Error getting current position: $e');
    }

    // Fallback: Try to get saved position from PermissionFlowCubit
    if (mounted) {
      final savedPosition = context.read<PermissionFlowCubit>().state.userPosition;
      if (savedPosition != null) {
        final savedLocation = LatLng(savedPosition.latitude, savedPosition.longitude);
        setState(() {
          _lastCameraCenter = savedLocation;
          _isMapLoading = false;
        });
        return;
      }
      
      // Final fallback: use default location
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

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join('، ');

        setState(() {
          _currentAddress = address.isNotEmpty ? address : null;
          _isAddressLoading = false;
          // Extract geocoded components for API fields
          _street = place.street ?? '';
          _city = place.locality ?? place.subLocality ?? '';
          _stateProvince = place.administrativeArea ?? '';
          _postalCode = place.postalCode ?? '';
          _countryCode = place.isoCountryCode ?? 'EG';
        });
      } else {
        setState(() {
          _currentAddress = null;
          _isAddressLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = null;
          _isAddressLoading = false;
        });
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
      }
    } catch (_) {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  /// Get user profile data for pre-filling API fields
  Map<String, String> _getUserProfileData() {
    try {
      final profileCubit = context.read<ProfileCubit>();
      final state = profileCubit.state;
      if (state is ProfileLoaded) {
        return {
          'first_name': state.user.firstName,
          'last_name': state.user.lastName,
          'phone_number': state.user.phoneNumber,
        };
      }
      if (state is ProfileUpdateSuccess) {
        return {
          'first_name': state.user.firstName,
          'last_name': state.user.lastName,
          'phone_number': state.user.phoneNumber,
        };
      }
    } catch (_) {
      // ProfileCubit might not be in the widget tree — that's OK
    }
    return {'first_name': '', 'last_name': '', 'phone_number': ''};
  }

  Future<void> _handleConfirmLocation() async {
    if (_selectedLatLng == null || _currentAddress == null) {
      context.showErrorSnackBar(
        AppLocalizations.of(context)!.address_select_location_first,
      );
      return;
    }

    // Show label dialog (pre-fill with existing label in edit mode)
    final label = await AddressLabelDialog.show(
      context,
      initialLabel: _isEditMode ? _editingAddress?.label : null,
    );
    
    if (label == null || !mounted) return;

    // Get user profile data for pre-filling
    final profileData = _getUserProfileData();

    if (_isEditMode && _editingAddress != null) {
      // ── EDIT MODE: Update existing address via API ──
      final updatedAddress = SavedAddress(
        id: _editingAddress!.id,
        label: label,
        address: _currentAddress!,
        latitude: _selectedLatLng!.latitude,
        longitude: _selectedLatLng!.longitude,
        isDefault: _editingAddress!.isDefault,
        createdAt: _editingAddress!.createdAt,
        firstName: _editingAddress!.firstName.isNotEmpty
            ? _editingAddress!.firstName
            : profileData['first_name'] ?? '',
        lastName: _editingAddress!.lastName.isNotEmpty
            ? _editingAddress!.lastName
            : profileData['last_name'] ?? '',
        company: _editingAddress!.company,
        addressLine1: _currentAddress!,
        addressLine2: _editingAddress!.addressLine2,
        city: _city.isNotEmpty ? _city : _editingAddress!.city,
        stateProvince: _stateProvince.isNotEmpty ? _stateProvince : _editingAddress!.stateProvince,
        postalCode: _postalCode.isNotEmpty ? _postalCode : _editingAddress!.postalCode,
        countryCode: _countryCode.isNotEmpty ? _countryCode : _editingAddress!.countryCode,
        phoneNumber: _editingAddress!.phoneNumber.isNotEmpty
            ? _editingAddress!.phoneNumber
            : profileData['phone_number'] ?? '',
        deliveryInstructions: _editingAddress!.deliveryInstructions,
        isDefaultShipping: _editingAddress!.isDefaultShipping,
        isDefaultBilling: _editingAddress!.isDefaultBilling,
      );

      await context.read<AddressCubit>().updateAddress(updatedAddress);
    } else {
      // ── CREATE MODE: Save new address via API ──
      await context.read<AddressCubit>().saveAddress(
        label: label,
        address: _currentAddress!,
        latitude: _selectedLatLng!.latitude,
        longitude: _selectedLatLng!.longitude,
        addressLine1: _currentAddress!,
        city: _city,
        stateProvince: _stateProvince,
        postalCode: _postalCode,
        countryCode: _countryCode,
        firstName: profileData['first_name'] ?? '',
        lastName: profileData['last_name'] ?? '',
        phoneNumber: profileData['phone_number'] ?? '',
      );
    }

    if (mounted) {
      context.pop(true); // Return true to indicate success
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddressError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            // ── Google Map (Hidden while loading) ────────────────────────
            if (!_isMapLoading)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _lastCameraCenter,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  setState(() => _isMapReady = true);
                },
                onCameraMove: (CameraPosition pos) {
                  _lastCameraCenter = pos.target;
                  if (!_isAddressLoading) {
                    setState(() => _isAddressLoading = true);
                  }
                },
                onCameraIdle: () {
                  setState(() => _selectedLatLng = _lastCameraCenter);
                  _getAddressFromCoordinates(
                    _lastCameraCenter.latitude,
                    _lastCameraCenter.longitude,
                  );
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

            // ── Static Center-Pin ─────────────────────────────────────────
            if (_isMapReady && !_isMapLoading)
              Align(
                alignment: Alignment.center,
                child: Padding(
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

            // ── Map Loading Overlay ───────────────────────────────────────
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
                        child: Icon(
                          Icons.location_searching_rounded,
                          size: 40.w,
                          color: AppColors.primary,
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
                        l10n.permissions_location_checking,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.permissions_please_wait,
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

            // ── Top Search Bar (Hidden while loading) ─────────────────────
            if (!_isMapLoading)
              PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 16.h,
              start: 16.w,
              end: 16.w,
              child: Row(
                children: [
                  // Orange location icon (with tap functionality)
                  GestureDetector(
                    onTap: () async {
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
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.surface,
                        size: 22.w,
                      ),
                    ),
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
                              child: Icon(
                                Icons.search,
                                color: AppColors.grey600,
                                size: 22.w,
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
                                hintText: l10n.location_map_search_placeholder,
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
                            onTap: _isListening ? _stopListening : _startListening,
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

                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
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

            // ── Bottom Sheet ───────────────────────────────────────────────
            PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location label
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                            size: 22.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.location_map_your_location,
                            style: AppTextStyles.h4.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // Address / shimmer
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: 30.w),
                        child: _isAddressLoading
                            ? Row(
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
                              )
                            : Text(
                                _currentAddress ??
                                    (_selectedLatLng != null
                                        ? l10n.location_map_coordinates_format(
                                            _selectedLatLng!.latitude
                                                .toStringAsFixed(4),
                                            _selectedLatLng!.longitude
                                                .toStringAsFixed(4),
                                          )
                                        : l10n.location_map_tap_to_select),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),

                      SizedBox(height: 24.h),

                      // Confirm button
                      BlocBuilder<AddressCubit, AddressState>(
                        builder: (context, addressState) {
                          final isSaving = addressState is AddressSaving;
                          return AppPrimaryButton(
                            text: _isEditMode
                                ? l10n.location_map_confirm_button
                                : l10n.location_map_confirm_button,
                            onPressed: (_selectedLatLng != null && _currentAddress != null && !isSaving)
                                ? _handleConfirmLocation
                                : null,
                            isLoading: isSaving,
                            size: AppButtonSize.medium,
                            borderRadius: 12.r,
                            disabledBackgroundColor: AppColors.textDisabled,
                          );
                        },
                      ),
                    ],
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
