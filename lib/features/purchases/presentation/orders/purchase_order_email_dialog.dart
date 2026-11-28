import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_email_controller.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_email_controller.dart'
    show AddTypedResult, RecipientChip, RecipientOrigin;
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Enviar orden {id} por correo" (spec 080 FR-027, FR-028, research R14):
/// the quote email dialog's chip input, with suggestions from the supplier's
/// contacts, and a message of up to 1000 characters. Success closes it with
/// the SnackBar "Orden enviada a {n} destinatarios."; a refusal shows in the
/// dialog, localized from its code, and keeps the input.
///
/// Reachable only on a confirmed order with PurchasesOrders (SystemObject 20)
/// update; the detail screen gates its button. When the server said the
/// order is no longer confirmed, closing the dialog reloads the order.
Future<void> showPurchaseOrderEmailDialog(
  BuildContext context,
  PurchaseOrder order,
) async {
  final container = ProviderScope.containerOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  // Held for as long as the dialog is open, so a not-confirmed refusal is
  // still known however the dialog is dismissed.
  final subscription = container.listen(
    purchaseOrderEmailControllerProvider(order.id),
    (_, _) {},
  );
  try {
    final receipt = await showResponsiveDialog<OrderEmailReceipt>(
      context,
      builder: (_) => _PurchaseOrderEmailDialog(order: order),
    );
    if (receipt != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.purchaseOrderEmailSentSnack(receipt.recipients.length),
          ),
        ),
      );
    } else if (subscription.read().sawNotConfirmed) {
      container.invalidate(purchaseOrderDetailControllerProvider(order.id));
    }
  } finally {
    subscription.close();
  }
}

class _PurchaseOrderEmailDialog extends ConsumerStatefulWidget {
  const _PurchaseOrderEmailDialog({required this.order});

  final PurchaseOrder order;

  @override
  ConsumerState<_PurchaseOrderEmailDialog> createState() =>
      _PurchaseOrderEmailDialogState();
}

class _PurchaseOrderEmailDialogState
    extends ConsumerState<_PurchaseOrderEmailDialog> {
  final _field = TextEditingController();
  final _message = TextEditingController();
  String? _fieldError;

  PurchaseOrderEmailController get _controller =>
      ref.read(purchaseOrderEmailControllerProvider(widget.order.id).notifier);

  @override
  void initState() {
    super.initState();
    // In a microtask: a provider must not change while the tree builds.
    Future.microtask(() {
      if (mounted) _controller.loadSuggestions(widget.order.supplierId);
    });
  }

  @override
  void dispose() {
    _field.dispose();
    _message.dispose();
    super.dispose();
  }

  void _addTyped() {
    final l10n = AppLocalizations.of(context)!;
    switch (_controller.addTyped(_field.text)) {
      case AddTypedResult.invalid:
        setState(() => _fieldError = l10n.salesQuoteEmailInvalidAddress);
      case AddTypedResult.added || AddTypedResult.selectedExisting:
        _field.clear();
        setState(() => _fieldError = null);
      // The counter already says why, and the text stays for the user to fix.
      case AddTypedResult.limitReached || AddTypedResult.ignored:
        break;
    }
  }

  Future<void> _send() async {
    final receipt = await _controller.send();
    if (receipt != null && mounted) Navigator.of(context).pop(receipt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final state = ref.watch(
      purchaseOrderEmailControllerProvider(widget.order.id),
    );
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final hasSuggestions = state.chips.any(
      (c) => c.origin == RecipientOrigin.contact,
    );

    final Widget suggestionStatus = switch (state.suggestions) {
      EmailSuggestions.loading => const LinearProgressIndicator(
        key: Key('purchase_order_email_suggestions_loading'),
      ),
      _ when hasSuggestions => Text(
        l10n.purchaseOrderEmailSuggestions,
        key: const Key('purchase_order_email_suggestions'),
        style: hintStyle,
      ),
      // No read on Suppliers, a failed lookup or no contact with an email:
      // the user types the address.
      _ => Text(
        l10n.purchaseOrderEmailNoSuggestions,
        key: const Key('purchase_order_email_no_suggestions'),
        style: hintStyle,
      ),
    };

    final counter = state.selected.isEmpty
        ? l10n.salesQuoteEmailLimitHint
        : state.atLimit
        ? l10n.salesQuoteEmailLimitReached
        : l10n.salesQuoteEmailCounter(state.selected.length);

    final failure = state.failureError;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.purchaseOrderEmailRecipients,
          style: theme.textTheme.titleSmall,
        ),
        SizedBox(height: spacing.xs),
        if (state.chips.isNotEmpty) ...[
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              for (final chip in state.chips)
                FilterChip(
                  key: Key('purchase_order_email_chip_${chip.key}'),
                  tooltip: chip.label,
                  label: _ChipLabel(chip: chip),
                  selected: state.selected.contains(chip.key),
                  onSelected: state.sending
                      ? null
                      : (_) => _controller.toggle(chip.key),
                ),
            ],
          ),
          SizedBox(height: spacing.xs),
        ],
        suggestionStatus,
        SizedBox(height: spacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('purchase_order_email_other_field'),
                controller: _field,
                enabled: !state.sending,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.salesQuoteEmailOtherAddressLabel,
                  errorText: _fieldError,
                ),
                onChanged: (_) {
                  if (_fieldError != null) setState(() => _fieldError = null);
                },
                onSubmitted: (_) => state.atLimit ? null : _addTyped(),
              ),
            ),
            SizedBox(width: spacing.xs),
            Padding(
              // Lines the button up with the field's own box, which sits below
              // its floating label.
              padding: EdgeInsets.only(top: spacing.xxs),
              child: OutlinedButton(
                key: const Key('purchase_order_email_add_button'),
                onPressed: state.sending || state.atLimit ? null : _addTyped,
                child: Text(l10n.salesQuoteEmailAddAction),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.xs),
        Text(
          counter,
          key: const Key('purchase_order_email_counter'),
          style: hintStyle,
        ),
        SizedBox(height: spacing.fieldGapVertical),
        TextField(
          key: const Key('purchase_order_email_message'),
          controller: _message,
          enabled: !state.sending,
          minLines: 3,
          maxLines: 6,
          maxLength: purchaseOrderEmailMessageMaxLength,
          decoration: InputDecoration(
            labelText: l10n.purchaseOrderEmailMessage,
            alignLabelWithHint: true,
          ),
          buildCounter:
              (_, {required currentLength, required isFocused, maxLength}) =>
                  Text(
                    l10n.purchaseOrderEmailMessageCounter(
                      fmt.display.count(currentLength),
                    ),
                    key: const Key('purchase_order_email_message_counter'),
                    style: hintStyle,
                  ),
          onChanged: _controller.setMessage,
        ),
        if (failure != null) ...[
          SizedBox(height: spacing.sm),
          // The reason comes from the refusal's code (§III).
          ErrorBanner(
            key: const Key('purchase_order_email_refusal'),
            error: failure,
            onDismiss: state.sending ? null : _controller.clearFailure,
          ),
        ],
      ],
    );

    return ResponsiveDialog(
      key: const Key('purchase_order_email_dialog'),
      title: l10n.purchaseOrderEmailTitle('${widget.order.id}'),
      body: body,
      dismissible: !state.sending,
      primaryAction: ResponsiveDialogAction(
        key: const Key('purchase_order_email_send'),
        label: state.sending
            ? l10n.salesQuoteEmailSendingLabel
            : l10n.salesQuoteEmailSendAction,
        busy: state.sending,
        onPressed: state.canSend ? _send : null,
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('purchase_order_email_cancel'),
        label: l10n.cancelButton,
        onPressed: state.sending ? null : () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// "owner · address"; when too wide, the owner's name is cut before the
/// address is.
class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.chip});

  final RecipientChip chip;

  @override
  Widget build(BuildContext context) {
    final owner = chip.owner;
    if (owner == null) {
      return Text(chip.address, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(owner, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Text(' · ${chip.address}', maxLines: 1),
      ],
    );
  }
}
