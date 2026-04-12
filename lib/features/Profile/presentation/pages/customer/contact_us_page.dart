import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../widgets/shared_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONTACT US PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  // ── Social Media Constants ─────────────────────────────────────────────────
  static const String _whatsappNumber = '01000724083';
  static const String _facebookUrl =
      'https://www.facebook.com/profile.php?id=61587275917807';
  static const String _websiteUrl = 'https://coupony.shop/ar/consumer';
  static const String _instagramUrl =
      'https://www.instagram.com/coupony_fym?igsh=MWx0OXFnYjU1YzZ4dw==';

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
        l10n.contact_us_page_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Center(
          child: FaIcon(
            FontAwesomeIcons.chevronRight,
            size: 20.w,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 24.h),

          // ── Header Section ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                // ── Contact Icon ────────────────────────────────────────────────
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.headset,
                      size: 38.w,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Title ───────────────────────────────────────────────────────
                Text(
                  l10n.contact_us_heading,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),

                // ── Subtitle ────────────────────────────────────────────────────
                Text(
                  l10n.contact_us_description,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // ── WhatsApp ────────────────────────────────────────────────────────
          _buildContactCard(
            context: context,
            icon: FontAwesomeIcons.whatsapp,
            label: l10n.contact_whatsapp,
            color: const Color(0xFF25D366),
            onTap: () => _launchWhatsApp(context),
          ),

          // ── Facebook ────────────────────────────────────────────────────────
          _buildContactCard(
            context: context,
            icon: FontAwesomeIcons.facebook,
            label: l10n.contact_facebook,
            color: const Color(0xFF1877F2),
            onTap: () => _launchUrl(context, _facebookUrl),
          ),

          // ── Website ─────────────────────────────────────────────────────────
          _buildContactCard(
            context: context,
            icon: FontAwesomeIcons.globe,
            label: l10n.contact_website,
            color: AppColors.primary,
            onTap: () => _launchUrl(context, _websiteUrl),
          ),

          // ── Instagram ───────────────────────────────────────────────────────
          _buildContactCard(
            context: context,
            icon: FontAwesomeIcons.instagram,
            label: l10n.contact_instagram,
            color: const Color(0xFFE4405F),
            onTap: () => _launchUrl(context, _instagramUrl),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ── Contact Card Widget ────────────────────────────────────────────────────
  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SharedProfileCard(
      title: '',
      onTap: onTap,
      child: Row(
        children: [
          // ── Colored Icon Circle ─────────────────────────────────────────────
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                icon,
                size: 24.w,
                color: color,
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // ── Label ───────────────────────────────────────────────────────────
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // ── Arrow Icon ──────────────────────────────────────────────────────
          Icon(
            Icons.arrow_back_ios_rounded,
            size: 16.w,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // ── Launch WhatsApp ────────────────────────────────────────────────────────
  Future<void> _launchWhatsApp(BuildContext context) async {
    final whatsappUrl = Uri.parse('https://wa.me/2$_whatsappNumber');
    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) _showErrorSnackBar(context);
    }
  }

  // ── Launch URL ─────────────────────────────────────────────────────────────
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) _showErrorSnackBar(context);
    }
  }

  // ── Error SnackBar ─────────────────────────────────────────────────────────
  void _showErrorSnackBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.contact_open_error,
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
}
