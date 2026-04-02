import 'dart:io';

import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/buttons/app_primary_button.dart';
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:coupony/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/entities/category_entity.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/entities/social_link_entity.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/use_cases/create_store_use_case.dart';
import 'package:coupony/features/seller_flow/CreateStore/presentation/cubit/create_store_cubit.dart';
import 'package:coupony/features/seller_flow/CreateStore/presentation/cubit/create_store_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CREATE STORE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CreateStoreScreen extends HookWidget {
  const CreateStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ── Hook declarations ──────────────────────────────────────────────────
    final storeNameController    = useTextEditingController();
    final phoneController        = useTextEditingController();
    final emailController        = useTextEditingController();
    final descriptionController  = useTextEditingController();
    final branchesController     = useTextEditingController();
    final selectedCategory       = useValueNotifier<CategoryEntity?>(null);
    final selectedCity           = useValueNotifier<String?>(null);
    final selectedArea           = useValueNotifier<String?>(null);
    final agreeToTerms           = useValueNotifier<bool>(false);
    final storeLogo              = useValueNotifier<File?>(null);

    // Verification docs
    final commercialRegister = useValueNotifier<File?>(null);
    final taxCard            = useValueNotifier<File?>(null);
    final idCardFront        = useValueNotifier<File?>(null);
    final idCardBack         = useValueNotifier<File?>(null);

    // ── Reactive derivations ───────────────────────────────────────────────
    final storeNameValue   = useValueListenable(storeNameController);
    final phoneValue       = useValueListenable(phoneController);
    final descriptionValue = useValueListenable(descriptionController);
    useValueListenable(branchesController); // tracked for future use
    final categoryValue    = useValueListenable(selectedCategory);
    final areaValue        = useValueListenable(selectedArea);
    final termsValue       = useValueListenable(agreeToTerms);

    final descriptionLength    = descriptionValue.text.length;
    const maxDescriptionLength = 500;
    final isDescriptionOverLimit = descriptionLength > maxDescriptionLength;

    final hasContent =
        storeNameValue.text.trim().isNotEmpty &&
        phoneValue.text.trim().isNotEmpty &&
        categoryValue != null &&
        areaValue != null &&
        !isDescriptionOverLimit &&
        termsValue;

    // ── BlocListener for side-effects ──────────────────────────────────────
    return BlocListener<CreateStoreCubit, CreateStoreState>(
      listener: (context, state) {
        if (state.navigationSignal == CreateStoreNavigation.toMerchantDashboard) {
          context.read<CreateStoreCubit>().clearNavigationSignal();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(AppRouter.merchantDashboard);
          });
        }
        if (state.errorKey != null) {
          context.showErrorSnackBar(context.getLocalizedMessage(state.errorKey));
        }
        if (state.successKey != null) {
          context.showSuccessSnackBar(context.getLocalizedMessage(state.successKey));
        }
      },
      child: Scaffold(
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
                  _LogoUploadArea(l10n: l10n, storeLogo: storeLogo),
                  SizedBox(height: 20.h),

                  // ── Store Name field ────────────────────────────────
                  AuthTextField(
                    controller: storeNameController,
                    hint: l10n.create_store_name_hint,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 12.h),

                  // ── Phone field ─────────────────────────────────────
                  AuthTextField(
                    controller: phoneController,
                    hint: l10n.create_store_phone_hint,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 12.h),

                  // ── Email field ─────────────────────────────────────
                  AuthTextField(
                    controller: emailController,
                    hint: l10n.email,
                    keyboardType: TextInputType.emailAddress,
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
                  SizedBox(height: 20.h),

                  // ── Location Picker ─────────────────────────────────
                  _LocationPickerSection(l10n: l10n),
                  SizedBox(height: 20.h),

                  // ── Social Links ────────────────────────────────────
                  _SocialLinksSection(l10n: l10n),
                  SizedBox(height: 20.h),

                  // ── Verification Documents ──────────────────────────
                  _VerificationDocsSection(
                    l10n: l10n,
                    commercialRegister: commercialRegister,
                    taxCard: taxCard,
                    idCardFront: idCardFront,
                    idCardBack: idCardBack,
                  ),
                  SizedBox(height: 16.h),

                  // ── Terms & Conditions checkbox ─────────────────────
                  _TermsCheckbox(agreeToTerms: agreeToTerms, l10n: l10n),
                  SizedBox(height: 24.h),

                  // ── Create Store button ─────────────────────────────
                  BlocBuilder<CreateStoreCubit, CreateStoreState>(
                    buildWhen: (prev, next) =>
                        prev.isSubmitting != next.isSubmitting,
                    builder: (context, state) {
                      return AppPrimaryButton(
                        text: l10n.create_store_button,
                        isLoading: state.isSubmitting,
                        onPressed: hasContent && !state.isSubmitting
                            ? () => _onSubmit(
                                  context,
                                  storeNameController.text.trim(),
                                  phoneController.text.trim(),
                                  emailController.text.trim(),
                                  descriptionController.text.trim(),
                                  selectedCity.value ?? '',
                                  selectedArea.value ?? '',
                                  categoryValue,
                                  storeLogo.value,
                                  commercialRegister.value,
                                  taxCard.value,
                                  idCardFront.value,
                                  idCardBack.value,
                                )
                            : null,
                        height: 56.h,
                        backgroundColor: hasContent && !state.isSubmitting
                            ? Theme.of(context).primaryColor
                            : AppColors.textDisabled,
                        textStyle: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.surface,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit(
    BuildContext context,
    String name,
    String phone,
    String email,
    String description,
    String city,
    String addressLine1,
    CategoryEntity? category,
    File? logoUrl,
    File? commercialRegister,
    File? taxCard,
    File? idCardFront,
    File? idCardBack,
  ) {
    final cubit = context.read<CreateStoreCubit>();
    final params = CreateStoreParams(
      name: name,
      description: description,
      email: email,
      phone: phone,
      addressLine1: addressLine1,
      city: city,
      latitude: cubit.state.latitude,
      longitude: cubit.state.longitude,
      categoryIds: category != null ? [category.id] : [],
      socials: cubit.state.socialLinks,
      logoUrl: logoUrl,
      commercialRegister: commercialRegister,
      taxCard: taxCard,
      idCardFront: idCardFront,
      idCardBack: idCardBack,
    );
    cubit.createStore(params);
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

  const _LogoUploadArea({required this.l10n, required this.storeLogo});

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
                    border: Border.all(color: AppColors.divider, width: 1.5.w),
                  ),
                  child: logoValue != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(logoValue, fit: BoxFit.cover),
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
  final ValueNotifier<CategoryEntity?> selectedCategory;

  const _CategoryDropdown({required this.l10n, required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      buildWhen: (prev, next) =>
          prev.categories != next.categories ||
          prev.isCategoriesLoading != next.isCategoriesLoading,
      builder: (context, state) {
        return ValueListenableBuilder<CategoryEntity?>(
          valueListenable: selectedCategory,
          builder: (context, value, _) {
            return Container(
              height: 56.r,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider, width: 1.5.w),
              ),
              child: state.isCategoriesLoading
                  ? Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<CategoryEntity>(
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
                        items: state.categories.map((category) {
                          return DropdownMenuItem<CategoryEntity>(
                            value: category,
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(start: 16.w),
                              child: Text(
                                category.name,
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
    final borderColor       = isOverLimit ? AppColors.error : AppColors.divider;
    final focusedBorderColor = isOverLimit ? AppColors.error : Theme.of(context).primaryColor;

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
              '$currentLength/$maxLength',
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

  const _CityDropdown({required this.l10n, required this.selectedCity});

  @override
  Widget build(BuildContext context) {
    final cities = [l10n.city_fayoum, l10n.city_giza];

    return ValueListenableBuilder<String?>(
      valueListenable: selectedCity,
      builder: (context, value, _) {
        return Container(
          height: 56.r,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.divider, width: 1.5.w),
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
              onChanged: (newValue) => selectedCity.value = newValue,
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

  const _AreaDropdown({required this.l10n, required this.selectedArea});

  @override
  Widget build(BuildContext context) {
    final areas = [l10n.area_lutf_allah];

    return ValueListenableBuilder<String?>(
      valueListenable: selectedArea,
      builder: (context, value, _) {
        return Container(
          height: 56.r,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.divider, width: 1.5.w),
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
              onChanged: (newValue) => selectedArea.value = newValue,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOCIAL LINKS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _SocialLinksSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _SocialLinksSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      buildWhen: (prev, next) => prev.socialLinks != next.socialLinks,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.create_store_socials_label,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddSocialDialog(context),
                  icon: Icon(Icons.add, size: 18.w, color: Theme.of(context).primaryColor),
                  label: Text(
                    l10n.create_store_add_social,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (state.socialLinks.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  l10n.create_store_socials_empty,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.socialLinks.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final social = state.socialLinks[index];
                  return _SocialLinkTile(
                    social: social,
                    index: index,
                    onRemove: () =>
                        context.read<CreateStoreCubit>().removeSocialLink(index),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showAddSocialDialog(BuildContext context) {
    final socialIdController = TextEditingController();
    final linkController     = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.create_store_add_social),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: socialIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: l10n.create_store_social_id_hint,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: linkController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: l10n.create_store_social_link_hint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.create_store_cancel),
            ),
            TextButton(
              onPressed: () {
                final id = int.tryParse(socialIdController.text.trim());
                final link = linkController.text.trim();
                if (id != null && link.isNotEmpty) {
                  context.read<CreateStoreCubit>().addSocialLink(
                        socialId: id,
                        link: link,
                      );
                }
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.create_store_add_social),
            ),
          ],
        );
      },
    );
  }
}

class _SocialLinkTile extends StatelessWidget {
  final SocialLinkEntity social;
  final int index;
  final VoidCallback onRemove;

  const _SocialLinkTile({
    required this.social,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.divider, width: 1.w),
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: 18.w, color: Theme.of(context).primaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${social.socialId}',
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  social.link,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18.w, color: AppColors.error),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VERIFICATION DOCUMENTS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _VerificationDocsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueNotifier<File?> commercialRegister;
  final ValueNotifier<File?> taxCard;
  final ValueNotifier<File?> idCardFront;
  final ValueNotifier<File?> idCardBack;

  const _VerificationDocsSection({
    required this.l10n,
    required this.commercialRegister,
    required this.taxCard,
    required this.idCardFront,
    required this.idCardBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.create_store_verification_docs_label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        _DocPickerRow(
          label: l10n.create_store_commercial_register_hint,
          fileNotifier: commercialRegister,
        ),
        SizedBox(height: 10.h),
        _DocPickerRow(
          label: l10n.create_store_tax_card_hint,
          fileNotifier: taxCard,
        ),
        SizedBox(height: 10.h),
        _DocPickerRow(
          label: l10n.create_store_id_front_hint,
          fileNotifier: idCardFront,
        ),
        SizedBox(height: 10.h),
        _DocPickerRow(
          label: l10n.create_store_id_back_hint,
          fileNotifier: idCardBack,
        ),
      ],
    );
  }
}

class _DocPickerRow extends HookWidget {
  final String label;
  final ValueNotifier<File?> fileNotifier;

  const _DocPickerRow({required this.label, required this.fileNotifier});

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      fileNotifier.value = File(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileValue = useValueListenable(fileNotifier);
    final hasFile   = fileValue != null;

    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: hasFile
              ? Theme.of(context).primaryColor.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasFile ? Theme.of(context).primaryColor : AppColors.divider,
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle_outline : Icons.upload_file_outlined,
              size: 22.w,
              color: hasFile ? Theme.of(context).primaryColor : AppColors.textDisabled,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                hasFile
                    ? fileValue.path.split(RegExp(r'[/\\]')).last
                    : label,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 13,
                  color: hasFile ? AppColors.textPrimary : AppColors.textDisabled,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasFile)
              GestureDetector(
                onTap: () => fileNotifier.value = null,
                child: Icon(Icons.close, size: 18.w, color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION PICKER SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _LocationPickerSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _LocationPickerSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      buildWhen: (prev, next) =>
          prev.isLocationLoading != next.isLocationLoading ||
          prev.latitude != next.latitude ||
          prev.longitude != next.longitude,
      builder: (context, state) {
        final hasLocation = state.latitude.isNotEmpty && state.longitude.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.create_store_location_section_label,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: state.isLocationLoading
                  ? null
                  : () => context.read<CreateStoreCubit>().determinePosition(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: hasLocation
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.06)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: hasLocation
                        ? Theme.of(context).primaryColor
                        : AppColors.divider,
                    width: 1.5.w,
                  ),
                ),
                child: state.isLocationLoading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            l10n.create_store_locate_button,
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            hasLocation
                                ? Icons.location_on
                                : Icons.my_location_outlined,
                            size: 20.w,
                            color: hasLocation
                                ? Theme.of(context).primaryColor
                                : AppColors.textDisabled,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              hasLocation
                                  ? l10n.create_store_location_fetched
                                  : l10n.create_store_locate_button,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 13,
                                color: hasLocation
                                    ? AppColors.textPrimary
                                    : AppColors.textDisabled,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (hasLocation)
                            Icon(
                              Icons.check_circle,
                              size: 18.w,
                              color: Theme.of(context).primaryColor,
                            ),
                        ],
                      ),
              ),
            ),
          ],
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
                    activeColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    side: BorderSide(color: AppColors.divider, width: 1.5.w),
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
