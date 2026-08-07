import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'contact.freezed.dart';

/// A named person to hand a delivery to (data-model.md §5.2), mapped from
/// `ContactResponse`. Mirrors [AddressListItem]'s shape deliberately: both
/// exist to back a picker plus an inline-create dialog on the delivery step,
/// not to drive a catalog screen of their own.
///
/// Only the fields the POS actually shows or sends are mapped — the wire
/// record also carries `phoneExt`, `fax`, `website`, `im` and `sip`, none of
/// which a cashier picking a delivery contact needs.
@freezed
class Contact with _$Contact {
  const factory Contact({
    required int contactId,
    required String name,
    String? jobTitle,
    String? phone,
    String? mobile,
    String? email,
  }) = _Contact;

  factory Contact.fromResponse(ContactResponse r) => Contact(
    contactId: r.contactId,
    name: r.name,
    jobTitle: r.jobTitle,
    phone: r.phone,
    // `mobile` is non-nullable on the wire but empty for a contact that has
    // none; normalized to null so callers have one "absent" to test.
    mobile: r.mobile.isEmpty ? null : r.mobile,
    email: r.email,
  );
}

/// How a contact reads in a picker row or on a destination card: the name,
/// plus whichever number is on file. Kept beside the entity rather than in a
/// widget so the delivery step and the inline-create dialog agree.
extension ContactDisplay on Contact {
  String? get preferredPhone => mobile ?? phone;

  String get displayLabel {
    final number = preferredPhone;
    return number == null ? name : '$name · $number';
  }
}
