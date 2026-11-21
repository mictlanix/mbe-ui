import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_document_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('es', 'MX'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: Center(child: child)),
);

const _spanish = {
  InventoryDocumentStatus.draft: 'Borrador',
  InventoryDocumentStatus.completed: 'Confirmada',
  InventoryDocumentStatus.cancelled: 'Cancelada',
};

/// Spec 067.
void main() {
  for (final status in InventoryDocumentStatus.values) {
    testWidgets('${status.name} renders its Spanish label', (tester) async {
      await tester.pumpWidget(
        _wrap(InventoryDocumentStatusChip(status: status)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<InventoryDocumentStatus>), findsOneWidget);
      expect(
        find.byKey(const Key('inventory_document_status_chip')),
        findsOneWidget,
      );
      expect(find.text(_spanish[status]!), findsOneWidget);
      // Every status shows an icon and a word (spec 077 FR-014).
      expect(
        find.descendant(
          of: find.byType(StatusChip<InventoryDocumentStatus>),
          matching: find.byType(Icon),
        ),
        findsOneWidget,
      );
    });
  }
}
