import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/fulfillment_mode.dart';

/// mbe-api#171 renumbered the wire scale this feature depends on — pickup
/// and delivery swapped places, and a third value (mixed) was added — while
/// unifying `delivery_order.fulfillment_type` and the new
/// `sales_order.fulfillment_intent` onto one enum. A test that only asserts
/// against enum *members* (`FulfillmentType.delivery`) cannot catch a
/// renumbering: the member survives, only the wire integer underneath it
/// changes. These assert against `api.FulfillmentType`'s own `wireNumber`
/// directly, which is what a real request/response body actually carries.
void main() {
  group('FulfillmentType — delivery_order.fulfillment_type (never MIXED)', () {
    test('counterPickup is wire 0, delivery is wire 1', () {
      expect(FulfillmentType.counterPickup.toApi(), api.FulfillmentType.number0);
      expect(FulfillmentType.delivery.toApi(), api.FulfillmentType.number1);
    });

    test('reads wire 0 as counterPickup and wire 1 as delivery', () {
      expect(
        FulfillmentType.fromApi(api.FulfillmentType.number0),
        FulfillmentType.counterPickup,
      );
      expect(FulfillmentType.fromApi(api.FulfillmentType.number1), FulfillmentType.delivery);
    });

    test('an unexpected wire value degrades to delivery rather than throwing', () {
      expect(FulfillmentType.fromApi(api.FulfillmentType.number2), FulfillmentType.delivery);
    });
  });

  group('FulfillmentMode — sales_order.fulfillment_intent (all three values)', () {
    test('counterPickup, delivery and mixed round-trip on the shared scale', () {
      for (final mode in FulfillmentMode.values) {
        expect(FulfillmentMode.fromApi(mode.toApi()), mode);
      }
    });

    test('the three modes sit at wire 0, 1 and 2 respectively', () {
      expect(FulfillmentMode.counterPickup.toApi(), api.FulfillmentType.number0);
      expect(FulfillmentMode.delivery.toApi(), api.FulfillmentType.number1);
      expect(FulfillmentMode.mixed.toApi(), api.FulfillmentType.number2);
    });

    test('a null intent stays null — "not recorded", not a guessed mode', () {
      expect(FulfillmentMode.fromApi(null), isNull);
    });
  });
}
