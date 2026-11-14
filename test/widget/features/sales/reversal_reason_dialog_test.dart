import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/sales/presentation/payment/reversal_reason_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Spec 059 C4 (T006): the one reverse dialog the register, Pagos and
/// Pedidos share.
void main() {
  String? result;
  var closed = false;

  Future<void> open(
    WidgetTester tester, {
    bool orderHasRefunds = false,
    Future<AppError?> Function(String reason)? submit,
  }) async {
    result = null;
    closed = false;
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('open'),
                  onPressed: () async {
                    result = await showReversalReasonDialog(
                      context,
                      amount: r'$1,500.00',
                      orderId: 1041,
                      orderHasRefunds: orderHasRefunds,
                      submit: submit,
                    );
                    closed = true;
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  bool confirmEnabled(WidgetTester tester) => tester
      .widget<FilledButton>(find.byKey(const Key('reversal_reason_confirm')))
      .enabled;

  testWidgets('confirm is disabled for an empty or whitespace-only reason', (
    tester,
  ) async {
    await open(tester);

    expect(confirmEnabled(tester), isFalse);

    await tester.enterText(
      find.byKey(const Key('reversal_reason_field')),
      '  ',
    );
    await tester.pump();
    expect(confirmEnabled(tester), isFalse);

    await tester.enterText(
      find.byKey(const Key('reversal_reason_field')),
      'Aplicado al pedido equivocado',
    );
    await tester.pump();
    expect(confirmEnabled(tester), isTrue);
  });

  testWidgets('names the amount and the order being reversed', (tester) async {
    await open(tester);

    expect(find.text(r'$1,500.00 aplicados al pedido #1041.'), findsOneWidget);
  });

  testWidgets('warns about refunds only when asked', (tester) async {
    await open(tester);
    expect(find.byKey(const Key('reversal_refund_warning')), findsNothing);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await open(tester, orderHasRefunds: true);

    expect(find.byKey(const Key('reversal_refund_warning')), findsOneWidget);
    expect(find.textContaining('no deshace la devolución'), findsOneWidget);
  });

  testWidgets('without submit, confirm returns the trimmed reason', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(
      find.byKey(const Key('reversal_reason_field')),
      '  Error de captura  ',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('reversal_reason_confirm')));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result, 'Error de captura');
  });

  testWidgets('cancel returns null', (tester) async {
    await open(tester);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(result, isNull);
  });

  testWidgets('a refusal from submit shows in the dialog, which stays open, '
      'and a later success closes it with the reason', (tester) async {
    var calls = 0;
    await open(
      tester,
      submit: (reason) async {
        calls++;
        return calls == 1 ? const AppError.server() : null;
      },
    );

    await tester.enterText(
      find.byKey(const Key('reversal_reason_field')),
      'Motivo',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('reversal_reason_confirm')));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorBanner), findsOneWidget);
    expect(find.byKey(const Key('reversal_reason_dialog')), findsOneWidget);
    expect(closed, isFalse);

    await tester.tap(find.byKey(const Key('reversal_reason_confirm')));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(closed, isTrue);
    expect(result, 'Motivo');
  });

  testWidgets('a second tap while submit is running does not submit twice', (
    tester,
  ) async {
    final gate = Completer<AppError?>();
    var calls = 0;
    await open(
      tester,
      submit: (reason) {
        calls++;
        return gate.future;
      },
    );

    await tester.enterText(
      find.byKey(const Key('reversal_reason_field')),
      'Motivo',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('reversal_reason_confirm')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('reversal_reason_confirm')));
    await tester.pump();

    expect(calls, 1);

    gate.complete(null);
    await tester.pumpAndSettle();
    expect(result, 'Motivo');
  });
}
