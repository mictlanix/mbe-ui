import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/invoice_amounts.dart';
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
}
