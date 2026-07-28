// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.green,
          appBar: AppBar(
            title: const Text("Belajar Flutter"),
            backgroundColor: Colors.blue,
          ),
          body: Center(
            child: Image.asset(
              'image/images.webp',
            ),
          ),
        ),
      ),
    );

    // Verify that the title text is found.
    expect(find.text('Belajar Flutter'), findsOneWidget);
  });
}

