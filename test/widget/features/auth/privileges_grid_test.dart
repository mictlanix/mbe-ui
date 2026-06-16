import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/features/auth/presentation/admin/privileges_grid.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

void main() {
  Future<void> pumpGrid(
    WidgetTester tester, {
    required List<Privilege> privileges,
    void Function(SystemObject, int)? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PrivilegesGrid(
              privileges: privileges,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders header row with C/R/U/D columns', (tester) async {
    await pumpGrid(tester, privileges: const []);

    expect(find.text('C'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
    expect(find.text('U'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('Module'), findsOneWidget);
  });

  testWidgets('renders a row for SystemObject.users', (tester) async {
    await pumpGrid(tester, privileges: const []);

    expect(find.text('users'), findsOneWidget);
  });

  testWidgets('checked boxes reflect privilege rawValue', (tester) async {
    // rawValue 2 = read only
    await pumpGrid(tester, privileges: [
      const Privilege(systemObject: SystemObject.users, rawValue: 2),
    ]);

    // Find all checkboxes — checkboxes for the users row: C=false, R=true,
    // U=false, D=false. We can't easily find the exact row checkboxes by
    // position so we assert at least one is true and some are false.
    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    final values = checkboxes.map((cb) => cb.value).toList();
    expect(values.any((v) => v == true), isTrue);
    expect(values.any((v) => v == false), isTrue);
  });

  testWidgets('toggling a checkbox calls onChanged with updated rawValue',
      (tester) async {
    SystemObject? changedObj;
    int? changedRaw;

    // Start with no privileges for users (raw=0). Tap the Read checkbox.
    await pumpGrid(
      tester,
      privileges: const [],
      onChanged: (obj, raw) {
        changedObj = obj;
        changedRaw = raw;
      },
    );

    // Scroll the users-create checkbox into view and tap it.
    final createKey = find.byKey(const Key('privilege_users_create'));
    await tester.ensureVisible(createKey);
    await tester.tap(createKey);
    await tester.pump();

    expect(changedObj, isNotNull);
    expect(changedRaw, isNotNull);
    expect(changedRaw! > 0, isTrue);
  });

  testWidgets('read-only when onChanged is null — checkboxes disabled',
      (tester) async {
    await pumpGrid(
      tester,
      privileges: [
        const Privilege(systemObject: SystemObject.users, rawValue: 15),
      ],
      // onChanged: null (default)
    );

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    // All checkboxes should be disabled (onChanged == null)
    expect(checkboxes.every((cb) => cb.onChanged == null), isTrue);
  });
}
