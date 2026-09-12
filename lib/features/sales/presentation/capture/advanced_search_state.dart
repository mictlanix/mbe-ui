import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';

/// The working selection made on the Advanced search screen
/// (`AdvancedSearchScreen`, spec 038), in tick order. Deliberately a plain,
/// non-autoDispose [StateProvider] rather than screen-local state: the
/// screen navigates within itself via `GoRouter.replace` (research.md R1),
/// which can remount the screen's own `State`, so the selection must live
/// above that. `ProductSearchField` resets it to `const []` immediately
/// before pushing the screen, and the screen is the only thing that mutates
/// it afterwards.
final advancedSearchSelectionProvider =
    StateProvider<List<ProductListItem>>((ref) => const []);

/// The confirmed selection, handed back to `ProductSearchField` once the
/// Advanced search screen pops (spec 038 data-model.md §4). `null` except in
/// the instant between confirm and the field consuming it — the field
/// resets this to `null` as the very first step of handling a non-null
/// value, so a rebuild mid-add can never re-enter (research.md R2, R3).
///
/// This is the only channel the result travels through: the screen is
/// pushed on the root navigator via `GoRouter.replace`-based navigation, so
/// an awaited `context.push` future never completes (research.md R1, R2),
/// and `OrderScreen` overrides `saleEditorProvider` inside its own nested
/// `ProviderScope` — a root-navigator screen cannot add lines to the right
/// sale itself. The host's own `ProductSearchField` does the adding.
final advancedSearchResultProvider =
    StateProvider<List<ProductListItem>?>((ref) => null);
