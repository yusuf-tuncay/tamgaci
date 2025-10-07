// ========== PAYTR IFRAME WIDGET ==========
// lib/features/subscription/presentation/widgets/paytr_iframe_widget.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/services/payment/paytr_service.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../../auth/domain/entities/user.dart';

/// PayTR IFrame widget'ı
class PaytrIframeWidget extends StatefulWidget {
  /// Kullanıcı bilgileri
  final User user;

  /// Seçilen plan
  final SubscriptionPlanType planType;

  /// Plan fiyatı
  final double amount;

  /// Başarılı ödeme callback'i
  final VoidCallback? onPaymentSuccess;

  /// Başarısız ödeme callback'i
  final VoidCallback? onPaymentFailed;

  /// İptal callback'i
  final VoidCallback? onPaymentCancelled;

  const PaytrIframeWidget({
    super.key,
    required this.user,
    required this.planType,
    required this.amount,
    this.onPaymentSuccess,
    this.onPaymentFailed,
    this.onPaymentCancelled,
  });

  @override
  State<PaytrIframeWidget> createState() => _PaytrIframeWidgetState();
}

class _PaytrIframeWidgetState extends State<PaytrIframeWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// WebView'i başlat
  void _initializeWebView() async {
    try {
      // PayTR token oluştur
      final paytrService = PaytrService();
      final tokenResponse = await paytrService.createPaymentToken(
        user: widget.user,
        planType: widget.planType,
        amount: widget.amount,
      );

      if (!tokenResponse.success) {
        setState(() {
          _error = tokenResponse.error ?? 'Token oluşturulamadı';
          _isLoading = false;
        });
        return;
      }

      // WebView controller oluştur
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('PayTR Page Started: $url');
              _handleUrlNavigation(url);
            },
            onPageFinished: (String url) {
              debugPrint('PayTR Page Finished: $url');
              setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('PayTR WebView Error: ${error.description}');
              setState(() {
                _error = 'Sayfa yüklenemedi: ${error.description}';
                _isLoading = false;
              });
            },
          ),
        );

      // PayTR IFrame URL'si oluştur
      final iframeUrl = 'https://www.paytr.com/odeme/guvenli/${tokenResponse.token}';
      
      // Sayfayı yükle
      await _controller.loadRequest(Uri.parse(iframeUrl));
    } catch (e) {
      debugPrint('PayTR IFrame Error: $e');
      setState(() {
        _error = 'Ödeme sayfası yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  /// URL navigasyonunu handle et
  void _handleUrlNavigation(String url) {
    debugPrint('PayTR Navigation: $url');

    // Başarılı ödeme URL'si
    if (url.contains('success') || url.contains('basarili')) {
      widget.onPaymentSuccess?.call();
      return;
    }

    // Başarısız ödeme URL'si
    if (url.contains('fail') || url.contains('basarisiz')) {
      widget.onPaymentFailed?.call();
      return;
    }

    // İptal URL'si
    if (url.contains('cancel') || url.contains('iptal')) {
      widget.onPaymentCancelled?.call();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ödeme',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _initializeWebView();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Ana body widget'ı
  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    return _buildWebView();
  }

  /// Hata widget'ı
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Ödeme Sayfası Yüklenemedi',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeWebView();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('İptal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Yükleniyor widget'ı
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Ödeme sayfası yükleniyor...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen bekleyin',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// WebView widget'ı
  Widget _buildWebView() {
    return WebViewWidget(controller: _controller);
  }
}
