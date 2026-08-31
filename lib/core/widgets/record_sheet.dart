import 'package:flutter/material.dart';

import 'app_side_sheet.dart';

/// Opens a single record — create, read-only view, or edit — in the app's
/// shared responsive panel (spec 035, US5), replacing what used to be a
/// pushed full-screen route for the 14 entities named in
/// specs/035-crud-ui-refinements/spec.md's Verbatim Constraints.
///
/// Every one of those 14 entities goes through this one function, so no
/// module invents its own record panel: it is [showAppSideSheet] pinned to
/// the record width (640 — wide enough that `ResponsiveFormGrid` still
/// produces two columns above the compact tier, since it measures its own
/// container rather than the screen; see research.md R6) with dismissal
/// confirmation wired to [isDirty].
///
/// [form] is built fresh each time the panel opens — the same widget
/// tree that used to be a `*DetailScreen`'s body (everything below its old
/// `Scaffold`/`AppBar`), taking the record's id (or none, for create) and a
/// read-only flag as constructor arguments in place of what used to be a
/// route parameter and a `?view=true` query parameter.
Future<void> showRecordSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder form,
  required bool Function() isDirty,
}) {
  return showAppSideSheet(
    context,
    title: title,
    builder: form,
    width: 640,
    confirmDismiss: isDirty,
  );
}
