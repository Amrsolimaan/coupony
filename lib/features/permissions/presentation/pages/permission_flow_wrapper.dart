import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/permission_flow_cubit.dart';
import '../cubit/permission_flow_state.dart';

/// Permission Flow Wrapper
///
/// This is the ENTRY POINT for the permission flow.
/// It listens to the Cubit's navSignal and automatically navigates
/// to the appropriate screen based on state changes.
///
/// ARCHITECTURE:
/// - Cubit updates `navSignal` → Wrapper listens → Auto-navigation happens
/// - No manual Navigator.push calls in pages
/// - Clean, maintainable, state-driven navigation
class PermissionFlowWrapper extends StatefulWidget {
  const PermissionFlowWrapper({super.key});

  @override
  State<PermissionFlowWrapper> createState() => _PermissionFlowWrapperState();
}

class _PermissionFlowWrapperState extends State<PermissionFlowWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize the flow when wrapper is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionFlowCubit>().initializeFlow();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PermissionFlowCubit, PermissionFlowState>(
      // Listen to navSignal changes
      listenWhen: (previous, current) =>
          previous.navSignal != current.navSignal,
      listener: (context, state) {
        final cubit = context.read<PermissionFlowCubit>();

        // Navigate based on signal
        switch (state.navSignal) {
          case PermissionNavigationSignal.toLocationIntro:
            context.go('/permission-location-intro');
            break;

          case PermissionNavigationSignal.toLocationMap:
            context.go('/permission-location-map');
            break;

          case PermissionNavigationSignal.toLocationError:
            context.go('/permission-location-error');
            break;

          case PermissionNavigationSignal.toNotificationIntro:
            context.go('/permission-notification-intro');
            break;

          case PermissionNavigationSignal.toNotificationError:
            context.go('/permission-notification-error');
            break;

          case PermissionNavigationSignal.toLoading:
            context.go('/permission-loading');
            break;

          case PermissionNavigationSignal.toHome:
            // Complete - go to main app
            context.go('/home');
            break;

          case PermissionNavigationSignal.none:
            // Do nothing - waiting for user action
            break;
        }

        // Clear the signal after handling it (prevents re-navigation)
        if (state.navSignal != PermissionNavigationSignal.none) {
          Future.microtask(() => cubit.clearNavigationSignal());
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
