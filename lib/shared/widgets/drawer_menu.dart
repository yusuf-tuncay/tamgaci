import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../core/theme/constants.dart';
import '../../core/routes/routes.dart';
import '../../core/providers/theme_provider.dart';
import '../../features/user_profile/presentation/providers/user_profile_providers.dart';
import '../../features/user_profile/domain/entities/user_profile.dart';
import 'theme_selector_dialog.dart';

// ========== DRAWER MENU MODELS ==========

/// Drawer menü öğesi modeli
class DrawerMenuItem {
  /// Menü öğesinin benzersiz ID'si
  final String id;

  /// Menü öğesinin başlığı
  final String title;

  /// Menü öğesinin ikonu
  final IconData icon;

  /// Menü öğesinin route'u
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
    );
  }
}

// ========== DRAWER STATE MANAGEMENT ==========

/// Drawer menü durumunu yöneten StateNotifier
class DrawerMenuNotifier extends StateNotifier<String> {
  /// Constructor - Başlangıç route'u
  DrawerMenuNotifier() : super(TamgaciRoutes.dashboard);

  /// Aktif route'u günceller
  void setActiveRoute(String route) {
    state = route;
  }

  /// Aktif route'u döndürür
  String get activeRoute => state;
}

// ========== PROVIDERS ==========

/// Drawer menu state provider'ı
final drawerMenuProvider = StateNotifierProvider<DrawerMenuNotifier, String>(
  (ref) => DrawerMenuNotifier(),
);

/// Drawer menü öğeleri provider'ı
final drawerMenuItemsProvider = Provider<List<DrawerMenuItem>>((ref) {
  return [
    // Ana Sayfa
    const DrawerMenuItem(
      id: 'dashboard',
      title: 'Ana Sayfa',
      icon: Icons.dashboard_outlined,
      route: TamgaciRoutes.dashboard,
    ),

    // Faturalar
    const DrawerMenuItem(
      id: 'invoices',
      title: 'Faturalar',
      icon: Icons.receipt_long_outlined,
      route: TamgaciRoutes.invoicesList,
    ),

    // Giderler
    const DrawerMenuItem(
      id: 'expenses',
      title: 'Giderler',
      icon: Icons.money_off_outlined,
      route: TamgaciRoutes.expensesList,
    ),

    // Gelirler
    const DrawerMenuItem(
      id: 'income',
      title: 'Gelirler',
      icon: Icons.attach_money_outlined,
      route: TamgaciRoutes.incomeList,
    ),

    // Müşteriler
    const DrawerMenuItem(
      id: 'customers',
      title: 'Müşteriler',
      icon: Icons.people_outlined,
      route: TamgaciRoutes.customersList,
    ),

    // Tedarikçiler
    const DrawerMenuItem(
      id: 'suppliers',
      title: 'Tedarikçiler',
      icon: Icons.local_shipping_outlined,
      route: TamgaciRoutes.suppliersList,
    ),

    // Fihrist
    const DrawerMenuItem(
      id: 'directory',
      title: 'Fihrist',
      icon: Icons.contacts_outlined,
      route: TamgaciRoutes.contactsList,
    ),

    // Ürünler
    const DrawerMenuItem(
      id: 'products',
      title: 'Ürünler',
      icon: Icons.inventory_2_outlined,
      route: TamgaciRoutes.productsList,
    ),

    // Kasa
    const DrawerMenuItem(
      id: 'cash',
      title: 'Kasa',
      icon: Icons.account_balance_wallet_outlined,
      route: TamgaciRoutes.cashOverview,
    ),

    // Depo Stok
    const DrawerMenuItem(
      id: 'inventory',
      title: 'Depo Stok',
      icon: Icons.warehouse_outlined,
      route: TamgaciRoutes.inventory,
    ),

    // Raporlar
    const DrawerMenuItem(
      id: 'reports',
      title: 'Raporlar',
      icon: Icons.analytics_outlined,
      route: TamgaciRoutes.reportsOverview,
    ),

    // Ayarlar
    const DrawerMenuItem(
      id: 'settings',
      title: 'Ayarlar',
      icon: Icons.settings_outlined,
      route: TamgaciRoutes.settings,
    ),
  ];
});

// ========== DRAWER MENU WIDGET ==========

/// Tamgaci Drawer Menü Widget'ı
class TamgaciDrawerMenu extends ConsumerStatefulWidget {
  /// Drawer genişliği
  final double? width;

  /// Header yüksekliği
  final double? headerHeight;

  /// Menü öğelerini özelleştirme
  final List<DrawerMenuItem>? customMenuItems;

  const TamgaciDrawerMenu({
    super.key,
    this.width,
    this.headerHeight,
    this.customMenuItems,
  });

  @override
  ConsumerState<TamgaciDrawerMenu> createState() => _TamgaciDrawerMenuState();
}

class _TamgaciDrawerMenuState extends ConsumerState<TamgaciDrawerMenu> {
  @override
  Widget build(BuildContext context) {
    final activeRoute = ref.watch(drawerMenuProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final menuItems = ref.watch(drawerMenuItemsProvider);

    return Drawer(
      width: widget.width ?? TamgaciConstants.sidebarWidth(context),
      backgroundColor: TamgaciConstants.backgroundColor,
      child: Column(
        children: [
          // Drawer Header
          userProfileAsync.when(
            data: (userProfile) => _buildDrawerHeader(userProfile),
            loading: () => _buildDrawerHeaderLoading(),
            error: (_, __) => _buildDrawerHeaderError(),
          ),

          // Menü Öğeleri
          Expanded(child: _buildMenuItems(menuItems, activeRoute)),

          // Drawer Footer
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  /// Drawer header'ını oluşturur
  Widget _buildDrawerHeader(UserProfile userProfile) {
    return Container(
      height: widget.headerHeight ??
          TamgaciConstants.getResponsiveValue(
            context,
            mobile: 250.0,
            tablet: 260.0,
            desktop: 270.0,
            wideDesktop: 280.0,
          ),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TamgaciConstants.primaryColor, TamgaciConstants.primaryDark],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: TamgaciConstants.paddingMedium(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kullanıcı Avatar'ı
              _buildUserAvatar(userProfile),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Kullanıcı Bilgileri
              _buildUserInfo(userProfile),
            ],
          ),
        ),
      ),
    );
  }

  /// Drawer header loading
  Widget _buildDrawerHeaderLoading() {
    return Container(
      height: widget.headerHeight ??
          TamgaciConstants.getResponsiveValue(
            context,
            mobile: 250.0,
            tablet: 260.0,
            desktop: 270.0,
            wideDesktop: 280.0,
          ),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TamgaciConstants.primaryColor, TamgaciConstants.primaryDark],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  /// Drawer header error
  Widget _buildDrawerHeaderError() {
    return Container(
      height: widget.headerHeight ??
          TamgaciConstants.getResponsiveValue(
            context,
            mobile: 250.0,
            tablet: 260.0,
            desktop: 270.0,
            wideDesktop: 280.0,
          ),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TamgaciConstants.primaryColor, TamgaciConstants.primaryDark],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: TamgaciConstants.paddingMedium(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kullanıcı Avatar'ı
              _buildUserAvatar(null),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Kullanıcı Bilgileri
              _buildUserInfoError(),
            ],
          ),
        ),
      ),
    );
  }

  /// Kullanıcı avatar'ını oluşturur
  Widget _buildUserAvatar(UserProfile? userProfile) {
    return Container(
      width: TamgaciConstants.getResponsiveValue(
        context,
        mobile: 70.0,
        tablet: 80.0,
        desktop: 90.0,
        wideDesktop: 100.0,
      ),
      height: TamgaciConstants.getResponsiveValue(
        context,
        mobile: 70.0,
        tablet: 80.0,
        desktop: 90.0,
        wideDesktop: 100.0,
      ),
      decoration: BoxDecoration(
        color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: userProfile?.profilePhotoUrl != null
          ? ClipOval(
              child: Image.file(
                File(userProfile!.profilePhotoUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: TamgaciConstants.getResponsiveValue(
                    context,
                    mobile: 35.0,
                    tablet: 40.0,
                    desktop: 45.0,
                    wideDesktop: 50.0,
                  ),
                  color: TamgaciConstants.textOnPrimary,
                ),
              ),
            )
          : Icon(
              Icons.person,
              size: TamgaciConstants.getResponsiveValue(
                context,
                mobile: 35.0,
                tablet: 40.0,
                desktop: 45.0,
                wideDesktop: 50.0,
              ),
              color: TamgaciConstants.textOnPrimary,
            ),
    );
  }

  /// Kullanıcı bilgilerini oluşturur
  Widget _buildUserInfo(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kullanıcı Adı
        Text(
          userProfile.fullName,
          style: GoogleFonts.poppins(
            fontSize: TamgaciConstants.getResponsiveValue(
              context,
              mobile: 18.0,
              tablet: 20.0,
              desktop: 22.0,
              wideDesktop: 24.0,
            ),
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textOnPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceXS),
        // Kullanıcı E-posta
        Text(
          userProfile.email,
          style: GoogleFonts.poppins(
            fontSize: TamgaciConstants.getResponsiveValue(
              context,
              mobile: 12.0,
              tablet: 13.0,
              desktop: 14.0,
              wideDesktop: 15.0,
            ),
            fontWeight: FontWeight.w400,
            color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceXS),
        // Kullanıcı Rolü
        Text(
          userProfile.role,
          style: GoogleFonts.poppins(
            fontSize: TamgaciConstants.getResponsiveValue(
              context,
              mobile: 11.0,
              tablet: 12.0,
              desktop: 13.0,
              wideDesktop: 14.0,
            ),
            fontWeight: FontWeight.w500,
            color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// Kullanıcı bilgileri error
  Widget _buildUserInfoError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kullanıcı',
          style: GoogleFonts.poppins(
            fontSize: TamgaciConstants.getResponsiveValue(
              context,
              mobile: 18.0,
              tablet: 20.0,
              desktop: 22.0,
              wideDesktop: 24.0,
            ),
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textOnPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceXS),
        Text(
          'kullanici@tamgaci.com',
          style: GoogleFonts.poppins(
            fontSize: TamgaciConstants.getResponsiveValue(
              context,
              mobile: 12.0,
              tablet: 13.0,
              desktop: 14.0,
              wideDesktop: 15.0,
            ),
            fontWeight: FontWeight.w400,
            color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceXS),
        Text(
          'Kullanıcı',
          style: GoogleFonts.poppins(
            fontSize: TamgaciConstants.getResponsiveValue(
              context,
              mobile: 11.0,
              tablet: 12.0,
              desktop: 13.0,
              wideDesktop: 14.0,
            ),
            fontWeight: FontWeight.w500,
            color: TamgaciConstants.textOnPrimary.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// Menü öğelerini oluşturur
  Widget _buildMenuItems(List<DrawerMenuItem> menuItems, String activeRoute) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isActive = item.route == activeRoute;

        return ListTile(
          leading: Icon(
            item.icon,
            color: isActive
                ? TamgaciConstants.primaryColor
                : TamgaciConstants.textSecondary,
          ),
          title: Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? TamgaciConstants.primaryColor
                  : TamgaciConstants.textPrimary,
            ),
          ),
          trailing: item.badgeCount != null && item.badgeCount! > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: TamgaciConstants.errorColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.badgeCount.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
          selected: isActive,
          selectedTileColor: TamgaciConstants.primaryColor.withValues(
            alpha: 0.1,
          ),
          onTap: () {
            ref.read(drawerMenuProvider.notifier).setActiveRoute(item.route);
            Navigator.pushNamed(context, item.route);
          },
        );
      },
    );
  }

  /// Drawer footer'ını oluşturur
  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: TamgaciConstants.cardColor,
        border: Border(
          top: BorderSide(color: TamgaciConstants.borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Profil düzenleme butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, TamgaciRoutes.profile);
              },
              icon: const Icon(Icons.person_outline, size: 18),
              label: Text(
                'Profili Düzenle',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: BorderSide(
                  color: TamgaciConstants.primaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: TamgaciConstants.spaceSM),
          // Tema değiştirme butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showThemeSelector(context, ref);
              },
              icon: Consumer(
                builder: (context, ref, child) {
                  final themeMode = ref.watch(themeProvider);
                  final themeNotifier = ref.read(themeProvider.notifier);
                  return Icon(themeNotifier.getThemeIcon(), size: 18);
                },
              ),
              label: Consumer(
                builder: (context, ref, child) {
                  final themeMode = ref.watch(themeProvider);
                  final themeNotifier = ref.read(themeProvider.notifier);
                  return Text(
                    'Tema: ${themeNotifier.getThemeName()}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: BorderSide(
                  color: TamgaciConstants.primaryColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: TamgaciConstants.spaceSM),
          // Çıkış butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Çıkış işlemi
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  TamgaciRoutes.splash,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_outlined, size: 18),
              label: Text(
                'Çıkış Yap',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                foregroundColor: TamgaciConstants.errorColor,
                side: BorderSide(
                  color: TamgaciConstants.errorColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tema seçici dialog'unu gösterir
  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSelectorDialog(),
    );
  }
}
