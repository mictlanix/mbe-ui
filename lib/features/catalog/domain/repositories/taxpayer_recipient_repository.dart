import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';

/// Taxpayer Recipient lookup and full CRUD management (data-model.md §5,
/// contracts/mbe-api-catalogs.md §5). `taxpayerRecipientId` is a
/// client-supplied String primary key (the RFC tax id) — required on
/// [create] and immutable thereafter; [get]/[update]/[delete] key off it
/// directly (research.md §9).
abstract class TaxpayerRecipientRepository {
  Future<TaxpayerRecipientPage> list({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  Future<TaxpayerRecipient> get({required String taxpayerRecipientId});

  Future<TaxpayerRecipient> create({
    required String taxpayerRecipientId,
    required String email,
    String? name,
    String? postalCode,
    String? regime,
  });

  Future<TaxpayerRecipient> update({
    required String taxpayerRecipientId,
    String? name,
    String? email,
    String? postalCode,
    String? regime,
  });

  Future<void> delete({required String taxpayerRecipientId});
}

class TaxpayerRecipientPage {
  const TaxpayerRecipientPage({required this.items, required this.total});
  final List<TaxpayerRecipientListItem> items;
  final int total;
}
