import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/approval_queue_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/approval_selection.dart';

import 'purchase_request_fixtures.dart';

class MockPurchaseRequestRepository extends Mock
    implements PurchaseRequestRepository {}

/// Spec 079 FR-023, research R10 (T020).
void main() {
  late MockPurchaseRequestRepository repository;
  late ProviderContainer container;
  const filter = ApprovalQueueFilter();
  final selection = approvalSelectionProvider(filter);

  setUp(() async {
    repository = MockPurchaseRequestRepository();
    when(
      () => repository.approvalQueue(
        facilityId: any(named: 'facilityId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => PurchaseRequestPage(
        items: [aRequestSummary(id: 1), aRequestSummary(id: 2)],
        total: 2,
        pageIndex: 0,
        pageSize: 20,
      ),
    );
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseRequestRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    // The screen keeps both alive.
    container.listen(selection, (_, _) {});
    await container.read(approvalQueueControllerProvider(filter).future);
  });

  ApprovalSelection notifier() => container.read(selection.notifier);

  test('starts empty', () {
    expect(container.read(selection), isEmpty);
    expect(notifier().count, 0);
  });

  test('toggle adds and removes an id', () {
    notifier().toggle(1);
    notifier().toggle(2);
    expect(container.read(selection), {1, 2});
    expect(notifier().count, 2);

    notifier().toggle(1);
    expect(container.read(selection), {2});
  });

  test('selectAll picks the given ids and clear empties it', () {
    notifier().selectAll([1, 2]);
    expect(container.read(selection), {1, 2});

    notifier().clear();
    expect(container.read(selection), isEmpty);
  });

  test('another page or facility has its own, empty selection', () {
    notifier().toggle(1);

    expect(
      container.read(
        approvalSelectionProvider(const ApprovalQueueFilter(pageIndex: 1)),
      ),
      isEmpty,
    );
    expect(
      container.read(
        approvalSelectionProvider(const ApprovalQueueFilter(facilityId: 2)),
      ),
      isEmpty,
    );
  });

  test('empties when the page reloads, as after any approval', () async {
    notifier().selectAll([1, 2]);

    container.invalidate(approvalQueueControllerProvider);
    await container.read(approvalQueueControllerProvider(filter).future);

    expect(container.read(selection), isEmpty);
  });
}
