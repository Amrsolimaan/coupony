import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/staff_member_model.dart';
import '../../domain/entities/staff_member_entity.dart';
import 'staff_list_state.dart';

class StaffListCubit extends Cubit<StaffListState> {
  StaffListCubit() : super(StaffListInitial());

  void loadStaff() {
    emit(StaffListLoading());

    // Mock data - Replace with actual API call
    final mockStaff = _getMockStaff();

    emit(StaffListLoaded(allStaff: mockStaff));
  }

  void changeFilter(StaffFilter filter) {
    if (state is StaffListLoaded) {
      final currentState = state as StaffListLoaded;
      emit(currentState.copyWith(currentFilter: filter));
    }
  }

  void searchStaff(String query) {
    if (state is StaffListLoaded) {
      final currentState = state as StaffListLoaded;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  void setLoading() {
    emit(StaffListLoading());
  }

  void addStaff(StaffMemberEntity newStaff) {
    if (state is StaffListLoaded) {
      final currentState = state as StaffListLoaded;
      final updatedList = [...currentState.allStaff, newStaff];
      emit(currentState.copyWith(allStaff: updatedList));
    } else {
      // If state is loading or initial, create new loaded state
      emit(StaffListLoaded(allStaff: [newStaff]));
    }
  }

  void updateStaff(StaffMemberEntity updatedStaff) {
    if (state is StaffListLoaded) {
      final currentState = state as StaffListLoaded;
      final updatedList = currentState.allStaff.map((staff) {
        return staff.id == updatedStaff.id ? updatedStaff : staff;
      }).toList();
      emit(currentState.copyWith(allStaff: updatedList));
    } else {
      // If state is loading, we need to emit loaded state with updated data
      // This will be called after setLoading()
      final mockStaff = _getMockStaff();
      final updatedList = mockStaff.map((staff) {
        return staff.id == updatedStaff.id ? updatedStaff : staff;
      }).toList();
      emit(StaffListLoaded(allStaff: updatedList));
    }
  }

  void deleteStaff(String staffId) {
    if (state is StaffListLoaded) {
      final currentState = state as StaffListLoaded;
      final updatedStaff =
          currentState.allStaff.where((staff) => staff.id != staffId).toList();
      emit(currentState.copyWith(allStaff: updatedStaff));
    }
  }

  List<StaffMemberEntity> _getMockStaff() {
    return [
      StaffMemberModel(
        id: '1',
        name: 'أحمد محمد صالح',
        email: 'ahmed@example.com',
        phone: '+966 50 123 4567',
        role: 'كاشير',
        branchName: 'فرع المسلة',
        joinedDate: DateTime(2024, 1, 23),
        status: StaffStatus.active,
      ),
      StaffMemberModel(
        id: '2',
        name: 'منه صالح',
        email: 'ahmed@example.com',
        phone: '+966 50 123 4567',
        role: 'كاشير',
        branchName: 'فرع المسلة',
        joinedDate: DateTime(2024, 1, 23),
        status: StaffStatus.active,
      ),
      StaffMemberModel(
        id: '3',
        name: 'مصطفى عصام',
        email: 'ahmed@example.com',
        phone: '+966 50 123 4567',
        role: 'كاشير',
        branchName: 'فرع المسلة',
        joinedDate: DateTime(2024, 1, 23),
        status: StaffStatus.stopped,
      ),
      StaffMemberModel(
        id: '4',
        name: 'ياسمين علي',
        email: 'ahmed@example.com',
        phone: '+966 50 123 4567',
        role: 'كاشير',
        branchName: 'فرع المسلة',
        joinedDate: DateTime(2024, 1, 23),
        status: StaffStatus.active,
      ),
    ];
  }
}
