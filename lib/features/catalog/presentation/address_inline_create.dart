import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/core/widgets/responsive_form_grid.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/presentation/address_inline_create_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Opens the "new address" dialog (FR-031, FR-032) and returns the created
/// [AddressListItem], or `null` if the user cancelled. Callers (the
/// facility form) select the returned item on success; a facility-save
/// failure afterward does NOT roll this address back (spec Edge Cases).
Future<AddressListItem?> showAddressInlineCreateDialog(BuildContext context) {
  return showDialog<AddressListItem>(
    context: context,
    builder: (_) => const _AddressInlineCreateDialog(),
  );
}

class _AddressInlineCreateDialog extends ConsumerWidget {
  const _AddressInlineCreateDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressInlineCreateControllerProvider);
    final controller = ref.read(
      addressInlineCreateControllerProvider.notifier,
    );
    final l10n = AppLocalizations.of(context)!;

    if (state.created != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).pop(state.created);
      });
    }

    final fieldsEnabled = !state.submitting;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.newAddressDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ResponsiveFormGrid(
                maxColumns: 2,
                children: [
                  if (state.error != null)
                    FormGridChild(
                      span: FormGridSpan.full,
                      ErrorBanner(
                        error: AppError.validation([
                          FieldError(
                            loc: const [],
                            msg: _localizeFormError(l10n, state.error!),
                            type: 'error',
                          ),
                          if (state.errorDetail != null)
                            FieldError(
                              loc: const [],
                              msg: state.errorDetail!,
                              type: 'error',
                            ),
                        ]),
                      ),
                    ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_street_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressStreetLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['street'],
                        ),
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.streetChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_exterior_number_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressExteriorNumberLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['exteriorNumber'],
                        ),
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.exteriorNumberChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_interior_number_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressInteriorNumberLabel,
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.interiorNumberChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_postal_code_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressPostalCodeLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['postalCode'],
                        ),
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.postalCodeChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_neighborhood_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressNeighborhoodLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['neighborhood'],
                        ),
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.neighborhoodChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_locality_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressLocalityLabel,
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.localityChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_borough_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressBoroughLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['borough'],
                        ),
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.boroughChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_state_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressStateLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['state'],
                        ),
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.addressStateChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_city_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressCityLabel,
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.cityChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_country_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressCountryLabel,
                        errorText: _localizeFieldError(
                          l10n,
                          state.fieldErrors['country'],
                        ),
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.countryChanged,
                    ),
                  ),
                  FormGridChild(
                    TextFormField(
                      key: const Key('address_nickname_field'),
                      decoration: InputDecoration(
                        labelText: l10n.addressNicknameLabel,
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.nicknameChanged,
                    ),
                  ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    TextFormField(
                      key: const Key('address_comment_field'),
                      decoration: InputDecoration(
                        labelText: l10n.columnComment,
                      ),
                      enabled: fieldsEnabled,
                      onChanged: controller.commentChanged,
                      maxLines: 2,
                    ),
                  ),
                  FormGridChild(
                    span: FormGridSpan.full,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: state.submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(l10n.cancelButton),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          key: const Key('create_address_button'),
                          onPressed: state.submitting
                              ? null
                              : controller.submit,
                          child: state.submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.createAddressButton),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _localizeFormError(AppLocalizations l10n, String code) {
  switch (code) {
    case AddressInlineCreateErrorCode.createFailed:
      return l10n.addressCreateFailedError;
    default:
      return code;
  }
}

String? _localizeFieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;
  switch (code) {
    case AddressInlineCreateErrorCode.streetRequired:
      return l10n.addressStreetRequiredError;
    case AddressInlineCreateErrorCode.exteriorNumberRequired:
      return l10n.addressExteriorNumberRequiredError;
    case AddressInlineCreateErrorCode.postalCodeRequired:
      return l10n.addressPostalCodeRequiredError;
    case AddressInlineCreateErrorCode.neighborhoodRequired:
      return l10n.addressNeighborhoodRequiredError;
    case AddressInlineCreateErrorCode.boroughRequired:
      return l10n.addressBoroughRequiredError;
    case AddressInlineCreateErrorCode.stateRequired:
      return l10n.addressStateRequiredError;
    case AddressInlineCreateErrorCode.countryRequired:
      return l10n.addressCountryRequiredError;
    default:
      return code;
  }
}
