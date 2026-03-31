import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;
  final Logger _logger;

  GoogleSignInService({
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
    Logger? logger,
  })  : _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _logger = logger ?? Logger();

  /// تسجيل الدخول بواسطة Google والحصول على بيانات المستخدم
  Future<Map<String, String>?> signInWithGoogleAndGetUserData() async {
    try {
      _logger.i('🔐 [SERVICE] Starting Google Sign-In process...');

      // إجبار تسجيل الخروج أولاً لضمان ظهور قائمة اختيار الحساب
      // هذا يحل مشكلة الدخول التلقائي على آخر حساب
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

      // إنشاء credential للـ Firebase
      _logger.i('🔐 [SERVICE] Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول في Firebase للتأكد من صحة التوكن
      _logger.i('🔐 [SERVICE] Signing in with Firebase...');
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      _logger.i('✅ [SERVICE] Firebase authentication successful for: ${userCredential.user?.email}');

      // استخراج بيانات المستخدم
      final user = userCredential.user!;
      final displayName = user.displayName ?? '';
      final nameParts = displayName.split(' ');
      
      final userData = {
        'id': user.uid,
        'email': user.email!,
        'firstName': nameParts.isNotEmpty ? nameParts.first : 'مستخدم',
        'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'جديد',
        'phoneNumber': user.phoneNumber ?? '', // قد يكون فارغ
      };

      _logger.i('✅ [SERVICE] Extracted user data: $userData');
      return userData;

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
      await Future.wait([
        _googleSignIn.disconnect(), // revokes OAuth grant + signs out
        _firebaseAuth.signOut(),
      ]);
      _logger.i('✅ Google Sign-Out + Disconnect successful');
    } catch (e) {
      _logger.e('❌ Google Sign-Out error: $e');
    }
  }

  /// التحقق من حالة تسجيل الدخول الحالية
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// الحصول على المستخدم الحالي
  User? get currentUser => _firebaseAuth.currentUser;
}