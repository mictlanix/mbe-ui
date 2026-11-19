import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_actions.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Whether the trip's print actions are offered (spec 075 FR-020, research
/// R11): the user can read Delivery Itineraries and the trip has left. An
/// Abierto trip has no fixed sent quantities yet, and a cancelled one has no
/// stops left, so the server refuses both with a 409
/// (`itinerary.not_departed`, `itinerary.cancelled`); no action is offered for
/// them. One rule for the screen's two buttons, so they never disagree.
bool canPrintItinerary(AccessControlService access, ItineraryStatus status) =>
    (status == ItineraryStatus.departed || status == ItineraryStatus.closed) &&
    canOpenDocument(access, DocumentKind.itineraryTicket);

/// Opens the trip ticket of [itineraryId] in the shared preview (spec 044).
/// Printing records nothing and reloads nothing; a server 409 shows in the
/// preview itself.
Future<void> openItineraryTicket(
  BuildContext context,
  WidgetRef ref, {
  required int itineraryId,
}) {
  final l10n = AppLocalizations.of(context)!;
  return ref
      .read(documentActionsProvider)
      .preview(
        context,
        DocumentRef(
          kind: DocumentKind.itineraryTicket,
          recordId: itineraryId,
          title: l10n.documentItineraryTicketTitle('$itineraryId'),
        ),
      );
}

/// Opens the delivery notes of [itineraryId], one per stop, in the shared
/// preview.
Future<void> openItineraryDeliveryNotes(
  BuildContext context,
  WidgetRef ref, {
  required int itineraryId,
}) {
  final l10n = AppLocalizations.of(context)!;
  return ref
      .read(documentActionsProvider)
      .preview(
        context,
        DocumentRef(
          kind: DocumentKind.itineraryDeliveryNotes,
          recordId: itineraryId,
          title: l10n.documentItineraryNotesTitle('$itineraryId'),
        ),
      );
}
