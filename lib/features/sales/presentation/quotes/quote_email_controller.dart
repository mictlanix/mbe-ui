import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/quote_email.dart';

part 'quote_email_controller.freezed.dart';
part 'quote_email_controller.g.dart';

/// The most recipients one send may carry (spec 053 FR-010) — mbe-api's own
/// limit.
const quoteEmailMaxRecipients = 10;

/// Where a recipient chip's address came from; also its order in the dialog
/// (spec 053 FR-008).
enum RecipientOrigin { contact, fiscalRecipient, typed }

/// One selectable address in the dialog (spec 053 data-model.md).
@freezed
abstract class RecipientChip with _$RecipientChip {
  const RecipientChip._();

  const factory RecipientChip({
    /// Trimmed, in the case it was entered or stored.
    required String address,

    /// The contact's or fiscal recipient's name; `null` for a typed address.
    required String? owner,
    required RecipientOrigin origin,
  }) = _RecipientChip;

  /// Identity and de-duplication: addresses differing only in letter case are
  /// one chip.
  String get key => address.toLowerCase();

  /// "owner · address", or the address alone when nobody owns it (FR-008).
  String get label => owner == null ? address : '$owner · $address';
}

/// Why the last send failed (spec 053 FR-013), localized in the UI layer.
enum QuoteEmailFailure {
  /// 409 — the quote is no longer confirmed.
  notSendable,

  /// 422 — mbe-api refused the recipient list.
  invalidRecipients,

  /// 502 — the mail server refused the message.
  mailRefused,

  /// 503 — mail is not configured.
  mailUnavailable,

  /// Anything else, including no response at all.
  other,
}

/// The cause behind [error], from the status mbe-api answered with.
QuoteEmailFailure quoteEmailFailureOf(AppError error) => switch (error) {
  ServerError(statusCode: 409) => QuoteEmailFailure.notSendable,
  ServerError(statusCode: 502) => QuoteEmailFailure.mailRefused,
  ServerError(statusCode: 503) => QuoteEmailFailure.mailUnavailable,
  ValidationError() => QuoteEmailFailure.invalidRecipients,
  _ => QuoteEmailFailure.other,
};

/// What [QuoteEmailController.toggle] did.
enum RecipientToggleResult {
  toggled,

  /// Selecting would be an eleventh recipient.
  limitReached,

  /// A send is in flight, or the chip does not exist.
  ignored,
}

/// What [QuoteEmailController.addTyped] did.
enum AddTypedResult {
  /// A new chip, selected.
  added,

  /// The address was already a chip; it is selected now.
  selectedExisting,

  /// Not an address mbe-api would accept.
  invalid,

  /// Selecting would be an eleventh recipient.
  limitReached,

  /// A send is in flight.
  ignored,
}

/// The email dialog's state (spec 053 data-model.md). Scoped to one dialog
/// instance — auto-disposed when it closes, so each opening starts with
/// nothing selected (FR-009).
@freezed
abstract class QuoteEmailState with _$QuoteEmailState {
  const QuoteEmailState._();

  const factory QuoteEmailState({
    /// Contacts, then fiscal recipients, then typed addresses (FR-008).
    @Default(<RecipientChip>[]) List<RecipientChip> chips,

    /// The [RecipientChip.key]s the quote will go to — exactly the recipients.
    @Default(<String>{}) Set<String> selected,
    @Default(false) bool sending,
    QuoteEmailFailure? failure,

    /// The error behind [failure], for the shared `ErrorBanner`.
    AppError? failureError,

    /// Latches on a 409, so closing the dialog tells the screen to refresh
    /// (FR-014).
    @Default(false) bool sawNotSendable,
  }) = _QuoteEmailState;

  bool get atLimit => selected.length >= quoteEmailMaxRecipients;

  bool get canSend =>
      !sending &&
      selected.isNotEmpty &&
      selected.length <= quoteEmailMaxRecipients;

  /// The addresses to send to, in chip order.
  List<String> get recipients => [
    for (final chip in chips)
      if (selected.contains(chip.key)) chip.address,
  ];
}

@riverpod
class QuoteEmailController extends _$QuoteEmailController {
  @override
  QuoteEmailState build(int quoteId) => const QuoteEmailState();

  /// Adds a chip for each contact and fiscal-recipient address not already
  /// shown. Safe to call again — after a reload or a retry — because it never
  /// removes a chip or changes the selection. An address held by both a
  /// contact and a fiscal recipient shows once, under the contact's name.
  ///
  /// An address mbe-api would refuse is not offered: selecting it could only
  /// fail the whole send.
  void seed({
    required List<Contact> contacts,
    required List<TaxpayerRecipient> taxpayers,
  }) {
    final known = {for (final chip in state.chips) chip.key};
    final added = <RecipientChip>[];

    void offer(String? raw, String owner, RecipientOrigin origin) {
      final address = raw?.trim() ?? '';
      if (!isPlausibleEmail(address)) return;
      if (!known.add(address.toLowerCase())) return;
      added.add(RecipientChip(address: address, owner: owner, origin: origin));
    }

    for (final contact in contacts) {
      offer(contact.email, contact.name, RecipientOrigin.contact);
    }
    for (final taxpayer in taxpayers) {
      offer(taxpayer.email, taxpayer.name, RecipientOrigin.fiscalRecipient);
    }
    if (added.isEmpty) return;

    List<RecipientChip> group(RecipientOrigin origin) => [
      ...state.chips.where((c) => c.origin == origin),
      ...added.where((c) => c.origin == origin),
    ];
    state = state.copyWith(
      chips: [
        ...group(RecipientOrigin.contact),
        ...group(RecipientOrigin.fiscalRecipient),
        ...group(RecipientOrigin.typed),
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

  /// Adds [text] as a new chip, already selected — or, when it matches a chip
  /// already shown (any letter case), selects that one instead (FR-009a).
  /// A typed chip stays when it is deselected again.
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

  /// Sends the quote to the selected chips. Returns the server's receipt, or
  /// `null` when nothing was sent — [QuoteEmailState.failure] says why. The
  /// selection is kept on failure so the user can retry.
  Future<QuoteEmailReceipt?> send() async {
    if (!state.canSend) return null;
    state = state.copyWith(sending: true, failure: null, failureError: null);
    try {
      final receipt = await ref
          .read(salesQuoteRepositoryProvider)
          .email(quoteId: quoteId, recipients: state.recipients);
      return receipt;
    } on AppError catch (e) {
      if (!ref.mounted) return null;
      final failure = quoteEmailFailureOf(e);
      state = state.copyWith(
        failure: failure,
        failureError: e,
        sawNotSendable:
            state.sawNotSendable || failure == QuoteEmailFailure.notSendable,
      );
      return null;
    } finally {
      if (ref.mounted) state = state.copyWith(sending: false);
    }
  }

  void clearFailure() =>
      state = state.copyWith(failure: null, failureError: null);
}
