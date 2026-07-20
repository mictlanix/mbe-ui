import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/merge_products_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockProductRepository extends Mock implements ProductRepository {}

const _canonical = ProductListItem(
  productId: 1,
  code: 'SKU-001',
  name: 'Widget',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  status: EntityStatus.active,
);

const _duplicate = ProductListItem(
  productId: 2,
  code: 'SKU-002',
  name: 'Widget (dup)',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  status: EntityStatus.active,
);

void main() {
  late MockProductRepository productRepository;

  setUp(() {
    productRepository = MockProductRepository();
    when(
      () => productRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const ProductListResult(items: [], total: 0));
  });

  /// Pumps `MergeProductsScreen` behind a real `GoRouter` (the screen calls
  /// `context.go(...)` for both the back affordance and post-success
  /// navigation) and returns the backing `ProviderContainer` so tests can
  /// drive `MergeProductsController` directly — `CatalogEntityPicker`'s
  /// `Autocomplete` overlay has no reliable way to "select" an option
  /// without a real pointer interaction in widget tests (mirrors
  /// product_detail_screen_test.dart's `pumpScreenWithContainer`).
  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepository),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/products/merge',
      routes: [
        GoRoute(
          path: '/products',
          builder: (_, _) => const Scaffold(body: Text('products-list')),
        ),
        GoRoute(
          path: '/products/merge',
          builder: (_, _) => const MergeProductsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  void select(ProviderContainer container) {
    final controller = container.read(mergeProductsControllerProvider.notifier);
    controller.canonicalSelected(_canonical);
    controller.duplicateSelected(_duplicate);
  }

  testWidgets(
    'selecting two distinct products, confirming, and merging calls the '
    'repository with the right ids, shows a success message, and returns '
    'to the products list',
    (tester) async {
      when(
        () => productRepository.mergeProducts(
          productId: any(named: 'productId'),
          duplicateId: any(named: 'duplicateId'),
        ),
      ).thenAnswer((_) async {});
      final container = await pumpScreen(tester);
      select(container);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('merge_submit_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('merge_confirm_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('merge_confirm_button')));
      await tester.pumpAndSettle();

      verify(
        () => productRepository.mergeProducts(productId: 1, duplicateId: 2),
      ).called(1);
      expect(find.text('Products merged successfully.'), findsOneWidget);
      expect(find.text('products-list'), findsOneWidget);
    },
  );

  testWidgets(
    'the in-flight merge disables the submit button and shows progress '
    '(FR-009)',
    (tester) async {
      final completer = Completer<void>();
      when(
        () => productRepository.mergeProducts(
          productId: any(named: 'productId'),
          duplicateId: any(named: 'duplicateId'),
        ),
      ).thenAnswer((_) => completer.future);
      final container = await pumpScreen(tester);
      select(container);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('merge_submit_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('merge_confirm_button')));
      await tester.pump();

      final button = tester.widget<FilledButton>(
        find.byKey(const Key('merge_submit_button')),
      );
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'the back affordance returns to the products list without merging '
    '(FR-013)',
    (tester) async {
      final container = await pumpScreen(tester);
      select(container);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('merge_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('products-list'), findsOneWidget);
      verifyNever(
        () => productRepository.mergeProducts(
          productId: any(named: 'productId'),
          duplicateId: any(named: 'duplicateId'),
        ),
      );
    },
  );

  testWidgets('cancelling the confirm dialog performs no merge and keeps both '
      'selections', (tester) async {
    final container = await pumpScreen(tester);
    select(container);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('merge_submit_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('merge_confirm_cancel_button')));
    await tester.pumpAndSettle();

    verifyNever(
      () => productRepository.mergeProducts(
        productId: any(named: 'productId'),
        duplicateId: any(named: 'duplicateId'),
      ),
    );
    final state = container.read(mergeProductsControllerProvider);
    expect(state.canonical, _canonical);
    expect(state.duplicate, _duplicate);
  });

  group('client-side guards (US3)', () {
    testWidgets(
      'the merge button is disabled and a both-required message is shown '
      'with no selections (FR-005)',
      (tester) async {
        await pumpScreen(tester);

        final button = tester.widget<FilledButton>(
          find.byKey(const Key('merge_submit_button')),
        );
        expect(button.onPressed, isNull);
        expect(
          find.byKey(const Key('merge_validation_message')),
          findsOneWidget,
        );
        expect(
          find.text('Select a product and a duplicate to continue.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'the merge button is disabled and a self-merge message is shown when '
      'both fields hold the same product (FR-006)',
      (tester) async {
        final container = await pumpScreen(tester);
        final controller = container.read(
          mergeProductsControllerProvider.notifier,
        );
        controller.canonicalSelected(_canonical);
        controller.duplicateSelected(_canonical);
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(
          find.byKey(const Key('merge_submit_button')),
        );
        expect(button.onPressed, isNull);
        expect(
          find.text("You can't merge a product with itself."),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a server rejection surfaces the error banner and preserves both '
      'selections (FR-011)',
      (tester) async {
        when(
          () => productRepository.mergeProducts(
            productId: any(named: 'productId'),
            duplicateId: any(named: 'duplicateId'),
          ),
        ).thenThrow(const AppError.notFound('Duplicate product not found'));
        final container = await pumpScreen(tester);
        select(container);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('merge_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('merge_confirm_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('merge_error_banner')), findsOneWidget);
        expect(find.text('The requested item was not found.'), findsOneWidget);
        final state = container.read(mergeProductsControllerProvider);
        expect(state.canonical, _canonical);
        expect(state.duplicate, _duplicate);
        expect(find.text('products-list'), findsNothing);
      },
    );
  });

  group('search-as-you-type (US2)', () {
    Future<void> typeAndSettle(
      WidgetTester tester,
      Key field,
      String text,
    ) async {
      await tester.enterText(
        find.descendant(
          of: find.byKey(field),
          matching: find.byType(TextFormField),
        ),
        text,
      );
      // CatalogEntityPicker debounces optionsBuilder by 300ms.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
    }

    testWidgets('a query under 3 characters does not call the repository', (
      tester,
    ) async {
      await pumpScreen(tester);

      await typeAndSettle(tester, const Key('merge_canonical_field'), 'wi');

      verifyNever(
        () => productRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      );
    });

    testWidgets(
      'a query of 3+ characters searches with deactivated: null and shows '
      'photo + code/model/SKU suggestions, including a deactivated product '
      '(spec.md Clarifications 2026-07-12; FR-003 via mbe-api#76)',
      (tester) async {
        when(
          () => productRepository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const ProductListResult(
            items: [
              ProductListItem(
                productId: 5,
                code: 'SKU-005',
                name: 'Deactivated Widget',
                model: 'M5',
                sku: 'INTERNAL-005',
                unitOfMeasurementCode: 'PCE',
                unitOfMeasurementName: 'Piece',
                taxRate: '0.16',
                status: EntityStatus.inactive,
                photo: 'http://test/widget5.png',
              ),
            ],
            total: 1,
          ),
        );
        await pumpScreen(tester);

        await typeAndSettle(
          tester,
          const Key('merge_canonical_field'),
          'widget',
        );

        verify(
          () =>
              productRepository.list(search: 'widget', status: null, limit: 15),
        ).called(1);
        expect(find.text('Deactivated Widget'), findsOneWidget);
        expect(find.text('SKU-005 · M5 · INTERNAL-005'), findsOneWidget);
      },
    );

    testWidgets(
      'omits blank subtitle parts rather than showing empty separators',
      (tester) async {
        when(
          () => productRepository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const ProductListResult(
            items: [_canonical], // no model, no sku
            total: 1,
          ),
        );
        await pumpScreen(tester);

        await typeAndSettle(
          tester,
          const Key('merge_canonical_field'),
          'widget',
        );

        expect(find.text('SKU-001'), findsOneWidget);
      },
    );

    testWidgets(
      'a search with no matches shows no suggestions (no-results, not a '
      'broken overlay)',
      (tester) async {
        await pumpScreen(tester);

        await typeAndSettle(
          tester,
          const Key('merge_canonical_field'),
          'nomatch',
        );

        expect(find.byType(ListTile), findsNothing);
      },
    );

    testWidgets(
      'selecting a suggestion is single-select and can be cleared and '
      're-searched (FR-004)',
      (tester) async {
        when(
          () => productRepository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const ProductListResult(items: [_canonical], total: 1),
        );
        final container = await pumpScreen(tester);

        await typeAndSettle(
          tester,
          const Key('merge_canonical_field'),
          'widget',
        );
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();

        expect(
          container.read(mergeProductsControllerProvider).canonical,
          _canonical,
        );

        // Clear and re-search — the field returns to empty and can be
        // searched again.
        await tester.enterText(
          find.descendant(
            of: find.byKey(const Key('merge_canonical_field')),
            matching: find.byType(TextFormField),
          ),
          '',
        );
        await typeAndSettle(
          tester,
          const Key('merge_canonical_field'),
          'widget',
        );

        expect(find.byType(ListTile), findsOneWidget);
      },
    );
  });
}
