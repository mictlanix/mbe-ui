import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/navigation/list_query.dart';
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

  group('LabelFilter.fromQuery (017-ui-consistency-filters FR-017)', () {
    test('derives every field from a ListQuery', () {
      final filter = LabelFilter.fromQuery(
        const ListQuery(search: 'Clearance', pageIndex: 2),
      );

      expect(filter.search, 'Clearance');
      expect(filter.pageIndex, 2);
    });

    test('defaults from an empty ListQuery', () {
      final filter = LabelFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.pageIndex, 0);
    });
  });

  group('LabelsListController (a family keyed by LabelFilter)', () {
    test('build(filter) maps the filter to repository query params', () async {
      when(
        () => repository.listDetailed(search: null, skip: 0, limit: 20),
      ).thenAnswer((_) async => LabelPage(items: [_label(1)], total: 1));

      const filter = LabelFilter();
      final result = await container.read(
        labelsListControllerProvider(filter).future,
      );

      expect(result.items, hasLength(1));
      expect(result.total, 1);
    });

    test(
      'a different search maps to a different provider instance and query',
      () async {
        when(
          () => repository.listDetailed(search: null, skip: 0, limit: 20),
        ).thenAnswer((_) async => LabelPage(items: [_label(1)], total: 1));
        when(
          () =>
              repository.listDetailed(search: 'Clearance', skip: 0, limit: 20),
        ).thenAnswer((_) async => LabelPage(items: [_label(2)], total: 1));

        final first = await container.read(
          labelsListControllerProvider(const LabelFilter()).future,
        );
        final second = await container.read(
          labelsListControllerProvider(
            const LabelFilter(search: 'Clearance'),
          ).future,
        );

        expect(first.items.single.labelId, 1);
        expect(second.items.single.labelId, 2);
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(
        () => repository.listDetailed(search: null, skip: 0, limit: 20),
      ).thenAnswer((_) async => LabelPage(items: [_label(1)], total: 21));
      when(
        () => repository.listDetailed(search: null, skip: 20, limit: 20),
      ).thenAnswer((_) async => LabelPage(items: [_label(2)], total: 21));

      final page0 = await container.read(
        labelsListControllerProvider(const LabelFilter()).future,
      );
      final page1 = await container.read(
        labelsListControllerProvider(const LabelFilter(pageIndex: 1)).future,
      );

      expect(page0.items.map((l) => l.labelId), [1]);
      expect(page0.pageIndex, 0);
      expect(page1.items.map((l) => l.labelId), [2]);
      expect(page1.pageIndex, 1);
      expect(page1.total, 21);
    });

    test(
      'invalidating the provider re-fetches the SAME page rather than '
      'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
      () async {
        const filter = LabelFilter(pageIndex: 1);
        when(
          () => repository.listDetailed(search: null, skip: 20, limit: 20),
        ).thenAnswer((_) async => LabelPage(items: [_label(2)], total: 21));

        await container.read(labelsListControllerProvider(filter).future);

        when(
          () => repository.listDetailed(search: null, skip: 20, limit: 20),
        ).thenAnswer((_) async => LabelPage(items: [_label(99)], total: 21));
        container.invalidate(labelsListControllerProvider(filter));

        final refreshed = await container.read(
          labelsListControllerProvider(filter).future,
        );
        expect(refreshed.pageIndex, 1);
        expect(refreshed.items.single.labelId, 99);
      },
    );
  });
}
