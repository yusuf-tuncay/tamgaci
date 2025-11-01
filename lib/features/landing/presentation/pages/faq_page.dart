// ========== FAQ PAGE (Sıkça Sorulan Sorular) ==========
// lib/features/landing/presentation/pages/faq_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

/// FAQ sayfası - SEO için önemli içerik
class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Sıkça Sorulan Sorular',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width > 768 ? 80 : 40,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF3B82F6),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Sıkça Sorulan Sorular',
                    style: GoogleFonts.poppins(
                      fontSize:
                          MediaQuery.of(context).size.width > 768 ? 56 : 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tamgaci hakkında merak ettiğiniz soruların cevaplarını bulun',
                    style: GoogleFonts.poppins(
                      fontSize:
                          MediaQuery.of(context).size.width > 768 ? 20 : 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // FAQ Items Section
            Container(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width > 768 ? 80 : 40,
              ),
              child: Column(
                children: [
                  // FAQ Accordion
                  ..._getFAQItems().asMap().entries.map((entry) {
                    final index = entry.key;
                    final faq = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildFAQItem(
                        context,
                        index,
                        faq['question'] as String,
                        faq['answer'] as String,
                      ),
                    );
                  }),

                  const SizedBox(height: 60),

                  // Contact CTA Section
                  _buildContactSection(context),

                  const SizedBox(height: 60),

                  // SEO Content Section
                  _buildSEOContent(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FAQ Item (Accordion)
  Widget _buildFAQItem(
    BuildContext context,
    int index,
    String question,
    String answer,
  ) {
    final isExpanded = _expandedIndex == index;
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(isMobile ? 20 : 24),
          childrenPadding: EdgeInsets.fromLTRB(
            isMobile ? 20 : 24,
            0,
            isMobile ? 20 : 24,
            isMobile ? 20 : 24,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isExpanded
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              color: isExpanded ? Colors.white : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.remove_circle : Icons.add_circle,
            color:
                isExpanded ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
          ),
          initiallyExpanded: false,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? index : null;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  color: const Color(0xFF64748B),
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Contact Section
  Widget _buildContactSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 30 : 50),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.support_agent,
            size: isMobile ? 60 : 80,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          Text(
            'Sorunuz mu var?',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Aradığınız cevabı bulamadıysanız, bizimle iletişime geçmekten çekinmeyin.',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Email veya iletişim sayfasına yönlendirme
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3B82F6),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 40 : 60,
                vertical: isMobile ? 16 : 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Text(
              'İletişime Geç',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SEO Content Section
  Widget _buildSEOContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width > 768 ? 60 : 40,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tamgaci Hakkında',
            style: GoogleFonts.poppins(
              fontSize: MediaQuery.of(context).size.width > 768 ? 36 : 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Tamgaci, kurumsal ve KOBİ işletmelerin ön muhasebe ihtiyaçlarını karşılamak için geliştirilmiş modern bir bulut tabanlı yazılımdır. Web, mobil ve masaüstü platformlarında kullanılabilen Tamgaci, işletmenizin tüm finansal işlemlerini tek bir platformda yönetmenize olanak tanır.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF64748B),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Özellikler',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureList(),
        ],
      ),
    );
  }

  /// Feature List
  Widget _buildFeatureList() {
    final features = [
      'Fatura yönetimi ve e-fatura entegrasyonu',
      'Stok takibi ve envanter yönetimi',
      'Müşteri ve tedarikçi yönetimi',
      'Gelir-gider takibi ve finansal raporlama',
      'Çoklu para birimi desteği',
      'Otomatik yedekleme ve bulut senkronizasyonu',
      'Mobil uygulama ile her yerden erişim',
      'Güvenli veri saklama ve şifreleme',
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 12),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  feature,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Get FAQ Items
  List<Map<String, dynamic>> _getFAQItems() {
    return [
      {
        'question': 'Tamgaci nedir?',
        'answer':
            'Tamgaci, kurumsal ve KOBİ işletmelerin ön muhasebe ihtiyaçlarını karşılamak için geliştirilmiş modern bir bulut tabanlı yazılımdır. Fatura yönetimi, stok takibi, müşteri-tedarikçi yönetimi, gelir-gider takibi ve finansal raporlama gibi özellikler sunar.',
      },
      {
        'question': 'Tamgaci\'yi nasıl kullanabilirim?',
        'answer':
            'Tamgaci\'yi kullanmak için web tarayıcınızdan giriş yapabilir, mobil uygulamasını indirebilir veya masaüstü uygulamasını kurabilirsiniz. Tüm platformlarda aynı verilerinize erişebilir, işlemlerinizi senkronize bir şekilde yönetebilirsiniz.',
      },
      {
        'question': 'Tamgaci ücretsiz mi?',
        'answer':
            'Tamgaci, 30 günlük ücretsiz deneme süresi sunar. Deneme süresi sonrasında işletmenizin ihtiyacına uygun paketlerden birini seçebilirsiniz. Detaylı fiyatlandırma bilgisi için lütfen iletişime geçin.',
      },
      {
        'question': 'Verilerim güvende mi?',
        'answer':
            'Evet, verilerinizin güvenliği bizim için çok önemlidir. Tamgaci, banka seviyesi güvenlik standartları kullanır. Verileriniz şifrelenmiş olarak bulut sunucularında saklanır ve düzenli olarak yedeklenir.',
      },
      {
        'question': 'E-fatura entegrasyonu var mı?',
        'answer':
            'Evet, Tamgaci e-fatura, e-arşiv fatura ve e-irsaliye entegrasyonu sunar. GİB (Gelir İdaresi Başkanlığı) sistemleri ile entegre çalışarak faturalarınızı otomatik olarak gönderebilir ve yönetebilirsiniz.',
      },
      {
        'question': 'Çoklu kullanıcı desteği var mı?',
        'answer':
            'Evet, Tamgaci çoklu kullanıcı desteği sunar. İşletmenizdeki farklı kullanıcılara farklı yetki seviyeleri atayabilir, her kullanıcının kendi rolüne göre sistem özelliklerine erişmesini sağlayabilirsiniz.',
      },
      {
        'question': 'Mobil uygulama hangi platformlarda mevcut?',
        'answer':
            'Tamgaci mobil uygulaması hem Android hem de iOS platformlarında mevcut. Google Play Store ve Apple App Store\'dan indirebilirsiniz.',
      },
      {
        'question': 'Yedekleme nasıl yapılır?',
        'answer':
            'Tamgaci, verilerinizi otomatik olarak bulut sunucularında yedekler. Ek olarak, istediğiniz zaman manuel yedekleme de yapabilirsiniz. Yedekleriniz güvenli bir şekilde saklanır ve gerektiğinde geri yüklenebilir.',
      },
      {
        'question': 'Destek nasıl alabilirim?',
        'answer':
            'Tamgaci müşteri desteği ekibimize e-posta üzerinden veya telefon ile ulaşabilirsiniz. Ayrıca uygulama içi destek sistemi ve detaylı dokümantasyon da mevcuttur.',
      },
      {
        'question': 'Yeni özellikler nasıl ekleniyor?',
        'answer':
            'Tamgaci sürekli geliştirilmekte olan bir platformdur. Düzenli güncellemeler ile yeni özellikler eklenir ve mevcut özellikler iyileştirilir. Tüm güncellemeler otomatik olarak uygulanır ve kullanıcılar ücretsiz olarak erişebilir.',
      },
    ];
  }
}
