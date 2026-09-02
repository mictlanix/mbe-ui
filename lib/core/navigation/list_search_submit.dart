import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'list_query.dart';

/// Submits a [CatalogSearchBar]'s value the way every catalog list screen
/// should (spec 035 FR-008/FR-009/FR-011): a **changed** term navigates —
/// resetting to page 0, exactly as before — and an **unchanged** term
/// instead calls [refresh] (the same `ref.invalidate(...)` closure a screen
/// already passes to `CatalogListStateView.onRetry`), re-fetching the
/// current page/sort/facets without any navigation at all.
///
/// Exactly one of the two happens per submission — never both, and never
/// neither — so pressing search always produces a fresh server response
/// (research.md R4), whether or not the user actually typed anything new.
/// `CatalogSearchBar` itself is untouched: it still exposes no `onChanged`,
/// so per-keystroke fetching stays impossible to wire by mistake.
void submitCatalogSearch({
  required BuildContext context,
  required ListQuery query,
  required String path,
  required String submitted,
  required String current,
  required VoidCallback refresh,
}) {
  if (submitted == current) {
    refresh();
    return;
  }
  context.go(
    query.copyWith(search: submitted, pageIndex: 0).toUri(path).toString(),
  );
}
