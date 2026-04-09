import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORT PROBLEM PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context, l10n),
      body: SafeArea(bottom: true, child: _buildBody(context, l10n)),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        l10n.help_report_problem_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            // ── Description Text ──────────────────────────────────────────────
            Text(
              l10n.report_problem_description,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // ── Subject Field ─────────────────────────────────────────────────
            _buildTextField(
              context: context,
              controller: _subjectController,
              label: l10n.report_problem_subject,
              maxLines: 1,
            ),
            SizedBox(height: 16.h),

            // ── Description Field ─────────────────────────────────────────────
            _buildTextField(
              context: context,
              controller: _descriptionController,
              label: l10n.report_problem_details,
              maxLines: 6,
            ),
            SizedBox(height: 32.h),

            // ── Submit Button ─────────────────────────────────────────────────
            _buildSubmitButton(context, l10n),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Text Field Widget ──────────────────────────────────────────────────────
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textInputAction:
              maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDisabled,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.divider, width: 1.5.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.divider, width: 1.5.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSubmit(context, l10n),
          borderRadius: BorderRadius.circular(14.r),
          child: Center(
            child: Text(
              l10n.report_problem_submit,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Handle Submit ──────────────────────────────────────────────────────────
  void _handleSubmit(BuildContext context, AppLocalizations l10n) {
    if (_subjectController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.report_problem_empty_error,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }

    // TODO: Send report to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.report_problem_success,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
    context.pop();
  }
}
