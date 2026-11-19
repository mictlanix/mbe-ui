import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The signature's output size, whatever the pad's on-screen size: a fixed
/// 1024 × 384 px (8:3), which keeps a PNG far under the server's 2 MB limit
/// and the server's 1024 px scaling a no-op (spec 075 research R9).
const signatureImageWidth = 1024;
const signatureImageHeight = 384;

/// What a [SignaturePad] has captured, and the PNG made of it.
///
/// Held by the dialog that owns the pad, so it can ask "is there a signature?"
/// to enable "Cerrar parada" and render it on confirm.
class SignatureController extends ChangeNotifier {
  final _strokes = <List<Offset>>[];

  /// The size the strokes were drawn at; the PNG scales from it.
  Size _canvas = Size.zero;

  /// Nothing has been drawn: an empty pad is not proof (FR-016).
  bool get isEmpty => _strokes.isEmpty;

  void _start(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void _extend(Offset point) {
    if (_strokes.isEmpty) return;
    _strokes.last.add(point);
    notifyListeners();
  }

  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    notifyListeners();
  }

  /// The signature as a PNG at [signatureImageWidth] × [signatureImageHeight]:
  /// black ink on white, since the proof is a document, not themed chrome.
  Future<Uint8List> toPng() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final target = Size(
      signatureImageWidth.toDouble(),
      signatureImageHeight.toDouble(),
    );
    canvas.drawRect(Offset.zero & target, Paint()..color = _paper);
    if (_canvas.width > 0) canvas.scale(target.width / _canvas.width);
    _SignaturePainter.paintStrokes(canvas, _strokes);
    final image = await recorder.endRecording().toImage(
      signatureImageWidth,
      signatureImageHeight,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }
}

// The signature is a document: black ink on white paper, in either theme.
const _ink = Color(0xFF000000);
const _paper = Color(0xFFFFFFFF);
const _strokeWidth = 3.0;

/// A box to sign in with a finger, a stylus or a mouse (spec 075 research R9).
///
/// Feature-local until a second caller needs it. It fills the width it is
/// given and keeps a fixed aspect ratio, and offers "Borrar" to start over.
class SignaturePad extends StatelessWidget {
  const SignaturePad({super.key, required this.controller});

  final SignatureController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: spacing.sm,
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: signatureImageWidth / signatureImageHeight,
            child: DecoratedBox(
              key: const Key('signature_pad'),
              decoration: BoxDecoration(
                color: _paper,
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(spacing.sm),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  controller._canvas = constraints.biggest;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (d) => controller._start(d.localPosition),
                    onPanUpdate: (d) => controller._extend(d.localPosition),
                    // A tap is a dot.
                    onTapDown: (d) => controller._start(d.localPosition),
                    child: ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) => Semantics(
                        label: l10n.itineraryCloseSignatureTooltip,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _SignaturePainter(controller._strokes),
                          child: controller.isEmpty
                              ? Center(
                                  child: Text(
                                    l10n.itineraryCloseSignatureHint,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => TextButton(
            key: const Key('signature_clear'),
            onPressed: controller.isEmpty ? null : controller.clear,
            child: Text(l10n.itineraryCloseClearSignature),
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes);

  final List<List<Offset>> strokes;

  static void paintStrokes(Canvas canvas, List<List<Offset>> strokes) {
    final line = Paint()
      ..color = _ink
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = _ink;
    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.single, _strokeWidth / 2, dot);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, line);
    }
  }

  @override
  void paint(Canvas canvas, Size size) => paintStrokes(canvas, strokes);

  // The stroke lists are mutated in place, so repaint on every notification.
  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
