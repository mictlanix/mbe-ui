import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('es', 'MX'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: Center(child: child)),
);

const _spanish = {
  InventoryTransferStatus.draft: 'Borrador',
  InventoryTransferStatus.inTransit: 'En tránsito',
  InventoryTransferStatus.received: 'Recibido',
  InventoryTransferStatus.cancelled: 'Cancelado',
};

/// Spec 069 research R3.
void main() {
  for (final status in InventoryTransferStatus.values) {
    testWidgets('${status.name} renders its Spanish label', (tester) async {
      await tester.pumpWidget(
        _wrap(InventoryTransferStatusChip(status: status)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<InventoryTransferStatus>), findsOneWidget);
      expect(
        find.byKey(const Key('inventory_transfer_status_chip')),
        findsOneWidget,
      );
      expect(find.text(_spanish[status]!), findsOneWidget);
    });
  }

  test('each status has its tone', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
    expect(
      inventoryTransferStatusColors(scheme, InventoryTransferStatus.draft).$1,
      scheme.surfaceContainerHighest,
    );
    expect(
      inventoryTransferStatusColors(
        scheme,
        InventoryTransferStatus.inTransit,
      ).$1,
      scheme.tertiaryContainer,
    );
    expect(
      inventoryTransferStatusColors(
        scheme,
        InventoryTransferStatus.received,
      ).$1,
      scheme.secondaryContainer,
    );
    expect(
      inventoryTransferStatusColors(
        scheme,
        InventoryTransferStatus.cancelled,
      ).$1,
      scheme.errorContainer,
    );
  });
}
