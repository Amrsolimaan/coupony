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
  /// Rejection reasons returned by the server when status == 'rejected'.
  final List<String> rejectionReasons;
  /// Single rejection reason (from API: rejection_reason)
  final String? rejectionReason;
  /// Timestamp when the store was rejected
  final String? rejectedAt;

  // ── Pre-fillable form fields (present in full store responses) ────────────
  final String? phone;
  final String? description;
  final String? city;
  final String? area;
  final int? branches;

  const UserStoreModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.status,
    this.rejectionReasons = const [],
    this.rejectionReason,
    this.rejectedAt,
    this.phone,
    this.description,
    this.city,
    this.area,
    this.branches,
  });

  bool get isActive     => status == 'active';
  bool get isPending    => status == 'pending';
  bool get isRejected   => status == 'rejected';
  bool get isIncomplete => status == 'incomplete';

  factory UserStoreModel.fromJson(Map<String, dynamic> json) {
    final rawReasons = json['rejection_reasons'];
    final List<String> reasons;
    if (rawReasons is List) {
      reasons = rawReasons.map((e) => e.toString()).toList();
    } else {
      reasons = const [];
    }
    return UserStoreModel(
      id:               json['id']?.toString() ?? '',
      name:             json['name']        as String? ?? '',
      logoUrl:          json['logo_url']    as String?,
      status:           json['status']      as String? ?? 'pending',
      rejectionReasons: reasons,
      rejectionReason:  json['rejection_reason'] as String?,
      rejectedAt:       json['rejected_at']      as String?,
      phone:            json['phone']       as String?,
      description:      json['description'] as String?,
      city:             json['city']        as String?,
      area:             json['address_line_1'] as String?,
      branches:         json['branches'] != null
                            ? int.tryParse(json['branches'].toString())
                            : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':                id,
        'name':              name,
        'logo_url':          logoUrl,
        'status':            status,
        'rejection_reasons': rejectionReasons,
        'rejection_reason':  rejectionReason,
        'rejected_at':       rejectedAt,
        'phone':             phone,
        'description':       description,
        'city':              city,
        'address_line_1':    area,
        'branches':          branches,
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
