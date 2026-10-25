import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/quote_email.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_email_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// How the email dialog ended, when it did not simply close (spec 053
/// data-model.md "QuoteEmailOutcome").
sealed class QuoteEmailOutcome {
  const QuoteEmailOutcome();
}

/// The server sent the quote; [receipt] names every recipient it confirmed.
final class QuoteEmailSent extends QuoteEmailOutcome {
  const QuoteEmailSent(this.receipt);

  final QuoteEmailReceipt receipt;
}

/// The dialog was closed after the server refused with 409: the quote is no
/// longer confirmed, so the screen showing it is out of date (FR-014).
final class QuoteEmailStaleQuote extends QuoteEmailOutcome {
  const QuoteEmailStaleQuote();
}

/// Opens the email dialog for [quote] (spec 053 FR-006–FR-014). `null` when
/// it was closed with nothing sent and nothing learned.
///
/// The controller is held open for as long as the dialog is, so a 409 is
/// still known when the dialog is dismissed by any route — its close control,
/// back, or the barrier — none of which can carry a result of their own.
Future<QuoteEmailOutcome?> showQuoteEmailDialog(
  BuildContext context, {
  required Sale quote,
}) async {
  final container = ProviderScope.containerOf(context);
  final subscription = container.listen(
    quoteEmailControllerProvider(quote.id),
    (_, _) {},
  );
  try {
    final receipt = await showResponsiveDialog<QuoteEmailReceipt>(
      context,
      builder: (_) => _QuoteEmailDialog(quote: quote),
    );
    if (receipt != null) return QuoteEmailSent(receipt);
    return subscription.read().sawNotSendable
        ? const QuoteEmailStaleQuote()
        : null;
  } finally {
    subscription.close();
  }
}

class _QuoteEmailDialog extends ConsumerStatefulWidget {
  const _QuoteEmailDialog({required this.quote});

  final Sale quote;

  @override
  ConsumerState<_QuoteEmailDialog> createState() => _QuoteEmailDialogState();
}

class _QuoteEmailDialogState extends ConsumerState<_QuoteEmailDialog> {
  final _field = TextEditingController();
  String? _fieldError;

  QuoteEmailController get _controller =>
      ref.read(quoteEmailControllerProvider(widget.quote.id).notifier);

  @override
  void initState() {
    super.initState();
    // The customer is usually already loaded for the screen behind, so this
    // fires at once; the chips are added in a microtask because a provider
    // must not be changed while the widget tree is building.
    ref.listenManual(saleCustomerControllerProvider(widget.quote.customer), (
      _,
      next,
    ) {
      final customer = next.value;
      if (customer == null) return;
      Future.microtask(() {
        if (!mounted) return;
        _controller.seed(
          contacts: customer.contacts,
          taxpayers: customer.taxpayers,
        );
      });
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _addTyped() {
    final l10n = AppLocalizations.of(context)!;
    final result = _controller.addTyped(_field.text);
    switch (result) {
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

  /// FR-013: one message per cause. A cause the server's own `detail` already
  /// explains (a refused recipient list, a connection failure) passes its
  /// error through unchanged; the three whose server text is no use to the
  /// user keep their status and carry our own line instead, so each still
  /// reads differently through the one shared banner.
  AppError _bannerError(AppLocalizations l10n, QuoteEmailState state) {
    final error = state.failureError!;
    final status = error is ServerError ? error.statusCode : null;
    return switch (state.failure!) {
      QuoteEmailFailure.notSendable => AppError.server(
        statusCode: status,
        message: l10n.salesQuoteEmailNotSendable,
      ),
      QuoteEmailFailure.mailRefused => AppError.server(
        statusCode: status,
        message: l10n.salesQuoteEmailMailRefused,
      ),
      QuoteEmailFailure.mailUnavailable => AppError.server(
        statusCode: status,
        message: l10n.salesQuoteEmailMailUnavailable,
      ),
      QuoteEmailFailure.invalidRecipients || QuoteEmailFailure.other => error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final quote = widget.quote;
    final state = ref.watch(quoteEmailControllerProvider(quote.id));
    final customer = ref.watch(saleCustomerControllerProvider(quote.customer));

    // The same reference the header strip shows, so the user sees one number
    // for the quote (research R12).
    final reference =
        quote.serial?.toString() ?? '#${quote.provisionalReference}';

    final hasSuggestions = state.chips.any(
      (c) => c.origin != RecipientOrigin.typed,
    );
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    Widget suggestionStatus() {
      if (hasSuggestions) return const SizedBox.shrink();
      return customer.when(
        loading: () => Row(
          key: const Key('quote_email_suggestions_loading'),
          children: [
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: spacing.xs),
            Flexible(
              child: Text(
                l10n.salesQuoteEmailSuggestionsLoading,
                style: hintStyle,
              ),
            ),
          ],
        ),
        error: (_, _) => Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: spacing.xs,
          children: [
            Text(l10n.salesQuoteEmailSuggestionsFailed, style: hintStyle),
            TextButton(
              key: const Key('quote_email_suggestions_retry'),
              onPressed: () => ref.invalidate(
                saleCustomerControllerProvider(quote.customer),
              ),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
        data: (_) => Text(
          l10n.salesQuoteEmailNoKnownAddresses,
          key: const Key('quote_email_no_addresses'),
          style: hintStyle,
        ),
      );
    }

    final counter = state.selected.isEmpty
        ? l10n.salesQuoteEmailLimitHint
        : state.atLimit
        ? l10n.salesQuoteEmailLimitReached
        : l10n.salesQuoteEmailCounter(state.selected.length);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.failure != null) ...[
          ErrorBanner(
            key: const Key('quote_email_error_banner'),
            error: _bannerError(l10n, state),
            onDismiss: state.sending ? null : _controller.clearFailure,
          ),
          SizedBox(height: spacing.sm),
        ],
        Text(
          l10n.salesQuoteEmailRecipientsLabel,
          style: theme.textTheme.titleSmall,
        ),
        SizedBox(height: spacing.xs),
        suggestionStatus(),
        if (state.chips.isNotEmpty)
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              for (final chip in state.chips)
                FilterChip(
                  key: Key('quote_email_chip_${chip.key}'),
                  tooltip: chip.label,
                  label: _ChipLabel(chip: chip),
                  selected: state.selected.contains(chip.key),
                  onSelected: state.sending
                      ? null
                      : (_) => _controller.toggle(chip.key),
                ),
            ],
          ),
        SizedBox(height: spacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('quote_email_other_field'),
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
                key: const Key('quote_email_add_button'),
                onPressed: state.sending || state.atLimit ? null : _addTyped,
                child: Text(l10n.salesQuoteEmailAddAction),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.xs),
        Text(counter, key: const Key('quote_email_counter'), style: hintStyle),
      ],
    );

    return ResponsiveDialog(
      key: const Key('quote_email_dialog'),
      title: l10n.salesQuoteEmailDialogTitle(reference),
      body: body,
      dismissible: !state.sending,
      primaryAction: ResponsiveDialogAction(
        key: const Key('quote_email_send_button'),
        label: state.sending
            ? l10n.salesQuoteEmailSendingLabel
            : l10n.salesQuoteEmailSendAction,
        busy: state.sending,
        onPressed: state.canSend ? _send : null,
      ),
      secondaryAction: ResponsiveDialogAction(
        key: const Key('quote_email_cancel_button'),
        label: l10n.cancelButton,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// "owner · address". When the chip is too wide, the owner's name is cut
/// before the address is (the address is what the user must be able to read).
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
