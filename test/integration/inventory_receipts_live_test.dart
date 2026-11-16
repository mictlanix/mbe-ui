import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';

/// Spec 067's repository calls against a live mbe-api (quickstart.md, task
/// T030): the Entradas de almacén list, its filters and a receipt's detail,
/// and, with `MBE_WRITE=true`, the whole draft flow with a stock check
/// before and after (SC-002).
///
///   flutter test test/integration/inventory_receipts_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env \
///     [--dart-define=MBE_WRITE=true]
///
/// `MBE_POS_*` is the administrator. Fixtures are discovered at run time
/// (research R12): the administrator's point-of-sale warehouse (W1), two
/// active stockable "clavo" products, a product whose available stock in W1
/// is negative (for the insufficient-stock refusal), and any receipt linked
/// to a purchase order (for the complementary path, skipped when none).
///
/// **Live answers (recorded 2026-11-16 against the dev mbe-api):**
///
/// 1. *Clearing the notes with `""` (research R8)*: the generated client
///    sends `"comment": ""`, the server stores `""` (GET answers
///    `"comment": ""`, not `null`), and the repository maps an empty note to
///    `null`, so the receipt shows no note. The `""` path stands; the raw
///    `{"comment": null}` fallback is not needed.
/// 2. *In-transit warehouses (quickstart step 4, research R5)*: `GET
///    /warehouses` never returns them. mbe-api filters `in_transit = false`
///    on every list, so the pickers cannot offer one; such a warehouse exists
///    (a GET by id answers 403 `warehouse.in_transit_managed`), and creating
///    a receipt in it is refused with `warehouse.in_transit_location`.
///
/// **Each write run leaves on the tenant:** two cancelled drafts, one
/// cancelled receipt (stock restored), and one confirmed 1-unit receipt of
/// the negative-stock product that the server refuses to cancel (that is the
/// refusal under test). When the complementary path creates a new draft it is
/// cancelled; an existing one is left alone. Run writes only against dev.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _canRun = _username != '' && _password != '';

/// A pattern with active stockable products on the dev tenant.
const _productPattern = 'clavo';

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

void main() {
  late Dio dio;
  late InventoryReceiptRepositoryImpl receipts;
  late WarehouseRepositoryImpl warehouses;
  late ProductRepositoryImpl products;
  late api.StockApi stock;
  late int employeeId;
  late int w1;
  final steps = <_Step>[];

  Future<void> step(String name, Future<String?> Function() body) async {
    try {
      final note = await body();
      steps.add(_Step(name, true, note ?? ''));
    } on Object catch (e, st) {
      steps.add(_Step(name, false, '$e\n$st'));
    }
  }

  void skipped(String name, String why) =>
      steps.add(_Step(name, true, 'SKIPPED: $why'));

  setUpAll(() async {
    if (!_canRun) return;
    dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final auth = AuthRepositoryImpl(dio);
    final token = await auth.login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    receipts = InventoryReceiptRepositoryImpl(dio);
    warehouses = WarehouseRepositoryImpl(dio);
    products = ProductRepositoryImpl(dio);
    stock = api.StockApi(dio, appSerializers);
    final me = await auth.me();
    final pointSaleId = me.settings?.pointSaleId;
    if (pointSaleId == null) {
      throw StateError('the administrator has no point of sale (W1)');
    }
    w1 = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: pointSaleId)).warehouseId;
    final raw = await dio.get<Map<String, dynamic>>('/api/v1/auth/me');
    employeeId = raw.data!['employee_id'] as int;
  });

  /// On-hand of [product] in W1 (`GET /stock/products/{product}`).
  Future<Decimal> onHand(int product) async {
    final s = (await stock.getProductStockApiV1StockProductsProductGet(
      product: product,
    )).data!;
    final row = s.warehouses?.where((w) => w.warehouse == w1).firstOrNull;
    return row == null ? Decimal.zero : Decimal.parse(row.onHand);
  }

  test(
    'Entradas de almacén against a live mbe-api',
    () async {
      // ---- Read-only (US1, US5 views) -----------------------------------
      late InventoryReceiptPage opening;
      await step('list opens, newest first', () async {
        opening = await receipts.list(skip: 0, limit: 20);
        expect(opening.items, isNotEmpty, reason: 'the tenant has none');
        final dates = opening.items.map((r) => r.createdAt).toList();
        final sorted = [...dates]..sort((a, b) => b.compareTo(a));
        expect(dates, sorted, reason: 'not newest first');
        return '${opening.total} receipts (administrator: all of them)';
      });

      await step('status filter: only that status', () async {
        for (final status in ReceiptStatus.values) {
          final page = await receipts.list(status: status, skip: 0, limit: 50);
          expect(page.items.every((r) => r.status == status), isTrue);
        }
        return null;
      });

      await step('warehouse filter: only that warehouse (W1 = $w1)', () async {
        final page = await receipts.list(warehouseId: w1, skip: 0, limit: 50);
        expect(page.items.every((r) => r.warehouseId == w1), isTrue);
        final both = await receipts.list(
          status: ReceiptStatus.completed,
          warehouseId: w1,
          skip: 0,
          limit: 50,
        );
        expect(
          both.items.every(
            (r) => r.warehouseId == w1 && r.status == ReceiptStatus.completed,
          ),
          isTrue,
        );
        return '${page.total} in W1, ${both.total} confirmed';
      });

      await step('a receipt\'s detail loads', () async {
        final first = opening.items.first;
        final detail = await receipts.get(first.id);
        expect(detail.id, first.id);
        expect(detail.status, first.status);
        expect(detail.warehouseId, first.warehouseId);
        return '#${detail.id}: ${detail.lines.length} line(s)';
      });

      // A receipt linked to a purchase order, for US5 (legacy data only).
      InventoryReceipt? linked;
      await step('discover a purchase-order receipt', () async {
        final page = await receipts.list(
          status: ReceiptStatus.completed,
          skip: 0,
          limit: 100,
        );
        final hit = page.items.where((r) => r.purchaseOrderId != null);
        if (hit.isEmpty) return 'SKIPPED: none among the newest 100';
        linked = await receipts.get(hit.first.id);
        expect(
          linked!.lines.any((l) => l.purchaseOrderLineId != null),
          isTrue,
          reason: 'a linked receipt carries linked lines',
        );
        return '#${linked!.id} (order ${linked!.purchaseOrderId})';
      });

      int? inTransitId;
      await step(
        'in-transit warehouses are not listed (quickstart 4)',
        () async {
          final listed = <int>{};
          for (var skip = 0; ; skip += 100) {
            final page = await warehouses.list(skip: skip, limit: 100);
            listed.addAll(page.items.map((w) => w.warehouseId));
            if (page.items.length < 100) break;
          }
          final top = listed.reduce((a, b) => a > b ? a : b);
          for (var id = 1; id <= top + 100 && inTransitId == null; id++) {
            if (listed.contains(id)) continue;
            try {
              await warehouses.get(warehouseId: id);
            } on AppError catch (e) {
              if (_code(e) == 'warehouse.in_transit_managed') inTransitId = id;
            }
          }
          return inTransitId == null
              ? '${listed.length} listed; no in-transit warehouse found'
              : '${listed.length} listed; #$inTransitId is in transit and '
                    'NOT listed';
        },
      );

      if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
        await step('qanoaccess is refused the list', () async {
          final other = Dio(BaseOptions(baseUrl: apiBaseUrl));
          final token = await AuthRepositoryImpl(
            other,
          ).login(username: _noAccessUser, password: _noAccessPass);
          other.options.headers['Authorization'] = 'Bearer $token';
          try {
            await InventoryReceiptRepositoryImpl(other).list(skip: 0, limit: 1);
            fail('qanoaccess read the receipts');
          } on AppError catch (e) {
            return 'refused: ${_code(e) ?? e.runtimeType}';
          }
        });
      }

      // ---- Writes (US2-US5) ---------------------------------------------
      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        final maxIdAtStart = opening.items.first.id;
        final tag = 'QA067 ${DateTime.now().millisecondsSinceEpoch % 100000}';
        late ProductListItem p1;
        late ProductListItem p2;

        await step('fixtures: two active stockable products', () async {
          final found = await products.list(
            search: _productPattern,
            status: EntityStatus.active,
            stockable: true,
            limit: 5,
          );
          expect(found.items.length, greaterThanOrEqualTo(2));
          p1 = found.items[0];
          p2 = found.items[1];
          return 'P1 ${p1.code}, P2 ${p2.code}';
        });

        if (inTransitId != null) {
          await step(
            'creating in an in-transit warehouse is refused',
            () async {
              try {
                final r = await receipts.create(warehouseId: inTransitId!);
                await receipts.cancel(r.id);
                fail('created #${r.id} in an in-transit warehouse');
              } on AppError catch (e) {
                expect(_code(e), 'warehouse.in_transit_location');
                return _code(e);
              }
            },
          );
        }

        InventoryReceipt? draft;
        await step('create a draft with notes', () async {
          draft = await receipts.create(warehouseId: w1, comment: tag);
          expect(draft!.status, ReceiptStatus.draft);
          expect(draft!.serial, isNull);
          expect(draft!.comment, tag);
          expect(draft!.warehouseId, w1);
          return '#${draft!.id}';
        });

        if (draft != null) {
          final id = draft!.id;

          await step(
            'clearing the notes with "" leaves no note (R8)',
            () async {
              final cleared = await receipts.updateHeader(
                id,
                clearComment: true,
              );
              expect(cleared.comment, isNull);
              expect((await receipts.get(id)).comment, isNull);
              final raw = await dio.get<Map<String, dynamic>>(
                '/api/v1/inventory-receipts/$id',
              );
              final stored = raw.data!['comment'];
              await receipts.updateHeader(id, comment: '$tag again');
              expect((await receipts.get(id)).comment, '$tag again');
              return 'server stores ${stored == null ? 'null' : '"$stored"'}';
            },
          );

          await step('add P1 × 3 then × 2: one line of 5', () async {
            await receipts.addLine(
              id,
              productId: p1.productId,
              quantity: Decimal.fromInt(3),
            );
            final r = await receipts.addLine(
              id,
              productId: p1.productId,
              quantity: Decimal.fromInt(2),
            );
            final p1Lines = r.lines.where((l) => l.productId == p1.productId);
            expect(p1Lines, hasLength(1));
            expect(p1Lines.single.quantity, Decimal.fromInt(5));
            return null;
          });

          await step('add P2 × 1, edit to 4, remove', () async {
            var r = await receipts.addLine(
              id,
              productId: p2.productId,
              quantity: Decimal.one,
            );
            final line = r.lines.singleWhere(
              (l) => l.productId == p2.productId,
            );
            r = await receipts.updateLine(
              id,
              line.id,
              quantity: Decimal.fromInt(4),
            );
            expect(
              r.lines.singleWhere((l) => l.id == line.id).quantity,
              Decimal.fromInt(4),
            );
            r = await receipts.removeLine(id, line.id);
            expect(r.lines.map((l) => l.productId), [p1.productId]);
            return null;
          });

          late Decimal before;
          await step(
            'confirm: folio assigned and P1 stock +5 (SC-002)',
            () async {
              before = await onHand(p1.productId);
              final r = await receipts.confirm(id);
              expect(r.status, ReceiptStatus.completed);
              expect(r.serial, isNotNull);
              final after = await onHand(p1.productId);
              expect(after, before + Decimal.fromInt(5));
              return 'folio ${r.serial}; on hand $before → $after';
            },
          );

          await step('cancel the confirmed receipt: stock restored', () async {
            final r = await receipts.cancel(id);
            expect(r.status, ReceiptStatus.cancelled);
            expect(await onHand(p1.productId), before);
            return null;
          });
        }

        await step(
          'confirm an empty draft is refused; cancel the draft',
          () async {
            final empty = await receipts.create(warehouseId: w1, comment: tag);
            try {
              await receipts.confirm(empty.id);
              fail('an empty draft was confirmed');
            } on AppError catch (e) {
              expect(_code(e), 'inventory_document.no_lines');
            }
            final r = await receipts.cancel(empty.id);
            expect(r.status, ReceiptStatus.cancelled);
            return '#${empty.id} cancelled';
          },
        );

        await step('cancel refused for insufficient stock', () async {
          // A stockable product whose available stock in W1 is ≤ -1: after a
          // 1-unit receipt it is still below 1, so the cancel is refused.
          int? productId;
          for (var skip = 0; productId == null; skip += 100) {
            final page = (await stock.listStockApiV1StockGet(
              warehouse: w1,
              skip: skip,
              limit: 100,
            )).data!;
            for (final row in page.items) {
              if (Decimal.parse(row.available) <= Decimal.fromInt(-1)) {
                productId = row.product;
                break;
              }
            }
            if (page.items.length < 100) break;
          }
          if (productId == null) {
            return 'SKIPPED: no product with negative stock in W1';
          }
          final r = await receipts.create(warehouseId: w1, comment: tag);
          await receipts.addLine(
            r.id,
            productId: productId,
            quantity: Decimal.one,
          );
          await receipts.confirm(r.id);
          try {
            await receipts.cancel(r.id);
            fail('the cancel went through');
          } on AppError catch (e) {
            expect(_code(e), 'inventory_document.insufficient_stock');
            expect(e.problem!.params['product_id'], productId);
          }
          expect((await receipts.get(r.id)).status, ReceiptStatus.completed);
          return '#${r.id} (product $productId) stays Confirmada';
        });

        if (linked == null) {
          skipped('complementary receipt', 'no purchase-order receipt');
        } else {
          await step('complementary: a draft or a coded refusal', () async {
            try {
              final r = await receipts.complementary(linked!.id);
              expect(r.status, ReceiptStatus.draft);
              expect(r.purchaseOrderId, linked!.purchaseOrderId);
              final again = await receipts.complementary(linked!.id);
              expect(again.id, r.id, reason: 'the same draft the second time');
              if (r.id > maxIdAtStart && r.creatorId == employeeId) {
                await receipts.cancel(r.id);
                return 'new draft #${r.id} (cancelled)';
              }
              return 'existing draft #${r.id} (left alone)';
            } on AppError catch (e) {
              expect(_code(e), 'inventory_receipt.complementary_unavailable');
              return 'refused: ${e.problem!.params}';
            }
          });
        }
      }

      // ---- Report ---------------------------------------------------------
      final out = StringBuffer('\n== Entradas de almacén live run ==\n');
      for (final s in steps) {
        out.writeln(
          '${s.ok ? 'PASS' : 'FAIL'}  ${s.name}'
          '${s.detail.isEmpty ? '' : '  [${s.detail.split('\n').first}]'}',
        );
      }
      // ignore: avoid_print
      print(out);
      final failed = steps.where((s) => !s.ok).toList();
      expect(
        failed,
        isEmpty,
        reason: [
          for (final f in failed) '${f.name}: ${f.detail}',
        ].join('\n---\n'),
      );
    },
    skip: _canRun ? null : 'needs --dart-define=MBE_POS_USERNAME/PASSWORD',
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
