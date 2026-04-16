// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION DOMAIN ENTITIES
// ─────────────────────────────────────────────────────────────────────────────

enum NotificationType {
  // Customer types
  offer,
  coupon,
  // Seller types
  order,      // طلب جديد/استخدام كوبون
  store,      // حالة المتجر
  analytics,  // تحليلات
  employee,   // موظفين
  // Shared
  system,
  general,
}

enum NotificationFilter {
  all,
  // Customer filters
  offer,
  coupon,
  // Seller filters
  order,
  store,
  analytics,
  employee,
  // Shared
  system,
  general,
}

enum NotificationSortOrder { newest, oldest }

// ── Badge status for store/employee notifications ────────────────────────────
enum NotificationBadgeStatus {
  approved,   // قبول
  rejected,   // رفض
  pending,    // قيد المراجعة
  used,       // تم الاستخدام
  none,       // بدون badge
}

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  
  // ✅ New fields for rich notifications
  final String? imageUrl;           // صورة المتجر أو الموظف أو العميل
  final String? email;              // البريد الإلكتروني
  final NotificationBadgeStatus badgeStatus;  // حالة الـ badge

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
    this.email,
    this.badgeStatus = NotificationBadgeStatus.none,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        imageUrl: imageUrl,
        email: email,
        badgeStatus: badgeStatus,
      );
}
