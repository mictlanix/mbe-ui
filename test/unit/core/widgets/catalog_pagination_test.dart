import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';

void main() {
  group('fetchClampedPage (017-ui-consistency-filters FR-026)', () {
    Future<CatalogPage<int>> fetchAt(
      int pageIndex, {
      required int total,
      required Map<int, List<int>> itemsByPage,
    }) async {
      return CatalogPage(
        items: itemsByPage[pageIndex] ?? const [],
        total: total,
        pageIndex: pageIndex,
        pageSize: 20,
      );
    }

    test('returns the requested page unchanged when it has items', () async {
      final page = await fetchClampedPage<int>(
        pageIndex: 0,
        pageSize: 20,
        fetch: (i) => fetchAt(
          i,
          total: 21,
          itemsByPage: {0: List.generate(20, (n) => n)},
        ),
      );

      expect(page.pageIndex, 0);
      expect(page.items, hasLength(20));
    });

    test('a page beyond the result set clamps to the last valid page instead '
        'of surfacing an empty view', () async {
      final calls = <int>[];
      final page = await fetchClampedPage<int>(
        pageIndex: 5,
        pageSize: 20,
        fetch: (i) {
          calls.add(i);
          return fetchAt(
            i,
            total: 21,
            itemsByPage: {
              1: [20],
            },
          );
        },
      );

      expect(calls, [5, 1]);
      expect(page.pageIndex, 1);
      expect(page.items, [20]);
    });

    test('a genuinely empty result (no matches at all) is left alone, not '
        'clamped', () async {
      final calls = <int>[];
      final page = await fetchClampedPage<int>(
        pageIndex: 0,
        pageSize: 20,
        fetch: (i) {
          calls.add(i);
          return fetchAt(i, total: 0, itemsByPage: const {});
        },
      );

      expect(calls, [0]);
      expect(page.pageIndex, 0);
      expect(page.items, isEmpty);
    });

    test('page 0 with a stale non-empty total but no items is not re-fetched '
        '(clamping only applies beyond page 0)', () async {
      final calls = <int>[];
      final page = await fetchClampedPage<int>(
        pageIndex: 0,
        pageSize: 20,
        fetch: (i) {
          calls.add(i);
          return fetchAt(i, total: 21, itemsByPage: const {});
        },
      );

      expect(calls, [0]);
      expect(page.pageIndex, 0);
    });

    test('when the computed last page equals the requested page, does not '
        'refetch a second time', () async {
      final calls = <int>[];
      final page = await fetchClampedPage<int>(
        pageIndex: 1,
        pageSize: 20,
        fetch: (i) {
          calls.add(i);
          // total=21 → lastPageIndex = (21-1)~/20 = 1, same as requested.
          return fetchAt(i, total: 21, itemsByPage: const {});
        },
      );

      expect(calls, [1]);
      expect(page.pageIndex, 1);
    });
  });
}
