// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_moa/main.dart';

void main() {
  testWidgets('NewsMoaApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NewsMoaApp());

    // Verify that the title text is present
    expect(find.text('Market Heatmap'), findsOneWidget);
    
    // Verify tabs are present
    expect(find.text('대한민국'), findsOneWidget);
    expect(find.text('미국'), findsOneWidget);
  });
}
