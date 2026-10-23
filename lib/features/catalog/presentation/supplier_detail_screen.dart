import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design_theme_extensions.dart';
import 'package:mbe_ui/core/widgets/app_side_sheet.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_form.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single supplier (spec 050; constitution
/// §VI v1.14.0 moved Suppliers from the side panel to a full detail screen,
/// since the record carries linked-record sections). [supplierId] is `null`
/// in create mode. Hosts [SupplierForm]; leaving with unsaved edits asks
/// first, as the panel did (spec 035 FR-032).
class SupplierDetailScreen extends ConsumerStatefulWidget {
  const SupplierDetailScreen({
    super.key,
    this.supplierId,
    this.forceReadOnly = false,
  });

  final int? supplierId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<SupplierDetailScreen> createState() =>
      _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {
  final _formKey = GlobalKey<SupplierFormPanelState>();

  Future<void> _leave() async {
    final dirty = _formKey.currentState?.isDirty() ?? false;
    if (dirty && !await confirmDiscardChanges(context)) return;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final supplierId = widget.supplierId;
    final canUpdate = ref
        .watch(accessControlProvider)
        .can(SystemObject.suppliers, AccessRight.update);
    final readOnly = supplierId != null && (widget.forceReadOnly || !canUpdate);
    final title = supplierId == null
        ? l10n.newSupplierTitle
        : (readOnly ? l10n.viewSupplierTitle : l10n.editSupplierTitle);

    return PopScope(
      // Every back navigation re-checks the form at the moment it happens;
      // a `canPop` computed here would not follow edits made after this
      // build (see `app_side_sheet.dart`'s matching guard).
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Theme.of(context).spacing.lg),
          child: SupplierForm(
            key: _formKey,
            supplierId: supplierId,
            forceReadOnly: widget.forceReadOnly,
            onEditRequested: supplierId == null
                ? null
                : () => context.replace('/suppliers/$supplierId'),
            onCreated: (id) => context.replace('/suppliers/$id'),
          ),
        ),
      ),
    );
  }
}
