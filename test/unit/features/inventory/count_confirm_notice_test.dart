import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_confirm_notice.dart';

import 'inventory_count_fixtures.dart';

/// Spec 070 US4 (T027), research R9: the per-count confirm warnings.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('starts empty, shows warnings, and dismiss clears them', () {
    final provider = countConfirmNoticeProvider(412);
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);

    expect(container.read(provider).isEmpty, isTrue);

    final warnings = someCountWarnings();
    container.read(provider.notifier).show(warnings);
    expect(container.read(provider), warnings);

    container.read(provider.notifier).dismiss();
    expect(container.read(provider), const CountWarnings());
  });

  test('is kept per count', () {
    final a = container.listen(countConfirmNoticeProvider(412), (_, _) {});
    final b = container.listen(countConfirmNoticeProvider(413), (_, _) {});
    addTearDown(a.close);
    addTearDown(b.close);

    container
        .read(countConfirmNoticeProvider(412).notifier)
        .show(someCountWarnings());

    expect(container.read(countConfirmNoticeProvider(412)).isEmpty, isFalse);
    expect(container.read(countConfirmNoticeProvider(413)).isEmpty, isTrue);
  });

  test('is dropped once nothing listens (leaving the count)', () async {
    final provider = countConfirmNoticeProvider(412);
    final sub = container.listen(provider, (_, _) {});
    container.read(provider.notifier).show(someCountWarnings());

    sub.close();
    await container.pump();

    final again = container.listen(provider, (_, _) {});
    addTearDown(again.close);
    expect(container.read(provider).isEmpty, isTrue);
  });
}
