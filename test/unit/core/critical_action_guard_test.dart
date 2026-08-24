import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';

/// Spec 031 FR-001…FR-012, FR-024, FR-030 — the generic mechanism behind
/// every gate this feature adds. No sales concept appears anywhere in this
/// file (SC-010): [pendingWritesProvider] and [unconfirmedEditsProvider] are
/// exercised with a scope and a fixture that has nothing to do with a sale,
/// which is the proof spec 031's User Story 5 asks for (contracts/
/// critical-action-guard.md §6).
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  const scope = 'test-scope';
  const otherScope = 'other-scope';

  PendingWrites writes([String s = scope]) =>
      container.read(pendingWritesProvider(s).notifier);

  int count([String s = scope]) => container.read(pendingWritesProvider(s));

  group('track', () {
    test('two concurrent writes count 2, settle back to 0 one at a time', () async {
      final first = Completer<void>();
      final second = Completer<void>();

      final f1 = writes().track(() => first.future);
      expect(count(), 1);
      final f2 = writes().track(() => second.future);
      expect(count(), 2);

      first.complete();
      await f1;
      expect(count(), 1);

      second.complete();
      await f2;
      expect(count(), 0);
    });

    test('a throwing write still releases, and the error still reaches the caller', () async {
      await expectLater(
        writes().track(() => Future<void>.error(StateError('refused'))),
        throwsA(isA<StateError>()),
      );
      expect(count(), 0);
    });

    test('registering a write changes nothing about its result (FR-012)', () async {
      final result = await writes().track(() async => 42);
      expect(result, 42);
    });

    test("a write's new state is observable before the count reaches 0 (research R6)", () async {
      var published = false;
      await writes().track(() async {
        published = true;
        // `track`'s own decrement runs in its `finally`, after this
        // callback returns — so by the time it does, the caller's state is
        // already published, and any concurrent read of `count()` here
        // would still see the write as outstanding.
        expect(count(), 1);
      });
      expect(published, isTrue);
      expect(count(), 0);
    });
  });

  group('begin/end (holds)', () {
    test('begin increments, end decrements, a second end is a no-op', () {
      final token = writes().begin();
      expect(count(), 1);
      writes().end(token);
      expect(count(), 0);
      writes().end(token);
      expect(count(), 0);
    });

    test('a token from one scope does nothing in another', () {
      final token = writes(scope).begin();
      writes(otherScope).end(token);
      expect(count(scope), 1);
      expect(count(otherScope), 0);
    });
  });

  group('reset', () {
    test('zeroes an idle scope', () {
      writes().reset();
      expect(count(), 0);
    });

    test('dropping a non-zero count trips the debug assertion', () {
      writes().begin();
      expect(() => writes().reset(), throwsA(isA<AssertionError>()));
    });
  });

  group('scope isolation', () {
    test('two scopes count independently', () {
      writes(scope).begin();
      writes(scope).begin();
      writes(otherScope).begin();
      expect(count(scope), 2);
      expect(count(otherScope), 1);
    });
  });

  group('unconfirmedEditsProvider', () {
    List<UnconfirmedEdit> edits([String s = scope]) =>
        container.read(unconfirmedEditsProvider(s));

    UnconfirmedEdits registry([String s = scope]) =>
        container.read(unconfirmedEditsProvider(s).notifier);

    UnconfirmedEdit entry(Object id, String text) => UnconfirmedEdit(
      id: id,
      text: text,
      confirm: () async => true,
      discard: () {},
      resume: () {},
    );

    test('put adds, put(same id) replaces, remove clears', () {
      registry().put(entry('a', '15'));
      expect(edits(), hasLength(1));
      expect(edits().single.text, '15');

      registry().put(entry('a', '25'));
      expect(edits(), hasLength(1));
      expect(edits().single.text, '25');

      registry().remove('a');
      expect(edits(), isEmpty);
    });

    test('removing an id that is not present is a no-op', () {
      registry().put(entry('a', '15'));
      registry().remove('missing');
      expect(edits(), hasLength(1));
    });

    test('two scopes hold independent registries', () {
      registry(scope).put(entry('a', '15'));
      expect(edits(scope), hasLength(1));
      expect(edits(otherScope), isEmpty);
    });
  });

  group('adoption by an unrelated critical action (US5, SC-010)', () {
    // Styled after a screen with its own critical submit and nothing to do
    // with a sale — e.g. applying a privilege profile
    // (`lib/features/auth/presentation/admin/apply_profile_dialog.dart`).
    // The point is that nothing below imports anything from
    // `package:mbe_ui/features/sales/`.
    const applyProfileScope = 'apply-profile';

    test('the whole mechanism works end to end for a non-sales operation', () async {
      final applied = Completer<void>();
      final track = container
          .read(pendingWritesProvider(applyProfileScope).notifier)
          .track(() => applied.future);

      expect(
        container.read(pendingWritesProvider(applyProfileScope)),
        1,
        reason: 'the critical action is gated the same way a POS step is',
      );

      applied.complete();
      await track;
      expect(container.read(pendingWritesProvider(applyProfileScope)), 0);
    });
  });
}
