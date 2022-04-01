import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Add and remove a todo', (WidgetTester tester) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('hi'), findsOneWidget);
  });
}
