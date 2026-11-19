import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child, {double width = 200}) => MaterialApp(
  locale: const Locale('es', 'MX'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(
    body: Align(
      alignment: AlignmentDirectional.topStart,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

const _status = {
  ItineraryStatus.open: 'Abierto',
  ItineraryStatus.departed: 'En ruta',
  ItineraryStatus.closed: 'Cerrado',
  ItineraryStatus.cancelled: 'Cancelado',
};

const _outcome = {
  StopOutcome.pending: 'Pendiente',
  StopOutcome.delivered: 'Entregada',
  StopOutcome.partiallyDelivered: 'Entregada parcialmente',
  StopOutcome.failed: 'Fallida',
};

/// Spec 075 T009: every value renders its own Spanish label, never the enum
/// name, and never truncated.
void main() {
  for (final status in ItineraryStatus.values) {
    testWidgets('trip status ${status.name} renders "${_status[status]}"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(ItineraryStatusChip(status: status)));
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<ItineraryStatus>), findsOneWidget);
      expect(find.text(_status[status]!), findsOneWidget);
      expect(find.text(status.name), findsNothing);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text(_status[status]!),
      );
      expect(paragraph.didExceedMaxLines, isFalse);
    });
  }

  for (final outcome in StopOutcome.values) {
    testWidgets('stop outcome ${outcome.name} renders "${_outcome[outcome]}"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(StopOutcomeChip(outcome: outcome)));
      await tester.pumpAndSettle();

      expect(find.byType(StatusChip<StopOutcome>), findsOneWidget);
      expect(find.text(_outcome[outcome]!), findsOneWidget);
      expect(find.text(outcome.name), findsNothing);
    });
  }

  testWidgets('every shortfall reason has its own label', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final labels = ShortfallReason.values
        .map((r) => shortfallReasonLabel(l10n, r))
        .toList();
    expect(labels.toSet(), hasLength(ShortfallReason.values.length));
    expect(labels, contains('Mercancía dañada'));
    for (final reason in ShortfallReason.values) {
      expect(labels, isNot(contains(reason.name)));
    }
  });
}
