import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';

/// Direct unit coverage of the shared status-facet decode/encode helpers
/// (spec 035 FR-001/FR-002/FR-004/FR-006), used by every entity-lifecycle
/// list controller's `XFilter.fromQuery` and by each screen's status-chip
/// `onChanged` and `CatalogListStateView.isFiltered` argument. Per-screen
/// coverage of the wiring lives alongside each entity's own controller/
/// screen tests; this file is the one place the helpers' own contract is
/// pinned independent of any single entity.
void main() {
  group('decodeStatusFacet', () {
    test('an absent facet decodes to the Active default (FR-001/FR-002)', () {
      expect(decodeStatusFacet(const ListQuery()), EntityStatus.active);
    });

    test('the literal "all" decodes to null — every state (FR-004)', () {
      final query = const ListQuery(
        facets: {
          'status': ['all'],
        },
      );
      expect(decodeStatusFacet(query), isNull);
    });

    test('a recognized value decodes to that status', () {
      final query = const ListQuery(
        facets: {
          'status': ['inactive'],
        },
      );
      expect(decodeStatusFacet(query), EntityStatus.inactive);

      final archived = const ListQuery(
        facets: {
          'status': ['archived'],
        },
      );
      expect(decodeStatusFacet(archived), EntityStatus.archived);
    });

    test(
      'an unrecognized value degrades to the Active default, not a throw',
      () {
        final query = const ListQuery(
          facets: {
            'status': ['not-a-real-status'],
          },
        );
        expect(decodeStatusFacet(query), EntityStatus.active);
      },
    );

    test('honors a non-default facetKey', () {
      final query = const ListQuery(
        facets: {
          'vehicleStatus': ['all'],
        },
      );
      expect(decodeStatusFacet(query), EntityStatus.active); // wrong key
      expect(
        decodeStatusFacet(query, facetKey: 'vehicleStatus'),
        isNull,
      ); // right key
    });
  });

  group('encodeStatusFacet', () {
    test('null (the user\'s "All") writes the literal all, not an absent '
        'facet (FR-004)', () {
      final query = encodeStatusFacet(const ListQuery(), null);
      expect(query.facet('status'), 'all');
      // Round-trips back to "every state", not silently to the default.
      expect(decodeStatusFacet(query), isNull);
    });

    test('a status writes its name', () {
      final query = encodeStatusFacet(const ListQuery(), EntityStatus.inactive);
      expect(query.facet('status'), 'inactive');
      expect(decodeStatusFacet(query), EntityStatus.inactive);
    });

    test('a round trip through encode/decode is stable for every status '
        'including "all"', () {
      for (final status in [null, ...EntityStatus.values]) {
        final query = encodeStatusFacet(const ListQuery(), status);
        expect(decodeStatusFacet(query), status);
      }
    });
  });

  group('isFilteredBeyondStatusDefault (FR-003/FR-006, Edge Cases)', () {
    test('an empty query (default-applied Active) counts as filtered — the '
        'default could be hiding records the client cannot see', () {
      final query = const ListQuery();
      expect(
        isFilteredBeyondStatusDefault(query, decodeStatusFacet(query)),
        isTrue,
      );
    });

    test('an explicit status=all with nothing else does NOT count as '
        'filtered — genuinely every record is shown', () {
      final query = const ListQuery(
        facets: {
          'status': ['all'],
        },
      );
      expect(
        isFilteredBeyondStatusDefault(query, decodeStatusFacet(query)),
        isFalse,
      );
    });

    test('an explicit non-default status counts as filtered', () {
      final query = const ListQuery(
        facets: {
          'status': ['inactive'],
        },
      );
      expect(
        isFilteredBeyondStatusDefault(query, decodeStatusFacet(query)),
        isTrue,
      );
    });

    test('search text counts as filtered even with status=all', () {
      final query = const ListQuery(
        search: 'foo',
        facets: {
          'status': ['all'],
        },
      );
      expect(
        isFilteredBeyondStatusDefault(query, decodeStatusFacet(query)),
        isTrue,
      );
    });

    test('another facet counts as filtered even with status=all — the bug '
        'this helper replaces a broken `query.isFiltered` check for', () {
      final query = const ListQuery(
        facets: {
          'status': ['all'],
          'stockable': ['true'],
        },
      );
      expect(
        isFilteredBeyondStatusDefault(query, decodeStatusFacet(query)),
        isTrue,
      );
    });
  });
}
