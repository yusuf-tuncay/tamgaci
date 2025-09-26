import 'package:flutter/material.dart';
import 'package:tamgaci/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:tamgaci/features/auth/presentation/pages/login_page.dart';
import 'package:tamgaci/features/auth/presentation/pages/register_page.dart';
// Eski cash sayfaları kaldırıldı - cash_management kullanılıyor
import 'package:tamgaci/features/customers/presentation/pages/customer_create_page.dart';
import 'package:tamgaci/features/customers/presentation/pages/customer_edit_page.dart';
import 'package:tamgaci/features/customers/presentation/pages/enhanced_customers_list_page.dart';
import 'package:tamgaci/features/customers/presentation/pages/enhanced_customer_detail_page_v2.dart';
import 'package:tamgaci/features/suppliers/presentation/pages/enhanced_suppliers_list_page.dart';
import 'package:tamgaci/features/suppliers/presentation/pages/enhanced_supplier_detail_page.dart';
import 'package:tamgaci/features/products/presentation/pages/warehouses_list_page.dart';
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
import 'package:tamgaci/features/reports/presentation/pages/enhanced_reports_list_page.dart';
import 'package:tamgaci/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:tamgaci/features/expenses/presentation/pages/create_expense_page.dart';
import 'package:tamgaci/features/expenses/presentation/pages/expense_detail_page.dart';
import 'package:tamgaci/features/expenses/presentation/pages/expenses_list_page.dart';
import 'package:tamgaci/features/income/presentation/pages/create_income_page.dart';
import 'package:tamgaci/features/income/presentation/pages/income_list_page.dart';
import 'package:tamgaci/features/invoices/presentation/pages/create_invoice_page.dart';
import 'package:tamgaci/features/invoices/presentation/pages/invoices_list_page.dart';
import 'package:tamgaci/features/products/presentation/pages/create_product_page.dart';
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
import 'package:tamgaci/features/settings/presentation/pages/subscription_page.dart';
import 'package:tamgaci/features/splash/presentation/pages/splash_page.dart';
import 'package:tamgaci/features/suppliers/presentation/pages/create_supplier_page.dart';
// import 'package:tamgaci/features/suppliers/presentation/pages/supplier_detail_page.dart'; // Unused
// import 'package:tamgaci/features/suppliers/presentation/pages/suppliers_list_page.dart'; // Unused
import 'package:tamgaci/shared/pages/not_found_page.dart';
import 'package:tamgaci/shared/pages/under_construction_page.dart';
// import 'package:tamgaci/features/invoices/presentation/pages/invoice_detail_page.dart'; // Unused
import 'package:tamgaci/features/income/presentation/pages/income_detail_page.dart';
import 'package:tamgaci/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/inventory_page.dart';
// import 'package:tamgaci/features/inventory/presentation/pages/warehouse_list_page.dart'; // Unused
import 'package:tamgaci/features/inventory/presentation/pages/create_warehouse_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/warehouse_detail_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/stock_list_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/create_stock_page.dart';
import 'package:tamgaci/features/inventory/presentation/pages/stock_detail_page.dart';

import 'package:tamgaci/features/directory/presentation/pages/contacts_list_page.dart';
import 'package:tamgaci/features/directory/presentation/pages/create_contact_page.dart';
import 'package:tamgaci/features/directory/presentation/pages/contact_detail_page.dart';
import 'package:tamgaci/features/directory/presentation/pages/edit_contact_page.dart';
import 'package:tamgaci/features/directory/domain/entities/contact.dart';

import 'package:tamgaci/features/products/presentation/pages/products_list_page.dart';
import 'package:tamgaci/features/products/presentation/pages/product_detail_page.dart';

/// Tamgaci Uygulaması Route Yönetim Sınıfı
/// Tüm sayfa route'larını merkezi olarak yönetir
class TamgaciRoutes {
  // ========== ROUTE NAMES (SABIT ROUTE İSİMLERİ) ==========

  // Ana Route'lar
  /// Splash ekranı route'u
  static const String splash = '/';

  /// Ana dashboard route'u
  static const String dashboard = '/dashboard';

  /// Login sayfası route'u
  static const String login = '/login';

  /// Kayıt sayfası route'u
  static const String register = '/register';

  /// Şifre sıfırlama sayfası route'u
  static const String forgotPassword = '/forgot-password';

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

  // Expense (Gider) Route'ları
  /// Gider listesi sayfası
  static const String expensesList = '/expenses';

  /// Yeni gider oluşturma sayfası
  static const String createExpense = '/expenses/create';

  /// Gider detay sayfası
  static const String expenseDetail = '/expenses/detail';

  /// Gider düzenleme sayfası
  static const String editExpense = '/expense/edit';

  // Income (Gelir) Route'ları
  /// Gelir listesi sayfası
  static const String incomeList = '/income';

  /// Yeni gelir oluşturma sayfası
  static const String createIncome = '/income/create';

  /// Gelir detay sayfası
  static const String incomeDetail = '/income/detail';

  /// Gelir düzenleme sayfası
  static const String editIncome = '/income/edit';

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

  // Cash Management (Nakit Yönetimi) Route'ları
  /// Hesaplar listesi sayfası
  static const String accountsList = '/accounts';

  /// Yeni hesap oluşturma sayfası
  static const String createAccount = '/accounts/create';

  /// Hesap detay sayfası
  static const String accountDetail = '/accounts/detail';

  /// Hesap düzenleme sayfası
  static const String editAccount = '/account/edit';

  /// Nakit işlemleri listesi sayfası
  static const String cashTransactionsList = '/cash-transactions';

  /// Yeni nakit işlemi oluşturma sayfası
  static const String createCashTransaction = '/cash-transactions/create';

  /// Nakit işlemi detay sayfası
  static const String cashTransactionDetail = '/cash-transactions/detail';

  // Directory (Fihrist) Route'ları
  /// Fihrist listesi sayfası
  static const String contactsList = '/directory';

  /// Yeni kişi/kurum oluşturma sayfası
  static const String createContact = '/directory/create';

  /// Kişi/kurum detay sayfası
  static const String contactDetail = '/directory/detail';

  /// Kişi/kurum düzenleme sayfası
  static const String editContact = '/directory/edit';

  // Product (Ürün) Route'ları
  /// Ürün listesi sayfası
  static const String productsList = '/products';

  /// Yeni ürün oluşturma sayfası
  static const String createProduct = '/products/create';

  /// Ürün detay sayfası
  static const String productDetail = '/products/detail';

  /// Ürün düzenleme sayfası
  static const String editProduct = '/product/edit';

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

  // Notifications (Bildirimler) Route'ları
  /// Bildirimler sayfası
  static const String notifications = '/notifications';

  // Shared Route'lar
  /// 404 sayfa bulunamadı
  static const String notFound = '/not-found';

  /// Yapım aşamasında sayfası
  static const String underConstruction = '/under-construction';

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

      case dashboard:
        return _createRoute(const DashboardPage(), settings: settings);

      case login:
        return _createRoute(const LoginPage(), settings: settings);

      case register:
        return _createRoute(const RegisterPage(), settings: settings);

      case forgotPassword:
        return _createRoute(const ForgotPasswordPage(), settings: settings);
      // ========== AYARLAR/PROFIL ==========
      case TamgaciRoutes.profile:
        return _createRoute(const ProfilePage(), settings: settings);

      case TamgaciRoutes.subscription:
        return _createRoute(const SubscriptionPage(), settings: settings);

      // ========== SATIŞ ROUTE'LARI ==========

      case salesList:
        return _createRoute(const EnhancedSalesListPage(), settings: settings);

      case createSale:
        {
          final args = settings.arguments;
          if (args is Map) {
            return _createRoute(
              const CreateSalePage(
                saleId: null,
              ),
              settings: settings,
            );
          }
          return _createRoute(const CreateSalePage(), settings: settings);
        }

      case saleDetail:
        // Sale ID parametresi bekleniyor
        final saleId =
            (arguments is String) ? arguments : arguments?.toString() ?? '';
        return _createRoute(
          SaleDetailPage(saleId: saleId),
          settings: settings,
        );

      case editSale:
        // Sale ID parametresi bekleniyor
        final saleId = arguments as String?;
        return _createRoute(
          CreateSalePage(saleId: saleId),
          settings: settings,
        );

      // ========== FATURA ROUTE'LARI ==========

      case invoicesList:
        return _createRoute(const InvoicesListPage(), settings: settings);

      case createInvoice:
        return _createRoute(const CreateInvoicePage(), settings: settings);

      case invoiceDetail:
        // Sale ID parametresi bekleniyor
        final saleId =
            (arguments is String) ? arguments : arguments?.toString() ?? '';
        return _createRoute(
          SaleDetailPage(saleId: saleId),
          settings: settings,
        );

      case editInvoice:
        // Invoice ID parametresi bekleniyor
        final invoiceId = arguments as String?;
        return _createRoute(
          CreateInvoicePage(invoiceId: invoiceId),
          settings: settings,
        );

      // ========== GİDER ROUTE'LARI ==========

      case expensesList:
        return _createRoute(const ExpensesListPage(), settings: settings);

      case createExpense:
        return _createRoute(const CreateExpensePage(), settings: settings);

      case expenseDetail:
        // Expense ID parametresi bekleniyor
        final expenseId = arguments as String?;
        return _createRoute(
          ExpenseDetailPage(expenseId: expenseId ?? ''),
          settings: settings,
        );

      case editExpense:
        // Expense ID parametresi bekleniyor
        final expenseId = arguments as String?;
        return _createRoute(
          CreateExpensePage(expenseId: expenseId),
          settings: settings,
        );

      // ========== GELİR ROUTE'LARI ==========

      case incomeList:
        return _createRoute(const IncomeListPage(), settings: settings);

      case createIncome:
        return _createRoute(const CreateIncomePage(), settings: settings);

      case incomeDetail:
        // Income ID parametresi bekleniyor
        final incomeId = arguments as String?;
        return _createRoute(
          IncomeDetailPage(incomeId: incomeId ?? ''),
          settings: settings,
        );

      case editIncome:
        // Income ID parametresi bekleniyor
        final incomeId = arguments as String?;
        return _createRoute(
          CreateIncomePage(incomeId: incomeId),
          settings: settings,
        );

      // ========== MÜŞTERİ ROUTE'LARI ==========

      case customersList:
        return _createRoute(const EnhancedCustomersListPage(),
            settings: settings);

      case createCustomer:
        return _createRoute(const CustomerCreatePage(), settings: settings);

      case customerDetail:
        // Customer ID parametresi bekleniyor
        final customerId = arguments as String?;
        return _createRoute(
          EnhancedCustomerDetailPageV2(customerId: customerId ?? ''),
          settings: settings,
        );

      case editCustomer:
        // Customer ID parametresi bekleniyor
        final customerId = arguments as String?;
        return _createRoute(
          CustomerEditPage(customerId: customerId ?? ''),
          settings: settings,
        );

      // ========== TEDARİKÇİ ROUTE'LARI ==========

      case suppliersList:
        return _createRoute(const EnhancedSuppliersListPage(),
            settings: settings);

      case createSupplier:
        return _createRoute(const CreateSupplierPage(), settings: settings);

      case supplierDetail:
        // Supplier ID parametresi bekleniyor
        final supplierId = arguments as String?;
        return _createRoute(
          EnhancedSupplierDetailPage(supplierId: supplierId ?? ''),
          settings: settings,
        );

      case editSupplier:
        // Supplier ID parametresi bekleniyor
        final supplierId = arguments as String?;
        return _createRoute(
          CreateSupplierPage(supplierId: supplierId),
          settings: settings,
        );

      // ========== ALIŞ ROUTE'LARI ==========

      case purchasesList:
        return _createRoute(const EnhancedPurchasesListPage(),
            settings: settings);

      case createPurchase:
        final args = arguments as Map<String, dynamic>?;
        return _createRoute(
          CreatePurchasePage(
            purchaseId: args?['purchaseId'] as String?,
            supplierId: args?['supplierId'] as String?,
            supplierName: args?['supplierName'] as String?,
          ),
          settings: settings,
        );

      case purchaseDetail:
        // Purchase ID parametresi bekleniyor
        final purchaseId = arguments as String?;
        return _createRoute(
          EnhancedPurchaseDetailPage(purchaseId: purchaseId ?? ''),
          settings: settings,
        );

      case editPurchase:
        // Purchase ID parametresi bekleniyor
        final purchaseId = arguments as String?;
        return _createRoute(
          CreatePurchasePage(purchaseId: purchaseId),
          settings: settings,
        );

      // ========== NAKİT YÖNETİMİ ROUTE'LARI ==========

      case accountsList:
        return _createRoute(const EnhancedAccountsListPage(),
            settings: settings);

      case createAccount:
        return _createRoute(const CreateAccountPage(), settings: settings);

      case accountDetail:
        // Account ID parametresi bekleniyor
        final accountId = arguments as String?;
        return _createRoute(
          EnhancedAccountDetailPage(accountId: accountId ?? ''),
          settings: settings,
        );

      case editAccount:
        // Account ID parametresi bekleniyor
        final accountId = arguments as String?;
        return _createRoute(
          CreateAccountPage(accountId: accountId),
          settings: settings,
        );

      case cashTransactionsList:
        return _createRoute(const EnhancedCashTransactionsListPage(),
            settings: settings);

      case createCashTransaction:
        return _createRoute(const CreateCashTransactionPage(),
            settings: settings);

      case cashTransactionDetail:
        // Transaction ID parametresi bekleniyor
        final transactionId = arguments as String?;
        return _createRoute(
          EnhancedCashTransactionDetailPage(transactionId: transactionId ?? ''),
          settings: settings,
        );

      // ========== RAPORLAR ROUTE'LARI ==========

      case reportsList:
        return _createRoute(const EnhancedReportsListPage(),
            settings: settings);

      case createReport:
        // Geçici olarak reports listesine yönlendir
        return _createRoute(const EnhancedReportsListPage(),
            settings: settings);

      case reportDetail:
        // Geçici olarak reports listesine yönlendir
        return _createRoute(const EnhancedReportsListPage(),
            settings: settings);

      case editReport:
        // Geçici olarak reports listesine yönlendir
        return _createRoute(const EnhancedReportsListPage(),
            settings: settings);

      // ========== ÜRÜN ROUTE'LARI ==========

      case productsList:
        return _createRoute(const ProductsListPage(), settings: settings);

      case createProduct:
        return _createRoute(const CreateProductPage(), settings: settings);

      case productDetail:
        final productId = arguments as String?;
        return _createRoute(
          ProductDetailPage(productId: productId ?? ''),
          settings: settings,
        );

      case editProduct:
        final productId = arguments as String?;
        return _createRoute(
          CreateProductPage(productId: productId),
          settings: settings,
        );

      // ========== KASA ROUTE'LARI ==========
      // Eski cash route'ları kaldırıldı - cash_management kullanılıyor

      // ========== RAPOR ROUTE'LARI ==========

      case reportsOverview:
        return _createRoute(const ReportsOverviewPage(), settings: settings);

      case incomeExpenseReport:
        return _createRoute(
          const IncomeExpenseReportPage(),
          settings: settings,
        );

      case customerReport:
        return _createRoute(const CustomerReportPage(), settings: settings);

      case supplierReport:
        return _createRoute(const SupplierReportPage(), settings: settings);

      case productReport:
        return _createRoute(const ProductReportPage(), settings: settings);

      // ========== INVENTORY ROUTE'LARI ==========
      case inventory:
        return _createRoute(const InventoryPage(), settings: settings);

      case warehouseList:
        return _createRoute(const WarehousesListPage(), settings: settings);

      case createWarehouse:
        return _createRoute(const CreateWarehousePage(), settings: settings);

      case editWarehouse:
        final warehouseId = arguments as String?;
        return _createRoute(
          CreateWarehousePage(warehouseId: warehouseId),
          settings: settings,
        );

      case warehouseDetail:
        final warehouseId = arguments as String?;
        return _createRoute(
          WarehouseDetailPage(warehouseId: warehouseId ?? ''),
          settings: settings,
        );

      case stockList:
        return _createRoute(const StockListPage(), settings: settings);

      case createStock:
        return _createRoute(const CreateStockPage(), settings: settings);

      case editStock:
        final stockId = arguments as String?;
        return _createRoute(
          CreateStockPage(stockId: stockId),
          settings: settings,
        );

      case stockDetail:
        final stockId = arguments as String?;
        return _createRoute(
          StockDetailPage(stockId: stockId ?? ''),
          settings: settings,
        );

      // ========== FİHRİST ROUTE'LARI ==========

      case contactsList:
        return _createRoute(const ContactsListPage(), settings: settings);

      case createContact:
        return _createRoute(const CreateContactPage(), settings: settings);

      case contactDetail:
        final contact = settings.arguments as Contact;
        return _createRoute(
          ContactDetailPage(contact: contact),
          settings: settings,
        );

      case editContact:
        final contact = settings.arguments as Contact;
        return _createRoute(
          EditContactPage(contact: contact),
          settings: settings,
        );

      // ========== AYARLAR ROUTE'LARI ==========

      case TamgaciRoutes.settings:
        return _createRoute(const SettingsPage(), settings: settings);

      case permissions:
        return _createRoute(const PermissionsPage(), settings: settings);

      case companySettings:
        return _createRoute(const CompanySettingsPage(), settings: settings);

      case taxSettings:
        return _createRoute(const TaxSettingsPage(), settings: settings);

      // ========== BİLDİRİMLER ROUTE'LARI ==========

      case notifications:
        return _createRoute(const NotificationsPage(), settings: settings);

      // ========== ENVANTER ROUTE'LARI ==========

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
      expensesList,
      createExpense,
      expenseDetail,
      incomeList,
      createIncome,
      incomeDetail,
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
      case expensesList:
        return 'Giderler';
      case incomeList:
        return 'Gelirler';
      case customersList:
        return 'Müşteriler';
      case suppliersList:
        return 'Tedarikçiler';
      case productsList:
        return 'Ürünler';

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
