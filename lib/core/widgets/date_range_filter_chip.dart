import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A `FilterChip` reporting a selected date range, opening
/// `showDateRangePicker` on tap (spec 023 research R6). The first shared
/// filter of this shape in the product — no other catalog filters by a date
/// range today.
///
/// [isToday] marks the default state (`from == to == today`): the chip then
/// reads as the plain "Hoy" label with no clear affordance, matching every
/// other list screen's convention that the *default* filter state carries no
/// dismiss control. Any other range shows as selected, with a delete icon
/// that calls [onClear] — clearing returns to today, never to an unbounded
/// range, since an unfiltered sales query has been measured at 19k+ rows for
/// a single register.
///
/// A screen whose list has no default range (spec 054 Pagos) passes `null`
/// for [from] and [to]: the chip then reads "any date", unselected and with no
/// dismiss control, since there is nothing to clear.
class DateRangeFilterChip extends ConsumerWidget {
  const DateRangeFilterChip({
    super.key,
    required this.from,
    required this.to,
    required this.isToday,
    required this.onChanged,
    required this.onClear,
    this.firstDate,
  });

  final DateTime? from;
  final DateTime? to;
  final bool isToday;

  /// Called with the picker's chosen range when the cashier picks one.
  final ValueChanged<DateTimeRange> onChanged;

  /// Called when the cashier dismisses a non-default range — the caller
  /// removes the `date-from`/`date-to` facets entirely rather than
  /// re-encoding today's date, so the URL matches every other screen's
  /// "default state has no facet" convention.
  final VoidCallback onClear;

  /// The earliest selectable date. Defaults to a year before [to] — a
  /// generous, sane bound with no caller computation required.
  final DateTime? firstDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final isAny = from == null || to == null;
    final label = isAny
        ? l10n.dateRangeFilterAny
        : isToday
        ? l10n.dateRangeFilterToday
        : l10n.dateRangeFilterRange(
            fmt.display.date(from),
            fmt.display.date(to),
          );
    final isDefault = isAny || isToday;

    return FilterChip(
      key: const Key('date_range_filter_chip'),
      avatar: const Icon(Icons.calendar_month_outlined, size: 18),
      label: Text(label),
      tooltip: l10n.dateRangeFilterLabel,
      selected: !isDefault,
      showCheckmark: false,
      onSelected: (_) => _pick(context),
      deleteIcon: isDefault ? null : const Icon(Icons.close, size: 18),
      onDeleted: isDefault
          ? null
          : () {
              onClear();
            },
      deleteButtonTooltipMessage: l10n.dateRangeFilterClear,
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final effectiveFirstDate = firstDate ?? DateTime(now.year - 1);
    final effectiveLastDate = DateTime(now.year, now.month, now.day);
    final range = await showDateRangePicker(
      context: context,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      initialDateRange: from == null || to == null
          ? null
          : DateTimeRange(
              start: _clamp(from!, effectiveFirstDate, effectiveLastDate),
              end: _clamp(to!, effectiveFirstDate, effectiveLastDate),
            ),
    );
    if (range != null) onChanged(range);
  }

  /// Bounds [value] to `[min, max]` — callers' default ranges can extend past
  /// today (e.g. the sales orders screen defaults `to` the current month's
  /// last day), which `showDateRangePicker` rejects as an `initialDateRange`
  /// past its `lastDate`.
  static DateTime _clamp(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
  }
}
