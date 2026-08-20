# US2 Spacing Conversion Inventory

Per FR-028 (data-model.md §4): every `Row`/`Column` carrying spacer widgets
that was examined during this feature, marked converted or skipped with a
reason. Compiled from the mechanical scan (research.md R7) plus the hand
sweep for collection-`if` cases it cannot see (T052).

## Converted

| File | Site | Kind | Gap |
|---|---|---|---|
| `sale_line_card.dart` | outer Column (worked example) | Column | 8 |
| `sale_line_card.dart` | discount/tax Row | Row | 8 |
| `sale_line_card.dart` | warning icon/text Row | Row | 4 |
| `core/widgets/brand_nav_header.dart` | logo/name Row | Row | 12 |
| `core/widgets/catalog_action_icons.dart` | overflow-menu item Row | Row | 12 |
| `auth/.../forgot_password_screen.dart` | success-view Column | Column | 16 |
| `auth/.../user_profiles_list_screen.dart` | status-filter Column | Column | 8 |
| `catalog/.../address_inline_create.dart` | header Column | Column | 16 |
| `catalog/.../address_inline_create.dart` | actions Row | Row | 8 |
| `catalog/.../contact_inline_create.dart` | actions Row | Row | 8 |
| `catalog/.../facilities_list_screen.dart` | status-filter Column | Column | 8 |
| `catalog/.../facility_detail_screen.dart` | picker + add-address Row | Row | 8 |
| `catalog/.../merge_products_screen.dart` | merge-confirm dialog Column (collection-if) | Column | 12 |
| `catalog/.../product_detail_screen.dart` | switches/labels compact Column | Column | 24 |
| `catalog/.../product_detail_screen.dart` | switches/labels wide Row | Row | 32 |
| `catalog/.../product_detail_screen.dart` | labels header Column | Column | 8 |
| `catalog/.../product_detail_screen.dart` | thumbnail+actions Column | Column | 8 |
| `catalog/.../product_detail_screen.dart` | thumbnail+actions Row | Row | 16 |
| `catalog/.../product_detail_screen.dart` | photo + error Column (collection-if) | Column | 4 |
| `catalog/.../taxpayer_certificate_upload_dialog.dart` | header Column | Column | 16 |
| `catalog/.../taxpayer_certificate_upload_dialog.dart` | actions Row | Row | 8 |
| `catalog/.../taxpayer_certificate_upload_dialog.dart` | file-picker Row | Row | 8 |
| `catalog/.../taxpayer_certificates_section.dart` | title Row + table Column | Column | 8 |
| `catalog/.../vehicles_list_screen.dart` | status-filter Column | Column | 8 |
| `catalog/widgets/facility_card.dart` | nameRow | Row | 10 |
| `catalog/widgets/facility_card.dart` | typeRow | Row | 6 |
| `catalog/widgets/facility_card.dart` | nested name/type Column | Column | 3 |
| `catalog/widgets/facility_card.dart` | error-retry Column | Column | 8 |
| `catalog/widgets/facility_card.dart` | `_CountsRow` (collection-if spread) | Row | 14 |
| `catalog/widgets/facility_card.dart` | `_CountBadge` icon/value Row | Row | 6 |
| `catalog/widgets/facility_card.dart` | production-site note Row | Row | 10 |
| `catalog/widgets/facility_child_row.dart` | warehouse-tooltip Row | Row | 4 |
| `catalog/widgets/facility_child_row.dart` | cross-facility badge Row | Row | 4 |
| `catalog/widgets/facility_child_section.dart` | header + body Column | Column | 8 |
| `catalog/widgets/merge_comparison_table.dart` | label Row (collection-if) | Row | 6 |
| `catalog/widgets/merge_comparison_table.dart` | compact label/values Column | Column | 4 |
| `catalog/widgets/merge_review_panel.dart` | photo + details Row | Row | 12 |
| `home/.../home_welcome.dart` | greeting/tiles/feed Column | Column | 24 |
| `sales/.../cash_session_detail_screen.dart` | form + close-section Column (collection-if) | Column | 24 |
| `sales/.../cash_sessions_screen.dart` | shift-button Row | Row | 8 |
| `sales/.../cash_sessions_screen.dart` | drawer-blocked Column | Column | 8 |
| `sales/.../cash_sessions_screen.dart` | shift-card name/status Row | Row | 8 |
| `sales/.../cash_sessions_screen.dart` | filter-bar + list Column | Column | 16 |
| `sales/.../customer_inline_create.dart` | actions Row | Row | 8 |
| `sales/.../open_sales_selector.dart` | identity + total Row | Row | 12 |
| `sales/.../pos_workspace_screen.dart` | step-indicator icon/label Row (collection-if) | Row | `theme.spacing.xxs` |

**~45 conversions across 22 files.** All verified pixel-identical against the
re-recorded (post-ISO-default) golden and screenshot baselines — see T054.

## Skipped (deliberate, not exhaustive — every genuinely non-uniform site
found is one of these three reasons)

| Reason | Representative files |
|---|---|
| Non-uniform gap sizes | `core/widgets/list_state_views.dart`, `auth/.../change_password_screen.dart`, `auth/.../user_detail_screen.dart` (8 conditional sections, gaps 12/16/24 mixed), `auth/.../apply_profile_dialog.dart`, `auth/.../login_screen.dart`, `catalog/.../taxpayer_issuer_detail_screen.dart`, `catalog/.../products_list_screen.dart`, `catalog/widgets/facility_card.dart` (the two compact/wide header Rows — 10+12 and 12+16+16), `catalog/widgets/facility_child_row.dart` (`CashDrawerChildRow`'s two Rows), `catalog/widgets/facility_child_section.dart` (header Row), `catalog/widgets/merge_review_panel.dart` (badge Row), `merge_comparison_table.dart` (title Row), `sales/.../cash_sessions_screen.dart` (open-form Column, filters-panel Column) |
| Trailing gap from a `for`-loop spread (not an "edge pad" in the strict single-child sense, but `spacing` cannot express a gap after the *last* item without one after every item) | `catalog/widgets/facility_card.dart` (`sections` list), `catalog/widgets/facility_child_row.dart` (`extraMeta` list), `catalog/widgets/facility_child_section.dart` (children list) |
| Only one of two potential gaps is declared (partial) | `core/widgets/error_banner.dart`, `auth/.../forgot_password_screen.dart` (top Column), `auth/.../user_detail_screen.dart` (Row), `auth/.../users_list_screen.dart`, `catalog/widgets/merge_review_panel.dart` (header Row), `merge_comparison_table.dart` (header Row) |

Non-uniform and partial-gap sites are the large majority of what the scan
flagged (31 + 13 in the original count) — correctly left untouched, since
converting any of them would change rendered spacing. Nothing was found
that the scan miscategorized as a skip; the corrections this session made
all went the other direction — a "partial"-looking site that was actually
a uniform collection-`if` case (`sale_line_card.dart`'s worked example and
five further ones found by the T052 hand sweep).
