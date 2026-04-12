import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/widgets/custom_bottom_nav_bar/customer_bottom_nav_bar.dart';
import 'package:coupony/features/auth/presentation/cubit/auth_state.dart';
import 'package:coupony/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<LoginCubit, AuthState>(
      listener: (context, state) {
        if (state.navSignal == AuthNavigation.toLogin) {
          context.go(AppRouter.login);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            l10n.home,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.grey.shade700,
                size: 24.w,
              ),
              tooltip: l10n.logout,
              onPressed: () => _showLogoutDialog(context, l10n),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Text(
              'Home Page',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 4,
          onTap: (index) {
            if (index == 0) {
              context.push(AppRouter.customerProfile);
            }
            // TODO: Handle other navigation
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.logout_dialog_title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.logout_dialog_message,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.logout_dialog_cancel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LoginCubit>().logout();
            },
            child: Text(
              l10n.logout_dialog_confirm,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
