import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tamgaci/main.dart' as app;

void main() {
  patrolTest(
    'Tamgacı uygulaması ana akış testi',
    ($) async {
      // Uygulamayı başlat
      await app.main();

      // Splash screen'i bekle
      await $.pumpAndSettle();

      // Ana sayfa yüklendiğini doğrula
      expect($(#Text, text: 'Tamgacı'), findsOneWidget);

      // Hesap oluştur butonuna tıkla
      await $(#ElevatedButton, text: 'Hesap Oluştur').tap();
      await $.pumpAndSettle();

      // Kayıt formunu doldur
      await $(#TextFormField, hintText: 'Ad Soyad').enterText('Test Kullanıcı');
      await $(#TextFormField, hintText: 'E-posta')
          .enterText('test@example.com');
      await $(#TextFormField, hintText: 'Şifre').enterText('123456');

      // Kayıt ol butonuna tıkla
      await $(#ElevatedButton, text: 'Kayıt Ol').tap();
      await $.pumpAndSettle();

      // Başarılı kayıt mesajını doğrula
      expect($(#Text, text: 'Hesabınız başarıyla oluşturuldu'), findsOneWidget);
    },
  );
}
