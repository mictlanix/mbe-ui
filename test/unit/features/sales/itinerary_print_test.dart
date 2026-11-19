import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_print.dart';

import '../../core/documents/document_fakes.dart';

User _user(int raw) => User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.deliveryItineraries, rawValue: raw),
  ],
);

/// Spec 075 FR-020, research R11: the trip's print actions.
void main() {
  group('canPrintItinerary', () {
    const printable = {ItineraryStatus.departed, ItineraryStatus.closed};

    for (final status in ItineraryStatus.values) {
      final expected = printable.contains(status);

      test('${status.name} is ${expected ? '' : 'not '}printable for a '
          'Delivery Itineraries reader', () {
        expect(canPrintItinerary(accessFor(_user(2)), status), expected);
      });

      test('${status.name} is never printable without read', () {
        // Create and update without read don't open a document.
        expect(canPrintItinerary(accessFor(_user(1 | 4)), status), isFalse);
        expect(canPrintItinerary(accessFor(noPrivileges), status), isFalse);
        expect(
          canPrintItinerary(accessFor(deliveryOrdersReader), status),
          isFalse,
          reason: 'Delivery Orders read is not Delivery Itineraries read',
        );
      });

      test('${status.name} follows the status for an administrator', () {
        expect(canPrintItinerary(accessFor(administrator), status), expected);
      });
    }

    test('exactly En ruta and Cerrado print', () {
      expect(
        ItineraryStatus.values
            .where((s) => canPrintItinerary(accessFor(_user(2)), s))
            .toSet(),
        printable,
      );
    });
  });
}
