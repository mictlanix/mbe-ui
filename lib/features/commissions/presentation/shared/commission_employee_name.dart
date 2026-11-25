import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';

/// The employee behind an audit stamp ("Cerrado el … por …", spec 078
/// research R2): the name through the app's cached per-id provider, `…` while
/// loading, and `#id` when it can't be read (a missing Employees right, a
/// deleted record or a failed request). One line, ellipsized, with the full
/// text in a tooltip (constitution §VI).
class CommissionEmployeeName extends ConsumerWidget {
  const CommissionEmployeeName({super.key, required this.employeeId});

  final int employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref
        .watch(employeeDisplayNameProvider(employeeId))
        .when(
          data: (name) => name ?? '#$employeeId',
          loading: () => '…',
          error: (_, _) => '#$employeeId',
        );
    return Tooltip(
      message: text,
      child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
    );
  }
}
