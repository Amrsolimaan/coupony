import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import 'auth_state.dart';

/// Manages login and session lifecycle
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

  void _safeEmit(AuthState s) {
    if (!isClosed) emit(s);
  }

  // ════════════════════════════════════════════════════════
  // INITIALIZATION
  // ════════════════════════════════════════════════════════

  Future<void> _checkExistingSession() async {
    final result = await repository.checkAuthStatus();
    result.fold(
      (failure) => logger.d('No existing session: ${failure.message}'),
      (isLoggedIn) {
        if (isLoggedIn) {
          logger.i('Existing session found — restoring');
          _safeEmit(state.copyWith(navSignal: AuthNavigation.toHome));
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // LOGIN
  // ════════════════════════════════════════════════════════

  Future<void> login({required String email, required String password, required String role}) async {
    if (state.isLoading) return;

    logger.i('Login attempt for: ${_maskEmail(email)}');
    _safeEmit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
      navSignal: AuthNavigation.none,
    ));

    final result = await loginUseCase(email: email, password: password, role: role);

    result.fold(
      (failure) {
        logger.e('Login failed: ${failure.message}');
        _safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToKey(failure),
        ));
      },
      (user) {
        logger.i('Login successful — UI role: $role, API role: ${user.role}, onboardingCompleted: ${user.isOnboardingCompleted}');

        // ✅ Use the UI-selected role (from role_toggle) NOT the API role
        final AuthNavigation nav;
        if (role == 'seller') {
          // User selected seller in UI → go to seller flow
          nav = user.isOnboardingCompleted
              ? AuthNavigation.toSellerLanding
              : AuthNavigation.toSellerOnboarding;
        } else {
          // User selected customer in UI → go to customer flow
          nav = user.isOnboardingCompleted
              ? AuthNavigation.toHome
              : AuthNavigation.toOnboarding;
        }
        
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

  void clearNavSignal() => _safeEmit(state.copyWith(navSignal: AuthNavigation.none));
  void clearMessages()  => _safeEmit(state.copyWith(errorMessage: null, successMessage: null));
  void goToRegister()   => _safeEmit(state.copyWith(navSignal: AuthNavigation.toRegister));

  // ════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════

  /// Maps a Failure to a localization key so the UI can translate it
  String _mapFailureToKey(Failure failure) {
    if (failure is NetworkFailure) return 'auth_error_network';
    if (failure is UnauthorizedFailure) return 'auth_error_invalid_credentials';
    
    // Validation errors - show backend message directly (not a localization key)
    if (failure is ValidationFailure) return failure.message;
    
    if (failure is ServerFailure) {
      final msg = failure.message.toLowerCase();
      if (msg.contains('invalid') || msg.contains('credentials') || msg.contains('password') || msg.contains('email')) {
        return 'auth_error_invalid_credentials';
      }
      if (msg.contains('not found') || msg.contains('user')) {
        return 'auth_error_user_not_found';
      }
      return 'auth_error_server';
    }
    return 'auth_error_unexpected';
  }

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return '****';
    return '${email[0]}****${email.substring(at)}';
  }
}
