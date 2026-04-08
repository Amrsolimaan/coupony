import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/buttons.dart';

/// Address Label Dialog
/// Shows a dialog to input a label for the address
class AddressLabelDialog extends StatefulWidget {
  final String? initialLabel;

  const AddressLabelDialog({
    super.key,
    this.initialLabel,
  });

  static Future<String?> show(
    BuildContext context, {
    String? initialLabel,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddressLabelDialog(initialLabel: initialLabel),
    );
  }

  @override
  State<AddressLabelDialog> createState() => _AddressLabelDialogState();
}

class _AddressLabelDialogState extends State<AddressLabelDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLabel);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title ──────────────────────────────────────────────────
              Text(
                l10n.address_label_dialog_title,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // ── Subtitle ───────────────────────────────────────────────
              Text(
                l10n.address_label_dialog_subtitle,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // ── Text Field ─────────────────────────────────────────────
              TextFormField(
                controller: _controller,
                autofocus: true,
                textAlign: TextAlign.center,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l10n.address_label_hint,
                  hintStyle: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    color: AppColors.textDisabled,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5.w,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.divider,
                      width: 1.5.w,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2.w,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.error,
                      width: 1.5.w,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.error,
                      width: 2.w,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.address_label_required;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleSave(),
              ),
              SizedBox(height: 24.h),

              // ── Save Button ────────────────────────────────────────────
              AppPrimaryButton(
                text: l10n.address_save,
                onPressed: _handleSave,
                size: AppButtonSize.medium,
                borderRadius: 12.r,
              ),
              SizedBox(height: 12.h),

              // ── Cancel Button ──────────────────────────────────────────
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  l10n.address_cancel,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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
