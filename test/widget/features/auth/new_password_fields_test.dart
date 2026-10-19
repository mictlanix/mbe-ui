import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/auth/domain/entities/password_policy.dart';
import 'package:mbe_ui/features/auth/presentation/widgets/new_password_fields.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

void main() {
  final formKey = GlobalKey<FormState>();

  const serverDefault = PasswordPolicy(
    minLength: 8,
    requireUpper: true,
    requireLower: true,
    requireDigit: true,
    requireSymbol: false,
  );

  Future<void> pumpFields(
    WidgetTester tester, {
    Key? newFieldKey,
    AsyncValue<PasswordPolicy> policy = const AsyncData(serverDefault),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            key: formKey,
            child: NewPasswordFields(
              newFieldKey: newFieldKey ?? const Key('new_password_field'),
              newLabel: 'New',
              confirmLabel: 'Confirm',
              policy: policy,
              onNewChanged: (_) {},
              onConfirmChanged: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  final confirm = find.byKey(const Key('new_password_confirm_field'));
  final newField = find.byKey(const Key('new_password_field'));

  testWidgets('confirmation shows the mismatch error, and clears on match', (
    tester,
  ) async {
    await pumpFields(tester);

    await tester.enterText(newField, 'abc123');
    await tester.enterText(confirm, 'abc124');
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text("Passwords don't match"), findsOneWidget);

    await tester.enterText(confirm, 'abc123');
    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text("Passwords don't match"), findsNothing);
  });

  testWidgets('editing the new password re-validates the confirmation', (
    tester,
  ) async {
    await pumpFields(tester);

    await tester.enterText(newField, 'abc123');
    await tester.enterText(confirm, 'abc123');
    formKey.currentState!.validate();
    await tester.pump();
    expect(find.text("Passwords don't match"), findsNothing);

    await tester.enterText(newField, 'abc1234');
    await tester.pump();
    expect(find.text("Passwords don't match"), findsOneWidget);

    await tester.enterText(newField, 'abc123');
    await tester.pump();
    expect(find.text("Passwords don't match"), findsNothing);
  });

  testWidgets('uses the new-password key it is given', (tester) async {
    await pumpFields(tester, newFieldKey: const Key('password_field'));

    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(newField, findsNothing);
    expect(confirm, findsOneWidget);
  });

  group('rule checklist', () {
    final rules = find.byKey(const Key('password_rules'));

    Finder row(String name) => find.byKey(Key('password_rule_$name'));

    Color? iconColor(WidgetTester tester, String name) => tester
        .widget<Icon>(
          find.descendant(of: row(name), matching: find.byType(Icon)),
        )
        .color;

    testWidgets('shows one row per rule of the policy', (tester) async {
      await pumpFields(tester);

      expect(rules, findsOneWidget);
      for (final name in ['minLength', 'upper', 'lower', 'digit']) {
        expect(row(name), findsOneWidget);
      }
      expect(row('symbol'), findsNothing);
      expect(find.text('At least 8 characters'), findsOneWidget);
    });

    testWidgets('each row follows what the user types', (tester) async {
      await pumpFields(tester);
      final scheme = Theme.of(tester.element(rules)).colorScheme;

      await tester.enterText(newField, 'abc12345');
      await tester.pump();
      expect(iconColor(tester, 'minLength'), scheme.primary);
      expect(iconColor(tester, 'upper'), scheme.onSurfaceVariant);
      expect(iconColor(tester, 'lower'), scheme.primary);
      expect(iconColor(tester, 'digit'), scheme.primary);

      await tester.enterText(newField, 'Abc12345');
      await tester.pump();
      expect(iconColor(tester, 'upper'), scheme.primary);
    });

    testWidgets('a policy that failed to load shows the unavailable note', (
      tester,
    ) async {
      await pumpFields(
        tester,
        policy: AsyncError<PasswordPolicy>('boom', StackTrace.empty),
      );

      expect(rules, findsOneWidget);
      expect(
        find.text(
          "The password rules couldn't be loaded. The server will check your password.",
        ),
        findsOneWidget,
      );
      expect(row('minLength'), findsNothing);
    });

    testWidgets('is hidden while the policy loads', (tester) async {
      await pumpFields(tester, policy: const AsyncLoading<PasswordPolicy>());

      expect(rules, findsNothing);
    });
  });
}
