# User Acceptance Testing Checklist

Bu dokümantasyon, Tamgaci uygulaması için kapsamlı User Acceptance Testing (UAT) checklist'ini içerir.

## 📋 İçindekiler

- [Genel UAT Checklist](#genel-uat-checklist)
- [Business User UAT](#business-user-uat)
- [Accountant User UAT](#accountant-user-uat)
- [Manager User UAT](#manager-user-uat)
- [Admin User UAT](#admin-user-uat)
- [Technical UAT](#technical-uat)
- [Performance UAT](#performance-uat)
- [Security UAT](#security-uat)

## ✅ Genel UAT Checklist

### Uygulama Girişi
- [ ] Uygulama başarıyla açılıyor
- [ ] Login ekranı düzgün görüntüleniyor
- [ ] Email ve şifre alanları çalışıyor
- [ ] Login butonu çalışıyor
- [ ] "Şifremi Unuttum" linki çalışıyor
- [ ] Geçersiz giriş bilgileri için hata mesajı gösteriliyor
- [ ] Başarılı giriş sonrası dashboard'a yönlendiriliyor

### Dashboard
- [ ] Dashboard başarıyla yükleniyor
- [ ] Toplam satış metrikleri doğru gösteriliyor
- [ ] Toplam müşteri sayısı doğru gösteriliyor
- [ ] Toplam ürün sayısı doğru gösteriliyor
- [ ] Düşük stok uyarıları gösteriliyor
- [ ] Grafikler düzgün çalışıyor
- [ ] Son işlemler listesi gösteriliyor
- [ ] Hızlı erişim menüleri çalışıyor

### Navigasyon
- [ ] Ana menü düzgün çalışıyor
- [ ] Tüm menü öğeleri erişilebilir
- [ ] Sayfa geçişleri hızlı ve sorunsuz
- [ ] Geri butonu çalışıyor
- [ ] Breadcrumb navigasyonu çalışıyor
- [ ] Arama fonksiyonu çalışıyor

## 👥 Business User UAT

### Müşteri Yönetimi
- [ ] Müşteri listesi düzgün yükleniyor
- [ ] Yeni müşteri ekleme formu çalışıyor
- [ ] Müşteri bilgileri doğru kaydediliyor
- [ ] Müşteri arama fonksiyonu çalışıyor
- [ ] Müşteri filtreleme çalışıyor
- [ ] Müşteri sıralama çalışıyor
- [ ] Müşteri düzenleme çalışıyor
- [ ] Müşteri silme çalışıyor
- [ ] Müşteri detay sayfası çalışıyor
- [ ] Müşteri işlem geçmişi gösteriliyor

### Ürün Yönetimi
- [ ] Ürün listesi düzgün yükleniyor
- [ ] Yeni ürün ekleme formu çalışıyor
- [ ] Ürün bilgileri doğru kaydediliyor
- [ ] Ürün arama fonksiyonu çalışıyor
- [ ] Ürün filtreleme çalışıyor
- [ ] Ürün sıralama çalışıyor
- [ ] Ürün düzenleme çalışıyor
- [ ] Ürün silme çalışıyor
- [ ] Stok güncelleme çalışıyor
- [ ] Düşük stok uyarıları çalışıyor

### Satış İşlemleri
- [ ] Satış listesi düzgün yükleniyor
- [ ] Yeni satış ekleme formu çalışıyor
- [ ] Müşteri seçimi çalışıyor
- [ ] Ürün seçimi çalışıyor
- [ ] Miktar girişi çalışıyor
- [ ] Fiyat hesaplama doğru çalışıyor
- [ ] İndirim hesaplama çalışıyor
- [ ] KDV hesaplama çalışıyor
- [ ] Toplam tutar doğru hesaplanıyor
- [ ] Satış kaydetme çalışıyor
- [ ] Stok otomatik düşüyor
- [ ] Tahsilat ekleme çalışıyor

### Temel Raporlar
- [ ] Satış raporları çalışıyor
- [ ] Müşteri raporları çalışıyor
- [ ] Ürün raporları çalışıyor
- [ ] Tarih filtreleme çalışıyor
- [ ] Excel export çalışıyor
- [ ] PDF export çalışıyor

## 💰 Accountant User UAT

### Finansal Raporlar
- [ ] Gelir-gider raporu çalışıyor
- [ ] Kar/zarar raporu çalışıyor
- [ ] Nakit akışı raporu çalışıyor
- [ ] Bilanço raporu çalışıyor
- [ ] Tarih aralığı seçimi çalışıyor
- [ ] Rapor detayları doğru gösteriliyor
- [ ] Grafik görünümü çalışıyor
- [ ] Export fonksiyonları çalışıyor

### Alış İşlemleri
- [ ] Alış listesi düzgün yükleniyor
- [ ] Yeni alış ekleme formu çalışıyor
- [ ] Tedarikçi seçimi çalışıyor
- [ ] Ürün seçimi çalışıyor
- [ ] Miktar girişi çalışıyor
- [ ] Fiyat hesaplama doğru çalışıyor
- [ ] Alış kaydetme çalışıyor
- [ ] Stok otomatik artıyor
- [ ] Ödeme ekleme çalışıyor

### Nakit Yönetimi
- [ ] Hesaplar listesi düzgün yükleniyor
- [ ] Yeni hesap ekleme çalışıyor
- [ ] Hesap bakiyesi doğru gösteriliyor
- [ ] Transfer işlemleri çalışıyor
- [ ] Hesap hareketleri gösteriliyor
- [ ] Bakiye güncellemeleri doğru çalışıyor

### Gider Yönetimi
- [ ] Gider listesi düzgün yükleniyor
- [ ] Yeni gider ekleme çalışıyor
- [ ] Gider kategorileri çalışıyor
- [ ] Gider raporları çalışıyor
- [ ] Gider analizi çalışıyor

## 👨‍💼 Manager User UAT

### Dashboard Yönetimi
- [ ] Yönetim dashboard'u çalışıyor
- [ ] KPI metrikleri doğru gösteriliyor
- [ ] Performans grafikleri çalışıyor
- [ ] Trend analizleri çalışıyor
- [ ] Karşılaştırmalı raporlar çalışıyor

### Takım Yönetimi
- [ ] Personel listesi düzgün yükleniyor
- [ ] Yeni personel ekleme çalışıyor
- [ ] Personel bilgileri düzenlenebiliyor
- [ ] Maaş yönetimi çalışıyor
- [ ] Personel performansı takip ediliyor

### Onay İşlemleri
- [ ] Bekleyen onaylar listesi çalışıyor
- [ ] Onay verme işlemi çalışıyor
- [ ] Onay reddetme işlemi çalışıyor
- [ ] Onay geçmişi gösteriliyor
- [ ] Onay bildirimleri çalışıyor

### Yönetim Raporları
- [ ] Yönetim raporları çalışıyor
- [ ] KPI raporları çalışıyor
- [ ] Performans raporları çalışıyor
- [ ] Karşılaştırmalı analizler çalışıyor
- [ ] Trend raporları çalışıyor

## 🔧 Admin User UAT

### Kullanıcı Yönetimi
- [ ] Kullanıcı listesi düzgün yükleniyor
- [ ] Yeni kullanıcı ekleme çalışıyor
- [ ] Kullanıcı rolleri düzenlenebiliyor
- [ ] Kullanıcı izinleri yönetilebiliyor
- [ ] Kullanıcı durumu değiştirilebiliyor
- [ ] Kullanıcı şifre sıfırlama çalışıyor

### Sistem Ayarları
- [ ] Sistem ayarları düzenlenebiliyor
- [ ] Şirket bilgileri güncellenebiliyor
- [ ] Para birimi ayarları çalışıyor
- [ ] Tarih formatı ayarları çalışıyor
- [ ] Dil ayarları çalışıyor
- [ ] Tema ayarları çalışıyor

### Güvenlik Yönetimi
- [ ] Güvenlik ayarları düzenlenebiliyor
- [ ] Audit logları görüntülenebiliyor
- [ ] Güvenlik raporları çalışıyor
- [ ] Kullanıcı aktiviteleri takip ediliyor
- [ ] Güvenlik uyarıları çalışıyor

### Sistem İzleme
- [ ] Sistem metrikleri gösteriliyor
- [ ] Performans izleme çalışıyor
- [ ] Hata logları görüntülenebiliyor
- [ ] Sistem durumu raporlanıyor
- [ ] Bakım işlemleri çalışıyor

## 🔧 Technical UAT

### Performans
- [ ] Uygulama hızlı açılıyor (< 3 saniye)
- [ ] Sayfa geçişleri hızlı (< 1 saniye)
- [ ] Arama işlemleri hızlı (< 500ms)
- [ ] Rapor oluşturma hızlı (< 5 saniye)
- [ ] Export işlemleri hızlı (< 10 saniye)
- [ ] Büyük veri setleri ile çalışıyor
- [ ] Bellek kullanımı optimize

### Uyumluluk
- [ ] Farklı tarayıcılarda çalışıyor
- [ ] Farklı ekran boyutlarında çalışıyor
- [ ] Mobil cihazlarda çalışıyor
- [ ] Tablet cihazlarda çalışıyor
- [ ] Desktop cihazlarda çalışıyor
- [ ] Farklı işletim sistemlerinde çalışıyor

### Veri Bütünlüğü
- [ ] Veri kaybı olmuyor
- [ ] Veri tutarlılığı korunuyor
- [ ] Backup işlemleri çalışıyor
- [ ] Restore işlemleri çalışıyor
- [ ] Veri senkronizasyonu çalışıyor
- [ ] Çakışma çözümü çalışıyor

### Hata Yönetimi
- [ ] Hata mesajları anlaşılır
- [ ] Hata durumları düzgün yönetiliyor
- [ ] Kullanıcı dostu hata mesajları
- [ ] Hata logları tutuluyor
- [ ] Hata raporlama çalışıyor
- [ ] Otomatik hata düzeltme çalışıyor

## ⚡ Performance UAT

### Yükleme Süreleri
- [ ] İlk yükleme < 3 saniye
- [ ] Sayfa yükleme < 1 saniye
- [ ] Arama sonuçları < 500ms
- [ ] Rapor oluşturma < 5 saniye
- [ ] Export işlemi < 10 saniye
- [ ] Büyük dosya yükleme < 30 saniye

### Kaynak Kullanımı
- [ ] CPU kullanımı optimize
- [ ] Bellek kullanımı optimize
- [ ] Disk kullanımı optimize
- [ ] Ağ kullanımı optimize
- [ ] Batarya tüketimi optimize
- [ ] Veri kullanımı optimize

### Ölçeklenebilirlik
- [ ] Çoklu kullanıcı desteği
- [ ] Büyük veri setleri desteği
- [ ] Yüksek trafik desteği
- [ ] Eşzamanlı işlem desteği
- [ ] Otomatik ölçeklendirme
- [ ] Load balancing desteği

## 🔒 Security UAT

### Kimlik Doğrulama
- [ ] Güçlü şifre politikası
- [ ] Çok faktörlü kimlik doğrulama
- [ ] Oturum yönetimi
- [ ] Oturum zaman aşımı
- [ ] Güvenli çıkış
- [ ] Şifre sıfırlama

### Yetkilendirme
- [ ] Rol tabanlı erişim kontrolü
- [ ] İzin yönetimi
- [ ] Veri izolasyonu
- [ ] Fonksiyon bazlı erişim
- [ ] API güvenliği
- [ ] Veri şifreleme

### Veri Güvenliği
- [ ] Veri şifreleme
- [ ] Güvenli veri aktarımı
- [ ] Veri maskeleme
- [ ] Hassas veri koruması
- [ ] Veri yedekleme
- [ ] Veri kurtarma

### Güvenlik İzleme
- [ ] Güvenlik logları
- [ ] Anomali tespiti
- [ ] Güvenlik uyarıları
- [ ] İhlal tespiti
- [ ] Güvenlik raporları
- [ ] Compliance raporları

## 📊 UAT Sonuçları

### Test Durumu
- [ ] Tüm testler geçti
- [ ] Kritik hatalar yok
- [ ] Minor hatalar düzeltildi
- [ ] Performans hedefleri karşılandı
- [ ] Güvenlik gereksinimleri karşılandı
- [ ] Kullanıcı deneyimi hedefleri karşılandı

### Kullanıcı Geri Bildirimi
- [ ] Kullanıcı memnuniyeti yüksek
- [ ] Kullanım kolaylığı iyi
- [ ] Performans memnun edici
- [ ] Güvenlik güven verici
- [ ] Özellikler yeterli
- [ ] Dokümantasyon yeterli

### Deployment Hazırlığı
- [ ] Production ortamı hazır
- [ ] Backup stratejisi hazır
- [ ] Monitoring sistemi hazır
- [ ] Support sistemi hazır
- [ ] Dokümantasyon hazır
- [ ] Training materyalleri hazır

## 📝 UAT Notları

### Test Tarihi
- **Başlangıç Tarihi**: ___________
- **Bitiş Tarihi**: ___________
- **Test Süresi**: ___________

### Test Ekibi
- **Test Lideri**: ___________
- **Business User**: ___________
- **Accountant User**: ___________
- **Manager User**: ___________
- **Admin User**: ___________
- **Technical Tester**: ___________

### Test Ortamı
- **Test Environment**: ___________
- **Test Data**: ___________
- **Test Tools**: ___________
- **Test Devices**: ___________

### Bulunan Hatalar
- **Kritik Hatalar**: ___________
- **Major Hatalar**: ___________
- **Minor Hatalar**: ___________
- **Cosmetic Hatalar**: ___________

### Öneriler
- **İyileştirme Önerileri**: ___________
- **Yeni Özellik Önerileri**: ___________
- **Performans Önerileri**: ___________
- **Güvenlik Önerileri**: ___________

### Sonuç
- **UAT Durumu**: ✅ BAŞARILI / ❌ BAŞARISIZ
- **Deployment Onayı**: ✅ ONAYLANDI / ❌ ONAYLANMADI
- **Sonraki Adımlar**: ___________
- **Notlar**: ___________
