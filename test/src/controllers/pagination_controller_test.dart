import 'package:flutter_test/flutter_test.dart';
import 'package:pagination_advanced/pagination_advanced.dart';

void main() {
  group('PaginationController', () {
    late PaginationController<int> controller;

    Future<PaginationResult<int>> fetchSuccess(PaginationQuery query) async {
      final page = query.page ?? 1;
      final items = List.generate(10, (i) => (page - 1) * 10 + i);
      return PaginationResult(
        items: items,
        hasMore: page < 3,
        totalCount: 30,
      );
    }

    test('loads initial data correctly', () async {
      controller = PaginationController<int>(fetch: fetchSuccess);
      
      // Initially loading
      expect(controller.value.status, PaginationStatus.initialLoading);
      
      await Future.delayed(Duration.zero); // Allow async fetch to complete
      
      expect(controller.value.status, PaginationStatus.loaded);
      expect(controller.value.items.length, 10);
      expect(controller.value.hasMore, true);
    });

    test('fetches more data correctly', () async {
      controller = PaginationController<int>(fetch: fetchSuccess);
      await Future.delayed(Duration.zero);
      
      await controller.fetchMore();
      
      expect(controller.value.items.length, 20);
      expect(controller.value.items.last, 19);
      expect(controller.value.hasMore, true);
      
      await controller.fetchMore();
      expect(controller.value.items.length, 30);
      expect(controller.value.hasMore, false);
    });

    test('handles errors', () async {
      controller = PaginationController<int>(
        fetch: (query) => throw Exception('Fetch failed'),
      );
      
      await Future.delayed(Duration.zero);
      
      expect(controller.value.status, PaginationStatus.error);
      expect(controller.value.error.toString(), contains('Fetch failed'));
    });

    test('refresh resets state', () async {
      controller = PaginationController<int>(fetch: fetchSuccess);
      await Future.delayed(Duration.zero);
      await controller.fetchMore();
      
      expect(controller.value.items.length, 20);
      
      await controller.refresh();
      expect(controller.value.items.length, 10);
    });
  });
}
