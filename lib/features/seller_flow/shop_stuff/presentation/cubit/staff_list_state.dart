import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_member_entity.dart';

enum StaffFilter { all, active, stopped }

abstract class StaffListState extends Equatable {
  const StaffListState();

  @override
  List<Object?> get props => [];
}

class StaffListInitial extends StaffListState {}

class StaffListLoading extends StaffListState {}

class StaffListLoaded extends StaffListState {
  final List<StaffMemberEntity> allStaff;
  final StaffFilter currentFilter;
  final String searchQuery;

  const StaffListLoaded({
    required this.allStaff,
    this.currentFilter = StaffFilter.all,
    this.searchQuery = '',
  });

  List<StaffMemberEntity> get filteredStaff {
    // First apply filter
    List<StaffMemberEntity> filtered;
    switch (currentFilter) {
      case StaffFilter.all:
        filtered = allStaff;
        break;
      case StaffFilter.active:
        filtered = allStaff
            .where((staff) => staff.status == StaffStatus.active)
            .toList();
        break;
      case StaffFilter.stopped:
        filtered = allStaff
            .where((staff) => staff.status == StaffStatus.stopped)
            .toList();
        break;
    }

    // Then apply search
    if (searchQuery.isEmpty) {
      return filtered;
    }

    final query = searchQuery.toLowerCase();
    return filtered.where((staff) {
      return staff.name.toLowerCase().contains(query) ||
          staff.role.toLowerCase().contains(query) ||
          staff.branchName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  List<Object?> get props => [allStaff, currentFilter, searchQuery];

  StaffListLoaded copyWith({
    List<StaffMemberEntity>? allStaff,
    StaffFilter? currentFilter,
    String? searchQuery,
  }) {
    return StaffListLoaded(
      allStaff: allStaff ?? this.allStaff,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class StaffListError extends StaffListState {
  final String message;

  const StaffListError(this.message);

  @override
  List<Object?> get props => [message];
}
