// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fieldRequired => 'Required';

  @override
  String get fieldMinLength6 => 'Must be at least 6 characters';

  @override
  String get viewActionTooltip => 'View';

  @override
  String get editActionTooltip => 'Edit';

  @override
  String get deleteActionTooltip => 'Delete';

  @override
  String get moreActionsTooltip => 'More actions';

  @override
  String get searchButtonTooltip => 'Search';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get forgotPasswordLink => 'Forgot your password?';

  @override
  String get changePasswordMenuTitle => 'Change password';

  @override
  String get appTitle => 'Mictlanix Business Essentials';

  @override
  String get homeMenuTitle => 'Home';

  @override
  String get homeWelcomeMessage => 'Welcome';

  @override
  String get catalogsGroupTitle => 'Catalogs';

  @override
  String get salesGroupTitle => 'Sales';

  @override
  String get usersMenuTitle => 'Users';

  @override
  String get userMenuLogout => 'Logout';

  @override
  String userMenuStoreFallback(int id) {
    return 'Store $id';
  }

  @override
  String userMenuPosFallback(int id) {
    return 'POS $id';
  }

  @override
  String userMenuDrawerFallback(int id) {
    return 'Drawer $id';
  }

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get changePasswordButton => 'Change password';

  @override
  String get passwordChangedSuccess => 'Password changed successfully.';

  @override
  String get backButton => 'Back';

  @override
  String get recoverPasswordTitle => 'Recover Password';

  @override
  String get recoveryHelpText =>
      'Ask your administrator to generate a recovery token for your account, then enter it below along with your new password.';

  @override
  String get recoveryTokenLabel => 'Recovery token';

  @override
  String get setNewPasswordButton => 'Set new password';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully. You can now sign in.';

  @override
  String get usersTitle => 'Users';

  @override
  String get newUserTooltip => 'New user';

  @override
  String get usersSearchLabel => 'Search by username or email';

  @override
  String usersLoadError(Object error) {
    return 'Failed to load users: $error';
  }

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get columnUsername => 'Username';

  @override
  String get columnEmail => 'Email';

  @override
  String get columnAdmin => 'Admin';

  @override
  String get columnStatus => 'Status';

  @override
  String get statusDisabled => 'Disabled';

  @override
  String get statusActive => 'Active';

  @override
  String get productsTitle => 'Products';

  @override
  String get newProductTooltip => 'New product';

  @override
  String get uploadPhotoButton => 'Upload photo';

  @override
  String get replacePhotoButton => 'Replace photo';

  @override
  String get removePhotoButton => 'Remove photo';

  @override
  String get productsSearchLabel => 'Search by code, name, brand, or model';

  @override
  String get productsShowInactiveFilter => 'Show inactive';

  @override
  String get productsStockableFilter => 'Stockable';

  @override
  String get productsSalableFilter => 'Salable';

  @override
  String get productsPurchasableFilter => 'Purchasable';

  @override
  String get productsLabelFilter => 'Labels';

  @override
  String get labelUnavailableTooltip => 'No matching products';

  @override
  String labelWithCount(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filtersButton => 'Filters';

  @override
  String get filtersTooltip => 'Filters';

  @override
  String get clearAllFilters => 'Clear all';

  @override
  String get applyFilters => 'Apply';

  @override
  String productsLoadError(Object error) {
    return 'Failed to load products: $error';
  }

  @override
  String get noProductsFound => 'No products found.';

  @override
  String get columnPhoto => 'Photo';

  @override
  String get columnCode => 'Code';

  @override
  String get copyCodeTooltip => 'Copy code';

  @override
  String get codeCopiedMessage => 'Code copied to clipboard';

  @override
  String get columnName => 'Name';

  @override
  String get columnBrand => 'Brand';

  @override
  String get columnUnit => 'Unit';

  @override
  String get newProductTitle => 'New Product';

  @override
  String get editProductTitle => 'Edit Product';

  @override
  String get viewProductTitle => 'View Product';

  @override
  String get codeLabel => 'Code';

  @override
  String get nameLabel => 'Name';

  @override
  String get skuLabel => 'SKU';

  @override
  String get unitOfMeasurementLabel => 'Unit of Measurement';

  @override
  String get supplierLabel => 'Supplier';

  @override
  String get satKeyLabel => 'SAT Product/Service Key';

  @override
  String get brandLabel => 'Brand';

  @override
  String get modelLabel => 'Model';

  @override
  String get barCodeLabel => 'Barcode';

  @override
  String get locationLabel => 'Bin Location';

  @override
  String get taxRateLabel => 'Tax Rate';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get commentLabel => 'Notes';

  @override
  String get stockableLabel => 'Stockable';

  @override
  String get perishableLabel => 'Perishable';

  @override
  String get seriableLabel => 'Seriable';

  @override
  String get purchasableLabel => 'Purchasable';

  @override
  String get salableLabel => 'Salable';

  @override
  String get invoiceableLabel => 'Invoiceable';

  @override
  String get labelsLabel => 'Labels';

  @override
  String get deleteProductButton => 'Delete product';

  @override
  String get deleteProductConfirmTitle => 'Delete product permanently?';

  @override
  String deleteProductConfirmMessage(String code) {
    return 'Are you sure you want to permanently delete \"$code\"? This cannot be undone — the product and its history will be removed entirely, not just hidden.';
  }

  @override
  String get statusInactiveBadge => 'Inactive';

  @override
  String get mergeProductsTitle => 'Merge Products';

  @override
  String get mergeProductsTooltip => 'Merge products';

  @override
  String get mergeProductLabel => 'Product';

  @override
  String get duplicatedLabel => 'Duplicate';

  @override
  String get mergeButton => 'Merge';

  @override
  String get mergeBackTooltip => 'Back';

  @override
  String get mergeBothRequiredMessage =>
      'Select a product and a duplicate to continue.';

  @override
  String get mergeSameProductMessage =>
      'You can\'t merge a product with itself.';

  @override
  String get mergeConfirmTitle => 'Merge products permanently?';

  @override
  String mergeConfirmMessage(String canonicalName, String duplicateName) {
    return 'Are you sure you want to merge \"$duplicateName\" into \"$canonicalName\"? This cannot be undone — \"$duplicateName\" will be permanently deleted and its history transferred to \"$canonicalName\".';
  }

  @override
  String get mergeSuccess => 'Products merged successfully.';

  @override
  String get editUserTitle => 'Edit User';

  @override
  String get viewUserTitle => 'View User';

  @override
  String get newUserTitle => 'New User';

  @override
  String get recoverPasswordTooltip => 'Recover password';

  @override
  String get deleteUserTooltip => 'Delete user';

  @override
  String get deleteUserConfirmTitle => 'Delete user?';

  @override
  String deleteUserConfirmMessage(String userId) {
    return 'Are you sure you want to delete \"$userId\"? This action cannot be undone.';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get editButton => 'Edit';

  @override
  String get editRecordTooltip => 'Switch to the editable form';

  @override
  String get viewPricingButton => 'View pricing';

  @override
  String get emailLabel => 'Email';

  @override
  String get employeeIdLabel => 'Employee ID (optional)';

  @override
  String get administratorLabel => 'Administrator';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get permissionsLabel => 'Permissions';

  @override
  String get saveButton => 'Save';

  @override
  String get recoveryTokenTitle => 'Recovery Token';

  @override
  String recoveryExpiresAt(String expiresAt) {
    return 'Expires: $expiresAt';
  }

  @override
  String get userIdLengthError => '4–20 characters';

  @override
  String get passwordLengthError => 'At least 6 characters';

  @override
  String get privilegesModuleColumn => 'Module';

  @override
  String get privilegesCreateColumn => 'C';

  @override
  String get privilegesReadColumn => 'R';

  @override
  String get privilegesUpdateColumn => 'U';

  @override
  String get privilegesDeleteColumn => 'D';

  @override
  String get privilegesCreateTooltip => 'Create';

  @override
  String get privilegesReadTooltip => 'Read';

  @override
  String get privilegesUpdateTooltip => 'Update';

  @override
  String get privilegesDeleteTooltip => 'Delete';

  @override
  String get productCodeRequiredError => 'Code is required.';

  @override
  String get productCodeWhitespaceError => 'Code must not contain whitespace.';

  @override
  String get productCodeTooLongError => 'Code must be at most 25 characters.';

  @override
  String get productNameLengthError =>
      'Name must be between 4 and 250 characters.';

  @override
  String get productUnitRequiredError => 'Unit of measurement is required.';

  @override
  String get productBarCodeInvalidError =>
      'Barcode must be empty or exactly 13 digits.';

  @override
  String get productPhotoInvalidTypeError =>
      'Photo must be a JPEG or PNG file.';

  @override
  String get productPhotoTooLargeError => 'Photo must be 2 MB or smaller.';

  @override
  String get productPhotoUploadFailedError =>
      'The product was saved, but the photo failed to upload. Try again.';

  @override
  String get productLoadFailedError => 'Failed to load product.';

  @override
  String get productCreateFailedError => 'Failed to create product.';

  @override
  String get productUpdateFailedError => 'Failed to update product.';

  @override
  String get productDeleteFailedError => 'Failed to delete product.';

  @override
  String get productCreatePermissionDeniedError =>
      'You no longer have permission to create products.';

  @override
  String get productUpdatePermissionDeniedError =>
      'You no longer have permission to edit products.';

  @override
  String get productDeletePermissionDeniedError =>
      'You no longer have permission to delete products.';

  @override
  String get userEmailRequiredError => 'Email is required.';

  @override
  String get userUsernameRequiredError => 'Username is required.';

  @override
  String get userPasswordLengthError =>
      'Password must be at least 6 characters.';

  @override
  String get userLoadFailedError => 'Failed to load user.';

  @override
  String get userSaveFailedError => 'Failed to save user.';

  @override
  String get userDeleteFailedError => 'Failed to delete user.';

  @override
  String get userRecoveryFailedError => 'Failed to generate recovery token.';

  @override
  String get priceListsMenuTitle => 'Price Lists';

  @override
  String get pricingMenuTitle => 'Pricing';

  @override
  String get exchangeRatesMenuTitle => 'Exchange Rates';

  @override
  String get priceListsSearchLabel => 'Search by name';

  @override
  String get newPriceListTooltip => 'New price list';

  @override
  String get noPriceListsFound => 'No price lists found.';

  @override
  String priceListsLoadError(Object error) {
    return 'Failed to load price lists: $error';
  }

  @override
  String get columnHighProfitMargin => 'High margin';

  @override
  String get columnLowProfitMargin => 'Low margin';

  @override
  String get priceListNameLabel => 'Name';

  @override
  String get priceListHighProfitMarginLabel => 'High profit margin';

  @override
  String get priceListLowProfitMarginLabel => 'Low profit margin';

  @override
  String get newPriceListTitle => 'New price list';

  @override
  String get editPriceListTitle => 'Edit price list';

  @override
  String get viewPriceListTitle => 'View price list';

  @override
  String get deletePriceListButton => 'Delete';

  @override
  String get deletePriceListConfirmTitle => 'Delete price list?';

  @override
  String deletePriceListConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get priceListNameRequiredError => 'Name is required.';

  @override
  String get priceListMarginInvalidError =>
      'Enter a valid non-negative percentage.';

  @override
  String get priceListLoadFailedError => 'Failed to load price list.';

  @override
  String get priceListCreateFailedError => 'Failed to create price list.';

  @override
  String get priceListUpdateFailedError => 'Failed to update price list.';

  @override
  String get priceListDeleteFailedError => 'Failed to delete price list.';

  @override
  String get priceListCreatePermissionDeniedError =>
      'You no longer have permission to create price lists.';

  @override
  String get priceListUpdatePermissionDeniedError =>
      'You no longer have permission to edit price lists.';

  @override
  String get priceListDeletePermissionDeniedError =>
      'You no longer have permission to delete price lists.';

  @override
  String get pricingProductPickerLabel => 'Product';

  @override
  String get pricingSelectProductPrompt =>
      'Select a product to see and edit its prices.';

  @override
  String get pricingNoPriceListsEmptyState =>
      'No price lists exist yet. Create one first.';

  @override
  String get pricingPriceNotSet => 'Not set';

  @override
  String pricingLoadError(Object error) {
    return 'Failed to load prices: $error';
  }

  @override
  String get pricingSaveFailedError => 'Failed to save price.';

  @override
  String get pricingUpdatePermissionDeniedError =>
      'You no longer have permission to edit prices.';

  @override
  String get pricingInvalidAmountError => 'Enter a valid non-negative amount.';

  @override
  String get columnPriceList => 'Price list';

  @override
  String get columnPrice => 'Price';

  @override
  String get columnLowProfit => 'Low profit';

  @override
  String get columnHighProfit => 'High profit';

  @override
  String get editPriceTooltip => 'Edit price';

  @override
  String get savePriceTooltip => 'Save';

  @override
  String get cancelPriceEditTooltip => 'Cancel';

  @override
  String get newExchangeRateTooltip => 'New exchange rate';

  @override
  String get noExchangeRatesFound => 'No exchange rates found.';

  @override
  String exchangeRatesLoadError(Object error) {
    return 'Failed to load exchange rates: $error';
  }

  @override
  String get columnDate => 'Date';

  @override
  String get columnBaseCurrency => 'Base';

  @override
  String get columnTargetCurrency => 'Target';

  @override
  String get columnRate => 'Rate';

  @override
  String get exchangeRateDateLabel => 'Date';

  @override
  String get exchangeRateBaseCurrencyLabel => 'Base currency';

  @override
  String get exchangeRateTargetCurrencyLabel => 'Target currency';

  @override
  String get exchangeRateRateLabel => 'Rate';

  @override
  String get newExchangeRateTitle => 'New exchange rate';

  @override
  String get editExchangeRateTitle => 'Edit exchange rate';

  @override
  String get viewExchangeRateTitle => 'View exchange rate';

  @override
  String get deleteExchangeRateButton => 'Delete';

  @override
  String get deleteExchangeRateConfirmTitle => 'Delete exchange rate?';

  @override
  String get deleteExchangeRateConfirmMessage =>
      'This will permanently delete this exchange rate. This cannot be undone.';

  @override
  String get exchangeRateDateRequiredError => 'Date is required.';

  @override
  String get exchangeRateRateInvalidError => 'Enter a valid positive rate.';

  @override
  String get exchangeRateCurrencyRequiredError => 'Select a currency.';

  @override
  String get exchangeRateLoadFailedError => 'Failed to load exchange rate.';

  @override
  String get exchangeRateCreateFailedError => 'Failed to create exchange rate.';

  @override
  String get exchangeRateUpdateFailedError => 'Failed to update exchange rate.';

  @override
  String get exchangeRateDeleteFailedError => 'Failed to delete exchange rate.';

  @override
  String get exchangeRateCreatePermissionDeniedError =>
      'You no longer have permission to create exchange rates.';

  @override
  String get exchangeRateUpdatePermissionDeniedError =>
      'You no longer have permission to edit exchange rates.';

  @override
  String get exchangeRateDeletePermissionDeniedError =>
      'You no longer have permission to delete exchange rates.';

  @override
  String get dateRangeFilterLabel => 'Date range';

  @override
  String get currencyFilterLabel => 'Currency pair';

  @override
  String get clearDateRangeTooltip => 'Clear date range';

  @override
  String get currencyMxnLabel => 'MXN — Mexican Peso';

  @override
  String get currencyUsdLabel => 'USD — US Dollar';

  @override
  String get currencyEurLabel => 'EUR — Euro';
}
