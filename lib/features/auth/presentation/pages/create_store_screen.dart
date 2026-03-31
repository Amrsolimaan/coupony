import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/app_primary_button.dart';
import '../widgets/auth_text_field.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CREATE STORE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CreateStoreScreen extends HookWidget {
  const CreateStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ── Hook declarations ──────────────────────────────────────────────────
    final storeNameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final branchesController = useTextEditingController();
    final selectedCategory = useValueNotifier<String?>(null);
    final selectedCity = useValueNotifier<String?>(null);
    final selectedArea = useValueNotifier<String?>(null);
    final agreeToTerms = useValueNotifier<bool>(false);
    final storeLogo = useValueNotifier<File?>(null);

    // ── Reactive derivations ───────────────────────────────────────────────
    final storeNameValue = useValueListenable(storeNameController);
    final descriptionValue = useValueListenable(descriptionController);
    final branchesValue = useValueListenable(branchesController);
    final categoryValue = useValueListenable(selectedCategory);
    final cityValue = useValueListenable(selectedCity);
    final areaValue = useValueListenable(selectedArea);
    final termsValue = useValueListenable(agreeToTerms);

    // Character counter for description
    final descriptionLength = descriptionValue.text.length;
    final maxDescriptionLength = 500;
    final isDescriptionOverLimit = descriptionLength > maxDescriptionLength;

    final hasContent = storeNameValue.text.trim().isNotEmpty &&
        categoryValue != null &&
        descriptionValue.text.trim().isNotEmpty &&
        !isDescriptionOverLimit &&
        cityValue != null &&
        areaValue != null &&
        branchesValue.text.trim().isNotEmpty &&
        termsValue;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16.h),

                // ── Top bar ─────────────────────────────────────────
                _TopBar(l10n: l10n),
                SizedBox(height: 28.h),

                // ── Title ───────────────────────────────────────────
                Text(
                  l10n.create_store_title,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),

                // ── Logo Upload Area ────────────────────────────────
                _LogoUploadArea(
                  l10n: l10n,
                  storeLogo: storeLogo,
                ),
                SizedBox(height: 20.h),

                // ── Store Name field ────────────────────────────────
                AuthTextField(
                  controller: storeNameController,
                  hint: l10n.create_store_name_hint,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12.h),

                // ── Category Dropdown ───────────────────────────────
                _CategoryDropdown(
                  l10n: l10n,
                  selectedCategory: selectedCategory,
                ),
                SizedBox(height: 12.h),

                // ── Description field with counter ──────────────────
                _DescriptionField(
                  controller: descriptionController,
                  l10n: l10n,
                  currentLength: descriptionLength,
                  maxLength: maxDescriptionLength,
                  isOverLimit: isDescriptionOverLimit,
                ),
                SizedBox(height: 12.h),

                // ── City & Area fields ──────────────────────────────
                Directionality(
                  textDirection: Directionality.of(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CityDropdown(
                          l10n: l10n,
                          selectedCity: selectedCity,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _AreaDropdown(
                          l10n: l10n,
                          selectedArea: selectedArea,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Branches field ──────────────────────────────────
                AuthTextField(
                  controller: branchesController,
                  hint: l10n.create_store_branches_hint,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 12.h),

                // ── Terms & Conditions checkbox ─────────────────────
                _TermsCheckbox(agreeToTerms: agreeToTerms, l10n: l10n),
                SizedBox(height: 24.h),

                // ── Create Store button ─────────────────────────────
                AppPrimaryButton(
                  text: l10n.create_store_button,
                  isLoading: false,
                  onPressed: hasContent
                      ? () {
                          // TODO: Implement create store logic
                        }
                      : null,
                  height: 56.h,
                  backgroundColor: hasContent
                      ? AppColors.primary_of_saller
                      : AppColors.textDisabled,
                  textStyle: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surface,
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final AppLocalizations l10n;
  const _TopBar({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => context.pop(),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20.w,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LogoUploadArea extends HookWidget {
  final AppLocalizations l10n;
  final ValueNotifier<File?> storeLogo;

  const _LogoUploadArea({
    required this.l10n,
    required this.storeLogo,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      storeLogo.value = File(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoValue = useValueListenable(storeLogo);

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.create_store_logo_label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.create_store_logo_hint,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.create_store_logo_format,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1.5.w,
                    ),
                  ),
                  child: logoValue != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            logoValue,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32.w,
                          color: AppColors.textDisabled,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueNotifier<String?> selectedCategory;

  const _CategoryDropdown({
    required this.l10n,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      l10n.category_toys,
      l10n.categoryRestaurants,
      l10n.categoryFashion,
      l10n.categorySupermarket,
      l10n.categoryElectronics,
    ];

    return ValueListenableBuilder<String?>(
      valueListenable: selectedCategory,
      builder: (context, value, _) {
        return Container(
          height: 56.r,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.divider,
              width: 1.5.w,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Padding(
                padding: EdgeInsetsDirectional.only(start: 16.w),
                child: Text(
                  l10n.create_store_category_hint,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 24.w,
                ),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 16.w),
                    child: Text(
                      category,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedCategory.value = newValue;
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;
  final int currentLength;
  final int maxLength;
  final bool isOverLimit;

  const _DescriptionField({
    required this.controller,
    required this.l10n,
    required this.currentLength,
    required this.maxLength,
    required this.isOverLimit,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isOverLimit ? AppColors.error : AppColors.divider;
    final focusedBorderColor = isOverLimit ? AppColors.error : AppColors.primary;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: borderColor, width: 1.5.w),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: focusedBorderColor, width: 1.5.w),
    );

    return Column(
      children: [
        SizedBox(
          height: 120.h,
          child: TextField(
            controller: controller,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: l10n.create_store_description_hint,
              hintStyle: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDisabled,
              ),
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: border,
              enabledBorder: border,
              focusedBorder: focusedBorder,
              errorBorder: border,
              focusedErrorBorder: focusedBorder,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isOverLimit)
              Text(
                l10n.create_store_description_error,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 12,
                  color: AppColors.error,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              '$currentLength/$maxLength ${l10n.create_store_description_error.split(' ').last}',
              style: AppTextStyles.customStyle(
                context,
                fontSize: 12,
                color: isOverLimit ? AppColors.error : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CityDropdown extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueNotifier<String?> selectedCity;

  const _CityDropdown({
    required this.l10n,
    required this.selectedCity,
  });

  @override
  Widget build(BuildContext context) {
    final cities = [
      l10n.city_fayoum,
      l10n.city_giza,
    ];

    return ValueListenableBuilder<String?>(
      valueListenable: selectedCity,
      builder: (context, value, _) {
        return Container(
          height: 56.r,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.divider,
              width: 1.5.w,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Padding(
                padding: EdgeInsetsDirectional.only(start: 16.w),
                child: Text(
                  l10n.create_store_city_hint,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 24.w,
                ),
              ),
              items: cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 16.w),
                    child: Text(
                      city,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedCity.value = newValue;
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AreaDropdown extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueNotifier<String?> selectedArea;

  const _AreaDropdown({
    required this.l10n,
    required this.selectedArea,
  });

  @override
  Widget build(BuildContext context) {
    final areas = [
      l10n.area_lutf_allah,
    ];

    return ValueListenableBuilder<String?>(
      valueListenable: selectedArea,
      builder: (context, value, _) {
        return Container(
          height: 56.r,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.divider,
              width: 1.5.w,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Padding(
                padding: EdgeInsetsDirectional.only(start: 16.w),
                child: Text(
                  l10n.create_store_area_hint,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 24.w,
                ),
              ),
              items: areas.map((area) {
                return DropdownMenuItem<String>(
                  value: area,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 16.w),
                    child: Text(
                      area,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedArea.value = newValue;
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  final ValueNotifier<bool> agreeToTerms;
  final AppLocalizations l10n;

  const _TermsCheckbox({required this.agreeToTerms, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: agreeToTerms,
      builder: (context, checked, _) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: GestureDetector(
            onTap: () => agreeToTerms.value = !checked,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: Checkbox(
                    value: checked,
                    onChanged: (v) => agreeToTerms.value = v ?? false,
                    activeColor: AppColors.primary_of_saller,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    side: BorderSide(
                      color: AppColors.divider,
                      width: 1.5.w,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.create_store_terms_agree,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
