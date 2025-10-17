// ========== GO ROUTER ROUTE CONSTANTS ==========
// lib/core/routing/route_constants.dart

/// Go Router route constants
class RouteConstants {
  // ========== PUBLIC ROUTES ==========
  
  static const String landing = 'landing';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  
  // ========== PAYMENT ROUTES ==========
  
  static const String paymentSuccess = 'payment-success';
  static const String paymentFail = 'payment-fail';
  
  // ========== PROTECTED ROUTES ==========
  
  static const String dashboard = 'dashboard';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String subscription = 'subscription';
  static const String permissions = 'permissions';
  static const String companySettings = 'company-settings';
  
  // ========== SALES ROUTES ==========
  
  static const String salesList = 'sales-list';
  static const String createSale = 'create-sale';
  static const String saleDetail = 'sale-detail';
  
  // ========== INVOICES ROUTES ==========
  
  static const String invoicesList = 'invoices-list';
  static const String createInvoice = 'create-invoice';
  
  // ========== CUSTOMERS ROUTES ==========
  
  static const String customersList = 'customers-list';
  static const String createCustomer = 'create-customer';
  static const String customerDetail = 'customer-detail';
  
  // ========== SUPPLIERS ROUTES ==========
  
  static const String suppliersList = 'suppliers-list';
  static const String supplierDetail = 'supplier-detail';
  
  // ========== PURCHASES ROUTES ==========
  
  static const String purchasesList = 'purchases-list';
  static const String createPurchase = 'create-purchase';
  static const String purchaseDetail = 'purchase-detail';
  
  // ========== ACCOUNTS ROUTES ==========
  
  static const String accountsList = 'accounts-list';
  static const String accountsHome = 'accounts-home';
  static const String createAccount = 'create-account';
  static const String accountDetail = 'account-detail';
  
  // ========== CASH TRANSACTIONS ROUTES ==========
  
  static const String cashTransactionsList = 'cash-transactions-list';
  static const String createCashTransaction = 'create-cash-transaction';
  static const String cashTransactionDetail = 'cash-transaction-detail';
  
  // ========== PRODUCTS ROUTES ==========
  
  static const String productsList = 'products-list';
  static const String createProduct = 'create-product';
  static const String productDetail = 'product-detail';
  static const String productVariants = 'product-variants';
  static const String bulkStockUpdate = 'bulk-stock-update';
  
  // ========== REPORTS ROUTES ==========
  
  static const String reportsOverview = 'reports-overview';
  static const String incomeExpenseReport = 'income-expense-report';
  static const String customerReport = 'customer-report';
  static const String supplierReport = 'supplier-report';
  static const String productReport = 'product-report';
  
  // ========== WAREHOUSE ROUTES ==========
  
  static const String warehousesHome = 'warehouses-home';
  
  // ========== SHARED ROUTES ==========
  
  static const String underConstruction = 'under-construction';
}
