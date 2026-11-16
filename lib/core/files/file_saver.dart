import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/files/file_saver_impl.dart';

/// Saves bytes as a file the user picks a place for (spec 066 research R10).
abstract interface class FileSaver {
  /// Asks where to save [bytes] as [filename] and writes them. Answers
  /// whether a file was saved: `false` means the user cancelled the dialog.
  Future<bool> save({required Uint8List bytes, required String filename});
}

final fileSaverProvider = Provider<FileSaver>((ref) => FileSaverImpl());
