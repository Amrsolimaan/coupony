import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupony/config/dependency_injection/injection_container.dart'
    as di;
import 'package:coupony/config/routes/app_router.dart';
import 'package:coupony/core/constants/api_constants.dart';
import 'package:coupony/core/localization/l10n/app_localizations.dart';
import 'package:coupony/core/theme/app_colors.dart';
import 'package:coupony/core/theme/app_text_styles.dart';
import 'package:coupony/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:coupony/features/auth/data/models/user_store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class StoreSelectionPage extends StatefulWidget {
  final List<UserStoreModel> stores;
  const StoreSelectionPage({super.key, this.stores = const []});

  @override
  State<StoreSelectionPage> createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends State<StoreSelectionPage>
    with TickerProviderStateMixin {
  static const _navy = AppColors.primaryOfSeller;

  List<UserStoreModel> _stores     = [];
  String?              _selectingId;
  bool                 _isLoading  = true;

  late AnimationController _headerCtrl;
  late AnimationController _listCtrl;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;
  List<Animation<double>>  _cardFades  = [];
  List<Animation<Offset>>  _cardSlides = [];

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerFade = CurvedAnimation(
      parent: _headerCtrl,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut),
    );

    _headerCtrl.forward();
    _loadStores();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    List<UserStoreModel> result;

    if (widget.stores.isNotEmpty) {
      result = widget.stores;
    } else {
      final ds  = di.sl<AuthLocalDataSource>();
      final all = await ds.getCachedStores();
      result    = all.where((s) => s.isActive).toList();
    }

    if (!mounted) return;

    _cardFades = List.generate(result.length, (i) {
      final start = (i * 0.12).clamp(0.0, 0.7);
      final end   = (start + 0.55).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _listCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _cardSlides = List.generate(result.length, (i) {
      final start = (i * 0.12).clamp(0.0, 0.7);
      final end   = (start + 0.55).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end:   Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _listCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    setState(() {
      _stores    = result;
      _isLoading = false;
    });

    _listCtrl.forward();
  }

  Future<void> _selectStore(UserStoreModel store) async {
    if (_selectingId != null) return;
    setState(() => _selectingId = store.id);
    try {
      await di.sl<AuthLocalDataSource>().saveSelectedStoreId(store.id);
      if (mounted) context.go(AppRouter.home);
    } catch (_) {
      if (mounted) setState(() => _selectingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          // ── Navy Header ────────────────────────────────────────────────
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: _NavyHeader(l10n: l10n),
            ),
          ),

          // ── Cards List ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _navy),
                  )
                : _stores.isEmpty
                    ? _EmptyState(l10n: l10n)
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                        itemCount: _stores.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, i) {
                          final store = _stores[i];
                          return FadeTransition(
                            opacity: _cardFades[i],
                            child: SlideTransition(
                              position: _cardSlides[i],
                              child: _StoreCard(
                                store:       store,
                                isSelecting: _selectingId == store.id,
                                isDisabled:  _selectingId != null &&
                                             _selectingId != store.id,
                                onTap:       () => _selectStore(store),
                                l10n:        l10n,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Navy Header ────────────────────────────────────────────────────────────────

class _NavyHeader extends StatelessWidget {
  const _NavyHeader({required this.l10n});
  final AppLocalizations l10n;

  static const _navy = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _navy,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 36.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon box
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 22.w,
                ),
              ),
              SizedBox(height: 18.h),

              Text(
                l10n.select_store,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6.h),

              Text(
                l10n.select_store_subtitle,
                style: AppTextStyles.customStyle(
                  context,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.60),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Store Card ─────────────────────────────────────────────────────────────────

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.store,
    required this.isSelecting,
    required this.isDisabled,
    required this.onTap,
    required this.l10n,
  });

  final UserStoreModel   store;
  final bool             isSelecting;
  final bool             isDisabled;
  final VoidCallback     onTap;
  final AppLocalizations l10n;

  static const _navy = AppColors.primaryOfSeller;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isDisabled ? 0.40 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(18.r),
          splashColor: const Color(0xFF215194).withValues(alpha: 0.06),
          highlightColor: const Color(0xFF215194).withValues(alpha: 0.03),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isSelecting ? _navy : const Color(0xFFE8EDF5),
                width: isSelecting ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF215194)
                      .withValues(alpha: isSelecting ? 0.12 : 0.05),
                  blurRadius: isSelecting ? 20 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Accent bar — يظهر فقط وقت الـ selecting
                if (isSelecting) ...[
                  Container(
                    width: 3.5.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],

                // Logo
                _StoreLogo(logoUrl: store.logoUrl, name: store.name),
                SizedBox(width: 14.w),

                // Name + badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name.isEmpty ? '—' : store.name,
                        style: AppTextStyles.customStyle(
                          context,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A2540),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                      _ActiveBadge(label: l10n.select_store_active_badge),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Trailing
                if (isSelecting)
                  SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _navy,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.w,
                    color: const Color(0xFFC5CEDE),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Store Logo ─────────────────────────────────────────────────────────────────

class _StoreLogo extends StatelessWidget {
  const _StoreLogo({required this.logoUrl, required this.name});
  final String? logoUrl;
  final String  name;

  static const _navy = AppColors.primaryOfSeller;

  /// بناء URL كامل للصورة
  String? _buildFullImageUrl(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) {
      print('🖼️ _StoreLogo: logoUrl is null or empty');
      return null;
    }
    
    print('🖼️ _StoreLogo: Original logoUrl = $logoUrl');
    
    // إذا كان URL كامل (يبدأ بـ http أو https)، استخدمه مباشرة
    if (logoUrl.startsWith('http://') || logoUrl.startsWith('https://')) {
      print('🖼️ _StoreLogo: Using full URL directly');
      return logoUrl;
    }
    
    // إذا كان مسار نسبي، أضف base URL
    // إزالة /api/v1 من base URL لأن الصور في المسار الرئيسي
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
    
    // إضافة /storage/ إذا لم يكن موجوداً في المسار
    String cleanPath = logoUrl;
    if (!cleanPath.startsWith('/storage/') && !cleanPath.startsWith('storage/')) {
      cleanPath = '/storage/$cleanPath';
    } else if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }
    
    final fullUrl = '$baseUrl$cleanPath';
    print('🖼️ _StoreLogo: Built full URL = $fullUrl');
    return fullUrl;
  }

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = _buildFullImageUrl(logoUrl);
    final hasLogo = fullImageUrl != null;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    print('🖼️ _StoreLogo.build: hasLogo=$hasLogo, fullImageUrl=$fullImageUrl, name=$name');

    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F9),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFDCE4F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? CachedNetworkImage(
              imageUrl: fullImageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                print('❌ _StoreLogo: Failed to load image: $url, error: $error');
                return _Initial(letter: initial);
              },
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: _navy,
                ),
              ),
            )
          : _Initial(letter: initial),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.letter});
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        letter,
        style: AppTextStyles.customStyle(
          context,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryOfSeller,
        ),
      ),
    );
  }
}

// ── Active Badge ───────────────────────────────────────────────────────────────

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEDFBF3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.w,
            height: 5.w,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF15803D),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 60.w,
            color: const Color(0xFFC5CEDE),
          ),
          SizedBox(height: 14.h),
          Text(
            l10n.select_store,
            style: AppTextStyles.customStyle(
              context,
              fontSize: 15,
              color: const Color(0xFF8A96B0),
            ),
          ),
        ],
      ),
    );
  }
}