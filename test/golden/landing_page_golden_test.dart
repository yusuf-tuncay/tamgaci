import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamgaci/features/landing/presentation/pages/landing_page.dart';

void main() {
  group('Landing Page Golden Tests', () {
    goldenTest(
      'Landing page görünümü',
      fileName: 'landing_page',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTest(
            name: 'Light Theme',
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const LandingPage(),
            ),
          ),
          GoldenTest(
            name: 'Dark Theme',
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const LandingPage(),
            ),
          ),
        ],
      ),
    );
  });
}
