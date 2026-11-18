import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_sources.dart';
import 'package:mbe_ui/l10n/app_localizations_es.dart';

/// A user holding read (2) on exactly [objects].
AccessControlService _access(List<SystemObject> objects) =>
    AccessControlService(
      AuthState.authenticated(
        token: 't',
        user: User(
          userId: 'c',
          email: 'c@example.com',
          administrator: false,
          status: EntityStatus.active,
          sessionVersion: 1,
          privileges: [
            for (final o in objects) Privilege(systemObject: o, rawValue: 2),
          ],
        ),
      ),
    );

KardexDocumentRef _ref(int type, {int id = 57}) =>
    KardexDocumentRef(type: type, id: id);

void main() {
  test('every source type has its label, and any other type the fallback', () {
    final l10n = AppLocalizationsEs();

    expect(
      {
        for (final type in [1, 2, 3, 4, 5, 6, 8, 10, 12, 13, 7, 99])
          type: kardexSourceLabel(l10n, type),
      },
      {
        1: 'Pedido',
        2: 'Devolución',
        3: 'Salida de almacén',
        4: 'Entrada de almacén',
        5: 'Traspaso',
        6: 'Orden de compra',
        8: 'Ajuste (sistema anterior)',
        10: 'Itinerario de reparto',
        12: 'Conteo físico',
        13: 'Entrega en mostrador',
        7: 'Movimiento',
        99: 'Movimiento',
      },
    );
  });

  const linked = {
    1: (SystemObject.salesOrders, '/sales/orders/57'),
    2: (SystemObject.customerRefunds, '/sales/refunds/57'),
    3: (SystemObject.inventoryIssues, '/inventory/issues/57'),
    4: (SystemObject.inventoryReceipts, '/inventory/receipts/57'),
    5: (SystemObject.inventoryTransfers, '/inventory/transfers/57'),
    8: (SystemObject.inventoryReceipts, '/inventory/receipts/57'),
    12: (SystemObject.physicalCountAdjustment, '/inventory/counts/57'),
    13: (SystemObject.deliveryOrders, '/sales/delivery-orders/57'),
  };

  for (final MapEntry(key: type, value: (object, path)) in linked.entries) {
    test('type $type links to $path with ${object.name} read only', () {
      expect(kardexDocumentRoute(_ref(type), _access([object])), path);
      expect(kardexDocumentRoute(_ref(type), _access([])), isNull);
      final others = [
        for (final (o, _) in linked.values)
          if (o != object) o,
      ];
      expect(kardexDocumentRoute(_ref(type), _access(others)), isNull);
    });
  }

  test('types 6, 10 and an unknown type never link, nor does a missing '
      'document', () {
    final everything = _access([for (final (o, _) in linked.values) o]);

    for (final type in [6, 10, 7, 99]) {
      expect(kardexDocumentRoute(_ref(type), everything), isNull);
    }
    expect(kardexDocumentRoute(null, everything), isNull);
  });
}
