import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/data_table_view.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_documents_list_screen.dart'
    show fiscalDocumentsPath;
import 'package:mbe_ui/features/invoicing/presentation/new_invoice_dialog.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/reject_payment_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verify_payment_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payments/apply_payment_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_widgets.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/payments/reverse_application_flow.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// "Ver pago": one payment and what was done with it (spec 054 US2).
///
/// A full detail screen rather than the side panel because a payment owns a
/// child collection (its applications) and needs its own address — the
/// constitution's §VI record-surface criteria. The AppBar carries only Back.
/// Spec 054 left the screen read-only (FR-003); spec 059 adds the two Payments
/// Editor actions in the body, where the data they change is: "Aplicar a
/// pedido" next to the summary, and a reverse icon on each live application.
/// Spec 060 adds "Verificar" and "Rechazar" in the header, beside the verified
/// chip they change, for an unverified payment and a user with Payments
/// Verification (108) update.
///
/// Gated by Customer Payments (8) read; [paymentDetailProvider] additionally
/// refuses another facility's payment unless the user is a Payments Editor.
class PaymentDetailScreen extends ConsumerWidget {
  /// [paymentId] is `null` for an address whose id isn't a number, which
  /// shows the not-found state instead of throwing.
  const PaymentDetailScreen({super.key, required this.paymentId});

  final int? paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = paymentId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentViewTitle)),
      body: id == null
          ? const _NotFound(paymentId: null)
          : ref
                .watch(paymentDetailProvider(id))
                .when(
                  // A write reloads the payment; keep the page on screen while
                  // it does, so the user stays where they were (spec 059).
                  skipLoadingOnReload: true,
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => error is NotFoundError
                      ? _NotFound(paymentId: id)
                      : ListFailedView(
                          error: toAppError(error),
                          retryLabel: l10n.retryButton,
                          onRetry: () {
                            ref.invalidate(paymentDetailProvider(id));
                            ref.invalidate(paymentApplicationsProvider(id));
                          },
                        ),
                  data: (payment) => _PaymentBody(payment: payment),
                ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.paymentId});

  final int? paymentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('payment_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(
            error: AppError.notFound(
              paymentId == null ? null : l10n.paymentNotFound(paymentId!),
            ),
          ),
          OutlinedButton(
            onPressed: () => context.go(paymentsPath),
            child: Text(l10n.paymentBackToList),
          ),
        ],
      ),
    );
  }
}

class _PaymentBody extends ConsumerWidget {
  const _PaymentBody({required this.payment});

  final CustomerPayment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final access = ref.watch(accessControlProvider);
    final spacing = Theme.of(context).spacing;
    final applications = ref.watch(
      paymentApplicationsProvider(payment.customerPaymentId),
    );
    final applied = applications.whenOrNull(
      data: (items) => appliedTotal(items),
    );

    final canOpenSession =
        payment.cashSessionId != null &&
        access.can(SystemObject.pos, AccessRight.read);

    // spec 060 FR-013: verify or reject an unverified payment. The right is
    // Payments Verification update, not a Customer Payments one: it mirrors
    // the server, where verification is its own right and acts on any
    // facility's payment.
    final canVerify =
        !payment.isVerified &&
        access.can(SystemObject.paymentsVerification, AccessRight.update);

    // spec 059 FR-005: money left to apply. Another facility's payment only
    // reaches this screen for a Payments Editor reader, whom the server lets
    // list that facility's outstanding orders (mbe-api#308).
    final canApply =
        compareAmounts(payment.unapplied, '0.01') > 0 &&
        access.can(SystemObject.customerPayments, AccessRight.create);

    // spec 074 FR-001: any payment can start a payment receipt, whatever its
    // state; the right is the server's, Create on FiscalDocuments (23).
    final canIssueReceipt = access.can(
      SystemObject.fiscalDocuments,
      AccessRight.create,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sectionGap,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.sm,
            children: [
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.paymentHeaderTitle(payment.customerPaymentId),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  PaymentVerifiedChip(verified: payment.isVerified),
                  if (canVerify) ...[
                    OutlinedButton.icon(
                      key: const Key('payment_verify_button'),
                      onPressed: () => _verify(context, payment),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(l10n.paymentVerifyAction),
                    ),
                    OutlinedButton.icon(
                      key: const Key('payment_reject_button'),
                      onPressed: () => _reject(context, payment),
                      icon: const Icon(Icons.block),
                      label: Text(l10n.paymentRejectAction),
                    ),
                  ],
                ],
              ),
              Wrap(
                spacing: spacing.sectionGap,
                runSpacing: spacing.sm,
                children: [
                  _Labeled(
                    key: const Key('payment_summary_amount'),
                    label: l10n.paymentSummaryAmount,
                    child: Text(
                      paymentAmountLabel(fmt, payment.amount, payment.currency),
                    ),
                  ),
                  _Labeled(
                    key: const Key('payment_summary_applied'),
                    label: l10n.paymentSummaryApplied,
                    // Loading shows a spinner and a failure shows "—": the
                    // total is unknown either way, and a wrong figure is
                    // worse than none.
                    child: applications.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            applied == null
                                ? emptyValuePlaceholder
                                : paymentAmountLabel(
                                    fmt,
                                    applied,
                                    payment.currency,
                                  ),
                          ),
                  ),
                  _Labeled(
                    key: const Key('payment_summary_unapplied'),
                    label: l10n.paymentSummaryUnapplied,
                    child: Text(
                      paymentAmountLabel(
                        fmt,
                        payment.unapplied,
                        payment.currency,
                      ),
                    ),
                  ),
                ],
              ),
              if (canApply || canIssueReceipt)
                Wrap(
                  spacing: spacing.md,
                  runSpacing: spacing.sm,
                  children: [
                    if (canApply)
                      OutlinedButton.icon(
                        key: const Key('payment_apply_button'),
                        onPressed: () =>
                            showApplyPaymentDialog(context, payment),
                        icon: const Icon(Icons.playlist_add_check),
                        label: Text(l10n.paymentApplyAction),
                      ),
                    if (canIssueReceipt)
                      OutlinedButton.icon(
                        key: const Key('payment_issue_receipt_button'),
                        onPressed: () => _issueReceipt(context, payment),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(l10n.paymentIssueReceiptAction),
                      ),
                  ],
                ),
            ],
          ),
          ResponsiveFormGrid(
            maxColumns: 2,
            spacing: spacing.fieldGapHorizontal,
            alignment: AlignmentDirectional.centerStart,
            children: [
              FormGridChild(
                _Labeled(
                  label: l10n.paymentsColumnCustomer,
                  child: PaymentCustomerName(
                    customerId: payment.customerId,
                    name: payment.customerName,
                  ),
                ),
              ),
              FormGridChild(
                _Labeled(
                  label: l10n.paymentsColumnDate,
                  child: Text(fmt.display.dateTime(payment.date)),
                ),
              ),
              FormGridChild(
                _Labeled(
                  label: l10n.paymentsColumnMethod,
                  child: Text(paymentMethodLabel(l10n, payment.methodCode)),
                ),
              ),
              FormGridChild(
                _Labeled(
                  label: l10n.paymentFieldPaymentOption,
                  child: payment.paymentOptionId == null
                      ? const Text(emptyValuePlaceholder)
                      : _OptionName(optionId: payment.paymentOptionId!),
                ),
              ),
              FormGridChild(
                _Labeled(
                  label: l10n.paymentsColumnReference,
                  child: Text(payment.reference ?? emptyValuePlaceholder),
                ),
              ),
              FormGridChild(
                _Labeled(
                  label: l10n.paymentsColumnType,
                  child: Text(paymentTypeLabel(l10n, payment.type)),
                ),
              ),
              FormGridChild(
                _Labeled(
                  label: l10n.paymentFieldFacility,
                  child: _FacilityName(facilityId: payment.facilityId),
                ),
              ),
              FormGridChild(
                _Labeled(
                  label: l10n.paymentFieldCashSession,
                  child: payment.cashSessionId == null
                      ? const Text(emptyValuePlaceholder)
                      : canOpenSession
                      ? TextButton(
                          key: const Key('payment_cash_session_link'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            alignment: AlignmentDirectional.centerStart,
                          ),
                          onPressed: () => context.push(
                            '/sales/cash-sessions/${payment.cashSessionId}',
                          ),
                          child: Text('#${payment.cashSessionId}'),
                        )
                      : Text('#${payment.cashSessionId}'),
                ),
              ),
              FormGridChild(
                _Labeled(
                  label: l10n.paymentFieldVerifier,
                  child: payment.verifierId == null
                      ? const Text(emptyValuePlaceholder)
                      : _EmployeeName(employeeId: payment.verifierId!),
                ),
              ),
              if (payment.lastRejection case final rejection?)
                FormGridChild(
                  _Labeled(
                    label: l10n.paymentFieldLastRejection,
                    child: PaymentRejectionDetails(rejection: rejection),
                  ),
                ),
              // spec 055 FR-001: the ticket of a credit payment or advance.
              // At the end of the grid, like the cash cut on its session, and
              // absent — not disabled — for any other type or without
              // Customer Payments read.
              if (canShowPaymentTicket(access, payment))
                FormGridChild(
                  span: FormGridSpan.full,
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: OutlinedButton.icon(
                      key: const Key('payment_view_ticket_button'),
                      onPressed: () => ref
                          .read(documentActionsProvider)
                          .preview(context, paymentTicketRef(l10n, payment)),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: Text(l10n.paymentViewTicketAction),
                    ),
                  ),
                ),
            ],
          ),
          _ApplicationsSection(
            paymentId: payment.customerPaymentId,
            currency: payment.currency,
            applications: applications,
          ),
        ],
      ),
    );
  }
}

/// "Emitir complemento de pago" (spec 074 C34): creates a payment-receipt draft
/// from [payment] and opens it. The dialog also answers the id of the receipt
/// the payment already has, when it does.
Future<void> _issueReceipt(
  BuildContext context,
  CustomerPayment payment,
) async {
  final id = await showNewFiscalDocumentDialog(
    context,
    NewFiscalDocumentMode.receiptFromPayment(payment),
  );
  if (id == null || !context.mounted) return;
  context.push('$fiscalDocumentsPath/$id');
}

/// Verifies [payment] after its confirmation, and says so once it went
/// through. The view reloads by itself: the write controller invalidates the
/// payment (spec 060 R4).
Future<void> _verify(BuildContext context, CustomerPayment payment) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(
    context,
  )!.paymentVerifiedSnack('${payment.customerPaymentId}');
  final done = await showVerifyPaymentDialog(context, payment);
  if (done) messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Rejects [payment] with a reason. The payment stays unverified, so the
/// buttons stay too (spec 060 FR-011).
Future<void> _reject(BuildContext context, CustomerPayment payment) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(
    context,
  )!.paymentRejectedSnack('${payment.customerPaymentId}');
  final done = await showRejectPaymentDialog(context, payment);
  if (done) messenger.showSnackBar(SnackBar(content: Text(message)));
}

class _Labeled extends StatelessWidget {
  const _Labeled({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        child,
      ],
    );
  }
}

/// A resolved name, or its number while loading and when it can't be
/// resolved (a removed option, an employee the user can't read).
class _OptionName extends ConsumerWidget {
  const _OptionName({required this.optionId});
  final int optionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(paymentMethodOptionNameProvider(optionId)).value ?? '#$optionId',
  );
}

class _FacilityName extends ConsumerWidget {
  const _FacilityName({required this.facilityId});
  final int facilityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(facilityDisplayNameProvider(facilityId)).value ?? '#$facilityId',
  );
}

class _EmployeeName extends ConsumerWidget {
  const _EmployeeName({required this.employeeId});
  final int employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(employeeDisplayNameProvider(employeeId)).value ?? '#$employeeId',
  );
}

class _ApplicationsSection extends ConsumerWidget {
  const _ApplicationsSection({
    required this.paymentId,
    required this.currency,
    required this.applications,
  });

  final int paymentId;
  final Currency currency;
  final AsyncValue<List<PaymentApplication>> applications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final spacing = Theme.of(context).spacing;
    final mutedStyle = TextStyle(color: Theme.of(context).disabledColor);
    // spec 059 FR-001: reversing is a Customer Payments update, as on the
    // server. Without it the table has no actions column at all.
    final canReverse = ref
        .watch(accessControlProvider)
        .can(SystemObject.customerPayments, AccessRight.update);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Text(
          l10n.paymentApplicationsTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        applications.when(
          // A write reloads the list; keep the rows while it does.
          skipLoadingOnReload: true,
          loading: () => const Center(child: CircularProgressIndicator()),
          // Only this section fails; the payment's own fields stay above it.
          error: (error, _) => ListFailedView(
            error: toAppError(error),
            retryLabel: l10n.retryButton,
            onRetry: () =>
                ref.invalidate(paymentApplicationsProvider(paymentId)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Text(
                l10n.paymentApplicationsEmpty,
                key: const Key('payment_applications_empty'),
              );
            }
            // A payment has few applications, so the table is unpaginated
            // (constitution §VI: a provably bounded set). `DataTableView`
            // needs a bounded height here, inside the scrolling page.
            return DataTableView<PaymentApplication>(
              key: const Key('payment_applications_table'),
              shrinkWrap: true,
              margin: EdgeInsets.zero,
              rows: items,
              rowActionsBuilder: canReverse
                  ? (context, a) => [
                      if (!a.reversed)
                        IconButton(
                          key: Key('payment_application_reverse_${a.id}'),
                          icon: const Icon(Icons.undo),
                          tooltip: l10n.paymentReverseTitle,
                          onPressed: () => reverseApplicationFlow(
                            context,
                            ref,
                            paymentId: paymentId,
                            applicationId: a.id,
                            saleId: a.saleId,
                            amount: paymentAmountLabel(fmt, a.amount, currency),
                          ),
                        ),
                    ]
                  : null,
              columns: [
                DataTableColumn(
                  label: l10n.paymentApplicationsColumnOrder,
                  fixedWidth: 110,
                  cellBuilder: (context, a) =>
                      _OrderCell(saleId: a.saleId, reversed: a.reversed),
                ),
                DataTableColumn(
                  label: l10n.paymentApplicationsColumnApplied,
                  numeric: true,
                  size: ColumnSize.M,
                  cellBuilder: (context, a) => Text(
                    paymentAmountLabel(fmt, a.amount, currency),
                    style: a.reversed ? mutedStyle : null,
                  ),
                ),
                DataTableColumn(
                  label: l10n.paymentApplicationsColumnChange,
                  numeric: true,
                  size: ColumnSize.M,
                  cellBuilder: (context, a) => Text(
                    paymentAmountLabel(fmt, a.change, currency),
                    style: a.reversed ? mutedStyle : null,
                  ),
                ),
                DataTableColumn(
                  label: l10n.paymentApplicationsColumnApplier,
                  size: ColumnSize.M,
                  cellBuilder: (context, a) => a.applierId == null
                      ? const Text(emptyValuePlaceholder)
                      : _EmployeeName(employeeId: a.applierId!),
                ),
                DataTableColumn(
                  label: l10n.paymentApplicationsColumnDate,
                  size: ColumnSize.M,
                  cellBuilder: (context, a) => Text(
                    fmt.display.dateTime(a.date),
                    style: a.reversed ? mutedStyle : null,
                  ),
                ),
                DataTableColumn(
                  label: l10n.paymentApplicationsColumnStatus,
                  fixedWidth: 130,
                  cellBuilder: (context, a) => a.reversed
                      ? const PaymentReversedChip()
                      : const Text(emptyValuePlaceholder),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// An application's order: a link when [orderLinkTargetProvider] finds a
/// destination the user can open, plain text otherwise (FR-015).
class _OrderCell extends ConsumerWidget {
  const _OrderCell({required this.saleId, required this.reversed});

  final int saleId;
  final bool reversed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(orderLinkTargetProvider(saleId)).value;
    final label = '#$saleId';
    final style = reversed
        ? TextStyle(color: Theme.of(context).disabledColor)
        : null;
    if (target == null) return Text(label, style: style);
    return TextButton(
      key: Key('payment_order_link_$saleId'),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: AlignmentDirectional.centerStart,
      ),
      onPressed: () => context.push(target),
      child: Text(label, style: style),
    );
  }
}
