import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// Mock Data Model to allow easy replacement when backend is ready
class MockFollower {
  final String name;
  final String username;
  final String avatarUrl;

  MockFollower({
    required this.name,
    required this.username,
    required this.avatarUrl,
  });
}

class FollowersShopPage extends StatelessWidget {
  const FollowersShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Using clean mock data to match the UI precisely
    // Can be easily swapped with a Cubit State list later.
    final followers = [
      MockFollower(name: 'Maryem kamal', username: 'marryyem', avatarUrl: 'https://i.pravatar.cc/150?img=5'),
      MockFollower(name: 'youstina', username: 'ttina', avatarUrl: 'https://i.pravatar.cc/150?img=47'),
      MockFollower(name: 'youstina', username: 'ttina', avatarUrl: 'https://i.pravatar.cc/150?img=40'),
      MockFollower(name: 'youstina', username: 'ttina', avatarUrl: 'https://i.pravatar.cc/150?img=44'),
      MockFollower(name: 'youstina', username: 'ttina', avatarUrl: 'https://i.pravatar.cc/150?img=43'),
      MockFollower(name: 'youstina', username: 'ttina', avatarUrl: 'https://i.pravatar.cc/150?img=42'),
      MockFollower(name: 'youstina', username: 'ttina', avatarUrl: 'https://i.pravatar.cc/150?img=41'),
      MockFollower(name: 'youstina', username: 'ttina', avatarUrl: 'https://i.pravatar.cc/150?img=45'),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: AppColors.textPrimary),
        title: Text(
          l10n.followers_page_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Container(
        color: AppColors.surface,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          itemCount: followers.length,
          separatorBuilder: (context, index) => SizedBox(height: 18.h),
          itemBuilder: (context, index) {
            return _buildFollowerItem(context, followers[index], l10n);
          },
        ),
      ),
    );
  }

  Widget _buildFollowerItem(BuildContext context, MockFollower follower, AppLocalizations l10n) {
    return Row(
      children: [
        // Avatar (First element in Row renders on the Right in RTL Locale)
        CircleAvatar(
          radius: 26.r,
          backgroundImage: NetworkImage(follower.avatarUrl),
          backgroundColor: AppColors.divider,
        ),
        SizedBox(width: 14.w),
        
        // User Info (Name & Username)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              follower.name,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              follower.username,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        
        const Spacer(),

        // Follow Button
        Container(
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.primaryOfSeller, width: 1.2),
          ),
          child: Center(
            child: Text(
              l10n.followers_page_follow_btn,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryOfSeller,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
