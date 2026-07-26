import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/merge_preview.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
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

/// Full records behind [_canonical] / [_duplicate], as the review step's
/// comparison fetch returns them. They differ in brand and status so the
/// diff-flagging has something real to flag.
final _fullCanonical = Product(
  productId: 1,
  code: 'SKU-001',
  name: 'Widget',
  sku: 'SKU-001',
  brand: 'Acme',
  model: 'M1',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  taxIncluded: false,
  priceType: 0,
  currency: 0,
  minOrderQty: 1,
  stockable: false,
  perishable: false,
  seriable: false,
  purchasable: false,
  salable: false,
  invoiceable: false,
  stockRequired: false,
  status: EntityStatus.active,
);

final _fullDuplicate = Product(
  productId: 2,
  code: 'SKU-002',
  name: 'Widget (dup)',
  sku: 'SKU-002',
  brand: 'Globex',
  model: 'M1',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
  taxRate: '0.16',
  taxIncluded: false,
  priceType: 0,
  currency: 0,
  minOrderQty: 1,
  stockable: false,
  perishable: false,
  seriable: false,
  purchasable: false,
  salable: false,
  invoiceable: false,
  stockRequired: false,
  status: EntityStatus.inactive,
);

const _preview = MergePreview(
  categories: [
    MergePreviewCategory(key: 'sales_order_detail.product', count: 7),
    MergePreviewCategory(key: 'product_price.product', count: 3),
  ],
  total: 10,
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

    // The review step (specs/016) fetches each selected product in full, so
    // every test that reaches a valid pair needs both ids resolvable.
    when(
      () => productRepository.get(productId: 1),
    ).thenAnswer((_) async => _fullCanonical);
    when(
      () => productRepository.get(productId: 2),
    ).thenAnswer((_) async => _fullDuplicate);

    when(
      () => productRepository.mergePreview(
        productId: any(named: 'productId'),
        duplicateId: any(named: 'duplicateId'),
      ),
    ).thenAnswer((_) async => _preview);
  });

  /// Pumps `MergeProductsScreen` behind a real `GoRouter` (the screen calls
  /// `context.go(...)` for both the back affordance and post-success
  /// navigation) and returns the backing `ProviderContainer` so tests can
  /// drive `MergeProductsController` directly — `CatalogEntityPicker`'s
  /// `Autocomplete` overlay has no reliable way to "select" an option
  /// without a real pointer interaction in widget tests (mirrors
  /// product_detail_screen_test.dart's `pumpScreenWithContainer`).
  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    Size surface = const Size(1400, 2400),
  }) async {
    // The review step (specs/016) makes this page far taller than the 800x600
    // default surface, which puts the acknowledgment and submit controls
    // off-screen where taps silently miss. Pump a desktop-sized viewport
    // (constitution §VI's primary tier) so the whole form is hit-testable;
    // the compact-layout test overrides `surface`.
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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

  /// Selects a valid, distinct pair **and** acknowledges the deletion, so the
  /// submit button is enabled. Tests below that exercise the merge itself use
  /// this; the acknowledgment gate has its own coverage (specs/016 FR-007).
  void select(ProviderContainer container) {
    final controller = container.read(mergeProductsControllerProvider.notifier);
    controller.canonicalSelected(_canonical);
    controller.duplicateSelected(_duplicate);
    controller.acknowledgeToggled();
  }

  /// Selects a valid, distinct pair without acknowledging.
  void selectOnly(ProviderContainer container) {
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

  group('review step (specs/016 US1)', () {
    testWidgets('appears only once both selections are valid and distinct', (
      tester,
    ) async {
      final container = await pumpScreen(tester);
      expect(find.byKey(const Key('merge_kept_panel')), findsNothing);

      container
          .read(mergeProductsControllerProvider.notifier)
          .canonicalSelected(_canonical);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('merge_kept_panel')),
        findsNothing,
        reason: 'one selection is not a reviewable pair',
      );

      container
          .read(mergeProductsControllerProvider.notifier)
          .duplicateSelected(_duplicate);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('merge_kept_panel')), findsOneWidget);
      expect(find.byKey(const Key('merge_deleted_panel')), findsOneWidget);
    });

    testWidgets('labels each panel in text, not colour alone (FR-002)', (
      tester,
    ) async {
      final container = await pumpScreen(tester);
      selectOnly(container);
      await tester.pumpAndSettle();

      // SC-001: the kept/deleted distinction must survive a greyscale read,
      // so it has to be carried by words and an icon, not just hue.
      expect(find.text('Kept'), findsWidgets);
      expect(find.text('Deleted'), findsWidgets);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('strikes through the name of the product being deleted', (
      tester,
    ) async {
      final container = await pumpScreen(tester);
      selectOnly(container);
      await tester.pumpAndSettle();

      final deletedName = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('merge_deleted_panel')),
          matching: find.text(_fullDuplicate.name),
        ),
      );
      expect(deletedName.style?.decoration, TextDecoration.lineThrough);

      final keptName = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('merge_kept_panel')),
          matching: find.text(_fullCanonical.name),
        ),
      );
      expect(keptName.style?.decoration, isNot(TextDecoration.lineThrough));
    });

    testWidgets('recomputes when a selection changes rather than showing '
        'stale data (FR-010)', (tester) async {
      const third = ProductListItem(
        productId: 3,
        code: 'SKU-003',
        name: 'Third widget',
        unitOfMeasurementCode: 'PCE',
        unitOfMeasurementName: 'Piece',
        taxRate: '0.16',
        status: EntityStatus.active,
      );
      when(() => productRepository.get(productId: 3)).thenAnswer(
        (_) async => _fullCanonical.copyWith(
          productId: 3,
          code: 'SKU-003',
          name: 'Third widget',
        ),
      );

      final container = await pumpScreen(tester);
      selectOnly(container);
      await tester.pumpAndSettle();
      expect(find.text(_fullDuplicate.name), findsWidgets);

      container
          .read(mergeProductsControllerProvider.notifier)
          .duplicateSelected(third);
      await tester.pumpAndSettle();

      expect(find.text('Third widget'), findsWidgets);
      expect(
        find.descendant(
          of: find.byKey(const Key('merge_deleted_panel')),
          matching: find.text(_fullDuplicate.name),
        ),
        findsNothing,
        reason: 'the previous duplicate must not linger in the review step',
      );
    });

    testWidgets('a failed comparison fetch blocks the merge and shows an '
        'error (FR-011)', (tester) async {
      when(
        () => productRepository.get(productId: 2),
      ).thenThrow(const AppError.notFound('Product not found'));

      final container = await pumpScreen(tester);
      select(container); // selects *and* acknowledges
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('merge_comparison_error_banner')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('merge_kept_panel')), findsNothing);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('merge_submit_button')))
            .onPressed,
        isNull,
        reason: 'an acknowledged pair must still not merge on absent data',
      );
    });
  });

  group('comparison table (specs/016 US2)', () {
    testWidgets('flags only the fields that differ', (tester) async {
      final container = await pumpScreen(tester);
      selectOnly(container);
      await tester.pumpAndSettle();

      // The fixtures differ in exactly id, code, SKU, brand and status.
      expect(find.byKey(const Key('merge_diff_badge')), findsNWidgets(5));
      // Model and unit of measurement match, so their rows carry no badge.
      for (final label in ['Model', 'Unit of measurement', 'Tax rate']) {
        expect(
          find.descendant(
            of: find.byKey(Key('merge_row_$label')),
            matching: find.byKey(const Key('merge_diff_badge')),
          ),
          findsNothing,
          reason: '$label matches and must not be flagged',
        );
      }
    });

    testWidgets('renders every row unflagged when the two products match', (
      tester,
    ) async {
      when(
        () => productRepository.get(productId: 2),
      ).thenAnswer((_) async => _fullCanonical.copyWith(productId: 2));

      final container = await pumpScreen(tester);
      selectOnly(container);
      await tester.pumpAndSettle();

      // Only the internal id differs — the table must still show all 8 rows
      // rather than collapsing to "no differences".
      expect(find.byKey(const Key('merge_row_Code')), findsOneWidget);
      expect(find.byKey(const Key('merge_row_Status')), findsOneWidget);
      expect(find.byKey(const Key('merge_diff_badge')), findsOneWidget);
    });

    testWidgets('keeps kept/deleted attribution at compact width (FR-012)', (
      tester,
    ) async {
      final container = await pumpScreen(
        tester,
        surface: const Size(420, 2400),
      );
      selectOnly(container);
      await tester.pumpAndSettle();

      // Both panels and both column headers remain present and labelled;
      // nothing is dropped or hidden behind a horizontal scroll.
      expect(find.byKey(const Key('merge_kept_panel')), findsOneWidget);
      expect(find.byKey(const Key('merge_deleted_panel')), findsOneWidget);
      expect(find.text('Kept'), findsWidgets);
      expect(find.text('Deleted'), findsWidgets);
      expect(find.byType(Scrollable), findsWidgets);
    });
  });

  group('swap control (specs/016 US3)', () {
    testWidgets('exchanges which product each panel shows', (tester) async {
      final container = await pumpScreen(tester);
      selectOnly(container);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('merge_kept_panel')),
          matching: find.text(_fullCanonical.name),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('merge_swap_button')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('merge_kept_panel')),
          matching: find.text(_fullDuplicate.name),
        ),
        findsOneWidget,
        reason: 'the former duplicate is now the surviving record',
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('merge_deleted_panel')),
          matching: find.text(_fullCanonical.name),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a merge after a swap submits the post-swap roles', (
      tester,
    ) async {
      when(
        () => productRepository.mergeProducts(
          productId: any(named: 'productId'),
          duplicateId: any(named: 'duplicateId'),
        ),
      ).thenAnswer((_) async {});

      final container = await pumpScreen(tester);
      selectOnly(container);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('merge_swap_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('merge_acknowledge_checkbox')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('merge_submit_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('merge_confirm_button')));
      await tester.pumpAndSettle();

      // Ids are reversed relative to the pre-swap pairing (1 kept, 2 deleted).
      verify(
        () => productRepository.mergeProducts(productId: 2, duplicateId: 1),
      ).called(1);
    });
  });

  group('blast-radius summary (specs/016 US5)', () {
    testWidgets('shows the categories and total for the doomed product', (
      tester,
    ) async {
      final container = await pumpScreen(tester);
      selectOnly(container);
      await tester.pumpAndSettle();

      expect(find.text('Sales order lines'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('merge_related_total'))).data,
        '10',
      );
      // The preview is asked about the pair actually on screen.
      verify(
        () => productRepository.mergePreview(productId: 1, duplicateId: 2),
      ).called(1);
    });

    testWidgets('a failed preview omits the summary without blocking the '
        'merge (Story 5 #4)', (tester) async {
      when(
        () => productRepository.mergePreview(
          productId: any(named: 'productId'),
          duplicateId: any(named: 'duplicateId'),
        ),
      ).thenThrow(const AppError.network());

      final container = await pumpScreen(tester);
      select(container); // selects and acknowledges
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('merge_related_total')), findsNothing);
      expect(find.text('Sales order lines'), findsNothing);
      // Crucially different from a comparison failure: this one must not
      // stop the operator from merging.
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('merge_submit_button')))
            .onPressed,
        isNotNull,
        reason: 'an informational count must never gate the merge',
      );
      expect(find.byKey(const Key('merge_kept_panel')), findsOneWidget);
    });

    testWidgets('the confirmation dialog carries the total when loaded', (
      tester,
    ) async {
      final container = await pumpScreen(tester);
      select(container);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('merge_submit_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('merge_confirm_total_line')),
        findsOneWidget,
      );
      expect(find.text('Records that will move: 10.'), findsOneWidget);
      // Both records restated by name *and* code (FR-009).
      expect(
        find.textContaining('"${_fullCanonical.name}" (${_fullCanonical.code})'),
        findsOneWidget,
      );
      expect(
        find.textContaining('"${_fullDuplicate.name}" (${_fullDuplicate.code})'),
        findsOneWidget,
      );
    });

    testWidgets('the dialog omits the total line when the preview failed', (
      tester,
    ) async {
      when(
        () => productRepository.mergePreview(
          productId: any(named: 'productId'),
          duplicateId: any(named: 'duplicateId'),
        ),
      ).thenThrow(const AppError.network());

      final container = await pumpScreen(tester);
      select(container);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('merge_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('merge_confirm_button')), findsOneWidget);
      expect(find.byKey(const Key('merge_confirm_total_line')), findsNothing);
    });
  });

  group('acknowledgment gate (specs/016 US4)', () {
    testWidgets(
      'a valid pair alone does not enable the merge — the acknowledgment '
      'must be checked first (FR-007)',
      (tester) async {
        final container = await pumpScreen(tester);
        selectOnly(container);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('merge_acknowledge_checkbox')),
          findsOneWidget,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('merge_submit_button')),
              )
              .onPressed,
          isNull,
          reason: 'unacknowledged pair must not be submittable',
        );

        await tester.tap(find.byKey(const Key('merge_acknowledge_checkbox')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('merge_submit_button')),
              )
              .onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'the acknowledgment names the product actually marked for deletion',
      (tester) async {
        final container = await pumpScreen(tester);
        selectOnly(container);
        await tester.pumpAndSettle();

        expect(
          find.text('I understand "${_duplicate.name}" will be permanently '
              'deleted.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('swapping resets the acknowledgment and re-locks submit '
        '(FR-008)', (tester) async {
      final container = await pumpScreen(tester);
      select(container); // selects and acknowledges
      await tester.pumpAndSettle();

      container.read(mergeProductsControllerProvider.notifier).swap();
      await tester.pumpAndSettle();

      final state = container.read(mergeProductsControllerProvider);
      expect(state.acknowledged, isFalse);
      expect(state.canonical, _duplicate);
      expect(state.duplicate, _canonical);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('merge_submit_button')))
            .onPressed,
        isNull,
        reason: 'a stale acknowledgment must not survive a role swap',
      );
      // The label now names the other product — the one newly at risk.
      expect(
        find.text('I understand "${_canonical.name}" will be permanently '
            'deleted.'),
        findsOneWidget,
      );
    });
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
        expect(
          find.text('Code: SKU-005 · Model: M5 · SKU: INTERNAL-005'),
          findsOneWidget,
        );
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

        // Only the code is present, so no dangling separators.
        expect(find.text('Code: SKU-001'), findsOneWidget);
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
