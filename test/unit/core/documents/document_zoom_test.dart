import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/core/documents/presentation/document_zoom.dart';

/// The preview's zoom and page arithmetic (spec 044 research R7, R8,
/// data-model.md "Zoom model"). Pure, so it is pinned without a widget tree.
void main() {
  group('zoom steps', () {
    test('are 50/75/100/125/150/200/300/400 % of fit-to-width', () {
      expect(zoomSteps, [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0]);
    });

    test('zooming in from a step goes to the next step', () {
      expect(zoomInStep(1.0), 1.25);
      expect(zoomInStep(0.5), 0.75);
      expect(zoomInStep(3.0), 4.0);
    });

    test('zooming out from a step goes to the previous step', () {
      expect(zoomOutStep(1.0), 0.75);
      expect(zoomOutStep(2.0), 1.5);
      expect(zoomOutStep(0.75), 0.5);
    });

    test('from a pinch value between steps, goes to the adjacent step', () {
      expect(zoomInStep(1.37), 1.5);
      expect(zoomOutStep(1.37), 1.25);
      expect(zoomInStep(0.6), 0.75);
      expect(zoomOutStep(0.6), 0.5);
    });

    test('is a no-op at the ends', () {
      expect(zoomInStep(4.0), 4.0);
      expect(zoomInStep(9.0), 4.0);
      expect(zoomOutStep(0.5), 0.5);
      expect(zoomOutStep(0.1), 0.5);
    });

    test('a value within rounding of a step counts as that step', () {
      expect(zoomInStep(1.0000001), 1.25);
      expect(zoomOutStep(0.9999999), 0.75);
    });

    test('pinch values clamp to 50 %–400 %', () {
      expect(clampZoom(10), 4.0);
      expect(clampZoom(0.1), 0.5);
      expect(clampZoom(1.7), 1.7);
    });

    test('the readout rounds to a whole percent', () {
      expect(zoomLabel(1.0), '100 %');
      expect(zoomLabel(0.75), '75 %');
      expect(zoomLabel(1.499), '150 %');
      expect(zoomLabel(4.0), '400 %');
    });
  });

  group('the view stays inside the content', () {
    const content = Size(800, 3000);
    const viewport = Size(800, 600);

    test('at fit, the view cannot move at all horizontally and only scrolls '
        'vertically', () {
      final view = clampView(
        const ZoomView(1, 50, -900),
        content: content,
        viewport: viewport,
      );

      expect(view.tx, 0);
      expect(view.ty, -900);
    });

    test('cannot scroll past the top or the bottom', () {
      final top = clampView(
        const ZoomView(1, 0, 400),
        content: content,
        viewport: viewport,
      );
      final bottom = clampView(
        const ZoomView(1, 0, -99999),
        content: content,
        viewport: viewport,
      );

      expect(top.ty, 0);
      expect(bottom.ty, -(3000 - 600));
    });

    test('zoomed in, it can pan sideways up to the content edge', () {
      final view = clampView(
        const ZoomView(2, -99999, 0),
        content: content,
        viewport: viewport,
      );

      expect(view.tx, -(800 * 2 - 800));
    });

    test('content shorter than the viewport is pinned to the top', () {
      final view = clampView(
        const ZoomView(1, 0, -200),
        content: const Size(800, 300),
        viewport: viewport,
      );

      expect(view.ty, 0);
    });

    test('an out-of-range scale is clamped first', () {
      final view = clampView(
        const ZoomView(10, 0, 0),
        content: content,
        viewport: viewport,
      );

      expect(view.scale, 4.0);
    });
  });

  group('zooming about a point', () {
    const content = Size(800, 3000);
    const viewport = Size(800, 600);

    test('keeps the point under the pointer fixed', () {
      const focal = Offset(400, 300);
      const start = ZoomView(1, 0, -1000);
      // Scene point under the focal before: (400, (300+1000)/1).
      final before = Offset(
        (focal.dx - start.tx) / start.scale,
        (focal.dy - start.ty) / start.scale,
      );

      final after = zoomAbout(
        start,
        2,
        focal,
        content: content,
        viewport: viewport,
      );
      final scenePointAfter = Offset(
        (focal.dx - after.tx) / after.scale,
        (focal.dy - after.ty) / after.scale,
      );

      expect(after.scale, 2);
      expect(scenePointAfter.dx, closeTo(before.dx, 1e-9));
      expect(scenePointAfter.dy, closeTo(before.dy, 1e-9));
    });

    test('clamps the result into the content', () {
      final view = zoomAbout(
        const ZoomView(1, 0, 0),
        4,
        const Offset(0, 0),
        content: content,
        viewport: viewport,
      );

      expect(view.tx, 0);
      expect(view.ty, 0);
      expect(view.scale, 4);
    });

    test('zooming back out to fit leaves nothing scrolled sideways', () {
      final zoomed = zoomAbout(
        const ZoomView(1, 0, 0),
        3,
        const Offset(700, 100),
        content: content,
        viewport: viewport,
      );
      final back = zoomAbout(
        zoomed,
        1,
        const Offset(700, 100),
        content: content,
        viewport: viewport,
      );

      expect(back.tx, 0);
    });
  });

  group('pageInView', () {
    // Pages 100, 200 and 100 tall with a 10 gap: tops at 0, 110 and 320.
    const heights = [100.0, 200.0, 100.0];
    const gap = 10.0;

    int at(double y) =>
        pageInView(pageHeights: heights, gap: gap, contentCenterY: y);

    test('picks the page the viewport centre is on', () {
      expect(at(50), 0);
      expect(at(110), 1);
      expect(at(250), 1);
      expect(at(320), 2);
      expect(at(400), 2);
    });

    test('the gap below a page belongs to that page', () {
      expect(at(105), 0);
      expect(at(109.9), 0);
    });

    test('above the first page is the first; past the last is the last', () {
      expect(at(-5), 0);
      expect(at(1000), 2);
    });

    test('a single page, or none, is always page 0', () {
      expect(
        pageInView(pageHeights: const [500], gap: gap, contentCenterY: 300),
        0,
      );
      expect(
        pageInView(pageHeights: const [], gap: gap, contentCenterY: 300),
        0,
      );
    });

    test('unequal page heights are respected', () {
      const tall = [1000.0, 100.0];
      expect(pageInView(pageHeights: tall, gap: gap, contentCenterY: 900), 0);
      expect(pageInView(pageHeights: tall, gap: gap, contentCenterY: 1015), 1);
    });
  });
}
