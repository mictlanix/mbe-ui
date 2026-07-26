import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';

void main() {
  group('ListQuery.fromUri / toUri round-trip', () {
    test('default query encodes to a bare path (FR-020)', () {
      const query = ListQuery();
      expect(query.toUri('/vehicles').toString(), '/vehicles');
      expect(query.isDefault, isTrue);
      expect(query.isFiltered, isFalse);
    });

    test('round-trips search alone', () {
      const query = ListQuery(search: 'tornillo');
      final uri = query.toUri('/products');
      expect(ListQuery.fromUri(uri), query);
    });

    test('round-trips page (one-based in the URL, zero-based internally)', () {
      const query = ListQuery(pageIndex: 2);
      final uri = query.toUri('/vehicles');
      expect(uri.toString(), '/vehicles?page=3');
      expect(ListQuery.fromUri(uri), query);
    });

    test('round-trips a single-valued facet (e.g. EntityStatus)', () {
      const query = ListQuery(
        facets: {
          'status': ['active'],
        },
      );
      final uri = query.toUri('/vehicles');
      expect(uri.toString(), '/vehicles?status=active');
      expect(ListQuery.fromUri(uri), query);
      expect(ListQuery.fromUri(uri).facet('status'), 'active');
    });

    test('round-trips a multi-valued facet (e.g. product labels)', () {
      const query = ListQuery(
        facets: {
          'label': ['3', '7'],
        },
      );
      final uri = query.toUri('/products');
      expect(uri.toString(), '/products?label=3&label=7');
      final decoded = ListQuery.fromUri(uri);
      expect(decoded, query);
      expect(decoded.facetValues('label'), ['3', '7']);
    });

    test('round-trips a tri-state bool facet, all three states', () {
      const trueQuery = ListQuery(
        facets: {
          'stockable': ['true'],
        },
      );
      const falseQuery = ListQuery(
        facets: {
          'stockable': ['false'],
        },
      );
      const absentQuery = ListQuery();

      expect(ListQuery.fromUri(trueQuery.toUri('/products')), trueQuery);
      expect(ListQuery.fromUri(falseQuery.toUri('/products')), falseQuery);
      expect(absentQuery.facet('stockable'), isNull);
      expect(
        trueQuery.toUri('/products').toString() ==
            falseQuery.toUri('/products').toString(),
        isFalse,
      );
    });

    test('round-trips an ISO date facet', () {
      const query = ListQuery(
        facets: {
          'dateFrom': ['2026-07-01'],
        },
      );
      final uri = query.toUri('/exchange-rates');
      expect(uri.toString(), '/exchange-rates?dateFrom=2026-07-01');
      expect(ListQuery.fromUri(uri), query);
    });

    test('round-trips search, page, and multiple facets together', () {
      const query = ListQuery(
        search: 'north',
        pageIndex: 1,
        facets: {
          'facility': ['9'],
          'status': ['inactive'],
        },
      );
      final uri = query.toUri('/warehouses');
      expect(ListQuery.fromUri(uri), query);
    });
  });

  group('deterministic ordering', () {
    test('the same view always produces a byte-identical URL', () {
      const query = ListQuery(
        search: 'a',
        pageIndex: 2,
        facets: {
          'facility': ['9'],
          'status': ['active'],
        },
      );
      final first = query.toUri('/warehouses').toString();
      final second = query.toUri('/warehouses').toString();
      expect(first, second);
      expect(first, '/warehouses?search=a&page=3&facility=9&status=active');
    });
  });

  group('character safety (contracts/list-query.md §9)', () {
    test('accented text round-trips intact', () {
      const query = ListQuery(search: 'niño baño');
      final uri = query.toUri('/customers');
      expect(ListQuery.fromUri(uri).search, 'niño baño');
    });

    test('reserved characters (&, #, +) round-trip intact', () {
      const query = ListQuery(search: 'A&B #1 +tax');
      final uri = query.toUri('/customers');
      expect(ListQuery.fromUri(uri).search, 'A&B #1 +tax');
    });

    test('spaces round-trip intact', () {
      const query = ListQuery(search: 'Acme Corp');
      final uri = query.toUri('/suppliers');
      expect(ListQuery.fromUri(uri).search, 'Acme Corp');
    });
  });

  group('malformed input is decoded gracefully, never throws (FR-021)', () {
    test(
      'an unknown parameter is captured but ignored by any specific reader',
      () {
        final query = ListQuery.fromUri(Uri.parse('/vehicles?nonsense=1'));
        expect(query.facet('status'), isNull);
      },
    );

    test('page <= 0 falls back to page 1 (index 0)', () {
      expect(ListQuery.fromUri(Uri.parse('/vehicles?page=0')).pageIndex, 0);
      expect(ListQuery.fromUri(Uri.parse('/vehicles?page=-3')).pageIndex, 0);
    });

    test('a non-numeric page falls back to page 1 (index 0)', () {
      expect(ListQuery.fromUri(Uri.parse('/vehicles?page=bogus')).pageIndex, 0);
    });

    test('an absent page defaults to page 1 (index 0)', () {
      expect(ListQuery.fromUri(Uri.parse('/vehicles')).pageIndex, 0);
    });

    test(
      'a repeated key on what a caller treats as single-valued: first value wins',
      () {
        final query = ListQuery.fromUri(
          Uri.parse('/vehicles?status=active&status=inactive'),
        );
        expect(query.facet('status'), 'active');
        // The raw values are still all captured, for a multi-valued reader.
        expect(query.facetValues('status'), ['active', 'inactive']);
      },
    );

    test('a malformed address never throws', () {
      expect(
        () => ListQuery.fromUri(
          Uri.parse('/vehicles?status=bogus&page=999&nonsense=1'),
        ),
        returnsNormally,
      );
    });
  });

  group('isFiltered / isDefault', () {
    test('search alone is filtered', () {
      expect(const ListQuery(search: 'x').isFiltered, isTrue);
    });

    test('a facet alone is filtered', () {
      expect(
        const ListQuery(
          facets: {
            'status': ['active'],
          },
        ).isFiltered,
        isTrue,
      );
    });

    test(
      'page alone (no search, no facets) is not "filtered" but is not default either',
      () {
        const query = ListQuery(pageIndex: 1);
        expect(query.isFiltered, isFalse);
        expect(query.isDefault, isFalse);
      },
    );
  });

  group('withFacet / withFacetValues', () {
    test('withFacet adds a single-valued facet', () {
      const query = ListQuery();
      final updated = query.withFacet('facility', '9');
      expect(updated.facet('facility'), '9');
    });

    test('withFacet replaces an existing facet without disturbing others', () {
      const query = ListQuery(
        facets: {
          'facility': ['9'],
          'status': ['active'],
        },
      );
      final updated = query.withFacet('facility', '12');
      expect(updated.facet('facility'), '12');
      expect(updated.facet('status'), 'active');
    });

    test('withFacet(key, null) removes the facet', () {
      const query = ListQuery(
        facets: {
          'facility': ['9'],
        },
      );
      expect(query.withFacet('facility', null).facet('facility'), isNull);
    });

    test(
      'withFacet preserves insertion order when updating an existing key',
      () {
        const query = ListQuery(
          facets: {
            'facility': ['9'],
            'status': ['active'],
          },
        );
        final updated = query.withFacet('facility', '12');
        expect(
          updated.toUri('/warehouses').toString(),
          '/warehouses?facility=12&status=active',
        );
      },
    );

    test('withFacetValues sets a multi-valued facet', () {
      const query = ListQuery();
      final updated = query.withFacetValues('label', ['3', '7']);
      expect(updated.facetValues('label'), ['3', '7']);
    });

    test('withFacetValues([]) removes the facet', () {
      const query = ListQuery(
        facets: {
          'label': ['3', '7'],
        },
      );
      expect(
        query.withFacetValues('label', const []).facetValues('label'),
        isEmpty,
      );
    });
  });
}
