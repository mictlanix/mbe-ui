import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/presentation/widgets/cash_session_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('es', 'MX'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: child),
);

void main() {
  group('StatusChip (SC-010: one shared implementation, not two)', () {
    testWidgets(
      'EntityStatusCell renders a non-active status through StatusChip<EntityStatus>',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const EntityStatusCell(status: EntityStatus.inactive)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StatusChip<EntityStatus>), findsOneWidget);
        expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
      },
    );

    testWidgets('EntityStatusCell renders active as plain text, not a chip', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const EntityStatusCell(status: EntityStatus.active)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<EntityStatus>), findsNothing);
    });

    testWidgets(
      'CashSessionStatusChip renders through StatusChip<CashSessionStatus>',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const CashSessionStatusChip(status: CashSessionStatus.stale)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StatusChip<CashSessionStatus>), findsOneWidget);
        expect(
          find.byKey(const Key('cash_session_status_chip_stale')),
          findsOneWidget,
        );
      },
    );

    testWidgets('the two status enums never share a StatusChip type', (
      tester,
    ) async {
      // The generic type parameter is what makes "one shared implementation"
      // (SC-010) verifiable at all -- confirms EntityStatus and
      // CashSessionStatus each instantiate their own StatusChip<T>, not a
      // dynamic/untyped one that would hide a divergence.
      await tester.pumpWidget(
        _wrap(
          Column(
            children: const [
              EntityStatusCell(status: EntityStatus.archived),
              CashSessionStatusChip(status: CashSessionStatus.closed),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<EntityStatus>), findsOneWidget);
      expect(find.byType(StatusChip<CashSessionStatus>), findsOneWidget);
    });
  });
}
