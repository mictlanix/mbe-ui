import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_certificate.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificate_upload_dialog.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_certificates_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A Taxpayer Issuer's CSD Certificates section (US3, FR-019, FR-020,
/// FR-024, FR-025) — a divider-delimited **child collection** rendered
/// inside the Taxpayer Issuer detail, not a standalone catalog list screen
/// (research §9). Each row is read-only (no per-row Edit/Delete — the API
/// has neither); "Agregar" opens the upload dialog and is gated on
/// **both** `can(taxpayers, create)` **and** `!readOnly`, so a read-only/
/// View render of the parent issuer never exposes a mutating control, even
/// to a create-privileged user (FR-025, constitution §VI row-click-is-
/// read-only rule).
class TaxpayerCertificatesSection extends ConsumerWidget {
  const TaxpayerCertificatesSection({
    super.key,
    required this.rfc,
    required this.readOnly,
  });

  final String rfc;

  /// The parent Taxpayer Issuer detail screen's own read-only flag
  /// (`forceReadOnly || !canUpdate`) — passed straight through so this
  /// section's Agregar action follows the same visibility rule as every
  /// other mutation control on that screen.
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsync = ref.watch(
      taxpayerCertificatesControllerProvider(rfc),
    );
    final access = ref.watch(accessControlProvider);
    final canAdd =
        !readOnly && access.can(SystemObject.taxpayers, AccessRight.create);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMd();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.certificatesSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (canAdd)
              FilledButton.icon(
                key: const Key('add_certificate_button'),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.addCertificateButton),
                onPressed: () =>
                    showTaxpayerCertificateUploadDialog(context, rfc: rfc),
              ),
          ],
        ),
        const SizedBox(height: 8),
        certificatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(l10n.certificatesLoadError(e)),
          data: (certificates) => certificates.isEmpty
              ? Text(l10n.noCertificatesFound)
              // DataTable2 (the unpaginated variant DataTableView renders
              // without a `pagination` page) needs a bounded height to lay
              // out its own internal scroll region — unlike the paginated
              // variant, it cannot shrink-wrap inside this section's
              // unbounded-height host (the issuer detail's
              // SingleChildScrollView). Sized to the row count, capped so a
              // long certificate history scrolls within its own bounded
              // area instead of growing the section indefinitely.
              : SizedBox(
                  height: (56 + 52.0 * certificates.length).clamp(0, 400),
                  child: DataTableView<TaxpayerCertificate>(
                    key: const Key('taxpayer_certificates_table'),
                    columns: [
                      DataTableColumn.text(
                        label: l10n.columnCertificateNumber,
                        text: (c) => c.taxpayerCertificateId,
                        size: ColumnSize.L,
                      ),
                      DataTableColumn.text(
                        label: l10n.columnValidFrom,
                        text: (c) => dateFormat.format(c.validFrom),
                        size: ColumnSize.S,
                      ),
                      DataTableColumn.text(
                        label: l10n.columnValidTo,
                        text: (c) => dateFormat.format(c.validTo),
                        size: ColumnSize.S,
                      ),
                      DataTableColumn(
                        label: l10n.columnStatus,
                        fixedWidth: 130,
                        cellBuilder: (context, c) =>
                            EntityStatusCell(status: c.status),
                      ),
                    ],
                    rows: certificates,
                    // No per-row actions and no row-tap: certificates are
                    // immutable, so there is nothing to edit/view beyond
                    // what this row already shows (FR-024).
                  ),
                ),
        ),
      ],
    );
  }
}
