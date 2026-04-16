import '../../domain/entities/notification_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION STATES
// ─────────────────────────────────────────────────────────────────────────────

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> allNotifications;
  final List<NotificationEntity> displayedNotifications;
  final NotificationFilter activeFilter;
  final NotificationSortOrder sortOrder;

  const NotificationLoaded({
    required this.allNotifications,
    required this.displayedNotifications,
    required this.activeFilter,
    required this.sortOrder,
  });

  NotificationLoaded copyWith({
    List<NotificationEntity>? allNotifications,
    List<NotificationEntity>? displayedNotifications,
    NotificationFilter? activeFilter,
    NotificationSortOrder? sortOrder,
  }) =>
      NotificationLoaded(
        allNotifications: allNotifications ?? this.allNotifications,
        displayedNotifications:
            displayedNotifications ?? this.displayedNotifications,
        activeFilter: activeFilter ?? this.activeFilter,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}
