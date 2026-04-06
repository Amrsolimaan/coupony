import 'dart:io' show Platform;

/// Compile-time app secrets.
///
/// Keys are injected at build time via --dart-define. The correct key for
/// each platform is selected automatically at runtime.
///
/// ─── Development (VS Code) ───────────────────────────────────────────────
/// Keys are already configured in .vscode/launch.json.
/// Just press F5 — no manual steps needed.
///
/// ─── CLI ─────────────────────────────────────────────────────────────────
/// flutter run \
///   --dart-define=MAPS_API_KEY_ANDROID=$MAPS_API_KEY_ANDROID \
///   --dart-define=MAPS_API_KEY_IOS=$MAPS_API_KEY_IOS
///
/// ─── CI/CD ───────────────────────────────────────────────────────────────
/// Add secrets to your CI environment and pass them as build args.
///
/// ⚠️  NEVER commit real key values to source control.
/// ⚠️  .vscode/launch.json and android/local.properties are gitignored.
class AppConfig {
  AppConfig._();

  static const String _androidKey = String.fromEnvironment(
    'MAPS_API_KEY_ANDROID',
    defaultValue: '',
  );

  static const String _iosKey = String.fromEnvironment(
    'MAPS_API_KEY_IOS',
    defaultValue: '',
  );

  /// Returns the platform-appropriate Google Maps API key.
  /// Android → MAPS_API_KEY_ANDROID
  /// iOS     → MAPS_API_KEY_IOS
  static String get googleMapsApiKey =>
      Platform.isAndroid ? _androidKey : _iosKey;
}
