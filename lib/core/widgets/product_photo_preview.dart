import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens a dialog showing [photoUrl] enlarged, with [title] (the product's
/// name) above it (046-catalog-improvements FR-014).
///
/// The photo is fitted to the available space with its aspect ratio kept.
/// Escape, a click outside the dialog and the close button all dismiss it
/// (FR-015). If the image fails to load, the shared [ProductPhoto]
/// placeholder is shown instead of a broken image.
Future<void> showProductPhotoPreview(
  BuildContext context, {
  required String photoUrl,
  required String title,
}) {
  return showPhotoPreview(
    context,
    image: NetworkImage(photoUrl),
    title: title,
    placeholder: (side) => Center(
      child: ProductPhoto(
        photoUrl: null,
        size: side.isFinite ? side.clamp(0, 240) : 240,
      ),
    ),
  );
}

/// The same enlarged-photo dialog for any [image] — the vehicle operator's
/// license photo is held as bytes behind authentication, so it has no URL to
/// hand to [showProductPhotoPreview] (051 R7). [placeholder] receives the
/// shortest side available and is shown if the image fails to decode.
Future<void> showPhotoPreview(
  BuildContext context, {
  required ImageProvider image,
  required String title,
  required Widget Function(double side) placeholder,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PhotoPreviewDialog(
      image: image,
      title: title,
      placeholder: placeholder,
    ),
  );
}

class _PhotoPreviewDialog extends StatelessWidget {
  const _PhotoPreviewDialog({
    required this.image,
    required this.title,
    required this.placeholder,
  });

  final ImageProvider image;
  final String title;
  final Widget Function(double side) placeholder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screen = MediaQuery.sizeOf(context);

    return Dialog(
      key: const Key('photo_preview_dialog'),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screen.width * 0.9,
          maxHeight: screen.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: title,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('photo_preview_close'),
                    tooltip: l10n.documentCloseTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.biggest.shortestSide;
                    return Image(
                      image: image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          placeholder(side),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
