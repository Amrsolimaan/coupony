import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Manages login and session lifecycle
///
/// Usage in UI:
/// ```dart
/// BlocProvider(
///   create: (_) => sl<LoginCubit>(),
///   child: BlocConsumer<LoginCubit, AuthState>(
///     listener: (context, state) {
///       if (state.navSignal == AuthNavigation.toHome) context.go(AppRouter.home);
///       if (state.navSignal == AuthNavigation.toMerchantDash) context.go(AppRouter.merchantDashboard);
///       if (state.errorMessage != null) showSnackBar(context, state.errorMessage!);
///     },
///     builder: (context, state) { ... },
///   ),
/// )
/// ```
class LoginCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository repository;
  final Logger logger;

  LoginCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.repository,
    required this.logger,
  }) : super(const AuthState()) {
    _checkExistingSession();
  }

  // ════════════════════════════════════════════════════════
  // SAFE EMIT
  // ════════════════════════════════════════════════════════

  void _safeEmit(AuthState newState) {
    if (!isClosed) emit(newState);
  }

  // ════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════

  /// Check if a valid session already exists on startup
  Future<void> _checkExistingSession() async {
    final result = await repository.checkAuthStatus();
    result.fold(
      (failure) => logger.d('No existing session: ${failure.message}'),
      (isLoggedIn) {
        if (isLoggedIn) {
          logger.i('Existing session found — restoring');
          // Emit authenticated with minimal cached user
          // Full profile fetch is handled by the home screen
          _safeEmit(state.copyWith(navSignal: AuthNavigation.toHome));
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // LOGIN
  // ════════════════════════════════════════════════════════

  Future<void> login({required String phone, required String password}) async {
    if (state.isLoading) return;

    logger.i('Login attempt for phone: ${_maskPhone(phone)}');
    _safeEmit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      navSignal: AuthNavigation.none,
    ));

    final result = await loginUseCase(phone: phone, password: password);

    result.fold(
      (failure) {
        logger.e('Login failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (user) {
        logger.i('Login successful — role: ${user.role}');
        final nav = user.role == 'merchant'
            ? AuthNavigation.toMerchantDash
            : AuthNavigation.toHome;
        _safeEmit(state.copyWith(
          isLoading: false,
          user: user,
          successMessage: 'login_success',
          navSignal: nav,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // LOGOUT
  // ════════════════════════════════════════════════════════

  Future<void> logout() async {
    logger.i('Logging out...');
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await logoutUseCase();

    result.fold(
      (failure) {
        // Logout always succeeds locally — failure is non-critical
        logger.w('Logout API failed (local cleared anyway): ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading: false,
          user: null,
          navSignal: AuthNavigation.toLogin,
        ));
      },
      (_) {
        logger.i('Logout successful');
        _safeEmit(state.copyWith(
          isLoading: false,
          user: null,
          navSignal: AuthNavigation.toLogin,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // NAVIGATION HELPERS
  // ════════════════════════════════════════════════════════

  /// Call from UI after handling navSignal to prevent re-triggering
  void clearNavSignal() {
    _safeEmit(state.copyWith(navSignal: AuthNavigation.none));
  }

  void clearMessages() {
    _safeEmit(state.copyWith(errorMessage: null, successMessage: null));
  }

  void goToRegister() {
    _safeEmit(state.copyWith(navSignal: AuthNavigation.toRegister));
  }

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  /// Mask phone for safe logging (e.g. +201234567890 → +20****7890)
  String _maskPhone(String phone) {
    if (phone.length < 6) return '****';
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }
}
