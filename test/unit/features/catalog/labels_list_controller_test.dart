import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/labels_list_controller.dart';

class MockLabelRepository extends Mock implements LabelRepository {}

Label _label(int id) => Label(labelId: id, name: 'Label $id');

void main() {
  late MockLabelRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockLabelRepository();
    container = ProviderContainer(
      overrides: [labelRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('LabelSearchController', () {
    test('starts empty', () {
      expect(container.read(labelSearchControllerProvider), '');
    });

    test('updates on searchChanged', () {
      container
          .read(labelSearchControllerProvider.notifier)
          .searchChanged('Clearance');
      expect(container.read(labelSearchControllerProvider), 'Clearance');
    });
  });

  group('LabelsListController', () {
    test(
      'build() maps the current search to repository query params',
      () async {
        when(
          () => repository.listDetailed(search: null, skip: 0, limit: 20),
        ).thenAnswer((_) async => LabelPage(items: [_label(1)], total: 1));

        final result = await container.read(labelsListControllerProvider.future);

        expect(result.items, hasLength(1));
        expect(result.total, 1);
      },
    );

    test('changing the search text re-fetches from skip=0', () async {
      when(
        () => repository.listDetailed(search: null, skip: 0, limit: 20),
      ).thenAnswer((_) async => LabelPage(items: [_label(1)], total: 1));
      await container.read(labelsListControllerProvider.future);

      when(
        () => repository.listDetailed(search: 'Clearance', skip: 0, limit: 20),
      ).thenAnswer((_) async => LabelPage(items: [_label(2)], total: 1));
      container
          .read(labelSearchControllerProvider.notifier)
          .searchChanged('Clearance');

      final result = await container.read(labelsListControllerProvider.future);
      expect(result.items.single.labelId, 2);
    });

    test('goToPage replaces the current page with the requested one', () async {
      when(
        () => repository.listDetailed(search: null, skip: 0, limit: 20),
      ).thenAnswer((_) async => LabelPage(items: [_label(1)], total: 21));
      await container.read(labelsListControllerProvider.future);

      when(
        () => repository.listDetailed(search: null, skip: 20, limit: 20),
      ).thenAnswer((_) async => LabelPage(items: [_label(2)], total: 21));

      await container.read(labelsListControllerProvider.notifier).goToPage(1);

      final page = container.read(labelsListControllerProvider).value!;
      expect(page.items.map((l) => l.labelId), [2]);
      expect(page.pageIndex, 1);
      expect(page.total, 21);
    });
  });
}
