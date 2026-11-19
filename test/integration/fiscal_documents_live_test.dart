import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_cancellation.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/invoice_amounts.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/sat_cancellation_reason.dart';
import 'package:mbe_ui/features/invoicing/domain/xml_filename.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// Spec 066's repository calls against a live mbe-api (quickstart.md,
/// task T042): the Facturas list and filters, an issued document's detail,
/// its PDF and its XML, and, with `MBE_WRITE=true`, the whole draft flow:
/// create, header round trip, add an order (twice), edit a line, add a
/// product, PPD, confirm, reopen and relations.
///
///   flutter test test/integration/fiscal_documents_live_test.dart \
///     --dart-define-from-file=.env.settings \
///     --dart-define=MBE_POS_USERNAME=... --dart-define=MBE_POS_PASSWORD=... \
///     [--dart-define=MBE_WRITE=true]
///
/// **Read-only by default.** Issued documents come from legacy data and are
/// discovered at run time (`status=issued`); with none on the tenant the PDF
/// and XML checks FAIL saying so, they never skip silently.
///
/// **With `MBE_WRITE=true` each run leaves on the tenant:** two draft invoices
/// (one holds the folio a confirm consumed, one is the empty draft used for
/// the refusal), plus whatever the sealing did. Run writes only against the
/// dev tenant. The headline check is that the server's total after confirm
/// equals the client's estimate (research R11).
///
/// A run without credentials is skipped, like the other live tests.
///
/// **Spec 073** adds `Credit note against the simulated PAC`: with
/// `MBE_WRITE=true` and `PAC_PROVIDER=simulated`, it takes an issued invoice,
/// creates a credit note, copies one line at quantity 1, confirms and stamps it
/// and cancels it with reason 02. It consumes **one credit-note folio** per run
/// and skips, saying why, when the issuer has no credit-note series.
///
/// **Spec 074** adds `Payment receipt against the simulated PAC`: with
/// `MBE_WRITE=true` and `PAC_PROVIDER=simulated`, it seals and stamps a PPD
/// invoice from a completed order, creates a payment receipt by hand for that invoice's customer and
/// recipient, fills the payment, pays the invoice, checks the refusal for
/// amounts that do not equal the payment, confirms, reopens, confirms again,
/// stamps and cancels it with reason 02, then cancels the invoice. It consumes
/// **one invoice folio and one payment-receipt folio** per run and skips,
/// saying why, when the issuer has no payment-receipt series. It does not create a
/// customer payment (the from-payment path is covered by the widget tests).
///
/// **Spec 072** adds a second test, `Stamp, cancel and refresh against the
/// simulated PAC`, which runs only with `MBE_WRITE=true` and against a backend
/// whose `PAC_PROVIDER=simulated` (dev and test). It seals **five** invoices
/// (five folios) and stamps them, each from a completed order that still has
/// something to invoice. It drives the simulator through the
/// generated `PacSimulatorApi`, which only this test uses: stamp, stamp that
/// times out but did stamp then refresh, cancel accepted, cancel pending with
/// the receiver rejecting and then accepting, and cancel with reason 01 naming
/// a stamped substitute.
///
/// **Spec 076** (mbe-api spec 040: the simulator is the CFDI library's) sets
/// these rules for every simulated group:
/// - a **stamp** outcome is set after the document's last seal (reopening and
///   sealing again discards it) and never while the document is stamping;
/// - a **cancellation** outcome is set after the stamp (409
///   `fiscal_document.not_stamped` otherwise);
/// - `not_cancellable` is permanent: every later cancel of that document
///   answers 409, so a successful cancel afterwards needs a new document;
/// - a simulated stamp carries provider RFC `SIM010101SI0`;
/// - the simulator's responses carry only uuid, sat_status and
///   cancellation_status, and no step reads more;
/// - each simulated group skips, saying why, when the simulator is off on the
///   server (its routes answer 404, as on a test server that has moved to the
///   PAC's own test mode).
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _canRun = _username != '' && _password != '';

/// The provider RFC of a stamp from the simulator (mbe-api spec 040). SAT's
/// schema rejected the old `SIM010101SIM`.
const _simulatorRfc = 'SIM010101SI0';

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

/// Whether the server runs the PAC simulator (spec 076, contract C4).
///
/// Asks for document 0, which no server has. With the simulator off the route
/// answers 404 `request.route_not_found` before it looks at anything else;
/// with it on, the same 404 carries the document's own `not_found` code. A
/// document is never sealed for this, so a skipped run spends no folio.
/// Anything else (network, 401, 5xx) is rethrown: it is a failure, not a skip.
Future<bool> _simulatorOn(api.PacSimulatorApi sim) async {
  try {
    await sim.getSimulationApiV1PacSimulatorFiscalDocumentsFiscalDocumentIdGet(
      fiscalDocumentId: 0,
    );
    return true;
  } on DioException catch (e) {
    final body = e.response?.data;
    final code = body is Map ? body['code'] : null;
    if (e.response?.statusCode != 404 || code == null) rethrow;
    return code != 'request.route_not_found';
  }
}

const _simulatorOffReason =
    'the PAC simulator is off on this server (PAC_PROVIDER is not simulated)';

void main() {
  late Dio dio;
  late FiscalDocumentRepositoryImpl docs;
  late DocumentSourceImpl documentSource;
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
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    docs = FiscalDocumentRepositoryImpl(dio);
    documentSource = DocumentSourceImpl(dio);
  });

  test(
    'Facturas against a live mbe-api',
    () async {
      // ---- Read-only (US1, US2) -----------------------------------------
      late FiscalDocumentSummary issued;

      await step('list opens, newest first, with every type', () async {
        final page = await docs.list(limit: 20);
        expect(page.items, isNotEmpty, reason: 'the tenant has no documents');
        final dates = [
          for (final d in page.items)
            if (d.issued != null) d.issued!,
        ];
        final sorted = [...dates]..sort((a, b) => b.compareTo(a));
        expect(dates, sorted, reason: 'not newest first');
        return '${page.total} documents';
      });

      var haveIssued = true;
      await step('an issued document exists to read', () async {
        final page = await docs.list(
          status: FiscalDocumentStatus.issued,
          type: 0,
          limit: 5,
        );
        if (page.items.isEmpty) {
          haveIssued = false;
          throw StateError(
            'NO ISSUED INVOICE on this tenant: the PDF and XML checks cannot '
            'run. They come from legacy data (quickstart prerequisites).',
          );
        }
        issued = page.items.first;
        return 'using #${issued.id} ${issued.folioLabel}';
      });

      if (haveIssued) {
        await step('search finds it by series+folio, UUID and recipient '
            'RFC', () async {
          Future<void> finds(String text, String how) async {
            final page = await docs.list(search: text, limit: 50);
            expect(
              page.items.map((d) => d.id),
              contains(issued.id),
              reason: 'search by $how ("$text") did not find #${issued.id}',
            );
          }

          await finds(issued.folioLabel!, 'series+folio');
          if (issued.stampUuid != null) await finds(issued.stampUuid!, 'UUID');
          if (issued.recipientRfc != null) {
            await finds(issued.recipientRfc!, 'recipient RFC');
          }
          return null;
        });

        await step(
          'filters narrow: status, type, issuer, date range',
          () async {
            final byStatus = await docs.list(
              status: FiscalDocumentStatus.issued,
              limit: 50,
            );
            expect(
              byStatus.items.every(
                (d) => d.status == FiscalDocumentStatus.issued,
              ),
              isTrue,
            );
            final byType = await docs.list(type: issued.typeCode, limit: 50);
            expect(
              byType.items.every((d) => d.typeCode == issued.typeCode),
              isTrue,
            );
            final byIssuer = await docs.list(
              issuer: issued.issuerRfc,
              limit: 50,
            );
            expect(
              byIssuer.items.every((d) => d.issuerRfc == issued.issuerRfc),
              isTrue,
            );
            final day = issued.issued!;
            final byDate = await docs.list(
              dateFrom: DateTime(day.year, day.month, day.day),
              dateTo: DateTime(day.year, day.month, day.day),
              limit: 100,
            );
            expect(byDate.items.map((d) => d.id), contains(issued.id));
            return null;
          },
        );

        await step('detail loads and its total equals the list\'s', () async {
          final detail = await docs.getById(issued.id);
          expect(detail.status, FiscalDocumentStatus.issued);
          expect(detail.lines, isNotEmpty);
          expect(detail.summary.total, issued.total);
          return '${detail.lines.length} lines, total ${detail.summary.total}';
        });

        await step('the PDF starts with %PDF-', () async {
          final pdf = await documentSource.fetch(
            DocumentRef(
              kind: DocumentKind.fiscalDocument,
              recordId: issued.id,
              title: 'live',
            ),
          );
          expect(String.fromCharCodes(pdf.bytes.take(5)), '%PDF-');
          return '${pdf.bytes.length} bytes, ${pdf.filename}';
        });

        await step('the XML bytes equal GET /xml and the name follows the '
            'rule', () async {
          final xml = await docs.downloadXml(issued.id);
          final raw = await dio.get<List<int>>(
            '/api/v1/fiscal-documents/${issued.id}/xml',
            options: Options(responseType: ResponseType.bytes),
          );
          expect(xml.bytes, orderedEquals(Uint8List.fromList(raw.data!)));
          if (issued.serial != null) {
            final expected = invoiceXmlFilename(
              issuerRfc: issued.issuerRfc,
              series: issued.series,
              serial: issued.serial!,
            );
            // The server's own name, when it sends one, should match ours.
            if (xml.filename != null) expect(xml.filename, expected);
          }
          return '${xml.bytes.length} bytes, ${xml.filename ?? 'no filename'}';
        });
      }

      await step('a draft or sealed document\'s PDF is refused with its own '
          'code', () async {
        final drafts = await docs.list(
          status: FiscalDocumentStatus.draft,
          limit: 1,
        );
        if (drafts.items.isEmpty) return 'no draft to try (fine)';
        try {
          await documentSource.fetch(
            DocumentRef(
              kind: DocumentKind.fiscalDocument,
              recordId: drafts.items.first.id,
              title: 'live',
            ),
          );
          fail('a draft produced a PDF');
        } on AppError catch (e) {
          expect(e.problem?.codeName, startsWith('fiscal_document.'));
          return e.problem!.codeName;
        }
      });

      // ---- Writes (US3-US6) ---------------------------------------------
      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        final orders = SalesOrderRepositoryImpl(dio);
        final customers = CustomerRepositoryImpl(dio);
        final products = ProductRepositoryImpl(dio);

        int? customerId;
        String? rfc;
        int? orderId;
        await step(
          'discover a customer with an RFC and a completed order',
          () async {
            final page = await orders.listOrders(
              status: SaleStatus.completed,
              limit: 40,
            );
            for (final o in page.items) {
              final sale = await orders.getById(saleId: o.id);
              final customer = await customers.get(customerId: sale.customer);
              if (customer.taxpayers.isNotEmpty) {
                customerId = sale.customer;
                rfc = customer.taxpayers.first.taxpayerRecipientId;
                orderId = o.id;
                return 'customer $customerId, RFC $rfc, order $orderId';
              }
            }
            throw StateError('no completed order whose customer has an RFC');
          },
        );

        if (customerId != null) {
          late FiscalDocument draft;
          await step('create a draft invoice', () async {
            draft = await docs.create(
              NewInvoice(customerId: customerId!, recipientRfc: rfc!),
            );
            expect(draft.status, FiscalDocumentStatus.draft);
            expect(draft.isEditableDraft, isTrue);
            expect(draft.summary.recipientRfc, rfc);
            return '#${draft.id} ${draft.summary.issuerRfc} '
                '${draft.summary.series}';
          });

          await step('header: the issue date round-trips', () async {
            final sent = DateTime.now().subtract(const Duration(hours: 1));
            final wall = DateTime(
              sent.year,
              sent.month,
              sent.day,
              sent.hour,
              sent.minute,
            );
            await docs.updateHeader(draft.id, InvoiceHeaderPatch(issued: wall));
            final back = await docs.getById(draft.id);
            expect(back.summary.issued, wall, reason: 'time zone shifted');
            return '$wall';
          });

          await step(
            'add the order; adding it again duplicates nothing',
            () async {
              final first = await docs.addSalesOrder(draft.id, orderId!);
              expect(first.lines, isNotEmpty);
              expect(first.lines.every((l) => l.orderLineId != null), isTrue);
              var count = first.lines.length;
              try {
                final again = await docs.addSalesOrder(draft.id, orderId!);
                count = again.lines.length;
              } on AppError catch (e) {
                // Nothing left to invoice is also "no duplicate".
                expect(
                  e.problem?.codeName,
                  'fiscal_document.no_invoiceable_lines',
                );
              }
              expect(count, first.lines.length);
              draft = first;
              return '${first.lines.length} lines';
            },
          );

          await step('edit a line: too much is refused, a discount and Exento '
              'change the estimate', () async {
            final line = draft.lines.first;
            try {
              await docs.updateLine(
                draft.id,
                line.id,
                InvoiceLinePatch(quantity: Decimal.parse('1000000')),
              );
              fail('a quantity above what remains was accepted');
            } on AppError catch (e) {
              expect(
                e.problem?.codeName,
                'fiscal_document.quantity_exceeds_invoiceable',
              );
            }
            final before = invoiceAmounts(draft.lines).total;
            final changed = await docs.updateLine(
              draft.id,
              line.id,
              InvoiceLinePatch(
                discountPercent: Decimal.parse('10'),
                taxRate: InvoiceTaxRate.exempt,
              ),
            );
            final edited = changed.lines.firstWhere((l) => l.id == line.id);
            expect(edited.discountRate, Decimal.parse('0.1'));
            expect(edited.taxRate, Decimal.fromInt(-1));
            expect(invoiceAmounts(changed.lines).total, isNot(before));
            draft = changed;
            return 'estimate $before -> ${invoiceAmounts(changed.lines).total}';
          });

          await step('add a manual product (admin has 56)', () async {
            final found = await products.list(search: 'clavo', limit: 10);
            for (final p in found.items) {
              try {
                final after = await docs.addProduct(draft.id, p.productId);
                expect(after.lines.length, draft.lines.length + 1);
                draft = after;
                return 'added ${p.name}';
              } on AppError catch (e) {
                if (e.problem?.codeName != 'fiscal_document.product_unpriced') {
                  rethrow;
                }
              }
            }
            return 'SKIPPED: no priced product matched "clavo"';
          });

          await step('PPD forces payment form 99', () async {
            final ppd = await docs.updateHeader(
              draft.id,
              const InvoiceHeaderPatch(paymentTerms: InvoicePaymentTerms.ppd),
            );
            expect(ppd.paymentTerms, InvoicePaymentTerms.ppd);
            expect(ppd.paymentForm, 99);
            draft = ppd;
            return null;
          });

          await step('confirming an empty draft is refused', () async {
            final empty = await docs.create(
              NewInvoice(customerId: customerId!, recipientRfc: rfc!),
            );
            try {
              await docs.confirm(empty.id);
              fail('an empty draft was sealed');
            } on AppError catch (e) {
              expect(e.problem?.codeName, 'fiscal_document.no_lines');
            }
            final still = await docs.getById(empty.id);
            expect(still.status, FiscalDocumentStatus.draft);
            return 'empty draft #${empty.id} left as a draft';
          });

          var sealed = false;
          await step('confirm seals it, and the server total equals the '
              'estimate', () async {
            var dropped = '';
            Future<FiscalDocument> confirmOnce() async {
              try {
                return await docs.confirm(draft.id);
              } on AppError catch (e) {
                // A catalog product with no SAT key can't be sealed; that is
                // tenant data, not the flow under test. Drop that line once
                // and retry, saying so.
                final line = e.problem?.intParam('line');
                if (e.problem?.codeName !=
                        'fiscal_document.line_missing_sat_key' ||
                    line == null ||
                    dropped.isNotEmpty) {
                  rethrow;
                }
                final bad = draft.lines[line - 1];
                draft = await docs.removeLine(draft.id, bad.id);
                dropped =
                    ' (dropped line $line "${bad.productName}": no SAT key)';
                return docs.confirm(draft.id);
              }
            }

            try {
              final estimateBefore = invoiceAmounts(draft.lines).total;
              final done = await confirmOnce();
              final estimate = dropped.isEmpty
                  ? estimateBefore
                  : invoiceAmounts(draft.lines).total;
              expect(done.status, FiscalDocumentStatus.sealed);
              expect(done.summary.serial, isNotNull);
              expect(
                done.summary.total,
                estimate,
                reason: 'the client estimate differs from the server total',
              );
              sealed = true;
              draft = done;
              return 'folio ${done.summary.folioLabel}, total $estimate$dropped';
            } on AppError catch (e) {
              final code = e.problem?.codeName ?? '';
              if (code == 'fiscal_document.no_valid_certificate' ||
                  code == 'fiscal_document.certificate_cannot_sign') {
                return 'SKIPPED sealing: $code (issuer has no usable '
                    'certificate)';
              }
              rethrow;
            }
          });

          if (sealed) {
            await step('reopen keeps the folio', () async {
              final serial = draft.summary.serial;
              final reopened = await docs.reopen(draft.id);
              expect(reopened.status, FiscalDocumentStatus.draft);
              expect(reopened.summary.serial, serial);
              draft = reopened;
              return 'folio ${reopened.summary.folioLabel} kept';
            });
          }

          await step('relations: add and remove a 04 if a cancelled invoice '
              'exists', () async {
            final candidates = await docs.list(
              status: FiscalDocumentStatus.cancelled,
              issuer: draft.summary.issuerRfc,
              search: rfc,
              limit: 5,
            );
            if (candidates.items.isEmpty) {
              return 'SKIPPED: no cancelled document of this issuer and RFC';
            }
            try {
              final withRelation = await docs.addRelation(
                draft.id,
                candidates.items.first.id,
                InvoiceRelationType.substitution,
              );
              expect(withRelation.relations, hasLength(1));
              expect(
                withRelation.relationType,
                InvoiceRelationType.substitution,
              );
              final removed = await docs.removeRelation(
                draft.id,
                withRelation.relations.single.id,
              );
              expect(removed.relations, isEmpty);
              return 'added and removed #${candidates.items.first.id}';
            } on AppError catch (e) {
              // The candidate may not be a stamped invoice of the same
              // recipient; the server says so with its own code.
              final code = e.problem?.codeName ?? '';
              if (code == 'fiscal_document.relation_not_allowed') {
                return 'SKIPPED: candidate refused ($code)';
              }
              rethrow;
            }
          });
        }
      }

      // ---- Report ---------------------------------------------------------
      final out = StringBuffer('\n== Facturas live run ==\n');
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

  test(
    'Stamp, cancel and refresh against the simulated PAC (spec 072)',
    () async {
      final steps = <_Step>[];
      final sim = api.PacSimulatorApi(dio, appSerializers);
      if (!await _simulatorOn(sim)) {
        markTestSkipped(_simulatorOffReason);
        return;
      }

      Future<void> step(String name, Future<String?> Function() body) async {
        try {
          final note = await body();
          steps.add(_Step(name, true, note ?? ''));
        } on Object catch (e, st) {
          steps.add(_Step(name, false, '$e\n$st'));
        }
      }

      Future<void> outcome({
        required int id,
        api.PacSimulationUpdateStampEnum? stamp,
        api.PacSimulationUpdateCancellationEnum? cancellation,
      }) =>
          sim.setSimulationApiV1PacSimulatorFiscalDocumentsFiscalDocumentIdPut(
            fiscalDocumentId: id,
            pacSimulationUpdate: api.PacSimulationUpdate(
              (b) => b
                ..stamp = stamp
                ..cancellation = cancellation,
            ),
          );

      Future<void> receiver(int id, api.ReceiverAnswerAnswerEnum answer) => sim
          .answerAsReceiverApiV1PacSimulatorFiscalDocumentsFiscalDocumentIdReceiverPost(
            fiscalDocumentId: id,
            receiverAnswer: api.ReceiverAnswer((b) => b..answer = answer),
          );

      // One customer and RFC feed every invoice. A stamped invoice holds what
      // it took from an order, so each invoice may need another order: keep
      // every completed order of that customer as a candidate.
      final orders = SalesOrderRepositoryImpl(dio);
      final customers = CustomerRepositoryImpl(dio);
      int? customerId;
      String? rfc;
      final orderIds = <int>[];
      await step(
        'discover a customer with an RFC and completed orders',
        () async {
          final page = await orders.listOrders(
            status: SaleStatus.completed,
            limit: 100,
          );
          for (final o in page.items) {
            final sale = await orders.getById(saleId: o.id);
            if (customerId == null) {
              final customer = await customers.get(customerId: sale.customer);
              if (customer.taxpayers.isEmpty) continue;
              customerId = sale.customer;
              rfc = customer.taxpayers.first.taxpayerRecipientId;
            }
            if (sale.customer == customerId) orderIds.add(o.id);
          }
          if (customerId == null) {
            throw StateError('no completed order whose customer has an RFC');
          }
          return 'customer $customerId, RFC $rfc, ${orderIds.length} orders';
        },
      );

      /// A new invoice sealed from the first candidate order that still has
      /// something to invoice. A catalog product with no SAT key is dropped
      /// once (tenant data, not the flow under test).
      Future<FiscalDocument> sealed() async {
        var draft = await docs.create(
          NewInvoice(customerId: customerId!, recipientRfc: rfc!),
        );
        var added = false;
        for (final id in orderIds) {
          try {
            draft = await docs.addSalesOrder(draft.id, id);
            added = true;
            break;
          } on AppError catch (e) {
            if (e.problem?.codeName != 'fiscal_document.no_invoiceable_lines') {
              rethrow;
            }
          }
        }
        if (!added) {
          throw StateError(
            'none of the ${orderIds.length} orders has anything left to '
            'invoice (draft #${draft.id} left empty)',
          );
        }
        try {
          return await docs.confirm(draft.id);
        } on AppError catch (e) {
          final line = e.problem?.intParam('line');
          if (e.problem?.codeName != 'fiscal_document.line_missing_sat_key' ||
              line == null) {
            rethrow;
          }
          draft = await docs.removeLine(draft.id, draft.lines[line - 1].id);
          return docs.confirm(draft.id);
        }
      }

      if (customerId != null) {
        late FiscalDocument a;
        await step('A: seal, stamp: issued, with a simulated stamp', () async {
          a = await sealed();
          expect(a.status, FiscalDocumentStatus.sealed);
          expect(a.canStamp, isTrue);
          a = await docs.stamp(a.id);
          expect(a.status, FiscalDocumentStatus.issued);
          expect(a.stamp, isNotNull);
          expect(
            a.stamp!.simulated,
            isTrue,
            reason: 'this is not a simulated PAC',
          );
          expect(
            a.stamp!.providerRfc,
            _simulatorRfc,
            reason: 'mbe-api spec 040 changed the simulator\'s provider RFC',
          );
          expect(a.canStamp, isFalse);
          expect(a.canCancel, isTrue);
          return '#${a.id} ${a.summary.folioLabel} ${a.stamp!.uuid}';
        });

        await step('A: a second stamp is a harmless no-op', () async {
          final again = await docs.stamp(a.id);
          expect(again.status, FiscalDocumentStatus.issued);
          expect(again.stamp!.uuid, a.stamp!.uuid);
          return null;
        });

        await step('A: cancel with 02, accepted at once: cancelled', () async {
          await outcome(
            id: a.id,
            cancellation: api.PacSimulationUpdateCancellationEnum.accepted,
          );
          final done = await docs.cancel(
            a.id,
            SatCancellationReason.withoutRelation,
          );
          expect(done.status, FiscalDocumentStatus.cancelled);
          expect(done.cancellations.first.reason, '02');
          expect(
            done.cancellations.first.outcome,
            CancellationOutcome.accepted,
          );
          expect(done.hasDocuments, isTrue);
          return null;
        });

        late FiscalDocument b;
        await step('B: a stamp that times out leaves it stamping, and refresh '
            'resolves it to issued', () async {
          b = await sealed();
          await outcome(
            id: b.id,
            stamp: api.PacSimulationUpdateStampEnum.timeoutStamped,
          );
          try {
            await docs.stamp(b.id);
            fail('the timeout was not reported');
          } on AppError catch (e) {
            expect(e.problem?.codeName, 'pac.timeout');
          }
          final waiting = await docs.getById(b.id);
          expect(waiting.status, FiscalDocumentStatus.stamping);
          expect(waiting.canRefresh, isTrue);
          expect(waiting.stampingSince, isNotNull);
          b = await docs.refresh(b.id);
          expect(b.status, FiscalDocumentStatus.issued);
          expect(b.stamp, isNotNull);
          return '#${b.id}';
        });

        await step('B: cancel pending, the receiver rejects, refresh: back to '
            'issued with a rejected entry', () async {
          await outcome(
            id: b.id,
            cancellation: api.PacSimulationUpdateCancellationEnum.pending,
          );
          final pending = await docs.cancel(
            b.id,
            SatCancellationReason.notCarriedOut,
          );
          expect(pending.status, FiscalDocumentStatus.cancellationPending);
          expect(pending.openCancellation, isNotNull);
          expect(pending.canRefresh, isTrue);
          expect(pending.hasDocuments, isTrue);

          final unchanged = await docs.refresh(b.id);
          expect(
            unchanged.status,
            FiscalDocumentStatus.cancellationPending,
            reason: 'nobody has answered yet',
          );

          await receiver(b.id, api.ReceiverAnswerAnswerEnum.reject);
          b = await docs.refresh(b.id);
          expect(b.status, FiscalDocumentStatus.issued);
          expect(b.cancellations.first.outcome, CancellationOutcome.rejected);
          expect(b.canCancel, isTrue);
          return null;
        });

        await step('B: cancel again, the receiver accepts, refresh: cancelled '
            'with two entries, newest first', () async {
          await outcome(
            id: b.id,
            cancellation: api.PacSimulationUpdateCancellationEnum.pending,
          );
          await docs.cancel(b.id, SatCancellationReason.notCarriedOut);
          await receiver(b.id, api.ReceiverAnswerAnswerEnum.accept);
          b = await docs.refresh(b.id);
          expect(b.status, FiscalDocumentStatus.cancelled);
          expect(b.cancellations, hasLength(2));
          expect(b.cancellations[0].outcome, CancellationOutcome.accepted);
          expect(b.cancellations[1].outcome, CancellationOutcome.rejected);
          expect(
            b.cancellations[0].id,
            greaterThan(b.cancellations[1].id),
            reason: 'not newest first',
          );
          return null;
        });

        late FiscalDocument c;
        await step(
          'C: seal and stamp the document that will substitute',
          () async {
            c = await sealed();
            c = await docs.stamp(c.id);
            expect(c.status, FiscalDocumentStatus.issued);
            return '#${c.id} ${c.stamp!.uuid}';
          },
        );

        await step('D: cancel with 01 naming C: cancelled, with the '
            'substitute recorded', () async {
          var d = await sealed();
          d = await docs.stamp(d.id);
          await outcome(
            id: d.id,
            cancellation: api.PacSimulationUpdateCancellationEnum.accepted,
          );
          final done = await docs.cancel(
            d.id,
            SatCancellationReason.withRelation,
            substitution: c.stamp!.uuid,
          );
          expect(done.status, FiscalDocumentStatus.cancelled);
          expect(done.cancellationSubstitution, c.stamp!.uuid);
          return '#${d.id} replaced by #${c.id}';
        });

        await step('cancel with 01 and no substitute is refused with its '
            'code', () async {
          final e = await sealed();
          final stamped = await docs.stamp(e.id);
          try {
            await docs.cancel(stamped.id, SatCancellationReason.withRelation);
            fail('reason 01 without a substitute was accepted');
          } on AppError catch (err) {
            expect(
              err.problem?.codeName,
              'fiscal_document.substitution_required',
            );
          }
          return null;
        });

        await step('the list filters by every new state', () async {
          for (final status in FiscalDocumentStatus.values) {
            final page = await docs.list(status: status, limit: 5);
            for (final item in page.items) {
              expect(item.status, status, reason: 'filter ${status.wireName}');
            }
          }
          return null;
        });
      }

      final out = StringBuffer('\n== Stamp / cancel / refresh live run ==\n');
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
    skip: !_canRun
        ? 'needs --dart-define=MBE_POS_USERNAME/PASSWORD'
        : !_write
        ? 'needs --dart-define=MBE_WRITE=true (stamps documents; dev tenant only)'
        : null,
    timeout: const Timeout(Duration(minutes: 5)),
  );

  test(
    'Credit note against the simulated PAC (spec 073)',
    () async {
      final steps = <_Step>[];
      final sim = api.PacSimulatorApi(dio, appSerializers);
      if (!await _simulatorOn(sim)) {
        markTestSkipped(_simulatorOffReason);
        return;
      }

      Future<void> step(String name, Future<String?> Function() body) async {
        try {
          final note = await body();
          steps.add(_Step(name, true, note ?? ''));
        } on Object catch (e, st) {
          steps.add(_Step(name, false, '$e\n$st'));
        }
      }

      FiscalDocument? invoice;
      await step('an issued, live invoice with a line to credit', () async {
        final page = await docs.list(
          status: FiscalDocumentStatus.issued,
          type: 0,
          limit: 20,
        );
        for (final row in page.items) {
          final candidate = await docs.getById(row.id);
          if (candidate.canIssueCreditNote &&
              candidate.lines.any((l) => l.quantity >= Decimal.one)) {
            invoice = candidate;
            return 'using #${candidate.id} ${candidate.summary.folioLabel}';
          }
        }
        throw StateError(
          'NO ISSUED INVOICE with a line of quantity 1 or more on this tenant',
        );
      });

      FiscalDocument? note;
      if (invoice != null) {
        await step(
          'create: a draft credit note that relates the invoice',
          () async {
            try {
              note = await docs.createCreditNote(invoice!.id);
            } on AppError catch (e) {
              if (e.problem?.codeName ==
                  'fiscal_document.issuer_has_no_series') {
                steps.add(
                  _Step(
                    'create',
                    true,
                    'SKIPPED: the issuer has no credit-note series',
                  ),
                );
                return null;
              }
              rethrow;
            }
            final n = note!;
            expect(n.isCreditNote, isTrue);
            expect(n.status, FiscalDocumentStatus.draft);
            expect(n.creditedInvoice?.documentId, invoice!.id);
            expect(n.isEditableDraft, isTrue);
            expect(n.paymentTerms, InvoicePaymentTerms.pue);
            return '#${n.id}';
          },
        );
      }

      if (note != null) {
        final line = invoice!.lines.firstWhere(
          (l) => l.quantity >= Decimal.one,
        );

        await step('copy above the invoiced quantity is refused with its '
            'code and maximum', () async {
          try {
            await docs.copyInvoiceLine(
              note!.id,
              line.id,
              quantity: line.quantity + Decimal.one,
            );
            fail('a quantity above the invoice line was accepted');
          } on AppError catch (e) {
            expect(
              e.problem?.codeName,
              'fiscal_document.credit_quantity_exceeds_line',
            );
            expect(e.problem?.decimalParam('max'), isNotNull);
          }
          return null;
        });

        await step('copy one line at quantity 1', () async {
          note = await docs.copyInvoiceLine(
            note!.id,
            line.id,
            quantity: Decimal.one,
          );
          expect(note!.lines, hasLength(1));
          expect(note!.lines.single.quantity, Decimal.one);
          return null;
        });

        await step('a form of 99 is replaced by a real one', () async {
          if (note!.needsPaymentForm) {
            note = await docs.updateHeader(
              note!.id,
              const InvoiceHeaderPatch(paymentForm: 3),
            );
          }
          expect(note!.needsPaymentForm, isFalse);
          return 'form ${note!.paymentForm}';
        });

        await step('confirm: sealed, with a folio', () async {
          note = await docs.confirm(note!.id);
          expect(note!.status, FiscalDocumentStatus.sealed);
          expect(note!.summary.serial, isNotNull);
          expect(note!.canReopen, isTrue);
          return note!.summary.folioLabel;
        });

        await step('stamp: issued, with a simulated stamp', () async {
          note = await docs.stamp(note!.id);
          expect(note!.status, FiscalDocumentStatus.issued);
          expect(
            note!.stamp?.simulated,
            isTrue,
            reason: 'this is not a simulated PAC',
          );
          expect(
            note!.stamp?.providerRfc,
            _simulatorRfc,
            reason: 'mbe-api spec 040 changed the simulator\'s provider RFC',
          );
          return note!.stamp!.uuid;
        });

        await step('cancel with 02: cancelled, so the invoice stays '
            'cancellable', () async {
          await sim
              .setSimulationApiV1PacSimulatorFiscalDocumentsFiscalDocumentIdPut(
                fiscalDocumentId: note!.id,
                pacSimulationUpdate: api.PacSimulationUpdate(
                  (b) => b
                    ..cancellation =
                        api.PacSimulationUpdateCancellationEnum.accepted,
                ),
              );
          final done = await docs.cancel(
            note!.id,
            SatCancellationReason.withoutRelation,
          );
          expect(done.status, FiscalDocumentStatus.cancelled);
          return null;
        });
      }

      final out = StringBuffer('\n== Credit note live run ==\n');
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
    skip: !_canRun
        ? 'needs --dart-define=MBE_POS_USERNAME/PASSWORD'
        : !_write
        ? 'needs --dart-define=MBE_WRITE=true (stamps a document; dev tenant only)'
        : null,
    timeout: const Timeout(Duration(minutes: 5)),
  );

  test(
    'Payment receipt against the simulated PAC (spec 074)',
    () async {
      final steps = <_Step>[];
      final sim = api.PacSimulatorApi(dio, appSerializers);
      if (!await _simulatorOn(sim)) {
        markTestSkipped(_simulatorOffReason);
        return;
      }

      Future<void> step(String name, Future<String?> Function() body) async {
        try {
          final note = await body();
          steps.add(_Step(name, true, note ?? ''));
        } on Object catch (e, st) {
          steps.add(_Step(name, false, '$e\n$st'));
        }
      }

      Future<void> simulate(int id) =>
          sim.setSimulationApiV1PacSimulatorFiscalDocumentsFiscalDocumentIdPut(
            fiscalDocumentId: id,
            pacSimulationUpdate: api.PacSimulationUpdate(
              (b) => b
                ..cancellation =
                    api.PacSimulationUpdateCancellationEnum.accepted,
            ),
          );

      // The receipt needs a stamped, live PPD invoice. Dev has few or none
      // among its recent ones, so the test makes its own from a completed
      // order that still has something to invoice (one invoice folio).
      final orders = SalesOrderRepositoryImpl(dio);
      final customers = CustomerRepositoryImpl(dio);
      int? customerId;
      String? rfc;
      final orderIds = <int>[];
      await step(
        'discover a customer with an RFC and completed orders',
        () async {
          final page = await orders.listOrders(
            status: SaleStatus.completed,
            limit: 100,
          );
          for (final o in page.items) {
            final sale = await orders.getById(saleId: o.id);
            if (customerId == null) {
              final customer = await customers.get(customerId: sale.customer);
              if (customer.taxpayers.isEmpty) continue;
              customerId = sale.customer;
              rfc = customer.taxpayers.first.taxpayerRecipientId;
            }
            if (sale.customer == customerId) orderIds.add(o.id);
          }
          if (customerId == null) {
            throw StateError('no completed order whose customer has an RFC');
          }
          return 'customer $customerId, RFC $rfc, ${orderIds.length} orders';
        },
      );

      FiscalDocument? invoice;
      if (customerId != null) {
        await step('a PPD invoice: sealed and stamped from an order', () async {
          var draft = await docs.create(
            NewInvoice(customerId: customerId!, recipientRfc: rfc!),
          );
          var added = false;
          for (final id in orderIds) {
            try {
              draft = await docs.addSalesOrder(draft.id, id);
              added = true;
              break;
            } on AppError catch (e) {
              if (e.problem?.codeName !=
                  'fiscal_document.no_invoiceable_lines') {
                rethrow;
              }
            }
          }
          if (!added) {
            throw StateError(
              'none of the ${orderIds.length} orders has anything left to '
              'invoice (draft #${draft.id} left empty)',
            );
          }
          draft = await docs.updateHeader(
            draft.id,
            const InvoiceHeaderPatch(paymentTerms: InvoicePaymentTerms.ppd),
          );
          expect(draft.paymentTerms, InvoicePaymentTerms.ppd);
          FiscalDocument sealedInvoice;
          try {
            sealedInvoice = await docs.confirm(draft.id);
          } on AppError catch (e) {
            final line = e.problem?.intParam('line');
            if (e.problem?.codeName != 'fiscal_document.line_missing_sat_key' ||
                line == null) {
              rethrow;
            }
            draft = await docs.removeLine(draft.id, draft.lines[line - 1].id);
            sealedInvoice = await docs.confirm(draft.id);
          }
          final stamped = await docs.stamp(sealedInvoice.id);
          expect(stamped.status, FiscalDocumentStatus.issued);
          expect(stamped.stamp?.simulated, isTrue);
          invoice = stamped;
          return '#${stamped.id} ${stamped.summary.folioLabel}';
        });
      }

      FiscalDocument? receipt;
      if (invoice != null) {
        await step(
          'create: a draft receipt for the invoice\'s customer',
          () async {
            try {
              receipt = await docs.createPaymentReceipt(
                NewPaymentReceipt(
                  customerId: invoice!.customerId!,
                  recipientRfc: invoice!.summary.recipientRfc!,
                ),
              );
            } on AppError catch (e) {
              if (e.problem?.codeName ==
                  'fiscal_document.issuer_has_no_series') {
                steps.add(
                  _Step(
                    'create',
                    true,
                    'SKIPPED: the issuer has no payment-receipt series',
                  ),
                );
                return null;
              }
              rethrow;
            }
            final r = receipt!;
            expect(r.isPaymentReceipt, isTrue);
            expect(r.status, FiscalDocumentStatus.draft);
            expect(r.customerPaymentId, isNull);
            expect(r.paidInvoices, isEmpty);
            expect(r.isEditableDraft, isTrue);
            return '#${r.id}';
          },
        );
      }

      if (receipt != null) {
        final id = receipt!.id;
        final today = DateTime.now();

        await step('header: date, amount and a real form', () async {
          receipt = await docs.updateHeader(
            id,
            InvoiceHeaderPatch(
              paymentDate: DateTime(today.year, today.month, today.day),
              paymentAmount: Decimal.parse('1.00'),
              paymentForm: 3,
              paymentReference: 'MBE-UI LIVE',
            ),
          );
          expect(receipt!.paymentAmount, Decimal.parse('1.00'));
          expect(receipt!.paymentForm, 3);
          expect(receipt!.paymentReference, 'MBE-UI LIVE');
          return null;
        });

        await step('pay the invoice: the default amount, installment and '
            'balance', () async {
          receipt = await docs.addPaidInvoice(id, invoice!.id);
          final paid = receipt!.paidInvoices.single;
          expect(paid.invoiceId, invoice!.id);
          expect(paid.amount, greaterThan(Decimal.zero));
          expect(paid.amount, lessThanOrEqualTo(Decimal.parse('1.00')));
          expect(paid.installment, greaterThanOrEqualTo(1));
          expect(paid.remaining, paid.previousBalance - paid.amount);
          return 'installment ${paid.installment}, amount ${paid.amount}';
        });

        await step(
          'a payment lowered below what is assigned is refused',
          () async {
            try {
              await docs.updateHeader(
                id,
                InvoiceHeaderPatch(
                  paymentAmount:
                      receipt!.assignedAmount - Decimal.parse('0.01'),
                ),
              );
              fail('a payment below the assigned amount was accepted');
            } on AppError catch (e) {
              expect(
                e.problem?.codeName,
                'fiscal_document.amounts_exceed_payment',
              );
            }
            return null;
          },
        );

        await step('confirm with amounts that do not equal the payment is '
            'refused', () async {
          receipt = await docs.updateHeader(
            id,
            InvoiceHeaderPatch(
              paymentAmount: receipt!.assignedAmount + Decimal.one,
            ),
          );
          try {
            await docs.confirm(id);
            fail('a receipt with unassigned money was confirmed');
          } on AppError catch (e) {
            expect(
              e.problem?.codeName,
              'fiscal_document.amounts_not_equal_payment',
            );
          }
          return null;
        });

        await step('confirm: sealed, with a folio', () async {
          receipt = await docs.updateHeader(
            id,
            InvoiceHeaderPatch(paymentAmount: receipt!.assignedAmount),
          );
          expect(receipt!.unassignedAmount, Decimal.zero);
          receipt = await docs.confirm(id);
          expect(receipt!.status, FiscalDocumentStatus.sealed);
          expect(receipt!.summary.serial, isNotNull);
          expect(receipt!.canReopen, isTrue);
          return receipt!.summary.folioLabel;
        });

        await step('reopen and confirm again keep the folio', () async {
          final folio = receipt!.summary.folioLabel;
          receipt = await docs.reopen(id);
          expect(receipt!.status, FiscalDocumentStatus.draft);
          receipt = await docs.confirm(id);
          expect(receipt!.summary.folioLabel, folio);
          return null;
        });

        await step('stamp: issued, with a simulated stamp', () async {
          receipt = await docs.stamp(id);
          expect(receipt!.status, FiscalDocumentStatus.issued);
          expect(
            receipt!.stamp?.simulated,
            isTrue,
            reason: 'this is not a simulated PAC',
          );
          expect(
            receipt!.stamp?.providerRfc,
            _simulatorRfc,
            reason: 'mbe-api spec 040 changed the simulator\'s provider RFC',
          );
          return receipt!.stamp!.uuid;
        });

        await step('the invoice cannot be cancelled while the receipt is '
            'live', () async {
          try {
            await docs.cancel(
              invoice!.id,
              SatCancellationReason.withoutRelation,
            );
            fail('an invoice with a live receipt was cancelled');
          } on AppError catch (e) {
            expect(e.problem?.codeName, 'fiscal_document.has_live_documents');
          }
          return null;
        });

        await step('cancel the receipt with 02: cancelled', () async {
          await simulate(id);
          final done = await docs.cancel(
            id,
            SatCancellationReason.withoutRelation,
          );
          expect(done.status, FiscalDocumentStatus.cancelled);
          return null;
        });

        await step('then the invoice cancels too (cleanup)', () async {
          await simulate(invoice!.id);
          final done = await docs.cancel(
            invoice!.id,
            SatCancellationReason.withoutRelation,
          );
          expect(done.status, FiscalDocumentStatus.cancelled);
          return done.summary.folioLabel;
        });
      }

      final out = StringBuffer('\n== Payment receipt live run ==\n');
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
    skip: !_canRun
        ? 'needs --dart-define=MBE_POS_USERNAME/PASSWORD'
        : !_write
        ? 'needs --dart-define=MBE_WRITE=true (stamps a document; dev tenant only)'
        : null,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
