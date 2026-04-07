import 'dart:convert';

/// Lightweight store object embedded in the auth API login/register response.
///
/// Not to be confused with `StoreModel` in the CreateStore feature — that model
/// is a multipart form-data object for *submitting* a new store. This one is
/// read-only and is used for splash routing decisions and the store-selection
/// screen.
class UserStoreModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String status;

  const UserStoreModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.status,
  });

  bool get isActive  => status == 'active';
  bool get isPending => status == 'pending';

  factory UserStoreModel.fromJson(Map<String, dynamic> json) => UserStoreModel(
        id:      json['id']?.toString() ?? '',
        name:    json['name']     as String? ?? '',
        logoUrl: json['logo_url'] as String?,
        status:  json['status']   as String? ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        'id':       id,
        'name':     name,
        'logo_url': logoUrl,
        'status':   status,
      };

  // ── List helpers ──────────────────────────────────────────────────────────

  static List<UserStoreModel> fromJsonList(List<dynamic> list) =>
      list
          .map((e) => UserStoreModel.fromJson(e as Map<String, dynamic>))
          .toList();

  /// Serialise a list to a JSON string suitable for SharedPreferences storage.
  static String encodeList(List<UserStoreModel> stores) =>
      jsonEncode(stores.map((s) => s.toJson()).toList());

  /// Deserialise from a SharedPreferences JSON string.
  /// Returns an empty list on any parse error — never throws.
  static List<UserStoreModel> decodeList(String jsonStr) {
    try {
      return fromJsonList(jsonDecode(jsonStr) as List<dynamic>);
    } catch (_) {
      return [];
    }
  }
}
