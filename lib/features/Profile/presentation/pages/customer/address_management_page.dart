import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/buttons/buttons.dart';
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../cubit/address_cubit.dart';
import '../../cubit/address_state.dart';
import '../../widgets/address_card_widget.dart';
import '../../widgets/empty_address_widget.dart';

/// Address Management Page
/// Displays and manages user's saved addresses
class AddressManagementPage extends StatelessWidget {
  const AddressManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        // ── Handle Success ─────────────────────────────────────────────
        if (state is AddressOperationSuccess) {
          context.showSuccessSnackBar(state.message);
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
          backgroundColor: AppColors.background,
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
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          size: 20.w,
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
    if (state is AddressLoading) {
      return _buildLoadingState(l10n);
    }

    if (state is AddressLoaded) {
      if (state.isEmpty) {
        return _buildEmptyState(context, l10n);
      }
      return _buildAddressList(context, state, l10n);
    }

    if (state is AddressOperationSuccess) {
      if (state.addresses.isEmpty) {
        return _buildEmptyState(context, l10n);
      }
      return _buildAddressListFromOperation(context, state, l10n);
    }

    return const SizedBox.shrink();
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

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: const EmptyAddressWidget(),
        ),
        
        // ── Add New Address Button ────────────────────────────────────────
        Container(
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
        ),
      ],
    );
  }

  // ── Address List ───────────────────────────────────────────────────────────
  Widget _buildAddressList(
    BuildContext context,
    AddressLoaded state,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // ── Search Bar ─────────────────────────────────────────────────────
        _buildSearchBar(context, l10n),
        SizedBox(height: 16.h),

        // ── Address List ───────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100.h),
            itemCount: state.addresses.length,
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return AddressCardWidget(
                address: address,
                onTap: () {
                  // TODO: Navigate to address details or map
                },
                onEdit: () async {
                  // TODO: Navigate to edit address
                  final result = await context.push(
                    AppRouter.addressMapPicker,
                    extra: address,
                  );
                  if (result == true && context.mounted) {
                    context.read<AddressCubit>().loadAddresses();
                  }
                },
                onDelete: () => _showDeleteConfirmation(context, address.id, l10n),
                onSetDefault: () {
                  context.read<AddressCubit>().setDefaultAddress(address.id);
                },
              );
            },
          ),
        ),

        // ── Add New Address Button (Fixed at bottom) ───────────────────────
        Container(
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
        ),
      ],
    );
  }

  // ── Address List from Operation Success ────────────────────────────────────
  Widget _buildAddressListFromOperation(
    BuildContext context,
    AddressOperationSuccess state,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // ── Search Bar ─────────────────────────────────────────────────────
        _buildSearchBar(context, l10n),
        SizedBox(height: 16.h),

        // ── Address List ───────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100.h),
            itemCount: state.addresses.length,
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return AddressCardWidget(
                address: address,
                onTap: () {
                  // TODO: Navigate to address details or map
                },
                onEdit: () async {
                  final result = await context.push(
                    AppRouter.addressMapPicker,
                    extra: address,
                  );
                  if (result == true && context.mounted) {
                    context.read<AddressCubit>().loadAddresses();
                  }
                },
                onDelete: () => _showDeleteConfirmation(context, address.id, l10n),
                onSetDefault: () {
                  context.read<AddressCubit>().setDefaultAddress(address.id);
                },
              );
            },
          ),
        ),

        // ── Add New Address Button (Fixed at bottom) ───────────────────────
        Container(
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
        ),
      ],
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
          // ── Orange Icon ────────────────────────────────────────────────
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

          // ── Search Field ───────────────────────────────────────────────
          Expanded(
            child: TextField(
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
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),

          // ── Search Icon ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20.w,
            ),
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
