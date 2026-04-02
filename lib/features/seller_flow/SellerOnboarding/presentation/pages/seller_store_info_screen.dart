import 'dart:io';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_action_buttons.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_submit_button.dart';
import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/domain/entities/onboarding_user_type.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/cubit/onboarding_Seller_flow_cubit.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/cubit/onboarding_Seller_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

/// Seller Store Info Screen — Cubit Step 3 (bestOfferTime)
///
/// Remains [StatefulWidget] because it owns:
///   • [TextEditingController] for store name and description.
///   • [ImagePicker] + [File] state for the logo.
///
/// Cubit binding: the store name is forwarded to
/// [SellerOnboardingFlowCubit.selectBestOfferTime] so that [isStep3Valid]
/// is set and the master-page flow can advance.
class SellerStoreInfoScreen extends StatefulWidget {
  const SellerStoreInfoScreen({super.key});

  @override
  State<SellerStoreInfoScreen> createState() => _SellerStoreInfoScreenState();
}

class _SellerStoreInfoScreenState extends State<SellerStoreInfoScreen> {
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _logoImage;
  int _descriptionLength = 0;
  static const int _maxDescriptionLength = 200;

  static const _theme = CouponyThemeProvider(OnboardingUserType.seller);

  @override
  void initState() {
    super.initState();

    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
      });
    });

    // Forward store-name text to the cubit so isStep3Valid is updated.
    _storeNameController.addListener(_syncStoreNameToCubit);
  }

  void _syncStoreNameToCubit() {
    if (!mounted) return;
    final name = _storeNameController.text.trim();
    final cubit = context.read<SellerOnboardingFlowCubit>();
    if (name.isNotEmpty) {
      cubit.selectBestOfferTime(name);
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  bool _isLocallyValid() =>
      _storeNameController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _descriptionLength <= _maxDescriptionLength;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SellerOnboardingFlowCubit>();

    return BlocBuilder<SellerOnboardingFlowCubit, SellerOnboardingFlowState>(
      builder: (context, state) {
        final isNextEnabled = state.isStep3Valid && _isLocallyValid();

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 24.h),

                OnboardingStepIndicator(
                  currentStep: state.currentStep,
                  totalSteps: 4,
                  theme: _theme,
                ),

                SizedBox(height: 32.h),

                Text(
                  l10n.seller_store_info_title,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 24.h),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLogoPicker(l10n),
                        SizedBox(height: 24.h),
                        _buildTextField(
                          controller: _storeNameController,
                          hint: l10n.seller_store_name_hint,
                        ),
                        SizedBox(height: 16.h),
                        _buildDescriptionField(l10n),
                      ],
                    ),
                  ),
                ),

                OnboardingActionButtons(
                  nextLabel: l10n.next,
                  skipLabel: l10n.skip,
                  isNextEnabled: isNextEnabled,
                  isLoading: state.isSaving,
                  onNext: () => cubit.completeBestOfferTimeSelection(),
                  onSkip: () => cubit.skipOnboarding(),
                  theme: _theme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoPicker(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.seller_store_logo_label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: _pickLogo,
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.divider, width: 1.5.w),
            ),
            child: _logoImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(_logoImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40.w,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.seller_store_logo_hint,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return SizedBox(
      height: 56.h,
      child: TextField(
        controller: controller,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDisabled,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.divider, width: 1.5.w),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.divider, width: 1.5.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: _theme.primaryColor, width: 1.5.w),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    final hasError = _descriptionLength > _maxDescriptionLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: l10n.seller_store_description_hint,
            hintStyle: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDisabled,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.divider,
                width: 1.5.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.divider,
                width: 1.5.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : _theme.primaryColor,
                width: 1.5.w,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            '$_descriptionLength/$_maxDescriptionLength',
            style: AppTextStyles.customStyle(
              context,
              fontSize: 12,
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
