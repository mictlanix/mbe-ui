import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'quote_email.freezed.dart';

/// What mbe-api confirms after emailing a quote (spec 053 data-model.md),
/// mapped from `QuoteEmailResponse`. [recipients] are as the server
/// normalised them (trimmed, deduplicated); [sentAt] is the Mexico City wall
/// time the send was recorded, not displayed in this spec.
@freezed
abstract class QuoteEmailReceipt with _$QuoteEmailReceipt {
  const factory QuoteEmailReceipt({
    required List<String> recipients,
    required DateTime sentAt,
  }) = _QuoteEmailReceipt;

  factory QuoteEmailReceipt.fromResponse(QuoteEmailResponse r) =>
      QuoteEmailReceipt(recipients: r.recipients.toList(), sentAt: r.sentAt);
}

/// mbe-api's own pattern for a recipient (`QuoteEmailRequest`'s validator in
/// `app/schemas/sales_quote.py`): something, `@`, something, `.`, something,
/// no whitespace. Deliberately no stricter, so the client never refuses an
/// address the server would accept, or the reverse (spec 053 research R8).
final _plausibleEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// The longest address mbe-api accepts.
const _maxEmailLength = 254;

/// Whether [value], once trimmed, is an address mbe-api would accept.
bool isPlausibleEmail(String value) {
  final address = value.trim();
  return address.length <= _maxEmailLength && _plausibleEmail.hasMatch(address);
}
