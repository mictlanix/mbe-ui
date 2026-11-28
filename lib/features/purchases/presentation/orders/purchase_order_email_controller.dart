import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/sales/domain/quote_email.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_email_controller.dart'
    show
        AddTypedResult,
        RecipientChip,
        RecipientOrigin,
        RecipientToggleResult,
        quoteEmailMaxRecipients;

part 'purchase_order_email_controller.freezed.dart';
part 'purchase_order_email_controller.g.dart';

/// The longest message mbe-api accepts (spec 080 FR-027).
const purchaseOrderEmailMessageMaxLength = 1000;

/// Where the supplier-contact suggestions stand (research R14).
enum EmailSuggestions {
  /// No supplier, or no read on Suppliers (SystemObject 3): none offered.
  none,
  loading,
  loaded,

  /// The supplier couldn't be read; typing an address still works.
  failed,
}

/// Why the last send failed (FR-028), recognized by the error's code, never
/// by its status or its text (§III). The banner text itself comes from the
/// code through the shared localizer.
enum PurchaseOrderEmailFailure {
  /// `purchase_order.not_confirmed`: the order is no longer confirmed, so the
  /// screen behind is out of date.
  notConfirmed,

  /// `email.send_failed`: the mail server refused the message.
  sendFailed,

  /// `email.not_configured`: mail is not set up on the server.
  notConfigured,

  /// Anything else, a refused recipient list or no response included.
  other,
}

/// The cause behind [error], from its code.
PurchaseOrderEmailFailure purchaseOrderEmailFailureOf(AppError error) =>
    switch (error.problem?.code) {
      api.ErrorCode.purchaseOrderPeriodNotConfirmed =>
        PurchaseOrderEmailFailure.notConfirmed,
      api.ErrorCode.emailPeriodSendFailed =>
        PurchaseOrderEmailFailure.sendFailed,
      api.ErrorCode.emailPeriodNotConfigured =>
        PurchaseOrderEmailFailure.notConfigured,
      _ => PurchaseOrderEmailFailure.other,
    };

/// The email dialog's state (research R14). Scoped to one dialog instance:
/// auto-disposed when it closes, so each opening starts empty.
@freezed
abstract class PurchaseOrderEmailState with _$PurchaseOrderEmailState {
  const PurchaseOrderEmailState._();

  const factory PurchaseOrderEmailState({
    /// Supplier contacts first, then typed addresses.
    @Default(<RecipientChip>[]) List<RecipientChip> chips,

    /// The [RecipientChip.key]s the order will go to.
    @Default(<String>{}) Set<String> selected,
    @Default('') String message,
    @Default(EmailSuggestions.none) EmailSuggestions suggestions,
    @Default(false) bool sending,
    PurchaseOrderEmailFailure? failure,

    /// The error behind [failure], for the banner.
    AppError? failureError,

    /// Latches on `purchase_order.not_confirmed`, so closing the dialog tells
    /// the detail screen to reload.
    @Default(false) bool sawNotConfirmed,
  }) = _PurchaseOrderEmailState;

  bool get atLimit => selected.length >= quoteEmailMaxRecipients;

  bool get canSend =>
      !sending &&
      selected.isNotEmpty &&
      selected.length <= quoteEmailMaxRecipients &&
      message.length <= purchaseOrderEmailMessageMaxLength;

  /// The addresses to send to, in chip order.
  List<String> get recipients => [
    for (final chip in chips)
      if (selected.contains(chip.key)) chip.address,
  ];
}

@riverpod
class PurchaseOrderEmailController extends _$PurchaseOrderEmailController {
  @override
  PurchaseOrderEmailState build(int orderId) => const PurchaseOrderEmailState();

  /// Offers [supplierId]'s contacts that have an email, with read on
  /// Suppliers (SystemObject 3); nothing otherwise. A failure leaves the
  /// dialog usable: the user types the address.
  Future<void> loadSuggestions(int? supplierId) async {
    final canRead = ref
        .read(accessControlProvider)
        .can(SystemObject.suppliers, AccessRight.read);
    if (supplierId == null || !canRead) return;
    state = state.copyWith(suggestions: EmailSuggestions.loading);
    try {
      final supplier = await ref
          .read(supplierRepositoryProvider)
          .get(supplierId: supplierId);
      if (!ref.mounted) return;
      seed(supplier.contacts);
      state = state.copyWith(suggestions: EmailSuggestions.loaded);
    } on AppError {
      if (!ref.mounted) return;
      state = state.copyWith(suggestions: EmailSuggestions.failed);
    }
  }

  /// Adds a chip for each contact address not already shown, before any
  /// typed one. An address mbe-api would refuse is not offered.
  void seed(List<Contact> contacts) {
    final known = {for (final chip in state.chips) chip.key};
    final added = <RecipientChip>[];
    for (final contact in contacts) {
      final address = contact.email?.trim() ?? '';
      if (!isPlausibleEmail(address)) continue;
      if (!known.add(address.toLowerCase())) continue;
      added.add(
        RecipientChip(
          address: address,
          owner: contact.name,
          origin: RecipientOrigin.contact,
        ),
      );
    }
    if (added.isEmpty) return;
    state = state.copyWith(
      chips: [
        ...state.chips.where((c) => c.origin == RecipientOrigin.contact),
        ...added,
        ...state.chips.where((c) => c.origin != RecipientOrigin.contact),
      ],
    );
  }

  /// Selects or deselects the chip with [key]; an eleventh selection is
  /// refused.
  RecipientToggleResult toggle(String key) {
    if (state.sending || !state.chips.any((c) => c.key == key)) {
      return RecipientToggleResult.ignored;
    }
    if (state.selected.contains(key)) {
      state = state.copyWith(selected: {...state.selected}..remove(key));
      return RecipientToggleResult.toggled;
    }
    if (state.atLimit) return RecipientToggleResult.limitReached;
    state = state.copyWith(selected: {...state.selected, key});
    return RecipientToggleResult.toggled;
  }

  /// Adds [text] as a new selected chip, or selects the chip already showing
  /// it (any letter case).
  AddTypedResult addTyped(String text) {
    if (state.sending) return AddTypedResult.ignored;
    final address = text.trim();
    if (!isPlausibleEmail(address)) return AddTypedResult.invalid;
    final key = address.toLowerCase();
    if (!state.selected.contains(key) && state.atLimit) {
      return AddTypedResult.limitReached;
    }
    if (state.chips.any((c) => c.key == key)) {
      state = state.copyWith(selected: {...state.selected, key});
      return AddTypedResult.selectedExisting;
    }
    state = state.copyWith(
      chips: [
        ...state.chips,
        RecipientChip(
          address: address,
          owner: null,
          origin: RecipientOrigin.typed,
        ),
      ],
      selected: {...state.selected, key},
    );
    return AddTypedResult.added;
  }

  void setMessage(String message) => state = state.copyWith(message: message);

  /// Sends the order to the selected chips with the message (none when it
  /// is blank). Returns the server's receipt, or `null` when nothing was
  /// sent: [PurchaseOrderEmailState.failureError] holds the refusal and the
  /// input is kept for a retry.
  Future<OrderEmailReceipt?> send() async {
    if (!state.canSend) return null;
    state = state.copyWith(sending: true, failure: null, failureError: null);
    final message = state.message.trim();
    try {
      return await ref
          .read(purchaseOrderRepositoryProvider)
          .email(
            orderId,
            recipients: state.recipients,
            message: message.isEmpty ? null : message,
          );
    } on AppError catch (e) {
      if (!ref.mounted) return null;
      final failure = purchaseOrderEmailFailureOf(e);
      state = state.copyWith(
        failure: failure,
        failureError: e,
        sawNotConfirmed:
            state.sawNotConfirmed ||
            failure == PurchaseOrderEmailFailure.notConfirmed,
      );
      return null;
    } finally {
      if (ref.mounted) state = state.copyWith(sending: false);
    }
  }

  void clearFailure() =>
      state = state.copyWith(failure: null, failureError: null);
}
