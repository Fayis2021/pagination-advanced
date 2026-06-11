import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagination_advanced/pagination_advanced.dart';

void main() {
  group('PaginatedGridView', () {
    testWidgets('renders grid of items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginatedGridView<String>(
              fetch: (query) async => PaginationResult(
                items: List.generate(10, (i) => 'Item $i'),
                hasMore: false,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item) => Text(item),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}
