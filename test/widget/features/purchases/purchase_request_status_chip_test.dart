import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('es', 'MX'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: Center(child: child)),
);

const _spanish = {
  PurchaseRequestStatus.draft: 'Borrador',
  PurchaseRequestStatus.submitted: 'Enviada',
  PurchaseRequestStatus.approved: 'Aprobada',
  PurchaseRequestStatus.cancelled: 'Cancelada',
};

const _tones = {
  PurchaseRequestStatus.draft: StatusTone.neutral,
  PurchaseRequestStatus.submitted: StatusTone.info,
  PurchaseRequestStatus.approved: StatusTone.success,
  PurchaseRequestStatus.cancelled: StatusTone.error,
};

/// Spec 079.
void main() {
  for (final status in PurchaseRequestStatus.values) {
    testWidgets('${status.name} renders its Spanish label, tone and icon', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(PurchaseRequestStatusChip(status: status)));
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<PurchaseRequestStatus>), findsOneWidget);
      expect(
        find.byKey(const Key('purchase_request_status_chip')),
        findsOneWidget,
      );
      expect(find.text(_spanish[status]!), findsOneWidget);
      expect(purchaseRequestStatusLook(status).$1, _tones[status]);
      expect(
        find.descendant(
          of: find.byType(StatusChip<PurchaseRequestStatus>),
          matching: find.byType(Icon),
        ),
        findsOneWidget,
      );
    });
  }
}
