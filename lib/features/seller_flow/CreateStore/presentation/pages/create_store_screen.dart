import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/constants/api_constants.dart';
import 'package:coupony/core/extensions/snackbar_extension.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/core/widgets/buttons/app_primary_button.dart';
import 'package:coupony/core/utils/message_formatter.dart';
import 'package:coupony/features/auth/presentation/cubit/login_cubit.dart';
import 'package:coupony/features/auth/presentation/cubit/auth_state.dart';
import 'package:coupony/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/entities/category_entity.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/entities/social_link_entity.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/entities/social_platform_entity.dart';
import 'package:coupony/features/seller_flow/CreateStore/data/models/social_platform_model.dart';
import 'package:coupony/features/seller_flow/CreateStore/domain/use_cases/create_store_use_case.dart';
import 'package:coupony/features/seller_flow/CreateStore/presentation/cubit/create_store_cubit.dart';
import 'package:coupony/features/seller_flow/CreateStore/presentation/cubit/create_store_state.dart';
import 'package:coupony/features/auth/data/models/user_store_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────

/// بناء URL كامل للصورة من المسار النسبي أو الكامل
String? _buildFullImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return null;
  
  // إذا كان URL كامل (يبدأ بـ http أو https)، استخدمه مباشرة
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  
  // إذا كان مسار نسبي، أضف base URL
  final baseUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
  
  // إضافة /storage/ إذا لم يكن موجوداً
  String cleanPath = imageUrl;
  if (!cleanPath.startsWith('/storage/') && !cleanPath.startsWith('storage/')) {
    cleanPath = '/storage/$cleanPath';
  } else if (!cleanPath.startsWith('/')) {
    cleanPath = '/$cleanPath';
  }
  
  final fullUrl = '$baseUrl$cleanPath';
  return fullUrl;
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE STORE MODE  (Strategy Pattern — decouples create vs. edit flows)
// ─────────────────────────────────────────────────────────────────────────────

/// Controls which flow is active inside [CreateStoreScreen].
///
/// [create]  — seller is registering a brand-new store.
///             Navigation on success → StoreUnderReview.
///
/// [edit]    — seller is correcting rejected/incomplete data.
///             Navigation on success → MerchantStatus.
///             Requires [storeId] to be supplied.
enum CreateStoreMode { create, edit }

// ─────────────────────────────────────────────────────────────────────────────
// CREATE STORE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CreateStoreScreen extends HookWidget {
  final CreateStoreMode mode;
  final String? storeId;
  /// Store snapshot used to pre-fill all form fields in edit mode.
  final UserStoreModel? initialStore;
  /// Optional override for post-success navigation.
  /// Null → default seller flow (→ storeUnderReview / merchantStatus).
  /// Non-null → caller-controlled destination (e.g. rejection loop → merchantPending).
  final VoidCallback? onSuccess;

  const CreateStoreScreen({
    super.key,
    this.mode = CreateStoreMode.create,
    this.storeId,
    this.initialStore,
    this.onSuccess,
  });

  bool get _isEditMode => mode == CreateStoreMode.edit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ── Hook declarations ──────────────────────────────────────────────────
    final storeNameController    = useTextEditingController();
    final phoneController        = useTextEditingController();
    final descriptionController  = useTextEditingController();
    final branchesController     = useTextEditingController();
    final cityController         = useTextEditingController();
    final areaController         = useTextEditingController();
    final selectedCategory       = useValueNotifier<CategoryEntity?>(null);
    final agreeToTerms           = useValueNotifier<bool>(false);
    final storeLogo              = useValueNotifier<File?>(null);

    // Verification docs
    final commercialRegister = useValueNotifier<File?>(null);
    final taxCard            = useValueNotifier<File?>(null);
    final idCardFront        = useValueNotifier<File?>(null);
    final idCardBack         = useValueNotifier<File?>(null);
    
    // Store the fetched store data for comparison in edit mode
    final fetchedStore = useValueNotifier<UserStoreModel?>(null);

    // ── Pre-fill from initialStore (edit mode only, runs once on mount) ────
    useEffect(() {
      if (!_isEditMode) return null;
      
      // If initialStore is provided and has data, use it
      if (initialStore != null) {
        final s = initialStore!;
        fetchedStore.value = s; // Store for comparison
        if (s.name.isNotEmpty)               storeNameController.text   = s.name;
        if (s.phone?.isNotEmpty ?? false)     phoneController.text       = s.phone!;
        if (s.description?.isNotEmpty ?? false) descriptionController.text = s.description!;
        if (s.city?.isNotEmpty ?? false)      cityController.text        = s.city!;
        if (s.area?.isNotEmpty ?? false)      areaController.text        = s.area!;
        if (s.branches != null)               branchesController.text    = s.branches.toString();
        return null;
      }
      
      // Otherwise, fetch store details from API
      final cubit = context.read<CreateStoreCubit>();
      Future.microtask(() async {
        final store = await cubit.fetchStoreDetails();
        
        if (store != null) {
          fetchedStore.value = store; // Store for comparison
          if (store.name.isNotEmpty)               storeNameController.text   = store.name;
          if (store.phone?.isNotEmpty ?? false)     phoneController.text       = store.phone!;
          if (store.description?.isNotEmpty ?? false) descriptionController.text = store.description!;
          if (store.city?.isNotEmpty ?? false)      cityController.text        = store.city!;
          if (store.area?.isNotEmpty ?? false)      areaController.text        = store.area!;
          if (store.branches != null)               branchesController.text    = store.branches.toString();
        }
      });
      
      return null;
    }, const []);

    // ── Reactive derivations ───────────────────────────────────────────────
    final storeNameValue   = useValueListenable(storeNameController);
    final phoneValue       = useValueListenable(phoneController);
    final descriptionValue = useValueListenable(descriptionController);
    useValueListenable(branchesController); // tracked for future use
    final cityValue        = useValueListenable(cityController);
    final areaValue        = useValueListenable(areaController);
    final categoryValue    = useValueListenable(selectedCategory);
    final termsValue       = useValueListenable(agreeToTerms);
    final fetchedStoreValue = useValueListenable(fetchedStore);

    final descriptionLength    = descriptionValue.text.length;
    const maxDescriptionLength = 500;
    final isDescriptionOverLimit = descriptionLength > maxDescriptionLength;

    final hasContent =
        storeNameValue.text.trim().isNotEmpty &&
        phoneValue.text.trim().isNotEmpty &&
        categoryValue != null &&
        cityValue.text.trim().isNotEmpty &&
        areaValue.text.trim().isNotEmpty &&
        !isDescriptionOverLimit &&
        termsValue;

    // ── BlocListener for side-effects ──────────────────────────────────────
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateStoreCubit, CreateStoreState>(
          listener: (context, state) {
            if (state.navigationSignal == CreateStoreNavigation.toStoreUnderReview) {
              context.read<CreateStoreCubit>().clearNavigationSignal();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                if (onSuccess != null) {
                  onSuccess!();
                } else {
                  context.go(AppRouter.storeUnderReview);
                }
              });
            }
            if (state.navigationSignal == CreateStoreNavigation.toMerchantDashboard) {
              context.read<CreateStoreCubit>().clearNavigationSignal();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go(AppRouter.merchantDashboard);
              });
            }
            if (state.navigationSignal == CreateStoreNavigation.toMerchantStatus) {
              context.read<CreateStoreCubit>().clearNavigationSignal();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                if (onSuccess != null) {
                  onSuccess!();
                } else {
                  context.go(AppRouter.merchantStatus);
                }
              });
            }
            if (state.errorKey != null) {
              context.showErrorSnackBar(context.getLocalizedMessage(state.errorKey));
            }
            if (state.successKey != null) {
              context.showSuccessSnackBar(context.getLocalizedMessage(state.successKey));
            }
          },
        ),
        BlocListener<LoginCubit, AuthState>(
          listenWhen: (previous, current) => 
            previous.navSignal != current.navSignal && 
            current.navSignal == AuthNavigation.toLogin,
          listener: (context, state) {
            context.go('/login');
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16.h),

                  // ── Top bar ─────────────────────────────────────────
                  _TopBar(l10n: l10n),
                  SizedBox(height: 28.h),

                  // ── Title ───────────────────────────────────────────
                  Text(
                    _isEditMode ? l10n.update_store_title : l10n.create_store_title,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),

                  // ── Logo Upload Area ────────────────────────────────
                  _LogoUploadArea(l10n: l10n, storeLogo: storeLogo),
                  SizedBox(height: 20.h),

                  // ── Store Name field ────────────────────────────────
                  AuthTextField(
                    controller: storeNameController,
                    hint: l10n.create_store_name_hint,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    overrideColor: AppColors.primaryOfSeller,
                  ),
                  SizedBox(height: 12.h),

                  // ── Phone field ─────────────────────────────────────
                  AuthTextField(
                    controller: phoneController,
                    hint: l10n.create_store_phone_hint,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    overrideColor: AppColors.primaryOfSeller,
                  ),
                  SizedBox(height: 12.h),

                  // ── Category Dropdown ───────────────────────────────
                  _CategoryDropdown(
                    l10n: l10n,
                    selectedCategory: selectedCategory,
                  ),
                  SizedBox(height: 12.h),

                  // ── Description field with counter ──────────────────
                  _DescriptionField(
                    controller: descriptionController,
                    l10n: l10n,
                    currentLength: descriptionLength,
                    maxLength: maxDescriptionLength,
                    isOverLimit: isDescriptionOverLimit,
                  ),
                  SizedBox(height: 12.h),

                  // ── City & Area fields ──────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: AuthTextField(
                          controller: cityController,
                          hint: l10n.create_store_city_hint,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          overrideColor: AppColors.primaryOfSeller,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AuthTextField(
                          controller: areaController,
                          hint: l10n.create_store_area_hint,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          overrideColor: AppColors.primaryOfSeller,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // ── Branches field ──────────────────────────────────
                  AuthTextField(
                    controller: branchesController,
                    hint: l10n.create_store_branches_hint,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    overrideColor: AppColors.primaryOfSeller,
                  ),
                  SizedBox(height: 20.h),

                  // ── Location Picker ─────────────────────────────────
                  _LocationPickerSection(l10n: l10n),
                  SizedBox(height: 20.h),

                  // ── Social Links ────────────────────────────────────
                  _SocialLinksSection(l10n: l10n),
                  SizedBox(height: 20.h),

                  // ── Verification Documents ──────────────────────────
                  _VerificationDocsSection(
                    l10n: l10n,
                    commercialRegister: commercialRegister,
                    taxCard: taxCard,
                    idCardFront: idCardFront,
                    idCardBack: idCardBack,
                  ),
                  SizedBox(height: 16.h),

                  // ── Terms & Conditions checkbox ─────────────────────
                  _TermsCheckbox(agreeToTerms: agreeToTerms, l10n: l10n),
                  SizedBox(height: 24.h),

                  // ── Create / Update Store button ────────────────────
                  BlocBuilder<CreateStoreCubit, CreateStoreState>(
                    buildWhen: (prev, next) =>
                        prev.isSubmitting != next.isSubmitting,
                    builder: (context, state) {
                      return AppPrimaryButton(
                        text: _isEditMode
                            ? l10n.update_store_button
                            : l10n.create_store_button,
                        isLoading: state.isSubmitting,
                        onPressed: hasContent && !state.isSubmitting
                            ? () => _onSubmit(
                                  context,
                                  storeNameController.text.trim(),
                                  phoneController.text.trim(),
                                  descriptionController.text.trim(),
                                  categoryValue,
                                  cityController.text.trim(),
                                  areaController.text.trim(),
                                  storeLogo.value,
                                  commercialRegister.value,
                                  taxCard.value,
                                  idCardFront.value,
                                  idCardBack.value,
                                  fetchedStoreData: fetchedStoreValue,
                                )
                            : null,
                        height: 56.h,
                        backgroundColor: hasContent && !state.isSubmitting
                            ? AppColors.primaryOfSeller
                            : AppColors.textDisabled,
                        textStyle: AppTextStyles.customStyle(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.surface,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit(
    BuildContext context,
    String name,
    String phone,
    String description,
    CategoryEntity? category,
    String city,
    String area,
    File? logo,
    File? commercialRegister,
    File? taxCard,
    File? idCardFront,
    File? idCardBack, {
    UserStoreModel? fetchedStoreData,
  }) {
    final cubit = context.read<CreateStoreCubit>();
    final params = CreateStoreParams(
      name: name,
      description: description,
      phone: phone,
      categoryId: category?.id ?? 0,
      city: city,
      addressLine1: area,
      latitude: cubit.state.latitude,
      longitude: cubit.state.longitude,
      socials: cubit.state.socialLinks,
      logo: logo,
      commercialRegister: commercialRegister,
      taxCard: taxCard,
      idCardFront: idCardFront,
      idCardBack: idCardBack,
    );

    if (_isEditMode && storeId != null) {
      // ══════════════════════════════════════════════════════════════════════
 
      final storeToCompare = fetchedStoreData ?? initialStore;
      
      if (storeToCompare != null && storeToCompare.isRejected) {
        final textFieldsUnchanged =
            name        == storeToCompare.name &&
            phone       == (storeToCompare.phone ?? '') &&
            description == (storeToCompare.description ?? '') &&
            city        == (storeToCompare.city ?? '') &&
            area        == (storeToCompare.area ?? '');

        // Check if logo was changed (new file selected)
        final logoUnchanged = logo == null;

        // Check if location was changed
        // Note: We don't have initial lat/lng in UserStoreModel, so we assume
        // if user didn't pick a new location, it's unchanged
        final locationUnchanged = 
            cubit.state.latitude == '0.0' && cubit.state.longitude == '0.0';

        // Check if social links were changed
        // Note: We don't have initial socials in UserStoreModel, so we assume
        // if user didn't add new socials, it's unchanged
        final socialsUnchanged = cubit.state.socialLinks.isEmpty;

        // Check if verification docs were changed
        final docsUnchanged = 
            commercialRegister == null &&
            taxCard == null &&
            idCardFront == null &&
            idCardBack == null;

        // If ALL fields are unchanged, block submission
        if (textFieldsUnchanged && 
            logoUnchanged && 
            locationUnchanged && 
            socialsUnchanged && 
            docsUnchanged) {
          final l10n = AppLocalizations.of(context)!;
          
          // Get rejection reason (prefer single reason, fallback to list)
          String message;
          if (storeToCompare.rejectionReason != null && storeToCompare.rejectionReason!.isNotEmpty) {
            message = '${l10n.merchant_no_changes_snackbar}\n\n${storeToCompare.rejectionReason}';
          } else if (storeToCompare.rejectionReasons.isNotEmpty) {
            message = '${l10n.merchant_no_changes_snackbar}\n\n${storeToCompare.rejectionReasons.join('\n')}';
          } else {
            message = l10n.merchant_no_changes_snackbar;
          }
          
          context.showErrorSnackBar(message);
          return;
        }
      }
      cubit.updateStore(storeId!, params);
    } else {
      cubit.createStore(params);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE STORE ROUTE ARGS  (passed as GoRouter `extra`)
// ─────────────────────────────────────────────────────────────────────────────

class CreateStoreArgs {
  final CreateStoreMode mode;
  final String? storeId;
  /// Store snapshot used to pre-fill the form in edit mode.
  final UserStoreModel? initialStore;
  /// Called after a successful submission instead of the default
  /// [AppRouter.storeUnderReview] redirect.  When null the screen
  /// falls back to the original seller-onboarding destination so the
  /// existing flow is fully preserved.
  final VoidCallback? onSuccess;

  const CreateStoreArgs({
    this.mode = CreateStoreMode.create,
    this.storeId,
    this.initialStore,
    this.onSuccess,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final AppLocalizations l10n;
  const _TopBar({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: FaIcon(
                FontAwesomeIcons.arrowRight,
                size: 20.w,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LogoUploadArea extends HookWidget {
  final AppLocalizations l10n;
  final ValueNotifier<File?> storeLogo;

  const _LogoUploadArea({required this.l10n, required this.storeLogo});

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      storeLogo.value = File(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoValue = useValueListenable(storeLogo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.create_store_logo_label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // ── Logo Box (Left/Start) ──────────────────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.divider, width: 1.5.w),
                ),
                child: logoValue != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(logoValue, fit: BoxFit.cover),
                      )
                    : Center(
                        child: FaIcon(
                          FontAwesomeIcons.image,
                          size: 32.w,
                          color: AppColors.textDisabled,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            
            // ── Description Text (Right/End) ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.create_store_logo_hint,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.create_store_logo_format,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueNotifier<CategoryEntity?> selectedCategory;

  const _CategoryDropdown({required this.l10n, required this.selectedCategory});

  void _showCategoryMenu(
    BuildContext context,
    List<CategoryEntity> categories,
    RenderBox renderBox,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    
    final selected = await showMenu<CategoryEntity>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height + 4.h,
        position.dx + renderBox.size.width,
        position.dy + renderBox.size.height + 4.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 8,
      color: AppColors.surface,
      constraints: BoxConstraints(
        maxHeight: 280.h,
        minWidth: renderBox.size.width,
      ),
      items: [
        // ── Scroll Indicator Header ────────────────────────────────────────
        PopupMenuItem<CategoryEntity>(
          enabled: false,
          height: 32.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.unfold_more_rounded,
                size: 16.w,
                color: AppColors.textDisabled,
              ),
              SizedBox(width: 4.w),
              Text(
                l10n.create_store_category_scroll_hint,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 11,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
        
        // ── Categories ─────────────────────────────────────────────────────
        ...categories.map((category) {
          return PopupMenuItem<CategoryEntity>(
            value: category,
            height: 52.h,
            child: Row(
              children: [
                // ── Category Icon ──────────────────────────────────────────
                _CategoryIcon(category: category),
                SizedBox(width: 12.w),
                
                // ── Category Name ──────────────────────────────────────────
                Expanded(
                  child: Text(
                    category.name,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );

    if (selected != null) {
      selectedCategory.value = selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      buildWhen: (prev, next) =>
          prev.categories != next.categories ||
          prev.isCategoriesLoading != next.isCategoriesLoading,
      builder: (context, state) {
        return ValueListenableBuilder<CategoryEntity?>(
          valueListenable: selectedCategory,
          builder: (context, value, _) {
            return Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: state.isCategoriesLoading || state.categories.isEmpty
                      ? null
                      : () {
                          final renderBox = context.findRenderObject() as RenderBox;
                          _showCategoryMenu(context, state.categories, renderBox);
                        },
                  child: Container(
                    height: 56.r,
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.divider, width: 1.5.w),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: state.isCategoriesLoading
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryOfSeller,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      l10n.create_store_category_hint,
                                      style: AppTextStyles.customStyle(
                                        context,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDisabled,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  value?.name ?? l10n.create_store_category_hint,
                                  style: AppTextStyles.customStyle(
                                    context,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: value != null
                                        ? AppColors.textPrimary
                                        : AppColors.textDisabled,
                                  ),
                                ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.chevronDown,
                          color: AppColors.textSecondary,
                          size: 16.w,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY ICON WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryIcon extends StatelessWidget {
  final CategoryEntity category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    // If icon_url is available, show network image
    if (category.iconUrl != null && category.iconUrl!.isNotEmpty) {
      return _buildNetworkIcon(context);
    }

    // Fallback to default icon
    return _buildFallbackIcon();
  }

  Widget _buildNetworkIcon(BuildContext context) {
    final iconUrl = category.iconUrl!;
    final isSvg = iconUrl.toLowerCase().endsWith('.svg');

    return Container(
      width: 36.w,
      height: 36.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: isSvg
          ? SvgPicture.network(
              iconUrl,
              width: 20.w,
              height: 20.w,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => _buildLoadingIcon(),
              // ✅ Try to apply color filter (works only for monochrome SVGs)
              colorFilter: ColorFilter.mode(
                AppColors.primaryOfSeller,
                BlendMode.srcIn,
              ),
            )
          : CachedNetworkImage(
              imageUrl: iconUrl,
              width: 20.w,
              height: 20.w,
              fit: BoxFit.contain,
              placeholder: (context, url) => _buildLoadingIcon(),
              errorWidget: (context, url, error) => _buildFallbackIcon(),
              // ✅ Try to apply color filter for PNG/JPG
              color: AppColors.primaryOfSeller,
              colorBlendMode: BlendMode.srcIn,
            ),
    );
  }

  Widget _buildLoadingIcon() {
    return SizedBox(
      width: 20.w,
      height: 20.w,
      child: Center(
        child: SizedBox(
          width: 14.w,
          height: 14.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryOfSeller,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 36.w,
      height: 36.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: FaIcon(
        FontAwesomeIcons.tag,
        size: 16.w,
        color: AppColors.primaryOfSeller,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;
  final int currentLength;
  final int maxLength;
  final bool isOverLimit;

  const _DescriptionField({
    required this.controller,
    required this.l10n,
    required this.currentLength,
    required this.maxLength,
    required this.isOverLimit,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor        = isOverLimit ? AppColors.error : AppColors.divider;
    final focusedBorderColor = isOverLimit ? AppColors.error : AppColors.primaryOfSeller;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: borderColor, width: 1.5.w),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: focusedBorderColor, width: 1.5.w),
    );

    return Column(
      children: [
        SizedBox(
          height: 120.h,
          child: TextField(
            controller: controller,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: l10n.create_store_description_hint,
              hintStyle: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDisabled,
              ),
              contentPadding: EdgeInsetsDirectional.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: border,
              enabledBorder: border,
              focusedBorder: focusedBorder,
              errorBorder: border,
              focusedErrorBorder: focusedBorder,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isOverLimit)
              Text(
                l10n.create_store_description_error,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 12,
                  color: AppColors.error,
                ),
              )
            else
              const SizedBox.shrink(),
            Text(
              '$currentLength/$maxLength',
              style: AppTextStyles.customStyle(
                context,
                fontSize: 12,
                color: isOverLimit ? AppColors.error : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOCIAL LINKS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _SocialLinksSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _SocialLinksSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      buildWhen: (prev, next) => prev.socialLinks != next.socialLinks,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.create_store_socials_label,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddSocialDialog(context),
                  icon: FaIcon(FontAwesomeIcons.plus, size: 16.w, color: AppColors.primaryOfSeller),
                  label: Text(
                    l10n.create_store_add_social,
                    style: AppTextStyles.customStyle(
                      context,
                      fontSize: 13,
                      color: AppColors.primaryOfSeller,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (state.socialLinks.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  l10n.create_store_socials_empty,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.socialLinks.length,
                // FIX: unnecessary_underscores → use single underscore
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final social = state.socialLinks[index];
                  return _SocialLinkTile(
                    social: social,
                    index: index,
                    onRemove: () =>
                        context.read<CreateStoreCubit>().removeSocialLink(index),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showAddSocialDialog(BuildContext context) {
    final cubit = context.read<CreateStoreCubit>();
    final linkController = TextEditingController();

    // FIX: was SocialPlatformModel? — changed to SocialPlatformEntity? to match state type
    final selectedPlatformNotifier = ValueNotifier<SocialPlatformEntity?>(null);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(context)!;

        return BlocBuilder<CreateStoreCubit, CreateStoreState>(
          bloc: cubit,
          buildWhen: (prev, next) =>
              prev.socialPlatforms != next.socialPlatforms ||
              prev.isSocialPlatformsLoading != next.isSocialPlatformsLoading,
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Handle ────────────────────────────────────────
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),

                      // ── Title ─────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.link,
                                color: AppColors.primaryOfSeller,
                                size: 22.w,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.create_store_add_social,
                                    style: AppTextStyles.customStyle(
                                      context,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    l10n.create_store_select_platform,
                                    style: AppTextStyles.customStyle(
                                      context,
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Platform Selection Grid ──────────────────────
                      if (state.isSocialPlatformsLoading)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primaryOfSeller,
                            ),
                          ),
                        )
                      else if (state.socialPlatforms.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(32.h),
                          child: Center(
                            child: Column(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.linkSlash,
                                  size: 44.w,
                                  color: AppColors.textDisabled,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  l10n.create_store_no_platforms,
                                  style: AppTextStyles.customStyle(
                                    context,
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // FIX: SocialPlatformEntity? instead of SocialPlatformModel?
                        ValueListenableBuilder<SocialPlatformEntity?>(
                          valueListenable: selectedPlatformNotifier,
                          builder: (context, selectedPlatform, _) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: state.socialPlatforms.length,
                                itemBuilder: (context, index) {
                                  final platform = state.socialPlatforms[index];
                                  final isSelected = selectedPlatform?.id == platform.id;

                                  return GestureDetector(
                                    onTap: () {
                                      selectedPlatformNotifier.value = platform;
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryOfSeller.withValues(alpha: 0.12)
                                            : AppColors.surface,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryOfSeller
                                              : AppColors.divider,
                                          width: isSelected ? 2.w : 1.w,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2.h),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (platform.iconUrl.isNotEmpty)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8.r),
                                              child: CachedNetworkImage(
                                                imageUrl: _buildFullImageUrl(platform.iconUrl) ?? '',
                                                width: 40.w,
                                                height: 40.w,
                                                fit: BoxFit.contain,
                                                errorWidget: (context, url, error) => FaIcon(
                                                  FontAwesomeIcons.link,
                                                  size: 36.w,
                                                  color: isSelected
                                                      ? AppColors.primaryOfSeller
                                                      : AppColors.textDisabled,
                                                ),
                                                placeholder: (context, url) => SizedBox(
                                                  width: 40.w,
                                                  height: 40.w,
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: AppColors.primaryOfSeller,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            FaIcon(
                                              FontAwesomeIcons.link,
                                              size: 36.w,
                                              color: isSelected
                                                  ? AppColors.primaryOfSeller
                                                  : AppColors.textDisabled,
                                            ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            platform.name,
                                            style: AppTextStyles.customStyle(
                                              context,
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? AppColors.primaryOfSeller
                                                  : AppColors.textPrimary,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (isSelected)
                                            Padding(
                                              padding: EdgeInsets.only(top: 4.h),
                                              child: FaIcon(
                                                FontAwesomeIcons.circleCheck,
                                                size: 14.w,
                                                color: AppColors.primaryOfSeller,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                      SizedBox(height: 20.h),

                      // ── Link TextField ────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.create_store_social_link_hint,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            TextField(
                              controller: linkController,
                              keyboardType: TextInputType.url,
                              textDirection: TextDirection.ltr,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'https://...',
                                hintStyle: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.textDisabled,
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: FaIcon(
                                    FontAwesomeIcons.link,
                                    color: AppColors.textSecondary,
                                    size: 18.w,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.divider,
                                    width: 1.5.w,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.divider,
                                    width: 1.5.w,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryOfSeller,
                                    width: 2.w,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // ── Action Buttons ────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  side: BorderSide(
                                    color: AppColors.divider,
                                    width: 1.5.w,
                                  ),
                                ),
                                child: Text(
                                  l10n.create_store_cancel,
                                  style: AppTextStyles.customStyle(
                                    context,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 2,
                              // FIX: SocialPlatformEntity? instead of SocialPlatformModel?
                              child: ValueListenableBuilder<SocialPlatformEntity?>(
                                valueListenable: selectedPlatformNotifier,
                                builder: (context, selectedPlatform, _) {
                                  return AppPrimaryButton(
                                    text: l10n.create_store_add_social,
                                    onPressed: selectedPlatform != null
                                        ? () {
                                            final link = linkController.text.trim();
                                            if (link.isNotEmpty) {
                                              cubit.addSocialLink(
                                                socialId: selectedPlatform.id,
                                                link: link,
                                              );
                                              Navigator.pop(dialogContext);
                                            }
                                          }
                                        : null,
                                    height: 50.h,
                                    backgroundColor: selectedPlatform != null
                                        ? AppColors.primaryOfSeller
                                        : AppColors.textDisabled,
                                    textStyle: AppTextStyles.customStyle(
                                      context,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.surface,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SocialLinkTile extends StatelessWidget {
  final SocialLinkEntity social;
  final int index;
  final VoidCallback onRemove;

  const _SocialLinkTile({
    required this.social,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      buildWhen: (prev, next) => prev.socialPlatforms != next.socialPlatforms,
      builder: (context, state) {
        final platform = state.socialPlatforms.firstWhere(
          (p) => p.id == social.socialId,
          orElse: () => const SocialPlatformModel(
            id: 0,
            name: 'Unknown',
            icon: '',
            iconUrl: '',
          ),
        );

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.divider, width: 1.w),
          ),
          child: Row(
            children: [
              if (platform.iconUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: _buildFullImageUrl(platform.iconUrl) ?? '',
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => FaIcon(
                    FontAwesomeIcons.link,
                    size: 18.w,
                    color: AppColors.primaryOfSeller,
                  ),
                  placeholder: (context, url) => SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.primaryOfSeller,
                    ),
                  ),
                )
              else
                FaIcon(
                  FontAwesomeIcons.link,
                  size: 18.w,
                  color: AppColors.primaryOfSeller,
                ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform.name,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      social.link,
                      style: AppTextStyles.customStyle(
                        context,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.xmark, size: 16.w, color: AppColors.error),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VERIFICATION DOCUMENTS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _VerificationDocsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ValueNotifier<File?> commercialRegister;
  final ValueNotifier<File?> taxCard;
  final ValueNotifier<File?> idCardFront;
  final ValueNotifier<File?> idCardBack;

  const _VerificationDocsSection({
    required this.l10n,
    required this.commercialRegister,
    required this.taxCard,
    required this.idCardFront,
    required this.idCardBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.create_store_verification_docs_label,
          style: AppTextStyles.customStyle(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        _DocPickerRow(
          label: l10n.create_store_commercial_register_hint,
          fileNotifier: commercialRegister,
        ),
        SizedBox(height: 10.h),
        _DocPickerRow(
          label: l10n.create_store_tax_card_hint,
          fileNotifier: taxCard,
        ),
        SizedBox(height: 10.h),
        _DocPickerRow(
          label: l10n.create_store_id_front_hint,
          fileNotifier: idCardFront,
        ),
        SizedBox(height: 10.h),
        _DocPickerRow(
          label: l10n.create_store_id_back_hint,
          fileNotifier: idCardBack,
        ),
      ],
    );
  }
}

class _DocPickerRow extends HookWidget {
  final String label;
  final ValueNotifier<File?> fileNotifier;

  const _DocPickerRow({required this.label, required this.fileNotifier});

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      fileNotifier.value = File(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileValue = useValueListenable(fileNotifier);
    final hasFile   = fileValue != null;

    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primaryOfSeller.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasFile ? AppColors.primaryOfSeller : AppColors.divider,
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            FaIcon(
              hasFile ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.fileArrowUp,
              size: 20.w,
              color: hasFile ? AppColors.primaryOfSeller : AppColors.textDisabled,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                hasFile
                    ? fileValue.path.split(RegExp(r'[/\\]')).last
                    : label,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 13,
                  color: hasFile ? AppColors.textPrimary : AppColors.textDisabled,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasFile)
              GestureDetector(
                onTap: () => fileNotifier.value = null,
                child: FaIcon(FontAwesomeIcons.xmark, size: 16.w, color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION PICKER SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _LocationPickerSection extends StatelessWidget {
  final AppLocalizations l10n;
  const _LocationPickerSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStoreCubit, CreateStoreState>(
      buildWhen: (prev, next) =>
          prev.isLocationLoading != next.isLocationLoading ||
          prev.latitude != next.latitude ||
          prev.longitude != next.longitude,
      builder: (context, state) {
        final hasLocation = state.latitude.isNotEmpty && state.longitude.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.create_store_location_section_label,
              style: AppTextStyles.customStyle(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: state.isLocationLoading
                  ? null
                  : () async {
                      // FIX: save cubit before async gap
                      final cubit = context.read<CreateStoreCubit>();

                      final result = await showModalBottomSheet<LatLng>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        // FIX: BlocProvider.value to pass cubit into the new route context
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const _MapLocationBottomSheet(),
                        ),
                      );

                      if (result != null && context.mounted) {
                        cubit.setLocation(
                          result.latitude.toString(),
                          result.longitude.toString(),
                        );
                      }
                    },
              // FIX: restored the missing child (was removed accidentally)
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppColors.primaryOfSeller.withValues(alpha: 0.06)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: hasLocation
                        ? AppColors.primaryOfSeller
                        : AppColors.divider,
                    width: 1.5.w,
                  ),
                ),
                child: state.isLocationLoading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryOfSeller,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            l10n.create_store_locate_button,
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          FaIcon(
                            hasLocation
                                ? FontAwesomeIcons.locationDot
                                : FontAwesomeIcons.locationCrosshairs,
                            size: 18.w,
                            color: hasLocation
                                ? AppColors.primaryOfSeller
                                : AppColors.textDisabled,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              hasLocation
                                  ? l10n.create_store_location_fetched
                                  : l10n.create_store_locate_button,
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 13,
                                color: hasLocation
                                    ? AppColors.textPrimary
                                    : AppColors.textDisabled,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (hasLocation)
                            FaIcon(
                              FontAwesomeIcons.circleCheck,
                              size: 16.w,
                              color: AppColors.primaryOfSeller,
                            ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAP LOCATION BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

/// Self-contained map bottom sheet.
/// Returns a [LatLng] via [Navigator.pop] when the user confirms a location,
/// Map Bottom Sheet for selecting store location.
///
/// Features:
/// - SafeArea wrapping
/// - Search with text + voice input
/// - Current GPS location as default
/// - Center-pin pattern (drag map to select)
/// - Address geocoding with loading shimmer
/// - "Use Current Location" button
///
/// Returns a [LatLng] via [Navigator.pop] when the user confirms a location,
/// or null when dismissed without confirming.
class _MapLocationBottomSheet extends StatefulWidget {
  const _MapLocationBottomSheet();

  @override
  State<_MapLocationBottomSheet> createState() => _MapLocationBottomSheetState();
}

class _MapLocationBottomSheetState extends State<_MapLocationBottomSheet> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357); // Cairo fallback

  bool _isMapReady = false;
  bool _isMapLoading = true; // ✅ Added: Track map loading state
  LatLng _lastCameraCenter = _defaultLocation;
  LatLng? _selectedLatLng;
  String? _currentAddress;
  bool _isAddressLoading = false;

  /// True once the camera has been animated to the GPS position.
  bool _hasCenteredOnGps = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CreateStoreCubit>();
      final lat = cubit.state.latitude;
      final lng = cubit.state.longitude;

      if (lat.isNotEmpty && lng.isNotEmpty) {
        final gpsPos = LatLng(
          double.tryParse(lat) ?? _defaultLocation.latitude,
          double.tryParse(lng) ?? _defaultLocation.longitude,
        );
        _lastCameraCenter = gpsPos;
        setState(() => _isMapLoading = false); // ✅ Stop loading if we have position
      }
    });

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final cubit = context.read<CreateStoreCubit>();
      await cubit.determinePosition();
      
      // ✅ Stop loading after getting position
      if (mounted) {
        setState(() => _isMapLoading = false);
      }
    } catch (_) {
      // GPS unavailable — stop loading and use fallback
      if (mounted) {
        setState(() => _isMapLoading = false);
      }
    }
  }

  void _moveCameraToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (!mounted) return;

      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);
        _moveCameraToPosition(newPosition);
      } else {
        if (mounted) {
          context.showErrorSnackBar(
            AppLocalizations.of(context)!.create_store_map_no_results,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        context.showErrorSnackBar(
          AppLocalizations.of(context)!.create_store_map_search_error,
        );
      }
    }
  }

  Future<void> _startListening() async {
    try {
      final available = await _speech.initialize(
        onError: (_) => setState(() => _isListening = false),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );

      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() => _searchController.text = result.recognizedWords);
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _searchLocation(result.recognizedWords);
              _speech.stop();
              setState(() => _isListening = false);
            }
          },
          localeId: 'ar_EG',
        );
      } else {
        if (mounted) {
          context.showWarningSnackBar(
            AppLocalizations.of(context)!.create_store_map_voice_unavailable,
          );
        }
      }
    } catch (_) {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    setState(() => _isAddressLoading = true);

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _currentAddress = address.isNotEmpty ? address : null;
          _isAddressLoading = false;
        });
      } else {
        setState(() => _isAddressLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAddressLoading = false);
      }
    }

    // Safety timeout
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isAddressLoading) {
        setState(() => _isAddressLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sheetHeight = MediaQuery.of(context).size.height * 0.78;

    return BlocListener<CreateStoreCubit, CreateStoreState>(
      listenWhen: (prev, curr) {
        if ((prev.latitude.isEmpty || prev.longitude.isEmpty) &&
            (curr.latitude.isNotEmpty && curr.longitude.isNotEmpty)) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state.latitude.isNotEmpty &&
            state.longitude.isNotEmpty &&
            _isMapReady &&
            !_hasCenteredOnGps) {
          _hasCenteredOnGps = true;
          final gpsPos = LatLng(
            double.tryParse(state.latitude) ?? _defaultLocation.latitude,
            double.tryParse(state.longitude) ?? _defaultLocation.longitude,
          );
          _moveCameraToPosition(gpsPos);

          setState(() {
            _selectedLatLng = gpsPos;
            _isAddressLoading = true;
            _isMapLoading = false; // ✅ Stop loading when position arrives
          });
          _getAddressFromCoordinates(gpsPos.latitude, gpsPos.longitude);
        }
      },
      child: SafeArea(
        child: Container(
          height: sheetHeight,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────────────────
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              // ── Search Bar with Location Icon ────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    // Orange location icon (with tap functionality)
                    GestureDetector(
                      onTap: () async {
                        await _getCurrentLocation();
                        if (mounted && _isMapReady) {
                          _moveCameraToPosition(_lastCameraCenter);
                        }
                      },
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOfSeller,
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.locationDot,
                          color: AppColors.surface,
                          size: 20.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Search box
                    Expanded(
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.divider, width: 1.w),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_searchController.text.trim().isNotEmpty) {
                                  _searchLocation(_searchController.text.trim());
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  color: AppColors.textSecondary,
                                  size: 18.w,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.create_store_map_search_placeholder,
                                  hintStyle: AppTextStyles.customStyle(
                                    context,
                                    fontSize: 14,
                                    color: AppColors.textDisabled,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 14.h,
                                  ),
                                ),
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    _searchLocation(value.trim());
                                  }
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: _isListening ? _stopListening : _startListening,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: FaIcon(
                                  _isListening ? FontAwesomeIcons.microphone : FontAwesomeIcons.microphoneLines,
                                  color: _isListening
                                      ? AppColors.primaryOfSeller
                                      : AppColors.textSecondary,
                                  size: 18.w,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // ── Map ───────────────────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    // ── Google Map (Hidden while loading) ──────────────
                    if (!_isMapLoading)
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _lastCameraCenter,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          setState(() => _isMapReady = true);

                          final cubit = context.read<CreateStoreCubit>();
                          final lat = cubit.state.latitude;
                          final lng = cubit.state.longitude;

                          if (lat.isNotEmpty && lng.isNotEmpty && !_hasCenteredOnGps) {
                            _hasCenteredOnGps = true;
                            final gpsPos = LatLng(
                              double.tryParse(lat) ?? _defaultLocation.latitude,
                              double.tryParse(lng) ?? _defaultLocation.longitude,
                            );
                            Future.delayed(const Duration(milliseconds: 200), () {
                              if (mounted) {
                                _moveCameraToPosition(gpsPos);
                                setState(() {
                                  _selectedLatLng = gpsPos;
                                  _isAddressLoading = true;
                                });
                                _getAddressFromCoordinates(
                                  gpsPos.latitude,
                                  gpsPos.longitude,
                                );
                              }
                            });
                          }
                        },
                        onCameraMove: (CameraPosition pos) {
                          _lastCameraCenter = pos.target;
                          if (!_isAddressLoading) {
                            setState(() => _isAddressLoading = true);
                          }
                        },
                        onCameraIdle: () {
                          setState(() => _selectedLatLng = _lastCameraCenter);
                          _getAddressFromCoordinates(
                            _lastCameraCenter.latitude,
                            _lastCameraCenter.longitude,
                          );
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                      ),

                    // ── Center Pin ──────────────────────────────────────
                    if (_isMapReady && !_isMapLoading)
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 36.h),
                          child: Icon(
                            Icons.location_pin,
                            color: AppColors.primaryOfSeller,
                            size: 48.w,
                            shadows: [
                              Shadow(
                                color: AppColors.shadow.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Map Loading Overlay ─────────────────────────────
                    if (_isMapLoading)
                      Positioned.fill(
                        child: Container(
                          color: AppColors.surface,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Loading Icon
                              Container(
                                width: 80.w,
                                height: 80.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOfSeller.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.locationCrosshairs,
                                  size: 36.w,
                                  color: AppColors.primaryOfSeller,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              
                              // Loading Indicator
                              SizedBox(
                                width: 40.w,
                                height: 40.w,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryOfSeller,
                                  strokeWidth: 3.w,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              
                              // Loading Text
                              Text(
                                l10n.permissions_location_checking,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                l10n.permissions_please_wait,
                                style: AppTextStyles.customStyle(
                                  context,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                  ],
                ),
              ),

              // ── Bottom Info Sheet ─────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, -2.h),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationDot,
                            color: AppColors.primaryOfSeller,
                            size: 18.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.create_store_map_your_location,
                            style: AppTextStyles.customStyle(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryOfSeller,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      _isAddressLoading
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 14.w,
                                  height: 14.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryOfSeller,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '...',
                                  style: AppTextStyles.customStyle(
                                    context,
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _currentAddress ??
                                  (_selectedLatLng != null
                                      ? '${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
                                      : l10n.create_store_map_tap_to_select),
                              style: AppTextStyles.customStyle(
                                context,
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      SizedBox(height: 16.h),

                      AppPrimaryButton(
                        text: l10n.create_store_map_confirm_button,
                        onPressed: _selectedLatLng != null
                            ? () => Navigator.of(context).pop(_selectedLatLng)
                            : null,
                        height: 48.h,
                        backgroundColor: _selectedLatLng != null
                            ? AppColors.primaryOfSeller
                            : AppColors.textDisabled,
                        textStyle: AppTextStyles.customStyle(
                          context,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.surface,
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  final ValueNotifier<bool> agreeToTerms;
  final AppLocalizations l10n;

  const _TermsCheckbox({required this.agreeToTerms, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: agreeToTerms,
      builder: (context, checked, _) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: GestureDetector(
            onTap: () => agreeToTerms.value = !checked,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: Checkbox(
                    value: checked,
                    onChanged: (v) => agreeToTerms.value = v ?? false,
                    activeColor: AppColors.primaryOfSeller,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    side: BorderSide(color: AppColors.divider, width: 1.5.w),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.create_store_terms_agree,
                  style: AppTextStyles.customStyle(
                    context,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}