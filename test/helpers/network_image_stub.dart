import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// A 1×1 transparent PNG.
final Uint8List _onePixelPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _MockHttpClient extends Mock implements HttpClient {}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {}

class _MockHttpHeaders extends Mock implements HttpHeaders {}

class _NetworkImageOverrides extends HttpOverrides {
  _NetworkImageOverrides(this.isBroken);

  final bool Function(Uri url) isBroken;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    registerFallbackValue(Uri());
    final client = _MockHttpClient();
    when(() => client.getUrl(any())).thenAnswer((invocation) async {
      final url = invocation.positionalArguments.single as Uri;
      final request = _MockHttpClientRequest();
      final response = _MockHttpClientResponse();
      when(() => request.headers).thenReturn(_MockHttpHeaders());
      when(request.close).thenAnswer((_) async => response);
      final bytes = isBroken(url) ? Uint8List(0) : _onePixelPng;
      when(
        () => response.statusCode,
      ).thenReturn(isBroken(url) ? HttpStatus.notFound : HttpStatus.ok);
      when(() => response.contentLength).thenReturn(bytes.length);
      when(
        () => response.compressionState,
      ).thenReturn(HttpClientResponseCompressionState.notCompressed);
      when(
        () => response.listen(
          any(),
          onError: any(named: 'onError'),
          onDone: any(named: 'onDone'),
          cancelOnError: any(named: 'cancelOnError'),
        ),
      ).thenAnswer((invocation) {
        final onData =
            invocation.positionalArguments.single as void Function(List<int>);
        return Stream<List<int>>.value(bytes).listen(
          onData,
          onError: invocation.namedArguments[#onError] as Function?,
          onDone: invocation.namedArguments[#onDone] as void Function()?,
          cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
        );
      });
      return request;
    });
    return client;
  }
}

/// Serves every `Image.network` request in this test file a real 1×1 PNG —
/// except URLs for which [isBroken] is true, which answer 404 — so a test
/// can reach the *loaded* state of a network image. flutter_test's own
/// client answers every request with an error, which only ever exercises an
/// image's error fallback.
///
/// Call from `setUpAll`; the override is process-wide for the file.
void stubNetworkImages({bool Function(Uri url)? isBroken}) {
  HttpOverrides.global = _NetworkImageOverrides(isBroken ?? (_) => false);
}

/// Pumps [tester] until network images have had a real chance to decode —
/// decoding runs outside the test's fake clock.
Future<void> pumpUntilImagesLoad(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pump();
}
