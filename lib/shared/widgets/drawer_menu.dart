// ========== ENHANCED DRAWER MENU ==========
// lib/shared/widgets/drawer_menu.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/theme/constants.dart';
import 'package:go_router/go_router.dart';
// Silinen modül: user_profile
import '../../core/providers/currency_providers.dart';
import '../../core/providers/company_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/domain/entities/user.dart' as auth_domain;
import '../overlays/calculator_overlay.dart';

import '../../core/services/firebase/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/cache/data_cache.dart';

// ========== DRAWER MENU MODELS ==========

/// Drawer menü öğesi modeli
class DrawerMenuItem {
  /// Menü öğesinin benzersiz ID'si
  final String id;

  /// Menü öğesinin başlığı
  final String title;

  /// Menü öğesinin ikonu
  final IconData icon;

  /// Menü öğesinin route'u (alt menü varsa null olabilir)
  final String route;

  /// Alt menü öğeleri (varsa)
  final List<DrawerMenuItem>? subItems;

  /// Menü öğesinin badge sayısı (bildirim için)
  final int? badgeCount;

  /// Menü öğesinin aktif olup olmadığı
  final bool isActive;

  /// Menü öğesinin görünür olup olmadığı
  final bool isVisible;

  /// Admin yetkisi gerekip gerekmediği
  final bool requiresAdmin;

  /// Yakında gelecek özellik olup olmadığı
  final bool comingSoon;

  const DrawerMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.subItems,
    this.badgeCount,
    this.isActive = true,
    this.isVisible = true,
    this.requiresAdmin = false,
    this.comingSoon = false,
  });

  /// DrawerMenuItem kopyalama metodu
  DrawerMenuItem copyWith({
    String? id,
    String? title,
    IconData? icon,
    String? route,
    List<DrawerMenuItem>? subItems,
    int? badgeCount,
    bool? isActive,
    bool? isVisible,
    bool? requiresAdmin,
    bool? comingSoon,
  }) {
    return DrawerMenuItem(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      subItems: subItems ?? this.subItems,
      badgeCount: badgeCount ?? this.badgeCount,
      isActive: isActive ?? this.isActive,
      isVisible: isVisible ?? this.isVisible,
      requiresAdmin: requiresAdmin ?? this.requiresAdmin,
      comingSoon: comingSoon ?? this.comingSoon,
    );
  }
}

class _SvgWhiteLogoFallback extends StatelessWidget {
  const _SvgWhiteLogoFallback({this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logos/140x140logo.png',
      fit: BoxFit.contain,
      color: color ?? Colors.white,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}

// ========== DRAWER STATE MANAGEMENT ==========

/// Drawer menü durumunu yöneten StateNotifier
class DrawerMenuNotifier extends StateNotifier<Map<String, dynamic>> {
  /// Constructor
  DrawerMenuNotifier()
      : super({
          'activeRoute': 'dashboard',
          'expandedItems': <String>{},
        });

  /// Aktif route'u günceller
  void setActiveRoute(String route) {
    state = {
      ...state,
      'activeRoute': route,
    };
  }

  /// Alt menüyü aç/kapat
  void toggleExpanded(String itemId) {
    final expandedItems = Set<String>.from(state['expandedItems'] ?? {});
    if (expandedItems.contains(itemId)) {
      expandedItems.remove(itemId);
    } else {
      expandedItems.add(itemId);
    }
    state = {
      ...state,
      'expandedItems': expandedItems,
    };
  }

  /// Aktif route'u döndürür
  String get activeRoute => state['activeRoute'] ?? 'dashboard';

  /// Alt menünün açık olup olmadığını kontrol eder
  bool isExpanded(String itemId) {
    final expandedItems = state['expandedItems'] ?? <String>{};
    return expandedItems.contains(itemId);
  }
}

// ========== PROVIDERS ==========

/// Drawer menu state provider'ı
final drawerMenuProvider =
    StateNotifierProvider<DrawerMenuNotifier, Map<String, dynamic>>(
  (ref) => DrawerMenuNotifier(),
);

/// Drawer menü öğeleri provider'ı
final drawerMenuItemsProvider = Provider<List<DrawerMenuItem>>((ref) {
  return [
    // Dashboard (Ana Sayfa)
    const DrawerMenuItem(
      id: 'dashboard',
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: 'dashboard',
    ),

    // Müşteriler
    const DrawerMenuItem(
      id: 'customers',
      title: 'Müşteriler',
      icon: Icons.people_outlined,
      route: 'customers-list',
    ),

    // Tedarikçiler
    const DrawerMenuItem(
      id: 'suppliers',
      title: 'Tedarikçiler',
      icon: Icons.local_shipping_outlined,
      route: 'suppliers-list',
    ),

    // Ürünler (Açılır Menü)
    const DrawerMenuItem(
      id: 'products',
      title: 'Ürünler',
      icon: Icons.inventory_2_outlined,
      route: '', // Alt menü olduğu için boş
      subItems: [
        DrawerMenuItem(
          id: 'products-list',
          title: 'Ürün / Hizmetler',
          icon: Icons.inventory_outlined,
          route: 'products-list',
        ),
        DrawerMenuItem(
          id: 'warehouses',
          title: 'Depolar',
          icon: Icons.warehouse_outlined,
          route: 'warehouses-home',
        ),
        DrawerMenuItem(
          id: 'stock-counts',
          title: 'Stok Sayımları',
          icon: Icons.fact_check_outlined,
          route: 'stock-counts-list',
          isActive: true,
        ),
      ],
    ),

    // Satışlar
    const DrawerMenuItem(
      id: 'sales',
      title: 'Satışlar',
      icon: Icons.sell_outlined,
      route: 'sales-list',
    ),

    // Alışlar
    const DrawerMenuItem(
      id: 'purchases',
      title: 'Alışlar',
      icon: Icons.shopping_cart_outlined,
      route: 'purchases-list',
    ),

    // Nakit Yönetimi (Açılır Menü)
    const DrawerMenuItem(
      id: 'cash-management',
      title: 'Nakit Yönetimi',
      icon: Icons.account_balance_wallet_outlined,
      route: '', // Alt menü olduğu için boş
      subItems: [
        DrawerMenuItem(
          id: 'accounts',
          title: 'Hesaplarım',
          icon: Icons.account_balance_outlined,
          route: 'accounts-list',
        ),
        DrawerMenuItem(
  id: 'employees',
  title: 'Personeller',
  icon: Icons.person_outline,
  route: 'employees-list',
  isActive: true,
),
        DrawerMenuItem(
          id: 'expenses',
          title: 'Masraflar',
          icon: Icons.money_off_outlined,
          route: 'expenses',
          isActive: true,
        ),
        DrawerMenuItem(
          id: 'credits',
          title: 'Krediler',
          icon: Icons.credit_card_outlined,
          route: '',
          isActive: false,
        ),
        DrawerMenuItem(
          id: 'projects',
          title: 'Projeler',
          icon: Icons.work_outline,
          route: '',
          isActive: false,
        ),
        DrawerMenuItem(
          id: 'checks',
          title: 'Çekler',
          icon: Icons.receipt_long_outlined,
          route: '',
          isActive: false,
        ),
        DrawerMenuItem(
          id: 'bills',
          title: 'Senetler',
          icon: Icons.description_outlined,
          route: '',
          isActive: false,
        ),
      ],
    ),

    // Raporlar (tek öğe)
    const DrawerMenuItem(
      id: 'reports',
      title: 'Raporlar',
      icon: Icons.assessment_outlined,
      route: 'reports-overview',
    ),

    // Entegrasyonlar (Açılır Menü)
    const DrawerMenuItem(
      id: 'integrations',
      title: 'Entegrasyonlar',
      icon: Icons.integration_instructions_outlined,
      route: '', // Alt menü olduğu için boş
      subItems: [
        DrawerMenuItem(
          id: 'e-invoice',
          title: 'E-Fatura',
          icon: Icons.receipt_long_outlined,
          route: '',
          isActive: false,
          comingSoon: true,
        ),
        DrawerMenuItem(
          id: 'e-commerce',
          title: 'E-Ticaret',
          icon: Icons.shopping_cart_outlined,
          route: '',
          isActive: false,
          comingSoon: true,
        ),
        DrawerMenuItem(
          id: 'banking',
          title: 'Banka',
          icon: Icons.account_balance_outlined,
          route: '',
          isActive: false,
          comingSoon: true,
        ),
        DrawerMenuItem(
          id: 'tools',
          title: 'Araçlar',
          icon: Icons.directions_car_outlined,
          route: '',
          isActive: false,
          comingSoon: true,
        ),
      ],
    ),

    // Eklentiler (Açılır Menü)
    const DrawerMenuItem(
      id: 'plugins',
      title: 'Eklentiler',
      icon: Icons.extension_outlined,
      route: '', // Alt menü olduğu için boş
      subItems: [
        DrawerMenuItem(
          id: 'production',
          title: 'Üretim',
          icon: Icons.precision_manufacturing_outlined,
          route: '',
          isActive: false,
          comingSoon: true,
        ),
        DrawerMenuItem(
          id: 'planning',
          title: 'Planlama',
          icon: Icons.schedule_outlined,
          route: '',
          isActive: false,
          comingSoon: true,
        ),
        DrawerMenuItem(
          id: 'sectoral',
          title: 'Sektörel',
          icon: Icons.business_outlined,
          route: '',
          isActive: false,
          comingSoon: true,
        ),
      ],
    ),
  ];
});

// ========== DRAWER MENU WIDGET ==========

/// Drawer menü widget'ı
class TamgaciDrawerMenu extends ConsumerStatefulWidget {
  const TamgaciDrawerMenu({super.key});

  @override
  ConsumerState<TamgaciDrawerMenu> createState() => _TamgaciDrawerMenuState();
}

class _TamgaciDrawerMenuState extends ConsumerState<TamgaciDrawerMenu> {
  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(drawerMenuItemsProvider);
    final drawerState = ref.watch(drawerMenuProvider);
    final activeRoute = drawerState['activeRoute'] as String;
    // Silinen modül: user_profile
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280, // Drawer genişliğini sınırla
      decoration: BoxDecoration(
        color: isDark
            ? TamgaciConstants.backgroundColorDark
            : TamgaciConstants.surfaceColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(null), // Silinen modül: user_profile
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? TamgaciConstants.backgroundColorDark
                    : TamgaciConstants.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: _buildMenuItem(item, activeRoute),
                  );
                },
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic userProfile) {
    // Silinen modül: user_profile
    final currentUser = ref.watch(currentUserProvider);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TamgaciConstants.primaryColor,
            Color(0xFF4C6EF5),
            TamgaciConstants.primaryColorDark,
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Logo ve şirket adı
              Row(
                children: [
                  // circular logo for consistency (open calculator on tap)
                  GestureDetector(
                      onTap: _showCalculator,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: _SvgWhiteLogoFallback(color: Colors.white),
                        ),
                      )),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tamgacı',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: TamgaciConstants.textOnPrimary,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ön Muhasebe Uygulaması',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: TamgaciConstants.textOnPrimary
                                .withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // removed calculator button - open via logo
                ],
              ),
              const SizedBox(height: 12),
              // Premium USD/EUR kur bilgisi
              Consumer(builder: (context, ref, _) {
                final rates = ref.watch(usdEurRatesProvider);
                final double usdRate = rates['USD']?.exchangeRate ?? 0.0;
                final double eurRate = rates['EUR']?.exchangeRate ?? 0.0;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        TamgaciConstants.textOnPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          TamgaciConstants.textOnPrimary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCurrencyItem('USD', usdRate),
                      Container(
                        width: 1,
                        height: 16,
                        color: TamgaciConstants.textOnPrimary
                            .withValues(alpha: 0.3),
                      ),
                      _buildCurrencyItem('EUR', eurRate),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              // Kullanıcı bilgileri
              _buildCompactUserInfo(currentUser.value),
            ],
          ),
        ),
      ),
    );
  }

  // _buildWhiteLogo removed (not used)

  Widget _buildCurrencyItem(String currency, double rate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              currency,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: TamgaciConstants.textOnPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${rate.toStringAsFixed(2)} ₺',
          style: GoogleFonts.poppins(
            color: TamgaciConstants.textOnPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionChip() {
    final container = ProviderScope.containerOf(context, listen: false);
    final userAsync = container.read(currentUserProvider);
    final user = userAsync.value;
    if (user == null) {
      return const SizedBox.shrink();
    }
    final now = DateTime.now();
    String text = '';
    Color color = Colors.grey;

    if (user.subscriptionStatus == auth_domain.SubscriptionStatus.trial &&
        user.trialEndAt != null) {
      final remaining = user.trialEndAt!.difference(now).inDays;
      if (remaining > 0) {
        text = 'Deneme ${remaining}g';
        color = Colors.orange;
      }
    } else if (user.subscriptionStatus ==
            auth_domain.SubscriptionStatus.active &&
        user.subscriptionEndAt != null) {
      final remaining = user.subscriptionEndAt!.difference(now).inDays;
      if (remaining > 0) {
        text = '${remaining}g';
        color = Colors.green;
      }
    }

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 9,
          color: TamgaciConstants.textOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool _isSubscriptionExpired(auth_domain.User? user) {
    if (user == null) return false;
    final now = DateTime.now();
    if (user.subscriptionStatus == auth_domain.SubscriptionStatus.trial) {
      final end = user.trialEndAt;
      if (end == null) return false;
      return now.isAfter(end);
    }
    if (user.subscriptionStatus == auth_domain.SubscriptionStatus.active) {
      final end = user.subscriptionEndAt;
      if (end == null) return false;
      return now.isAfter(end);
    }
    return false;
  }

  Widget _buildUserAvatar(auth_domain.User? user) {
    final imageProvider = _getAvatarImageProvider(user);
    final hasValidImage = imageProvider != null;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
        backgroundImage: hasValidImage ? imageProvider : null,
        child: !hasValidImage
            ? Text(
                _getInitials(user?.name, user?.surname),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TamgaciConstants.textOnPrimary,
                ),
              )
            : null,
      ),
    );
  }

  ImageProvider<Object>? _getAvatarImageProvider(auth_domain.User? user) {
    // Priority 1: User entity's profile image URL
    final userProfileUrl = user?.profileImageUrl;
    if (userProfileUrl != null && userProfileUrl.isNotEmpty) {
      // Validate URL has token before using
      if (!userProfileUrl.contains('token=')) {
        debugPrint('⚠️ Invalid user profile URL (no token): $userProfileUrl');
        return null;
      }
      String workingUrl = _fixImageUrl(userProfileUrl);
      debugPrint('✅ Loading avatar from User entity: $workingUrl');
      return NetworkImage(workingUrl);
    }

    // Priority 2: Check UserProfile entity
    // Silinen modül: user_profile
    const userProfile = null;
    final profilePhotoUrl = userProfile?.profilePhotoUrl;
    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      // Validate URL has token before using
      if (!profilePhotoUrl.contains('token=')) {
        debugPrint('⚠️ Invalid profile photo URL (no token): $profilePhotoUrl');
        return null;
      }
      String workingUrl = _fixImageUrl(profilePhotoUrl);
      debugPrint('✅ Loading avatar from UserProfile entity: $workingUrl');
      return NetworkImage(workingUrl);
    }

    // Priority 3: Check user settings for backup URL
    final settingsUrl = user?.settings?['profileImageUrl'] as String?;
    if (settingsUrl != null && settingsUrl.isNotEmpty) {
      // Validate URL has token before using
      if (!settingsUrl.contains('token=')) {
        debugPrint('⚠️ Invalid settings URL (no token): $settingsUrl');
        return null;
      }
      String workingUrl = _fixImageUrl(settingsUrl);
      debugPrint('✅ Loading avatar from settings: $workingUrl');
      return NetworkImage(workingUrl);
    }

    // Priority 3.5: If no URL but we have a user, try to resolve by fixed path
    if (user?.id.isNotEmpty == true) {
      final fixedPath = 'users/${user!.id}/profile/profile_${user.id}.jpg';
      debugPrint('🔎 Trying fixed storage path for avatar: $fixedPath');
      _refreshImageUrlFromPath(fixedPath);
    }

    // Priority 4: Path available but no URL - try to load fresh URL in background
    final imagePath = user?.profileImagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      debugPrint('📷 Profile image path available: $imagePath');
      _refreshImageUrlFromPath(imagePath);
      return null; // Show initials while loading
    }

    debugPrint('🚫 No profile image found, showing initials');
    return null;
  }

  /// Fix common Firebase Storage URL issues
  String _fixImageUrl(String url) {
    String workingUrl = url;

    // Fix old bucket URLs to new format
    if (url.contains('tamgaci.appspot.com')) {
      workingUrl =
          url.replaceAll('tamgaci.appspot.com', 'tamgaci.firebasestorage.app');
      debugPrint('🔧 Fixed image URL format: $workingUrl');
    }

    // Add token if missing for authenticated requests
    if (!workingUrl.contains('token=') && !workingUrl.contains('alt=media')) {
      final separator = workingUrl.contains('?') ? '&' : '?';
      workingUrl += '${separator}alt=media';
    }

    // Don't add cache busting for Firebase Storage URLs with tokens
    // This prevents 404 errors when file doesn't exist
    if (!workingUrl.contains('token=')) {
      final separator = workingUrl.contains('?') ? '&' : '?';
      workingUrl += '${separator}_t=${DateTime.now().millisecondsSinceEpoch}';
    }

    debugPrint('🔧 Final image URL: $workingUrl');
    return workingUrl;
  }

  /// Refresh image URL from storage path in background
  Future<void> _refreshImageUrlFromPath(String imagePath) async {
    try {
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child(imagePath);
      final freshUrl = await storageRef.getDownloadURL();

      debugPrint('🔄 Refreshed URL from path: $freshUrl');

      // Update both User and UserProfile entities with fresh URL
      final currentUserAsync = ref.read(currentUserProvider);
      final currentUser = currentUserAsync.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          profileImageUrl: freshUrl,
          updatedAt: DateTime.now(),
        );
        // Fire and forget - don't block UI
        ref
            .read(authProvider.notifier)
            .updateUserProfile(updatedUser)
            .catchError((e) {
          debugPrint('⚠️ Background user update failed: $e');
        });
      }

      // Also refresh UserProfile provider in background
      // Silinen modül: user_profile
      Future.value().catchError((e) {
        debugPrint('⚠️ Background profile refresh failed: $e');
      });
    } catch (e) {
      debugPrint('❌ Failed to refresh image URL from path: $e');
    }
  }

  /// Get user display name with fallback
  String _getUserDisplayName(auth_domain.User? user) {
    if (user == null) return 'Kullanıcı';

    final name = user.name.trim();
    final surname = user.surname.trim();

    if (name.isNotEmpty && surname.isNotEmpty) {
      return '$name $surname';
    } else if (name.isNotEmpty) {
      return name;
    } else if (surname.isNotEmpty) {
      return surname;
    }

    // Fallback to UserProfile if User entity is incomplete
    // Silinen modül: user_profile
    const userProfile = null;
    if (userProfile != null) {
      return userProfile.fullName;
    }

    return 'Kullanıcı';
  }

  /// Get company name with fallback
  String _getCompanyName(auth_domain.User? user, WidgetRef ref) {
    // Try to get from company provider first
    final companyName = ref.watch(companyNameProvider);
    if (companyName != 'Tamgaci') {
      return companyName;
    }

    // Try from User entity settings
    String? company = user?.settings?['companyName'] as String?;

    if (company == null || company.isEmpty) {
      company = user?.settings?['businessName'] as String?;
    }

    // Fallback to UserProfile
    if (company == null || company.isEmpty) {
      // Silinen modül: user_profile
      const userProfile = null;
      company = userProfile?.company;
    }

    return company?.isNotEmpty == true ? company! : 'Tamgaci';
  }

  String _getInitials(String? name, String? surname) {
    final n = (name ?? '').trim();
    final s = (surname ?? '').trim();

    // If both name and surname are empty, try to get from UserProfile
    if (n.isEmpty && s.isEmpty) {
      // Silinen modül: user_profile
      const userProfile = null;
      if (userProfile != null) {
        final profileName = userProfile.name.trim();
        final profileSurname = userProfile.surname.trim();
        if (profileName.isNotEmpty || profileSurname.isNotEmpty) {
          final first =
              profileName.isNotEmpty ? profileName.characters.first : '';
          final second =
              profileSurname.isNotEmpty ? profileSurname.characters.first : '';
          final result = (first + second).toUpperCase();
          return result.isEmpty ? 'KU' : result;
        }
      }
    }

    final first = n.isNotEmpty ? n.characters.first : '';
    final second = s.isNotEmpty ? s.characters.first : '';
    final result = (first + second).toUpperCase();
    return result.isEmpty ? 'KU' : result;
  }

  Widget _buildCompactUserInfo(auth_domain.User? user) {
    return InkWell(
      onTap: () {
        // Drawer kapat ve profil sayfasına git
        if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
        }
        ref.read(drawerMenuProvider.notifier).setActiveRoute('profile');
        context.goNamed('profile');
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildUserAvatar(user),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getUserDisplayName(user),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TamgaciConstants.textOnPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getCompanyName(user, ref),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: TamgaciConstants.textOnPrimary
                                .withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildSubscriptionChip(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_outlined,
              size: 16,
              color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(DrawerMenuItem item, String activeRoute) {
    final isActive = item.route == activeRoute;
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded =
        ref.watch(drawerMenuProvider)['expandedItems']?.contains(item.id) ??
            false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                    ? TamgaciConstants.primaryColor.withValues(alpha: 0.15)
                    : TamgaciConstants.primaryColor.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: TamgaciConstants.primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color:
                          TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? TamgaciConstants.primaryColor.withValues(alpha: 0.2)
                    : (isDark
                        ? TamgaciConstants.textSecondaryDark
                            .withValues(alpha: 0.1)
                        : TamgaciConstants.textSecondary
                            .withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                color: isActive
                    ? TamgaciConstants.primaryColor
                    : (isDark
                        ? TamgaciConstants.textSecondaryDark
                        : TamgaciConstants.textSecondary),
                size: 20,
              ),
            ),
            title: Text(
              item.title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: !item.isActive
                    ? Colors.grey
                    : (isActive
                        ? TamgaciConstants.primaryColor
                        : (isDark
                            ? TamgaciConstants.textPrimaryDark
                            : TamgaciConstants.textPrimary)),
              ),
            ),
            trailing: hasSubItems
                ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? TamgaciConstants.textSecondaryDark
                              .withValues(alpha: 0.1)
                          : TamgaciConstants.textSecondary
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: isDark
                          ? TamgaciConstants.textSecondaryDark
                          : TamgaciConstants.textSecondary,
                      size: 16,
                    ),
                  )
                : item.badgeCount != null && item.badgeCount! > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: TamgaciConstants.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: TamgaciConstants.primaryColor
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item.badgeCount.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: TamgaciConstants.textOnPrimary,
                          ),
                        ),
                      )
                    : null,
            onTap: () {
              if (!item.isActive) return;
              if (hasSubItems) {
                ref.read(drawerMenuProvider.notifier).toggleExpanded(item.id);
              } else if (item.route.isNotEmpty) {
                // Subscription guard: if expired, redirect to subscription page
                final container =
                    ProviderScope.containerOf(context, listen: false);
                final userAsync = container.read(currentUserProvider);
                final user = userAsync.value;
                if (_isSubscriptionExpired(user)) {
                  ref
                      .read(drawerMenuProvider.notifier)
                      .setActiveRoute('subscription');
                  if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                    Navigator.of(context).pop();
                  }
                  context.goNamed('subscription');
                  return;
                }
                ref
                    .read(drawerMenuProvider.notifier)
                    .setActiveRoute(item.route);
                if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop();
                }
                // Go Router ile navigation
                if (item.route == 'expenses') {
                  context.go('/expenses');
                } else {
                  context.goNamed(item.route);
                }
              }
            },
          ),
        ),
        // Alt menü öğeleri
        if (hasSubItems && isExpanded)
          ...item.subItems!
              .map((subItem) => _buildSubMenuItem(subItem, activeRoute)),
      ],
    );
  }

  Widget _buildSubMenuItem(DrawerMenuItem subItem, String activeRoute) {
    final isActive = subItem.route == activeRoute;

    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: ListTile(
        leading: Icon(
          subItem.icon,
          color: subItem.isActive
              ? (isActive
                  ? TamgaciConstants.primaryColor
                  : (Theme.of(context).brightness == Brightness.dark
                      ? TamgaciConstants.textPrimaryDark
                      : TamgaciConstants.textSecondary))
              : (Theme.of(context).brightness == Brightness.dark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary),
          size: 20,
        ),
        title: Text(
          subItem.title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: subItem.isActive
                ? (isActive ? FontWeight.w600 : FontWeight.w500)
                : FontWeight.w400,
            color: subItem.isActive
                ? (isActive
                    ? TamgaciConstants.primaryColor
                    : (Theme.of(context).brightness == Brightness.dark
                        ? TamgaciConstants.textPrimaryDark
                        : TamgaciConstants.textSecondary))
                : (Theme.of(context).brightness == Brightness.dark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary),
          ),
        ),
        trailing: subItem.badgeCount != null && subItem.badgeCount! > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: TamgaciConstants.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  subItem.badgeCount.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: TamgaciConstants.textOnPrimary,
                  ),
                ),
              )
            : subItem.comingSoon
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Yakında',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  )
                : null,
        selected: isActive,
        selectedTileColor: Theme.of(context).brightness == Brightness.dark
            ? TamgaciConstants.primaryColor.withValues(alpha: 0.15)
            : TamgaciConstants.primaryColor.withValues(alpha: 0.1),
        hoverColor: Theme.of(context).brightness == Brightness.dark
            ? TamgaciConstants.primaryColor.withValues(alpha: 0.08)
            : TamgaciConstants.primaryColor.withValues(alpha: 0.05),
        onTap: () {
          if (!subItem.isActive) return;
          if (subItem.route.isNotEmpty) {
            ref.read(drawerMenuProvider.notifier).setActiveRoute(subItem.route);
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
            // Go Router ile navigation
            context.goNamed(subItem.route);
          }
        },
      ),
    );
  }

  Widget _buildFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.backgroundColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? TamgaciConstants.borderColor.withValues(alpha: 0.1)
              : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ayarlar kısayolu - Premium tasarım
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? TamgaciConstants.primaryColor.withValues(alpha: 0.1)
                  : TamgaciConstants.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? TamgaciConstants.primaryColor.withValues(alpha: 0.2)
                    : TamgaciConstants.primaryColor.withValues(alpha: 0.1),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: TamgaciConstants.primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                'Ayarlar',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? TamgaciConstants.textPrimaryDark
                      : TamgaciConstants.textPrimary,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
              onTap: () {
                if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop();
                }
                context.goNamed('settings');
              },
            ),
          ),
          // Çıkış yap - Premium tasarım
          Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.1),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: Text(
                'Çıkış Yap',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.red.withValues(alpha: 0.6),
              ),
              onTap: () {
                _showLogoutDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCalculator() {
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    // Toggle floating overlay (navigations persist)
    CalculatorOverlay.instance.toggle(context);
  }

  void _showLogoutDialog() {
    bool forgetMe = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Çıkış Yap',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uygulamadan çıkmak istediğinizden emin misiniz?',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: forgetMe,
                      onChanged: (v) {
                        setDialogState(() => forgetMe = v ?? false);
                      },
                    ),
                    Text(
                      'Beni unut',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Beni unut seçiliyse flag'i güncelle
                if (forgetMe) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('remember_me', false);
                  // Remove stored credentials and clear caches
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'cred_email');
                  await storage.delete(key: 'cred_password');
                  try {
                    await DataCache().clearAllDataCache();
                  } catch (_) {}
                }
              } catch (_) {}
              try {
                await FirebaseAuthService.signOut();
              } catch (_) {}
              if (mounted) {
                context.goNamed('login');
              }
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
