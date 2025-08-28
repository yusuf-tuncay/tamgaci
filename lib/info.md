// ========== KLASÖR YAPISI VE DOSYA YERLEŞTİRME REHBERİ ==========

/*
📁 lib/
├── 📁 core/                           # Çekirdek sistemler
│   ├── 📁 theme/                      # Tema yönetimi
│   │   ├── 📄 constants.dart          # ✅ HAZIR (İlk artifact)
│   │   └── 📄 theme.dart              # ✅ HAZIR (İkinci artifact)
│   │
│   ├── 📁 routes/                     # Route yönetimi
│   │   └── 📄 routes.dart             # ✅ HAZIR (Üçüncü artifact)
│   │
│   ├── 📁 errors/                     # Hata yönetimi
│   │   ├── 📄 failures.dart
│   │   └── 📄 exceptions.dart
│   │
│   ├── 📁 network/                    # Ağ işlemleri
│   │   ├── 📄 api_client.dart
│   │   └── 📄 network_info.dart
│   │
│   └── 📁 utils/                      # Yardımcı sınıflar
│       ├── 📄 formatters.dart
│       ├── 📄 validators.dart
│       └── 📄 extensions.dart
│
├── 📁 shared/                         # Paylaşılan bileşenler
│   ├── 📁 widgets/                    # Paylaşılan widget'lar
│   │   ├── 📄 drawer_menu.dart        # ✅ HAZIR (Dördüncü artifact)
│   │   ├── 📄 custom_app_bar.dart
│   │   ├── 📄 loading_widget.dart
│   │   ├── 📄 empty_state_widget.dart
│   │   ├── 📄 error_widget.dart
│   │   └── 📄 custom_buttons.dart
│   │
│   ├── 📁 pages/                      # Paylaşılan sayfalar
│   │   ├── 📄 not_found_page.dart
│   │   └── 📄 under_construction_page.dart
│   │
│   └── 📁 models/                     # Paylaşılan modeller
│       ├── 📄 base_model.dart
│       └── 📄 response_model.dart
│
├── 📁 features/                       # Feature'lar (Business Logic)
│   │
│   ├── 📁 splash/                     # Splash Screen Feature
│   │   └── 📁 presentation/
│   │       └── 📁 pages/
│   │           └── 📄 splash_page.dart  # ✅ HAZIR (İlk splash artifact)
│   │
│   ├── 📁 auth/                       # Kimlik doğrulama
│   │   ├── 📁 data/
│   │   │   ├── 📁 models/
│   │   │   ├── 📁 repositories/
│   │   │   └── 📁 datasources/
│   │   ├── 📁 domain/
│   │   │   ├── 📁 entities/
│   │   │   ├── 📁 repositories/
│   │   │   └── 📁 usecases/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 login_page.dart
│   │       │   ├── 📄 register_page.dart
│   │       │   └── 📄 forgot_password_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 dashboard/                  # Ana sayfa
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   └── 📄 dashboard_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 invoices/                   # Faturalar
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 invoices_list_page.dart
│   │       │   ├── 📄 create_invoice_page.dart
│   │       │   └── 📄 invoice_detail_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 expenses/                   # Giderler
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 expenses_list_page.dart
│   │       │   ├── 📄 create_expense_page.dart
│   │       │   └── 📄 expense_detail_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 income/                     # Gelirler
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 income_list_page.dart
│   │       │   ├── 📄 create_income_page.dart
│   │       │   └── 📄 income_detail_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 customers/                  # Müşteriler
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 customers_list_page.dart
│   │       │   ├── 📄 create_customer_page.dart
│   │       │   └── 📄 customer_detail_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 suppliers/                  # Tedarikçiler
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 suppliers_list_page.dart
│   │       │   ├── 📄 create_supplier_page.dart
│   │       │   └── 📄 supplier_detail_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 products/                   # Ürünler
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 products_list_page.dart
│   │       │   ├── 📄 create_product_page.dart
│   │       │   └── 📄 product_detail_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 cash/                       # Kasa yönetimi
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 cash_overview_page.dart
│   │       │   ├── 📄 cash_transactions_page.dart
│   │       │   └── 📄 create_cash_transaction_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   ├── 📁 reports/                    # Raporlar
│   │   ├── 📁 data/
│   │   ├── 📁 domain/
│   │   └── 📁 presentation/
│   │       ├── 📁 pages/
│   │       │   ├── 📄 reports_overview_page.dart
│   │       │   ├── 📄 income_expense_report_page.dart
│   │       │   ├── 📄 customer_report_page.dart
│   │       │   ├── 📄 supplier_report_page.dart
│   │       │   └── 📄 product_report_page.dart
│   │       ├── 📁 widgets/
│   │       └── 📁 providers/
│   │
│   └── 📁 settings/                   # Ayarlar
│       ├── 📁 data/
│       ├── 📁 domain/
│       └── 📁 presentation/
│           ├── 📁 pages/
│           │   ├── 📄 settings_page.dart
│           │   ├── 📄 profile_page.dart
│           │   ├── 📄 company_settings_page.dart
│           │   └── 📄 tax_settings_page.dart
│           ├── 📁 widgets/
│           └── 📁 providers/
│
└── 📄 main.dart                       # ✅ HAZIR (Bu artifact)

========== DOSYA YERLEŞTİRME TALİMATLARI ==========

1. 📄 constants.dart 
   → lib/core/theme/constants.dart

2. 📄 theme.dart 
   → lib/core/theme/theme.dart

3. 📄 routes.dart 
   → lib/core/routes/routes.dart

4. 📄 drawer_menu.dart 
   → lib/shared/widgets/drawer_menu.dart

5. 📄 splash.dart (önceki artifact)
   → lib/features/splash/presentation/pages/splash_page.dart

6. 📄 main.dart (bu artifact)
   → lib/main.dart

========== SONRAKİ ADIMLAR ==========

Bu dosyaları yerleştirdikten sonra şu dosyaları da oluşturmanız gerekecek:

🔲 lib/shared/pages/not_found_page.dart
🔲 lib/shared/pages/under_construction_page.dart
🔲 lib/features/dashboard/presentation/pages/dashboard_page.dart
🔲 lib/features/auth/presentation/pages/login_page.dart
🔲 Diğer feature sayfaları (ihtiyaca göre)

========== PUBSPEC.YAML DEPENDENCİLERİ ==========

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # UI & Theming
  google_fonts: ^6.1.0
  
  # Routing (opsiyonel - Go Router için)
  go_router: ^12.1.3
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^5.0.2
  
  # Utils
  intl: ^0.18.1
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^3.0.1
  
  # Code Generation
  hive_generator: ^2.0.1
  build_runner: ^2.4.7

========== FLUTTER CREATE KOMUTU ==========

Yeni proje oluşturmak için:
flutter create tamgaci --org com.tamgaci --project-name tamgaci

========== İMPORT HATALARI İÇİN ==========

Tüm dosyaları yerleştirdikten sonra import hatalarını çözmek için:
1. flutter pub get
2. flutter clean
3. flutter pub get
4. Restart IDE/Editor

Bu yapı ile tamamen modüler, ölçeklenebilir ve profesyonel bir 
ön muhasebe uygulaması geliştirebilirsiniz! 🎯
*/