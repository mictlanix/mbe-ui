import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design_theme_extensions.dart';
import 'package:mbe_ui/core/widgets/app_side_sheet.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_form.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Create / view / edit screen for a single customer (046-catalog-improvements;
/// constitution §VI v1.13.3 moved Customers from the side panel to a full
/// detail screen). [customerId] is `null` in create mode. Hosts the same
/// [CustomerForm] the panel used; leaving with unsaved edits asks first,
/// as the panel did (spec 035 FR-032).
class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({
    super.key,
    this.customerId,
    this.forceReadOnly = false,
  });

  final int? customerId;

  /// Forces read-only rendering — set when navigated to via a row click
  /// rather than Edit (constitution §VI), read from the `?view=true` query
  /// parameter.
  final bool forceReadOnly;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  final _formKey = GlobalKey<CustomerFormPanelState>();

  Future<void> _leave() async {
    final dirty = _formKey.currentState?.isDirty() ?? false;
    if (dirty && !await confirmDiscardChanges(context)) return;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customerId = widget.customerId;
    final canUpdate = ref
        .watch(accessControlProvider)
        .can(SystemObject.customers, AccessRight.update);
    final readOnly = customerId != null && (widget.forceReadOnly || !canUpdate);
    final title = customerId == null
        ? l10n.newCustomerTitle
        : (readOnly ? l10n.viewCustomerTitle : l10n.editCustomerTitle);

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
          child: CustomerForm(
            key: _formKey,
            customerId: customerId,
            forceReadOnly: widget.forceReadOnly,
            onEditRequested: customerId == null
                ? null
                : () => context.replace('/customers/$customerId'),
          ),
        ),
      ),
    );
  }
}
