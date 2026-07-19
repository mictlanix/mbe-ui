import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_label_facet.dart';

/// Exercises `ProductRepositoryImpl.productLabelFacets` and the AND
/// ("contains all") label filter against a *real* mbe-api instance
/// (constitution §VII), covering spec 009 (Faceted Label Filtering) FR-001,
/// FR-002, FR-003, FR-004, FR-005, FR-009 and quickstart.md's US1/US2
/// scenarios — via mictlanix/mbe-api#78.
///
/// Requires mbe-api running at [apiBaseUrl] (default
/// `http://127.0.0.1:8000`) with an administrator account (full access,
/// per `.env`'s documented `MBE_ADMIN_USERNAME`/`MBE_ADMIN_PASSWORD`) and an
/// existing catalog with at least one pair of co-occurring labels.
///
/// Rather than hardcoding specific label/product ids or counts — which would
/// make the test brittle to the seeded catalog changing over time — this
/// test *discovers* a co-occurring label pair live from the facets endpoint
/// itself, then cross-checks that discovery against `list()`'s actual
/// narrowed result. This directly validates the mathematical guarantee the
/// whole feature depends on: a label present in `productLabelFacets()`'s
/// response is exactly a label that, if selected, narrows to a non-empty
/// result (FR-005) with the count it reported (FR-009); a label absent from
/// it is exactly one that would empty the results if selected (FR-004),
/// which is why the UI safely disables it.
///
/// Configure via `--dart-define` (or `--dart-define-from-file=.env`):
///   --dart-define=MBE_ADMIN_USERNAME=...
///   --dart-define=MBE_ADMIN_PASSWORD=...
///
/// All tests are skipped when credentials are not provided.
const _adminUsername = String.fromEnvironment('MBE_ADMIN_USERNAME');
const _adminPassword = String.fromEnvironment('MBE_ADMIN_PASSWORD');
const _hasAdminCredentials = _adminUsername != '' && _adminPassword != '';

void main() {
  late ProductRepositoryImpl productRepository;

  setUp(() async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUsername, password: _adminPassword);
    dio.options.headers['Authorization'] = 'Bearer $token';
    productRepository = ProductRepositoryImpl(dio);
  });

  test('productLabelFacets() with no filter reports every label present in the '
      'catalog with a positive count (FR-009 baseline)', () async {
    final facets = await productRepository.productLabelFacets();

    expect(facets, isNotEmpty, reason: 'expected a non-empty seeded catalog');
    expect(facets.every((f) => f.count > 0), isTrue);
  }, skip: !_hasAdminCredentials);

  test('a label absent from productLabelFacets(labels: [primary]) narrows '
      'list() to zero results when combined with it — the guarantee that '
      'lets the UI safely disable it (FR-004)', () async {
    final baseline = await productRepository.productLabelFacets();
    final primary = baseline.reduce((a, b) => a.count >= b.count ? a : b);

    final coOccurring = await productRepository.productLabelFacets(
      labels: [primary.labelId],
    );
    final coOccurringIds = coOccurring.map((f) => f.labelId).toSet();
    final nonCoOccurring = baseline.firstWhere(
      (f) =>
          f.labelId != primary.labelId && !coOccurringIds.contains(f.labelId),
      orElse: () => const ProductLabelFacet(labelId: -1, count: 0),
    );

    if (nonCoOccurring.labelId == -1) {
      markTestSkipped(
        'no non-co-occurring label pair found in the seeded catalog',
      );
      return;
    }

    final narrowed = await productRepository.list(
      labels: [primary.labelId, nonCoOccurring.labelId],
    );

    expect(
      narrowed.total,
      0,
      reason:
          'label ${nonCoOccurring.labelId} was absent from the facets for '
          'label ${primary.labelId}, so combining them should yield no '
          'products (AND semantics)',
    );
  }, skip: !_hasAdminCredentials);

  test('a label present in productLabelFacets(labels: [primary]) narrows '
      'list() to exactly the reported count — facets and list() agree '
      '(FR-001, FR-002, FR-005, FR-009)', () async {
    final baseline = await productRepository.productLabelFacets();
    final primary = baseline.reduce((a, b) => a.count >= b.count ? a : b);

    final coOccurring = await productRepository.productLabelFacets(
      labels: [primary.labelId],
    );
    final secondary = coOccurring.firstWhere(
      (f) => f.labelId != primary.labelId,
      orElse: () => const ProductLabelFacet(labelId: -1, count: 0),
    );

    if (secondary.labelId == -1) {
      markTestSkipped(
        'the highest-count label has no co-occurring label in the seeded '
        'catalog to narrow against',
      );
      return;
    }

    final primaryOnly = await productRepository.list(labels: [primary.labelId]);
    final narrowed = await productRepository.list(
      labels: [primary.labelId, secondary.labelId],
    );

    // AND narrows, never broadens.
    expect(narrowed.total, lessThanOrEqualTo(primaryOnly.total));
    // Selecting an "available" (facet-reported) label never empties the
    // list — the no-dead-end guarantee (FR-005).
    expect(narrowed.total, greaterThan(0));
    // The facet's reported count matches the real narrowed result exactly.
    expect(narrowed.total, secondary.count);
  }, skip: !_hasAdminCredentials);
}
