import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamgaci/features/splash/presentation/pages/splash.dart';

void main() {
  group('Splash Screen Golden Tests', () {
    goldenTest(
      'Splash screen görünümü',
      fileName: 'splash_screen',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTest(
            name: 'Light Theme',
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const SplashPage(),
            ),
          ),
          GoldenTest(
            name: 'Dark Theme',
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const SplashPage(),
            ),
          ),
        ],
      ),
    );
  });
}
