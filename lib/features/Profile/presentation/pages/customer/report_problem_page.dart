import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../../../auth/domain/entities/user_persona.dart';
import '../../../../auth/presentation/cubit/persona_cubit.dart';
import '../../../../auth/presentation/widgets/role_animation_wrapper.dart';
import '../../cubit/Customer_Profile_cubit.dart';
import '../../cubit/Customer_Profile_state.dart';
import '../../cubit/report_problem_cubit.dart';
import '../../cubit/report_problem_state.dart';
import '../../cubit/stores_display_cubit.dart';

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
  void initState() {
    super.initState();
    // Load stores for sellers after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = (context.read<PersonaCubit>().state is SellerPersona ? 'seller' : 'customer');
      if (role == 'seller') {
        context.read<StoresDisplayCubit>().loadStores();
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (_) => di.sl<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<StoresDisplayCubit>(
          create: (_) => di.sl<StoresDisplayCubit>(),
        ),
        BlocProvider<ReportProblemCubit>(
          create: (_) => di.sl<ReportProblemCubit>(),
        ),
      ],
      child: BlocListener<ReportProblemCubit, ReportProblemState>(
        listener: (context, state) {
          if (state is ReportProblemSuccess) {
            context.showSuccessSnackBar(state.message);
            context.pop();
          } else if (state is ReportProblemError) {
            context.showErrorSnackBar(state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(context, l10n),
          body: SafeArea(bottom: true, child: _buildBody(context, l10n)),
        ),
      ),
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
          Icons.arrow_back_ios_rounded,
          size: 20.w,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        // Show loading indicator while profile is loading
        if (profileState is ProfileLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }

        // Show error if profile failed to load
        if (profileState is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.w,
                  color: AppColors.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.profile_error,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => context.read<ProfileCubit>().loadProfile(),
                  child: Text(l10n.profile_retry),
                ),
              ],
            ),
          );
        }

        // Show form when profile is loaded
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
      },
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
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit Button ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<ReportProblemCubit, ReportProblemState>(
      builder: (context, state) {
        final isLoading = state is ReportProblemLoading;

        return AnimatedPrimaryColor(
          builder: (context, primaryColor) {
            return Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : () => _handleSubmit(context, l10n),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
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
          },
        );
      },
    );
  }

  // ── Handle Submit ──────────────────────────────────────────────────────────
  void _handleSubmit(BuildContext context, AppLocalizations l10n) {
    // Validate form fields
    if (_subjectController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      context.showErrorSnackBar(l10n.report_problem_empty_error);
      return;
    }

    // Get current role
    final role = (context.read<PersonaCubit>().state is SellerPersona ? 'seller' : 'customer');

    // Get user data from ProfileCubit
    final profileState = context.read<ProfileCubit>().state;
    
    // Handle different profile states
    if (profileState is ProfileLoading) {
      context.showInfoSnackBar(l10n.permissions_please_wait);
      return;
    }
    
    if (profileState is! ProfileLoaded) {
      // Try to load profile if not loaded
      context.read<ProfileCubit>().loadProfile();
      context.showInfoSnackBar(l10n.permissions_please_wait);
      return;
    }

    final user = profileState.user;
    final name = user.fullName;
    final email = user.email;
    final phone = user.phoneNumber;
    final message = _descriptionController.text.trim();

    // Submit based on role
    if (role == 'seller') {
      // For seller: Get company name from stores
      final storesState = context.read<StoresDisplayCubit>().state;
      
      if (storesState is StoresDisplayLoading) {
        context.showInfoSnackBar(l10n.permissions_please_wait);
        return;
      }
      
      if (storesState is! StoresDisplayLoaded || storesState.stores.isEmpty) {
        // Try to load stores if not loaded
        context.read<StoresDisplayCubit>().loadStores();
        context.showInfoSnackBar(l10n.permissions_please_wait);
        return;
      }

      final company = storesState.stores.first.name;

      // Submit seller report
      context.read<ReportProblemCubit>().submitSellerReport(
            name: name,
            email: email,
            phone: phone,
            company: company,
            message: message,
          );
    } else {
      // For customer: Use subject field
      final subject = _subjectController.text.trim();

      // Submit customer report
      context.read<ReportProblemCubit>().submitCustomerReport(
            name: name,
            email: email,
            phone: phone,
            subject: subject,
            message: message,
          );
    }
  }
}
