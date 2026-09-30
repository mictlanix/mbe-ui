import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_zoom.dart';

/// CSS pixels per PDF point: a page's natural on-screen size is its physical
/// size at 96 dpi, so a 72 mm ticket stays a narrow strip in a wide dialog
/// instead of being stretched to fill it.
const double _pxPerPoint = 96 / 72;

/// Where each page sits in the scrolled content (spec 044 FR-011): fitted to
/// the available width, never wider than its natural size, centred, with a
/// margin around the stack and a gap between pages.
class DocumentPageLayout {
  DocumentPageLayout({
    required List<DocumentPage> pages,
    required this.availableWidth,
    required this.margin,
    required this.gap,
  }) {
    final usable = math.max(1.0, availableWidth - 2 * margin);
    var top = margin;
    for (final page in pages) {
      final natural = page.size.width * _pxPerPoint;
      final width = math.max(1.0, math.min(natural, usable));
      final height = width * page.size.height / page.size.width;
      sizes.add(Size(width, height));
      tops.add(top);
      top += height + gap;
    }
    // The last page has a margin below it, not a gap.
    content = Size(availableWidth, pages.isEmpty ? 0 : top - gap + margin);
  }

  final double availableWidth;
  final double margin;
  final double gap;

  /// Each page's displayed size.
  final List<Size> sizes = [];

  /// Each page's top edge in content coordinates.
  final List<double> tops = [];

  /// The whole stack, as wide as the viewport at fit-to-width.
  late final Size content;

  List<double> get heights => [for (final size in sizes) size.height];
}

/// The preview's view state: zoom level, and the page in view. It owns the
/// transformation the page area shows, so the action bar's zoom buttons and
/// the mouse wheel change the same thing the pinch gesture does.
///
/// The viewer reports its geometry through [attach] on every layout; until
/// then there is nothing to zoom.
class DocumentViewController extends ChangeNotifier {
  DocumentViewController() {
    transformation.addListener(_onTransformation);
  }

  final TransformationController transformation = TransformationController();

  Size _content = Size.zero;
  Size _viewport = Size.zero;
  List<double> _pageHeights = const [];
  List<double> _pageTops = const [];
  double _gap = 0;

  double _scale = 1;
  int _pageIndex = 0;

  /// The current zoom, as a multiple of fit-to-width.
  double get scale => _scale;

  /// The zero-based page whose vertical centre is in the middle of the view.
  int get pageIndex => _pageIndex;

  bool get canZoomIn => _scale < maxZoom - 0.001;
  bool get canZoomOut => _scale > minZoom + 0.001;

  /// Called by the viewer on every layout with the geometry the zoom maths
  /// needs. Never notifies during the build that calls it.
  void attach({
    required Size content,
    required Size viewport,
    required DocumentPageLayout layout,
  }) {
    _content = content;
    _pageHeights = layout.heights;
    _pageTops = layout.tops;
    _gap = layout.gap;
    if (_viewport != viewport) {
      _viewport = viewport;
      // The viewport changed (window resized, keyboard shown): the view may
      // now hang outside the content.
      SchedulerBinding.instance.addPostFrameCallback((_) => _reclamp());
    }
  }

  ZoomView get _view {
    final m = transformation.value;
    return ZoomView(m.getMaxScaleOnAxis(), m.storage[12], m.storage[13]);
  }

  void _apply(ZoomView view) {
    transformation.value = Matrix4.identity()
      ..translateByDouble(view.tx, view.ty, 0, 1)
      ..scaleByDouble(view.scale, view.scale, view.scale, 1);
  }

  void _reclamp() {
    final view = _view;
    final clamped = clampView(view, content: _content, viewport: _viewport);
    if (clamped != view) _apply(clamped);
  }

  Offset get _center => Offset(_viewport.width / 2, _viewport.height / 2);

  void zoomIn() => _zoomTo(zoomInStep(_scale));

  void zoomOut() => _zoomTo(zoomOutStep(_scale));

  void _zoomTo(double scale) => zoomBy(scale / _scale, _center);

  /// Zooms by [factor] about [focal] (viewport pixels), keeping the content
  /// point under it where it was.
  void zoomBy(double factor, Offset focal) {
    _apply(
      zoomAbout(
        _view,
        _scale * factor,
        focal,
        content: _content,
        viewport: _viewport,
      ),
    );
  }

  /// Scrolls by [delta] viewport pixels.
  void panBy(Offset delta) {
    _apply(panView(_view, delta, content: _content, viewport: _viewport));
  }

  /// Back to fit-to-width, scrolled to the top of the page in view.
  void fit() {
    final top = _pageTops.isEmpty ? 0.0 : _pageTops[_pageIndex];
    _apply(
      clampView(ZoomView(1, 0, -top), content: _content, viewport: _viewport),
    );
  }

  void _onTransformation() {
    final view = _view;
    final index = pageInView(
      pageHeights: _pageHeights,
      gap: _gap,
      contentCenterY: (_viewport.height / 2 - view.ty) / view.scale,
    );
    if (view.scale != _scale || index != _pageIndex) {
      _scale = view.scale;
      _pageIndex = index;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    transformation
      ..removeListener(_onTransformation)
      ..dispose();
    super.dispose();
  }
}

/// The pages, stacked and zoomable (spec 044 FR-011, research R8).
///
/// Pinch and drag are `InteractiveViewer`'s own. A mouse wheel scrolls, and
/// zooms only with Ctrl or ⌘ held, because `InteractiveViewer` alone would
/// make a plain wheel zoom, which makes a long pedido impossible to scroll on
/// a desktop. A trackpad's two-finger scroll pans and its pinch zooms, both
/// by `InteractiveViewer` as usual.
class DocumentPageViewer extends StatelessWidget {
  const DocumentPageViewer({
    super.key,
    required this.pages,
    required this.controller,
  });

  final List<DocumentPage> pages;
  final DocumentViewController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = DocumentPageLayout(
          pages: pages,
          availableWidth: constraints.maxWidth,
          margin: spacing.md,
          gap: spacing.md,
        );
        controller.attach(
          content: layout.content,
          viewport: constraints.biggest,
          layout: layout,
        );

        return ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: InteractiveViewer(
            transformationController: controller.transformation,
            constrained: false,
            minScale: minZoom,
            maxScale: maxZoom,
            boundaryMargin: EdgeInsets.zero,
            // The wheel is handled below. Left at its default, this would
            // zoom on a wheel over any part the content does not cover.
            scaleFactor: double.infinity,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (event) => _onPointerSignal(context, event),
              child: SizedBox(
                width: layout.content.width,
                height: layout.content.height,
                child: Stack(
                  children: [
                    for (var i = 0; i < pages.length; i++)
                      Positioned(
                        left:
                            (layout.content.width - layout.sizes[i].width) / 2,
                        top: layout.tops[i],
                        width: layout.sizes[i].width,
                        height: layout.sizes[i].height,
                        child: _PageView(
                          key: Key('document_page_$i'),
                          page: pages[i],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPointerSignal(BuildContext context, PointerSignalEvent event) {
    // A trackpad is left to InteractiveViewer, which pans and pinch-zooms it.
    if (event is! PointerScrollEvent ||
        event.kind == PointerDeviceKind.trackpad) {
      return;
    }
    // Registered first (this Listener is inside the InteractiveViewer, so it
    // sees the event first), so InteractiveViewer's own wheel-zoom is ignored.
    GestureBinding.instance.pointerSignalResolver.register(event, (resolved) {
      final scroll = resolved as PointerScrollEvent;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final keyboard = HardwareKeyboard.instance;
      if (keyboard.isControlPressed || keyboard.isMetaPressed) {
        controller.zoomBy(
          math.exp(-scroll.scrollDelta.dy / 200),
          box.globalToLocal(scroll.position),
        );
      } else {
        controller.panBy(
          Offset(-scroll.scrollDelta.dx, -scroll.scrollDelta.dy),
        );
      }
    });
  }
}

/// One page: the server's pixels on white paper.
class _PageView extends StatelessWidget {
  const _PageView({super.key, required this.page});

  final DocumentPage page;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // Paper is white in every theme: the page's own pixels assume it, so
        // this is the one colour that does not come from the colour scheme.
        color: Colors.white,
        boxShadow: kElevationToShadow[2],
      ),
      child: Image(
        image: page.image,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      ),
    );
  }
}
