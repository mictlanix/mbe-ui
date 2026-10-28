import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/auth_interceptor.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/repositories/credit_note_repository.dart';

final creditNoteRepositoryProvider = Provider<CreditNoteRepository>((ref) {
  return CreditNoteRepositoryImpl(ref.watch(dioProvider));
});

/// The widest page `GET /credit-notes` allows.
const _maxPage = 100;

/// `CreditNoteRepository` backed by the generated `CreditNotesApi`.
class CreditNoteRepositoryImpl implements CreditNoteRepository {
  CreditNoteRepositoryImpl(Dio dio)
    : _api = api.CreditNotesApi(dio, appSerializers);

  final api.CreditNotesApi _api;

  @override
  Future<CreditNoteListResult> list({
    int? customerId,
    bool openOnly = false,
    int skip = 0,
    int limit = 20,
  }) => _page(
    customerId: customerId,
    openOnly: openOnly,
    skip: skip,
    limit: limit,
  );

  @override
  Future<List<CreditNote>> listSpendable(int customerId) async {
    final notes = <CreditNote>[];
    var skip = 0;
    while (true) {
      final page = await _page(
        customerId: customerId,
        openOnly: true,
        skip: skip,
        limit: _maxPage,
      );
      notes.addAll(page.items);
      skip += page.items.length;
      // Stop on a short page as well as on the count, so a server that
      // reports `total` differently cannot spin this loop forever.
      if (page.items.isEmpty || skip >= page.total) break;
    }
    // The server orders newest first; spending goes oldest first.
    notes.sort((a, b) {
      final byDate = _compareDates(a.date, b.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return notes;
  }

  @override
  Future<CreditNote?> findByPayment(int customerPaymentId) async {
    final page = await _page(customerPaymentId: customerPaymentId, limit: 1);
    return page.items.isEmpty ? null : page.items.first;
  }

  Future<CreditNoteListResult> _page({
    int? customerId,
    int? customerPaymentId,
    bool openOnly = false,
    int skip = 0,
    required int limit,
  }) async {
    try {
      final response = await _api.listCreditNotesApiV1CreditNotesGet(
        customer: customerId,
        customerPayment: customerPaymentId,
        openOnly: openOnly,
        skip: skip,
        limit: limit,
      );
      final result = response.data;
      if (result == null) throw const AppError.server();
      return CreditNoteListResult(
        items: result.items.map(CreditNote.fromResponse).toList(),
        total: result.total,
      );
    } on DioException catch (e) {
      throw _toAppError(e);
    }
  }
}

int _compareDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;
  return a.compareTo(b);
}

AppError _toAppError(DioException error) {
  final mapped = error.error;
  return mapped is AppError ? mapped : mapDioException(error);
}
