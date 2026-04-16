import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/notification_mock_datasource.dart';
import '../../domain/entities/notification_entity.dart';
import 'notification_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION CUBIT
// ─────────────────────────────────────────────────────────────────────────────

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationDatasource _datasource;

  NotificationCubit({NotificationDatasource? datasource})
      : _datasource = datasource ?? NotificationMockDatasource(),
        super(const NotificationInitial());

  // ── Public API ─────────────────────────────────────────────────────────────

  void loadNotifications() {
    emit(const NotificationLoading());
    final data = _datasource.getNotifications();
    _emitLoaded(
      all: data,
      filter: NotificationFilter.all,
      sort: NotificationSortOrder.newest,
    );
  }

  void setFilter(NotificationFilter filter) {
    final current = state;
    if (current is! NotificationLoaded) return;
    final filtered = filter == NotificationFilter.all
        ? current.allNotifications
        : current.allNotifications
            .where((n) => _matchesFilter(n, filter))
            .toList();
    emit(current.copyWith(
      activeFilter: filter,
      displayedNotifications: _sorted(filtered, current.sortOrder),
    ));
  }

  void setSortOrder(NotificationSortOrder order) {
    final current = state;
    if (current is! NotificationLoaded) return;
    emit(current.copyWith(
      sortOrder: order,
      displayedNotifications:
          _sorted(List.of(current.displayedNotifications), order),
    ));
  }

  void markAsRead(String id) {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updated = current.allNotifications.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    final filtered = current.activeFilter == NotificationFilter.all
        ? updated
        : updated
            .where((n) => _matchesFilter(n, current.activeFilter))
            .toList();
    emit(current.copyWith(
      allNotifications: updated,
      displayedNotifications: _sorted(filtered, current.sortOrder),
    ));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _matchesFilter(NotificationEntity n, NotificationFilter filter) {
    switch (filter) {
      // Customer filters
      case NotificationFilter.offer:
        return n.type == NotificationType.offer;
      case NotificationFilter.coupon:
        return n.type == NotificationType.coupon;
      // Seller filters
      case NotificationFilter.order:
        return n.type == NotificationType.order;
      case NotificationFilter.store:
        return n.type == NotificationType.store;
      case NotificationFilter.analytics:
        return n.type == NotificationType.analytics;
      case NotificationFilter.employee:
        return n.type == NotificationType.employee;
      // Shared
      case NotificationFilter.system:
        return n.type == NotificationType.system;
      case NotificationFilter.general:
        return n.type == NotificationType.general;
      case NotificationFilter.all:
        return true;
    }
  }

  List<NotificationEntity> _sorted(
    List<NotificationEntity> list,
    NotificationSortOrder order,
  ) {
    final copy = List.of(list);
    if (order == NotificationSortOrder.newest) {
      copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      copy.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return copy;
  }

  void _emitLoaded({
    required List<NotificationEntity> all,
    required NotificationFilter filter,
    required NotificationSortOrder sort,
  }) {
    emit(NotificationLoaded(
      allNotifications: all,
      displayedNotifications: _sorted(List.of(all), sort),
      activeFilter: filter,
      sortOrder: sort,
    ));
  }
}
