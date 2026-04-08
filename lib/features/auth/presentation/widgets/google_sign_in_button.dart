import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

import '../cubit/auth_state.dart';
import '../cubit/google_sign_in_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Google Sign-In Button
//
// Shared widget for Google authentication across login and register screens.
// Connects directly to GoogleSignInCubit and handles loading states.
// ─────────────────────────────────────────────────────────────────────────────

class GoogleSignInButton extends StatelessWidget {
  final String label;
  final String role;
  final Logger logger = Logger();

  GoogleSignInButton({
    super.key,
    required this.label,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Dynamic theme color based on active role (Customer=Orange, Seller=Blue)
    final primaryColor = Theme.of(context).primaryColor;
    
    // 🎨 Dynamic border color based on role
    final borderColor = role == 'seller' 
        ? AppColors.primaryOfSeller.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.3);
    
    return BlocBuilder<GoogleSignInCubit, AuthState>(
      builder: (context, state) {
        return SizedBox(
          height: 56.h,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: state.isLoading 
                ? null 
                : () => _handleGoogleSignIn(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: borderColor, width: 1.5.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              backgroundColor: AppColors.surface,
            ),
            child: state.isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/google_ic.svg',
                        width: 24.w,
                        height: 24.h,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        label,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _handleGoogleSignIn(BuildContext context) {
    logger.i("Google Sign-In started...");
    context.read<GoogleSignInCubit>().signInWithGoogle(role: role);
  }
}
