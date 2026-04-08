import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

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
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, l10n),
      body: _buildBody(context, l10n),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.contact_us_page_title,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 20,
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.h),

          // ── WhatsApp Button ─────────────────────────────────────────────────
          _buildContactButton(
            context: context,
            icon: Icons.chat_rounded,
            label: l10n.contact_whatsapp,
            onTap: () => _launchWhatsApp(context),
          ),

          // ── Facebook Button ─────────────────────────────────────────────────
          _buildContactButton(
            context: context,
            icon: Icons.facebook_rounded,
            label: l10n.contact_facebook,
            onTap: () => _launchUrl(context, _facebookUrl),
          ),

          // ── Website Button ──────────────────────────────────────────────────
          _buildContactButton(
            context: context,
            icon: Icons.language_rounded,
            label: l10n.contact_website,
            onTap: () => _launchUrl(context, _websiteUrl),
          ),

          // ── Instagram Button ────────────────────────────────────────────────
          _buildContactButton(
            context: context,
            icon: Icons.camera_alt_outlined,
            label: l10n.contact_instagram,
            onTap: () => _launchUrl(context, _instagramUrl),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ── Contact Button Widget ──────────────────────────────────────────────────
  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24.w,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 12.w),
                Text(
                  label,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Launch WhatsApp ────────────────────────────────────────────────────────
  Future<void> _launchWhatsApp(BuildContext context) async {
    final whatsappUrl = Uri.parse('https://wa.me/2$_whatsappNumber');
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context);
      }
    }
  }

  // ── Launch URL ─────────────────────────────────────────────────────────────
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context);
      }
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
