import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:mbe_ui/core/files/file_saver.dart';

/// Asks the picker where to save: on web, Android and iOS it is given the
/// bytes, on desktop only the name, and answers the chosen path.
typedef SaveDialog =
    Future<String?> Function({required String fileName, Uint8List? bytes});

typedef WriteFile = Future<void> Function(String path, Uint8List bytes);

/// `FileSaver` over `file_picker`'s `saveFile`.
///
/// file_picker 8.3.7 saves the bytes itself on web, Android and iOS, but on
/// macOS it throws `UnsupportedError` when given bytes, and on Windows and
/// Linux it only returns a path. So desktop asks for a path and writes the
/// bytes with `dart:io` (the macOS app isn't sandboxed). The platform and the
/// two I/O calls are constructor seams, so each branch is testable.
class FileSaverImpl implements FileSaver {
  FileSaverImpl({
    bool? isWeb,
    TargetPlatform? platform,
    SaveDialog? saveDialog,
    WriteFile? writeFile,
  }) : _isWeb = isWeb ?? kIsWeb,
       _platform = platform ?? defaultTargetPlatform,
       _saveDialog = saveDialog ?? _pickerSaveDialog,
       _writeFile = writeFile ?? _ioWriteFile;

  final bool _isWeb;
  final TargetPlatform _platform;
  final SaveDialog _saveDialog;
  final WriteFile _writeFile;

  bool get _desktop =>
      !_isWeb &&
      (_platform == TargetPlatform.macOS ||
          _platform == TargetPlatform.windows ||
          _platform == TargetPlatform.linux);

  @override
  Future<bool> save({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (_desktop) {
      final path = await _saveDialog(fileName: filename);
      if (path == null) return false;
      await _writeFile(path, bytes);
      return true;
    }
    final path = await _saveDialog(fileName: filename, bytes: bytes);
    // On web the browser downloads the file and the picker has no way to say
    // whether the user cancelled, so a download counts as saved.
    return _isWeb || path != null;
  }
}

Future<String?> _pickerSaveDialog({
  required String fileName,
  Uint8List? bytes,
}) => FilePicker.platform.saveFile(fileName: fileName, bytes: bytes);

Future<void> _ioWriteFile(String path, Uint8List bytes) =>
    File(path).writeAsBytes(bytes, flush: true);
