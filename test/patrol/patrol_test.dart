import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tamgaci/main.dart' as app;

void main() {
  patrolTest(
    'Tamgacı uygulaması genel testi',
    ($) async {
      // Uygulamayı başlat
      await app.main();
      await $.pumpAndSettle();

      // Ana sayfa elementlerini kontrol et
      expect($(#AppBar), findsOneWidget);
      expect($(#BottomNavigationBar), findsOneWidget);

      // Navigasyon testi
      await $(#BottomNavigationBar).$(#BottomNavigationBarItem, index: 0).tap();
      await $.pumpAndSettle();

      await $(#BottomNavigationBar).$(#BottomNavigationBarItem, index: 1).tap();
      await $.pumpAndSettle();

      await $(#BottomNavigationBar).$(#BottomNavigationBarItem, index: 2).tap();
      await $.pumpAndSettle();

      // Geri dönüş testi
      await $.native.back();
      await $.pumpAndSettle();
    },
  );
}
