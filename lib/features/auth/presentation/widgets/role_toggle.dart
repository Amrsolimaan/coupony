import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Role toggle widget — user / merchant selector.
/// Uses [ValueNotifier<String>] so the parent can read the selected role
/// without rebuilding the whole tree.
class RoleToggle extends StatelessWidget {
  final ValueNotifier<String> roleNotifier;
  final String userLabel;
  final String merchantLabel;

  const RoleToggle({
    super.key,
    required this.roleNotifier,
    required this.userLabel,
    required this.merchantLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: roleNotifier,
      builder: (context, selectedRole, _) {
        return Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
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
                  onTap: () => roleNotifier.value = 'customer',
                ),
              ),
              Expanded(
                child: _Segment(
                  label: merchantLabel,
                  value: 'merchant',
                  selected: selectedRole == 'merchant',
                  onTap: () => roleNotifier.value = 'merchant',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48.h,
        margin: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
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