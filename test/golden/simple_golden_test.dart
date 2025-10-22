import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Golden Tests', () {
    goldenTest(
      'Basit widget görünümü',
      fileName: 'simple_widget',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTest(
            name: 'Light Theme',
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                appBar: AppBar(title: const Text('Test App')),
                body: const Center(
                  child: Text('Hello World'),
                ),
              ),
            ),
          ),
          GoldenTest(
            name: 'Dark Theme',
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: Scaffold(
                appBar: AppBar(title: const Text('Test App')),
                body: const Center(
                  child: Text('Hello World'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
