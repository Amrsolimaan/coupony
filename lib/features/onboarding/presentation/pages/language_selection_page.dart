import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;

import '../../../../config/routes/app_router.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Language Selection Page - Coupony
///
/// Modern, minimalist design with smart language switching
/// - Title changes based on selected language (Arabic or English only)
/// - Pre-selects device locale
/// - Clean typography and spacing
class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  late String _selectedLanguage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select system language
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    _selectedLanguage = systemLocale.languageCode == 'ar' ? 'ar' : 'en';
  }

  void _onLanguageTapped(String languageCode) {
    if (_isLoading) return;
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _onContinue() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save language preference and trigger locale rebuild
      await context.read<LocaleCubit>().changeLocale(_selectedLanguage);

      if (mounted) {
        context.go(AppRouter.permissionSplash);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  SizedBox(height: 80.h),

                  // Logo
                  _buildLogo(),

                  SizedBox(height: 60.h),

                  // Title (changes based on selected language)
                  _buildTitle(),

                  SizedBox(height: 48.h),

                  // Language Options
                  _buildLanguageOption(
                    languageCode: 'ar',
                    languageName: 'العربية',
                    isSelected: _selectedLanguage == 'ar',
                  ),

                  SizedBox(height: 16.h),

                  _buildLanguageOption(
                    languageCode: 'en',
                    languageName: 'English',
                    isSelected: _selectedLanguage == 'en',
                  ),

                  const Spacer(),

                  // Continue Button
                  _buildContinueButton(),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          // Full-screen loading overlay
          if (_isLoading)
            Container(
              color: AppColors.surface.withValues(alpha: 0.75),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3.w,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Text(
      'Coupony',
      style: AppTextStyles.customStyle(
        context,
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        letterSpacing: 0,
        fontFamily: AppTextStyles.Main_Font_logo,
      ),
    );
  }

  Widget _buildTitle() {
    // Smart title: Shows ONLY the selected language
    final title = _selectedLanguage == 'ar' ? 'اختر لغتك' : 'Choose Your Language';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        title,
        key: ValueKey(_selectedLanguage),
        style: AppTextStyles.customStyle(
          context,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLanguageOption({
    required String languageCode,
    required String languageName,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onLanguageTapped(languageCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            // Language Name
            Expanded(
              child: Text(
                languageName,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),

            // Selection Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey600,
                  width: 2.w,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: AppColors.surface,
                      size: 14.sp,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.grey200,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  color: AppColors.surface,
                  strokeWidth: 2.5.w,
                ),
              )
            : Text(
                _selectedLanguage == 'ar' ? 'متابعة' : 'Continue',
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: AppColors.surface,
                ),
              ),
      ),
    );
  }
}
