import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/quote_email.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_header_panel.dart';
import 'package:mbe_ui/features/sales/presentation/sales_quote_write_scope.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../golden/golden_harness.dart' show loadGoldenFonts;
import '../../../unit/core/documents/document_fakes.dart';
import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Reads sales quotes: may open the quote document.
const _readerUser = User(
  userId: 'quote-reader',
  email: 'quote-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesQuotes, rawValue: 2)],
);

/// Updates but does not read: the quote screen's existing tests' user.
const _updaterOnlyUser = User(
  userId: 'quote-updater',
  email: 'quote-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesQuotes, rawValue: 4)],
);

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'FERRETERÍA LOS PINOS',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// Spec 053 US1: "Ver cotización" in the quote header.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockSalesQuoteRepository salesQuotes;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late FakeDocumentSource source;
  late FakeDocumentOutput output;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    salesQuotes = MockSalesQuoteRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    source = FakeDocumentSource();
    output = FakeDocumentOutput();

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () =>
          payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
  });

  void stubQuote(SaleStatus status, {bool hasExpired = false}) {
    when(() => salesQuotes.getById(quoteId: 42)).thenAnswer(
      (_) async => testQuote(
        id: 42,
        serial: 1001,
        status: status,
        lines: [testQuoteLine()],
        hasExpired: hasExpired,
      ),
    );
  }

  Future<ProviderContainer> pumpQuote(
    WidgetTester tester, {
    User user = _readerUser,
    Size? surface,
  }) async {
    final (_, container) = await pumpQuotesRouted(
      tester,
      surface: surface ?? const Size(1200, 2400),
      initialLocation: '/sales/quotes/42',
      overrides: [
        authProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user),
          ),
        ),
        salesOrderOverride(salesOrders),
        salesQuoteOverride(salesQuotes),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
        documentSourceProvider.overrideWithValue(source),
        documentOutputProvider.overrideWithValue(output),
      ],
    );
    return container;
  }

  final button = find.byKey(const Key('sales_quote_view_document_button'));

  group('availability (FR-001, FR-016)', () {
    for (final status in [
      SaleStatus.draft,
      SaleStatus.completed,
      SaleStatus.cancelled,
    ]) {
      testWidgets('is offered for a quote that is $status', (tester) async {
        stubQuote(status);
        await pumpQuote(tester);

        expect(button, findsOneWidget);
        expect(find.text('Ver cotización'), findsOneWidget);
      });
    }

    testWidgets('is absent — not disabled — without sales-quotes read', (
      tester,
    ) async {
      stubQuote(SaleStatus.draft);
      await pumpQuote(tester, user: _updaterOnlyUser);

      expect(button, findsNothing);
      // The disclosure toggle is still there: only the document action is
      // gated.
      expect(
        find.byKey(const Key('sales_quote_more_details_toggle')),
        findsOneWidget,
      );
    });

    testWidgets('is a body action inside the header panel, never in the app '
        'bar (constitution §VI)', (tester) async {
      stubQuote(SaleStatus.draft);
      await pumpQuote(tester);

      expect(
        find.descendant(of: find.byType(QuoteHeaderPanel), matching: button),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(AppBar), matching: button),
        findsNothing,
      );
    });
  });

  group('opening it (FR-002, FR-003)', () {
    testWidgets('with nothing pending or unconfirmed, opens the quote in the '
        'preview at once', (tester) async {
      stubQuote(SaleStatus.completed);
      await pumpQuote(tester);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched, hasLength(1));
      expect(source.fetched.single.kind, DocumentKind.salesQuote);
      expect(source.fetched.single.recordId, 42);
      expect(source.fetched.single.title, 'Cotización · 00000042');
    });

    testWidgets('a cancelled quote opens too (any state)', (tester) async {
      stubQuote(SaleStatus.cancelled);
      await pumpQuote(tester);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched.single.kind, DocumentKind.salesQuote);
    });
  });

  group('a document that cannot be fetched (US1-4)', () {
    testWidgets('shows the preview\'s error state with retry, and closing it '
        'leaves the quote screen unchanged', (tester) async {
      stubQuote(SaleStatus.completed);
      var attempts = 0;
      source.handler = (ref) async {
        attempts++;
        throw const AppError.server(statusCode: 500, message: 'boom');
      };
      await pumpQuote(tester);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text(l10n.documentLoadFailedError), findsOneWidget);
      expect(find.byKey(const Key('document_preview_retry')), findsOneWidget);
      expect(attempts, 1);

      await tester.tap(find.byKey(const Key('document_preview_retry')));
      await tester.pumpAndSettle();
      expect(attempts, 2, reason: 'retry fetches again');

      await tester.tap(find.byKey(const Key('document_preview_close')));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(find.byType(QuoteHeaderPanel), findsOneWidget);
      expect(button, findsOneWidget);
    });
  });

  group('edits still being saved (FR-005)', () {
    testWidgets('is disabled while a write is pending, and enabled again '
        'when it lands', (tester) async {
      stubQuote(SaleStatus.draft);
      final container = await pumpQuote(tester);
      final writes = container.read(
        pendingWritesProvider(salesQuoteWritesScope).notifier,
      );
      expect(tester.widget<OutlinedButton>(button).onPressed, isNotNull);

      final hold = writes.begin();
      await tester.pump();
      expect(tester.widget<OutlinedButton>(button).onPressed, isNull);

      writes.end(hold);
      await tester.pump();
      expect(tester.widget<OutlinedButton>(button).onPressed, isNotNull);
    });
  });

  group('unconfirmed typed text (FR-005)', () {
    late int confirmed;
    late int discarded;
    late int resumed;

    setUp(() {
      confirmed = discarded = resumed = 0;
    });

    /// Registers a field holding text the user typed and did not confirm.
    void registerUnconfirmedEdit(ProviderContainer container) {
      container
          .read(unconfirmedEditsProvider(salesQuoteWritesScope).notifier)
          .put(
            UnconfirmedEdit(
              id: 'comment',
              text: 'Entregar por la tarde',
              confirm: () async {
                confirmed++;
                return true;
              },
              discard: () => discarded++,
              resume: () => resumed++,
            ),
          );
    }

    testWidgets('asks first, using the screen\'s existing prompt', (
      tester,
    ) async {
      stubQuote(SaleStatus.draft);
      final container = await pumpQuote(tester);
      registerUnconfirmedEdit(container);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text(l10n.posUnconfirmedChangesTitle), findsOneWidget);
      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(source.fetched, isEmpty, reason: 'nothing is fetched until asked');
    });

    testWidgets('"Seguir editando" cancels: no preview, no fetch, and the '
        'draft is kept', (tester) async {
      stubQuote(SaleStatus.draft);
      final container = await pumpQuote(tester);
      registerUnconfirmedEdit(container);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesKeepEditing));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(source.fetched, isEmpty);
      expect(resumed, 1);
      expect(confirmed, 0);
      expect(discarded, 0);
    });

    testWidgets('"Conservar" saves the text first, then opens the quote', (
      tester,
    ) async {
      stubQuote(SaleStatus.draft);
      final container = await pumpQuote(tester);
      registerUnconfirmedEdit(container);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
      await tester.pumpAndSettle();

      expect(confirmed, 1);
      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched.single.recordId, 42);
    });

    testWidgets('"Descartar" drops the text, then opens the quote', (
      tester,
    ) async {
      stubQuote(SaleStatus.draft);
      final container = await pumpQuote(tester);
      registerUnconfirmedEdit(container);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesDiscard));
      await tester.pumpAndSettle();

      expect(discarded, 1);
      expect(confirmed, 0);
      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
    });

    testWidgets('a failed "Conservar" (the server refused the text) does not '
        'open the quote', (tester) async {
      stubQuote(SaleStatus.draft);
      final container = await pumpQuote(tester);
      container
          .read(unconfirmedEditsProvider(salesQuoteWritesScope).notifier)
          .put(
            UnconfirmedEdit(
              id: 'comment',
              text: 'x',
              confirm: () async => false,
              discard: () {},
              resume: () {},
            ),
          );

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(source.fetched, isEmpty);
    });
  });

  // ---------------------------------------------------------------- US2
  const wide = Size(1200, 2400);
  const compact = Size(500, 1600);
  final emailButton = find.byKey(const Key('sales_quote_email_button'));
  final toggle = find.byKey(const Key('sales_quote_more_details_toggle'));
  final moreActions = find.byKey(const Key('sales_quote_more_actions_button'));
  final viewItem = find.byKey(const Key('sales_quote_view_document_menu_item'));
  final emailItem = find.byKey(const Key('sales_quote_email_menu_item'));
  final emailDialog = find.byKey(const Key('quote_email_dialog'));
  final juanChip = find.byKey(const Key('quote_email_chip_juan@lapaz.mx'));
  final sendButton = find.byKey(const Key('quote_email_send_button'));
  final cancelButton = find.byKey(const Key('quote_email_cancel_button'));

  void stubCustomerWithContact() {
    when(() => customers.get(customerId: any(named: 'customerId'))).thenAnswer(
      (_) async => _customer().copyWith(
        contacts: const [
          Contact(contactId: 1, name: 'Juan Pérez', email: 'juan@lapaz.mx'),
        ],
      ),
    );
  }

  QuoteEmailReceipt receipt() => QuoteEmailReceipt(
    recipients: const ['juan@lapaz.mx'],
    sentAt: DateTime(2026, 10, 24),
  );

  group('"Enviar por correo" availability (FR-006)', () {
    for (final (status, expired) in [
      (SaleStatus.completed, false),
      (SaleStatus.completed, true),
    ]) {
      testWidgets('is offered for a confirmed quote (expired: $expired)', (
        tester,
      ) async {
        stubQuote(status, hasExpired: expired);
        await pumpQuote(tester);

        expect(emailButton, findsOneWidget);
        expect(find.text('Enviar por correo'), findsOneWidget);
      });
    }

    for (final status in [SaleStatus.draft, SaleStatus.cancelled]) {
      testWidgets('is absent for a quote that is $status', (tester) async {
        stubQuote(status);
        await pumpQuote(tester);

        expect(emailButton, findsNothing);
      });
    }

    testWidgets('is absent without sales-quotes read', (tester) async {
      stubQuote(SaleStatus.completed);
      await pumpQuote(tester, user: _updaterOnlyUser);

      expect(emailButton, findsNothing);
      expect(button, findsNothing);
    });

    testWidgets('is inside the header panel, never in the app bar', (
      tester,
    ) async {
      stubQuote(SaleStatus.completed);
      await pumpQuote(tester);

      expect(
        find.descendant(
          of: find.byType(QuoteHeaderPanel),
          matching: emailButton,
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(AppBar), matching: emailButton),
        findsNothing,
      );
    });
  });

  group('sending (FR-012)', () {
    testWidgets('a successful send closes the dialog and confirms in a '
        'snackbar', (tester) async {
      stubQuote(SaleStatus.completed);
      stubCustomerWithContact();
      when(
        () => salesQuotes.email(
          quoteId: 42,
          recipients: any(named: 'recipients'),
        ),
      ).thenAnswer((_) async => receipt());
      await pumpQuote(tester);

      await tester.tap(emailButton);
      await tester.pumpAndSettle();
      expect(emailDialog, findsOneWidget);

      await tester.tap(juanChip);
      await tester.pumpAndSettle();
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      verify(
        () => salesQuotes.email(quoteId: 42, recipients: ['juan@lapaz.mx']),
      ).called(1);
      expect(emailDialog, findsNothing);
      expect(
        find.text(l10n.salesQuoteEmailSentMessage('juan@lapaz.mx')),
        findsOneWidget,
      );
    });

    testWidgets('a 409 says the quote is not sendable, and closing the dialog '
        're-reads the quote: now cancelled, no email action', (tester) async {
      stubCustomerWithContact();
      var reads = 0;
      when(() => salesQuotes.getById(quoteId: 42)).thenAnswer((_) async {
        reads++;
        return testQuote(
          id: 42,
          serial: 1001,
          status: reads == 1 ? SaleStatus.completed : SaleStatus.cancelled,
          lines: [testQuoteLine()],
        );
      });
      when(
        () => salesQuotes.email(
          quoteId: 42,
          recipients: any(named: 'recipients'),
        ),
      ).thenThrow(const AppError.server(statusCode: 409, message: 'conflict'));
      await pumpQuote(tester);
      expect(reads, 1);

      await tester.tap(emailButton);
      await tester.pumpAndSettle();
      await tester.tap(juanChip);
      await tester.pumpAndSettle();
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(find.text(l10n.salesQuoteEmailNotSendable), findsOneWidget);
      expect(emailDialog, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(emailDialog, findsNothing);
      expect(reads, 2);
      expect(find.text('Cancelada'), findsOneWidget);
      expect(emailButton, findsNothing);
    });
  });

  group('compact tier (FR-015a)', () {
    testWidgets('the document actions sit behind one overflow menu', (
      tester,
    ) async {
      stubQuote(SaleStatus.completed);
      await pumpQuote(tester, surface: compact);

      expect(toggle, findsOneWidget);
      expect(moreActions, findsOneWidget);
      expect(button, findsNothing);
      expect(emailButton, findsNothing);

      await tester.tap(moreActions);
      await tester.pumpAndSettle();
      expect(viewItem, findsOneWidget);
      expect(emailItem, findsOneWidget);
    });

    testWidgets('a draft lists only "Ver cotización"', (tester) async {
      stubQuote(SaleStatus.draft);
      await pumpQuote(tester, surface: compact);

      await tester.tap(moreActions);
      await tester.pumpAndSettle();
      expect(viewItem, findsOneWidget);
      expect(emailItem, findsNothing);
    });

    testWidgets('the "Ver cotización" item opens the quote preview', (
      tester,
    ) async {
      stubQuote(SaleStatus.completed);
      await pumpQuote(tester, surface: compact);

      await tester.tap(moreActions);
      await tester.pumpAndSettle();
      await tester.tap(viewItem);
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched.single.kind, DocumentKind.salesQuote);
    });

    testWidgets('the "Enviar por correo" item opens the email dialog', (
      tester,
    ) async {
      stubQuote(SaleStatus.completed);
      stubCustomerWithContact();
      await pumpQuote(tester, surface: compact);

      await tester.tap(moreActions);
      await tester.pumpAndSettle();
      await tester.tap(emailItem);
      await tester.pumpAndSettle();

      expect(emailDialog, findsOneWidget);
    });

    testWidgets('without sales-quotes read there is no overflow trigger', (
      tester,
    ) async {
      stubQuote(SaleStatus.completed);
      await pumpQuote(tester, user: _updaterOnlyUser, surface: compact);

      expect(moreActions, findsNothing);
      expect(toggle, findsOneWidget);
    });

    testWidgets('the "Ver cotización" item is disabled while a write is '
        'pending', (tester) async {
      stubQuote(SaleStatus.completed);
      final container = await pumpQuote(tester, surface: compact);
      final writes = container.read(
        pendingWritesProvider(salesQuoteWritesScope).notifier,
      );
      await tester.tap(moreActions);
      await tester.pumpAndSettle();
      expect(tester.widget<MenuItemButton>(viewItem).onPressed, isNotNull);

      final hold = writes.begin();
      await tester.pump();
      expect(tester.widget<MenuItemButton>(viewItem).onPressed, isNull);

      writes.end(hold);
      await tester.pump();
      expect(tester.widget<MenuItemButton>(viewItem).onPressed, isNotNull);
    });
  });

  group('header band measurements (constitution §VI)', () {
    // Whether the controls fit on one line depends on real glyph widths; the
    // test font draws every glyph a full em wide and overstates them by more
    // than half. This group is the file's last, so loading the app font here
    // changes no earlier test.
    setUpAll(loadGoldenFonts);

    testWidgets('wide: the three controls share a vertical center and the '
        'band is symmetric in the card', (tester) async {
      stubQuote(SaleStatus.completed);
      await pumpQuote(tester, surface: wide);

      final controls = [button, emailButton, toggle];
      final centers = [for (final c in controls) tester.getCenter(c).dy];
      expect(centers[1], closeTo(centers[0], 1));
      expect(centers[2], closeTo(centers[0], 1));

      final card = find.ancestor(
        of: find.byType(FactStripRow),
        matching: find.byType(Card),
      );
      final above =
          controls.map((c) => tester.getTopLeft(c).dy).reduce(min) -
          tester.getTopLeft(card.first).dy;
      final below =
          tester.getBottomLeft(card.first).dy -
          controls.map((c) => tester.getBottomLeft(c).dy).reduce(max);
      expect(above, closeTo(below, 1));
    });

    testWidgets('compact: the toggle and the overflow trigger share a '
        'vertical center', (tester) async {
      stubQuote(SaleStatus.completed);
      await pumpQuote(tester, surface: compact);

      expect(
        tester.getCenter(toggle).dy,
        closeTo(tester.getCenter(moreActions).dy, 1),
      );
    });
  });
}
