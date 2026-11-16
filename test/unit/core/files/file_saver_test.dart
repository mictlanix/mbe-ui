import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/files/file_saver_impl.dart';

void main() {
  final bytes = Uint8List.fromList([1, 2, 3, 250]);

  ({
    FileSaverImpl saver,
    List<({String name, Uint8List? bytes})> asked,
    List<(String, Uint8List)> written,
  })
  build({
    bool web = false,
    TargetPlatform platform = TargetPlatform.android,
    String? answer = '/saved/a.xml',
  }) {
    final asked = <({String name, Uint8List? bytes})>[];
    final written = <(String, Uint8List)>[];
    final saver = FileSaverImpl(
      isWeb: web,
      platform: platform,
      saveDialog: ({required fileName, bytes}) async {
        asked.add((name: fileName, bytes: bytes));
        return answer;
      },
      writeFile: (path, data) async => written.add((path, data)),
    );
    return (saver: saver, asked: asked, written: written);
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test(
      '$platform hands the bytes to the picker and writes nothing',
      () async {
        final t = build(platform: platform);

        final saved = await t.saver.save(bytes: bytes, filename: 'a.xml');

        expect(saved, isTrue);
        expect(t.asked.single.name, 'a.xml');
        expect(t.asked.single.bytes, bytes);
        expect(t.written, isEmpty);
      },
    );

    test('$platform cancelled is not saved', () async {
      final t = build(platform: platform, answer: null);
      expect(await t.saver.save(bytes: bytes, filename: 'a.xml'), isFalse);
    });
  }

  test('web hands the bytes to the picker and counts as saved even without '
      'a path', () async {
    final t = build(web: true, answer: null);

    expect(await t.saver.save(bytes: bytes, filename: 'a.xml'), isTrue);
    expect(t.asked.single.bytes, bytes);
    expect(t.written, isEmpty);
  });

  for (final platform in [
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ]) {
    test(
      '$platform asks for a path only and writes the bytes itself',
      () async {
        final t = build(platform: platform, answer: '/home/u/a.xml');

        final saved = await t.saver.save(bytes: bytes, filename: 'a.xml');

        expect(saved, isTrue);
        expect(t.asked.single.bytes, isNull);
        expect(t.written.single.$1, '/home/u/a.xml');
        expect(t.written.single.$2, bytes);
      },
    );

    test('$platform cancelled writes nothing', () async {
      final t = build(platform: platform, answer: null);

      expect(await t.saver.save(bytes: bytes, filename: 'a.xml'), isFalse);
      expect(t.written, isEmpty);
    });
  }

  test('the default writer puts the bytes in the file', () async {
    final dir = await Directory.systemTemp.createTemp('file_saver_test');
    addTearDown(() => dir.delete(recursive: true));
    final path = '${dir.path}/out.xml';
    final saver = FileSaverImpl(
      platform: TargetPlatform.macOS,
      isWeb: false,
      saveDialog: ({required fileName, bytes}) async => path,
    );

    expect(await saver.save(bytes: bytes, filename: 'out.xml'), isTrue);
    expect(File(path).readAsBytesSync(), bytes);
  });
}
