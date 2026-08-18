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

  final DateTime from;
  final DateTime to;
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
    final label = isToday
        ? l10n.dateRangeFilterToday
        : l10n.dateRangeFilterRange(
            fmt.display.date(from),
            fmt.display.date(to),
          );

    return FilterChip(
      key: const Key('date_range_filter_chip'),
      avatar: const Icon(Icons.calendar_month_outlined, size: 18),
      label: Text(label),
      tooltip: l10n.dateRangeFilterLabel,
      selected: !isToday,
      showCheckmark: false,
      onSelected: (_) => _pick(context),
      deleteIcon: isToday ? null : const Icon(Icons.close, size: 18),
      onDeleted: isToday
          ? null
          : () {
              onClear();
            },
      deleteButtonTooltipMessage: l10n.dateRangeFilterClear,
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: DateTimeRange(start: from, end: to),
    );
    if (range != null) onChanged(range);
  }
}
