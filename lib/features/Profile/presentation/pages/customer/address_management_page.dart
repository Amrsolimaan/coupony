import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../../../../core/storage/local_cache_service.dart';
import '../../../../../core/constants/storage_keys.dart';
import '../../../../permissions/data/models/permission_status_model.dart';
import '../../../domain/entities/saved_address.dart';
import '../../cubit/address_cubit.dart';
import '../../cubit/address_state.dart';
import '../../widgets/address_card_widget.dart';
import '../../widgets/empty_address_widget.dart';

/// Address Management Page
/// Displays and manages user's saved addresses.
/// Supports server-side search via GET /me/addresses?search=
class AddressManagementPage extends StatefulWidget {
  const AddressManagementPage({super.key});

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // ── GPS Location saved from permission flow ─────────────────────────────
  SavedAddress? _gpsLocationAddress;

  @override
  void initState() {
    super.initState();
    _loadGpsLocation();
  }

  /// Reads the location saved during the permission flow (location_map_page)
  /// and builds a read-only SavedAddress to prepend to the list.
  Future<void> _loadGpsLocation() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final cache = LocalCacheService();
      final model = await cache.get<PermissionStatusModel>(
        boxName: StorageKeys.permissionsBox,
        key: StorageKeys.permissionStatusKey,
      );
      if (!mounted) return;
      if (model != null &&
          model.latitude != null &&
          model.longitude != null) {
        setState(() {
          _gpsLocationAddress = SavedAddress(
            id: '__gps_location__',
            label: l10n.current_location_default_name,
            address: model.address ?? '${model.latitude!.toStringAsFixed(4)}, ${model.longitude!.toStringAsFixed(4)}',
            latitude: model.latitude!,
            longitude: model.longitude!,
            isDefault: true,
            createdAt: model.timestamp,
          );
        });
      }
    } catch (_) {
      // Silently ignore — GPS card is optional
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── Debounced search trigger ───────────────────────────────────────────────
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<AddressCubit>().searchAddresses(value);
    });
  }

  // ── Clear search and snap back to full list ────────────────────────────────
  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    context.read<AddressCubit>().searchAddresses('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        // ── Handle Success ─────────────────────────────────────────────
        if (state is AddressOperationSuccess) {
          // Check if message is a localization key
          final message = state.message == 'address_set_default_success'
              ? l10n.address_set_default_success
              : state.message;
          context.showSuccessSnackBar(message);
        }

        // ── Handle Error ───────────────────────────────────────────────
        if (state is AddressError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        // ── Trigger load if initial ────────────────────────────────────
        if (state is AddressInitial) {
          context.read<AddressCubit>().loadAddresses();
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(context, l10n),
          body: _buildBody(context, state, l10n),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.address_management_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.chevronLeft,
          size: 18.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(
    BuildContext context,
    AddressState state,
    AppLocalizations l10n,
  ) {
    // ── Hard loading (first fetch / delete / save) ─────────────────────
    if (state is AddressLoading ||
        state is AddressSaving ||
        state is AddressDeleting) {
      return _buildLoadingState(l10n);
    }

    // ── Search in-flight ───────────────────────────────────────────────
    if (state is AddressSearching) {
      return Column(
        children: [
          _buildSearchBar(context, l10n),
          SizedBox(height: 16.h),
          Expanded(child: _buildLoadingState(l10n)),
        ],
      );
    }

    // ── Search results ─────────────────────────────────────────────────
    if (state is AddressSearchLoaded) {
      return Column(
        children: [
          _buildSearchBar(context, l10n),
          SizedBox(height: 16.h),
          state.isEmpty
              ? Expanded(child: _buildSearchEmptyState(l10n, state.query))
              : Expanded(
                  child: _buildAddressList(context, state.results, l10n),
                ),
        ],
      );
    }

    // ── Normal loaded list ─────────────────────────────────────────────
    if (state is AddressLoaded) {
      if (state.isEmpty) return _buildEmptyState(context, l10n);
      return _buildFullAddressPage(context, state.addresses, l10n);
    }

    // ── Operation success (post delete / save / update) ────────────────
    if (state is AddressOperationSuccess) {
      if (state.addresses.isEmpty) return _buildEmptyState(context, l10n);
      return _buildFullAddressPage(context, state.addresses, l10n);
    }

    return const SizedBox.shrink();
  }

  // ── Full address page (search bar + list + add button) ────────────────────
  Widget _buildFullAddressPage(
    BuildContext context,
    List addresses,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        _buildSearchBar(context, l10n),
        SizedBox(height: 16.h),
        Expanded(
          child: _buildAddressList(context, addresses.cast(), l10n),
        ),
        _buildAddButton(context, l10n),
      ],
    );
  }

  // ── Loading State ──────────────────────────────────────────────────────────
  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3.w,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.loading,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State (no addresses at all) ─────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        const Expanded(child: EmptyAddressWidget()),
        _buildAddButton(context, l10n),
      ],
    );
  }

  // ── Search Empty State (query returned 0 results) ─────────────────────────
  Widget _buildSearchEmptyState(AppLocalizations l10n, String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56.w,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: 16.h),
          Text(
            '${l10n.address_search_no_results} "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Address List ───────────────────────────────────────────────────────────
  Widget _buildAddressList(
    BuildContext context,
    List<dynamic> addresses,
    AppLocalizations l10n,
  ) {
    // Merge GPS card + API addresses into one flat list
    final items = <SavedAddress>[
      if (_gpsLocationAddress != null) _gpsLocationAddress!,
      ...addresses.cast<SavedAddress>(),
    ];

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 100.h),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final address = items[index];
        final isGps = address.id == '__gps_location__';

        return AddressCardWidget(
          address: address,
          onTap: () {
            // TODO: Navigate to address details or map
          },
          // GPS card has no edit/delete/setDefault actions
          onEdit: isGps
              ? null
              : () async {
                  final result = await context.push(
                    AppRouter.addressMapPicker,
                    extra: address,
                  );
                  if (result == true && context.mounted) {
                    context.read<AddressCubit>().loadAddresses();
                  }
                },
          onDelete: isGps
              ? null
              : () => _showDeleteConfirmation(context, address.id, l10n),
          onSetDefault: isGps
              ? null
              : () {
                  context.read<AddressCubit>().setDefaultAddress(address.id);
                },
        );
      },
    );
  }

  // ── Add New Address Button ─────────────────────────────────────────────────
  Widget _buildAddButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AppPrimaryButton(
          text: l10n.address_add_new,
          onPressed: () async {
            final result = await context.push(AppRouter.addressMapPicker);
            if (result == true && context.mounted) {
              context.read<AddressCubit>().loadAddresses();
            }
          },
          size: AppButtonSize.large,
          borderRadius: 12.r,
        ),
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Orange Location Icon ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.surface,
                size: 18.w,
              ),
            ),
          ),

          // ── Search TextField ──────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10n.address_search_hint,
                hintStyle: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // ── Clear (✕) / Search Icon ───────────────────────────────────
          AnimatedBuilder(
            animation: _searchController,
            builder: (_, __) {
              final hasText = _searchController.text.isNotEmpty;
              return Padding(
                padding: EdgeInsets.all(12.w),
                child: GestureDetector(
                  onTap: hasText ? _clearSearch : null,
                  child: Icon(
                    hasText
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    color: hasText
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20.w,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Delete Confirmation Dialog ─────────────────────────────────────────────
  void _showDeleteConfirmation(
    BuildContext context,
    String addressId,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.address_delete_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          l10n.address_delete_message,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.address_cancel,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AddressCubit>().deleteAddress(addressId);
            },
            child: Text(
              l10n.address_delete,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
