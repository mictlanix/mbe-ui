/// The name an invoice's XML is saved under: `{RFC}-{series}{serial}.xml`,
/// the serial padded to 6 digits and never truncated (spec 066 research
/// R10). With no series the name is `{RFC}-{serial}.xml`.
String invoiceXmlFilename({
  required String issuerRfc,
  String? series,
  required int serial,
}) => '$issuerRfc-${series ?? ''}${serial.toString().padLeft(6, '0')}.xml';
