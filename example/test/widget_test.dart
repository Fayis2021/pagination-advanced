import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('App launches and shows bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(const PaginationDemoApp());
    // NavigationBar should be present
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
