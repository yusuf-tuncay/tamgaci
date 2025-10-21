import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tamgaci/main.dart' as app;

void main() {
  patrolTest(
    'Hesap makinesi işlevsellik testi',
    ($) async {
      // Uygulamayı başlat
      await app.main();
      await $.pumpAndSettle();

      // Hesap makinesi sayfasına git
      await $(#BottomNavigationBar).$(#BottomNavigationBarItem, index: 1).tap();
      await $.pumpAndSettle();

      // Basit hesaplama yap
      await $(#TextButton, text: '1').tap();
      await $(#TextButton, text: '+').tap();
      await $(#TextButton, text: '2').tap();
      await $(#TextButton, text: '=').tap();

      // Sonucu doğrula
      expect($(#Text, text: '3'), findsOneWidget);

      // Temizle butonuna tıkla
      await $(#TextButton, text: 'C').tap();
      expect($(#Text, text: '0'), findsOneWidget);
    },
  );
}
