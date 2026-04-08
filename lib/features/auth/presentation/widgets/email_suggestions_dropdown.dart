import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Modern dropdown for displaying saved email suggestions
/// Appears below the email text field with smooth animations
/// Max 3 visible items with scroll for more
class EmailSuggestionsDropdown extends StatelessWidget {
  final List<String> emails;
  final Function(String) onEmailSelected;
  final Function(String) onEmailRemoved;
  final Color primaryColor;
  
  static const int maxVisibleItems = 3;
  static const double itemHeight = 60.0;

  const EmailSuggestionsDropdown({
    super.key,
    required this.emails,
    required this.onEmailSelected,
    required this.onEmailRemoved,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (emails.isEmpty) return const SizedBox.shrink();

    // Calculate height: max 3 items visible, then scroll
    final visibleCount = emails.length > maxVisibleItems ? maxVisibleItems : emails.length;
    final containerHeight = visibleCount * itemHeight;

    return Container(
      margin: EdgeInsets.only(top: 4.h),
      constraints: BoxConstraints(
        maxHeight: containerHeight.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: emails.length,
          itemBuilder: (context, index) {
            return _EmailSuggestionItem(
              email: emails[index],
              primaryColor: primaryColor,
              onTap: () => onEmailSelected(emails[index]),
              onRemove: () => onEmailRemoved(emails[index]),
            );
          },
        ),
      ),
    );
  }
}

class _EmailSuggestionItem extends StatelessWidget {
  final String email;
  final Color primaryColor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _EmailSuggestionItem({
    required this.email,
    required this.primaryColor,
    required this.onTap,
    required this.onRemove,
  });

  /// Get first letter of email for avatar
  String get _initial {
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // Avatar with first letter
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initial,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              
              // Email text
              Expanded(
                child: Text(
                  email,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Remove button
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: onRemove,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.close,
                      size: 18.w,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
