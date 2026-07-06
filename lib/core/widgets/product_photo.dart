import 'package:flutter/material.dart';

/// Renders a product's photo, falling back to a placeholder when [photoUrl]
/// is `null` or the network image fails to load (FR-002, research.md §5).
/// Shared by `ProductsListScreen`, `ProductDetailScreen`, and the
/// create/edit form's in-progress preview (data-model.md "Derived display
/// rule") — constitution §VI requires shared visual components to live once
/// in `core/widgets/`.
class ProductPhoto extends StatelessWidget {
  const ProductPhoto({super.key, this.photoUrl, this.size = 84});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url == null) return _placeholder(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: size * 0.6,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
