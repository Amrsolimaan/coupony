import '../../domain/entities/notification_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION DATASOURCE — ABSTRACT CONTRACT
// Replace NotificationMockDatasource with a real HTTP implementation
// once the backend is ready. The cubit depends on the abstract type only.
// ─────────────────────────────────────────────────────────────────────────────

abstract class NotificationDatasource {
  /// Returns all notifications for the current user.
  List<NotificationEntity> getNotifications();
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK IMPLEMENTATION (hook data)
// ─────────────────────────────────────────────────────────────────────────────

class NotificationMockDatasource implements NotificationDatasource {
  @override
  List<NotificationEntity> getNotifications() {
    final now = DateTime.now();
    return [
      // ══════════════════════════════════════════════════════════════════════
      // SELLER NOTIFICATIONS
      // ══════════════════════════════════════════════════════════════════════
      
      // ── Store: Approved ────────────────────────────────────────────────────
      NotificationEntity(
        id: 's1',
        title: 'تم قبول متجرك',
        body: 'مبروك! تم الموافقة على متجرك وأصبح نشطاً الآن. يمكنك البدء في إضافة العروض والمنتجات.',
        type: NotificationType.store,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        imageUrl: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=Store',
        badgeStatus: NotificationBadgeStatus.approved,
      ),
      
      // ── Store: Rejected ────────────────────────────────────────────────────
      NotificationEntity(
        id: 's2',
        title: 'تم رفض متجرك',
        body: 'نأسف لإبلاغك أن طلب متجرك تم رفضه. يرجى مراجعة البيانات والمستندات المطلوبة وإعادة المحاولة.',
        type: NotificationType.store,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
        imageUrl: 'https://via.placeholder.com/150/F44336/FFFFFF?text=Store',
        badgeStatus: NotificationBadgeStatus.rejected,
      ),
      
      // ── Store: Pending ─────────────────────────────────────────────────────
      NotificationEntity(
        id: 's3',
        title: 'متجرك قيد المراجعة',
        body: 'شكراً لتقديم طلبك. متجرك حالياً قيد المراجعة من قبل فريقنا. سنخبرك بالنتيجة قريباً.',
        type: NotificationType.store,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        imageUrl: 'https://via.placeholder.com/150/FF9800/FFFFFF?text=Store',
        badgeStatus: NotificationBadgeStatus.pending,
      ),
      
      // ── Order: Used ────────────────────────────────────────────────────────
      NotificationEntity(
        id: 'o1',
        title: 'amooor@gmail.com',
        body: 'استخدم عميلك كوبون خصم 20% على طلب بقيمة 250 ريال. تم خصم 50 ريال بنجاح.',
        type: NotificationType.order,
        createdAt: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        imageUrl: 'https://via.placeholder.com/150/2196F3/FFFFFF?text=A',
        email: 'amooor@gmail.com',
        badgeStatus: NotificationBadgeStatus.used,
      ),
      
      NotificationEntity(
        id: 'o2',
        title: 'sara.ahmed@gmail.com',
        body: 'استخدمت عميلتك كوبون خصم 15% على طلب بقيمة 180 ريال. تم خصم 27 ريال بنجاح.',
        type: NotificationType.order,
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
        imageUrl: 'https://via.placeholder.com/150/E91E63/FFFFFF?text=S',
        email: 'sara.ahmed@gmail.com',
        badgeStatus: NotificationBadgeStatus.used,
      ),
      
      // ── Employee: Approved ─────────────────────────────────────────────────
      NotificationEntity(
        id: 'e1',
        title: 'mohamed.ali@gmail.com',
        body: 'قبل محمد علي دعوتك للعمل كـ كاشير في متجرك. يمكنه الآن الوصول إلى لوحة التحكم.',
        type: NotificationType.employee,
        createdAt: now.subtract(const Duration(hours: 6)),
        isRead: false,
        imageUrl: 'https://via.placeholder.com/150/4CAF50/FFFFFF?text=M',
        email: 'mohamed.ali@gmail.com',
        badgeStatus: NotificationBadgeStatus.approved,
      ),
      
      // ── Employee: Rejected ─────────────────────────────────────────────────
      NotificationEntity(
        id: 'e2',
        title: 'fatima.hassan@gmail.com',
        body: 'رفضت فاطمة حسن دعوتك للعمل كـ مدير مبيعات في متجرك. يمكنك إرسال دعوة لشخص آخر.',
        type: NotificationType.employee,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        imageUrl: 'https://via.placeholder.com/150/F44336/FFFFFF?text=F',
        email: 'fatima.hassan@gmail.com',
        badgeStatus: NotificationBadgeStatus.rejected,
      ),
      
      // ── Analytics ──────────────────────────────────────────────────────────
      NotificationEntity(
        id: 'a1',
        title: 'متجرك يحقق نمواً رائعاً',
        body: 'متجرك حقق 150 مشاهدة اليوم بزيادة 30% عن الأمس. استمر في تقديم عروض مميزة!',
        type: NotificationType.analytics,
        createdAt: now.subtract(const Duration(hours: 8)),
        isRead: false,
      ),
      
      NotificationEntity(
        id: 'a2',
        title: 'إحصائيات الأسبوع',
        body: 'هذا الأسبوع: 45 كوبون مستخدم، 890 مشاهدة، 67 متابع جديد. أداء ممتاز!',
        type: NotificationType.analytics,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      
      // ══════════════════════════════════════════════════════════════════════
      // CUSTOMER NOTIFICATIONS
      // ══════════════════════════════════════════════════════════════════════
      
      NotificationEntity(
        id: 'c1',
        title: 'تم استخدام كوبونك بنجاح',
        body: 'شكراً لاستخدامك التطبيق. تم استخدام كوبون الخصم بنجاح على طلبك.',
        type: NotificationType.coupon,
        createdAt: now.subtract(const Duration(minutes: 1)),
        isRead: false,
      ),
      
      NotificationEntity(
        id: 'c2',
        title: 'عروض و متاجر جديد في منطقتك',
        body: 'تنبيه: الحق العرض قبل ما يخلص. عروض حصرية وخصومات مميزة في متاجر قريبة منك.',
        type: NotificationType.offer,
        createdAt: now.subtract(const Duration(minutes: 3)),
        isRead: false,
      ),
      
      NotificationEntity(
        id: 'c3',
        title: 'عروض و متاجر جديد في منطقتك',
        body: 'تنبيه: الحق العرض قبل ما يخلص. عروض حصرية وخصومات مميزة في متاجر قريبة منك.',
        type: NotificationType.offer,
        createdAt: now.subtract(const Duration(minutes: 10)),
        isRead: false,
      ),
      
      NotificationEntity(
        id: 'c4',
        title: 'رسالة ترحيبية',
        body: 'مرحباً بك في تطبيقنا! نتمنى لك تجربة رائعة مع كوبوني. استمتع بأفضل العروض والخصومات.',
        type: NotificationType.general,
        createdAt: now.subtract(const Duration(days: 7)),
        isRead: true,
      ),
    ];
  }
}
