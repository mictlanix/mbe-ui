import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/record_form_actions.dart';

Future<void> _pump(WidgetTester tester, Widget child, {double width = 1200}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, child: Align(alignment: Alignment.topLeft, child: child)),
      ),
    ),
  );
}

void main() {
  group('RecordFormActions (017-ui-consistency-filters contracts/record-form-actions.md §7)', () {
    testWidgets('create mode with Save privileged: renders Save only', (tester) async {
      var saved = false;
      await _pump(
        tester,
        RecordFormActions(
          mode: RecordFormMode.create,
          saveLabel: 'Save',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
          onSave: () => saved = true,
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);

      await tester.tap(find.text('Save'));
      expect(saved, isTrue);
    });

    testWidgets('create mode without Save privilege: renders nothing', (tester) async {
      await _pump(
        tester,
        const RecordFormActions(
          mode: RecordFormMode.create,
          saveLabel: 'Save',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
        ),
      );

      expect(find.text('Save'), findsNothing);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      expect(find.byType(SizedBox).first, findsOneWidget);
    });

    testWidgets(
      'create mode structurally cannot render Edit or Delete even if those '
      'callbacks are mistakenly supplied (mode gates, not just RBAC)',
      (tester) async {
        await _pump(
          tester,
          RecordFormActions(
            mode: RecordFormMode.create,
            saveLabel: 'Save',
            editLabel: 'Edit',
            deleteLabel: 'Delete',
            onSave: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        );

        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Edit'), findsNothing);
        expect(find.text('Delete'), findsNothing);
      },
    );

    testWidgets('view mode with update privilege: renders Edit only', (tester) async {
      var editTapped = false;
      await _pump(
        tester,
        RecordFormActions(
          mode: RecordFormMode.view,
          saveLabel: 'Save',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
          onEdit: () => editTapped = true,
        ),
      );

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(find.text('Delete'), findsNothing);

      await tester.tap(find.text('Edit'));
      expect(editTapped, isTrue);
    });

    testWidgets('view mode without update privilege: renders no Edit', (tester) async {
      await _pump(
        tester,
        const RecordFormActions(
          mode: RecordFormMode.view,
          saveLabel: 'Save',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
        ),
      );

      expect(find.text('Edit'), findsNothing);
    });

    testWidgets(
      'view mode structurally cannot render Save even if onSave is supplied',
      (tester) async {
        await _pump(
          tester,
          RecordFormActions(
            mode: RecordFormMode.view,
            saveLabel: 'Save',
            editLabel: 'Edit',
            deleteLabel: 'Delete',
            onEdit: () {},
            onSave: () {},
          ),
        );

        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Save'), findsNothing);
      },
    );

    testWidgets('edit mode with update+delete privilege: renders Delete then Save, in that order', (
      tester,
    ) async {
      await _pump(
        tester,
        RecordFormActions(
          mode: RecordFormMode.edit,
          saveLabel: 'Save',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
          onSave: () {},
          onDelete: () {},
        ),
      );

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);

      // Delete is leftmost, Save is rightmost (contract §2 order).
      final deleteX = tester.getTopLeft(find.text('Delete')).dx;
      final saveX = tester.getTopLeft(find.text('Save')).dx;
      expect(deleteX, lessThan(saveX));
    });

    testWidgets('edit mode without delete privilege: renders Save only', (tester) async {
      await _pump(
        tester,
        RecordFormActions(
          mode: RecordFormMode.edit,
          saveLabel: 'Save',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
          onSave: () {},
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets(
      'isSubmitting suppresses every callback and shows a progress indicator on Save',
      (tester) async {
        var saveCalls = 0;
        var deleteCalls = 0;
        await _pump(
          tester,
          RecordFormActions(
            mode: RecordFormMode.edit,
            saveLabel: 'Save',
            editLabel: 'Edit',
            deleteLabel: 'Delete',
            onSave: () => saveCalls++,
            onDelete: () => deleteCalls++,
            isSubmitting: true,
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Save'), findsNothing);

        // Both remain present (disabled), not hidden — busy-state disables,
        // RBAC hides.
        final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
        final deleteButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
        expect(saveButton.onPressed, isNull);
        expect(deleteButton.onPressed, isNull);
      },
    );

    testWidgets('delete invokes its callback only after confirmation', (tester) async {
      var deleted = false;
      await _pump(
        tester,
        RecordFormActions(
          mode: RecordFormMode.edit,
          saveLabel: 'Save',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
          onSave: () {},
          onDelete: () => deleted = true,
          deleteConfirmation: const RecordDeleteConfirmation(
            title: 'Delete this record?',
            message: 'This cannot be undone.',
            confirmLabel: 'Delete',
            cancelLabel: 'Cancel',
          ),
        ),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this record?'), findsOneWidget);
      expect(deleted, isFalse);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(deleted, isFalse);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });

    testWidgets(
      'buttons are not stretched to the form width on a wide (Expanded-tier) layout',
      (tester) async {
        await _pump(
          tester,
          RecordFormActions(
            mode: RecordFormMode.edit,
            saveLabel: 'Save',
            editLabel: 'Edit',
            deleteLabel: 'Delete',
            onSave: () {},
            onDelete: () {},
          ),
          width: 1200,
        );

        final saveWidth = tester.getSize(find.widgetWithText(FilledButton, 'Save')).width;
        // A stretched button would be close to the full 1200px container;
        // a content-sized one is a few tens of pixels wide.
        expect(saveWidth, lessThan(300));
      },
    );
  });
}
