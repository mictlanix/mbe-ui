import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/invoicing/domain/xml_filename.dart';

void main() {
  test('series and a short serial are padded to 6 digits', () {
    expect(
      invoiceXmlFilename(issuerRfc: 'CAG190523ES5', series: 'GR', serial: 4776),
      'CAG190523ES5-GR004776.xml',
    );
  });

  test('no series leaves the serial alone', () {
    expect(
      invoiceXmlFilename(issuerRfc: 'XAXX010101000', serial: 12),
      'XAXX010101000-000012.xml',
    );
  });

  test('a 7-digit serial is not truncated', () {
    expect(
      invoiceXmlFilename(
        issuerRfc: 'XAXX010101000',
        series: 'A',
        serial: 1234567,
      ),
      'XAXX010101000-A1234567.xml',
    );
  });
}
