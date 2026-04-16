import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/snackbar_extension.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/staff_member_model.dart';
import '../../domain/entities/staff_member_entity.dart';
import '../cubit/staff_list_cubit.dart';
import '../cubit/staff_list_state.dart';

class DisplayStaffDetailsPage extends StatelessWidget {
  const DisplayStaffDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffListCubit()..loadStaff(),
      child: const _DisplayStaffDetailsView(),
    );
  }
}

class _DisplayStaffDetailsView extends StatefulWidget {
  const _DisplayStaffDetailsView();

  @override
  State<_DisplayStaffDetailsView> createState() => _DisplayStaffDetailsViewState();
}

class _DisplayStaffDetailsViewState extends State<_DisplayStaffDetailsView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // Track which card is in edit mode
  String? _editingStaffId;
  
  // Controllers for editing
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _roleControllers = {};
  final Map<String, TextEditingController> _branchControllers = {};
  final Map<String, StaffStatus> _statusValues = {};

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    // Dispose all editing controllers
    for (var controller in _nameControllers.values) {
      controller.dispose();
    }
    for (var controller in _roleControllers.values) {
      controller.dispose();
    }
    for (var controller in _branchControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startEditing(StaffMemberEntity staff) {
    setState(() {
      _editingStaffId = staff.id;
      _nameControllers[staff.id] = TextEditingController(text: staff.name);
      _roleControllers[staff.id] = TextEditingController(text: staff.role);
      _branchControllers[staff.id] = TextEditingController(text: staff.branchName);
      _statusValues[staff.id] = staff.status;
    });
  }

  void _cancelEditing(String staffId) {
    setState(() {
      _editingStaffId = null;
      _nameControllers[staffId]?.dispose();
      _roleControllers[staffId]?.dispose();
      _branchControllers[staffId]?.dispose();
      _nameControllers.remove(staffId);
      _roleControllers.remove(staffId);
      _branchControllers.remove(staffId);
      _statusValues.remove(staffId);
    });
  }

  void _saveEditing(BuildContext context, StaffMemberEntity staff) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<StaffListCubit>();
    
    final name = _nameControllers[staff.id]?.text.trim() ?? '';
    final role = _roleControllers[staff.id]?.text.trim() ?? '';
    final branch = _branchControllers[staff.id]?.text.trim() ?? '';
    
    if (name.isEmpty || role.isEmpty || branch.isEmpty) {
      context.showErrorSnackBar(l10n.staff_update_error);
      return;
    }
    
    // Exit edit mode and show loading
    setState(() {
      _editingStaffId = null;
    });
    
    // Emit loading state
    cubit.setLoading();
    
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final updatedStaff = StaffMemberModel(
      id: staff.id,
      name: name,
      email: staff.email,
      phone: staff.phone,
      role: role,
      branchName: branch,
      joinedDate: staff.joinedDate,
      status: _statusValues[staff.id] ?? staff.status,
    );
    
    cubit.updateStaff(updatedStaff);
    _cancelEditing(staff.id);
    
    if (context.mounted) {
      context.showSuccessSnackBar(l10n.staff_update_success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.w,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.staff_list_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<StaffListCubit, StaffListState>(
          builder: (context, state) {
            if (state is StaffListLoading || state is StaffListInitial) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOfSeller,
                  strokeWidth: 3,
                ),
              );
            }

            if (state is StaffListError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            if (state is StaffListLoaded) {
              return Column(
                children: [
                  _buildSearchBar(context),
                  _buildFilterSection(context, state),
                  Expanded(
                    child: _buildStaffList(context, state),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<StaffListCubit, StaffListState>(
      builder: (context, state) {
        final cubit = context.read<StaffListCubit>();
        
        return Container(
          color: AppColors.surface,
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              cubit.searchStaff(value);
              setState(() {}); // Update UI to show/hide clear button
            },
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: l10n.staff_search_hint,
              hintStyle: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 22.w,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20.w,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        cubit.searchStaff('');
                        _searchFocusNode.unfocus();
                        setState(() {}); // Update UI
                      },
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.primaryOfSeller,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(BuildContext context, StaffListLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<StaffListCubit>();

    return Container(
      color: AppColors.surface,
      padding: EdgeInsetsDirectional.only(
        bottom: 12.h,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            _buildFilterChip(
              context,
              label: l10n.staff_filter_all,
              isSelected: state.currentFilter == StaffFilter.all,
              onTap: () => cubit.changeFilter(StaffFilter.all),
            ),
            SizedBox(width: 8.w),
            _buildFilterChip(
              context,
              label: l10n.staff_filter_active,
              isSelected: state.currentFilter == StaffFilter.active,
              onTap: () => cubit.changeFilter(StaffFilter.active),
            ),
            SizedBox(width: 8.w),
            _buildFilterChip(
              context,
              label: l10n.staff_filter_stopped,
              isSelected: state.currentFilter == StaffFilter.stopped,
              onTap: () => cubit.changeFilter(StaffFilter.stopped),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 20.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOfSeller : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOfSeller
                : AppColors.primaryOfSeller.withValues(alpha: 0.4),
            width: 1,
          ),
          borderRadius: BorderRadiusDirectional.circular(8.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.surface : AppColors.primaryOfSeller,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffList(BuildContext context, StaffListLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final filteredStaff = state.filteredStaff;

    if (filteredStaff.isEmpty) {
      return Center(
        child: Text(
          l10n.staff_empty_message,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsetsDirectional.all(16.w),
      itemCount: filteredStaff.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _buildStaffCard(context, filteredStaff[index]);
      },
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffMemberEntity staff) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = _editingStaffId == staff.id;
    final isActive = isEditing 
        ? (_statusValues[staff.id] ?? staff.status) == StaffStatus.active
        : staff.status == StaffStatus.active;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 14.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadiusDirectional.circular(12.r),
        border: isEditing ? Border.all(
          color: AppColors.primaryOfSeller.withValues(alpha: 0.5),
          width: 1.5,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isEditing ? 0.1 : 0.05),
            blurRadius: isEditing ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          if (!isEditing) ...[
            Row(
              children: [
                // Name with status dot
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF5252),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          staff.name,
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Status Badge
                Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadiusDirectional.circular(6.r),
                  ),
                  child: Text(
                    isActive ? l10n.staff_status_active : l10n.staff_status_stopped,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF5252),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Menu
                GestureDetector(
                  onTap: () => _showStaffMenu(context, staff),
                  child: Container(
                    padding: EdgeInsetsDirectional.all(4.w),
                    child: Icon(
                      Icons.more_vert,
                      size: 20.w,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            // Role
            Text(
              staff.role,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            // Edit Mode Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.staff_menu_edit,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOfSeller,
                    ),
                  ),
                ),
                // Status Dropdown
                Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadiusDirectional.circular(6.r),
                  ),
                  child: DropdownButton<StaffStatus>(
                    value: _statusValues[staff.id],
                    underline: const SizedBox(),
                    isDense: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 18.w,
                      color: isActive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF5252),
                    ),
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF5252),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: StaffStatus.active,
                        child: Text(l10n.staff_status_active),
                      ),
                      DropdownMenuItem(
                        value: StaffStatus.stopped,
                        child: Text(l10n.staff_status_stopped),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _statusValues[staff.id] = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Name Field
            _buildEditField(
              context,
              controller: _nameControllers[staff.id]!,
              hint: l10n.staff_name_hint,
              icon: Icons.person_outline,
            ),
            SizedBox(height: 10.h),
            // Role Field
            _buildEditField(
              context,
              controller: _roleControllers[staff.id]!,
              hint: l10n.staff_role_hint,
              icon: Icons.work_outline,
            ),
          ],
          SizedBox(height: 8.h),
          // Divider
          Container(
            height: 1,
            color: AppColors.divider.withValues(alpha: 0.6),
          ),
          SizedBox(height: 8.h),
          // Branch Info
          if (!isEditing) ...[
            Row(
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 16.w,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  staff.branchName,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Branch Field
            _buildEditField(
              context,
              controller: _branchControllers[staff.id]!,
              hint: l10n.staff_branch_hint,
              icon: Icons.store_outlined,
            ),
          ],
          SizedBox(height: 5.h),
          // Joined Date (Always visible, not editable)
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16.w,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                _formatJoinedDate(context, staff.joinedDate),
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Edit Mode Actions
          if (isEditing) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelEditing(staff.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsetsDirectional.symmetric(vertical: 10.h),
                      side: BorderSide(
                        color: AppColors.divider,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.staff_edit_cancel,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveEditing(context, staff),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOfSeller,
                      foregroundColor: AppColors.surface,
                      padding: EdgeInsetsDirectional.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.staff_edit_save,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.customStyle(
          context,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          icon,
          size: 18.w,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: AppColors.primaryOfSeller,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
      ),
    );
  }

  String _formatJoinedDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    
    try {
      final formatter = DateFormat('d MMMM yyyy', locale);
      final formattedDate = formatter.format(date);
      return l10n.staff_joined_since.replaceAll('{date}', formattedDate);
    } catch (e) {
      // Fallback if locale is not supported
      final formatter = DateFormat('d MMMM yyyy');
      final formattedDate = formatter.format(date);
      return l10n.staff_joined_since.replaceAll('{date}', formattedDate);
    }
  }

  void _showStaffMenu(BuildContext context, StaffMemberEntity staff) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          margin: EdgeInsetsDirectional.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadiusDirectional.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Option
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _startEditing(staff);
                },
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.staff_menu_edit,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(
                height: 1,
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
              // Delete Option
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, staff);
                },
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.staff_menu_delete,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StaffMemberEntity staff) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Container(
          padding: EdgeInsetsDirectional.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadiusDirectional.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                l10n.staff_delete_confirm_title,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<StaffListCubit>().deleteStaff(staff.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOfSeller,
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.staff_delete_confirm_button,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
                    side: BorderSide(
                      color: AppColors.divider,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(8.r),
                    ),
                  ),
                  child: Text(
                    l10n.staff_delete_cancel_button,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
