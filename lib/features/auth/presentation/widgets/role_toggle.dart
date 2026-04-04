import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/auth_role_cubit.dart';
import '../cubit/auth_role_state.dart';
import 'role_animation_wrapper.dart';

/// Role toggle widget — user / seller selector.
/// NOW USES GLOBAL AuthRoleCubit FOR PERSISTENCE
/// 
/// Now with magical color animation when switching roles!
class RoleToggle extends StatelessWidget {
  final String userLabel;
  final String merchantLabel;

  const RoleToggle({
    super.key,
    required this.userLabel,
    required this.merchantLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPrimaryColor(
      builder: (context, primaryColor) {
        return BlocBuilder<AuthRoleCubit, AuthRoleState>(
          builder: (context, roleState) {
            final selectedRole = roleState.role;
            
            return Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: _Segment(
                      label: userLabel,
                      value: 'customer',
                      selected: selectedRole == 'customer',
                      primaryColor: primaryColor,
                      onTap: () => context.read<AuthRoleCubit>().setRole('customer'),
                    ),
                  ),
                  Expanded(
                    child: _Segment(
                      label: merchantLabel,
                      value: 'seller',
                      selected: selectedRole == 'seller',
                      primaryColor: primaryColor,
                      onTap: () => context.read<AuthRoleCubit>().setRole('seller'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.value,
    required this.selected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 48.h,
        margin: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}