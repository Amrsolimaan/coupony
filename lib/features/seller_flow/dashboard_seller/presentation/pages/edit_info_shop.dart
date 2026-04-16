import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../CreateStore/presentation/cubit/create_store_cubit.dart';
import '../../../CreateStore/presentation/cubit/create_store_state.dart';
import '../../domain/entities/store_display_entity.dart';
import '../../domain/use_cases/update_store_profile_use_case.dart';
import '../cubit/edit_store_info_cubit.dart';
import '../cubit/edit_store_info_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EDIT STORE INFO PAGE
// Pre-fills all fields from the passed StoreDisplayEntity.
// Submits via EditStoreInfoCubit → UpdateStoreProfileUseCase → repository.
// ─────────────────────────────────────────────────────────────────────────────

class EditInfoShopPage extends StatefulWidget {
  final StoreDisplayEntity store;
  const EditInfoShopPage({super.key, required this.store});

  @override
  State<EditInfoShopPage> createState() => _EditInfoShopPageState();
}

class _EditInfoShopPageState extends State<EditInfoShopPage> {
  static const _blue = AppColors.primaryOfSeller;

  // ── Form key + controllers ─────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  // ── Hours state — one entry per day (0=Sun … 6=Sat) ───────────────────────
  late List<_DayHours> _hours;

  // ── Expanded day index (null = all collapsed) ──────────────────────────────
  int? _expandedDayIndex;

  // ── Working hours section expanded ─────────────────────────────────────────
  bool _workingHoursExpanded = false;

  // ── Selected categories (for editing) ──────────────────────────────────────
  late List<int> _selectedCategoryIds;

  // ── Day name (locale-aware) ────────────────────────────────────────────────
  String _dayName(AppLocalizations l10n, int dayIndex) {
    return switch (dayIndex) {
      0 => l10n.shop_display_day_sun,
      1 => l10n.shop_display_day_mon,
      2 => l10n.shop_display_day_tue,
      3 => l10n.shop_display_day_wed,
      4 => l10n.shop_display_day_thu,
      5 => l10n.shop_display_day_fri,
      _ => l10n.shop_display_day_sat,
    };
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.store.name);
    _descCtrl = TextEditingController(text: widget.store.description ?? '');
    _emailCtrl = TextEditingController(text: widget.store.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.store.phone ?? '');

    // Initialize selected category IDs from current store
    _selectedCategoryIds = widget.store.categories.map((c) => c.id).toList();

    // Seed hours from the existing store data; fill any missing days with defaults.
    final existingByDay = {
      for (final h in widget.store.hours) h.dayOfWeek: h,
    };
    _hours = List.generate(7, (day) {
      final existing = existingByDay[day];
      return _DayHours(
        dayOfWeek: day,
        openTime: _parseTime(existing?.openTime ?? '09:00'),
        closeTime: _parseTime(existing?.closeTime ?? '17:00'),
        isClosed: existing?.isClosed ?? false,
      );
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(
    BuildContext ctx,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onPicked,
  ) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: initial,
    );
    if (picked != null) onPicked(picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final params = UpdateStoreProfileParams(
      storeId: widget.store.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      categoryIds: _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds : null,
      hours: _hours
          .map(
            (h) => StoreHoursParams(
              dayOfWeek: h.dayOfWeek,
              openTime: _fmtTime(h.openTime),
              closeTime: _fmtTime(h.closeTime),
              isClosed: h.isClosed,
            ),
          )
          .toList(),
    );

    context.read<EditStoreInfoCubit>().save(params);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => di.sl<CreateStoreCubit>(),
      child: BlocListener<EditStoreInfoCubit, EditStoreInfoState>(
        listener: (ctx, state) {
          if (state is EditStoreInfoSuccess) {
            ctx.showSuccessSnackBar(state.message);
            Navigator.pop(ctx);
          } else if (state is EditStoreInfoError) {
            ctx.showErrorSnackBar(state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(context, l10n),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Store name ─────────────────────────────────────
                        _buildFieldLabel(context, l10n.edit_store_field_name),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _nameCtrl,
                          hint: l10n.edit_store_field_name_hint,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.edit_store_field_name_required
                              : null,
                        ),

                        SizedBox(height: 20.h),

                        // ── Category (Display as Card) ─────────────────────
                        _buildCategoryCard(context, l10n),

                        SizedBox(height: 20.h),

                        // ── Description ────────────────────────────────────
                        _buildFieldLabel(
                            context, l10n.edit_store_field_description_label),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _descCtrl,
                          hint: l10n.edit_store_field_description_hint,
                          maxLines: 4,
                        ),

                        SizedBox(height: 20.h),

                        // ── Email ──────────────────────────────────────────
                        _buildFieldLabel(context, l10n.email),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _emailCtrl,
                          hint: l10n.edit_store_field_email_hint,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(height: 20.h),

                        // ── Phone ──────────────────────────────────────────
                        _buildFieldLabel(context, l10n.phone_number),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _phoneCtrl,
                          hint: l10n.edit_store_field_phone_hint,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Working hours (Expandable Card) ────────────────────────
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header (always visible)
                        InkWell(
                          onTap: () => setState(() {
                            _workingHoursExpanded = !_workingHoursExpanded;
                            if (!_workingHoursExpanded) {
                              _expandedDayIndex = null; // Close any open day
                            }
                          }),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    color: _blue, size: 18.w),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    l10n.edit_store_working_hours_title,
                                    style: AppTextStyles.customStyle(
                                      context,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _workingHoursExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                  size: 24.w,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Days list (expandable)
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Column(
                            children: [
                              SizedBox(height: 16.h),
                              ...List.generate(
                                  7, (i) => _buildDayRow(context, l10n, i)),
                            ],
                          ),
                          crossFadeState: _workingHoursExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Save button ────────────────────────────────────────────
                  BlocBuilder<EditStoreInfoCubit, EditStoreInfoState>(
                    builder: (ctx, state) {
                      final isLoading = state is EditStoreInfoLoading;
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _submit,
                              icon: isLoading
                                  ? SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(Icons.save_rounded,
                                      color: Colors.white, size: 18.w),
                              label: Text(
                                isLoading
                                    ? l10n.edit_store_save_loading
                                    : l10n.edit_store_save_changes,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _blue,
                                disabledBackgroundColor:
                                    _blue.withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: OutlinedButton(
                              onPressed:
                                  isLoading ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: AppColors.divider, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                l10n.create_store_cancel,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Add safe area padding at bottom
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: BackButton(color: AppColors.textPrimary),
      title: Text(
        l10n.shop_display_edit_button,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        BlocBuilder<EditStoreInfoCubit, EditStoreInfoState>(
          builder: (ctx, state) {
            final isLoading = state is EditStoreInfoLoading;
            return TextButton(
              onPressed: isLoading ? null : _submit,
              child: Text(
                l10n.save,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isLoading ? AppColors.textSecondary : _blue,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Card wrapper ───────────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Field label ────────────────────────────────────────────────────────────

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ── Text field ─────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.customStyle(
        context,
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.customStyle(
          context,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: _blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  // ── Category Card ──────────────────────────────────────────────────────────

  Widget _buildCategoryCard(BuildContext context, AppLocalizations l10n) {
    String displayText = l10n.edit_store_select_category;

    if (_selectedCategoryIds.isNotEmpty) {
      final createStoreCubit = context.read<CreateStoreCubit>();
      final selectedCategory = createStoreCubit.state.categories
          .where((cat) => _selectedCategoryIds.contains(cat.id))
          .firstOrNull;

      if (selectedCategory != null) {
        displayText = selectedCategory.name;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, l10n.edit_store_category_label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _showCategoryBottomSheet(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      color: _selectedCategoryIds.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Show Category Bottom Sheet ─────────────────────────────────────────────

  void _showCategoryBottomSheet(BuildContext parentContext) {
    final l10n = AppLocalizations.of(parentContext)!;
    final createStoreCubit = parentContext.read<CreateStoreCubit>();

    // Trigger fetch if categories are empty
    if (createStoreCubit.state.categories.isEmpty &&
        !createStoreCubit.state.isCategoriesLoading) {
      createStoreCubit.fetchCategories();
    }

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: createStoreCubit,
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────────
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.divider, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.edit_store_select_category,
                          style: AppTextStyles.customStyle(
                            context,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 24.w,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // ── Categories List ────────────────────────────────────────
                Expanded(
                  child: BlocBuilder<CreateStoreCubit, CreateStoreState>(
                    builder: (context, state) {
                      // Loading state
                      if (state.isCategoriesLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: _blue),
                              SizedBox(height: 12.h),
                              Text(
                                l10n.edit_store_loading_categories,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Error state
                      if (state.categoriesErrorKey != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 48.w,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                l10n.edit_store_categories_error,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              TextButton.icon(
                                onPressed: () =>
                                    createStoreCubit.fetchCategories(),
                                icon: Icon(Icons.refresh_rounded, size: 18.w),
                                label: Text(l10n.retry),
                                style: TextButton.styleFrom(
                                  foregroundColor: _blue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Empty state
                      if (state.categories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                color: AppColors.textDisabled,
                                size: 48.w,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                l10n.no_categories_available,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Success state - Display categories in a scrollable list
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        itemCount: state.categories.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          final isSelected =
                              _selectedCategoryIds.contains(category.id);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIds = [category.id];
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _blue.withValues(alpha: 0.08)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color:
                                      isSelected ? _blue : AppColors.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Category name
                                  Expanded(
                                    child: Text(
                                      category.name,
                                      style: AppTextStyles.customStyle(
                                        context,
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? _blue
                                            : AppColors.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Selection indicator
                                  if (isSelected)
                                    Container(
                                      margin: EdgeInsetsDirectional.only(
                                          start: 8.w),
                                      padding: EdgeInsets.all(4.w),
                                      decoration: const BoxDecoration(
                                        color: _blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 16.w,
                                      ),
                                    )
                                  else
                                    Container(
                                      margin: EdgeInsetsDirectional.only(
                                          start: 8.w),
                                      width: 24.w,
                                      height: 24.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.divider,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Day row (Expandable) ───────────────────────────────────────────────────

  Widget _buildDayRow(
      BuildContext context, AppLocalizations l10n, int dayIndex) {
    final day = _hours[dayIndex];
    final isExpanded = _expandedDayIndex == dayIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isExpanded ? const Color(0xFFF9FAFB) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isExpanded ? _blue.withValues(alpha: 0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // ── Collapsed view (always visible) ──────────────────────────────
          InkWell(
            onTap: () => setState(() {
              _expandedDayIndex = isExpanded ? null : dayIndex;
            }),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  // Day name
                  Expanded(
                    flex: 2,
                    child: Text(
                      _dayName(l10n, dayIndex),
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Status/Time summary
                  Expanded(
                    flex: 3,
                    child: Text(
                      day.isClosed
                          ? l10n.shop_display_closed
                          : '${day.openTime.format(context)} - ${day.closeTime.format(context)}',
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: day.isClosed
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Switch
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: !day.isClosed,
                      activeColor: _blue,
                      onChanged: (val) {
                        setState(() => _hours[dayIndex].isClosed = !val);
                      },
                    ),
                  ),

                  // Expand/Collapse icon
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20.w,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded view (time pickers) ───────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: !day.isClosed
                ? Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                    child: Column(
                      children: [
                        Divider(
                          color: AppColors.divider.withValues(alpha: 0.5),
                          height: 1,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            // Open time
                            Expanded(
                              child: _buildTimeTile(
                                context,
                                label: l10n.edit_store_time_from,
                                time: day.openTime,
                                onTap: () => _pickTime(
                                  context,
                                  day.openTime,
                                  (t) => setState(
                                      () => _hours[dayIndex].openTime = t),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            // Close time
                            Expanded(
                              child: _buildTimeTile(
                                context,
                                label: l10n.edit_store_time_to,
                                time: day.closeTime,
                                onTap: () => _pickTime(
                                  context,
                                  day.closeTime,
                                  (t) => setState(
                                      () => _hours[dayIndex].closeTime = t),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            crossFadeState: isExpanded && !day.isClosed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(
    BuildContext context, {
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, color: _blue, size: 16.w),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  time.format(context),
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MUTABLE HOURS STATE PER DAY
// ─────────────────────────────────────────────────────────────────────────────

class _DayHours {
  final int dayOfWeek;
  TimeOfDay openTime;
  TimeOfDay closeTime;
  bool isClosed;

  _DayHours({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });
}
