import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_period_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

void main() {
  Future<void> pumpChip(WidgetTester tester, CommissionPeriodStatus status) =>
      tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CommissionPeriodStatusChip(status: status)),
        ),
      );

  for (final (status, label, tone) in [
    (CommissionPeriodStatus.open, 'Abierto', StatusTone.neutral),
    (CommissionPeriodStatus.closed, 'Cerrado', StatusTone.info),
    (CommissionPeriodStatus.paid, 'Pagado', StatusTone.success),
  ]) {
    testWidgets('${status.name} reads "$label"', (tester) async {
      await pumpChip(tester, status);
      expect(find.text(label), findsOneWidget);
      expect(commissionPeriodStatusLook(status).$1, tone);
    });
  }
}
