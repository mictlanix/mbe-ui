import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

/// Zoom levels the preview steps through, as a multiple of fit-to-width
/// (spec 044 research R7, data-model.md "Zoom model").
const List<double> zoomSteps = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0];

const double minZoom = 0.5;
const double maxZoom = 4.0;

/// A value this close to a step counts as being on it, so a pinch that lands
/// at 1.0000001 does not need two presses to leave 100 %.
const double _epsilon = 0.001;

double clampZoom(double scale) => scale.clamp(minZoom, maxZoom);

/// The next level above [current] (the top level when there is none).
double zoomInStep(double current) {
  for (final step in zoomSteps) {
    if (step > current + _epsilon) return step;
  }
  return maxZoom;
}

/// The next level below [current] (the bottom level when there is none).
double zoomOutStep(double current) {
  for (final step in zoomSteps.reversed) {
    if (step < current - _epsilon) return step;
  }
  return minZoom;
}

/// The level readout, rounded to a whole percent.
String zoomLabel(double scale) => '${(scale * 100).round()} %';

/// Where the content sits in the viewport: its [scale], and its top-left
/// corner's offset ([tx], [ty]) in viewport pixels. Matches the translation
/// and scale of the `InteractiveViewer`'s transformation matrix.
class ZoomView {
  const ZoomView(this.scale, this.tx, this.ty);

  static const fit = ZoomView(1, 0, 0);

  final double scale;
  final double tx;
  final double ty;

  @override
  bool operator ==(Object other) =>
      other is ZoomView &&
      other.scale == scale &&
      other.tx == tx &&
      other.ty == ty;

  @override
  int get hashCode => Object.hash(scale, tx, ty);

  @override
  String toString() => 'ZoomView($scale, $tx, $ty)';
}

/// [view] moved back inside the content: the scale clamped to the zoom range,
/// and the offset so no edge of the content is dragged past the viewport's.
/// Content smaller than the viewport on an axis is pinned to that axis' start.
///
/// `InteractiveViewer` clamps its own gestures but not a transformation set
/// from outside (the zoom buttons, the mouse wheel), so this does it.
ZoomView clampView(
  ZoomView view, {
  required Size content,
  required Size viewport,
}) {
  final scale = clampZoom(view.scale);
  final minTx = math.min(0.0, viewport.width - content.width * scale);
  final minTy = math.min(0.0, viewport.height - content.height * scale);
  return ZoomView(scale, view.tx.clamp(minTx, 0.0), view.ty.clamp(minTy, 0.0));
}

/// [view] rescaled to [newScale], keeping the content point under [focal]
/// (in viewport pixels) where it was.
ZoomView zoomAbout(
  ZoomView view,
  double newScale,
  Offset focal, {
  required Size content,
  required Size viewport,
}) {
  final scale = clampZoom(newScale);
  final sceneX = (focal.dx - view.tx) / view.scale;
  final sceneY = (focal.dy - view.ty) / view.scale;
  return clampView(
    ZoomView(scale, focal.dx - sceneX * scale, focal.dy - sceneY * scale),
    content: content,
    viewport: viewport,
  );
}

/// [view] moved by [delta] viewport pixels, clamped into the content.
ZoomView panView(
  ZoomView view,
  Offset delta, {
  required Size content,
  required Size viewport,
}) {
  return clampView(
    ZoomView(view.scale, view.tx + delta.dx, view.ty + delta.dy),
    content: content,
    viewport: viewport,
  );
}

/// The page the viewport's vertical centre is on, given each page's laid-out
/// height and the [gap] below it (which belongs to the page above). Pages are
/// stacked from the top of the content. `0` for no pages, and the first or
/// last page for a centre above or below them all.
int pageInView({
  required List<double> pageHeights,
  required double gap,
  required double contentCenterY,
}) {
  if (pageHeights.isEmpty) return 0;
  var bottom = 0.0;
  for (var i = 0; i < pageHeights.length; i++) {
    bottom += pageHeights[i] + gap;
    if (contentCenterY < bottom) return i;
  }
  return pageHeights.length - 1;
}
