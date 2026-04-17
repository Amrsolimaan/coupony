import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../../../../core/extensions/snackbar_extension.dart';
import '../../../../../core/localization/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/staff_member_model.dart';
import '../../domain/entities/staff_member_entity.dart';
import '../cubit/staff_list_cubit.dart';

class AddShopStuffPage extends StatefulWidget {
  const AddShopStuffPage({super.key});

  @override
  State<AddShopStuffPage> createState() => _AddShopStuffPageState();
}

class _AddShopStuffPageState extends State<AddShopStuffPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String? _selectedRole;
  String? _selectedBranch;
  bool _isRoleExpanded = false;
  bool _isBranchExpanded = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLearnMorePressed = false;

  final List<String> _branches = [
    'فرع المسلة',
    'فرع المعادي',
    'فرع مدينة نصر',
    'فرع الزمالك',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showRolesComparison(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          margin: EdgeInsetsDirectional.all(16.w),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadiusDirectional.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsetsDirectional.all(20.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.staff_roles_comparison_title,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        size: 24.w,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Comparison Table
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.all(20.w),
                  child: _buildComparisonTable(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadiusDirectional.circular(12.r),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(12.r),
                topEnd: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.staff_permission_label,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOfSeller,
                    ),
                  ),
                ),
                _buildRoleHeader(context, l10n.staff_role_cashier),
                _buildRoleHeader(context, l10n.staff_role_analyst),
                _buildRoleHeader(context, l10n.staff_role_manager),
              ],
            ),
          ),
          // Permission Rows
          _buildPermissionRow(
            context,
            l10n.staff_permission_scan_qr,
            cashier: true,
            analyst: false,
            manager: true,
          ),
          _buildPermissionRow(
            context,
            l10n.staff_permission_view_data,
            cashier: false,
            analyst: true,
            manager: true,
          ),
          _buildPermissionRow(
            context,
            l10n.staff_permission_add_data,
            cashier: false,
            analyst: false,
            manager: true,
          ),
          _buildPermissionRow(
            context,
            l10n.staff_permission_edit_data,
            cashier: false,
            analyst: false,
            manager: true,
          ),
          _buildPermissionRow(
            context,
            l10n.staff_permission_delete_data,
            cashier: false,
            analyst: false,
            manager: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleHeader(BuildContext context, String role) {
    return Expanded(
      child: Center(
        child: Text(
          role,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPermissionRow(
    BuildContext context,
    String permission, {
    required bool cashier,
    required bool analyst,
    required bool manager,
  }) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              permission,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildPermissionIcon(cashier),
          _buildPermissionIcon(analyst),
          _buildPermissionIcon(manager),
        ],
      ),
    );
  }

  Widget _buildPermissionIcon(bool hasPermission) {
    return Expanded(
      child: Center(
        child: Icon(
          hasPermission ? Icons.check_circle : Icons.cancel,
          size: 20.w,
          color: hasPermission
              ? const Color(0xFF4CAF50)
              : const Color(0xFFFF5252),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null) {
      context.showErrorSnackBar(
        AppLocalizations.of(context)!.staff_add_error_role_required,
      );
      return;
    }

    if (_selectedBranch == null) {
      context.showErrorSnackBar(
        AppLocalizations.of(context)!.staff_add_error_branch_required,
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryOfSeller,
          strokeWidth: 3,
        ),
      ),
    );

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1200));

    // Create new staff member
    final newStaff = StaffMemberModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: '+966 50 123 4567', // Mock phone
      role: _selectedRole!,
      branchName: _selectedBranch!,
      joinedDate: DateTime.now(),
      status: StaffStatus.active,
    );

    // Add to cubit
    if (context.mounted) {
      context.read<StaffListCubit>().addStaff(newStaff);
      
      // Close loading
      Navigator.pop(context);
      
      // Show success
      context.showSuccessSnackBar(l10n.staff_add_success);
      
      // Navigate back
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        Navigator.pop(context);
      }
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
          l10n.staff_add_title,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLearnMoreButton(context),
                      SizedBox(height: 24.h),
                      _buildSectionHeader(context, l10n.staff_add_personal_info),
                      SizedBox(height: 16.h),
                      _buildNameField(context),
                      SizedBox(height: 12.h),
                      _buildEmailField(context),
                      SizedBox(height: 24.h),
                      _buildSectionHeader(context, l10n.staff_add_role_assignment),
                      SizedBox(height: 16.h),
                      _buildRoleSelector(context),
                      SizedBox(height: 12.h),
                      _buildBranchSelector(context),
                    ],
                  ),
                ),
              ),
            ),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnMoreButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLearnMorePressed ? 0.97 : _pulseAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isLearnMorePressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isLearnMorePressed = false;
              });
              _showRolesComparison(context);
            },
            onTapCancel: () {
              setState(() {
                _isLearnMorePressed = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
                borderRadius: BorderRadiusDirectional.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryOfSeller.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOfSeller.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20.w,
                    color: AppColors.primaryOfSeller,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.staff_add_learn_more,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOfSeller,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: _nameController,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: l10n.staff_name_hint,
        hintStyle: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.person_outline,
          size: 22.w,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: AppColors.surface,
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.staff_add_error_name_required;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: l10n.staff_add_email_hint,
        hintStyle: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          size: 22.w,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: AppColors.surface,
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.staff_add_error_email_required;
        }
        if (!value.contains('@')) {
          return l10n.staff_add_error_email_invalid;
        }
        return null;
      },
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final roles = [
      {'name': l10n.staff_role_cashier, 'icon': Icons.point_of_sale_outlined},
      {'name': l10n.staff_role_analyst, 'icon': Icons.analytics_outlined},
      {'name': l10n.staff_role_manager, 'icon': Icons.admin_panel_settings_outlined},
    ];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _isRoleExpanded = !_isRoleExpanded;
          if (_isRoleExpanded) _isBranchExpanded = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadiusDirectional.circular(12.r),
          border: Border.all(
            color: _isRoleExpanded
                ? AppColors.primaryOfSeller
                : AppColors.divider.withValues(alpha: 0.5),
            width: _isRoleExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedRole != null
                        ? roles.firstWhere((r) => r['name'] == _selectedRole)['icon'] as IconData
                        : Icons.work_outline,
                    size: 22.w,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _selectedRole ?? l10n.staff_role_hint,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _selectedRole != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isRoleExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24.w,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Expanded List
            if (_isRoleExpanded)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: roles.map((role) {
                    final roleName = role['name'] as String;
                    final roleIcon = role['icon'] as IconData;
                    final isSelected = _selectedRole == roleName;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedRole = roleName;
                          _isRoleExpanded = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryOfSeller.withValues(alpha: 0.05)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              roleIcon,
                              size: 20.w,
                              color: isSelected
                                  ? AppColors.primaryOfSeller
                                  : AppColors.textSecondary.withValues(alpha: 0.7),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                roleName,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primaryOfSeller
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                size: 20.w,
                                color: AppColors.primaryOfSeller,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _isBranchExpanded = !_isBranchExpanded;
          if (_isBranchExpanded) _isRoleExpanded = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadiusDirectional.circular(12.r),
          border: Border.all(
            color: _isBranchExpanded
                ? AppColors.primaryOfSeller
                : AppColors.divider.withValues(alpha: 0.5),
            width: _isBranchExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 22.w,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _selectedBranch ?? l10n.staff_add_branch_hint,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _selectedBranch != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isBranchExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24.w,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Expanded List
            if (_isBranchExpanded)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: _branches.map((branch) {
                    final isSelected = _selectedBranch == branch;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedBranch = branch;
                          _isBranchExpanded = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryOfSeller.withValues(alpha: 0.05)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 34.w), // Align with icon
                            Expanded(
                              child: Text(
                                branch,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primaryOfSeller
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check,
                                size: 20.w,
                                color: AppColors.primaryOfSeller,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: EdgeInsetsDirectional.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _submitForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOfSeller,
            foregroundColor: AppColors.surface,
            padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(12.r),
            ),
            elevation: 0,
          ),

child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Transform.rotate(
      angle: Directionality.of(context) == TextDirection.rtl 
          ? math.pi * 0.7   // بدل 2.198
          : math.pi * 0.354, // بدل 1.1138
      child: Icon(
        Icons.send_rounded,
        size: 20.w,
        color: AppColors.surface,
      ),
    ),
    SizedBox(width: 8.w),
    Text(
      l10n.staff_add_submit,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
      ),
    ),
  ],
),   ),
      ),
    );
  }
}
