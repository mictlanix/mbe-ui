import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_issue_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issue_detail_controller.dart';

import 'inventory_issue_fixtures.dart';

class MockInventoryIssueRepository extends Mock
    implements InventoryIssueRepository {}

/// Spec 068 (T011).
void main() {
  late MockInventoryIssueRepository repository;
  late ProviderContainer container;
  final provider = inventoryIssueDetailControllerProvider(318);

  setUp(() {
    repository = MockInventoryIssueRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryIssueRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Keeps the autodispose family alive, as the screen does. Called after the
  /// stub, since listening builds the provider.
  void listen() => container.listen(provider, (_, _) {});

  test('loads the issue by id', () async {
    when(() => repository.get(318)).thenAnswer((_) async => anIssue());
    listen();

    expect(await container.read(provider.future), anIssue());
    verify(() => repository.get(318)).called(1);
  });

  test('a missing issue keeps its AppError', () async {
    when(
      () => repository.get(318),
    ).thenAnswer((_) async => throw const AppError.notFound());
    listen();

    await expectLater(
      container.read(provider.future),
      throwsA(isA<NotFoundError>()),
    );
    expect(container.read(provider).error, isA<NotFoundError>());
  });

  test('refresh() re-fetches the issue', () async {
    when(() => repository.get(318)).thenAnswer((_) async => anIssue());
    listen();
    await container.read(provider.future);
    when(() => repository.get(318)).thenAnswer(
      (_) async => anIssue(status: InventoryDocumentStatus.completed),
    );

    await container.read(provider.notifier).refresh();

    expect(
      container.read(provider).value?.status,
      InventoryDocumentStatus.completed,
    );
    verify(() => repository.get(318)).called(2);
  });
}
