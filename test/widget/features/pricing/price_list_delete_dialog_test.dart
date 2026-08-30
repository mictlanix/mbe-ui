import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list_delete_preview.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_delete_dialog.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockPriceListRepository extends Mock implements PriceListRepository {}

const _priceList = PriceList(priceListId: 7, name: 'Retail 2026');

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.priceLists, rawValue: 15)],
);

void main() {
  late MockPriceListRepository repository;
  late ProviderContainer container;
  PriceListDeleteOutcome? outcome;
  var outcomeCaptured = false;

  setUp(() async {
    repository = MockPriceListRepository();
    when(
      () => repository.get(priceListId: _priceList.priceListId),
    ).thenAnswer((_) async => _priceList);

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        priceListRepositoryProvider.overrideWithValue(repository),
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(token: 't', user: _fullAccessUser),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // The dialog's `delete()` call goes through
    // `priceListFormControllerProvider`, the same instance the detail
    // screen's `initState` would already have loaded — a standalone dialog
    // test must seed it the same way, or `delete()` no-ops on a null
    // `priceListId` (research.md R7's reuse of the existing controller).
    await container
        .read(priceListFormControllerProvider.notifier)
        .loadForEdit(_priceList.priceListId);

    outcome = null;
    outcomeCaptured = false;
  });

  Future<void> pump(WidgetTester tester, {TextSizeLevel? textSizeLevel}) async {
    // A real GoRouter, not a bare MaterialApp — the customers-row link
    // (FR-006) calls context.go('/customers?priceList=<id>'), and the
    // '/customers' stub route below lets a test assert the target it
    // actually navigated to.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  outcome = await showPriceListDeleteDialog(
                    context,
                    priceList: _priceList,
                  );
                  outcomeCaptured = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/customers',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
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
          // Mirrors app.dart's own ComposedTextScaler wiring (constitution
          // §V's four text-size levels), so a test can exercise the dialog
          // at the largest one exactly as the running app would apply it.
          builder: textSizeLevel == null
              ? null
              : (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: ComposedTextScaler(
                      platform: MediaQuery.textScalerOf(context),
                      level: textSizeLevel,
                    ),
                  ),
                  child: child!,
                ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    // Not pumpAndSettle: the loading skeleton and the in-flight confirm
    // button both carry an indefinitely-animating CircularProgressIndicator
    // by design in some of these tests, which pumpAndSettle would hang on
    // forever. A bounded pump opens the dialog and lets its own entrance
    // transition finish; callers that expect the preview to have resolved
    // add their own pumpAndSettle afterwards.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('loading state (FR-007)', () {
    testWidgets('shows a skeleton and keeps the confirm action unavailable', (
      tester,
    ) async {
      final neverCompletes = Completer<PriceListDeletePreview>();
      when(
        () => repository.deletePreview(priceListId: _priceList.priceListId),
      ).thenAnswer((_) => neverCompletes.future);

      await pump(tester);

      expect(find.byKey(const Key('price_list_delete_loading')), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('price_list_delete_confirm')),
            )
            .onPressed,
        isNull,
      );
    });
  });

  group('clean state (FR-008)', () {
    testWidgets(
      'shows a plain note with no breakdown, picker, or acknowledgment, '
      'and the confirm action is available with no ack required',
      (tester) async {
        when(
          () => repository.deletePreview(priceListId: _priceList.priceListId),
        ).thenAnswer(
          (_) async => const PriceListDeletePreview(categories: [], total: 0),
        );

        await pump(tester);

        expect(
          find.byKey(const Key('price_list_delete_clean_note')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('price_list_delete_summary')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('price_list_delete_acknowledge')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('price_list_delete_replacement')),
          findsNothing,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNotNull,
        );
        expect(find.text('Delete list'), findsOneWidget);
      },
    );
  });

  group('priced state (US1, US3)', () {
    setUp(() {
      when(
        () => repository.deletePreview(priceListId: _priceList.priceListId),
      ).thenAnswer(
        (_) async => const PriceListDeletePreview(
          categories: [
            PriceListDeleteCategory(key: 'product_price.list', count: 4312),
          ],
          total: 4312,
        ),
      );
    });

    testWidgets(
      'the confirm button names the destroyed prices and is disabled until '
      'acknowledged',
      (tester) async {
        await pump(tester);

        expect(find.text('Delete list and 4,312 prices'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNull,
        );

        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNotNull,
        );

        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNull,
          reason: 'unticking re-disables the confirm action',
        );
      },
    );

    testWidgets('shows no replacement picker (FR-013 first clause)', (
      tester,
    ) async {
      await pump(tester);

      expect(
        find.byKey(const Key('price_list_delete_replacement')),
        findsNothing,
      );
    });

    testWidgets(
      'confirming sends the deletion with replacement omitted '
      '(FR-013 second clause)',
      (tester) async {
        when(
          () => repository.delete(priceListId: _priceList.priceListId),
        ).thenAnswer((_) async {});

        await pump(tester);
        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('price_list_delete_confirm')));
        await tester.pumpAndSettle();

        verify(
          () => repository.delete(priceListId: _priceList.priceListId),
        ).called(1);
        expect(outcomeCaptured, isTrue);
        expect(outcome, isNotNull);
        expect(outcome!.movedCount, 0);
        expect(outcome!.replacementName, isNull);
      },
    );

    testWidgets(
      'the in-flight state shows progress and disables both confirm and '
      'Cancel (FR-016)',
      (tester) async {
        final pendingDelete = Completer<void>();
        when(
          () => repository.delete(priceListId: _priceList.priceListId),
        ).thenAnswer((_) => pendingDelete.future);

        await pump(tester);
        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('price_list_delete_confirm')));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsWidgets);
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNull,
        );
        expect(
          tester.widget<TextButton>(find.widgetWithText(TextButton, 'Cancel')).onPressed,
          isNull,
        );

        pendingDelete.complete();
        await tester.pumpAndSettle();
      },
    );
  });

  group('assigned state (US2)', () {
    setUp(() {
      when(
        () => repository.deletePreview(priceListId: _priceList.priceListId),
      ).thenAnswer(
        (_) async => const PriceListDeletePreview(
          categories: [
            PriceListDeleteCategory(key: 'customer.price_list', count: 12),
          ],
          total: 12,
        ),
      );
    });

    const wholesale = PriceList(priceListId: 3, name: 'Wholesale');
    const distributor = PriceList(priceListId: 4, name: 'Distributor');

    testWidgets(
      'the list being deleted is never offered as its own replacement '
      '(FR-010), and the confirm gate holds until one is chosen (FR-009)',
      (tester) async {
        when(() => repository.list(search: null)).thenAnswer(
          (_) async => PriceListResult(
            items: const [wholesale, distributor, _priceList],
            total: 3,
          ),
        );

        await pump(tester);
        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Delete list and move 12 customers'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNull,
          reason: 'no replacement chosen yet',
        );

        await tester.tap(find.byKey(const Key('price_list_delete_replacement')));
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('Wholesale'), findsOneWidget);
        expect(find.text('Distributor'), findsOneWidget);
        expect(
          find.text('Retail 2026'),
          findsNothing,
          reason: 'the list being deleted must not be its own replacement',
        );

        await tester.tap(find.text('Wholesale'));
        await tester.pumpAndSettle();

        expect(
          find.text('All 12 customers move to Wholesale.'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'confirming sends the chosen replacement and the outcome reports the '
      'move',
      (tester) async {
        when(() => repository.list(search: null)).thenAnswer(
          (_) async => PriceListResult(items: const [wholesale], total: 1),
        );
        when(
          () => repository.delete(priceListId: _priceList.priceListId, replacement: 3),
        ).thenAnswer((_) async {});

        await pump(tester);
        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('price_list_delete_replacement')));
        await tester.pump(const Duration(milliseconds: 350));
        await tester.tap(find.text('Wholesale'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('price_list_delete_confirm')));
        await tester.pumpAndSettle();

        verify(
          () => repository.delete(
            priceListId: _priceList.priceListId,
            replacement: 3,
          ),
        ).called(1);
        expect(outcome!.movedCount, 12);
        expect(outcome!.replacementName, 'Wholesale');
      },
    );
  });

  group('customers row navigation (FR-006)', () {
    testWidgets(
      'tapping the customers row closes the dialog and navigates to the '
      'filtered customers list',
      (tester) async {
        when(
          () => repository.deletePreview(priceListId: _priceList.priceListId),
        ).thenAnswer(
          (_) async => const PriceListDeletePreview(
            categories: [
              PriceListDeleteCategory(key: 'customer.price_list', count: 12),
            ],
            total: 12,
          ),
        );

        await pump(tester);
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('price_list_delete_customers_link')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('price_list_delete_dialog')),
          findsNothing,
        );
        expect(find.text('/customers?priceList=7'), findsOneWidget);
      },
    );
  });

  group('blocked state (US4, FR-018)', () {
    testWidgets(
      'shows the blocked banner, marks the blocking row, and offers only '
      'Close — no confirm button, no acknowledgment, no replacement picker',
      (tester) async {
        when(
          () => repository.deletePreview(priceListId: _priceList.priceListId),
        ).thenAnswer(
          (_) async => const PriceListDeletePreview(
            categories: [
              PriceListDeleteCategory(key: 'product_price.list', count: 4312),
              PriceListDeleteCategory(key: 'sales_order.price_list', count: 38),
            ],
            total: 4350,
          ),
        );

        await pump(tester);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('price_list_delete_blocked_banner')),
          findsOneWidget,
        );
        expect(find.text('(blocks deletion — clear these first)'), findsOneWidget);
        expect(
          find.byKey(const Key('price_list_delete_confirm')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('price_list_delete_acknowledge')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('price_list_delete_replacement')),
          findsNothing,
        );
        expect(find.text('Close'), findsOneWidget);
        // The lead line ("will be permanently deleted") would contradict
        // the banner directly above it, so it is suppressed here.
        expect(find.textContaining('will be permanently deleted'), findsNothing);

        verifyNever(
          () => repository.delete(
            priceListId: any(named: 'priceListId'),
            replacement: any(named: 'replacement'),
          ),
        );
      },
    );
  });

  group('refusal path (US4, FR-019)', () {
    testWidgets(
      'a rejected deletion keeps the dialog open, shows the server\'s own '
      'sentence, and preserves the chosen replacement',
      (tester) async {
        when(
          () => repository.deletePreview(priceListId: _priceList.priceListId),
        ).thenAnswer(
          (_) async => const PriceListDeletePreview(
            categories: [
              PriceListDeleteCategory(key: 'customer.price_list', count: 12),
            ],
            total: 12,
          ),
        );
        const wholesale = PriceList(priceListId: 3, name: 'Wholesale');
        when(() => repository.list(search: null)).thenAnswer(
          (_) async => PriceListResult(items: const [wholesale], total: 1),
        );
        when(
          () => repository.delete(
            priceListId: _priceList.priceListId,
            replacement: 3,
          ),
        ).thenThrow(
          const AppError.server(
            statusCode: 409,
            message:
                'Still referenced by sales_order.price_list (38) — remove '
                'those records first',
          ),
        );

        await pump(tester);
        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('price_list_delete_replacement')));
        await tester.pump(const Duration(milliseconds: 350));
        await tester.tap(find.text('Wholesale'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('price_list_delete_confirm')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('price_list_delete_dialog')),
          findsOneWidget,
          reason: 'the dialog stays open on a refusal',
        );
        expect(
          find.textContaining(
            'Still referenced by sales_order.price_list (38)',
          ),
          findsOneWidget,
        );
        // The chosen replacement is preserved, so retrying doesn't require
        // re-picking it.
        expect(find.text('Wholesale'), findsOneWidget);
        expect(outcomeCaptured, isFalse);
      },
    );
  });

  group('previewFailed state (US5, FR-020)', () {
    setUp(() {
      when(
        () => repository.deletePreview(priceListId: _priceList.priceListId),
      ).thenThrow(const AppError.server(statusCode: 503));
    });

    testWidgets(
      'shows the degraded note, an optional replacement picker, and still '
      'allows confirming once acknowledged',
      (tester) async {
        const wholesale = PriceList(priceListId: 3, name: 'Wholesale');
        when(() => repository.list(search: null)).thenAnswer(
          (_) async => PriceListResult(items: const [wholesale], total: 1),
        );

        await pump(tester);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('price_list_delete_preview_failed_note')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('price_list_delete_replacement')),
          findsOneWidget,
        );
        expect(
          find.text('Optional — used only if customers turn out to be '
              'assigned.'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNull,
          reason: 'the acknowledgment is still required (FR-014)',
        );

        // The extra note+optional-picker content in this state can push the
        // checkbox below the dialog's visible viewport on the test surface.
        await tester.ensureVisible(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('price_list_delete_confirm')),
              )
              .onPressed,
          isNotNull,
          reason: 'no replacement is required when the preview never loaded',
        );
      },
    );

    testWidgets(
      'a subsequent server refusal still renders via ErrorBanner',
      (tester) async {
        when(
          () => repository.delete(priceListId: _priceList.priceListId),
        ).thenThrow(
          const AppError.server(
            statusCode: 409,
            message:
                'Still referenced by customer.price_list (12) — remove '
                'those records first',
          ),
        );

        await pump(tester);
        await tester.ensureVisible(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.tap(
          find.byKey(const Key('price_list_delete_acknowledge')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('price_list_delete_confirm')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('price_list_delete_dialog')),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Still referenced by customer.price_list (12)',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('largest text size (constitution §V, quickstart.md step 15)', () {
    testWidgets(
      'the assigned state — its densest content: lead line, breakdown, '
      'picker, and acknowledgment all at once — renders with no overflow '
      'at TextSizeLevel.extraLarge on a supported desktop width',
      (tester) async {
        when(
          () => repository.deletePreview(priceListId: _priceList.priceListId),
        ).thenAnswer(
          (_) async => const PriceListDeletePreview(
            categories: [
              PriceListDeleteCategory(key: 'product_price.list', count: 4312),
              PriceListDeleteCategory(key: 'customer.price_list', count: 12),
            ],
            total: 4324,
          ),
        );
        when(() => repository.list(search: null)).thenAnswer(
          (_) async => const PriceListResult(items: [], total: 0),
        );

        await pump(tester, textSizeLevel: TextSizeLevel.extraLarge);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
