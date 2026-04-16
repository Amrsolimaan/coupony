import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/seller_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/app_router.dart';
import '../../domain/entities/offer_entity.dart';
import '../cubit/manage_offer_cubit.dart';
import '../cubit/seller_offers_cubit.dart';
import '../cubit/seller_offers_state.dart';
import '../widgets/guest_seller_view.dart';
import '../widgets/pending_approval_view_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SELLER OFFERS PAGE — Smart Manage Offer Page (Create / Edit)
// • Preserves guest + pending auth guards (SellerOffersCubit).
// • Authorized sellers see the full offer form backed by ManageOfferCubit.
// ─────────────────────────────────────────────────────────────────────────────

class CreateSellerPage extends StatelessWidget {
  const CreateSellerPage({super.key});

  static const _blue = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          // ── Auth error snackbar ──────────────────────────────────────────
          BlocListener<SellerOffersCubit, SellerOffersState>(
            listener: (context, state) {
              if (state is SellerOffersError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              }
            },
          ),
          // ── Form submit result ───────────────────────────────────────────
          BlocListener<ManageOfferCubit, ManageOfferState>(
            listener: (context, state) {
              if (state.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.offer_success_message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
                context.pop();
              } else if (state.submitError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.submitError!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SellerOffersCubit, SellerOffersState>(
          builder: (context, offersState) {
            final cubit = context.read<ManageOfferCubit>();
            final isEditMode = cubit.initialOffer != null;
            final l10n = AppLocalizations.of(context)!;

            final showBottomNav =
                offersState is SellerOffersGuest ||
                offersState is SellerOffersPending;

            return Scaffold(
              backgroundColor: AppColors.surface,
              appBar: _buildAppBar(
                context,
                l10n,
                isEditMode,
                offersState,
                cubit,
              ),
              body: _buildBody(context, offersState, l10n, cubit, isEditMode),
              // Bottom nav only for guest/pending (top-level destination feel)
              bottomNavigationBar: showBottomNav
                  ? _buildGuestBottomNav(context, offersState)
                  : null,
            );
          },
        ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isEditMode,
    SellerOffersState offersState,
    ManageOfferCubit cubit,
  ) {
    if (offersState is SellerOffersGuest ||
        offersState is SellerOffersPending) {
      return null;
    }

    return AppBar(
      surfaceTintColor: AppColors.primaryOfSeller,
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: BackButton(color: AppColors.textPrimary),
      title: Text(
        isEditMode ? l10n.offer_edit_title : l10n.offer_create_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      // "حفظ" quick-action visible only in edit mode
      actions: isEditMode
          ? [
              BlocBuilder<ManageOfferCubit, ManageOfferState>(
                buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
                builder: (context, state) => TextButton(
                  onPressed: state.isSubmitting ? null : () => cubit.submit(),
                  child: Text(
                    l10n.offer_save_action,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: state.isSubmitting
                          ? AppColors.textSecondary
                          : _blue,
                    ),
                  ),
                ),
              ),
            ]
          : [],
    );
  }

  // ── Body router ────────────────────────────────────────────────────────────

  Widget _buildBody(
    BuildContext context,
    SellerOffersState offersState,
    AppLocalizations l10n,
    ManageOfferCubit cubit,
    bool isEditMode,
  ) {
    if (offersState is SellerOffersLoading ||
        offersState is SellerOffersInitial) {
      return _buildLoading();
    }
    if (offersState is SellerOffersError) {
      return _buildErrorState(context, offersState, l10n);
    }
    if (offersState is SellerOffersGuest) {
      return const GuestSellerViewWidget(icon: FontAwesomeIcons.tags);
    }
    if (offersState is SellerOffersPending) {
      return PendingApprovalViewWidget(
        icon: FontAwesomeIcons.tags,
        onContactUs: () {},
      );
    }
    // All authorized states (SellerOffersDataLoaded, SellerOffersLoaded…)
    return _buildForm(context, l10n, cubit, isEditMode);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OFFER FORM
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    ManageOfferCubit cubit,
    bool isEditMode,
  ) {
    return BlocBuilder<ManageOfferCubit, ManageOfferState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image picker
              _buildImagePicker(context, l10n, state, cubit),
              SizedBox(height: 20.h),

              // 2. Title
              _buildLabel(context, l10n.offer_title_label),
              _buildTextField(
                controller: cubit.titleController,
                hint: l10n.offer_title_label,
                error: state.fieldErrors[OfferField.title],
                context: context,
              ),
              SizedBox(height: 16.h),

              // 3. Description
              _buildLabel(context, l10n.offer_description_label),
              _buildTextField(
                controller: cubit.descriptionController,
                hint: l10n.offer_description_label,
                maxLines: 3,
                context: context,
              ),
              SizedBox(height: 16.h),

              // 4. Discount type
              _buildLabel(context, l10n.offer_discount_type_label),
              _buildDiscountTypeDropdown(context, l10n, state, cubit),
              SizedBox(height: 16.h),

              // 5. Category
              _buildLabel(context, l10n.offer_category_label),
              _buildCategoryDropdown(context, l10n, state, cubit),
              SizedBox(height: 16.h),

              // 6. Sub-category
              _buildLabel(context, l10n.offer_sub_category_label),
              _buildSubCategoryDropdown(context, l10n, state, cubit),
              SizedBox(height: 16.h),

              // 7. Sizes
              _buildLabel(context, l10n.offer_sizes_label),
              _buildSizeChips(context, state, cubit),
              SizedBox(height: 16.h),

              // 8. Colors
              _buildLabel(context, l10n.offer_colors_label),
              _buildColorRow(context, state, cubit),
              SizedBox(height: 16.h),

              // 9. Price row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, l10n.offer_original_price_label),
                        _buildTextField(
                          controller: cubit.originalPriceController,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          error: state.fieldErrors[OfferField.originalPrice],
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(context, l10n.offer_discounted_price_label),
                        _buildTextField(
                          controller: cubit.discountedPriceController,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          error: state.fieldErrors[OfferField.discountedPrice],
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // 10. Discount value (auto-calculated, read-only)
              _buildLabel(context, l10n.offer_discount_value_label),
              _buildDiscountDisplay(context, cubit),
              SizedBox(height: 16.h),

              // 11. Publish settings
              _buildLabel(context, l10n.offer_publish_settings_label),
              _buildPublishSettings(context, l10n, state, cubit),

              // 12–13. Date pickers (only when scheduled)
              if (!state.publishNow) ...[
                SizedBox(height: 16.h),
                _buildLabel(context, l10n.offer_start_date_label),
                _buildDatePicker(
                  context: context,
                  date: state.startDate,
                  onChanged: cubit.setStartDate,
                ),
                SizedBox(height: 16.h),
                _buildLabel(context, l10n.offer_end_date_label),
                _buildDatePicker(
                  context: context,
                  date: state.endDate,
                  onChanged: cubit.setEndDate,
                ),
              ],

              SizedBox(height: 32.h),

              // Submit button
              _buildSubmitButton(context, l10n, state, cubit, isEditMode),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Text field ─────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    String? error,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        errorText: error,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: _blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  // ── Image picker ───────────────────────────────────────────────────────────

  Widget _buildImagePicker(
    BuildContext context,
    AppLocalizations l10n,
    ManageOfferState state,
    ManageOfferCubit cubit,
  ) {
    return GestureDetector(
      onTap: () {
        // TODO: integrate image_picker package
      },
      child: Container(
        width: double.infinity,
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: _blue.withValues(alpha: 0.04),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _blue.withValues(alpha: 0.45),
            radius: 12.r,
          ),
          child: state.imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    state.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _imagePlaceholder(context, l10n),
                  ),
                )
              : _imagePlaceholder(context, l10n),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 36.w, color: _blue),
        SizedBox(height: 8.h),
        Text(
          l10n.offer_image_picker_hint,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.offer_image_picker_sub,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Discount type dropdown ─────────────────────────────────────────────────

  Widget _buildDiscountTypeDropdown(
    BuildContext context,
    AppLocalizations l10n,
    ManageOfferState state,
    ManageOfferCubit cubit,
  ) {
    final items = {
      DiscountType.percentage: l10n.offer_discount_type_percentage,
      DiscountType.buyGet: l10n.offer_discount_type_buy_get,
      DiscountType.fixedAmount: l10n.offer_discount_type_fixed,
    };

    return _buildDropdown<DiscountType>(
      context: context,
      value: state.discountType,
      items: items,
      onChanged: (val) {
        if (val != null) cubit.setDiscountType(val);
      },
    );
  }

  // ── Category dropdown ──────────────────────────────────────────────────────

  Widget _buildCategoryDropdown(
    BuildContext context,
    AppLocalizations l10n,
    ManageOfferState state,
    ManageOfferCubit cubit,
  ) {
    return _buildDropdown<String>(
      context: context,
      value: state.category,
      hint: l10n.offer_select_hint,
      items: {for (final c in ManageOfferCubit.categories) c: c},
      onChanged: cubit.setCategory,
      error: state.fieldErrors[OfferField.category],
    );
  }

  // ── Sub-category dropdown ──────────────────────────────────────────────────

  Widget _buildSubCategoryDropdown(
    BuildContext context,
    AppLocalizations l10n,
    ManageOfferState state,
    ManageOfferCubit cubit,
  ) {
    return _buildDropdown<String>(
      context: context,
      value: state.subCategory,
      hint: l10n.offer_select_hint,
      items: {for (final s in ManageOfferCubit.subCategories) s: s},
      onChanged: cubit.setSubCategory,
    );
  }

  // ── Generic styled dropdown ────────────────────────────────────────────────

  Widget _buildDropdown<T>({
    required BuildContext context,
    required T? value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
    String? hint,
    String? error,
  }) {
    final decoration = InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      errorText: error,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: _blue, width: 1.5),
      ),
    );

    return DropdownButtonFormField<T>(
      value: value,
      decoration: decoration,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
        size: 22.w,
      ),
      style: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      dropdownColor: AppColors.surface,
      items: items.entries
          .map((e) => DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ── Size chips ─────────────────────────────────────────────────────────────

  Widget _buildSizeChips(
    BuildContext context,
    ManageOfferState state,
    ManageOfferCubit cubit,
  ) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: ManageOfferCubit.availableSizes.map((size) {
        final isSelected = state.selectedSizes.contains(size);
        return GestureDetector(
          onTap: () => cubit.toggleSize(size),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? _blue : AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: isSelected ? _blue : AppColors.divider),
            ),
            child: Text(
              size,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Color circles ──────────────────────────────────────────────────────────

  Widget _buildColorRow(
    BuildContext context,
    ManageOfferState state,
    ManageOfferCubit cubit,
  ) {
    return Row(
      children: ManageOfferCubit.availableColors.map((colorVal) {
        final color = Color(colorVal);
        final isSelected = state.selectedColors.contains(colorVal);
        final isWhite = colorVal == 0xFFFFFFFF;

        return GestureDetector(
          onTap: () => cubit.toggleColor(colorVal),
          child: Container(
            margin: EdgeInsetsDirectional.only(start: 8.w),
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? _blue
                    : isWhite
                    ? AppColors.divider
                    : Colors.transparent,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 14.w,
                    color: isWhite ? AppColors.textPrimary : Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  // ── Discount display (read-only, auto-calculated) ──────────────────────────

  Widget _buildDiscountDisplay(BuildContext context, ManageOfferCubit cubit) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        '${cubit.computedDiscountPercent.toStringAsFixed(0)} %',
        style: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _blue,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  // ── Publish settings ───────────────────────────────────────────────────────

  Widget _buildPublishSettings(
    BuildContext context,
    AppLocalizations l10n,
    ManageOfferState state,
    ManageOfferCubit cubit,
  ) {
    return Column(
      children: [
        _buildRadioRow(
          context: context,
          label: l10n.offer_publish_now,
          isSelected: state.publishNow,
          onTap: () => cubit.setPublishNow(true),
        ),
        _buildRadioRow(
          context: context,
          label: l10n.offer_schedule,
          isSelected: !state.publishNow,
          onTap: () => cubit.setPublishNow(false),
        ),
      ],
    );
  }

  Widget _buildRadioRow({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: _blue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  // ── Date picker ────────────────────────────────────────────────────────────

  Widget _buildDatePicker({
    required BuildContext context,
    required DateTime? date,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 730)),
          builder: (context, child) => Theme(
            data: Theme.of(
              context,
            ).copyWith(colorScheme: ColorScheme.light(primary: _blue)),
            child: child!,
          ),
        );
        onChanged(picked);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 20.w,
              color: AppColors.textSecondary,
            ),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : AppLocalizations.of(context)!.offer_details_date_placeholder,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: date != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit button ──────────────────────────────────────────────────────────

  Widget _buildSubmitButton(
    BuildContext context,
    AppLocalizations l10n,
    ManageOfferState state,
    ManageOfferCubit cubit,
    bool isEditMode,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: state.isSubmitting ? null : () => cubit.submit(),
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          disabledBackgroundColor: _blue.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: state.isSubmitting
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                isEditMode ? l10n.offer_update : l10n.offer_save_publish,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SUPPORTING STATES
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(color: _blue, strokeWidth: 3.w),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    SellerOffersError state,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              state.message,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.read<SellerOffersCubit>().loadOffers(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                l10n.profile_retry,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Guest/Pending keep bottom nav for top-level feel
  Widget _buildGuestBottomNav(BuildContext context, SellerOffersState state) {
    return SellerBottomNavBar(
      currentIndex: 3,
      onTap: (index) => _handleNavigation(context, index, state),
    );
  }

  void _handleNavigation(
    BuildContext context,
    int index,
    SellerOffersState state,
  ) {
    bool isGuest = false;
    bool isPending = false;
    if (state is SellerOffersInitial) {
      isGuest = state.isGuest;
      isPending = state.isPending;
    } else if (state is SellerOffersLoaded) {
      isGuest = state.isGuest;
      isPending = state.isPending;
    } else if (state is SellerOffersGuest) {
      isGuest = true;
    } else if (state is SellerOffersPending) {
      isPending = true;
    }
    final args = {'isGuest': isGuest, 'isPending': isPending};
    switch (index) {
      case 0:
        context.go(AppRouter.customerProfile);
        break;
      case 1:
        context.go(AppRouter.sellerStore, extra: args);
        break;
      case 2:
        context.go(AppRouter.sellerAnalytics, extra: args);
        break;
      case 3:
        break;
      case 4:
        context.go(AppRouter.sellerHome, extra: args);
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHED BORDER PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final metrics = path.computeMetrics().first;
    double distance = 0;
    while (distance < metrics.length) {
      final start = distance;
      final end = (distance + dashWidth).clamp(0.0, metrics.length);
      canvas.drawPath(metrics.extractPath(start, end), paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
