import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamgaci/features/calculator/presentation/pages/calculator_page.dart';

void main() {
  group('Calculator Golden Tests', () {
    goldenTest(
      'Calculator görünümü',
      fileName: 'calculator_page',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTest(
            name: 'Light Theme',
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const CalculatorPage(),
            ),
          ),
          GoldenTest(
            name: 'Dark Theme',
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const CalculatorPage(),
            ),
          ),
        ],
      ),
    );
  });
}
