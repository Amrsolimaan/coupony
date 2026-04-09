import '../constants/api_constants.dart';

/// Centralised image-URL resolution.
///
/// Consolidates the three copies of `_buildFullImageUrl` that existed across
/// [StoreSelectionPage], [EditProfilePage], and [MainProfile].
///
/// Rules (applied in order):
/// 1. null / empty  → returns null
/// 2. Already absolute (`http://` or `https://`)
///    a. Contains `/users/avatars/` → corrected to `/storage/avatars/`
///    b. Otherwise → returned as-is
/// 3. Relative path → prepends storage base URL
///    • `storage/foo` or `/storage/foo` → `{base}/storage/foo`
///    • Any other path               → `{base}/storage/{path}`
class ImageUrlUtils {
  ImageUrlUtils._();

  /// Base URL without the `/api/v1` API suffix.
  static String get _storageBase =>
      ApiConstants.baseUrl.replaceAll('/api/v1', '');

  /// Resolves [path] to a fully-qualified URL suitable for network loading.
  /// Returns null when [path] is null or empty.
  static String? buildFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;

    // ── Absolute URL ──────────────────────────────────────────────────────
    if (path.startsWith('http://') || path.startsWith('https://')) {
      // Correct a known legacy path issue on the API side.
      if (path.contains('/users/avatars/')) {
        return path.replaceAll('/users/avatars/', '/storage/avatars/');
      }
      return path;
    }

    // ── Relative path → storage URL ───────────────────────────────────────
    String cleanPath = path;

    if (cleanPath.startsWith('/storage/') ||
        cleanPath.startsWith('storage/')) {
      // Already has the storage prefix — just ensure leading slash.
      if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
    } else {
      // Prepend /storage/
      cleanPath = '/storage/$cleanPath';
    }

    return '$_storageBase$cleanPath';
  }
}
