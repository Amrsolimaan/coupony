// lib/features/onboarding/presentation/pages/customer_onboarding/onboarding_preferences_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_action_buttons.dart';
import 'package:coupony/core/widgets/Shared_Onboarding/onboarding_submit_button.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/entities/category_entity.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/use_cases/get_categories_use_case.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/cubit/onboarding_flow_cubit.dart';
import 'package:coupony/features/user_flow/CustomerOnboarding/presentation/cubit/onboarding_flow_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:coupony/core/widgets/providers_theme/coupony_theme_provider.dart';
import 'package:coupony/config/dependency_injection/injection_container.dart' as di;

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING CATEGORY SELECTION SCREEN (STEP 1/3)
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingCategorySelectionScreen extends StatefulWidget {
  const OnboardingCategorySelectionScreen({super.key});

  @override
  State<OnboardingCategorySelectionScreen> createState() =>
      _OnboardingCategorySelectionScreenState();
}

class _OnboardingCategorySelectionScreenState
    extends State<OnboardingCategorySelectionScreen> {
  List<CategoryEntity> _categories = [];
  bool _isLoading = true;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorKey = null;
    });

    final getCategoriesUseCase = di.sl<GetCategoriesUseCase>();
    final result = await getCategoriesUseCase();

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorKey = failure.message;
        });
      },
      (categories) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingCategorySelectionView(
      categories: _categories,
      isLoading: _isLoading,
      errorKey: _errorKey,
      onRetry: _loadCategories,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY SELECTION VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingCategorySelectionView extends StatelessWidget {
  final List<CategoryEntity> categories;
  final bool isLoading;
  final String? errorKey;
  final VoidCallback onRetry;

  const _OnboardingCategorySelectionView({
    required this.categories,
    required this.isLoading,
    required this.errorKey,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<OnboardingFlowCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<OnboardingFlowCubit, OnboardingFlowState>(
          listener: (context, state) {
            if (state.navigationSignal == OnboardingNavigation.toBudget) {
              context.push(AppRouter.onboardingBudget);
              cubit.clearNavigationSignal();
            }

            if (state.navigationSignal == OnboardingNavigation.toHome) {
              context.go(AppRouter.home);
              cubit.clearNavigationSignal();
            }

            if (state.successMessageKey != null &&
                state.successMessageKey!.isNotEmpty) {
              context.showSuccessSnackBar(
                context.getLocalizedMessage(state.successMessageKey),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<OnboardingFlowCubit>().clearSuccessMessage();
                }
              });
            }

            if (state.errorMessageKey != null) {
              context.showErrorSnackBar(
                context.getLocalizedMessage(state.errorMessageKey),
              );
            }
          },
          builder: (context, state) {
            final theme = CouponyThemeProvider(state.userType);

            return Column(
              children: [
                SizedBox(height: 24.h),

                // ── Step Indicator ──────────────────────────────────────────
                OnboardingStepIndicator(
                  currentStep: 1,
                  totalSteps: 3,
                  theme: theme,
                ),

                SizedBox(height: 32.h),

                // ── Title & Subtitle ────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.onboardingTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.onboardingSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Category List ───────────────────────────────────────────
                Expanded(
                  child: _buildCategoryContent(context, state, theme, l10n),
                ),

                // ── Action Buttons ──────────────────────────────────────────
                OnboardingActionButtons(
                  nextLabel: l10n.next,
                  skipLabel: l10n.skip,
                  isNextEnabled: state.isStep1Valid,
                  isLoading: state.isSaving,
                  onNext: () => cubit.completeCategorySelection(),
                  onSkip: () => cubit.skipOnboarding(),
                  theme: theme,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryContent(
    BuildContext context,
    OnboardingFlowState state,
    CouponyThemeProvider theme,
    AppLocalizations l10n,
  ) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.primaryColor,
        ),
      );
    }

    if (errorKey != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              context.getLocalizedMessage(errorKey),
              textAlign: TextAlign.center,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                l10n.retry,
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
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Text(
          l10n.no_categories_available,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // ✅ Original ListView Design with API Data
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: categories.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryKey = category.slug ?? category.id.toString();
        final isSelected = state.selectedCategories.contains(categoryKey);

        return _CategorySelectionCard(
          category: category,
          isSelected: isSelected,
          onTap: () => context.read<OnboardingFlowCubit>().toggleCategory(
                categoryKey,
              ),
          theme: theme,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY SELECTION CARD (Original Design with API Data)
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySelectionCard extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;
  final CouponyThemeProvider theme;

  const _CategorySelectionCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? theme.primaryColor : AppColors.grey200,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryWithOpacity(0.1),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Radio Indicator
            _buildRadioIndicator(),
            const Spacer(),
            // Content
            Expanded(
              flex: 8,
              child: Text(
                category.name,
                textAlign: TextAlign.right,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            // Icon (from API or fallback)
            SizedBox(width: 12.w),
            _buildIconContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20.w,
      height: 20.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? theme.primaryColor : AppColors.surface,
        border: Border.all(
          color: isSelected ? theme.primaryColor : AppColors.textDisabled,
          width: 2.w,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 8.w,
                height: 8.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildIconContainer(BuildContext context) {
    // If icon_url is available, show network image
    if (category.iconUrl != null && category.iconUrl!.isNotEmpty) {
      return _buildNetworkIcon(context);
    }

    // Fallback to default icon
    return _buildFallbackIcon();
  }

  Widget _buildNetworkIcon(BuildContext context) {
    final iconUrl = category.iconUrl!;
    final isSvg = iconUrl.toLowerCase().endsWith('.svg');

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryWithOpacity(0.1)
            : AppColors.grey200,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: isSvg
          ? SvgPicture.network(
              iconUrl,
              width: 24.w,
              height: 24.w,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => _buildLoadingIcon(),
              // ✅ REMOVED: color parameter to preserve original SVG colors
            )
          : CachedNetworkImage(
              imageUrl: iconUrl,
              width: 24.w,
              height: 24.w,
              fit: BoxFit.contain,
              placeholder: (context, url) => _buildLoadingIcon(),
              errorWidget: (context, url, error) => _buildFallbackIcon(),
            ),
    );
  }

  Widget _buildLoadingIcon() {
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: Center(
        child: SizedBox(
          width: 16.w,
          height: 16.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryWithOpacity(0.1)
            : AppColors.grey200,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        Icons.category,
        size: 24.w,
        color: isSelected ? theme.primaryColor : AppColors.grey600,
      ),
    );
  }
}
