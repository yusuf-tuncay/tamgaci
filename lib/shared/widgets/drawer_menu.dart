// ========== ENHANCED DRAWER MENU ==========
// lib/shared/widgets/drawer_menu.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';
import '../../core/routes/routes.dart';
import '../../features/user_profile/presentation/providers/user_profile_providers.dart';
import '../../features/user_profile/domain/entities/user_profile.dart';
import 'theme_selector_dialog.dart';
import '../../core/providers/currency_providers.dart';

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
class DrawerMenuNotifier extends StateNotifier<Map<String, dynamic>> {
  /// Constructor
  DrawerMenuNotifier()
      : super({
          'activeRoute': TamgaciRoutes.dashboard,
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
  String get activeRoute => state['activeRoute'] ?? TamgaciRoutes.dashboard;

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
      route: TamgaciRoutes.dashboard,
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
          route: TamgaciRoutes.productsList,
        ),
        DrawerMenuItem(
          id: 'warehouses',
          title: 'Depolar',
          icon: Icons.warehouse_outlined,
          route: TamgaciRoutes.warehouseList,
        ),
        DrawerMenuItem(
          id: 'production',
          title: 'Üretim',
          icon: Icons.precision_manufacturing_outlined,
          route: TamgaciRoutes.inventory,
        ),
        DrawerMenuItem(
          id: 'price-lists',
          title: 'Özel Fiyat Listeleri',
          icon: Icons.price_check_outlined,
          route: TamgaciRoutes.productsList, // Geçici route
        ),
        DrawerMenuItem(
          id: 'product-variants',
          title: 'Ürün Varyantları',
          icon: Icons.style_outlined,
          route: TamgaciRoutes.productsList, // Geçici route
        ),
      ],
    ),

    // Satışlar
    const DrawerMenuItem(
      id: 'sales',
      title: 'Satışlar',
      icon: Icons.sell_outlined,
      route: TamgaciRoutes.invoicesList,
    ),

    // Alışlar
    const DrawerMenuItem(
      id: 'purchases',
      title: 'Alışlar',
      icon: Icons.shopping_cart_outlined,
      route: TamgaciRoutes.purchasesList,
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
          route: TamgaciRoutes.accountsList,
        ),
        DrawerMenuItem(
          id: 'employees',
          title: 'Personeller',
          icon: Icons.person_outline,
          route: TamgaciRoutes.incomeList, // Geçici route
        ),
        DrawerMenuItem(
          id: 'expenses',
          title: 'Masraflar',
          icon: Icons.money_off_outlined,
          route: TamgaciRoutes.expensesList,
        ),
        DrawerMenuItem(
          id: 'credits',
          title: 'Krediler',
          icon: Icons.credit_card_outlined,
          route: TamgaciRoutes.accountsList, // Geçici route
        ),
        DrawerMenuItem(
          id: 'projects',
          title: 'Projeler',
          icon: Icons.work_outline,
          route: TamgaciRoutes.accountsList, // Geçici route
        ),
        DrawerMenuItem(
          id: 'checks',
          title: 'Çekler',
          icon: Icons.receipt_long_outlined,
          route: TamgaciRoutes.accountsList, // Geçici route
        ),
        DrawerMenuItem(
          id: 'bills',
          title: 'Senetler',
          icon: Icons.description_outlined,
          route: TamgaciRoutes.accountsList, // Geçici route
        ),
      ],
    ),

    // Raporlar (Açılır Menü)
    const DrawerMenuItem(
      id: 'reports',
      title: 'Raporlar',
      icon: Icons.assessment_outlined,
      route: '', // Alt menü olduğu için boş
      subItems: [
        DrawerMenuItem(
          id: 'reports-list',
          title: 'Tüm Raporlar',
          icon: Icons.list_outlined,
          route: TamgaciRoutes.reportsList,
        ),
        DrawerMenuItem(
          id: 'sales-purchases-reports',
          title: 'Satışlar / Alışlar',
          icon: Icons.trending_up_outlined,
          route: TamgaciRoutes.invoicesList, // Geçici route
        ),
        DrawerMenuItem(
          id: 'financial-reports',
          title: 'Finansal Raporlar',
          icon: Icons.pie_chart,
          route: TamgaciRoutes.accountsList, // Geçici route
        ),
        DrawerMenuItem(
          id: 'stock-reports',
          title: 'Stok Raporları',
          icon: Icons.inventory_2_outlined,
          route: TamgaciRoutes.inventory,
        ),
        DrawerMenuItem(
          id: 'customer-reports',
          title: 'Müşteri Listesi',
          icon: Icons.people_outline,
          route: TamgaciRoutes.customersList,
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
    final userProfile = ref.watch(userProfileProvider);

    return Drawer(
      child: Column(
        children: [
          _buildHeader(userProfile),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItem(item, activeRoute);
              },
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(AsyncValue<UserProfile?> userProfile) {
    return Container(
      height: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo ve uygulama adı
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAMGACI',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Ön Muhasebe',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // USD/EUR kısa kur bilgisi (mavi alan içinde)
              Consumer(builder: (context, ref, child) {
                final converter = ref.watch(currencyConverterProvider);
                final selected = ref.watch(selectedCurrencyProvider);
                final code = selected.code;
                final usd = converter.convert(
                    amount: 1, fromCurrencyCode: 'USD', toCurrencyCode: code);
                final eur = converter.convert(
                    amount: 1, fromCurrencyCode: 'EUR', toCurrencyCode: code);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 USD = ${usd.toStringAsFixed(2)} $code',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '1 EUR = ${eur.toStringAsFixed(2)} $code',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 12),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 12),
              // Kullanıcı bilgileri
              userProfile.when(
                data: (profile) => _buildUserInfo(profile),
                loading: () =>
                    const CircularProgressIndicator(color: Colors.white),
                error: (error, stack) => Text(
                  'Kullanıcı bilgisi yüklenemedi',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserProfile? profile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kullanıcı',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'email@example.com',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(DrawerMenuItem item, String activeRoute) {
    final isActive = item.route == activeRoute;
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded =
        ref.watch(drawerMenuProvider)['expandedItems']?.contains(item.id) ??
            false;

    return Column(
      children: [
        ListTile(
          leading: Icon(
            item.icon,
            color: isActive ? AppColors.primary : Colors.grey[600],
            size: 24,
          ),
          title: Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.primary : Colors.grey[800],
            ),
          ),
          trailing: hasSubItems
              ? Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[600],
                )
              : item.badgeCount != null && item.badgeCount! > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.badgeCount.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
          selected: isActive,
          selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
          onTap: () {
            if (hasSubItems) {
              ref.read(drawerMenuProvider.notifier).toggleExpanded(item.id);
            } else if (item.route.isNotEmpty) {
              ref.read(drawerMenuProvider.notifier).setActiveRoute(item.route);
              Navigator.pushNamed(context, item.route);
            }
          },
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
          color: isActive ? AppColors.primary : Colors.grey[500],
          size: 20,
        ),
        title: Text(
          subItem.title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : Colors.grey[700],
          ),
        ),
        trailing: subItem.badgeCount != null && subItem.badgeCount! > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  subItem.badgeCount.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        selected: isActive,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        onTap: () {
          if (subItem.route.isNotEmpty) {
            ref.read(drawerMenuProvider.notifier).setActiveRoute(subItem.route);
            Navigator.pushNamed(context, subItem.route);
          }
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        children: [
          // Ayarlar kısayolu
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(
              'Ayarlar',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            onTap: () {
              Navigator.pushNamed(context, TamgaciRoutes.settings);
            },
          ),
          // Güncel kur bilgisi
          Consumer(builder: (context, ref, child) {
            final selected = ref.watch(selectedCurrencyProvider);
            final converter = ref.watch(currencyConverterProvider);
            final code = selected.code;
            final rate = converter.convert(
              amount: 1,
              fromCurrencyCode: 'USD',
              toCurrencyCode: code,
            );
            return ListTile(
              leading: const Icon(Icons.show_chart),
              title: Text(
                'Güncel Kur',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              subtitle: Text(
                '1 USD = ${rate.toStringAsFixed(2)} $code',
                style:
                    GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
            );
          }),
          // Tema seçici
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(
              'Tema',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ThemeSelectorDialog(),
              );
            },
          ),
          // Para birimi seçici
          Consumer(
            builder: (context, ref, child) {
              final selectedCurrency = ref.watch(selectedCurrencyProvider);
              return ListTile(
                leading: const Icon(Icons.currency_exchange_outlined),
                title: Text(
                  'Para Birimi',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                subtitle: Text(
                  selectedCurrency.code,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[600]),
                ),
                onTap: () {
                  _showCurrencySelector(ref);
                },
              );
            },
          ),
          const Divider(),
          // Çıkış yap
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.red),
            title: Text(
              'Çıkış Yap',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showCurrencySelector(WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Para Birimi Seç',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Consumer(
          builder: (context, ref, child) {
            final currencies = ref.watch(exchangeRatesProvider);
            final selectedCurrency = ref.watch(selectedCurrencyProvider);

            return currencies.when(
              data: (currencyList) => SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currencyList.length,
                  itemBuilder: (context, index) {
                    final currency = currencyList[index];
                    final isSelected = selectedCurrency.code == currency.code;

                    return ListTile(
                      leading: Text(
                        currency.symbol,
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(currency.name),
                      subtitle: Text(currency.code),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref
                            .read(selectedCurrencyProvider.notifier)
                            .selectCurrency(currency);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Hata: $error'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Çıkış Yap',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Uygulamadan çıkmak istediğinizden emin misiniz?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Çıkış işlemi burada yapılacak
              // ref.read(authProvider.notifier).logout();
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
