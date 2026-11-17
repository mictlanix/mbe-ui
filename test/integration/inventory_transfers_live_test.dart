import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// Spec 069's repository calls against a live mbe-api (quickstart.md, task
/// T038): the Traspasos list, its filters and a transfer's detail, and, with
/// `MBE_WRITE=true`, the draft flow, dispatch, partial and full receipt,
/// close, cancel, the insufficient-stock refusal, adding from a sales order
/// and the in-transit view, each with a stock check before and after.
///
///   flutter test test/integration/inventory_transfers_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env \
///     [--dart-define=MBE_WRITE=true]
///
/// `MBE_POS_*` is the administrator (the only account with rights on
/// InventoryTransfers, 17; no seeded non-administrator has them, so the
/// non-administrator cases stay manual, research R12). Fixtures are
/// discovered at run time: two listed warehouses W1 and W2 (preferably in one
/// facility), a W3 in another facility when there is one, an active stockable
/// product with available stock >= 5 at W1, and a completed sales order with
/// stockable lines (skipped when none).
///
/// **Each facility used must have an in-transit warehouse.** Otherwise
/// dispatch answers `facility.no_in_transit_location`; that is recorded as a
/// skipped step, not a failure.
///
/// **Each write run leaves on the tenant:** only cancelled transfers (drafts
/// that were cancelled, and dispatched ones that were cancelled with their
/// stock restored), plus one received transfer and one closed transfer.
/// Run writes only against dev.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _canRun = _username != '' && _password != '';

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

Decimal _d(int n) => Decimal.fromInt(n);

void main() {
  late Dio dio;
  late InventoryTransferRepositoryImpl transfers;
  late WarehouseRepositoryImpl warehouses;
  late ProductRepositoryImpl products;
  late SalesOrderRepositoryImpl orders;
  late api.StockApi stock;
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
    transfers = InventoryTransferRepositoryImpl(dio);
    warehouses = WarehouseRepositoryImpl(dio);
    products = ProductRepositoryImpl(dio);
    orders = SalesOrderRepositoryImpl(dio);
    stock = api.StockApi(dio, appSerializers);
  });

  /// On-hand of [product] in [warehouse].
  Future<Decimal> onHand(int product, int warehouse) async {
    final s = (await stock.getProductStockApiV1StockProductsProductGet(
      product: product,
    )).data!;
    final row = s.warehouses
        ?.where((w) => w.warehouse == warehouse)
        .firstOrNull;
    return row == null ? Decimal.zero : Decimal.parse(row.onHand);
  }

  test(
    'Traspasos against a live mbe-api',
    () async {
      // ---- Read-only ----------------------------------------------------
      late InventoryTransferPage opening;
      await step('list opens, newest first', () async {
        opening = await transfers.list(skip: 0, limit: 20);
        final dates = opening.items.map((r) => r.createdAt).toList();
        final sorted = [...dates]..sort((a, b) => b.compareTo(a));
        expect(dates, sorted, reason: 'not newest first');
        return '${opening.total} transfers (administrator: all of them)';
      });

      await step('status filter: only that status', () async {
        for (final status in InventoryTransferStatus.values) {
          final page = await transfers.list(status: status, skip: 0, limit: 50);
          expect(page.items.every((r) => r.status == status), isTrue);
        }
        return null;
      });

      // Listed warehouses (in-transit ones are never listed).
      final listed = <Warehouse>[];
      await step('warehouses are listed', () async {
        for (var skip = 0; ; skip += 100) {
          final page = await warehouses.list(skip: skip, limit: 100);
          listed.addAll(page.items);
          if (page.items.length < 100) break;
        }
        expect(listed, isNotEmpty);
        return '${listed.length} listed';
      });

      await step(
        'warehouse filter matches the origin or destination',
        () async {
          final w = opening.items.isEmpty
              ? listed.first.warehouseId
              : opening.items.first.warehouseToId;
          final page = await transfers.list(warehouseId: w, skip: 0, limit: 50);
          expect(
            page.items.every((r) => r.warehouseId == w || r.warehouseToId == w),
            isTrue,
          );
          if (opening.items.isNotEmpty) {
            expect(
              page.items.map((r) => r.id),
              contains(opening.items.first.id),
            );
          }
          final both = await transfers.list(
            status: InventoryTransferStatus.received,
            warehouseId: w,
            skip: 0,
            limit: 50,
          );
          expect(
            both.items.every(
              (r) =>
                  (r.warehouseId == w || r.warehouseToId == w) &&
                  r.status == InventoryTransferStatus.received,
            ),
            isTrue,
          );
          return '${page.total} in W$w, ${both.total} received';
        },
      );

      await step('a transfer\'s detail loads', () async {
        if (opening.items.isEmpty) return 'SKIPPED: the tenant has none';
        final first = opening.items.first;
        final detail = await transfers.get(first.id);
        expect(detail.id, first.id);
        expect(detail.status, first.status);
        expect(detail.warehouseId, first.warehouseId);
        expect(detail.warehouseToId, first.warehouseToId);
        return '#${detail.id}: ${detail.lines.length} line(s)';
      });

      // ---- Writes -------------------------------------------------------
      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        final tag = 'QA069 ${DateTime.now().millisecondsSinceEpoch % 100000}';
        var n = 0;
        String next() => '$tag ${++n}';
        final created = <int>[];
        late Warehouse w1;
        late Warehouse w2;
        Warehouse? w3;
        late int p1;
        int? p2;
        late Decimal available1;

        Future<InventoryTransfer> newDraft(Warehouse from, Warehouse to) async {
          final t = await transfers.create(
            warehouseId: from.warehouseId,
            warehouseToId: to.warehouseId,
            comment: next(),
          );
          created.add(t.id);
          return t;
        }

        /// Dispatches [id]; null when the facility has no in-transit warehouse.
        Future<InventoryTransfer?> dispatchOrNull(int id) async {
          try {
            return await transfers.dispatch(id);
          } on AppError catch (e) {
            if (_code(e) == 'facility.no_in_transit_location') return null;
            rethrow;
          }
        }

        const noTransit =
            'facility has no in-transit warehouse '
            '(facility.no_in_transit_location)';

        await step('fixtures: W1, W2 (W3), a stocked product at W1', () async {
          for (final candidate in listed) {
            final rows = <({int product, Decimal available})>[];
            for (var skip = 0; ; skip += 100) {
              final page = (await stock.listStockApiV1StockGet(
                warehouse: candidate.warehouseId,
                skip: skip,
                limit: 100,
              )).data!;
              for (final r in page.items) {
                final available = Decimal.parse(r.available);
                if (available >= _d(5)) {
                  rows.add((product: r.product, available: available));
                }
              }
              if (page.items.length < 100 || rows.length >= 20) break;
            }
            final ok = <({int product, Decimal available})>[];
            for (final r in rows) {
              final p = await products.get(productId: r.product);
              if (p.stockable && p.status.name == 'active') ok.add(r);
              if (ok.length == 2) break;
            }
            if (ok.isEmpty) continue;
            final others = listed
                .where((x) => x.warehouseId != candidate.warehouseId)
                .toList();
            if (others.isEmpty) continue;
            w1 = candidate;
            w2 =
                others
                    .where((x) => x.facilityId == w1.facilityId)
                    .firstOrNull ??
                others.first;
            w3 = listed
                .where((x) => x.facilityId != w1.facilityId)
                .where((x) => x.warehouseId != w2.warehouseId)
                .firstOrNull;
            p1 = ok[0].product;
            available1 = ok[0].available;
            p2 = ok.length > 1 ? ok[1].product : null;
            return 'W1 ${w1.warehouseId} (facility ${w1.facilityId}), '
                'W2 ${w2.warehouseId} (facility ${w2.facilityId}), '
                'W3 ${w3?.warehouseId}, P1 $p1 (available $available1), '
                'P2 $p2';
          }
          fail(
            'no active stockable product with stock >= 5 in a listed '
            'warehouse that has another warehouse to send to',
          );
        });

        if (steps.last.ok) {
          final w1id = w1.warehouseId;
          final w2id = w2.warehouseId;

          // ---- Transfer A: draft edits, dispatch, receipts ---------------
          InventoryTransfer? a;
          await step('create a draft with notes; list finds it', () async {
            a = await newDraft(w1, w2);
            expect(a!.status, InventoryTransferStatus.draft);
            expect(a!.serial, isNull);
            expect(a!.warehouseId, w1id);
            expect(a!.warehouseToId, w2id);
            expect(a!.comment, startsWith(tag));
            final byDestination = await transfers.list(
              warehouseId: w2id,
              skip: 0,
              limit: 50,
            );
            expect(byDestination.items.map((r) => r.id), contains(a!.id));
            expect(
              byDestination.items.every(
                (r) => r.warehouseId == w2id || r.warehouseToId == w2id,
              ),
              isTrue,
            );
            expect((await transfers.get(a!.id)).id, a!.id);
            return '#${a!.id}';
          });

          await step('same_warehouse on create', () async {
            try {
              await transfers.create(warehouseId: w1id, warehouseToId: w1id);
              fail('a transfer to the same warehouse was created');
            } on AppError catch (e) {
              expect(_code(e), 'inventory_transfer.same_warehouse');
            }
            return null;
          });

          if (a != null) {
            final id = a!.id;
            late Decimal w1Before;
            late Decimal w2Before;
            var dispatched = false;

            await step(
              'header: same_warehouse; clear the notes, set them',
              () async {
                try {
                  await transfers.updateHeader(id, warehouseToId: w1id);
                  fail('the header accepted the same warehouse');
                } on AppError catch (e) {
                  expect(_code(e), 'inventory_transfer.same_warehouse');
                }
                final cleared = await transfers.updateHeader(
                  id,
                  clearComment: true,
                );
                expect(cleared.comment, isNull);
                expect((await transfers.get(id)).comment, isNull);
                final again = next();
                await transfers.updateHeader(id, comment: again);
                expect((await transfers.get(id)).comment, again);
                return null;
              },
            );

            await step('add P1 × 2 then × 1: one line of 3', () async {
              await transfers.addLine(id, productId: p1, quantity: _d(2));
              final r = await transfers.addLine(
                id,
                productId: p1,
                quantity: Decimal.one,
              );
              final lines = r.lines.where((l) => l.productId == p1);
              expect(lines, hasLength(1));
              expect(lines.single.quantity, _d(3));
              return null;
            });

            await step('edit the P1 line to 4', () async {
              final line = (await transfers.get(
                id,
              )).lines.singleWhere((l) => l.productId == p1);
              final r = await transfers.updateLine(
                id,
                line.id,
                quantity: _d(4),
              );
              expect(
                r.lines.singleWhere((l) => l.id == line.id).quantity,
                _d(4),
              );
              return null;
            });

            if (p2 == null) {
              skipped('add P2 × 1, remove it', 'only one stocked product');
            } else {
              await step('add P2 × 1, remove it', () async {
                var r = await transfers.addLine(
                  id,
                  productId: p2!,
                  quantity: Decimal.one,
                );
                final line = r.lines.singleWhere((l) => l.productId == p2);
                r = await transfers.removeLine(id, line.id);
                expect(r.lines.map((l) => l.productId), [p1]);
                return null;
              });
            }

            await step('dispatch: W1 -4, W2 unchanged (SC-003)', () async {
              w1Before = await onHand(p1, w1id);
              w2Before = await onHand(p1, w2id);
              final r = await dispatchOrNull(id);
              if (r == null) return 'SKIPPED: $noTransit';
              dispatched = true;
              expect(r.status, InventoryTransferStatus.inTransit);
              expect(r.serial, isNotNull);
              final line = r.lines.single;
              expect(line.quantityReceived, Decimal.zero);
              expect(line.quantityOutstanding, _d(4));
              expect(await onHand(p1, w1id), w1Before - _d(4));
              expect(await onHand(p1, w2id), w2Before);
              return 'folio ${r.serial}; W1 $w1Before → ${w1Before - _d(4)}';
            });

            if (!dispatched) {
              skipped('receive, over-receive, full receive', noTransit);
              await transfers.cancel(id);
            } else {
              final lineId = (await transfers.get(id)).lines.single.id;

              await step(
                'partial receive 1: W2 +1, still in transit',
                () async {
                  final r = await transfers.receive(id, lines: {lineId: _d(1)});
                  expect(r.status, InventoryTransferStatus.inTransit);
                  expect(r.lines.single.quantityReceived, Decimal.one);
                  expect(r.lines.single.quantityOutstanding, _d(3));
                  expect(await onHand(p1, w2id), w2Before + Decimal.one);
                  return null;
                },
              );

              await step('receive above outstanding: over_received', () async {
                try {
                  await transfers.receive(id, lines: {lineId: _d(4)});
                  fail('an over-receipt went through');
                } on AppError catch (e) {
                  expect(_code(e), 'inventory_transfer.over_received');
                }
                expect(await onHand(p1, w2id), w2Before + Decimal.one);
                return null;
              });

              await step('full receive with no body: received', () async {
                final r = await transfers.receive(id);
                expect(r.status, InventoryTransferStatus.received);
                expect(r.lines.single.quantityReceived, _d(4));
                expect(r.lines.single.quantityOutstanding, Decimal.zero);
                expect(await onHand(p1, w2id), w2Before + _d(4));
                expect(await onHand(p1, w1id), w1Before - _d(4));
                return null;
              });

              await step('a further receive: not_in_transit', () async {
                try {
                  await transfers.receive(id);
                  fail('a received transfer was received again');
                } on AppError catch (e) {
                  expect(_code(e), 'inventory_transfer.not_in_transit');
                }
                return null;
              });
            }
          }

          // ---- Transfer B: close the remainder ---------------------------
          await step(
            'close after a partial receive: W1 regains the remainder',
            () async {
              final dest = w3 ?? w2;
              final t = await newDraft(w1, dest);
              await transfers.addLine(t.id, productId: p1, quantity: _d(3));
              final w1Before = await onHand(p1, w1.warehouseId);
              final destBefore = await onHand(p1, dest.warehouseId);
              final sent = await dispatchOrNull(t.id);
              if (sent == null) {
                await transfers.cancel(t.id);
                return 'SKIPPED: $noTransit';
              }
              final lineId = sent.lines.single.id;
              await transfers.receive(t.id, lines: {lineId: Decimal.one});
              expect(
                await onHand(p1, dest.warehouseId),
                destBefore + Decimal.one,
              );
              final r = await transfers.close(t.id);
              expect(r.status, InventoryTransferStatus.received);
              final line = r.lines.single;
              expect(line.quantity, _d(3));
              expect(line.quantityReceived, Decimal.one);
              expect(line.quantityOutstanding, Decimal.zero);
              expect(await onHand(p1, w1.warehouseId), w1Before - Decimal.one);
              expect(
                await onHand(p1, dest.warehouseId),
                destBefore + Decimal.one,
              );
              return '#${t.id} W${w1.warehouseId} → W${dest.warehouseId} '
                  '${w3 == null ? '(same facility)' : '(cross-facility)'}';
            },
          );

          // ---- Transfer C: in-transit view, then cancel -------------------
          await step(
            'in-transit view lists the outstanding line; cancel restores '
            'both ends',
            () async {
              final t = await newDraft(w1, w2);
              await transfers.addLine(t.id, productId: p1, quantity: _d(2));
              final w1Before = await onHand(p1, w1id);
              final w2Before = await onHand(p1, w2id);
              final sent = await dispatchOrNull(t.id);
              if (sent == null) {
                await transfers.cancel(t.id);
                return 'SKIPPED: $noTransit';
              }
              final lineId = sent.lines.single.id;
              await transfers.receive(t.id, lines: {lineId: Decimal.one});

              final view = await transfers.inTransit(facilityId: w1.facilityId);
              expect(view.facilityId, w1.facilityId);
              final mine = view.lines.where((l) => l.transferId == t.id);
              expect(mine, hasLength(1));
              expect(mine.single.lineId, lineId);
              expect(mine.single.productId, p1);
              expect(mine.single.quantityOutstanding, Decimal.one);
              expect(mine.single.serial, sent.serial);
              expect(
                view.products
                    .where((p) => p.productId == p1)
                    .fold(Decimal.zero, (s, p) => s + p.quantity),
                greaterThanOrEqualTo(Decimal.one),
              );

              final r = await transfers.cancel(t.id);
              expect(r.status, InventoryTransferStatus.cancelled);
              expect(await onHand(p1, w1id), w1Before);
              expect(await onHand(p1, w2id), w2Before);
              final after = await transfers.inTransit(
                facilityId: w1.facilityId,
              );
              expect(after.lines.where((l) => l.transferId == t.id), isEmpty);
              return '#${t.id} cancelled; W1 $w1Before, W2 $w2Before restored';
            },
          );

          // ---- Refusals ---------------------------------------------------
          await step(
            'dispatch refused for insufficient stock; stays a draft',
            () async {
              final t = await newDraft(w1, w2);
              await transfers.addLine(
                t.id,
                productId: p1,
                quantity: available1 + Decimal.one,
              );
              try {
                await transfers.dispatch(t.id);
                fail('the dispatch went through');
              } on AppError catch (e) {
                final code = _code(e);
                if (code == 'facility.no_in_transit_location') {
                  await transfers.cancel(t.id);
                  return 'SKIPPED: $noTransit';
                }
                expect(code, 'inventory_document.insufficient_stock');
                expect(e.problem!.params['product_id'], p1);
              }
              expect(
                (await transfers.get(t.id)).status,
                InventoryTransferStatus.draft,
              );
              await transfers.cancel(t.id);
              return '#${t.id} (${available1 + Decimal.one} > $available1) '
                  'stays Borrador';
            },
          );

          await step('dispatch an empty draft: no_lines; cancel it', () async {
            final t = await newDraft(w1, w2);
            try {
              await transfers.dispatch(t.id);
              fail('an empty draft was dispatched');
            } on AppError catch (e) {
              final code = _code(e);
              if (code == 'facility.no_in_transit_location') {
                await transfers.cancel(t.id);
                return 'SKIPPED: $noTransit';
              }
              expect(code, 'inventory_document.no_lines');
            }
            final r = await transfers.cancel(t.id);
            expect(r.status, InventoryTransferStatus.cancelled);
            expect(r.serial, isNull);
            return '#${t.id} cancelled';
          });

          // ---- Add from a sales order ------------------------------------
          await step('add from sales order, twice', () async {
            final page = await orders.listOrders(
              status: SaleStatus.completed,
              limit: 15,
            );
            if (page.items.isEmpty) {
              return 'SKIPPED: no completed sales order';
            }
            final t = await newDraft(w1, w2);
            for (final order in page.items) {
              InventoryTransfer first;
              try {
                first = await transfers.addSalesOrderItems(
                  t.id,
                  salesOrderId: order.id,
                );
              } on AppError {
                continue;
              }
              if (first.lines.isEmpty) continue;
              final second = await transfers.addSalesOrderItems(
                t.id,
                salesOrderId: order.id,
              );
              expect(
                [for (final l in second.lines) (l.productId, l.quantity)],
                [for (final l in first.lines) (l.productId, l.quantity)],
                reason: 'the second add changed the lines',
              );
              await transfers.cancel(t.id);
              return 'order ${order.id}: ${first.lines.length} line(s), '
                  'second add changed nothing (draft #${t.id} cancelled)';
            }
            await transfers.cancel(t.id);
            return 'SKIPPED: none of the ${page.items.length} newest orders '
                'gave stockable lines';
          });
        }

        // Leave nothing in draft.
        await step('no QA069 draft is left behind', () async {
          for (final id in created) {
            final t = await transfers.get(id);
            if (t.status == InventoryTransferStatus.draft) {
              await transfers.cancel(id);
            }
          }
          return '${created.length} created: '
              '${[for (final id in created) '#$id'].join(' ')}';
        });
        // ignore: avoid_print
        print('Created (tag $tag):');
        for (final id in created) {
          final t = await transfers.get(id);
          // ignore: avoid_print
          print('  #$id ${t.status.name} serial ${t.serial}');
        }
      }

      // ---- Report -------------------------------------------------------
      final out = StringBuffer('\n== Traspasos live run ==\n');
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
