import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';

/// Contact lookup and creation (contracts/mbe-api-pos.md §4).
///
/// Deliberately **not** full CRUD, mirroring `AddressRepository`: the POS
/// delivery step only ever picks an existing contact or creates one inline
/// (FR-031). `ContactsApi` does expose get/update/delete, but nothing in this
/// app edits or removes a contact, and a repository method with no caller is
/// dead surface — add them when a screen needs them.
abstract class ContactRepository {
  /// `GET /api/v1/contacts` — backs the destination editor's contact picker.
  Future<List<Contact>> list({String? search, int skip = 0, int limit = 20});

  /// `POST /api/v1/contacts` — the inline-create dialog. The new contact is
  /// linked to the customer separately, via
  /// `CustomerRepository.update(contacts: ...)`.
  Future<Contact> create({
    required String name,
    String? jobTitle,
    String? phone,
    String? mobile,
    String? email,
  });
}
