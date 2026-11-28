import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

/// Spec 080's repository calls against a live mbe-api (quickstart.md, task
/// T036). With `MBE_WRITE=true`: an order created by hand, its lines added and
/// edited (quantity, price and tax-rate strings), the estimated date set and
/// read back as the same calendar day (spec 043), notes and date cleared
/// (research R7's raw `dio.put`), an approved request's lines added, confirm
/// (one receipt per destination warehouse, none for a service line), `get`
/// (no receipts until mictlanix/mbe-api#355), print, email, and a draft
/// created from a Por comprar group, then cancelled, its lines back in Por
/// comprar.
///
///   flutter test test/integration/purchase_orders_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env \
///     [--dart-define=MBE_WRITE=true]
///
/// `MBE_POS_*` is the administrator (rights 20, 86, 96 and 15). Fixtures are
/// discovered at run time: the administrator's point-of-sale warehouse (W1),
/// an active purchasable, stockable "clavo" product with a supplier (the run
/// is skipped without one), a non-stockable purchasable product (the
/// service-line check is skipped without one) and a warehouse of another
/// facility (the two-receipt check is skipped without one). The approved
/// requests are made by the test through spec 079's repository.
///
/// **Email never reaches a person.** The run first probes the email route with
/// an order id that cannot exist: the server checks the mailer before the
/// order, so a 503 `email.not_configured` means mail is off (then the real
/// order is "sent" to an example.com address and must answer the same 503),
/// and a 404 means mail is on, and the send is skipped.
///
/// Cleanup: the drafts the run creates are cancelled, the receipts confirm
/// generates (drafts) are cancelled, and so are the requests. The confirmed
/// order stays (a confirmed order cannot be cancelled); its notes carry the
/// run's `QA080` tag. Run writes only against dev.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _canRun = _username != '' && _password != '';

/// A pattern with active purchasable products on the dev tenant ('a' finds
/// nothing there).
const _patternDefine = String.fromEnvironment('MBE_POS_PRODUCT_PATTERN');
const _productPattern = _patternDefine == '' || _patternDefine == 'a'
    ? 'clavo'
    : _patternDefine;

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

/// The tenant lacks the product the write flow needs.
class _NoFixture implements Exception {
  const _NoFixture();
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

bool _isPdf(List<int> bytes) =>
    bytes.length > 5 && String.fromCharCodes(bytes.take(5)) == '%PDF-';

bool _sameDay(DateTime? a, DateTime b) =>
    a != null && a.year == b.year && a.month == b.month && a.day == b.day;

void main() {
  late Dio dio;
  late PurchaseOrderRepositoryImpl orders;
  late PurchaseRequestRepositoryImpl requests;
  late WarehouseRepositoryImpl warehouses;
  late ProductRepositoryImpl products;
  late int w1;
  final steps = <_Step>[];

  /// Bodies of the order line PUTs, as they went on the wire.
  final lineBodies = <String>[];

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
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          if (o.method == 'PUT' &&
              RegExp(r'/purchase-orders/\d+/lines/\d+$').hasMatch(o.path)) {
            lineBodies.add(
              o.data is String ? o.data as String : jsonEncode(o.data),
            );
          }
          h.next(o);
        },
      ),
    );
    orders = PurchaseOrderRepositoryImpl(dio);
    requests = PurchaseRequestRepositoryImpl(dio);
    warehouses = WarehouseRepositoryImpl(dio);
    products = ProductRepositoryImpl(dio);
    final me = await auth.me();
    final pointSaleId = me.settings?.pointSaleId;
    if (pointSaleId == null) {
      throw StateError('the administrator has no point of sale (W1)');
    }
    w1 = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: pointSaleId)).warehouseId;
  });

  Future<Map<String, dynamic>> rawOrder(int id) async =>
      (await dio.get<Map<String, dynamic>>(
        '/api/v1/purchase-orders/$id',
      )).data!;

  test(
    'Órdenes de compra against a live mbe-api',
    () async {
      await step('list, default scope', () async {
        final page = await orders.list(skip: 0, limit: 20);
        final all = await orders.list(all: true, skip: 0, limit: 20);
        expect(all.total, greaterThanOrEqualTo(page.total));
        return 'default ${page.total}, all ${all.total}';
      });

      await step('Por comprar loads', () async {
        final groups = await orders.toPurchase();
        return '${groups.length} group(s)';
      });

      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        final tag = 'QA080 ${DateTime.now().millisecondsSinceEpoch % 100000}';
        final createdOrders = <int>[];
        final createdRequests = <int>[];
        final receiptIds = <int>[];

        Future<PurchaseRequest> approvedRequest(int productId) async {
          var r = await requests.create(warehouseId: w1, comment: tag);
          createdRequests.add(r.id);
          r = await requests.addLine(r.id, productId: productId);
          await requests.submit(r.id);
          await requests.approve(r.id);
          return requests.markLine(r.id, r.lines.single.id, toPurchase: true);
        }

        try {
          // ---- Fixtures ----
          Product? product;
          await step(
            'fixtures: purchasable stockable product with a supplier',
            () async {
              final found = await products.list(
                search: _productPattern,
                status: EntityStatus.active,
                purchasable: true,
                stockable: true,
                limit: 30,
              );
              for (final p in found.items) {
                final full = await products.get(productId: p.productId);
                if (full.supplierId != null && full.stockable) {
                  product = full;
                  break;
                }
              }
              if (product == null) {
                return 'SKIPPED: no active purchasable stockable '
                    '"$_productPattern" product with a supplier';
              }
              return '${product!.code} (#${product!.productId}), supplier '
                  '${product!.supplierId} ${product!.supplierName}';
            },
          );
          if (product == null) throw const _NoFixture();
          final supplierId = product!.supplierId!;

          Product? service;
          await step('fixtures: a non-stockable purchasable product', () async {
            final found = await products.list(
              status: EntityStatus.active,
              purchasable: true,
              stockable: false,
              limit: 5,
            );
            if (found.items.isEmpty) return 'SKIPPED: none';
            service = await products.get(
              productId: found.items.first.productId,
            );
            expect(service!.stockable, isFalse);
            return '${service!.code} (#${service!.productId})';
          });

          int? w2;
          late int facility1;
          await step('fixtures: a warehouse of another facility', () async {
            final home = await warehouses.get(warehouseId: w1);
            facility1 = home.facilityId;
            final page = await warehouses.list(
              status: EntityStatus.active,
              limit: 100,
            );
            final other = page.items.where(
              (w) => w.facilityId != home.facilityId,
            );
            if (other.isEmpty) return 'SKIPPED: none';
            w2 = other.first.warehouseId;
            return 'W1 $w1 (facility ${home.facilityId}); W2 $w2 '
                '(facility ${other.first.facilityId})';
          });

          // ---- Create by hand (quickstart 4) ----
          final date1 = DateTime.now().add(const Duration(days: 10));
          late PurchaseOrder o1;
          await step('create by hand: supplier, date, notes', () async {
            o1 = await orders.create(
              supplierId: supplierId,
              estimatedReceiptDate: date1,
              comment: tag,
            );
            createdOrders.add(o1.id);
            expect(o1.status, InventoryDocumentStatus.draft);
            expect(o1.supplierId, supplierId);
            expect(o1.comment, tag);
            expect(o1.lines, isEmpty);
            expect(
              _sameDay(o1.estimatedReceiptDate, date1),
              isTrue,
              reason:
                  'sent ${date1.toIso8601String()}, got '
                  '${o1.estimatedReceiptDate}',
            );
            return '#${o1.id}, date ${o1.estimatedReceiptDate}';
          });
          if (createdOrders.isEmpty) {
            throw StateError('no order; the write flow stops');
          }
          final id1 = o1.id;

          // ---- Lines (quickstart 6) ----
          late PurchaseOrderLine line;
          await step('add a line: server defaults', () async {
            final o = await orders.addLine(
              id1,
              productId: product!.productId,
              quantity: Decimal.fromInt(2),
            );
            line = o.lines.single;
            expect(line.productId, product!.productId);
            expect(line.quantity, Decimal.fromInt(2));
            expect(line.productCode, product!.code);
            return 'line ${line.id}: warehouse ${line.warehouseId}, price '
                '${line.price}, tax ${line.taxRate}, amount ${line.amount}';
          });

          await step('edit quantity, price and tax rate; read back', () async {
            final q = Decimal.parse('1.2345');
            final p = Decimal.parse('10.1234567');
            final t = Decimal.zero;
            lineBodies.clear();
            final o = await orders.updateLine(
              id1,
              line.id,
              quantity: q,
              price: p,
              taxRate: t,
            );
            final sent = lineBodies.single;
            final l = o.lines.singleWhere((l) => l.id == line.id);
            expect(l.quantity, q);
            expect(l.price, p);
            expect(l.taxRate, t);
            final got = (await orders.get(id1)).lines.single;
            expect(got.quantity, q);
            expect(got.price, p);
            expect(got.taxRate, t);
            final raw = ((await rawOrder(id1))['lines'] as List).single as Map;
            return 'sent $sent; server returns quantity '
                '${jsonEncode(raw['quantity'])}, price '
                '${jsonEncode(raw['price'])}, tax_rate '
                '${jsonEncode(raw['tax_rate'])}';
          });

          if (w2 == null) {
            skipped(
              'move the hand line to W2',
              'no warehouse of another '
                  'facility',
            );
          } else {
            await step('move the hand line to W2', () async {
              final o = await orders.updateLine(id1, line.id, warehouseId: w2);
              expect(
                o.lines.singleWhere((l) => l.id == line.id).warehouseId,
                w2,
              );
              return null;
            });
          }

          // ---- Header (quickstart 5) ----
          final date2 = DateTime.now().add(const Duration(days: 20));
          await step(
            'set the date: same calendar day in list and get',
            () async {
              final o = await orders.updateHeader(
                id1,
                estimatedReceiptDate: date2,
              );
              expect(_sameDay(o.estimatedReceiptDate, date2), isTrue);
              final got = await orders.get(id1);
              expect(
                _sameDay(got.estimatedReceiptDate, date2),
                isTrue,
                reason: 'get: ${got.estimatedReceiptDate}',
              );
              final row = (await orders.list(
                orderId: id1,
                skip: 0,
                limit: 5,
              )).items.singleWhere((s) => s.id == id1);
              expect(
                _sameDay(row.estimatedReceiptDate, date2),
                isTrue,
                reason: 'list: ${row.estimatedReceiptDate}',
              );
              final raw = (await rawOrder(id1))['estimated_receipt_date'];
              return 'sent ${date2.toIso8601String().substring(0, 10)}; '
                  'server ${jsonEncode(raw)}; list ${row.estimatedReceiptDate}';
            },
          );

          await step('clear notes and date (raw PUT, R7)', () async {
            final o = await orders.updateHeader(
              id1,
              clearComment: true,
              clearDate: true,
            );
            expect(o.comment, isNull);
            expect(o.estimatedReceiptDate, isNull);
            final got = await orders.get(id1);
            expect(got.comment, isNull);
            expect(got.estimatedReceiptDate, isNull);
            expect(got.supplierId, supplierId, reason: 'supplier untouched');
            final row = (await orders.list(
              orderId: id1,
              skip: 0,
              limit: 5,
            )).items.singleWhere((s) => s.id == id1);
            expect(row.comment, isNull);
            expect(row.estimatedReceiptDate, isNull);
            final raw = await rawOrder(id1);
            // Put the tag back so the confirmed order is recognizable.
            await orders.updateHeader(id1, comment: tag);
            return 'server stores comment ${jsonEncode(raw['comment'])}, '
                'date ${jsonEncode(raw['estimated_receipt_date'])}';
          });

          // ---- Request lines (quickstart 7) ----
          PurchaseRequest? r1;
          await step('add an approved request\'s lines', () async {
            r1 = await approvedRequest(product!.productId);
            final reqLine = r1!.lines.single;
            expect(reqLine.toPurchase, isTrue);
            final o = await orders.addRequestLines(id1, requestId: r1!.id);
            final added = o.lines.where((l) => l.requestId == r1!.id);
            expect(added, hasLength(1));
            expect(added.single.requestLineId, reqLine.id);
            expect(added.single.warehouseId, w1);
            expect(o.skippedCount, 0);
            return 'request #${r1!.id} (folio ${r1!.serial}): line '
                '${added.single.id} at ${added.single.price}';
          });

          await step('the same request again: nothing added', () async {
            if (r1 == null) return 'SKIPPED: no request';
            try {
              final o = await orders.addRequestLines(id1, requestId: r1!.id);
              expect(o.skippedCount, greaterThan(0));
              return 'skipped ${o.skippedCount}';
            } on AppError catch (e) {
              return 'refused: ${_code(e)}';
            }
          });

          if (service == null) {
            skipped('add a service line', 'no non-stockable product');
          } else {
            await step('add a service line', () async {
              final o = await orders.addLine(
                id1,
                productId: service!.productId,
                quantity: Decimal.one,
              );
              final l = o.lines.singleWhere(
                (l) => l.productId == service!.productId,
              );
              return 'line ${l.id}, warehouse ${l.warehouseId}';
            });
          }

          // ---- Confirm (quickstart 8) ----
          await step('confirm: one receipt per destination warehouse', () async {
            final before = await orders.get(id1);
            final stockable = before.lines
                .where(
                  (l) => service == null || l.productId != service!.productId,
                )
                .toList();
            final expected = stockable.map((l) => l.warehouseId).toSet();
            final o = await orders.confirm(id1);
            expect(o.status, InventoryDocumentStatus.completed);
            receiptIds.addAll(o.receipts.map((r) => r.id));
            expect(
              o.receipts.map((r) => r.warehouseId).toSet(),
              expected,
              reason: 'receipts ${o.receipts}',
            );
            expect(o.receipts, hasLength(expected.length));
            expect(
              o.receipts.fold<int>(0, (n, r) => n + r.lineCount),
              stockable.length,
              reason: 'a service line must not land on a receipt',
            );
            final service_ = service == null
                ? ''
                : '; service line ${before.lines.where((l) => l.productId == service!.productId).single.id}: '
                      'received ${o.lines.where((l) => l.productId == service!.productId).single.quantityReceived}';
            return '${o.receipts.length} receipt(s): '
                '${o.receipts.map((r) => '#${r.id} W${r.warehouseId} '
                    'F${r.facilityId} ${r.lineCount} line(s)').join(', ')}'
                '$service_';
          });

          await step('get after confirm: no receipts (mbe-api#355)', () async {
            final o = await orders.get(id1);
            expect(o.status, InventoryDocumentStatus.completed);
            // GET carries no receipts until mictlanix/mbe-api#355. When #355
            // ships this fails on purpose: then assert the receipts here and
            // drop the "empty after a plain load" rule from the detail
            // controller (T007).
            expect(o.receipts, isEmpty, reason: 'mbe-api#355 shipped?');
            final pending = o.lines
                .map(
                  (l) =>
                      '${l.id}: ${l.quantityReceived}/'
                      '${l.quantityPending}',
                )
                .join(', ');
            return 'received/pending $pending';
          });

          await step('a confirmed order refuses cancel', () async {
            try {
              await orders.cancel(id1);
              fail('a confirmed order was cancelled');
            } on AppError catch (e) {
              expect(_code(e), 'purchase_order.confirmed_cannot_cancel');
              return _code(e);
            }
          });

          // ---- Print (quickstart 10) ----
          await step('print: PDF bytes', () async {
            final doc = await DocumentSourceImpl(dio).fetch(
              DocumentRef(
                kind: DocumentKind.purchaseOrder,
                recordId: id1,
                title: 't',
              ),
            );
            expect(_isPdf(doc.bytes), isTrue);
            return '${doc.bytes.length} bytes';
          });

          // ---- Email (quickstart 10) ----
          await step('email: only when mail is off', () async {
            // The server checks the mailer before looking up the order, so
            // an order that cannot exist tells mail-off (503) from mail-on
            // (404) without sending anything.
            String? probe;
            try {
              await orders.email(999999999, recipients: ['qa080@example.com']);
              probe = 'no error';
            } on AppError catch (e) {
              probe = _code(e) ?? e.toString();
            }
            if (probe != 'email.not_configured') {
              return 'SKIPPED: mail looks configured (probe answered '
                  '$probe); not sending to anyone';
            }
            try {
              await orders.email(
                id1,
                recipients: ['qa080@example.com'],
                message: tag,
              );
              fail('sent with mail off');
            } on AppError catch (e) {
              expect(_code(e), 'email.not_configured');
              return 'mail off: ${_code(e)}';
            }
          });

          // ---- Create from a group, cancel (quickstart 3, 11) ----
          PurchaseRequest? r2;
          PurchaseOrder? o2;
          await step('create from a Por comprar group', () async {
            r2 = await approvedRequest(product!.productId);
            final reqLine = r2!.lines.single.id;
            final groups = await orders.toPurchase();
            final group = groups.singleWhere(
              (g) => g.supplierId == supplierId && g.facilityId == facility1,
            );
            expect(group.lines.map((l) => l.requestLineId), contains(reqLine));
            o2 = await orders.createFromGroup(
              supplierId: supplierId,
              facilityId: facility1,
            );
            createdOrders.add(o2!.id);
            expect(o2!.status, InventoryDocumentStatus.draft);
            expect(o2!.supplierId, supplierId);
            final taken = o2!.lines.map((l) => l.requestLineId).toSet();
            expect(taken, contains(reqLine));
            expect(
              o2!.lines.length + o2!.skippedCount,
              group.lines.length,
              reason: 'group had ${group.lines.length} line(s)',
            );
            final after = await orders.toPurchase();
            final still = after
                .expand((g) => g.lines)
                .where((l) => l.requestLineId == reqLine);
            expect(still, isEmpty, reason: 'line still pending');
            return 'order #${o2!.id}: ${o2!.lines.length} line(s) of the '
                'group\'s ${group.lines.length}, skipped '
                '${o2!.skippedCount}';
          });

          await step(
            'cancel that draft: its lines back in Por comprar',
            () async {
              if (o2 == null) return 'SKIPPED: no draft from a group';
              final ids = o2!.lines.map((l) => l.requestLineId).toSet();
              final c = await orders.cancel(o2!.id);
              expect(c.status, InventoryDocumentStatus.cancelled);
              expect(
                c.lines,
                hasLength(o2!.lines.length),
                reason: 'lines kept',
              );
              final pending = (await orders.toPurchase())
                  .expand((g) => g.lines)
                  .map((l) => l.requestLineId)
                  .toSet();
              expect(pending.containsAll(ids), isTrue);
              try {
                await orders.cancel(o2!.id);
                fail('cancelled twice');
              } on AppError catch (e) {
                expect(_code(e), 'purchase_order.already_cancelled');
              }
              return '#${o2!.id} cancelled; ${ids.length} line(s) pending again';
            },
          );
        } on _NoFixture {
          skipped('write flow', 'no purchasable product with a supplier');
        } on StateError catch (e) {
          steps.add(_Step('write flow stopped', false, '$e'));
        } finally {
          // Leave dev clean.
          final left = <String>[];
          final receipts = InventoryReceiptRepositoryImpl(dio);
          for (final id in receiptIds) {
            try {
              final r = await receipts.cancel(id);
              left.add('receipt #$id ${r.status.name}');
            } on Object catch (e) {
              left.add('receipt #$id NOT CANCELLED (${_code(e) ?? e})');
            }
          }
          for (final id in createdOrders) {
            try {
              var o = await orders.get(id);
              if (o.status == InventoryDocumentStatus.draft) {
                o = await orders.cancel(id);
              }
              left.add('order #$id ${o.status.name}');
            } on Object catch (e) {
              left.add('order #$id NOT CANCELLED (${_code(e) ?? e})');
            }
          }
          for (final id in createdRequests) {
            try {
              var r = await requests.get(id);
              if (r.status != PurchaseRequestStatus.cancelled) {
                r = await requests.cancel(id);
              }
              left.add('request #$id ${r.status.name}');
            } on Object catch (e) {
              left.add('request #$id NOT CANCELLED (${_code(e) ?? e})');
            }
          }
          steps.add(_Step('cleanup', true, left.join(', ')));
        }
      }

      // ---- Report -----------------------------------------------------------
      final out = StringBuffer('\n== Órdenes de compra live run ==\n');
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
