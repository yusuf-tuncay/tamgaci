import 'package:flutter/material.dart';
import 'package:tamgaci/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:tamgaci/features/auth/presentation/pages/login_page.dart';
import 'package:tamgaci/features/auth/presentation/pages/register_page.dart';
import 'package:tamgaci/core/guards/subscription_guard.dart';
// Eski cash sayfaları kaldırıldı - cash_management kullanılıyor
import 'package:tamgaci/features/customers/presentation/pages/customer_create_page.dart';
import 'package:tamgaci/features/customers/presentation/pages/customer_edit_page.dart';
import 'package:tamgaci/features/customers/presentation/pages/enhanced_customers_list_page.dart';
import 'package:tamgaci/features/customers/presentation/pages/enhanced_customer_detail_page_v2.dart';
import 'package:tamgaci/features/suppliers/presentation/pages/enhanced_suppliers_list_page.dart';
import 'package:tamgaci/features/suppliers/presentation/pages/enhanced_supplier_detail_page.dart';
import 'package:tamgaci/features/warehouses/presentation/pages/warehouses_home_page.dart';
import 'package:tamgaci/features/warehouses/domain/entities/warehouse.dart';
import 'package:tamgaci/features/sales/presentation/pages/enhanced_sales_list_page.dart';
import 'package:tamgaci/features/sales/presentation/pages/sale_detail_page.dart';
import 'package:tamgaci/features/sales/presentation/pages/create_sale_page.dart';
import 'package:tamgaci/features/purchases/presentation/pages/enhanced_purchases_list_page.dart';
import 'package:tamgaci/features/purchases/presentation/pages/enhanced_purchase_detail_page.dart';
import 'package:tamgaci/features/purchases/presentation/pages/create_purchase_page.dart';
import 'package:tamgaci/features/cash_management/presentation/pages/enhanced_accounts_list_page.dart';
import 'package:tamgaci/features/cash_management/presentation/pages/enhanced_cash_transactions_list_page.dart';
import 'package:tamgaci/features/cash_management/presentation/pages/create_account_page.dart';
import 'package:tamgaci/features/cash_management/presentation/pages/enhanced_account_detail_page.dart';
import 'package:tamgaci/features/cash_management/presentation/pages/create_cash_transaction_page.dart';
import 'package:tamgaci/features/cash_management/presentation/pages/enhanced_cash_transaction_detail_page.dart';
// Yeni Accounts modülü
import 'package:tamgaci/features/accounts/domain/entities/account.dart';
import 'package:tamgaci/features/accounts/presentation/pages/accounts_home_page.dart';
import 'package:tamgaci/features/accounts/presentation/pages/create_account_page.dart'
    as accounts;
import 'package:tamgaci/features/accounts/presentation/pages/account_detail_page.dart';
// Silinen modül: enhanced_reports_list_page - ReportsOverviewPage kullanılıyor
import 'package:tamgaci/features/dashboard/presentation/pages/dashboard_page.dart';
// Silinen modül: expenses
// Silinen modül: income
import 'package:tamgaci/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:tamgaci/features/invoices/presentation/pages/invoices_list_page.dart';
import 'package:tamgaci/features/products/presentation/pages/create_product_page.dart';
import 'package:tamgaci/features/products/presentation/pages/product_variants_page.dart';
import 'package:tamgaci/features/products/presentation/pages/bulk_stock_update_page.dart';
// product_detail_page.dart kaldırıldı - enhanced_product_detail_page.dart kullanılıyor
// import 'package:tamgaci/features/products/presentation/pages/products_list_page.dart'; // Unused
import 'package:tamgaci/features/reports/presentation/pages/customer_report_page.dart';
import 'package:tamgaci/features/reports/presentation/pages/income_expense_report_page.dart';
import 'package:tamgaci/features/reports/presentation/pages/product_report_page.dart';
import 'package:tamgaci/features/reports/presentation/pages/reports_overview_page.dart';
import 'package:tamgaci/features/reports/presentation/pages/supplier_report_page.dart';
import 'package:tamgaci/features/settings/presentation/pages/company_settings_page.dart';
import 'package:tamgaci/features/settings/presentation/pages/permissions_page.dart';
import 'package:tamgaci/features/settings/presentation/pages/profile_page.dart';
import 'package:tamgaci/features/settings/presentation/pages/settings_page.dart';
import 'package:tamgaci/features/settings/presentation/pages/tax_settings_page.dart';
import 'package:tamgaci/features/subscription/presentation/pages/subscription_page.dart';
import 'package:tamgaci/features/subscription/presentation/pages/subscription_test_page.dart';
import 'package:tamgaci/features/splash/presentation/pages/splash_page.dart';
import 'package:tamgaci/features/suppliers/presentation/pages/create_supplier_page.dart';
// import 'package:tamgaci/features/suppliers/presentation/pages/supplier_detail_page.dart'; // Unused
// import 'package:tamgaci/features/suppliers/presentation/pages/suppliers_list_page.dart'; // Unused
import 'package:tamgaci/shared/pages/not_found_page.dart';
import 'package:tamgaci/shared/pages/under_construction_page.dart';
// import 'package:tamgaci/features/invoices/presentation/pages/invoice_detail_page.dart'; // Unused
// Silinen modül: income
// Silinen modül: notifications
import 'package:tamgaci/features/inventory/presentation/pages/inventory_page.dart';
// import 'package:tamgaci/features/inventory/presentation/pages/warehouse_list_page.dart'; // Unused
import 'package:tamgaci/features/warehouses/presentation/pages/create_warehouse_page.dart';
import 'package:tamgaci/features/warehouses/presentation/pages/warehouse_detail_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/stock_count_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/stock_counts_list_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/stock_list_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/create_stock_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/stock_detail_page.dart';
import 'package:tamgaci/core/services/colorized_logger_test_page.dart';

// Silinen modül: directory

import 'package:tamgaci/features/products/presentation/pages/products_home_page.dart';
import 'package:tamgaci/features/products/presentation/pages/product_detail_page.dart';
import 'package:tamgaci/features/landing/presentation/pages/landing_route.dart';

// Silinen modül: payments

/// Tamgaci Uygulaması Route Yönetim Sınıfı
/// Tüm sayfa route'larını merkezi olarak yönetir
class TamgaciRoutes {
  // ========== ROUTE NAMES (SABIT ROUTE İSİMLERİ) ==========

  // Ana Route'lar
  /// Splash ekranı route'u
  static const String splash = '/';

  /// Landing page route'u (Web için)
  static const String landing = '/landing';

  /// Ana dashboard route'u
  static const String dashboard = '/dashboard';

  /// Login sayfası route'u
  static const String login = '/login';

  /// Kayıt sayfası route'u
  static const String register = '/register';

  /// Şifre sıfırlama sayfası route'u
  static const String forgotPassword = '/forgot-password';

  /// Renkli logger test sayfası route'u
  static const String colorizedLoggerTest = '/colorized-logger-test';

  // Sales (Satış) Route'ları
  /// Satış listesi sayfası
  static const String salesList = '/sales';

  /// Yeni satış oluşturma sayfası
  static const String createSale = '/sales/create';

  /// Satış detay sayfası
  static const String saleDetail = '/sales/detail';

  /// Satış düzenleme sayfası
  static const String editSale = '/sales/edit';

  // Invoice (Fatura) Route'ları
  /// Fatura listesi sayfası
  static const String invoicesList = '/invoices';

  /// Yeni fatura oluşturma sayfası
  static const String createInvoice = '/invoices/create';

  /// Fatura detay sayfası
  static const String invoiceDetail = '/invoices/detail';

  /// Fatura düzenleme sayfası
  static const String editInvoice = '/invoice/edit';

  // Silinen modül: expenses

  // Silinen modül: income

  // Customer (Müşteri) Route'ları
  /// Müşteri listesi sayfası
  static const String customersList = '/customers';

  /// Yeni müşteri oluşturma sayfası
  static const String createCustomer = '/customers/create';

  /// Müşteri detay sayfası
  static const String customerDetail = '/customers/detail';

  /// Müşteri düzenleme sayfası
  static const String editCustomer = '/customer/edit';

  // Supplier (Tedarikçi) Route'ları
  /// Tedarikçi listesi sayfası
  static const String suppliersList = '/suppliers';

  /// Yeni tedarikçi oluşturma sayfası
  static const String createSupplier = '/suppliers/create';

  /// Tedarikçi detay sayfası
  static const String supplierDetail = '/suppliers/detail';

  /// Tedarikçi düzenleme sayfası
  static const String editSupplier = '/supplier/edit';

  // Purchase (Alış) Route'ları
  /// Alış listesi sayfası
  static const String purchasesList = '/purchases';

  /// Yeni alış oluşturma sayfası
  static const String createPurchase = '/purchases/create';

  /// Alış detay sayfası
  static const String purchaseDetail = '/purchases/detail';

  /// Alış düzenleme sayfası
  static const String editPurchase = '/purchase/edit';

  // Cash Management (Nakit Yönetimi) Route'ları - ESKİ
  /// Hesaplar listesi sayfası
  static const String accountsList = '/accounts';

  /// Yeni hesap oluşturma sayfası
  static const String createAccount = '/accounts/create';

  /// Hesap detay sayfası
  static const String accountDetail = '/accounts/detail';

  /// Hesap düzenleme sayfası
  static const String editAccount = '/account/edit';

  // Accounts (Hesaplar) Route'ları - YENİ
  /// Hesaplar ana sayfası
  static const String accountsHome = '/accounts/home';

  /// Yeni hesap oluşturma sayfası (Yeni)
  static const String createNewAccount = '/accounts/new';

  /// Hesap detay sayfası (Yeni)
  static const String newAccountDetail = '/accounts/detail-new';

  /// Nakit işlemleri listesi sayfası
  static const String cashTransactionsList = '/cash-transactions';

  /// Yeni nakit işlemi oluşturma sayfası
  static const String createCashTransaction = '/cash-transactions/create';

  /// Nakit işlemi detay sayfası
  static const String cashTransactionDetail = '/cash-transactions/detail';

  // Silinen modül: directory

  // Product (Ürün) Route'ları
  /// Ürün listesi sayfası
  static const String productsList = '/products';

  /// Yeni ürün oluşturma sayfası
  static const String createProduct = '/products/create';

  /// Ürün detay sayfası
  static const String productDetail = '/products/detail';

  /// Ürün düzenleme sayfası
  static const String editProduct = '/product/edit';

  /// Ürün varyantları sayfası
  static const String productVariants = '/products/variants';

  /// Toplu stok güncelleme
  static const String bulkStockUpdate = '/products/bulk-stock-update';

  // Cash (Kasa) Route'ları - Eski route'lar kaldırıldı, cash_management kullanılıyor

  // Reports (Rapor) Route'ları
  /// Raporlar ana sayfası
  static const String reportsOverview = '/reports';

  /// Raporlar listesi sayfası
  static const String reportsList = '/reports/list';

  /// Yeni rapor oluşturma sayfası
  static const String createReport = '/reports/create';

  /// Rapor detay sayfası
  static const String reportDetail = '/reports/detail';

  /// Rapor düzenleme sayfası
  static const String editReport = '/reports/edit';

  /// Gelir-Gider raporu sayfası
  static const String incomeExpenseReport = '/reports/income-expense';

  /// Müşteri raporu sayfası
  static const String customerReport = '/reports/customers';

  /// Tedarikçi raporu sayfası
  static const String supplierReport = '/reports/suppliers';

  /// Ürün raporu sayfası
  static const String productReport = '/reports/products';

  // Settings (Ayarlar) Route'ları
  /// Ayarlar ana sayfası
  static const String settings = '/settings';

  /// Profil sayfası
  static const String profile = '/settings/profile';

  /// Abonelik sayfası
  static const String subscription = '/settings/subscription';
  static const String subscriptionTest = '/subscription-test';

  /// PayTR callback sayfası

  /// İzinler sayfası
  static const String permissions = '/settings/permissions';

  /// Şirket ayarları sayfası
  static const String companySettings = '/settings/company';

  /// Vergi ayarları sayfası
  static const String taxSettings = '/settings/tax';

  // Inventory (Depo Stok) Route'ları
  /// Depo stok ana sayfası
  static const String inventory = '/inventory';

  /// Depo listesi sayfası
  static const String warehouseList = '/warehouse-list';

  /// Yeni depo oluşturma sayfası
  static const String createWarehouse = '/warehouse/create';

  /// Depo düzenleme sayfası
  static const String editWarehouse = '/warehouse/edit';

  /// Stok sayımları listesi
  static const String stockCountsList = '/stock-counts';

  /// Yeni stok sayımı
  static const String createStockCount = '/stock-count/create';

  /// Depo detay sayfası
  static const String warehouseDetail = '/warehouse/detail';

  // Stock (Stok) Route'ları
  /// Stok listesi sayfası
  static const String stockList = '/stock-list';

  /// Yeni stok oluşturma sayfası
  static const String createStock = '/stock/create';

  /// Stok düzenleme sayfası
  static const String editStock = '/stock/edit';

  /// Stok detay sayfası
  static const String stockDetail = '/stock/detail';

  // Silinen modül: notifications

  // Shared Route'lar
  /// 404 sayfa bulunamadı
  static const String notFound = '/not-found';

  /// Yapım aşamasında sayfası
  static const String underConstruction = '/under-construction';

  // ========== PAYMENTS (TAHSİLAT) ROUTE'LARI ==========

  // Silinen modül: payments

  // ========== ROUTE GENERATOR ==========

  /// Ana route generator fonksiyonu
  /// Navigator tarafından her route değişikliğinde çağrılır
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Route name ve arguments'ları al
    final routeName = settings.name ?? notFound;
    final arguments = settings.arguments;

    // Debug modda route log'u
    debugPrint('🚀 Navigating to: $routeName');
    if (arguments != null) {
      debugPrint('📦 Arguments: $arguments');
    }

    // Route'a göre sayfa döndür
    switch (routeName) {
      // ========== ANA ROUTE'LAR ==========

      case splash:
        return _createRoute(const SplashPage(), settings: settings);

      case landing:
        return _createRoute(const LandingRoute(), settings: settings);

      case dashboard:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: DashboardPage(),
          ),
          settings: settings,
        );

      case login:
        return _createRoute(const LoginPage(), settings: settings);

      case register:
        return _createRoute(const RegisterPage(), settings: settings);

      case forgotPassword:
        return _createRoute(const ForgotPasswordPage(), settings: settings);

      case colorizedLoggerTest:
        return _createRoute(const ColorizedLoggerTestPage(),
            settings: settings);
      // ========== AYARLAR/PROFIL ==========
      case TamgaciRoutes.profile:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProfilePage(),
          ),
          settings: settings,
        );

      case TamgaciRoutes.subscription:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SubscriptionPage(),
          ),
          settings: settings,
        );

      case TamgaciRoutes.subscriptionTest:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SubscriptionTestPage(),
          ),
          settings: settings,
        );


      // ========== SATIŞ ROUTE'LARI ==========

      case salesList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedSalesListPage(),
          ),
          settings: settings,
        );

      case createSale:
        {
          final args = settings.arguments;
          if (args is Map) {
            return _createRoute(
              const SubscriptionGuard(
                allowTrial: true,
                allowExpired: false,
                child: CreateSalePage(saleId: null),
              ),
              settings: settings,
            );
          }
          return _createRoute(
            const SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: CreateSalePage(),
            ),
            settings: settings,
          );
        }

      case saleDetail:
        // Sale ID parametresi bekleniyor
        final saleId =
            (arguments is String) ? arguments : arguments?.toString() ?? '';
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SaleDetailPage(saleId: saleId),
          ),
          settings: settings,
        );

      case editSale:
        // Sale ID parametresi bekleniyor
        final saleId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateSalePage(saleId: saleId),
          ),
          settings: settings,
        );

      // ========== FATURA ROUTE'LARI ==========

      case invoicesList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: InvoicesListPage(),
          ),
          settings: settings,
        );

      case createInvoice:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateInvoicePage(),
          ),
          settings: settings,
        );

      case invoiceDetail:
        // Sale ID parametresi bekleniyor
        final saleId =
            (arguments is String) ? arguments : arguments?.toString() ?? '';
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SaleDetailPage(saleId: saleId),
          ),
          settings: settings,
        );

      case editInvoice:
        // Invoice ID parametresi bekleniyor
        final invoiceId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateInvoicePage(invoiceId: invoiceId),
          ),
          settings: settings,
        );

      // ========== GİDER ROUTE'LARI ==========

      // Silinen modül: expenses

      // ========== GELİR ROUTE'LARI ==========

      // Silinen modül: income

      // ========== MÜŞTERİ ROUTE'LARI ==========

      case customersList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedCustomersListPage(),
          ),
          settings: settings,
        );

      case createCustomer:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CustomerCreatePage(),
          ),
          settings: settings,
        );

      case customerDetail:
        // Customer ID parametresi bekleniyor
        final customerId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedCustomerDetailPageV2(customerId: customerId ?? ''),
          ),
          settings: settings,
        );

      case editCustomer:
        // Customer ID parametresi bekleniyor
        final customerId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CustomerEditPage(customerId: customerId ?? ''),
          ),
          settings: settings,
        );

      // ========== TEDARİKÇİ ROUTE'LARI ==========

      case suppliersList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedSuppliersListPage(),
          ),
          settings: settings,
        );

      case createSupplier:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateSupplierPage(),
          ),
          settings: settings,
        );

      case supplierDetail:
        // Supplier ID parametresi bekleniyor
        final supplierId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedSupplierDetailPage(supplierId: supplierId ?? ''),
          ),
          settings: settings,
        );

      case editSupplier:
        // Supplier ID parametresi bekleniyor
        final supplierId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateSupplierPage(supplierId: supplierId),
          ),
          settings: settings,
        );

      // ========== ALIŞ ROUTE'LARI ==========

      case purchasesList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedPurchasesListPage(),
          ),
          settings: settings,
        );

      case createPurchase:
        final args = arguments as Map<String, dynamic>?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreatePurchasePage(
              purchaseId: args?['purchaseId'] as String?,
              supplierId: args?['supplierId'] as String?,
              supplierName: args?['supplierName'] as String?,
            ),
          ),
          settings: settings,
        );

      case purchaseDetail:
        // Purchase ID parametresi bekleniyor
        final purchaseId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedPurchaseDetailPage(purchaseId: purchaseId ?? ''),
          ),
          settings: settings,
        );

      case editPurchase:
        // Purchase ID parametresi bekleniyor
        final purchaseId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreatePurchasePage(purchaseId: purchaseId),
          ),
          settings: settings,
        );

      // ========== NAKİT YÖNETİMİ ROUTE'LARI (ESKİ) ==========

      case accountsList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedAccountsListPage(),
          ),
          settings: settings,
        );

      case createAccount:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateAccountPage(),
          ),
          settings: settings,
        );

      case accountDetail:
        // Account ID parametresi bekleniyor
        final accountId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedAccountDetailPage(accountId: accountId ?? ''),
          ),
          settings: settings,
        );

      case editAccount:
        // Account ID parametresi bekleniyor
        final accountId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateAccountPage(accountId: accountId),
          ),
          settings: settings,
        );

      // ========== HESAPLAR ROUTE'LARI (YENİ) ==========

      case accountsHome:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: AccountsHomePage(),
          ),
          settings: settings,
        );

      case createNewAccount:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: accounts.CreateAccountPage(),
          ),
          settings: settings,
        );

      case newAccountDetail:
        // Account objesi parametresi bekleniyor
        final account = arguments as Account?;
        if (account != null) {
          return _createRoute(
            SubscriptionGuard(
              allowTrial: true,
              allowExpired: false,
              child: AccountDetailPage(account: account),
            ),
            settings: settings,
          );
        }
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: AccountsHomePage(),
          ),
          settings: settings,
        );

      case cashTransactionsList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedCashTransactionsListPage(),
          ),
          settings: settings,
        );

      case createCashTransaction:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateCashTransactionPage(),
          ),
          settings: settings,
        );

      case cashTransactionDetail:
        // Transaction ID parametresi bekleniyor
        final transactionId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: EnhancedCashTransactionDetailPage(
                transactionId: transactionId ?? ''),
          ),
          settings: settings,
        );

      // ========== RAPORLAR ROUTE'LARI ==========

      case reportsList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ReportsOverviewPage(),
          ),
          settings: settings,
        );

      case createReport:
        // Geçici olarak reports overview'a yönlendir
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ReportsOverviewPage(),
          ),
          settings: settings,
        );

      case reportDetail:
        // Geçici olarak reports overview'a yönlendir
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ReportsOverviewPage(),
          ),
          settings: settings,
        );

      case editReport:
        // Geçici olarak reports overview'a yönlendir
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ReportsOverviewPage(),
          ),
          settings: settings,
        );

      // ========== ÜRÜN ROUTE'LARI ==========

      case productsList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProductsHomePage(),
          ),
          settings: settings,
        );

      case createProduct:
        final productId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateProductPage(productId: productId),
          ),
          settings: settings,
        );

      case productVariants:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProductVariantsPage(),
          ),
          settings: settings,
        );

      case bulkStockUpdate:
        final warehouseId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: BulkStockUpdatePage(warehouseId: warehouseId),
          ),
          settings: settings,
        );

      case productDetail:
        final productId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProductDetailPage(productId: productId ?? ''),
          ),
          settings: settings,
        );

      case editProduct:
        final productId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateProductPage(productId: productId),
          ),
          settings: settings,
        );

      // ========== KASA ROUTE'LARI ==========
      // Eski cash route'ları kaldırıldı - cash_management kullanılıyor

      // ========== RAPOR ROUTE'LARI ==========

      case reportsOverview:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ReportsOverviewPage(),
          ),
          settings: settings,
        );

      case incomeExpenseReport:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: IncomeExpenseReportPage(),
          ),
          settings: settings,
        );

      case customerReport:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CustomerReportPage(),
          ),
          settings: settings,
        );

      case supplierReport:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SupplierReportPage(),
          ),
          settings: settings,
        );

      case productReport:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: ProductReportPage(),
          ),
          settings: settings,
        );

      // ========== INVENTORY ROUTE'LARI ==========
      case inventory:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: InventoryPage(),
          ),
          settings: settings,
        );

      case warehouseList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: WarehousesHomePage(),
          ),
          settings: settings,
        );

      case createWarehouse:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateWarehousePage(),
          ),
          settings: settings,
        );

      case editWarehouse:
        final warehouse = arguments as Warehouse?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateWarehousePage(existingWarehouse: warehouse),
          ),
          settings: settings,
        );

      case stockCountsList:
        final warehouse = arguments as Warehouse?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: StockCountsListPage(warehouse: warehouse),
          ),
          settings: settings,
        );

      case createStockCount:
        final warehouse = arguments as Warehouse;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: StockCountPage(warehouse: warehouse),
          ),
          settings: settings,
        );

      case warehouseDetail:
        final warehouse = arguments as Warehouse?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: WarehouseDetailPage(warehouse: warehouse!),
          ),
          settings: settings,
        );

      case stockList:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: StockListPage(),
          ),
          settings: settings,
        );

      case createStock:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateStockPage(),
          ),
          settings: settings,
        );

      case editStock:
        final stockId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CreateStockPage(stockId: stockId),
          ),
          settings: settings,
        );

      case stockDetail:
        final stockId = arguments as String?;
        return _createRoute(
          SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: StockDetailPage(stockId: stockId ?? ''),
          ),
          settings: settings,
        );

      // ========== FİHRİST ROUTE'LARI ==========

      // Silinen modül: directory

      // ========== AYARLAR ROUTE'LARI ==========

      case TamgaciRoutes.settings:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: SettingsPage(),
          ),
          settings: settings,
        );

      case permissions:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: PermissionsPage(),
          ),
          settings: settings,
        );

      case companySettings:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: CompanySettingsPage(),
          ),
          settings: settings,
        );

      case taxSettings:
        return _createRoute(
          const SubscriptionGuard(
            allowTrial: true,
            allowExpired: false,
            child: TaxSettingsPage(),
          ),
          settings: settings,
        );

      // ========== BİLDİRİMLER ROUTE'LARI ==========

      // Silinen modül: notifications

      // ========== ENVANTER ROUTE'LARI ==========

      // Silinen modül: payments

      // ========== SHARED ROUTE'LAR ==========

      case underConstruction:
        return _createRoute(const UnderConstructionPage(), settings: settings);

      // ========== VARSAYILAN (404) ==========

      case notFound:
      default:
        debugPrint('❌ Route not found: $routeName');
        return _createRoute(
          const NotFoundPage(),
          settings: const RouteSettings(name: notFound),
        );
    }
  }

  // ========== ROUTE OLUŞTURUCU HELPER METODLAR ==========

  /// Standart sayfa geçişi ile route oluşturur
  static PageRoute<T> _createRoute<T>(
    Widget page, {
    required RouteSettings settings,
  }) {
    return MaterialPageRoute<T>(builder: (context) => page, settings: settings);
  }

  /// Fade geçişi ile route oluşturur
  // ignore: unused_element
  static PageRoute<T> _createFadeRoute<T>(
    Widget page, {
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, _) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Slide geçişi ile route oluşturur
  // ignore: unused_element
  static PageRoute<T> _createSlideRoute<T>(
    Widget page, {
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, _) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }

  // ========== NAVİGASYON HELPER METODLARI ==========

  /// Push navigation - Yeni sayfa ekler
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Push replacement - Mevcut sayfayı değiştirir
  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Push and remove until - Tüm geçmişi temizleyerek yeni sayfa
  static Future<T?> pushNamedAndClearAll<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop - Geri git
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Pop until - Belirli route'a kadar geri git
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  // ========== ROUTE GUARD METODLARI ==========

  /// Kullanıcı giriş durumunu kontrol eder
  static bool _isAuthenticated() {
    // TODO: Implement actual authentication check
    // SharedPreferences veya Secure Storage'dan token kontrolü
    return true;
  }

  /// Admin yetkisi kontrolü
  static bool _isAdmin() {
    // TODO: Implement admin check
    return true;
  }

  /// Route erişim izni kontrolü
  static bool canAccess(String routeName) {
    // Public route'lar - Giriş gerektirmez
    const publicRoutes = [splash, login, register, forgotPassword, notFound];

    if (publicRoutes.contains(routeName)) {
      return true;
    }

    // Admin route'ları
    const adminRoutes = [companySettings, taxSettings];

    if (adminRoutes.contains(routeName)) {
      return _isAuthenticated() && _isAdmin();
    }

    // Diğer tüm route'lar giriş gerektirir
    return _isAuthenticated();
  }

  // ========== ROUTE INFO METODLARI ==========

  /// Tüm route'ları listeler (debug için)
  static List<String> getAllRoutes() {
    return [
      splash,
      dashboard,
      login,
      register,
      forgotPassword,
      invoicesList,
      createInvoice,
      invoiceDetail,
      // Silinen modül: expenses
      // Silinen modül: income
      customersList,
      createCustomer,
      customerDetail,
      suppliersList,
      createSupplier,
      supplierDetail,
      productsList,
      createProduct,
      productDetail,
      // Eski cash route'ları kaldırıldı
      createCashTransaction,
      reportsOverview,
      incomeExpenseReport,
      customerReport,
      supplierReport,
      productReport,
      settings,
      profile,
      companySettings,
      taxSettings,
      notFound,
      underConstruction,
    ];
  }

  /// Route'un başlığını döndürür
  static String getRouteTitle(String routeName) {
    switch (routeName) {
      case dashboard:
        return 'Ana Sayfa';
      case invoicesList:
        return 'Faturalar';
      // Silinen modül: expenses
      // Silinen modül: income
      case customersList:
        return 'Müşteriler';
      case suppliersList:
        return 'Tedarikçiler';
      case productsList:
        return 'Ürünler';

      // Silinen modül: payments

      // Eski cash route'ları kaldırıldı
      case reportsOverview:
        return 'Raporlar';
      case settings:
        return 'Ayarlar';
      default:
        return 'Tamgaci';
    }
  }
}
