import 'package:coupony/config/dependency_injection/injection_container.dart' as di;
import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/cubit/onboarding_Seller_flow_cubit.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/cubit/onboarding_Seller_flow_state.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/pages/seller_delivery_method_screen.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/pages/seller_price_range_screen.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/pages/seller_store_info_screen.dart';
import 'package:coupony/features/seller_flow/SellerOnboarding/presentation/pages/seller_target_audience_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Master page for the 4-step Seller Onboarding flow.
///
/// Responsibilities:
///   - Provides [SellerOnboardingFlowCubit] to the entire subtree.
///   - Listens for navigation signals and shows snack-bars.
///   - Delegates rendering to the correct step screen via [BlocBuilder].
///
/// Step routing (cubit-driven, no separate GoRouter entries):
///   currentStep 1 → [SellerPriceRangeScreen]
///   currentStep 2 → [SellerDeliveryMethodScreen]
///   currentStep 3 → [SellerStoreInfoScreen]
///   currentStep 4 → [SellerTargetAudienceScreen]
class SellerOnboardingPage extends StatelessWidget {
  const SellerOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SellerOnboardingFlowCubit>(
      create: (_) => di.sl<SellerOnboardingFlowCubit>(),
      child: BlocListener<SellerOnboardingFlowCubit, SellerOnboardingFlowState>(
        listener: (context, state) {
          // ── Navigation signals ────────────────────────────────────────────
          if (state.navigationSignal == SellerOnboardingNavigation.toCreateStore) {
            final router = GoRouter.of(context);
            context.read<SellerOnboardingFlowCubit>().clearNavigationSignal();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              router.go(AppRouter.createStore);
            });
          }

          if (state.navigationSignal == SellerOnboardingNavigation.toLogin) {
            context.read<SellerOnboardingFlowCubit>().clearNavigationSignal();
            GoRouter.of(context).go(AppRouter.home);
          }

          // ── Error messages ─────────────────────────────────────────────────
          if (state.apiErrorKey != null) {
            context.showErrorSnackBar(
              context.getLocalizedMessage(state.apiErrorKey),
            );
          }

          if (state.errorMessageKey != null) {
            context.showErrorSnackBar(
              context.getLocalizedMessage(state.errorMessageKey),
            );
          }

          // ── Success messages ───────────────────────────────────────────────
          if (state.successMessageKey != null &&
              state.successMessageKey!.isNotEmpty) {
            context.showSuccessSnackBar(
              context.getLocalizedMessage(state.successMessageKey),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context
                    .read<SellerOnboardingFlowCubit>()
                    .clearSuccessMessage();
              }
            });
          }
        },

        // ── Step screen switcher ─────────────────────────────────────────────
        child: BlocBuilder<SellerOnboardingFlowCubit, SellerOnboardingFlowState>(
          buildWhen: (prev, next) => prev.currentStep != next.currentStep,
          builder: (context, state) {
            switch (state.currentStep) {
              case 2:
                return const SellerDeliveryMethodScreen();
              case 3:
                return const SellerStoreInfoScreen();
              case 4:
                return const SellerTargetAudienceScreen();
              case 1:
              default:
                return const SellerPriceRangeScreen();
            }
          },
        ),
      ),
    );
  }
}
