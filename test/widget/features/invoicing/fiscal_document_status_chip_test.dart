import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child, {double width = 120}) => MaterialApp(
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

const _spanish = {
  FiscalDocumentStatus.draft: 'Borrador',
  FiscalDocumentStatus.sealed: 'Sellado',
  FiscalDocumentStatus.stamping: 'Timbrando',
  FiscalDocumentStatus.issued: 'Timbrado',
  FiscalDocumentStatus.cancellationPending: 'Cancelación pendiente',
  FiscalDocumentStatus.cancelled: 'Cancelado',
};

/// Spec 066 C4, spec 072 C15.
void main() {
  for (final status in FiscalDocumentStatus.values) {
    testWidgets('${status.name} renders its Spanish label without clipping at '
        'a narrow width', (tester) async {
      await tester.pumpWidget(_wrap(FiscalDocumentStatusChip(status: status)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(StatusChip<FiscalDocumentStatus>), findsOneWidget);
      expect(
        find.byKey(Key('fiscal_document_status_chip_${status.name}')),
        findsOneWidget,
      );
      final label = find.text(_spanish[status]!);
      expect(label, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(label);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(paragraph.size.width, lessThanOrEqualTo(120));
    });
  }

  test('stamping and cancellation pending share the "waiting" pair, which '
      'differs from the other four', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    final pairs = {
      for (final status in FiscalDocumentStatus.values)
        status: fiscalDocumentStatusColors(scheme, status),
    };

    expect(pairs[FiscalDocumentStatus.stamping], (
      scheme.tertiaryContainer,
      scheme.onTertiaryContainer,
    ));
    expect(
      pairs[FiscalDocumentStatus.cancellationPending],
      pairs[FiscalDocumentStatus.stamping],
    );
    final others = [
      FiscalDocumentStatus.draft,
      FiscalDocumentStatus.sealed,
      FiscalDocumentStatus.issued,
      FiscalDocumentStatus.cancelled,
    ];
    for (final other in others) {
      expect(
        pairs[other],
        isNot(pairs[FiscalDocumentStatus.stamping]),
        reason: other.name,
      );
    }
  });
}
