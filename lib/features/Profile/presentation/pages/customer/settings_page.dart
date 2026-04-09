import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/core/localization/locale_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/auth_state.dart';
import 'package:coupony/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../cubit/Customer_Profile_cubit.dart';
import '../../cubit/Customer_Profile_state.dart';
import '../../widgets/shared_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS PAGE
// ─────────────────────────────────────────────────────────────────────────────

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider<LoginCubit>(
      create: (_) => di.sl<LoginCubit>(),
      child: BlocListener<LoginCubit, AuthState>(
        listener: (context, state) {
          if (state.navSignal == AuthNavigation.toLogin) {
            context.go(AppRouter.login);
          }
        },
        child: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileDeleteSuccess) {
              context.go(AppRouter.login);
            }
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
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
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.surface,
            appBar: _buildAppBar(context, l10n),
            body: _buildBody(context, l10n),
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        l10n.settings_page_title,
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // ── App Settings Section ─────────────────────────────────────────────
                _buildSectionHeader(context, l10n.settings_app_section),
                _buildLanguageCard(context, l10n),
                _buildNotificationsCard(context, l10n),

                SizedBox(height: 8.h),

                // ── Data Management Section ──────────────────────────────────────────
                _buildSectionHeader(context, l10n.settings_data_section),
                _buildDeleteAccountCard(context, l10n),

                SizedBox(height: 8.h),

                // ── Privacy & Security Section ───────────────────────────────────────
                _buildSectionHeader(context, l10n.settings_security_section),
                _buildChangePasswordCard(context, l10n),

                SizedBox(height: 8.h),

                // ── Legal Section ────────────────────────────────────────────────────
                _buildSectionHeader(context, l10n.settings_legal_section),
                SharedProfileCard(
                  title: l10n.settings_terms_of_use,
                  icon: null,
                  useFontAwesome: false,
                  onTap: () => context.push(AppRouter.termsPage),
                ),
                SharedProfileCard(
                  title: l10n.settings_privacy_policy,
                  icon: null,
                  useFontAwesome: false,
                  onTap: () => context.push(AppRouter.privacyPolicyPage),
                ),

                SizedBox(height: 8.h),

                // ── About Section ────────────────────────────────────────────────────
                _buildAboutSection(context, l10n),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
            child: _buildLogoutButton(context, l10n),
          ),
        ),
      ],
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
      child: Text(
        title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ── Language Card ──────────────────────────────────────────────────────────
  Widget _buildLanguageCard(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final currentLang = locale.languageCode == 'ar'
            ? l10n.language_arabic
            : l10n.language_english;

        return SharedProfileCard(
          title: l10n.settings_language,
          subtitle: currentLang,
          leading: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.language_rounded,
              size: 20.w,
              color: AppColors.primary,
            ),
          ),
          onTap: () => _showLanguageDialog(context, l10n, locale.languageCode),
        );
      },
    );
  }

  // ── Notifications Card ─────────────────────────────────────────────────────
  Widget _buildNotificationsCard(BuildContext context, AppLocalizations l10n) {
    return SharedProfileCard(
      title: l10n.settings_notifications,
      leading: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.notifications_rounded,
          size: 20.w,
          color: AppColors.primary,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.85,
        child: Switch(
          value: _notificationsEnabled,
          onChanged: (val) => setState(() => _notificationsEnabled = val),
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ── Delete Account Card ────────────────────────────────────────────────────
  Widget _buildDeleteAccountCard(BuildContext context, AppLocalizations l10n) {
    return SharedProfileCard(
      title: l10n.settings_delete_account,
      subtitle: l10n.settings_delete_account_subtitle,
      leading: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.delete_forever_rounded,
          size: 20.w,
          color: AppColors.error,
        ),
      ),
      child: Row(
        children: [
          // Leading icon
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.delete_forever_rounded,
              size: 20.w,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settings_delete_account,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.settings_delete_account_subtitle,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16.w,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      onTap: () => _showDeleteAccountDialog(context, l10n),
    );
  }

  // ── Change Password Card ───────────────────────────────────────────────────
  Widget _buildChangePasswordCard(BuildContext context, AppLocalizations l10n) {
    return SharedProfileCard(
      title: l10n.settings_change_password,
      subtitle: l10n.settings_change_password_subtitle,
      leading: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: FaIcon(
          FontAwesomeIcons.key,
          size: 17.w,
          color: AppColors.primary,
        ),
      ),
      onTap: () => context.push(AppRouter.changePassword),
    );
  }

  // ── About Section ──────────────────────────────────────────────────────────
  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.settings_about_app,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.settings_app_version,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.settings_copyright,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout Button ──────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLogoutDialog(context, l10n),
            borderRadius: BorderRadius.circular(14.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 20.w,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10.w),
                Text(
                  l10n.logout,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Language Dialog ────────────────────────────────────────────────────────
  void _showLanguageDialog(
      BuildContext context, AppLocalizations l10n, String currentLang) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String selected = currentLang;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Close Button ─────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: AppColors.grey200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16.w,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // ── Title ────────────────────────────────────────────────
                    Text(
                      l10n.language_dialog_title,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      l10n.language_dialog_subtitle,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Arabic Option ────────────────────────────────────────
                    _buildLanguageOption(
                      context: context,
                      title: l10n.language_arabic_full,
                      subtitle: 'Arabic',
                      languageCode: 'ar',
                      selected: selected,
                      onTap: () {
                        setDialogState(() => selected = 'ar');
                        context.read<LocaleCubit>().changeLocale('ar');
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    SizedBox(height: 12.h),

                    // ── English Option ───────────────────────────────────────
                    _buildLanguageOption(
                      context: context,
                      title: l10n.language_english_full,
                      subtitle: l10n.language_english_subtitle,
                      languageCode: 'en',
                      selected: selected,
                      onTap: () {
                        setDialogState(() => selected = 'en');
                        context.read<LocaleCubit>().changeLocale('en');
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String languageCode,
    required String selected,
    required VoidCallback onTap,
  }) {
    final isSelected = selected == languageCode;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider,
            width: isSelected ? 2.w : 1.5.w,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surface,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 6.w : 1.5.w,
                ),
                color: isSelected ? AppColors.primary : AppColors.surface,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Account Dialog ──────────────────────────────────────────────────
  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    final passwordController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final canConfirm = passwordController.text.isNotEmpty;
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Icon ────────────────────────────────────────────────
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        size: 32.w,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Title ────────────────────────────────────────────────
                    Text(
                      l10n.delete_account_dialog_title,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),

                    // ── Message ──────────────────────────────────────────────
                    Text(
                      l10n.delete_account_dialog_message,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),

                    // ── Password Field ───────────────────────────────────────
                    TextField(
                      controller: passwordController,
                      obscureText: obscure,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.change_password_current_label,
                        hintStyle: AppTextStyles.customStyle(
                          context,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.grey200,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20.w,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () =>
                              setDialogState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Confirm Button ───────────────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: canConfirm
                            ? AppColors.error
                            : AppColors.grey200,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: canConfirm
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.error.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14.r),
                          onTap: canConfirm
                              ? () {
                                  final password = passwordController.text;
                                  Navigator.of(dialogContext).pop();
                                  context
                                      .read<ProfileCubit>()
                                      .deleteAccount(password);
                                }
                              : null,
                          child: Center(
                            child: Text(
                              l10n.delete_account_confirm_button,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: canConfirm
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // ── Cancel Button ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.primary,
                            width: 1.5.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => passwordController.dispose());
  }

  // ── Logout Dialog ──────────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            l10n.logout_dialog_title,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            l10n.logout_dialog_message,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.divider, width: 1.5.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      l10n.logout_dialog_cancel,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<LoginCubit>().logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      l10n.logout_dialog_confirm,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
