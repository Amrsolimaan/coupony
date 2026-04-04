import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/use_cases/google_sign_in_use_case.dart';
import 'auth_state.dart';

/// Manages Google Sign-In authentication
class GoogleSignInCubit extends Cubit<AuthState> {
  final GoogleSignInUseCase googleSignInUseCase;
  final Logger logger;

  GoogleSignInCubit({
    required this.googleSignInUseCase,
    required this.logger,
  }) : super(const AuthState());

  void _safeEmit(AuthState s) {
    if (!isClosed) emit(s);
  }

  /// تسجيل الدخول بواسطة Google
  Future<void> signInWithGoogle({required String role}) async {
    logger.i('🔐 [CUBIT] Starting Google Sign-In for role: $role');
    
    try {
      _safeEmit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        navSignal: AuthNavigation.none,
      ));

      logger.i('🔐 [CUBIT] Calling googleSignInUseCase...');
      final result = await googleSignInUseCase(GoogleSignInParams(role: role));
      logger.i('🔐 [CUBIT] UseCase returned result');

      result.fold(
        (failure) {
          logger.e('❌ [CUBIT] Google Sign-In failed: ${failure.message}');
          logger.e('❌ [CUBIT] Failure type: ${failure.runtimeType}');

          // Account exists but email is unverified → redirect to OTP screen
          if (failure is OtpRequiredFailure) {
            logger.i('🔐 [CUBIT] OTP required for ${failure.email} — navigating to OTP screen');
            _safeEmit(state.copyWith(
              isLoading:   false,
              otpEmail:    failure.email,
              otpPassword: failure.password,
              navSignal:   AuthNavigation.toOtpVerification,
            ));
            return;
          }

          _safeEmit(state.copyWith(
            isLoading:    false,
            errorMessage: failure.message,
            navSignal:    AuthNavigation.none,
          ));
        },
        (user) {
          logger.i('✅ [CUBIT] Google Sign-In successful for: ${user.email}');
          logger.d("Google Sign-In Success - User: ${user.email}, Onboarding: ${user.isOnboardingCompleted}");
          
          // Determine navigation based on role and onboarding status
          final AuthNavigation navigation;
          if (user.role == 'seller') {
            // Sellers: check if onboarding is completed
            navigation = user.isOnboardingCompleted
                ? AuthNavigation.toMerchantDash
                : AuthNavigation.toSellerOnboarding;
            logger.d("Seller - navigating to ${user.isOnboardingCompleted ? 'merchant dashboard' : 'seller onboarding'}");
          } else {
            // Customers: check if onboarding is completed
            navigation = user.isOnboardingCompleted
                ? AuthNavigation.toHome
                : AuthNavigation.toOnboarding;
            logger.d("Customer - navigating to ${user.isOnboardingCompleted ? 'home' : 'customer onboarding'}");
          }

          _safeEmit(state.copyWith(
            isLoading: false,
            user: user,
            successMessage: 'تم تسجيل الدخول بنجاح',
            navSignal: navigation,
          ));
        },
      );
    } catch (e, stackTrace) {
      logger.e('❌ [CUBIT] Unexpected error in signInWithGoogle: $e');
      logger.e('❌ [CUBIT] Stack trace: $stackTrace');
      logger.e("Google Sign-In Failed: $e");
      _safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ غير متوقع: $e',
        navSignal: AuthNavigation.none,
      ));
    }
  }

  /// مسح الرسائل والإشارات
  void clearMessages() {
    _safeEmit(state.copyWith(
      errorMessage: null,
      successMessage: null,
      navSignal: AuthNavigation.none,
    ));
  }
}