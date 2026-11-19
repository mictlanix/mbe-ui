import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_cancellation.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/sat_cancellation_reason.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

ResponseBody _json(Object body, [int status = 200]) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: _jsonHeaders);

Map<String, Object?> _lineJson({
  int id = 10,
  String quantity = '2.0000',
  String price = '100.0000000',
  String discount = '0.1000',
  String taxRate = '0.16',
  int? orderDetail = 5,
}) => {
  'fiscal_document_detail_id': id,
  'product_service': '01010101',
  'product_code': 'P-1',
  'product_name': 'Tornillo',
  'unit_of_measurement': 'H87',
  'unit_of_measurement_name': 'Pieza',
  'quantity': quantity,
  'price': price,
  'discount': discount,
  'tax_rate': taxRate,
  'tax_included': false,
  'comment': null,
  'product': 3,
  'order_detail': orderDetail,
};

Map<String, Object?> _docJson({
  String status = 'draft',
  int type = 0,
  int paymentTerms = 0,
  int? serial,
  String? total,
  List<Object?>? lines,
  List<Object?>? relations,
  Map<String, Object?> extra = const {},
}) => {
  'fiscal_document_id': 7,
  'type': type,
  'version': '4.0',
  'batch': 'A',
  'serial': serial,
  'issuer': 'XAXX010101000',
  'issuer_name': 'Emisor',
  'recipient': 'XEXX010101000',
  'recipient_name': 'Receptor',
  'issued': '2026-11-16T10:30:00',
  'stamp_uuid': null,
  'status': status,
  'total': total,
  'payment_method': 99,
  'payment_terms': paymentTerms,
  'currency': 100,
  'exchange_rate': '1.0000',
  'issued_location': '64000',
  'customer': 4,
  'facility': 2,
  'lines': lines ?? [_lineJson()],
  'relations': relations,
  ...extra,
};

Map<String, Object?> _summaryJson({
  int id = 1,
  String status = 'issued',
  String? total = '232.00',
}) => {
  'fiscal_document_id': id,
  'type': 0,
  'version': '4.0',
  'batch': 'GR',
  'serial': 4776,
  'issuer': 'XAXX010101000',
  'issuer_name': 'Emisor',
  'recipient': 'XEXX010101000',
  'recipient_name': 'Receptor',
  'issued': '2026-11-16T10:30:00',
  'stamp_uuid': 'AAAA-BBBB',
  'status': status,
  'total': total,
};

FiscalDocumentRepositoryImpl _repo(
  Future<ResponseBody> Function(RequestOptions) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _Adapter(handler);
  return FiscalDocumentRepositoryImpl(dio);
}

void main() {
  group('list', () {
    test('sends the filters, maps rows and a null total', () async {
      late RequestOptions captured;
      final repo = _repo((o) async {
        captured = o;
        return _json({
          'items': [
            _summaryJson(),
            _summaryJson(id: 2, status: 'sealed', total: null),
          ],
          'total': 2,
        });
      });

      final page = await repo.list(
        search: 'GR4776',
        issuer: 'XAXX010101000',
        type: 100,
        status: FiscalDocumentStatus.sealed,
        dateFrom: DateTime(2026, 11, 1),
        dateTo: DateTime(2026, 11, 16),
        skip: 20,
        limit: 20,
      );

      final q = captured.queryParameters;
      expect(q['search'], 'GR4776');
      expect(q['issuer'], 'XAXX010101000');
      expect(q['type'], 100);
      expect(q['status'], 'sealed');
      expect(q['skip'], 20);
      expect(q['limit'], 20);
      expect(page.total, 2);
      expect(page.items[0].status, FiscalDocumentStatus.issued);
      expect(page.items[0].total, Decimal.parse('232'));
      expect(page.items[0].folioLabel, 'GR4776');
      expect(page.items[1].status, FiscalDocumentStatus.sealed);
      expect(page.items[1].total, isNull);
    });
  });

  group('getById', () {
    test('maps ints, decimal strings, tax rate and relation type', () async {
      final repo = _repo(
        (o) async => _json(
          _docJson(
            status: 'sealed',
            paymentTerms: 1,
            serial: 12,
            lines: [_lineJson(taxRate: '-1')],
            relations: [
              {
                'fiscal_document_relation_id': 3,
                'relation': 99,
                'type': '04',
                'stamp_uuid': 'U',
                'batch': 'A',
                'serial': 1,
              },
              {'fiscal_document_relation_id': 4, 'relation': 98, 'type': null},
            ],
          ),
        ),
      );

      final doc = await repo.getById(7);

      expect(doc.status, FiscalDocumentStatus.sealed);
      expect(doc.paymentTerms, InvoicePaymentTerms.ppd);
      expect(doc.paymentForm, 99);
      expect(doc.currencyCode, 100);
      expect(doc.summary.total, isNull);
      expect(doc.canReopen, isTrue);
      final line = doc.lines.single;
      expect(line.quantity, Decimal.parse('2'));
      expect(line.discountRate, Decimal.parse('0.1'));
      expect(line.tax, InvoiceTaxRate.exempt);
      expect(line.orderLineId, 5);
      expect(doc.relations[0].type, InvoiceRelationType.substitution);
      expect(doc.relations[1].type, isNull);
      expect(doc.relationType, InvoiceRelationType.substitution);
    });

    test('a document with no relations key has none', () async {
      final repo = _repo((o) async => _json(_docJson()));
      expect((await repo.getById(7)).relations, isEmpty);
    });
  });

  group('writes', () {
    test('create sends the customer and RFC', () async {
      late RequestOptions c;
      final repo = _repo((o) async {
        c = o;
        return _json(_docJson(), 201);
      });
      await repo.create(
        const NewInvoice(customerId: 4, recipientRfc: 'XEXX010101000'),
      );
      expect(c.method, 'POST');
      expect(c.path, '/api/v1/fiscal-documents');
      expect(c.data, {'customer': 4, 'recipient': 'XEXX010101000'});
    });

    test('updateHeader sends only the changed fields', () async {
      late RequestOptions c;
      final repo = _repo((o) async {
        c = o;
        return _json(_docJson());
      });
      await repo.updateHeader(
        7,
        const InvoiceHeaderPatch(reference: 'OC-1', usage: 'G03'),
      );
      expect(c.method, 'PUT');
      expect(c.data, {'reference': 'OC-1', 'usage': 'G03'});
    });

    test('PPD sends the terms and no payment form', () async {
      late RequestOptions c;
      final repo = _repo((o) async {
        c = o;
        return _json(_docJson());
      });
      await repo.updateHeader(
        7,
        const InvoiceHeaderPatch(
          paymentTerms: InvoicePaymentTerms.ppd,
          paymentForm: 3,
        ),
      );
      final body = c.data as Map<String, dynamic>;
      expect(body['payment_terms'], 1);
      expect(body.containsKey('payment_method'), isFalse);
    });

    test('updateHeader sends the issue date as wall-clock time', () async {
      late RequestOptions c;
      final repo = _repo((o) async {
        c = o;
        return _json(_docJson());
      });
      await repo.updateHeader(
        7,
        InvoiceHeaderPatch(issued: DateTime(2026, 11, 16, 9, 30)),
      );
      final sent = (c.data as Map<String, dynamic>)['issued'] as String;
      expect(sent, startsWith('2026-11-16T09:30:00'));
      expect(sent, isNot(contains('Z')));
    });

    test(
      'updateLine turns a percentage into a fraction and wraps values',
      () async {
        late RequestOptions c;
        final repo = _repo((o) async {
          c = o;
          return _json(_docJson());
        });
        await repo.updateLine(
          7,
          10,
          InvoiceLinePatch(
            quantity: Decimal.parse('3'),
            price: Decimal.parse('12.5'),
            discountPercent: Decimal.parse('10'),
            taxRate: InvoiceTaxRate.exempt,
            productName: '',
          ),
        );
        expect(c.method, 'PUT');
        expect(c.path, '/api/v1/fiscal-documents/7/lines/10');
        final body = c.data as Map<String, dynamic>;
        expect(Decimal.parse('${body['quantity']}'), Decimal.parse('3'));
        expect(Decimal.parse('${body['price']}'), Decimal.parse('12.5'));
        expect(Decimal.parse('${body['discount']}'), Decimal.parse('0.1'));
        expect(Decimal.parse('${body['tax_rate']}'), Decimal.fromInt(-1));
        // A blank name is sent blank so the server resets it.
        expect(body['product_name'], '');
        expect(body.containsKey('comment'), isFalse);
      },
    );

    test('add order, add product, remove line, confirm and reopen hit their '
        'endpoints', () async {
      final calls = <String>[];
      final repo = _repo((o) async {
        calls.add('${o.method} ${o.path}');
        return _json(_docJson());
      });
      await repo.addSalesOrder(7, 55);
      await repo.addProduct(7, 3);
      await repo.removeLine(7, 10);
      await repo.confirm(7);
      await repo.reopen(7);
      expect(calls, [
        'POST /api/v1/fiscal-documents/7/sales-orders',
        'POST /api/v1/fiscal-documents/7/lines',
        'DELETE /api/v1/fiscal-documents/7/lines/10',
        'POST /api/v1/fiscal-documents/7/confirm',
        'POST /api/v1/fiscal-documents/7/reopen',
      ]);
    });

    test('relations send 04 or 07 and delete by relation id', () async {
      final sent = <RequestOptions>[];
      final repo = _repo((o) async {
        sent.add(o);
        return _json(_docJson());
      });
      await repo.addRelation(7, 99, InvoiceRelationType.substitution);
      await repo.addRelation(7, 98, InvoiceRelationType.advanceApplication);
      await repo.removeRelation(7, 3);
      expect(sent[0].data, {'relation': 99, 'type': '04'});
      expect(sent[1].data, {'relation': 98, 'type': '07'});
      expect(sent[2].path, '/api/v1/fiscal-documents/7/relations/3');
    });

    test('a refusal keeps its code', () async {
      final repo = _repo(
        (o) async => _json({
          'detail': 'no lines',
          'code': 'fiscal_document.no_lines',
          'params': <String, Object?>{},
        }, 422),
      );
      await expectLater(
        repo.confirm(7),
        throwsA(
          isA<Object>().having((e) => '$e', 'text', contains('no_lines')),
        ),
      );
    });
  });

  group('payment receipts (spec 074)', () {
    Map<String, Object?> receiptJson({
      List<Object?>? paid,
      Map<String, Object?> extra = const {},
    }) => _docJson(
      type: 200,
      lines: const [],
      extra: {
        'payment_date': '2026-11-12',
        'payment_amount': '11600.00',
        'payment_reference': 'SPEI 99812',
        'customer_payment': 4127,
        'paid_invoices': paid ?? const [],
        ...extra,
      },
    );

    Map<String, Object?> paidJson({int id = 31}) => {
      'fiscal_document_relation_id': id,
      'invoice': 12,
      'batch': 'A',
      'serial': 5238,
      'stamp_uuid': 'AAAA-BBBB',
      'installment': 2,
      'previous_balance': '8000.00',
      'amount': '3600.00',
      'remaining': '4400.00',
    };

    test('createPaymentReceipt posts the customer, RFC and payment and maps '
        'the receipt', () async {
      late RequestOptions sent;
      final repo = _repo((o) async {
        sent = o;
        return _json(receiptJson(paid: [paidJson()]), 201);
      });

      final doc = await repo.createPaymentReceipt(
        const NewPaymentReceipt(
          customerId: 4,
          recipientRfc: 'XEXX010101000',
          customerPaymentId: 4127,
        ),
      );

      expect(sent.method, 'POST');
      expect(sent.path, '/api/v1/fiscal-documents/payment-receipts');
      expect(sent.data, {
        'customer': 4,
        'recipient': 'XEXX010101000',
        'customer_payment': 4127,
      });
      expect(doc.isPaymentReceipt, isTrue);
      expect(doc.paymentDate, DateTime(2026, 11, 12));
      expect(doc.paymentAmount, Decimal.parse('11600.00'));
      expect(doc.paymentReference, 'SPEI 99812');
      expect(doc.customerPaymentId, 4127);
      final paid = doc.paidInvoices.single;
      expect(paid.relationId, 31);
      expect(paid.invoiceId, 12);
      expect(paid.folioLabel, 'A5238');
      expect(paid.installment, 2);
      expect(paid.previousBalance, Decimal.parse('8000.00'));
      expect(paid.amount, Decimal.parse('3600.00'));
      expect(paid.remaining, Decimal.parse('4400.00'));
    });

    test('a by-hand receipt sends no payment id', () async {
      late RequestOptions sent;
      final repo = _repo((o) async {
        sent = o;
        return _json(receiptJson(extra: {'customer_payment': null}), 201);
      });

      final doc = await repo.createPaymentReceipt(
        const NewPaymentReceipt(customerId: 4, recipientRfc: 'XEXX010101000'),
      );

      expect((sent.data as Map).containsKey('customer_payment'), isFalse);
      expect(doc.customerPaymentId, isNull);
    });

    test(
      'addPaidInvoice sends the invoice, and the amount only when given',
      () async {
        final sent = <RequestOptions>[];
        final repo = _repo((o) async {
          sent.add(o);
          return _json(receiptJson(paid: [paidJson()]));
        });

        await repo.addPaidInvoice(7, 12);
        await repo.addPaidInvoice(7, 12, amount: Decimal.parse('3600.5'));

        expect(sent[0].method, 'POST');
        expect(sent[0].path, '/api/v1/fiscal-documents/7/paid-invoices');
        expect(sent[0].data, {'invoice': 12});
        final body = sent[1].data as Map<String, dynamic>;
        expect(body['invoice'], 12);
        expect(Decimal.parse('${body['amount']}'), Decimal.parse('3600.5'));
      },
    );

    test('updatePaidInvoice puts the amount on the relation', () async {
      late RequestOptions sent;
      final repo = _repo((o) async {
        sent = o;
        return _json(receiptJson(paid: [paidJson()]));
      });

      await repo.updatePaidInvoice(7, 31, Decimal.parse('100'));

      expect(sent.method, 'PUT');
      expect(sent.path, '/api/v1/fiscal-documents/7/paid-invoices/31');
      expect(
        Decimal.parse('${(sent.data as Map)['amount']}'),
        Decimal.parse('100'),
      );
    });

    test('removePaidInvoice deletes the relation', () async {
      late RequestOptions sent;
      final repo = _repo((o) async {
        sent = o;
        return _json(receiptJson());
      });

      final doc = await repo.removePaidInvoice(7, 31);

      expect(sent.method, 'DELETE');
      expect(sent.path, '/api/v1/fiscal-documents/7/paid-invoices/31');
      expect(doc.paidInvoices, isEmpty);
    });

    test('a receipt header patch sends only the receipt fields', () async {
      late RequestOptions sent;
      final repo = _repo((o) async {
        sent = o;
        return _json(receiptJson());
      });

      await repo.updateHeader(
        7,
        InvoiceHeaderPatch(
          paymentDate: DateTime(2026, 11, 12),
          paymentAmount: Decimal.parse('11600'),
          paymentForm: 3,
          paymentReference: 'SPEI 1',
          orderingBank: 'Bank X',
          comment: 'n',
        ),
      );

      final body = sent.data as Map<String, dynamic>;
      expect(body.keys.toSet(), {
        'payment_date',
        'payment_amount',
        'payment_method',
        'payment_reference',
        'ordering_bank',
        'comment',
      });
      expect(body['payment_date'], '2026-11-12');
      expect(
        Decimal.parse('${body['payment_amount']}'),
        Decimal.parse('11600'),
      );
      expect(body['payment_method'], 3);
    });

    test('an invoice header patch sends none of the receipt fields', () async {
      late RequestOptions sent;
      final repo = _repo((o) async {
        sent = o;
        return _json(_docJson());
      });

      await repo.updateHeader(
        7,
        const InvoiceHeaderPatch(reference: 'OC-1', usage: 'G03'),
      );

      expect((sent.data as Map).keys.toSet(), {'reference', 'usage'});
    });

    test('a refusal keeps its code and params', () async {
      final repo = _repo(
        (o) async => _json({
          'detail': 'x',
          'code': 'fiscal_document.payment_already_receipted',
          'params': {'fiscal_document_id': 77},
        }, 409),
      );
      await expectLater(
        repo.createPaymentReceipt(
          const NewPaymentReceipt(
            customerId: 4,
            recipientRfc: 'X',
            customerPaymentId: 1,
          ),
        ),
        throwsA(
          isA<Object>().having(
            (e) => '$e',
            'text',
            contains('payment_already_receipted'),
          ),
        ),
      );
    });
  });

  group('credit notes (spec 073)', () {
    test(
      'createCreditNote posts the invoice id and maps the document',
      () async {
        late RequestOptions sent;
        final repo = _repo((o) async {
          sent = o;
          return _json(
            _docJson(
              type: 100,
              relations: [
                {
                  'fiscal_document_relation_id': 9,
                  'relation': 12,
                  'type': '01',
                  'batch': 'GR',
                  'serial': 12,
                },
              ],
            ),
            201,
          );
        });

        final doc = await repo.createCreditNote(12);

        expect(sent.method, 'POST');
        expect(sent.path, '/api/v1/fiscal-documents/credit-notes');
        expect(sent.data, {'invoice': 12});
        expect(doc.isCreditNote, isTrue);
        // A wire relation of type 01 is the credited invoice.
        expect(doc.relations.single.type, InvoiceRelationType.creditNoteOf);
        expect(doc.creditedInvoice?.documentId, 12);
      },
    );

    test('copyInvoiceLine posts the invoice line and the quantity', () async {
      late RequestOptions sent;
      final repo = _repo((o) async {
        sent = o;
        return _json(_docJson(type: 100));
      });

      await repo.copyInvoiceLine(7, 31, quantity: Decimal.parse('1.5'));

      expect(sent.method, 'POST');
      expect(sent.path, '/api/v1/fiscal-documents/7/invoice-lines');
      final body = sent.data as Map<String, dynamic>;
      expect(body['line'], 31);
      expect(Decimal.parse('${body['quantity']}'), Decimal.parse('1.5'));
    });

    test('a refused copy keeps its code', () async {
      final repo = _repo(
        (o) async => _json({
          'detail': 'x',
          'code': 'fiscal_document.credit_quantity_exceeds_line',
          'params': {'max': '2'},
        }, 422),
      );
      await expectLater(
        repo.copyInvoiceLine(7, 31, quantity: Decimal.parse('9')),
        throwsA(
          isA<Object>().having(
            (e) => '$e',
            'text',
            contains('credit_quantity_exceeds_line'),
          ),
        ),
      );
    });
  });

  group('states (spec 072 R1)', () {
    test('every constant of both generated status enums maps, and the six '
        'domain states are all reached', () async {
      final repo = _repo((o) async {
        if (o.path.endsWith('/fiscal-documents')) {
          return _json({
            'items': [
              for (final v in FiscalDocumentStatus.values)
                _summaryJson(status: v.wireName),
            ],
            'total': 6,
          });
        }
        return _json(_docJson(status: 'sealed'));
      });
      final page = await repo.list();
      expect(page.items.map((i) => i.status).toSet(), {
        ...FiscalDocumentStatus.values,
      });
      expect(
        api.FiscalDocumentSummaryStatusEnum.values.length,
        FiscalDocumentStatus.values.length,
        reason: 'a state added on the server needs a domain state',
      );
      expect(
        api.FiscalDocumentResponseStatusEnum.values.length,
        FiscalDocumentStatus.values.length,
      );
      // The detail's twin, one request per wire value.
      for (final status in FiscalDocumentStatus.values) {
        final detail = _repo(
          (o) async => _json(_docJson(status: status.wireName)),
        );
        expect((await detail.getById(7)).status, status);
      }
    });

    test(
      'sends the wire name, not the enum name, as the list filter',
      () async {
        late RequestOptions captured;
        final repo = _repo((o) async {
          captured = o;
          return _json({'items': <Object?>[], 'total': 0});
        });
        await repo.list(status: FiscalDocumentStatus.cancellationPending);
        expect(captured.uri.queryParameters['status'], 'cancellation_pending');
      },
    );
  });

  group('stamp and cancellations', () {
    test('maps the stamp, the pending stamp time, the substitute and the '
        'history, with an unrecognised outcome kept raw', () async {
      final repo = _repo(
        (o) async => _json(
          _docJson(
            status: 'cancelled',
            extra: {
              'stamp': {
                'uuid': 'U-1',
                'stamped': '2026-11-17T09:13:00',
                'sat_certificate': '00001000000509846663',
                'provider_rfc': 'SIM010101SI0',
                'simulated': true,
              },
              'stamping_since': '2026-11-17T11:05:00',
              'cancellation_substitution': 'U-2',
              'cancellations': [
                {
                  'fiscal_document_cancellation_id': 2,
                  'reason': '01',
                  'substitution': 'U-2',
                  'status': 'accepted',
                  'pac_code': null,
                  'pac_message': null,
                  'requested_by': 5,
                  'requested_at': '2026-11-17T12:40:00',
                  'answered_at': '2026-11-17T12:41:00',
                  'resolved_at': '2026-11-17T12:41:00',
                  'last_checked_at': null,
                },
                {
                  'fiscal_document_cancellation_id': 1,
                  'reason': '02',
                  'substitution': null,
                  'status': 'not_cancellable',
                  'pac_code': '2001',
                  'pac_message': 'El receptor rechazó',
                  'requested_by': 5,
                  'requested_at': '2026-11-17T12:30:00',
                  'answered_at': null,
                  'resolved_at': null,
                  'last_checked_at': null,
                },
                {
                  'fiscal_document_cancellation_id': 0,
                  'reason': '03',
                  'substitution': null,
                  'status': 'from_the_future',
                  'requested_by': 6,
                  'requested_at': '2026-11-17T12:00:00',
                },
              ],
            },
          ),
        ),
      );

      final doc = await repo.getById(7);

      expect(doc.stamp?.uuid, 'U-1');
      expect(doc.stamp?.simulated, isTrue);
      expect(doc.stamp?.providerRfc, 'SIM010101SI0');
      expect(doc.stamp?.satCertificate, '00001000000509846663');
      expect(doc.stampingSince, DateTime(2026, 11, 17, 11, 5));
      expect(doc.cancellationSubstitution, 'U-2');
      expect(doc.cancellations.map((c) => c.id), [2, 1, 0]);
      expect(doc.cancellations[0].outcome, CancellationOutcome.accepted);
      expect(doc.cancellations[0].requestedBy, 5);
      expect(doc.cancellations[1].outcome, CancellationOutcome.notCancellable);
      expect(doc.cancellations[1].pacMessage, 'El receptor rechazó');
      expect(doc.cancellations[2].outcome, CancellationOutcome.unknown);
      expect(doc.cancellations[2].rawOutcome, 'from_the_future');
      expect(doc.openCancellation, isNull);
    });

    test(
      'a document with no stamp and no history maps to null and empty',
      () async {
        final repo = _repo((o) async => _json(_docJson()));
        final doc = await repo.getById(7);
        expect(doc.stamp, isNull);
        expect(doc.cancellations, isEmpty);
        expect(doc.stampingSince, isNull);
      },
    );

    test('an open cancellation is the one with no final answer', () async {
      final repo = _repo(
        (o) async => _json(
          _docJson(
            status: 'cancellation_pending',
            extra: {
              'cancellations': [
                {
                  'fiscal_document_cancellation_id': 4,
                  'reason': '02',
                  'status': 'pending',
                  'requested_by': 5,
                  'requested_at': '2026-11-17T12:30:00',
                },
              ],
            },
          ),
        ),
      );
      final doc = await repo.getById(7);
      expect(doc.openCancellation?.id, 4);
      expect(doc.canRefresh, isTrue);
      expect(doc.canCancel, isFalse);
      expect(doc.hasDocuments, isTrue);
    });
  });

  group('stamp, cancel and refresh', () {
    test('hit their endpoints', () async {
      final sent = <RequestOptions>[];
      final repo = _repo((o) async {
        sent.add(o);
        return _json(_docJson(status: 'issued'));
      });
      await repo.stamp(7);
      await repo.refresh(7);
      expect(
        [for (final o in sent) '${o.method} ${o.path}'],
        [
          'POST /api/v1/fiscal-documents/7/stamp',
          'POST /api/v1/fiscal-documents/7/refresh',
        ],
      );
    });

    test('cancel with 01 sends the substitute and with 02 does not', () async {
      final sent = <RequestOptions>[];
      final repo = _repo((o) async {
        sent.add(o);
        return _json(_docJson(status: 'cancelled'));
      });
      await repo.cancel(
        7,
        SatCancellationReason.withRelation,
        substitution: 'U-2',
      );
      await repo.cancel(
        7,
        SatCancellationReason.withoutRelation,
        substitution: 'U-2',
      );
      expect(sent[0].path, '/api/v1/fiscal-documents/7/cancel');
      expect(sent[0].data, {'reason': '01', 'substitution': 'U-2'});
      expect(sent[1].data, {'reason': '02'});
    });

    test('a refusal keeps its code', () async {
      final repo = _repo(
        (o) async => _json({
          'detail': 'busy',
          'code': 'fiscal_document.has_live_documents',
          'params': {
            'documents': ['P12', 'NC3'],
          },
        }, 409),
      );
      await expectLater(
        repo.cancel(7, SatCancellationReason.withoutRelation),
        throwsA(
          isA<Object>().having((e) => '$e', 'text', contains('has_live')),
        ),
      );
    });
  });

  group('downloadXml', () {
    test('returns the bytes and the server filename when present', () async {
      final repo = _repo(
        (o) async => ResponseBody.fromBytes(
          utf8.encode('<xml/>'),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/xml'],
            'content-disposition': ['attachment; filename="../A-000012.xml"'],
          },
        ),
      );
      final xml = await repo.downloadXml(7);
      expect(utf8.decode(xml.bytes), '<xml/>');
      expect(xml.filename, 'A-000012.xml');
    });

    test('has no filename without the header', () async {
      final repo = _repo(
        (o) async => ResponseBody.fromBytes(
          utf8.encode('<xml/>'),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/xml'],
          },
        ),
      );
      expect((await repo.downloadXml(7)).filename, isNull);
    });
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);

  @override
  void close({bool force = false}) {}
}
