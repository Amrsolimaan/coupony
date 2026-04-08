import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../permissions/presentation/cubit/permission_flow_cubit.dart';
import '../../../../permissions/presentation/cubit/permission_flow_state.dart';
import '../../cubit/address_cubit.dart';
import '../../widgets/address_label_dialog.dart';

/// Address Map Picker Page
/// Allows user to pick a location on the map and save it as an address
/// Similar to location_map_page.dart but for address management
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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadInitialPosition();
  }

  Future<void> _loadInitialPosition() async {
    // Try to get saved position from permissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = context.read<PermissionFlowCubit>().state.userPosition;
      if (position != null) {
        _lastCameraCenter = LatLng(position.latitude, position.longitude);
      }
      setState(() => _isMapLoading = false);
    });
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

  Future<void> _handleConfirmLocation() async {
    if (_selectedLatLng == null || _currentAddress == null) {
      context.showErrorSnackBar(
        AppLocalizations.of(context)!.address_select_location_first,
      );
      return;
    }

    // Show label dialog
    final label = await AddressLabelDialog.show(context);
    
    if (label == null || !mounted) return;

    // Save address
    await context.read<AddressCubit>().saveAddress(
      label: label,
      address: _currentAddress!,
      latitude: _selectedLatLng!.latitude,
      longitude: _selectedLatLng!.longitude,
    );

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

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────────────────────────
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
          if (_isMapReady)
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
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          // ── Top Search Bar ─────────────────────────────────────────────
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 16.h,
            start: 16.w,
            end: 16.w,
            child: Row(
              children: [
                // Orange location icon
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

          // ── "Use Current Location" Button ─────────────────────────────
          PositionedDirectional(
            bottom: 240.h,
            start: 0,
            end: 0,
            child: Center(
              child: GestureDetector(
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.location_map_use_current,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.surface,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.my_location,
                        color: AppColors.surface,
                        size: 20.w,
                      ),
                    ],
                  ),
                ),
              ),
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
                    AppPrimaryButton(
                      text: l10n.location_map_confirm_button,
                      onPressed: (_selectedLatLng != null && _currentAddress != null)
                          ? _handleConfirmLocation
                          : null,
                      size: AppButtonSize.medium,
                      borderRadius: 12.r,
                      disabledBackgroundColor: AppColors.textDisabled,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
