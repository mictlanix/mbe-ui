repo: mictlanix/mbe-ui
branch: main
path: lib/

## Last sync
date: 2026-08-29T19:49:08Z

### Updated in this project
- Recreated the app shell (nav rail, app bar, brand header) from `app_shell.dart` / `app_navigation.dart` / `nav_destinations.dart`.
- Recreated the catalog table chrome (filter bar, search, filter side sheet, pagination) from the `core/widgets/` shared components.
- Copied the real brand mark `assets/brand/nav_lockup.png` (the default `BrandConfig.markAsset`) into the project.
- New bulk Pricing grid replacing the one-product-at-a-time pricing screen: one row per product, one column per price list, row-level inline editing.

## Screen map
| Screen | Built from |
| --- | --- |
| Pricing Grid.dc.html — shell + rail | lib/core/widgets/app_shell.dart, app_navigation.dart, brand_nav_header.dart, brand_logo.dart, lib/core/branding/brand_config.dart, assets/brand/nav_lockup.png, lib/core/navigation/nav_destinations.dart |
| Pricing Grid.dc.html — filter bar + drawer | lib/core/widgets/catalog_filter_bar.dart, catalog_search_bar.dart, catalog_filter_sheet.dart, app_side_sheet.dart, label_multi_picker.dart, entity_status_controls.dart |
| Pricing Grid.dc.html — table | lib/core/widgets/data_table_view.dart, catalog_pagination.dart, product_photo.dart, catalog_action_icons.dart, lib/features/catalog/presentation/products_list_screen.dart |
| Pricing Grid.dc.html — price cells | lib/features/pricing/presentation/pricing_screen.dart, product_price_row.dart, lib/features/pricing/domain/entities/product_price.dart, lib/core/formatting/app_formatters.dart |
| Tokens (colors, type, spacing, density, shapes) | lib/app/theme/app_theme.dart, lib/core/branding/xbe_palette.dart, lib/core/design/{type_roles,spacing,density,elevations,shapes,component_themes}.dart |
