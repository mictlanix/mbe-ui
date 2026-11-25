import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/settings/product_labels_controller.dart';

import '../../../widget/features/commissions/commission_harness.dart';

CommissionProductLabel _row(int product, {int label = 3}) =>
    CommissionProductLabel(
      productId: product,
      productCode: 'P$product',
      productName: 'Producto $product',
      labelId: label,
    );

void main() {
  late MockCommissionRepository repo;
  late ProviderContainer c;
  var reads = 0;

  setUp(() {
    repo = MockCommissionRepository();
    reads = 0;
    when(
      () => repo.listProductLabels(
        labelId: any(named: 'labelId'),
        productId: any(named: 'productId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      reads++;
      return CommissionProductLabelPage(items: [_row(1)], total: 45);
    });
    c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [commissionRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
  });

  Future<ProductLabelsController> start() async {
    c.listen(productLabelsControllerProvider, (_, _) {});
    await c.read(productLabelsControllerProvider.future);
    return c.read(productLabelsControllerProvider.notifier);
  }

  ProductLabelsView view() =>
      c.read(productLabelsControllerProvider).requireValue;

  test('the first page is 20 rows with no filter', () async {
    await start();
    verify(
      () => repo.listProductLabels(
        labelId: null,
        productId: null,
        skip: 0,
        limit: 20,
      ),
    ).called(1);
    expect(view().page.total, 45);
  });

  test('filters go as commission and product, and reset the page', () async {
    final n = await start();
    await n.setPage(2);
    verify(
      () => repo.listProductLabels(
        labelId: null,
        productId: null,
        skip: 40,
        limit: 20,
      ),
    ).called(1);
    expect(view().pageIndex, 2);

    await n.setLabel(3);
    verify(
      () => repo.listProductLabels(
        labelId: 3,
        productId: null,
        skip: 0,
        limit: 20,
      ),
    ).called(1);
    expect(view().pageIndex, 0);

    await n.setProduct(9);
    verify(
      () =>
          repo.listProductLabels(labelId: 3, productId: 9, skip: 0, limit: 20),
    ).called(1);

    await n.clearFilters();
    expect((view().labelId, view().productId), (null, null));
  });

  test('set and remove write, then re-read the page', () async {
    when(() => repo.setProductLabel(5, 3)).thenAnswer((_) async => _row(5));
    when(() => repo.removeProductLabel(5)).thenAnswer((_) async {});
    final n = await start();
    expect(reads, 1);

    expect(await n.set(5, 3), isNull);
    verify(() => repo.setProductLabel(5, 3)).called(1);
    expect(reads, 2);

    expect(await n.remove(5), isNull);
    verify(() => repo.removeProductLabel(5)).called(1);
    expect(reads, 3);
  });

  test('a refusal is answered, and the page is still re-read', () async {
    when(() => repo.setProductLabel(5, 3)).thenThrow(
      aRefusal(
        api.ErrorCode.resourcePeriodAlreadyExists,
        'resource.already_exists',
      ),
    );
    final n = await start();
    expect(await n.set(5, 3), isNotNull);
    expect(reads, 2);
  });

  test(
    'removing the last row of a later page falls back to the last page',
    () async {
      when(() => repo.removeProductLabel(1)).thenAnswer((_) async {});
      final n = await start();
      // Page 3 (index 2) holds one row; once it is removed the total is 40.
      var removed = false;
      when(
        () => repo.listProductLabels(
          labelId: any(named: 'labelId'),
          productId: any(named: 'productId'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((i) async {
        final skip = i.namedArguments[#skip] as int;
        if (!removed) {
          return CommissionProductLabelPage(items: [_row(1)], total: 41);
        }
        return skip >= 40
            ? const CommissionProductLabelPage(items: [], total: 40)
            : CommissionProductLabelPage(items: [_row(2)], total: 40);
      });
      await n.setPage(2);
      removed = true;
      await n.remove(1);
      expect(view().pageIndex, 1);
      expect(view().page.items.single.productId, 2);
    },
  );
}
