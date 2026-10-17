import 'package:flutter/material.dart';

import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipient_form.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the full taxpayer-recipient form in a dialog, in create mode, and
/// returns the created recipient — or `null` if the user dismissed it
/// (046-catalog-improvements research R7, contracts C2).
///
/// The record is created on the server as soon as the form is saved; a
/// caller that only links it later (the customer form) leaves it unlinked if
/// its own save never happens, the same as `showAddressInlineCreateDialog`.
Future<TaxpayerRecipientListItem?> showTaxpayerRecipientInlineCreateDialog(
  BuildContext context,
) async {
  final created = await showDialog<TaxpayerRecipient>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text(
                AppLocalizations.of(context)!.newTaxpayerRecipientTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const TaxpayerRecipientForm(),
            ],
          ),
        ),
      ),
    ),
  );
  return created == null
      ? null
      : TaxpayerRecipientListItem.fromRecipient(created);
}
