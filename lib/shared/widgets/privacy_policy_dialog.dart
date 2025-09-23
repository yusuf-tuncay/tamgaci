// ========== PRIVACY POLICY DIALOG ==========
// lib/shared/widgets/privacy_policy_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/constants.dart';

/// Gizlilik Politikası Dialog Widget'ı
class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 600,
          maxWidth: 500,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gizlilik Politikası',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      '1. Giriş',
                      'Bu Gizlilik Politikası, Tamgaci uygulaması ("Uygulama") kullanıcılarının kişisel verilerinin nasıl toplandığını, kullanıldığını, saklandığını ve korunduğunu açıklar. Uygulamayı kullanarak bu politikayı kabul etmiş olursunuz.',
                    ),

                    _buildSection(
                      '2. Toplanan Bilgiler',
                      'Uygulama aşağıdaki kişisel bilgileri toplar:\n\n'
                          '• Kimlik Bilgileri: Ad, soyad, e-posta adresi\n'
                          '• İletişim Bilgileri: Telefon numarası, adres\n'
                          '• İş Bilgileri: Şirket adı, vergi kimlik numarası, vergi dairesi\n'
                          '• Profil Bilgileri: Profil fotoğrafı, tercihler\n'
                          '• Teknik Bilgiler: Cihaz bilgileri, IP adresi, kullanım verileri',
                    ),

                    _buildSection(
                      '3. Bilgilerin Kullanımı',
                      'Toplanan bilgiler aşağıdaki amaçlarla kullanılır:\n\n'
                          '• Hesap oluşturma ve yönetimi\n'
                          '• Hizmet sunumu ve geliştirme\n'
                          '• Müşteri desteği sağlama\n'
                          '• Güvenlik ve dolandırıcılık önleme\n'
                          '• Yasal yükümlülüklerin yerine getirilmesi\n'
                          '• İletişim ve bildirimler',
                    ),

                    _buildSection(
                      '4. Veri Güvenliği',
                      'Kişisel verilerinizi korumak için:\n\n'
                          '• End-to-end şifreleme kullanıyoruz\n'
                          '• Güvenli sunucu altyapısı kullanıyoruz\n'
                          '• Düzenli güvenlik güncellemeleri yapıyoruz\n'
                          '• Erişim kontrolleri uyguluyoruz\n'
                          '• Veri yedekleme sistemleri kullanıyoruz',
                    ),

                    _buildSection(
                      '5. Veri Paylaşımı',
                      'Kişisel verilerinizi üçüncü taraflarla paylaşmayız, ancak:\n\n'
                          '• Yasal zorunluluklar gereği\n'
                          '• Mahkeme kararı ile\n'
                          '• Kullanıcı onayı ile\n'
                          '• Hizmet sağlayıcılarımızla (sınırlı erişim)',
                    ),

                    _buildSection(
                      '6. Çerezler ve Takip',
                      'Uygulama aşağıdaki teknolojileri kullanır:\n\n'
                          '• Oturum çerezleri (giriş durumu)\n'
                          '• Tercih çerezleri (kullanıcı ayarları)\n'
                          '• Analitik çerezler (kullanım istatistikleri)\n'
                          '• Güvenlik çerezleri (dolandırıcılık önleme)',
                    ),

                    _buildSection(
                      '7. Kullanıcı Hakları',
                      'KVKK kapsamında aşağıdaki haklara sahipsiniz:\n\n'
                          '• Kişisel verilerinizin işlenip işlenmediğini öğrenme\n'
                          '• İşlenen verileriniz hakkında bilgi talep etme\n'
                          '• Verilerinizin düzeltilmesini isteme\n'
                          '• Verilerinizin silinmesini isteme\n'
                          '• Veri işlemeye itiraz etme\n'
                          '• Zararın giderilmesini talep etme',
                    ),

                    _buildSection(
                      '8. Veri Saklama',
                      'Kişisel verileriniz:\n\n'
                          '• Hesap aktif olduğu sürece saklanır\n'
                          '• Hesap silindikten sonra 30 gün içinde silinir\n'
                          '• Yasal zorunluluklar gereği daha uzun saklanabilir\n'
                          '• Yedekleme sistemlerinden 90 gün içinde silinir',
                    ),

                    _buildSection(
                      '9. Çocukların Gizliliği',
                      'Uygulama 18 yaş altındaki kişilerden bilerek kişisel veri toplamaz. '
                          '18 yaş altındaki kullanıcıların ebeveyn/vasilerinin onayı gereklidir.',
                    ),

                    _buildSection(
                      '10. Politika Güncellemeleri',
                      'Bu gizlilik politikası gerektiğinde güncellenebilir. '
                          'Önemli değişiklikler kullanıcılara e-posta veya uygulama içi bildirim ile duyurulur.',
                    ),

                    _buildSection(
                      '11. İletişim',
                      'Gizlilik ile ilgili sorularınız için:\n\n'
                          'E-posta: privacy@tamgaci.com\n'
                          'Adres: Tamgaci Teknoloji A.Ş.\n'
                          'İstanbul, Türkiye',
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: TamgaciConstants.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Son güncelleme: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: TamgaciConstants.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TamgaciConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: TamgaciConstants.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gizlilik Politikası Dialog'unu gösteren fonksiyon
void showPrivacyPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const PrivacyPolicyDialog(),
  );
}
