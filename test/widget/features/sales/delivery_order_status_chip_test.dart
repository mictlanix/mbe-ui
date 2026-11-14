import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/status_chip.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_status_chip.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(Widget child, {double width = 160}) => MaterialApp(
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
  DeliveryOrderStatus.draft: 'Borrador',
  DeliveryOrderStatus.pendingApproval: 'Pendiente de aprobación',
  DeliveryOrderStatus.approved: 'Aprobada',
  DeliveryOrderStatus.readyForPickup: 'Lista para recoger',
  DeliveryOrderStatus.pickedUp: 'Recogida',
  DeliveryOrderStatus.inPreparation: 'En preparación',
  DeliveryOrderStatus.inTransit: 'En tránsito',
  DeliveryOrderStatus.delivered: 'Entregada',
  DeliveryOrderStatus.partiallyDelivered: 'Entregada parcialmente',
  DeliveryOrderStatus.failed: 'Fallida',
  DeliveryOrderStatus.cancelled: 'Cancelada',
};

/// Spec 061 C11 (T012).
void main() {
  for (final status in DeliveryOrderStatus.values) {
    testWidgets('${status.name} renders its Spanish label without clipping at '
        'a narrow width', (tester) async {
      await tester.pumpWidget(_wrap(DeliveryOrderStatusChip(status: status)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(StatusChip<DeliveryOrderStatus>), findsOneWidget);
      expect(
        find.byKey(Key('delivery_order_status_chip_${status.name}')),
        findsOneWidget,
      );
      final label = find.text(_spanish[status]!);
      expect(label, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(label);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(paragraph.size.width, lessThanOrEqualTo(160));
    });
  }

  testWidgets('type labels come from l10n', (tester) async {
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

    expect(deliveryOrderTypeLabel(l10n, FulfillmentType.delivery), 'Entrega');
    expect(
      deliveryOrderTypeLabel(l10n, FulfillmentType.counterPickup),
      'Recoge en tienda',
    );
  });
}
