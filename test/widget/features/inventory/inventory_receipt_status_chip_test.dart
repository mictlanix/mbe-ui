import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('es', 'MX'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: Center(child: child)),
);

const _spanish = {
  ReceiptStatus.draft: 'Borrador',
  ReceiptStatus.completed: 'Confirmada',
  ReceiptStatus.cancelled: 'Cancelada',
};

/// Spec 067.
void main() {
  for (final status in ReceiptStatus.values) {
    testWidgets('${status.name} renders its Spanish label', (tester) async {
      await tester.pumpWidget(
        _wrap(InventoryReceiptStatusChip(status: status)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<ReceiptStatus>), findsOneWidget);
      expect(
        find.byKey(const Key('inventory_receipt_status_chip')),
        findsOneWidget,
      );
      expect(find.text(_spanish[status]!), findsOneWidget);
    });
  }
}
