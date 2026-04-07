import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn;
  final Logger _logger;

  GoogleSignInService({
    GoogleSignIn? googleSignIn,
    Logger? logger,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _logger = logger ?? Logger();

  /// تسجيل الدخول بواسطة Google والحصول على idToken
  Future<String?> signInWithGoogleAndGetIdToken() async {
    try {
      _logger.i('🔐 [SERVICE] Starting Google Sign-In process...');

      // إجبار تسجيل الخروج أولاً لضمان ظهور قائمة اختيار الحساب
      _logger.i('🔐 [SERVICE] Signing out first to force account picker...');
      await _googleSignIn.signOut();

      // تسجيل الدخول بواسطة Google
      _logger.i('🔐 [SERVICE] Calling _googleSignIn.signIn()...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _logger.w('❌ [SERVICE] Google Sign-In cancelled by user');
        return null;
      }

      _logger.i('✅ [SERVICE] Google user signed in: ${googleUser.email}');

      // الحصول على authentication details
      _logger.i('🔐 [SERVICE] Getting authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        _logger.e('❌ [SERVICE] Failed to get Google ID token');
        throw Exception('Failed to get Google ID token');
      }

      _logger.i('✅ [SERVICE] Got Google ID token');
      return googleAuth.idToken;

    } catch (e, stackTrace) {
      _logger.e('❌ [SERVICE] Google Sign-In error: $e');
      _logger.e('❌ [SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// تسجيل الخروج من Google وإلغاء تفويض الحساب.
  /// استخدام disconnect() بدلاً من signOut() فقط يضمن ظهور
  /// نافذة اختيار الحساب في المرة القادمة.
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect(); // revokes OAuth grant + signs out
      _logger.i('✅ Google Sign-Out + Disconnect successful');
    } catch (e) {
      _logger.e('❌ Google Sign-Out error: $e');
    }
  }
}