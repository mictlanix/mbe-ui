import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_action_icons.dart';
import 'package:mbe_ui/core/widgets/compact_field.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart' show toAppError;
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/add_stop_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/close_stop_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itineraries_list_screen.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/delivery_itinerary_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_header_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_lookups.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_print.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_status_chip.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_stop_card.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One trip on its own screen (spec 075 ui-contract "Trip screen"), gated by
/// Delivery Itineraries (SystemObject 87) read.
///
/// A header band, the actions the trip's status allows, and a card per stop.
/// The AppBar has a title and no actions (constitution §VI): the actions are
/// buttons in the body, and each is absent, not disabled, when its right is
/// missing (§IV). The one disabled control is "Dar salida", whose reason is
/// shown under it (FR-012).
class DeliveryItineraryDetailScreen extends ConsumerWidget {
  /// [itineraryId] is `null` for an address whose id isn't a number, which
  /// shows the not-found state instead of throwing.
  const DeliveryItineraryDetailScreen({super.key, required this.itineraryId});

  final int? itineraryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final id = itineraryId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navDeliveryItineraries)),
        body: const _NotFound(error: AppError.notFound()),
      );
    }
    final detail = ref.watch(deliveryItineraryDetailControllerProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detail.value == null
              ? l10n.navDeliveryItineraries
              : l10n.itineraryTitle(detail.value!.id),
        ),
      ),
      // The trip stays on screen while a refused or unknown write reloads it,
      // so the refusal the screen is showing isn't lost with it.
      body: detail.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is NotFoundError
            ? _NotFound(error: error)
            : _LoadFailed(
                error: toAppError(error),
                onRetry: () => ref.invalidate(
                  deliveryItineraryDetailControllerProvider(id),
                ),
              ),
        data: (trip) => _TripBody(trip: trip),
      ),
    );
  }
}

/// Back to the list: pops when the list is underneath, otherwise goes there.
void _backToList(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(deliveryItinerariesPath);

class _NotFound extends StatelessWidget {
  const _NotFound({required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('itinerary_not_found'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          OutlinedButton(
            key: const Key('itinerary_back_to_list'),
            onPressed: () => _backToList(context),
            child: Text(l10n.itineraryNotFoundBack),
          ),
        ],
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.error, required this.onRetry});

  final AppError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    return Padding(
      padding: EdgeInsets.all(spacing.screenMargin),
      child: Column(
        key: const Key('itinerary_load_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.fieldGapVertical,
        children: [
          ErrorBanner(error: error),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              OutlinedButton(
                key: const Key('itinerary_back_to_list'),
                onPressed: () => _backToList(context),
                child: Text(l10n.itineraryNotFoundBack),
              ),
              FilledButton(
                key: const Key('itinerary_retry_button'),
                onPressed: onRetry,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripBody extends ConsumerStatefulWidget {
  const _TripBody({required this.trip});

  final Itinerary trip;

  @override
  ConsumerState<_TripBody> createState() => _TripBodyState();
}

class _TripBodyState extends ConsumerState<_TripBody> {
  /// The last write's refusal, shown above the stops until the next write.
  AppError? _refusal;

  Itinerary get _trip => widget.trip;

  void _onResult(ItineraryActionResult? result) {
    // `null` is the user backing out: leave what is shown.
    if (result == null || !mounted) return;
    setState(() => _refusal = result.error);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final access = ref.watch(accessControlProvider);
    final canUpdate = access.can(
      SystemObject.deliveryItineraries,
      AccessRight.update,
    );
    final canReadOrders = access.can(
      SystemObject.deliveryOrders,
      AccessRight.read,
    );
    final isOpen = _trip.status == ItineraryStatus.open;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(spacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing.fieldGapVertical,
          children: [
            _HeaderBand(
              trip: _trip,
              onEdit: isOpen && canUpdate
                  ? () async => _onResult(
                      await showItineraryHeaderDialog(context, trip: _trip),
                    )
                  : null,
            ),
            if (isOpen) _LicenceWarning(trip: _trip),
            if (_refusal != null) ItineraryRefusal(error: _refusal!),
            if (isOpen && canUpdate)
              _OpenActions(
                trip: _trip,
                canAddStop: canReadOrders,
                onResult: _onResult,
              ),
            // Print: a trip that has left, with read on 87 (FR-020). Printing
            // is read-only, so it stays on a closed trip.
            if (canPrintItinerary(access, _trip.status))
              Wrap(
                alignment: WrapAlignment.end,
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  OutlinedButton.icon(
                    key: const Key('itinerary_print_ticket'),
                    onPressed: () => openItineraryTicket(
                      context,
                      ref,
                      itineraryId: _trip.id,
                    ),
                    icon: const Icon(Icons.print_outlined),
                    label: Text(l10n.itineraryActionPrintTicket),
                  ),
                  OutlinedButton.icon(
                    key: const Key('itinerary_print_notes'),
                    onPressed: () => openItineraryDeliveryNotes(
                      context,
                      ref,
                      itineraryId: _trip.id,
                    ),
                    icon: const Icon(Icons.print_outlined),
                    label: Text(l10n.itineraryActionPrintNotes),
                  ),
                ],
              ),
            if (_trip.status == ItineraryStatus.cancelled)
              Text(
                l10n.itineraryCancelledNote,
                key: const Key('itinerary_cancelled_note'),
              ),
            for (final stop in _trip.stops)
              ItineraryStopCard(
                trip: _trip,
                stop: stop,
                canUpdate: canUpdate,
                onResult: _onResult,
                // A pending stop of a departed trip is closed from the
                // returned paperwork (FR-015), with update on 87.
                onCloseStop:
                    canUpdate &&
                        _trip.status == ItineraryStatus.departed &&
                        stop.isPending
                    ? () async => _onResult(
                        await showCloseStopDialog(
                          context,
                          trip: _trip,
                          stop: stop,
                        ),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

/// The trip's facts: status, date, vehicle, operator, dispatch warehouse,
/// the departure and return times once set, and the comment (FR-006, FR-013).
class _HeaderBand extends ConsumerWidget {
  const _HeaderBand({required this.trip, required this.onEdit});

  final Itinerary trip;

  /// "Editar encabezado", for an Abierto trip with update right.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    String name(String? text, int? id, {String? none}) =>
        text ?? (id == null ? (none ?? emptyValuePlaceholder) : '#$id');

    return FactStripRow(
      key: const Key('itinerary_facts'),
      facts: [
        CompactField(
          label: l10n.itineraryColumnStatus,
          child: ItineraryStatusChip(status: trip.status),
        ),
        CompactField(
          label: l10n.itineraryColumnDate,
          child: Text(fmt.display.date(trip.date)),
        ),
        CompactField(
          label: l10n.itineraryColumnVehicle,
          child: Text(name(trip.vehicleName, trip.vehicleId)),
        ),
        CompactField(
          label: l10n.itineraryColumnOperator,
          child: Text(
            name(
              trip.operatorName,
              trip.vehicleOperatorId,
              none: l10n.itineraryNoOperator,
            ),
          ),
        ),
        CompactField(
          label: l10n.itineraryColumnWarehouse,
          child: Text(name(trip.warehouseName, trip.warehouseId)),
        ),
        if (trip.departedAt != null)
          CompactField(
            label: l10n.itineraryColumnDeparture,
            child: Text(fmt.display.dateTime(trip.departedAt)),
          ),
        if (trip.returnedAt != null)
          CompactField(
            label: l10n.itineraryColumnReturn,
            child: Text(fmt.display.dateTime(trip.returnedAt)),
          ),
        if (trip.comment != null && trip.comment!.isNotEmpty)
          CompactField(
            label: l10n.itineraryHeaderComment,
            child: Text(trip.comment!),
          ),
      ],
      trailing: onEdit == null
          ? const SizedBox.shrink()
          : Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton.icon(
                key: const Key('itinerary_edit_header'),
                onPressed: onEdit,
                icon: Icon(CatalogAction.edit.icon),
                label: Text(l10n.itineraryEditHeader),
              ),
            ),
    );
  }
}

/// "La licencia de {operador} venció el {fecha}": advisory, blocks nothing
/// (FR-007). Built from the operator's expiry, never from the server's own
/// English warning (§III, research R4). Shown for an Abierto trip whose
/// operator's licence has expired; silent when the operator can't be read.
class _LicenceWarning extends ConsumerWidget {
  const _LicenceWarning({required this.trip});

  final Itinerary trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operatorId = trip.vehicleOperatorId;
    if (operatorId == null) return const SizedBox.shrink();
    final operator = ref.watch(vehicleOperatorProvider(operatorId)).value;
    if (operator == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      operator.expirationDate.year,
      operator.expirationDate.month,
      operator.expirationDate.day,
    );
    if (!expiry.isBefore(today)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final scheme = theme.colorScheme;
    final fmt = ref.watch(formattersProvider);
    return Container(
      key: const Key('itinerary_licence_warning'),
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(spacing.sm),
      ),
      child: Row(
        spacing: spacing.sm,
        children: [
          Icon(Icons.warning_amber_outlined, color: scheme.onTertiaryContainer),
          Expanded(
            child: Text(
              l10n.itineraryLicenseExpired(
                trip.operatorName ?? operator.driverName,
                fmt.display.date(operator.expirationDate),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Abierto trip's action bar (FR-008, FR-012, FR-014): "Agregar parada",
/// "Cancelar itinerario" and "Dar salida". "Agregar parada" needs read on
/// Delivery Orders (71) for its picker. "Dar salida" is disabled while the
/// trip can't depart, with the reason under it.
class _OpenActions extends ConsumerWidget {
  const _OpenActions({
    required this.trip,
    required this.canAddStop,
    required this.onResult,
  });

  final Itinerary trip;
  final bool canAddStop;
  final ValueChanged<ItineraryActionResult?> onResult;

  /// Why the trip can't depart yet, or `null` when it can (FR-012).
  String? _guard(AppLocalizations l10n) {
    if (trip.canDepart) return null;
    if (trip.loadedLineCount == 0) return l10n.itineraryDepartGuardNothing;
    final empty = trip.emptyStops.firstOrNull;
    return empty == null
        ? null
        : l10n.itineraryDepartGuardEmptyStop(empty.sequence);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final guard = _guard(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: spacing.xs,
      children: [
        Wrap(
          alignment: WrapAlignment.end,
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            OutlinedButton(
              key: const Key('itinerary_cancel'),
              onPressed: () async => onResult(
                await showCancelItineraryDialog(context, trip: trip),
              ),
              child: Text(l10n.itineraryActionCancel),
            ),
            if (canAddStop)
              OutlinedButton.icon(
                key: const Key('itinerary_add_stop'),
                onPressed: () async => onResult(
                  await showAddStopDialog(
                    context,
                    itineraryId: trip.id,
                    existingOrderIds: {
                      for (final s in trip.stops)
                        if (s.deliveryOrderId != null) s.deliveryOrderId!,
                    },
                  ),
                ),
                icon: Icon(CatalogAction.create.icon),
                label: Text(l10n.itineraryActionAddStop),
              ),
            FilledButton.icon(
              key: const Key('itinerary_depart'),
              onPressed: trip.canDepart
                  ? () async =>
                        onResult(await showDepartDialog(context, trip: trip))
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.itineraryActionDepart),
            ),
          ],
        ),
        if (guard != null)
          Text(
            guard,
            key: const Key('itinerary_depart_guard'),
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }
}
