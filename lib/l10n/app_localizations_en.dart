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
  String get errorValidationGeneric => 'Please correct the highlighted fields.';

  @override
  String get errorAuthGeneric => 'Invalid username or password.';

  @override
  String get errorNotFoundGeneric => 'The requested item was not found.';

  @override
  String get errorServerGeneric =>
      'Something went wrong on the server. Please try again later.';

  @override
  String get errorNetworkGeneric =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get errorCreditHoldGeneric =>
      'This customer cannot be placed on credit right now.';

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
  String get loginTagline => 'All your operations, in one place.';

  @override
  String get loginSubhead =>
      'Catalogs, price lists, facilities, and sales for all your branches, synced in real time.';

  @override
  String get changePasswordMenuTitle => 'Change password';

  @override
  String get appTitle => 'Mictlanix Business Essentials';

  @override
  String get homeMenuTitle => 'Home';

  @override
  String get homeWelcomeMessage => 'Welcome';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeSummary =>
      'You have price lists pending approval and facilities with yesterday\'s cash cut still open.';

  @override
  String get homeReviewPendingButton => 'Review pending';

  @override
  String get homeNewSaleButton => 'New sale';

  @override
  String get catalogsGroupTitle => 'Catalogs';

  @override
  String get salesGroupTitle => 'Sales';

  @override
  String get logisticsGroupTitle => 'Logistics';

  @override
  String get usersMenuTitle => 'Users';

  @override
  String get userMenuLogout => 'Logout';

  @override
  String userMenuFacilityFallback(int id) {
    return 'Facility $id';
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
  String get settingsMenuTitle => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearanceLabel => 'Appearance';

  @override
  String get settingsAppearanceLight => 'Light';

  @override
  String get settingsAppearanceDark => 'Dark';

  @override
  String get settingsAppearanceSystem => 'System';

  @override
  String get settingsTextSizeLabel => 'Text size';

  @override
  String get settingsTextSizeSmall => 'Small';

  @override
  String get settingsTextSizeNormal => 'Normal';

  @override
  String get settingsTextSizeLarge => 'Large';

  @override
  String get settingsTextSizeExtraLarge => 'Extra large';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSystem => 'Follow system';

  @override
  String get usersTitle => 'Users';

  @override
  String get newUserTooltip => 'New user';

  @override
  String get usersSearchLabel => 'Search by username or email';

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
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusArchived => 'Archived';

  @override
  String get statusFilterLabel => 'Status';

  @override
  String get statusFilterAll => 'All';

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
  String get productsStockableFilter => 'Stockable';

  @override
  String get productsSalableFilter => 'Salable';

  @override
  String get productsPurchasableFilter => 'Purchasable';

  @override
  String get productsPerishableFilter => 'Perishable';

  @override
  String get productsSeriableFilter => 'Seriable';

  @override
  String get productsInvoiceableFilter => 'Invoiceable';

  @override
  String get productsAttributesFilterLabel => 'Product attributes';

  @override
  String get productsSupplierFilter => 'Supplier';

  @override
  String get productsSupplierSearchHint => 'Search suppliers…';

  @override
  String get productsLabelFilter => 'Labels';

  @override
  String get advancedSearchButton => 'Advanced search';

  @override
  String get advancedSearchTitle => 'Advanced search';

  @override
  String advancedSearchAddButton(int count) {
    return 'Add ($count)';
  }

  @override
  String advancedSearchSelectionCount(int count) {
    return '$count selected';
  }

  @override
  String get advancedSearchClearSelection => 'Clear selection';

  @override
  String get advancedSearchNoSaleHint =>
      'Open this from a sale to add products';

  @override
  String get advancedSearchSkipped => 'These products could not be added:';

  @override
  String advancedSearchAdding(int done, int total) {
    return 'Adding $done of $total…';
  }

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
  String get retryButton => 'Retry';

  @override
  String get clearFiltersButton => 'Clear filters';

  @override
  String get filteredEmptyTitle => 'No matches found';

  @override
  String get filteredEmptyMessage => 'Try adjusting or clearing your filters.';

  @override
  String get loadErrorTitle => 'Couldn\'t load this list';

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
  String mergeConfirmMessage(
    String canonicalName,
    String canonicalCode,
    String duplicateName,
    String duplicateCode,
  ) {
    return '\"$canonicalName\" ($canonicalCode) is kept.\n\"$duplicateName\" ($duplicateCode) is deleted and its history moves to the kept product. This cannot be undone.';
  }

  @override
  String mergeConfirmTotalLine(int total) {
    return 'Records that will move: $total.';
  }

  @override
  String get mergeSuccess => 'Products merged successfully.';

  @override
  String get mergeKeptLabel => 'Kept';

  @override
  String get mergeDeletedLabel => 'Deleted';

  @override
  String get mergeSwapTooltip =>
      'Swap which product is kept and which is deleted';

  @override
  String get mergeComparisonTitle => 'Data comparison';

  @override
  String get mergeComparisonFieldHeader => 'Field';

  @override
  String get mergeDiffBadge => 'Differs';

  @override
  String mergeAcknowledgeLabel(String duplicateName) {
    return 'I understand \"$duplicateName\" will be permanently deleted.';
  }

  @override
  String get mergeFieldId => 'Internal ID';

  @override
  String get mergeFieldCode => 'Code';

  @override
  String get mergeFieldSku => 'SKU';

  @override
  String get mergeFieldModel => 'Model';

  @override
  String get mergeFieldBrand => 'Brand';

  @override
  String get mergeFieldUom => 'Unit of measurement';

  @override
  String get mergeFieldTaxRate => 'Tax rate';

  @override
  String get mergeFieldStatus => 'Status';

  @override
  String get mergeRelatedRecordsTitle =>
      'Records attached to the product being deleted';

  @override
  String get mergeRelatedDestroyedNote => 'deleted, not moved';

  @override
  String get mergeRelatedTotalLabel => 'Total';

  @override
  String get mergeCategorySalesOrderDetail => 'Sales order lines';

  @override
  String get mergeCategoryPurchaseOrderDetail => 'Purchase order lines';

  @override
  String get mergeCategoryInventoryReceiptDetail => 'Inventory receipt lines';

  @override
  String get mergeCategoryInventoryIssueDetail => 'Inventory issue lines';

  @override
  String get mergeCategoryInventoryTransferDetail => 'Inventory transfer lines';

  @override
  String get mergeCategoryLotSerialTracking => 'Lot and serial tracking';

  @override
  String get mergeCategoryProductPrice => 'Price lists';

  @override
  String get mergeCategoryProductLabel => 'Labels';

  @override
  String get mergeCategoryFiscalDocumentDetail => 'Fiscal document lines';

  @override
  String get mergeCategoryCommissionProduct => 'Commissions';

  @override
  String get mergeCategoryCustomerDiscount => 'Customer discounts';

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
  String get employeeIdLabel => 'Employee';

  @override
  String get administratorLabel => 'Administrator';

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
  String get userEmployeeRequiredError => 'Employee is required.';

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
  String get pricingGridHint =>
      'Click any price to edit · Enter saves and drops down · Tab moves right · Escape cancels';

  @override
  String get pricingGridReadOnlyHint =>
      'Read-only — your profile has no update right on Pricing.';

  @override
  String get pricingGridColumnsFilterLabel => 'Price lists shown';

  @override
  String get pricingGridWorklistAll => 'All products';

  @override
  String pricingGridWorklistMissing(String priceListName, int count) {
    return 'Missing $priceListName ($count)';
  }

  @override
  String get pricingGridColumnActionsTooltip => 'Column actions';

  @override
  String get pricingGridFillDown => 'Fill down from first row';

  @override
  String pricingGridCopyFromCost(String costListName) {
    return 'Copy from $costListName';
  }

  @override
  String get pricingGridAdjustLabel => 'Adjust every shown row by';

  @override
  String get pricingGridAdjustApply => 'Apply';

  @override
  String pricingGridRowsChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prices changed',
      one: '1 price changed',
      zero: 'No prices changed',
    );
    return '$_temp0';
  }

  @override
  String get pricingGridColumnActionFailed =>
      'Could not apply the action. No prices changed.';

  @override
  String get pricingGridCellSaving => 'Saving…';

  @override
  String pricingGridCellSaved(String previous) {
    return 'Saved · was $previous';
  }

  @override
  String get pricingGridCellSavedNew => 'Saved · newly priced';

  @override
  String pricingGridSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prices changed',
      one: '1 price changed',
    );
    return '$_temp0';
  }

  @override
  String pricingGridSummaryRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rejected',
      one: '1 rejected',
    );
    return '$_temp0';
  }

  @override
  String get pricingGridUndoLast => 'Undo last';

  @override
  String get pricingGridRevertAll => 'Revert all';

  @override
  String get pricingGridDismissRejected => 'Dismiss rejected';

  @override
  String get pricingGridDiscardTitle => 'Discard outstanding changes?';

  @override
  String get pricingGridDiscardBody =>
      'The undo history and any rejected text will be lost. Prices already saved are unaffected.';

  @override
  String get pricingGridDiscardConfirm => 'Leave anyway';

  @override
  String get pricingGridDiscardCancel => 'Stay';

  @override
  String get exchangeRatesMenuTitle => 'Exchange Rates';

  @override
  String get priceListsSearchLabel => 'Search by name';

  @override
  String get newPriceListTooltip => 'New price list';

  @override
  String get noPriceListsFound => 'No price lists found.';

  @override
  String get priceListNameLabel => 'Name';

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
  String priceListDeleteLead(String name, int id) {
    return '$name #$id will be permanently deleted. This cannot be undone.';
  }

  @override
  String get priceListDeleteRelatedTitle =>
      'Records attached to this price list';

  @override
  String get priceListDeleteTotalLabel => 'Total';

  @override
  String get priceListDeleteTotalCaption =>
      'Records this deletion touches — not all of them are deleted.';

  @override
  String get priceListDeleteFateDestroyed => 'deleted permanently';

  @override
  String get priceListDeleteFateMoved => 'moved to the replacement';

  @override
  String get priceListDeleteFateBlocking =>
      'blocks deletion — clear these first';

  @override
  String get priceListDeleteCategoryProductPrice => 'Product prices';

  @override
  String get priceListDeleteCategoryCustomer => 'Customers';

  @override
  String get priceListDeleteViewCustomers => 'View customers';

  @override
  String get priceListDeleteCleanNote =>
      'No prices and no customers depend on this list.';

  @override
  String get priceListDeleteConfirm => 'Delete list';

  @override
  String priceListDeleteConfirmPrices(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete list and $formatted prices',
      one: 'Delete list and 1 price',
    );
    return '$_temp0';
  }

  @override
  String get priceListDeletedMessage => 'Price list deleted.';

  @override
  String get priceListDeleteReplacementLabel => 'Replacement price list';

  @override
  String get priceListDeleteReplacementLabelOptional =>
      'Replacement price list (optional)';

  @override
  String get priceListDeleteReplacementRequiredHelper =>
      'Required — every customer on this list moves here.';

  @override
  String get priceListDeleteReplacementOptionalHelper =>
      'Optional — used only if customers turn out to be assigned.';

  @override
  String priceListDeleteReplacementChosenHelper(
    int count,
    String formatted,
    String name,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $formatted customers move to $name.',
      one: 'All 1 customer moves to $name.',
    );
    return '$_temp0';
  }

  @override
  String priceListDeleteConfirmCustomers(int count, String formatted) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete list and move $formatted customers',
      one: 'Delete list and move 1 customer',
    );
    return '$_temp0';
  }

  @override
  String priceListDeletedWithMoveMessage(
    int count,
    String formatted,
    String name,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Price list deleted. $formatted customers moved to $name.',
      one: 'Price list deleted. 1 customer moved to $name.',
    );
    return '$_temp0';
  }

  @override
  String get priceListDeleteAcknowledge =>
      'I understand this cannot be undone and that this list\'s prices are deleted with it.';

  @override
  String get priceListDeleteBlockedBanner =>
      'This list is still in use by records the deletion cannot touch. Clear them first, then delete the list.';

  @override
  String get priceListDeletePreviewFailedNote =>
      'Could not load what depends on this list. You can still delete it — if customers are assigned, the deletion will be refused.';

  @override
  String get priceListDeleteClose => 'Close';

  @override
  String get priceListNameRequiredError => 'Name is required.';

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

  @override
  String get suppliersMenuTitle => 'Suppliers';

  @override
  String get labelsMenuTitle => 'Labels';

  @override
  String get employeesMenuTitle => 'Employees';

  @override
  String get customersMenuTitle => 'Customers';

  @override
  String get taxpayerRecipientsMenuTitle => 'Taxpayer Recipients';

  @override
  String get expensesMenuTitle => 'Expenses';

  @override
  String get vehiclesMenuTitle => 'Vehicles';

  @override
  String get vehicleOperatorsMenuTitle => 'Vehicle Operators';

  @override
  String get zoneLabel => 'Zone';

  @override
  String get creditLimitLabel => 'Credit limit';

  @override
  String get creditDaysLabel => 'Credit days';

  @override
  String get creditLimitInvalidError => 'Enter a valid non-negative amount.';

  @override
  String get creditDaysInvalidError =>
      'Enter a valid non-negative whole number.';

  @override
  String get suppliersSearchLabel => 'Search by code or name';

  @override
  String get newSupplierTooltip => 'New supplier';

  @override
  String get noSuppliersFound => 'No suppliers found.';

  @override
  String get newSupplierTitle => 'New supplier';

  @override
  String get editSupplierTitle => 'Edit supplier';

  @override
  String get viewSupplierTitle => 'View supplier';

  @override
  String get deleteSupplierButton => 'Delete supplier';

  @override
  String get deleteSupplierConfirmTitle => 'Delete supplier?';

  @override
  String deleteSupplierConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get supplierLoadFailedError => 'Failed to load supplier.';

  @override
  String get supplierCreateFailedError => 'Failed to create supplier.';

  @override
  String get supplierUpdateFailedError => 'Failed to update supplier.';

  @override
  String get supplierDeleteFailedError => 'Failed to delete supplier.';

  @override
  String get supplierSaveConflictError =>
      'Another supplier already uses that code, or one of the linked records no longer exists. Check the code and the links, then save again.';

  @override
  String get supplierDeleteConflictError =>
      'This supplier can\'t be deleted while it has addresses, contacts, bank accounts or agreements. Unlink them and remove the agreements first.';

  @override
  String get supplierCreatePermissionDeniedError =>
      'You no longer have permission to create suppliers.';

  @override
  String get supplierUpdatePermissionDeniedError =>
      'You no longer have permission to edit suppliers.';

  @override
  String get supplierDeletePermissionDeniedError =>
      'You no longer have permission to delete suppliers.';

  @override
  String get supplierCodeRequiredError => 'Code is required.';

  @override
  String get supplierNameRequiredError => 'Name is required.';

  @override
  String get labelsSearchLabel => 'Search by name';

  @override
  String get newLabelTooltip => 'New label';

  @override
  String get noLabelsFound => 'No labels found.';

  @override
  String get newLabelTitle => 'New label';

  @override
  String get editLabelTitle => 'Edit label';

  @override
  String get viewLabelTitle => 'View label';

  @override
  String get deleteLabelButton => 'Delete label';

  @override
  String get deleteLabelConfirmTitle => 'Delete label?';

  @override
  String deleteLabelConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get labelLoadFailedError => 'Failed to load label.';

  @override
  String get labelCreateFailedError => 'Failed to create label.';

  @override
  String get labelUpdateFailedError => 'Failed to update label.';

  @override
  String get labelDeleteFailedError => 'Failed to delete label.';

  @override
  String get labelCreatePermissionDeniedError =>
      'You no longer have permission to create labels.';

  @override
  String get labelUpdatePermissionDeniedError =>
      'You no longer have permission to edit labels.';

  @override
  String get labelDeletePermissionDeniedError =>
      'You no longer have permission to delete labels.';

  @override
  String get labelNameRequiredError => 'Name is required.';

  @override
  String get expensesSearchLabel => 'Search by name';

  @override
  String get newExpenseTooltip => 'New expense';

  @override
  String get noExpensesFound => 'No expenses found.';

  @override
  String get newExpenseTitle => 'New expense';

  @override
  String get editExpenseTitle => 'Edit expense';

  @override
  String get viewExpenseTitle => 'View expense';

  @override
  String get deleteExpenseButton => 'Delete expense';

  @override
  String get deleteExpenseConfirmTitle => 'Delete expense?';

  @override
  String deleteExpenseConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get expenseLoadFailedError => 'Failed to load expense.';

  @override
  String get expenseCreateFailedError => 'Failed to create expense.';

  @override
  String get expenseUpdateFailedError => 'Failed to update expense.';

  @override
  String get expenseDeleteFailedError => 'Failed to delete expense.';

  @override
  String get expenseCreatePermissionDeniedError =>
      'You no longer have permission to create expenses.';

  @override
  String get expenseUpdatePermissionDeniedError =>
      'You no longer have permission to edit expenses.';

  @override
  String get expenseDeletePermissionDeniedError =>
      'You no longer have permission to delete expenses.';

  @override
  String get expenseNameRequiredError => 'Name is required.';

  @override
  String get licensePlateLabel => 'License plate';

  @override
  String get tonsCapacityLabel => 'Tons capacity';

  @override
  String get vehiclesSearchLabel => 'Search by plate, name, or nickname';

  @override
  String get newVehicleTooltip => 'New vehicle';

  @override
  String get noVehiclesFound => 'No vehicles found.';

  @override
  String get newVehicleTitle => 'New vehicle';

  @override
  String get editVehicleTitle => 'Edit vehicle';

  @override
  String get viewVehicleTitle => 'View vehicle';

  @override
  String get deleteVehicleButton => 'Delete vehicle';

  @override
  String get deleteVehicleConfirmTitle => 'Delete vehicle?';

  @override
  String deleteVehicleConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get vehicleLoadFailedError => 'Failed to load vehicle.';

  @override
  String get vehicleCreateFailedError => 'Failed to create vehicle.';

  @override
  String get vehicleUpdateFailedError => 'Failed to update vehicle.';

  @override
  String get vehicleDeleteFailedError => 'Failed to delete vehicle.';

  @override
  String get vehicleCreatePermissionDeniedError =>
      'You no longer have permission to create vehicles.';

  @override
  String get vehicleUpdatePermissionDeniedError =>
      'You no longer have permission to edit vehicles.';

  @override
  String get vehicleDeletePermissionDeniedError =>
      'You no longer have permission to delete vehicles.';

  @override
  String get vehicleLicensePlateRequiredError => 'License plate is required.';

  @override
  String get vehicleNameRequiredError => 'Name is required.';

  @override
  String get vehicleNicknameRequiredError => 'Nickname is required.';

  @override
  String get vehicleTonsCapacityInvalidError =>
      'Enter a valid non-negative whole number.';

  @override
  String get driverLabel => 'Driver';

  @override
  String get licensePhotoLabel => 'License photo';

  @override
  String get licensePhotoUnavailable => 'Photo unavailable';

  @override
  String get licensePhotoInvalidTypeError =>
      'Photo must be a JPEG or PNG file.';

  @override
  String get licensePhotoTooLargeError => 'Photo must be 2 MB or smaller.';

  @override
  String get licensePhotoSaveFailedError =>
      'The operator was saved, but the license photo could not be saved. Press Save to try again.';

  @override
  String get licenseTypeLabel => 'License type';

  @override
  String get driverLicenseNumberLabel => 'License number';

  @override
  String get issueDateLabel => 'Issue date';

  @override
  String get expirationDateLabel => 'Expiration date';

  @override
  String get issuingLocationLabel => 'Issuing location';

  @override
  String get daysUntilExpiryColumn => 'Expiry';

  @override
  String expiresInDays(int days) {
    return 'Expires in $days days';
  }

  @override
  String get expiresToday => 'Expires today';

  @override
  String expiredDaysAgo(int days) {
    return 'Expired $days days ago';
  }

  @override
  String get vehicleOperatorsDriverFilter => 'Driver';

  @override
  String get vehicleOperatorsSearchLabel =>
      'Search by driver or license number';

  @override
  String get newVehicleOperatorTooltip => 'New vehicle operator';

  @override
  String get noVehicleOperatorsFound => 'No vehicle operators found.';

  @override
  String get newVehicleOperatorTitle => 'New vehicle operator';

  @override
  String get editVehicleOperatorTitle => 'Edit vehicle operator';

  @override
  String get viewVehicleOperatorTitle => 'View vehicle operator';

  @override
  String get deleteVehicleOperatorButton => 'Delete vehicle operator';

  @override
  String get deleteVehicleOperatorConfirmTitle => 'Delete vehicle operator?';

  @override
  String deleteVehicleOperatorConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get vehicleOperatorLoadFailedError =>
      'Failed to load vehicle operator.';

  @override
  String get vehicleOperatorCreateFailedError =>
      'Failed to create vehicle operator.';

  @override
  String get vehicleOperatorUpdateFailedError =>
      'Failed to update vehicle operator.';

  @override
  String get vehicleOperatorDeleteFailedError =>
      'Failed to delete vehicle operator.';

  @override
  String get vehicleOperatorCreatePermissionDeniedError =>
      'You no longer have permission to create vehicle operators.';

  @override
  String get vehicleOperatorUpdatePermissionDeniedError =>
      'You no longer have permission to edit vehicle operators.';

  @override
  String get vehicleOperatorDeletePermissionDeniedError =>
      'You no longer have permission to delete vehicle operators.';

  @override
  String get vehicleOperatorDriverRequiredError => 'Driver is required.';

  @override
  String get vehicleOperatorLicenseTypeRequiredError =>
      'License type is required.';

  @override
  String get vehicleOperatorDriverLicenseNumberRequiredError =>
      'License number is required.';

  @override
  String get vehicleOperatorIssueDateRequiredError => 'Issue date is required.';

  @override
  String get vehicleOperatorExpirationDateRequiredError =>
      'Expiration date is required.';

  @override
  String get vehicleOperatorExpirationBeforeIssueError =>
      'Expiration date must not be before the issue date.';

  @override
  String get vehicleOperatorIssuingLocationRequiredError =>
      'Issuing location is required.';

  @override
  String get genderFemaleLabel => 'Female';

  @override
  String get genderMaleLabel => 'Male';

  @override
  String get genderLabel => 'Gender';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get birthdayLabel => 'Birthday';

  @override
  String get taxpayerIdLabel => 'Taxpayer ID (RFC)';

  @override
  String get salesPersonLabel => 'Sales person';

  @override
  String get personalIdLabel => 'Personal ID';

  @override
  String get startJobDateLabel => 'Start date';

  @override
  String get enrollNumberLabel => 'Enrollment number';

  @override
  String get columnFullName => 'Name';

  @override
  String get employeesSearchLabel => 'Search by name or nickname';

  @override
  String get newEmployeeTooltip => 'New employee';

  @override
  String get noEmployeesFound => 'No employees found.';

  @override
  String get employeesSalesPersonFilter => 'Sales person';

  @override
  String get newEmployeeTitle => 'New employee';

  @override
  String get editEmployeeTitle => 'Edit employee';

  @override
  String get viewEmployeeTitle => 'View employee';

  @override
  String get deleteEmployeeButton => 'Delete employee';

  @override
  String get deleteEmployeeConfirmTitle => 'Delete employee?';

  @override
  String deleteEmployeeConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get employeeLoadFailedError => 'Failed to load employee.';

  @override
  String get employeeCreateFailedError => 'Failed to create employee.';

  @override
  String get employeeUpdateFailedError => 'Failed to update employee.';

  @override
  String get employeeDeleteFailedError => 'Failed to delete employee.';

  @override
  String get employeeCreatePermissionDeniedError =>
      'You no longer have permission to create employees.';

  @override
  String get employeeUpdatePermissionDeniedError =>
      'You no longer have permission to edit employees.';

  @override
  String get employeeDeletePermissionDeniedError =>
      'You no longer have permission to delete employees.';

  @override
  String get employeeFirstNameRequiredError => 'First name is required.';

  @override
  String get employeeLastNameRequiredError => 'Last name is required.';

  @override
  String get employeeNicknameRequiredError => 'Nickname is required.';

  @override
  String get employeeGenderRequiredError => 'Gender is required.';

  @override
  String get employeeBirthdayRequiredError => 'Birthday is required.';

  @override
  String get employeeStartJobDateRequiredError => 'Start date is required.';

  @override
  String get employeeEnrollNumberInvalidError =>
      'Enter a valid non-negative whole number.';

  @override
  String get priceListFieldLabel => 'Price list';

  @override
  String get noneAssignedLabel => 'None assigned';

  @override
  String get columnSalesperson => 'Salesperson';

  @override
  String get customersSearchLabel => 'Search by code or name';

  @override
  String get newCustomerTooltip => 'New customer';

  @override
  String get noCustomersFound => 'No customers found.';

  @override
  String get customersPriceListFilterLabel => 'Price list';

  @override
  String get customersSalespersonFilterLabel => 'Salesperson';

  @override
  String get newCustomerTitle => 'New customer';

  @override
  String get editCustomerTitle => 'Edit customer';

  @override
  String get viewCustomerTitle => 'View customer';

  @override
  String get deleteCustomerButton => 'Delete customer';

  @override
  String get deleteCustomerConfirmTitle => 'Delete customer?';

  @override
  String deleteCustomerConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get customerLoadFailedError => 'Failed to load customer.';

  @override
  String get customerCreateFailedError => 'Failed to create customer.';

  @override
  String get customerUpdateFailedError => 'Failed to update customer.';

  @override
  String get customerDeleteFailedError => 'Failed to delete customer.';

  @override
  String get customerCreatePermissionDeniedError =>
      'You no longer have permission to create customers.';

  @override
  String get customerUpdatePermissionDeniedError =>
      'You no longer have permission to edit customers.';

  @override
  String get customerDeletePermissionDeniedError =>
      'You no longer have permission to delete customers.';

  @override
  String get customerNameRequiredError => 'Name is required.';

  @override
  String get customerPriceListRequiredError => 'Price list is required.';

  @override
  String get taxpayerRecipientIdLabel => 'Tax ID (RFC)';

  @override
  String get postalCodeFieldLabel => 'Postal code';

  @override
  String get regimeFieldLabel => 'Tax regime';

  @override
  String get unresolvedFallbackLabel => 'Unknown';

  @override
  String get taxpayerRecipientsSearchLabel => 'Search by name or email';

  @override
  String get newTaxpayerRecipientTooltip => 'New taxpayer recipient';

  @override
  String get noTaxpayerRecipientsFound => 'No taxpayer recipients found.';

  @override
  String get newTaxpayerRecipientTitle => 'New taxpayer recipient';

  @override
  String get editTaxpayerRecipientTitle => 'Edit taxpayer recipient';

  @override
  String get viewTaxpayerRecipientTitle => 'View taxpayer recipient';

  @override
  String get deleteTaxpayerRecipientButton => 'Delete taxpayer recipient';

  @override
  String get deleteTaxpayerRecipientConfirmTitle =>
      'Delete taxpayer recipient?';

  @override
  String deleteTaxpayerRecipientConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get taxpayerRecipientLoadFailedError =>
      'Failed to load taxpayer recipient.';

  @override
  String get taxpayerRecipientCreateFailedError =>
      'Failed to create taxpayer recipient.';

  @override
  String get taxpayerRecipientUpdateFailedError =>
      'Failed to update taxpayer recipient.';

  @override
  String get taxpayerRecipientDeleteFailedError =>
      'Failed to delete taxpayer recipient.';

  @override
  String get taxpayerRecipientCreatePermissionDeniedError =>
      'You no longer have permission to create taxpayer recipients.';

  @override
  String get taxpayerRecipientUpdatePermissionDeniedError =>
      'You no longer have permission to edit taxpayer recipients.';

  @override
  String get taxpayerRecipientDeletePermissionDeniedError =>
      'You no longer have permission to delete taxpayer recipients.';

  @override
  String get taxpayerRecipientIdRequiredError => 'Tax ID is required.';

  @override
  String get taxpayerRecipientNameRequiredError => 'Name is required.';

  @override
  String get taxpayerRecipientEmailRequiredError => 'Email is required.';

  @override
  String get facilityTypeStore => 'Store';

  @override
  String get facilityTypeProductionSite => 'Production Site';

  @override
  String get columnFacility => 'Facility';

  @override
  String get columnWarehouse => 'Warehouse';

  @override
  String get columnComment => 'Comment';

  @override
  String get columnType => 'Type';

  @override
  String get columnTaxpayer => 'Taxpayer';

  @override
  String get columnAddress => 'Address';

  @override
  String get columnLocation => 'Postal Code';

  @override
  String get facilityFieldLabel => 'Facility';

  @override
  String get warehouseFieldLabel => 'Warehouse';

  @override
  String get unknownFacilityLabel => 'Unknown facility';

  @override
  String get unknownWarehouseLabel => 'Unknown warehouse';

  @override
  String get warehousesMenuTitle => 'Warehouses';

  @override
  String get warehousesSearchLabel => 'Search by code or name';

  @override
  String get newWarehouseTooltip => 'New warehouse';

  @override
  String get noWarehousesFound => 'No warehouses found.';

  @override
  String get viewWarehouseTitle => 'View Warehouse';

  @override
  String get editWarehouseTitle => 'Edit Warehouse';

  @override
  String get newWarehouseTitle => 'New Warehouse';

  @override
  String get deleteWarehouseButton => 'Delete warehouse';

  @override
  String get deleteWarehouseConfirmTitle => 'Delete warehouse?';

  @override
  String deleteWarehouseConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get warehouseLoadFailedError => 'Failed to load warehouse.';

  @override
  String get warehouseCreateFailedError => 'Failed to create warehouse.';

  @override
  String get warehouseUpdateFailedError => 'Failed to update warehouse.';

  @override
  String get warehouseDeleteFailedError => 'Failed to delete warehouse.';

  @override
  String get warehouseCreatePermissionDeniedError =>
      'You no longer have permission to create warehouses.';

  @override
  String get warehouseUpdatePermissionDeniedError =>
      'You no longer have permission to edit warehouses.';

  @override
  String get warehouseDeletePermissionDeniedError =>
      'You no longer have permission to delete warehouses.';

  @override
  String get warehouseFacilityRequiredError => 'Facility is required.';

  @override
  String get warehouseCodeRequiredError => 'Code is required.';

  @override
  String get warehouseNameRequiredError => 'Name is required.';

  @override
  String get cashDrawersMenuTitle => 'Cash Drawers';

  @override
  String get cashDrawersSearchLabel => 'Search by code or name';

  @override
  String get newCashDrawerTooltip => 'New cash drawer';

  @override
  String get noCashDrawersFound => 'No cash drawers found.';

  @override
  String get viewCashDrawerTitle => 'View Cash Drawer';

  @override
  String get editCashDrawerTitle => 'Edit Cash Drawer';

  @override
  String get newCashDrawerTitle => 'New Cash Drawer';

  @override
  String get deleteCashDrawerButton => 'Delete cash drawer';

  @override
  String get deleteCashDrawerConfirmTitle => 'Delete cash drawer?';

  @override
  String deleteCashDrawerConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get cashDrawerLoadFailedError => 'Failed to load cash drawer.';

  @override
  String get cashDrawerCreateFailedError => 'Failed to create cash drawer.';

  @override
  String get cashDrawerUpdateFailedError => 'Failed to update cash drawer.';

  @override
  String get cashDrawerDeleteFailedError => 'Failed to delete cash drawer.';

  @override
  String get cashDrawerCreatePermissionDeniedError =>
      'You no longer have permission to create cash drawers.';

  @override
  String get cashDrawerUpdatePermissionDeniedError =>
      'You no longer have permission to edit cash drawers.';

  @override
  String get cashDrawerDeletePermissionDeniedError =>
      'You no longer have permission to delete cash drawers.';

  @override
  String get cashDrawerFacilityRequiredError => 'Facility is required.';

  @override
  String get cashDrawerCodeRequiredError => 'Code is required.';

  @override
  String get cashDrawerNameRequiredError => 'Name is required.';

  @override
  String get pointsOfSaleMenuTitle => 'Points of Sale';

  @override
  String get pointsOfSaleSearchLabel => 'Search by code or name';

  @override
  String get newPointSaleTooltip => 'New point of sale';

  @override
  String get noPointsOfSaleFound => 'No points of sale found.';

  @override
  String get viewPointSaleTitle => 'View Point of Sale';

  @override
  String get editPointSaleTitle => 'Edit Point of Sale';

  @override
  String get newPointSaleTitle => 'New Point of Sale';

  @override
  String get deletePointSaleButton => 'Delete point of sale';

  @override
  String get deletePointSaleConfirmTitle => 'Delete point of sale?';

  @override
  String deletePointSaleConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get pointSaleLoadFailedError => 'Failed to load point of sale.';

  @override
  String get pointSaleCreateFailedError => 'Failed to create point of sale.';

  @override
  String get pointSaleUpdateFailedError => 'Failed to update point of sale.';

  @override
  String get pointSaleDeleteFailedError => 'Failed to delete point of sale.';

  @override
  String get pointSaleCreatePermissionDeniedError =>
      'You no longer have permission to create points of sale.';

  @override
  String get pointSaleUpdatePermissionDeniedError =>
      'You no longer have permission to edit points of sale.';

  @override
  String get pointSaleDeletePermissionDeniedError =>
      'You no longer have permission to delete points of sale.';

  @override
  String get pointSaleFacilityRequiredError => 'Facility is required.';

  @override
  String get pointSaleCodeRequiredError => 'Code is required.';

  @override
  String get pointSaleNameRequiredError => 'Name is required.';

  @override
  String get pointSaleWarehouseRequiredError => 'Warehouse is required.';

  @override
  String get facilitiesMenuTitle => 'Facilities';

  @override
  String get facilitiesSearchLabel => 'Search by code or name';

  @override
  String get newFacilityTooltip => 'New facility';

  @override
  String get noFacilitiesFound => 'No facilities found.';

  @override
  String get viewFacilityTitle => 'View Facility';

  @override
  String get editFacilityTitle => 'Edit Facility';

  @override
  String get newFacilityTitle => 'New Facility';

  @override
  String get facilityReceiptMessageLabel => 'Receipt message';

  @override
  String get facilityDefaultBatchLabel => 'Default batch';

  @override
  String get facilityLogoLabel => 'Logo';

  @override
  String get facilityLogoUploadButton => 'Upload logo';

  @override
  String get facilityLogoReplaceButton => 'Replace logo';

  @override
  String get facilityLogoRemoveButton => 'Remove logo';

  @override
  String get facilityLogoInvalidTypeError =>
      'The logo must be a JPEG or PNG file.';

  @override
  String get facilityLogoTooLargeError => 'The logo must be 2 MB or smaller.';

  @override
  String get facilityLogoUploadFailedError =>
      'The facility was saved, but the logo could not be uploaded. Try again.';

  @override
  String get facilityLogoRemoveFailedError =>
      'The facility was saved, but the logo could not be removed. Try again.';

  @override
  String get deleteFacilityButton => 'Delete facility';

  @override
  String get deleteFacilityConfirmTitle => 'Delete facility?';

  @override
  String deleteFacilityConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get facilityLoadFailedError => 'Failed to load facility.';

  @override
  String get facilityCreateFailedError => 'Failed to create facility.';

  @override
  String get facilityUpdateFailedError => 'Failed to update facility.';

  @override
  String get facilityDeleteFailedError => 'Failed to delete facility.';

  @override
  String get facilityCreatePermissionDeniedError =>
      'You no longer have permission to create facilities.';

  @override
  String get facilityUpdatePermissionDeniedError =>
      'You no longer have permission to edit facilities.';

  @override
  String get facilityDeletePermissionDeniedError =>
      'You no longer have permission to delete facilities.';

  @override
  String get facilityCodeRequiredError => 'Code is required.';

  @override
  String get facilityNameRequiredError => 'Name is required.';

  @override
  String get facilityLocationRequiredError => 'Postal code is required.';

  @override
  String get facilityAddressRequiredError => 'Address is required.';

  @override
  String get facilityTaxpayerRequiredError => 'Taxpayer is required.';

  @override
  String get facilityTaxpayerInvalidError =>
      'Enter a valid RFC (up to 13 characters).';

  @override
  String get facilitiesExpandAll => 'Expand all';

  @override
  String get facilitiesCollapseAll => 'Collapse all';

  @override
  String get noWarehousesInFacility => 'No warehouses registered.';

  @override
  String get noPointsOfSaleInFacility => 'No points of sale.';

  @override
  String get noCashDrawersInFacility => 'No cash drawers registered.';

  @override
  String get pointSaleForeignFacilityBadge => 'Other facility';

  @override
  String get newWarehouseInFacility => 'Warehouse';

  @override
  String get newPointSaleInFacility => 'Point of sale';

  @override
  String get newCashDrawerInFacility => 'Cash drawer';

  @override
  String get facilityChildrenLoadFailed =>
      'Could not load this facility\'s items.';

  @override
  String facilitiesPaginationSummary(int start, int end, int total) {
    return '$start–$end of $total facilities';
  }

  @override
  String get previousPageTooltip => 'Previous page';

  @override
  String get nextPageTooltip => 'Next page';

  @override
  String get newAddressTooltip => 'New address';

  @override
  String get newAddressDialogTitle => 'New Address';

  @override
  String get createAddressButton => 'Create address';

  @override
  String get addressStreetLabel => 'Street';

  @override
  String get addressExteriorNumberLabel => 'Exterior number';

  @override
  String get addressInteriorNumberLabel => 'Interior number';

  @override
  String get addressPostalCodeLabel => 'Postal code';

  @override
  String get addressNeighborhoodLabel => 'Neighborhood';

  @override
  String get addressLocalityLabel => 'Locality';

  @override
  String get addressBoroughLabel => 'Borough';

  @override
  String get addressStateLabel => 'State';

  @override
  String get addressCityLabel => 'City';

  @override
  String get addressCountryLabel => 'Country';

  @override
  String get addressNicknameLabel => 'Nickname';

  @override
  String get addressCreateFailedError => 'Failed to create address.';

  @override
  String get addressStreetRequiredError => 'Street is required.';

  @override
  String get addressExteriorNumberRequiredError =>
      'Exterior number is required.';

  @override
  String get addressPostalCodeRequiredError => 'Postal code is required.';

  @override
  String get addressNeighborhoodRequiredError => 'Neighborhood is required.';

  @override
  String get addressBoroughRequiredError => 'Borough is required.';

  @override
  String get addressStateRequiredError => 'State is required.';

  @override
  String get addressCountryRequiredError => 'Country is required.';

  @override
  String get paymentMethodOptionsMenuTitle => 'Payment Method Options';

  @override
  String get columnPaymentMethod => 'Payment Method';

  @override
  String get columnNumberOfPayments => 'Payments';

  @override
  String get paymentMethodFieldLabel => 'Payment method';

  @override
  String get numberOfPaymentsFieldLabel => 'Number of payments';

  @override
  String get displayOnTicketFieldLabel => 'Show on ticket';

  @override
  String get commissionFieldLabel => 'Commission';

  @override
  String get newPaymentMethodOptionTooltip => 'New payment method option';

  @override
  String get paymentMethodOptionsSearchLabel => 'Search by name';

  @override
  String get noPaymentMethodOptionsFound => 'No payment method options found.';

  @override
  String get viewPaymentMethodOptionTitle => 'View Payment Method Option';

  @override
  String get editPaymentMethodOptionTitle => 'Edit Payment Method Option';

  @override
  String get newPaymentMethodOptionTitle => 'New Payment Method Option';

  @override
  String get deletePaymentMethodOptionButton => 'Delete payment method option';

  @override
  String get deletePaymentMethodOptionConfirmTitle =>
      'Delete payment method option?';

  @override
  String deletePaymentMethodOptionConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get paymentMethodOptionLoadFailedError =>
      'Failed to load payment method option.';

  @override
  String get paymentMethodOptionCreateFailedError =>
      'Failed to create payment method option.';

  @override
  String get paymentMethodOptionUpdateFailedError =>
      'Failed to update payment method option.';

  @override
  String get paymentMethodOptionDeleteFailedError =>
      'Failed to delete payment method option.';

  @override
  String get paymentMethodOptionCreatePermissionDeniedError =>
      'You no longer have permission to create payment method options.';

  @override
  String get paymentMethodOptionUpdatePermissionDeniedError =>
      'You no longer have permission to update payment method options.';

  @override
  String get paymentMethodOptionDeletePermissionDeniedError =>
      'You no longer have permission to delete payment method options.';

  @override
  String get paymentMethodOptionFacilityRequiredError =>
      'Facility is required.';

  @override
  String get paymentMethodOptionNameRequiredError => 'Name is required.';

  @override
  String get paymentMethodOptionPaymentMethodRequiredError =>
      'Payment method is required.';

  @override
  String get paymentMethodOptionNumberOfPaymentsInvalidError =>
      'Number of payments must be at least 1.';

  @override
  String get paymentMethodOptionCommissionInvalidError =>
      'Commission must be a non-negative number.';

  @override
  String get paymentMethodNa => 'N/A';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodCheck => 'Check';

  @override
  String get paymentMethodEft => 'Electronic funds transfer';

  @override
  String get paymentMethodCreditCard => 'Credit card';

  @override
  String get paymentMethodElectronicPurse => 'Electronic purse';

  @override
  String get paymentMethodElectronicMoney => 'Electronic money';

  @override
  String get paymentMethodFoodVouchers => 'Food vouchers';

  @override
  String get paymentMethodGiving => 'Payment in kind';

  @override
  String get paymentMethodCreditorSatisfaction =>
      'To the satisfaction of the creditor';

  @override
  String get paymentMethodDebitCard => 'Debit card';

  @override
  String get paymentMethodServiceCard => 'Service card';

  @override
  String get paymentMethodAdvancePayments => 'Advance payments';

  @override
  String get paymentMethodToBeDefined => 'To be defined';

  @override
  String get paymentMethodGovernmentFunding => 'Government funding';

  @override
  String get taxpayerIssuersMenuTitle => 'Taxpayer Issuers';

  @override
  String get columnRfc => 'RFC';

  @override
  String get columnPostalCodeShort => 'C.P.';

  @override
  String get columnRegime => 'Fiscal Regime';

  @override
  String get rfcFieldLabel => 'RFC';

  @override
  String get providerFieldLabel => 'Certification provider';

  @override
  String get newTaxpayerIssuerTooltip => 'New taxpayer issuer';

  @override
  String get taxpayerIssuersSearchLabel => 'Search by RFC or name';

  @override
  String get noTaxpayerIssuersFound => 'No taxpayer issuers found.';

  @override
  String get viewTaxpayerIssuerTitle => 'View Taxpayer Issuer';

  @override
  String get editTaxpayerIssuerTitle => 'Edit Taxpayer Issuer';

  @override
  String get newTaxpayerIssuerTitle => 'New Taxpayer Issuer';

  @override
  String get deleteTaxpayerIssuerButton => 'Delete taxpayer issuer';

  @override
  String get deleteTaxpayerIssuerConfirmTitle => 'Delete taxpayer issuer?';

  @override
  String deleteTaxpayerIssuerConfirmMessage(String name) {
    return 'This will permanently delete \"$name\". This cannot be undone.';
  }

  @override
  String get taxpayerIssuerLoadFailedError => 'Failed to load taxpayer issuer.';

  @override
  String get taxpayerIssuerCreateFailedError =>
      'Failed to create taxpayer issuer.';

  @override
  String get taxpayerIssuerUpdateFailedError =>
      'Failed to update taxpayer issuer.';

  @override
  String get taxpayerIssuerDeleteFailedError =>
      'Failed to delete taxpayer issuer.';

  @override
  String get taxpayerIssuerCreatePermissionDeniedError =>
      'You no longer have permission to create taxpayer issuers.';

  @override
  String get taxpayerIssuerUpdatePermissionDeniedError =>
      'You no longer have permission to update taxpayer issuers.';

  @override
  String get taxpayerIssuerDeletePermissionDeniedError =>
      'You no longer have permission to delete taxpayer issuers.';

  @override
  String get taxpayerIssuerRfcRequiredError => 'RFC is required.';

  @override
  String get taxpayerIssuerNameRequiredError => 'Name is required.';

  @override
  String get taxpayerIssuerRegimeRequiredError => 'Fiscal regime is required.';

  @override
  String get fiscalCertificationProviderNone => 'None';

  @override
  String get fiscalCertificationProviderDiverza => 'Diverza';

  @override
  String get fiscalCertificationProviderFiscoClic => 'FiscoClic';

  @override
  String get fiscalCertificationProviderServisim => 'Servisim';

  @override
  String get fiscalCertificationProviderProFact => 'ProFact';

  @override
  String get certificatesSectionTitle => 'Certificates';

  @override
  String get columnCertificateNumber => 'Certificate Number';

  @override
  String get columnValidFrom => 'Valid From';

  @override
  String get columnValidTo => 'Valid To';

  @override
  String get addCertificateButton => 'Add';

  @override
  String get noCertificatesFound => 'No certificates registered.';

  @override
  String get newCertificateDialogTitle => 'Register Certificate';

  @override
  String get certificateFileLabel => 'Certificate file (.cer)';

  @override
  String get keyFileLabel => 'Key file (.key)';

  @override
  String get keyPasswordLabel => 'Key password';

  @override
  String get chooseFileButton => 'Choose file';

  @override
  String get uploadCertificateButton => 'Register';

  @override
  String get certificateFileRequiredError =>
      'Select a certificate (.cer) file.';

  @override
  String get keyFileRequiredError => 'Select a key (.key) file.';

  @override
  String get keyPasswordRequiredError => 'Key password is required.';

  @override
  String get certificateUploadFailedError => 'Failed to register certificate.';

  @override
  String get cashSessionsMenuTitle => 'Cash Sessions';

  @override
  String get posMenuTitle => 'Point of Sale';

  @override
  String get salesOrdersMenuTitle => 'Sales Orders';

  @override
  String get salesQuotesMenuTitle => 'Sales Quotes';

  @override
  String get salesOrdersScreenTitle => 'Sales Orders';

  @override
  String get salesOrderNewAction => 'New order';

  @override
  String get salesOrdersColumnReference => 'Reference';

  @override
  String get salesOrdersColumnDate => 'Date';

  @override
  String get salesOrdersColumnCustomer => 'Customer';

  @override
  String get salesOrdersColumnStatus => 'Status';

  @override
  String get salesOrdersColumnTotal => 'Total';

  @override
  String get salesOrdersColumnBalance => 'Balance';

  @override
  String get salesOrdersSearchLabel => 'Search orders';

  @override
  String get salesOrderReferenceLabel => 'Reference';

  @override
  String get salesOrderStatusLabel => 'Status';

  @override
  String get salesOrderDateLabel => 'Date';

  @override
  String get salesOrderDueDateLabel => 'Due date';

  @override
  String get salesOrderExchangeRateLabel => 'Exchange rate';

  @override
  String get salesOrderPaymentTermsLabel => 'Payment terms';

  @override
  String get salesOrderPromiseDateLabel => 'Promise date';

  @override
  String get salesOrderCurrencyLabel => 'Currency';

  @override
  String get salesOrderPriorityLabel => 'Priority';

  @override
  String get salesOrderSalespersonLabel => 'Salesperson';

  @override
  String get salesOrderRecipientLabel => 'Tax ID';

  @override
  String get salesOrderCommentLabel => 'Comment';

  @override
  String get salesOrderMoreDetails => 'More details';

  @override
  String get salesOrderFewerDetails => 'Fewer details';

  @override
  String get salesQuoteConfirmAction => 'Confirm quote';

  @override
  String get salesQuoteStatusDraft => 'Draft';

  @override
  String get salesQuoteStatusCompleted => 'Confirmed';

  @override
  String get salesQuoteStatusCancelled => 'Cancelled';

  @override
  String get salesQuoteReferenceLabel => 'Reference';

  @override
  String get salesQuoteStatusLabel => 'Status';

  @override
  String get salesQuoteDateLabel => 'Date';

  @override
  String get salesQuoteMoreDetails => 'More details';

  @override
  String get salesQuoteFewerDetails => 'Fewer details';

  @override
  String get salesQuoteExpiryLabel => 'Expiry date';

  @override
  String get salesQuoteCurrencyLabel => 'Currency';

  @override
  String get salesQuoteCommentLabel => 'Comment';

  @override
  String get salesQuoteConvertAction => 'Convert to order';

  @override
  String get salesQuoteDuplicateAction => 'Duplicate';

  @override
  String get salesQuoteNewAction => 'New quote';

  @override
  String get salesQuotesColumnReference => 'Reference';

  @override
  String get salesQuotesColumnCustomer => 'Customer';

  @override
  String get salesQuotesColumnDate => 'Date';

  @override
  String get salesQuotesColumnExpiry => 'Expiry';

  @override
  String get salesQuotesColumnStatus => 'Status';

  @override
  String get salesQuotesColumnTotal => 'Total';

  @override
  String get salesQuotesSearchLabel => 'Search quotes';

  @override
  String get salesQuotesStatusFilterLabel => 'Status';

  @override
  String get salesQuotesCustomerFilterLabel => 'Customer';

  @override
  String get salesQuoteExpiredBadge => 'Expired';

  @override
  String get salesQuoteCancelAction => 'Cancel quote';

  @override
  String get salesQuoteCancelDialogTitle => 'Cancel this quote?';

  @override
  String get salesQuoteCancelDialogMessage =>
      'This cannot be undone. The quote will be marked cancelled.';

  @override
  String get salesQuoteCancelDialogKeepEditing => 'Keep editing';

  @override
  String get salesQuoteCancelDialogConfirm => 'Cancel quote';

  @override
  String get salesOrderPriorityLow => 'Low';

  @override
  String get salesOrderPriorityNormal => 'Normal';

  @override
  String get salesOrderPriorityHigh => 'High';

  @override
  String get salesOrderPriorityCritical => 'Critical';

  @override
  String get salesOrderNoRegisterTitle => 'No point of sale configured';

  @override
  String get salesOrderNoRegisterMessage =>
      'Your account has no point of sale assigned, so you cannot create new orders. Ask your administrator to configure one on your user.';

  @override
  String get salesOrderNoFacilityTitle => 'No facility configured';

  @override
  String get salesOrderNoFacilityMessage =>
      'Your account has no facility assigned, so orders cannot be listed. Ask your administrator to configure one on your user.';

  @override
  String get salesOrderConfirmAction => 'Confirm order';

  @override
  String get salesOrderNoLinesYet =>
      'Add at least one product before confirming the order.';

  @override
  String get salesOrderChooseCustomerFirst =>
      'Choose a customer to start the order.';

  @override
  String get salesOrderStepVenta => 'Sale';

  @override
  String get salesOrderStepEntrega => 'Delivery';

  @override
  String salesOrderStepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get salesOrderContinueToDeliveryAction => 'Continue to delivery';

  @override
  String get salesOrderCompleteDeliveryAction => 'Complete order';

  @override
  String get salesOrderForeignOrderTitle => 'This order cannot be edited here';

  @override
  String get salesOrderForeignOrderMessage =>
      'It was raised at the point of sale. Open it from Ventas instead.';

  @override
  String get salesOrdersEmptyMessage => 'No orders yet in this period.';

  @override
  String get salesOrderCancelAction => 'Cancel order';

  @override
  String get salesOrderCancelDialogTitle => 'Cancel this order?';

  @override
  String get salesOrderCancelDialogMessage =>
      'This cannot be undone. The order will be marked cancelled.';

  @override
  String get salesOrderCancelDialogKeepEditing => 'Keep editing';

  @override
  String get salesOrderCancelDialogConfirm => 'Cancel order';

  @override
  String get salesOrderSalespersonEveryone => 'Everyone';

  @override
  String get salesOrderCrossFacilityNotice =>
      'The order will be created in your own facility, regardless of the facility you are viewing.';

  @override
  String get cashSessionStatusOpen => 'Open';

  @override
  String get cashSessionStatusStale => 'Stale';

  @override
  String get cashSessionStatusClosed => 'Closed';

  @override
  String get cashSessionDrawerFieldLabel => 'Cash drawer';

  @override
  String get cashSessionCashierFieldLabel => 'Cashier';

  @override
  String get cashSessionStartFieldLabel => 'Start';

  @override
  String get cashSessionEndFieldLabel => 'End';

  @override
  String get cashSessionOpenButtonLabel => 'Open session';

  @override
  String get cashSessionOpeningAmountFieldLabel => 'Opening amount';

  @override
  String get cashSessionNoOpenSessionMessage =>
      'You have no open cash session.';

  @override
  String get cashSessionDrawerBlockedMessage =>
      'A cash drawer must be assigned to your user before you can open a session. Contact your administrator.';

  @override
  String get cashSessionDrawerBusyError =>
      'That cash drawer already has an open session. Choose a different drawer.';

  @override
  String get cashSessionCashierBusyError =>
      'You already have an open session. Close it before opening another.';

  @override
  String get cashSessionCloseButtonLabel => 'Close session';

  @override
  String get cashSessionShiftSheetTitle => 'Shift';

  @override
  String get cashSessionShiftButtonTooltip => 'Shift';

  @override
  String get cashSessionPaymentsByMethodLabel => 'Payments taken this shift';

  @override
  String get cashSessionStaleWarningMessage =>
      'This session was opened on an earlier day and must be closed before you can continue selling.';

  @override
  String get cashSessionOpenFailedError => 'Failed to open the cash session.';

  @override
  String get cashSessionOpenPermissionDeniedError =>
      'You no longer have permission to open a cash session.';

  @override
  String get cashSessionCountedTotalLabel => 'Counted total';

  @override
  String get cashSessionExpectedCashLabel => 'Expected cash';

  @override
  String get cashSessionDifferenceLabel => 'Difference';

  @override
  String get cashSessionDifferenceOver => 'Over';

  @override
  String get cashSessionDifferenceShort => 'Short';

  @override
  String get cashSessionDifferenceZero => 'Exact';

  @override
  String get cashSessionAdvisoryNote =>
      'Advisory only: the opening amount plus this shift\'s cash sales net of change given, minus expenses and cash refunds.';

  @override
  String get cashSessionEmptyCountConfirmTitle => 'Confirm empty drawer';

  @override
  String get cashSessionEmptyCountConfirmMessage =>
      'Every denomination is at zero. Confirm the drawer was counted and found empty before closing.';

  @override
  String get cashSessionConfirmEmptyCountButton => 'Confirm empty';

  @override
  String get cashSessionAlreadyClosedError => 'This session is already closed.';

  @override
  String get cashSessionSupervisorRequiredMessage =>
      'A user with closing rights must close this session.';

  @override
  String get cashSessionClosedByFieldLabel => 'Closed by';

  @override
  String get cashSessionQuantityInvalidError =>
      'Enter a valid, non-negative whole number for each denomination.';

  @override
  String get cashSessionSessionNotFoundError =>
      'This session no longer exists.';

  @override
  String get cashSessionCloseFailedError => 'Failed to close the cash session.';

  @override
  String get cashSessionClosePermissionDeniedError =>
      'You no longer have permission to close a cash session.';

  @override
  String get cashSessionCloseSuccessTitle => 'Session closed';

  @override
  String cashSessionCloseSuccessMessage(
    String counted,
    String expected,
    String difference,
  ) {
    return 'Counted $counted, expected $expected, difference $difference.';
  }

  @override
  String get cashSessionViewTitle => 'Cash session';

  @override
  String get cashSessionLoadFailedError => 'Failed to load the cash session.';

  @override
  String get okButton => 'OK';

  @override
  String get cashSessionsListEmptyMessage => 'No cash sessions found.';

  @override
  String get cashSessionsFilterDrawerLabel => 'Cash drawer';

  @override
  String get cashSessionsFilterCashierLabel => 'Cashier';

  @override
  String get cashSessionsFilterStatusLabel => 'Status';

  @override
  String get cashSessionColumnDrawer => 'Drawer';

  @override
  String get cashSessionColumnCashier => 'Cashier';

  @override
  String get cashSessionColumnStart => 'Start';

  @override
  String get cashSessionColumnEnd => 'End';

  @override
  String get cashSessionColumnStatus => 'Status';

  @override
  String get cashSessionOtherSessionsWarningMessage =>
      'You may have other open sessions that need attention. Check the history below.';

  @override
  String get posGateNoSessionTitle => 'No cash session is open';

  @override
  String get posGateNoSessionBody =>
      'You must open a cash session before starting a sale.';

  @override
  String get posGateOpenSessionAction => 'Go to cash sessions';

  @override
  String get posStaleSessionBanner => 'The cash session is stale.';

  @override
  String get posStepVenta => 'Sale';

  @override
  String get posStepCobro => 'Payment';

  @override
  String get posStepEntrega => 'Delivery';

  @override
  String get posSaleCompletedTitle => 'Sale completed';

  @override
  String posSaleReference(String reference) {
    return 'Reference #$reference';
  }

  @override
  String get posNewSaleAction => 'New sale';

  @override
  String get posCustomerLabel => 'Customer';

  @override
  String get posPaymentTermsImmediate => 'Cash';

  @override
  String get posPaymentTermsCredit => 'Credit';

  @override
  String get posFulfillmentCounter => 'In store';

  @override
  String get posFulfillmentDelivery => 'Delivery';

  @override
  String get posFulfillmentMixed => 'Mixed';

  @override
  String get posProductSearchLabel => 'Search or scan a product';

  @override
  String get posProductSearchNoResults => 'No results';

  @override
  String get posRemoveLineTooltip => 'Remove line';

  @override
  String get posLineQuantityLabel => 'Qty.';

  @override
  String posLineQuantityWithUnitLabel(String unit) {
    return 'Qty. ($unit)';
  }

  @override
  String get posLinePriceLabel => 'Price';

  @override
  String get posLineDiscountLabel => 'Disc. %';

  @override
  String get posLineTaxLabel => 'Tax %';

  @override
  String get posLineWarehouseLabel => 'Warehouse';

  @override
  String get posLineNoStock => 'No stock in this warehouse';

  @override
  String posLineShortfall(String available) {
    return 'Only $available available';
  }

  @override
  String get posLineAdjustToAvailable => 'Adjust to available';

  @override
  String get posLineWarehouseStockUnknown => 'Stock not checked';

  @override
  String posLineWarehouseStockShort(String available) {
    return 'Only $available left';
  }

  @override
  String get posLineWarehouseStockNone => 'No stock';

  @override
  String posTotalsCounts(int lines, String units, num unitsValue) {
    String _temp0 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines lines',
      one: '$lines line',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unitsValue,
      locale: localeName,
      other: 'units',
      one: 'unit',
    );
    return '$_temp0 · $units $_temp1';
  }

  @override
  String get posTotalsArticlesLabel => 'Items';

  @override
  String get posTotalsSubtotalLabel => 'Subtotal';

  @override
  String get posTotalsDiscountLabel => 'Discounts';

  @override
  String get posTotalsTaxLabel => 'Tax';

  @override
  String get posTotalsTotalLabel => 'Total';

  @override
  String get posSaleReadOnlyBanner =>
      'The sale is already confirmed; its details are read-only.';

  @override
  String get posSalesSearchLabel => 'Search sales';

  @override
  String get posSalesStatusFilterLabel => 'Status';

  @override
  String get posSalesStatusFilterAll => 'All statuses';

  @override
  String get posSalesNewSaleAction => 'New sale';

  @override
  String get posSalesColumnReference => 'Reference';

  @override
  String get posSalesColumnDate => 'Date';

  @override
  String get posSalesColumnCustomer => 'Customer';

  @override
  String get posSalesColumnStatus => 'Status';

  @override
  String get posSalesColumnTotal => 'Total';

  @override
  String get posSalesColumnBalance => 'Balance';

  @override
  String get posSalesEmptyToday => 'No sales on this register today';

  @override
  String get posSalesNoRegister => 'This account has no register assigned.';

  @override
  String get posSalesNewSaleBlockedNoSession =>
      'You must open a cash session before starting a sale.';

  @override
  String get dateRangeFilterToday => 'Today';

  @override
  String dateRangeFilterRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get dateRangeFilterClear => 'Back to today';

  @override
  String get posSaleStatusDraft => 'Capturing';

  @override
  String get posSaleStatusCompleted => 'Payment due';

  @override
  String get posSaleStatusPaid => 'Paid';

  @override
  String get posSaleStatusCancelled => 'Cancelled';

  @override
  String get posSaleUnreachableTitle => 'This sale can\'t be opened';

  @override
  String get posSaleUnreachableUnknown => 'This sale could not be found.';

  @override
  String get posSaleUnreachableCancelled =>
      'This sale was cancelled and can no longer be opened.';

  @override
  String get posSaleUnreachableOtherRegister =>
      'This sale belongs to a different register.';

  @override
  String get posSaleBackToListAction => 'Back to sales';

  @override
  String get posNoLinesHint => 'No lines — search or scan a product';

  @override
  String get posAmountLabel => 'Amount';

  @override
  String get posQuickAmountRemaining => 'Remaining';

  @override
  String get posQuickAmountHalf => 'Half';

  @override
  String get posPaymentTotal => 'Total';

  @override
  String get posPaymentPaid => 'Paid';

  @override
  String get posPaymentBalance => 'Remaining';

  @override
  String get posPaymentReferenceLabel => 'Reference';

  @override
  String get posPaymentChangeLabel => 'Change';

  @override
  String get posPaymentGateHint => 'Opens once the balance is settled';

  @override
  String get posPaymentMethodRequiresReference => 'Requires a reference';

  @override
  String get posPaymentMethodNoReference => 'No reference needed';

  @override
  String get posPaymentMethodSectionLabel => 'Payment method';

  @override
  String get posApplyPayment => 'Apply payment';

  @override
  String get posContinue => 'Continue';

  @override
  String get posAppliedPaymentsTitle => 'Applied payments';

  @override
  String get posNoAppliedPayments => 'No payments applied';

  @override
  String get posAppliedPaymentsLoadError =>
      'Applied payments could not be loaded';

  @override
  String posPaymentReferenceValue(String reference) {
    return 'Ref. $reference';
  }

  @override
  String get posPaymentPendingValidation => 'Pending validation';

  @override
  String get posPaymentCancelled => 'Cancelled';

  @override
  String get posReverseAction => 'Reverse';

  @override
  String get posReversePaymentTitle => 'Reverse payment';

  @override
  String get posReversalReasonLabel => 'Reason';

  @override
  String get posCustomerNameLabel => 'Customer';

  @override
  String get posCustomerPriceListLabel => 'Price list';

  @override
  String get posCustomerSearchAction => 'Search';

  @override
  String get posCustomerCreateAction => 'New';

  @override
  String get posCustomerSearchCancelAction => 'Cancel search';

  @override
  String get posCustomerNoCreditHint => 'No credit line';

  @override
  String get newContactDialogTitle => 'New contact';

  @override
  String get contactNameLabel => 'Name';

  @override
  String get contactMobileLabel => 'Mobile';

  @override
  String get contactPhoneLabel => 'Phone';

  @override
  String get contactJobTitleLabel => 'Job title';

  @override
  String get contactEmailLabel => 'Email';

  @override
  String get contactMethodRequired => 'Enter a mobile or a phone number.';

  @override
  String get posDeliveryAddressTitle => 'Delivery address';

  @override
  String get posDeliveryContactTitle => 'Contact';

  @override
  String get posNoAddressesOnFile => 'This customer has no addresses on file.';

  @override
  String get posNoContactsOnFile => 'This customer has no contacts on file.';

  @override
  String get posNewAddressAction => 'New address';

  @override
  String get posNewContactAction => 'New contact';

  @override
  String get posDeliveryNotPermitted =>
      'This customer is not set up to receive deliveries.';

  @override
  String get posGenericCustomerResetToPickup =>
      'This customer cannot receive deliveries — the sale was switched to counter pickup.';

  @override
  String get posCounterPickupRemainder => 'Collected at the counter';

  @override
  String get posDeliveryAddressPending => 'Address pending';

  @override
  String posDestinationCounts(int lines, String units) {
    return '$lines lines · $units units';
  }

  @override
  String get posRemoveDestination => 'Remove destination';

  @override
  String get posRemoveDestinationReason =>
      'Removed by the cashier during capture';

  @override
  String get posDistributionTitle => 'Distribution';

  @override
  String posDistributionOrdered(String quantity) {
    return 'Ordered: $quantity';
  }

  @override
  String posDistributionAssigned(String quantity) {
    return 'Assigned: $quantity';
  }

  @override
  String posDistributionAtCounter(String quantity) {
    return 'At counter: $quantity';
  }

  @override
  String posDistributionClaimable(String quantity) {
    return 'Available: $quantity';
  }

  @override
  String get posDistributionOverClaimed => 'More than is left';

  @override
  String get posDistributionClaimAll => 'Take everything left';

  @override
  String posDestinationBadge(int ordinal) {
    return 'D$ordinal';
  }

  @override
  String get posDeliveryDestinationsTitle => 'Delivery destinations';

  @override
  String posDistributionRailSubtitle(int lines, int destinations) {
    return '$lines lines · $destinations destinations';
  }

  @override
  String posDeliveryAssignedUnits(String assigned, String total) {
    return '$assigned / $total units assigned';
  }

  @override
  String get posDestinationLinesTitle =>
      'Quantity to deliver from this destination';

  @override
  String get posAddDestinationSheetTitle => 'Delivery details';

  @override
  String get posEditDestinationSheetTitle => 'Edit destination';

  @override
  String get posUnconfirmedChangesTitle => 'Unconfirmed changes';

  @override
  String get posUnconfirmedChangesBody =>
      'There are typed values that were never confirmed. What would you like to do?';

  @override
  String get posUnconfirmedChangesKeep => 'Keep';

  @override
  String get posUnconfirmedChangesDiscard => 'Discard';

  @override
  String get posUnconfirmedChangesKeepEditing => 'Keep editing';

  @override
  String get posCounterPickupLinesTitle => 'Quantity staying at the store';

  @override
  String posDestinationCounterChip(String units) {
    return 'Counter $units';
  }

  @override
  String posDeliveryAssignmentRefused(String reason) {
    return 'Couldn\'t assign: $reason';
  }

  @override
  String get posAddDestinationNothingLeft => 'Nothing left to assign';

  @override
  String get posDeliverRestAtCounter => 'Leave the rest at the counter';

  @override
  String get posDeliveryDateLabel => 'Delivery date';

  @override
  String get posDeliveryInstructions => 'Delivery instructions';

  @override
  String get posAddDestination => 'Add destination';

  @override
  String get posNoDestinationsYet => 'No destinations yet — add the first one.';

  @override
  String posDeliveryOutstanding(String lines) {
    return 'Still unassigned: $lines';
  }

  @override
  String get posFinishSale => 'Finish sale';

  @override
  String get posCustomerBalanceLabel => 'Balance';

  @override
  String get posNoOpenSales => 'No other open sales';

  @override
  String posOpenSalesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open',
      one: '1 open',
    );
    return '$_temp0';
  }

  @override
  String get posOpenSaleDraft => 'In progress';

  @override
  String get posOpenSaleUndelivered => 'Awaiting delivery';

  @override
  String get posCreateCustomerAction => 'Create customer';

  @override
  String posStepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get posLineDecreaseQuantity => 'Decrease quantity';

  @override
  String get posLineIncreaseQuantity => 'Increase quantity';

  @override
  String get numberPadBackspace => 'Backspace';

  @override
  String get dismissErrorTooltip => 'Dismiss';

  @override
  String posOpenSaleId(int id) {
    return 'Id $id';
  }

  @override
  String posOpenSaleSerial(int serial) {
    return 'Serial $serial';
  }

  @override
  String get taxpayerRecipientFieldLabel => 'Tax recipient (RFC)';

  @override
  String get userProfilesMenuTitle => 'User Profiles';

  @override
  String get newUserProfileTooltip => 'New profile';

  @override
  String get userProfilesSearchLabel => 'Search by name';

  @override
  String get noUserProfilesYetMessage =>
      'No user profiles yet — create the first one.';

  @override
  String get columnProfileName => 'Name';

  @override
  String get columnProfile => 'Profile';

  @override
  String get columnProfileDescription => 'Description';

  @override
  String get newUserProfileTitle => 'New Profile';

  @override
  String get editUserProfileTitle => 'Edit Profile';

  @override
  String get viewUserProfileTitle => 'View Profile';

  @override
  String get userProfileNameFieldLabel => 'Name';

  @override
  String get userProfileDescriptionFieldLabel => 'Description';

  @override
  String get userProfileNameRequiredError => 'Name is required.';

  @override
  String get userProfileLoadFailedError => 'Could not load the profile.';

  @override
  String get userProfileSaveFailedError => 'Could not save the profile.';

  @override
  String get userProfileDeleteFailedError => 'Could not delete the profile.';

  @override
  String get deleteUserProfileTooltip => 'Delete profile';

  @override
  String get deleteUserProfileConfirmTitle => 'Delete profile?';

  @override
  String deleteUserProfileConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get userProfilePickerLabel => 'Profile';

  @override
  String get applyProfileButtonLabel => 'Apply profile';

  @override
  String get applyProfileDialogTitle => 'Apply Profile';

  @override
  String get applyProfileReplaceWarning =>
      'This replaces every permission this account currently holds.';

  @override
  String get applyProfileSessionWarning =>
      'The account\'s active sessions will end and it must sign in again.';

  @override
  String get applyProfileSelfWarning =>
      'This is your own account — your own session will end too.';

  @override
  String get applyProfileConfirmLabel => 'Apply';

  @override
  String get applyProfileSuccessMessage => 'Profile applied.';

  @override
  String get userFormApplyFailedError => 'Could not apply the profile.';

  @override
  String userProvisionedFromLabel(String profileName) {
    return 'Provisioned from $profileName';
  }

  @override
  String get recordSheetDiscardTitle => 'Discard unsaved changes?';

  @override
  String get recordSheetDiscardBody =>
      'Your changes to this record have not been saved.';

  @override
  String get recordSheetDiscardConfirm => 'Discard';

  @override
  String get recordSheetDiscardCancel => 'Keep editing';

  @override
  String get documentPrintAction => 'Print';

  @override
  String get documentDownloadAction => 'Download';

  @override
  String get documentLoadingMessage => 'Loading document…';

  @override
  String get documentLoadFailedError => 'The document could not be loaded.';

  @override
  String get documentCloseTooltip => 'Close';

  @override
  String get documentZoomOutTooltip => 'Zoom out';

  @override
  String get documentZoomInTooltip => 'Zoom in';

  @override
  String get documentZoomFitTooltip => 'Fit to width';

  @override
  String documentPageIndicator(String current, String total) {
    return 'Page $current / $total';
  }

  @override
  String documentTicketTitle(String reference) {
    return 'Ticket · Reference #$reference';
  }

  @override
  String documentSalesOrderTitle(String reference) {
    return 'Sales order · $reference';
  }

  @override
  String documentCashCutTitle(String reference) {
    return 'Cash cut · $reference';
  }

  @override
  String documentSalesQuoteTitle(String reference) {
    return 'Quote · $reference';
  }

  @override
  String get posSalePrintTicketAction => 'Print ticket';

  @override
  String get posSalePrintTicketError => 'The ticket could not be printed.';

  @override
  String get cashSessionViewCutAction => 'View cut';

  @override
  String get posSaleViewTicketTooltip => 'View ticket';

  @override
  String get salesOrderViewDocumentAction => 'View sales order';

  @override
  String get salesQuoteViewDocumentAction => 'View quote';

  @override
  String get salesQuoteEmailAction => 'Send by email';

  @override
  String get salesQuoteMoreActionsTooltip => 'More actions';

  @override
  String salesQuoteEmailDialogTitle(String reference) {
    return 'Send quote $reference';
  }

  @override
  String get salesQuoteEmailRecipientsLabel => 'Recipients';

  @override
  String get salesQuoteEmailOtherAddressLabel => 'Another email address';

  @override
  String get salesQuoteEmailAddAction => 'Add';

  @override
  String get salesQuoteEmailSendAction => 'Send';

  @override
  String get salesQuoteEmailSendingLabel => 'Sending…';

  @override
  String get salesQuoteEmailLimitHint => 'Up to 10 recipients.';

  @override
  String salesQuoteEmailCounter(int count) {
    return '$count of 10 recipients.';
  }

  @override
  String get salesQuoteEmailLimitReached =>
      '10 of 10 recipients. No more can be added.';

  @override
  String get salesQuoteEmailInvalidAddress =>
      'That is not a valid email address.';

  @override
  String get salesQuoteEmailNoKnownAddresses =>
      'This customer has no email addresses on file.';

  @override
  String get salesQuoteEmailSuggestionsLoading =>
      'Loading the customer\'s email addresses…';

  @override
  String get salesQuoteEmailSuggestionsFailed =>
      'The customer\'s email addresses could not be loaded.';

  @override
  String get salesQuoteEmailNotSendable => 'This quote can no longer be sent.';

  @override
  String get salesQuoteEmailMailRefused =>
      'The mail server rejected the message. Try again, or download the quote instead.';

  @override
  String get salesQuoteEmailMailUnavailable =>
      'Sending email is not available. Download the quote to send it yourself.';

  @override
  String salesQuoteEmailSentMessage(String recipients) {
    return 'Quote sent to $recipients';
  }

  @override
  String get customerAddressesSection => 'Addresses';

  @override
  String get customerContactsSection => 'Contacts';

  @override
  String get customerTaxpayersSection => 'Tax recipients';

  @override
  String get customerAddressesEmpty => 'No addresses linked.';

  @override
  String get customerContactsEmpty => 'No contacts linked.';

  @override
  String get customerTaxpayersEmpty => 'No tax recipients linked.';

  @override
  String get customerAddressLinkLabel => 'Link an existing address';

  @override
  String get customerContactLinkLabel => 'Link an existing contact';

  @override
  String get customerTaxpayerLinkLabel => 'Link an existing tax recipient';

  @override
  String get linkedRecordUnlinkTooltip => 'Unlink';

  @override
  String get linkedRecordNewAction => 'New';

  @override
  String customerGenericTaxpayerNote(String rfc) {
    return 'This is the walk-in customer: its only tax recipient is $rfc (general public), and nothing else can be linked to it.';
  }

  @override
  String get posSessionExpiredRedirect =>
      'Your cash session has expired. Close it to keep selling.';

  @override
  String get posSessionExpiredPaymentsBlocked =>
      'The cash session has expired. Close it to take payments.';

  @override
  String get posSessionCloseAction => 'Close session';

  @override
  String posCaptureShortLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines without enough stock',
      one: '1 line without enough stock',
    );
    return '$_temp0';
  }

  @override
  String get posWarehousePickerTitle => 'Warehouse';

  @override
  String get posWarehousePickerNotTracked =>
      'This product is not stock-tracked, so any warehouse is valid.';

  @override
  String get posPaymentAmountRequired => 'Enter an amount greater than zero.';

  @override
  String get posPaymentOverpayNonCash => 'Only cash can exceed the balance.';

  @override
  String get posPaymentSessionInvalid =>
      'The cash session is no longer valid. Close it and open a new one to take payments.';

  @override
  String get posPaymentChangeDue => 'Change to hand back';

  @override
  String get posPaymentDismissChange => 'Dismiss';

  @override
  String get posPaymentReferenceTitle => 'Payment reference';

  @override
  String get posPaymentReferenceConfirm => 'Apply payment';

  @override
  String posCaptureUnknownStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines with unverified stock',
      one: '1 line with unverified stock',
    );
    return '$_temp0';
  }

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get passwordMismatchError => 'Passwords don\'t match';

  @override
  String get posSaleDetailTitle => 'View sale';

  @override
  String get posSaleDetailDateLabel => 'Date';

  @override
  String get posSaleDetailRegisterLabel => 'Register';

  @override
  String get posSaleDetailPaymentsForbidden =>
      'You don\'t have permission to see this sale\'s payments.';

  @override
  String get posPaymentDateLabel => 'Payment date';

  @override
  String get posWarehousePickerOtherFacilities => 'Other facilities';

  @override
  String get posWarehousePickerOtherNone =>
      'Not available in other facilities.';

  @override
  String passwordRuleMinLength(int count) {
    return 'At least $count characters';
  }

  @override
  String get passwordRuleUpper => 'An uppercase letter';

  @override
  String get passwordRuleLower => 'A lowercase letter';

  @override
  String get passwordRuleDigit => 'A number';

  @override
  String get passwordRuleSymbol => 'A symbol';

  @override
  String get passwordRulesUnavailable =>
      'The password rules couldn\'t be loaded. The server will check your password.';

  @override
  String get passwordRequiredTitle => 'Change your password';

  @override
  String get passwordRequiredExplanation =>
      'An administrator set your password. Choose a new one to continue.';

  @override
  String get supplierAddressesSection => 'Addresses';

  @override
  String get supplierAddressesEmpty => 'This supplier has no addresses.';

  @override
  String get supplierContactsSection => 'Contacts';

  @override
  String get supplierContactsEmpty => 'This supplier has no contacts.';

  @override
  String get supplierBankAccountsSection => 'Bank accounts';

  @override
  String get supplierBankAccountsEmpty => 'This supplier has no bank accounts.';

  @override
  String get supplierAgreementsSection => 'Agreements';

  @override
  String get supplierAgreementsEmpty => 'This supplier has no agreements.';

  @override
  String get supplierAgreementsAfterSaveNote =>
      'You can add agreements after saving the supplier.';

  @override
  String get supplierAgreementColumnStart => 'Start';

  @override
  String get supplierAgreementColumnEnd => 'End';

  @override
  String get supplierAgreementColumnNotes => 'Notes';

  @override
  String get supplierAddressLinkLabel => 'Link an existing address';

  @override
  String get supplierContactLinkLabel => 'Link an existing contact';

  @override
  String get supplierBankAccountLinkLabel => 'Link an existing bank account';

  @override
  String get newBankAccountDialogTitle => 'New bank account';

  @override
  String get bankAccountBankNameLabel => 'Bank';

  @override
  String get bankAccountNumberLabel => 'Account number';

  @override
  String get bankAccountReferenceLabel => 'Reference';

  @override
  String get bankAccountRoutingLabel => 'CLABE / routing';

  @override
  String bankAccountFieldTooLongError(int max) {
    return 'Must be at most $max characters.';
  }

  @override
  String get bankAccountCreateFailedError =>
      'Could not create the bank account.';

  @override
  String get addAgreementButton => 'Add agreement';

  @override
  String get newAgreementDialogTitle => 'New agreement';

  @override
  String get editAgreementDialogTitle => 'Edit agreement';

  @override
  String get supplierAgreementEndBeforeStartError =>
      'The end date cannot be before the start date.';

  @override
  String agreementCommentTooLongError(int max) {
    return 'Notes must be at most $max characters.';
  }

  @override
  String get deleteAgreementButton => 'Delete';

  @override
  String get deleteAgreementConfirmTitle => 'Delete agreement?';

  @override
  String deleteAgreementConfirmMessage(String start, String end) {
    return 'This will delete the agreement from $start to $end. This cannot be undone.';
  }

  @override
  String get agreementSaveFailedError => 'Could not save the agreement.';

  @override
  String get agreementDeleteFailedError => 'Could not delete the agreement.';

  @override
  String get customerDiscountsSection => 'Discounts';

  @override
  String get customerDiscountsEmpty => 'No product discounts.';

  @override
  String get customerDiscountsAfterSaveNote =>
      'Discounts can be added once the customer is saved.';

  @override
  String get customerDiscountColumnCode => 'Code';

  @override
  String get customerDiscountColumnProduct => 'Product';

  @override
  String get customerDiscountColumnDiscount => 'Discount';

  @override
  String get newCustomerDiscountDialogTitle => 'New discount';

  @override
  String get customerDiscountProductLabel => 'Product';

  @override
  String get customerDiscountPercentLabel => 'Discount (%)';

  @override
  String get customerDiscountPercentRequiredError => 'Enter a percentage.';

  @override
  String get customerDiscountPercentInvalidError =>
      'Enter a number, e.g. 12.5.';

  @override
  String get customerDiscountPercentOutOfRangeError =>
      'Must be between 0 and 100.';

  @override
  String get customerDiscountPercentTooPreciseError =>
      'At most 6 decimal places.';

  @override
  String get customerDiscountDuplicateError =>
      'This customer already has a discount on that product.';

  @override
  String get customerDiscountProductMissingError =>
      'The product no longer exists.';

  @override
  String get customerDiscountSaveFailedError =>
      'The discount could not be saved.';

  @override
  String get editCustomerDiscountDialogTitle => 'Edit discount';

  @override
  String get customerDiscountMissingError => 'This discount no longer exists.';

  @override
  String get customerDiscountDeleteFailedError =>
      'The discount could not be removed.';

  @override
  String get deleteCustomerDiscountButton => 'Remove';

  @override
  String get deleteCustomerDiscountConfirmTitle => 'Remove discount';

  @override
  String deleteCustomerDiscountConfirmMessage(String code, String name) {
    return 'Remove the discount on $code — $name? Lines already entered keep their discount.';
  }

  @override
  String get customerDiscountChangeProductTooltip => 'Change product';

  @override
  String get paymentsMenuTitle => 'Payments';

  @override
  String get paymentTypeNa => 'N/A';

  @override
  String get paymentTypeImmediate => 'Cash sale';

  @override
  String get paymentTypeCreditPayment => 'Credit payment';

  @override
  String get paymentTypePaymentInAdvance => 'Payment in advance';

  @override
  String get paymentTypeCreditNote => 'Credit note';

  @override
  String get paymentTypeExpense => 'Expense';

  @override
  String get paymentVerified => 'Verified';

  @override
  String get paymentUnverified => 'Unverified';

  @override
  String get paymentApplicationReversed => 'Reversed';

  @override
  String get paymentsColumnFolio => 'No.';

  @override
  String get paymentsColumnDate => 'Date';

  @override
  String get paymentsColumnCustomer => 'Customer';

  @override
  String get paymentsColumnAmount => 'Amount';

  @override
  String get paymentsColumnMethod => 'Payment method';

  @override
  String get paymentsColumnReference => 'Reference';

  @override
  String get paymentsColumnType => 'Type';

  @override
  String get paymentsColumnUnapplied => 'Unapplied';

  @override
  String get paymentsColumnVerified => 'Verified';

  @override
  String get paymentsFilterCustomer => 'Customer';

  @override
  String get paymentsFilterDate => 'Date';

  @override
  String get paymentsFilterMethod => 'Payment method';

  @override
  String get paymentsFilterMethodAll => 'All';

  @override
  String get paymentsFilterVerified => 'Verification';

  @override
  String get paymentsVerifiedAny => 'All';

  @override
  String get paymentsVerifiedYes => 'Verified';

  @override
  String get paymentsVerifiedNo => 'Unverified';

  @override
  String get paymentsFilterCashSession => 'Cash session';

  @override
  String get paymentsListEmpty => 'There are no payments yet.';

  @override
  String get dateRangeFilterAny => 'Any date';

  @override
  String get paymentViewTitle => 'View payment';

  @override
  String paymentHeaderTitle(int id) {
    return 'Payment $id';
  }

  @override
  String get paymentSummaryAmount => 'Amount';

  @override
  String get paymentSummaryApplied => 'Applied';

  @override
  String get paymentSummaryUnapplied => 'Unapplied';

  @override
  String get paymentFieldPaymentOption => 'Payment option';

  @override
  String get paymentFieldFacility => 'Facility';

  @override
  String get paymentFieldCashSession => 'Cash session';

  @override
  String get paymentFieldVerifier => 'Verified by';

  @override
  String get paymentFieldLastRejection => 'Last rejection';

  @override
  String get paymentRejected => 'Rejected';

  @override
  String get paymentVerificationFilterRejected => 'Rejections';

  @override
  String get paymentVerificationRejectedAny => 'All';

  @override
  String get paymentVerificationRejectedYes => 'Rejected';

  @override
  String get paymentVerificationRejectedNo => 'Never rejected';

  @override
  String get paymentApplicationsTitle => 'Applications';

  @override
  String get paymentApplicationsEmpty =>
      'This payment hasn\'t been applied to any order.';

  @override
  String get paymentApplicationsColumnOrder => 'Order';

  @override
  String get paymentApplicationsColumnApplied => 'Applied';

  @override
  String get paymentApplicationsColumnChange => 'Change';

  @override
  String get paymentApplicationsColumnApplier => 'Applied by';

  @override
  String get paymentApplicationsColumnDate => 'Date';

  @override
  String get paymentApplicationsColumnStatus => 'Status';

  @override
  String paymentNotFound(int id) {
    return 'Payment $id doesn\'t exist.';
  }

  @override
  String get paymentBackToList => 'Back to Payments';

  @override
  String get paymentsScopeFacility => 'This facility';

  @override
  String get paymentsScopeAll => 'All facilities';

  @override
  String get paymentsSearchReferenceHint => 'Search reference…';

  @override
  String get paymentsColumnFacility => 'Facility';

  @override
  String get paymentsSearchCustomerHint => 'Search customer…';

  @override
  String get paymentsListForbidden =>
      'You aren\'t allowed to see these payments.';

  @override
  String get paymentViewTicketTooltip => 'View ticket';

  @override
  String get paymentViewTicketAction => 'View ticket';

  @override
  String documentPaymentTicketTitle(int id) {
    return 'Payment ticket · #$id';
  }

  @override
  String documentRefundReceiptTitle(int id) {
    return 'Refund receipt · #$id';
  }

  @override
  String get creditNotesMenuTitle => 'Credit notes';

  @override
  String get creditNotesColumnDate => 'Date';

  @override
  String get creditNotesColumnCustomer => 'Customer';

  @override
  String get creditNotesColumnOrigin => 'Origin';

  @override
  String get creditNotesColumnIssued => 'Issued';

  @override
  String get creditNotesColumnRemaining => 'Balance';

  @override
  String creditNotesOrigin(int refund, int order) {
    return 'Refund #$refund · Order #$order';
  }

  @override
  String get creditNotesOpenOnlyFilter => 'Only spendable';

  @override
  String get creditNotesCustomerFilter => 'Customer';

  @override
  String get creditNotesEmpty => 'There are no credit notes.';

  @override
  String get creditNotesForbidden => 'You don\'t have access to credit notes.';

  @override
  String get paymentCreditNoteTile => 'Credit note';

  @override
  String paymentCreditNoteBalance(String amount) {
    return 'Balance $amount';
  }

  @override
  String get paymentCreditNoteRedeemTile => 'Redeem credit note';

  @override
  String get paymentCreditNoteRedeemHint => 'Scan the ticket';

  @override
  String paymentCreditPartlyApplied(String amount) {
    return '$amount of credit was applied; the rest could not be applied.';
  }

  @override
  String appliedPaymentCreditNoteNumber(int number) {
    return 'No. $number';
  }

  @override
  String get creditNoteTicketTitle => 'Redeem credit note';

  @override
  String get creditNoteTicketInput => 'Ticket number';

  @override
  String get creditNoteTicketHelp =>
      'Scan the ticket\'s barcode or type the number.';

  @override
  String get creditNoteTicketSearching => 'Searching…';

  @override
  String get creditNoteTicketConfirm => 'Apply';

  @override
  String creditNoteTicketHeading(int number, String date) {
    return 'Credit note No. $number · $date';
  }

  @override
  String creditNoteTicketAvailable(String amount) {
    return 'Available balance $amount';
  }

  @override
  String creditNoteTicketWillApply(String amount) {
    return 'Will apply $amount';
  }

  @override
  String get creditNoteNotFound =>
      'No credit note has that number at this store.';

  @override
  String get creditNoteUsedUp => 'This credit note has been fully used.';

  @override
  String get creditNoteAlreadyOnSale =>
      'This credit note is already applied to this sale.';

  @override
  String creditNoteOtherCustomer(String name) {
    return 'This credit note belongs to $name. Make the sale out to them to use it.';
  }

  @override
  String get refundsMenuTitle => 'Refunds';

  @override
  String get refundsColumnNumber => 'No.';

  @override
  String get refundsColumnDate => 'Date';

  @override
  String get refundsColumnCustomer => 'Customer';

  @override
  String get refundsColumnOrder => 'Order';

  @override
  String get refundsColumnStatus => 'Status';

  @override
  String get refundsColumnTotal => 'Total';

  @override
  String get refundsFilterStatus => 'Status';

  @override
  String get refundsFilterOrder => 'Order';

  @override
  String get refundsSearchHint => 'Folio, order or customer…';

  @override
  String get refundsFilterMine => 'Only my refunds';

  @override
  String get refundsFilterAll => 'All';

  @override
  String get refundsFilterOpen => 'Open';

  @override
  String get refundsFilterConfirmed => 'Confirmed';

  @override
  String get refundsFilterCancelled => 'Cancelled';

  @override
  String get refundStatusDraft => 'Open';

  @override
  String get refundStatusCompleted => 'Confirmed';

  @override
  String get refundStatusCancelled => 'Cancelled';

  @override
  String get refundsNew => 'New refund';

  @override
  String get refundsNewShort => 'New';

  @override
  String get refundsEmpty => 'There are no refunds.';

  @override
  String get refundsForbidden => 'You do not have permission to view refunds.';

  @override
  String get refundsLoadError => 'The refunds could not be loaded.';

  @override
  String get refundNewOrderLabel => 'Order number';

  @override
  String get refundNewContinue => 'Continue';

  @override
  String refundRefusalOrderNotFound(int n) {
    return 'Order $n does not exist.';
  }

  @override
  String refundRefusalNotCompleted(int n) {
    return 'Order $n is not confirmed.';
  }

  @override
  String refundRefusalNotPaid(int n) {
    return 'Order $n is not paid. Cancel it instead of refunding it.';
  }

  @override
  String refundRefusalNothingToReturn(int n) {
    return 'Order $n has nothing left to return.';
  }

  @override
  String get refundAction => 'Refund';

  @override
  String get refundDetailTitle => 'Refund';

  @override
  String refundDetailTitleWithNumber(int n) {
    return 'Refund $n';
  }

  @override
  String get refundFieldNumber => 'Folio';

  @override
  String get refundFieldDate => 'Date';

  @override
  String get refundFieldCustomer => 'Customer';

  @override
  String get refundFieldOrder => 'Order';

  @override
  String get refundFieldStatus => 'Status';

  @override
  String get refundDraftNumber => 'Draft';

  @override
  String get refundNoValue => '—';

  @override
  String get refundColumnProduct => 'Product';

  @override
  String get refundColumnPrice => 'Price';

  @override
  String get refundColumnDiscount => 'Disc.';

  @override
  String get refundColumnTax => 'VAT';

  @override
  String get refundColumnRefundable => 'Refundable';

  @override
  String get refundColumnRefundableShort => 'Refundable';

  @override
  String get refundColumnReturn => 'Return';

  @override
  String get refundColumnReturned => 'Returned';

  @override
  String get refundColumnWarehouse => 'Warehouse';

  @override
  String get refundColumnTotal => 'Total';

  @override
  String get refundSubtotal => 'Subtotal';

  @override
  String get refundTax => 'VAT';

  @override
  String get refundTotal => 'Total';

  @override
  String refundNotFound(int id) {
    return 'Refund $id does not exist.';
  }

  @override
  String get refundConfirmAction => 'Confirm refund';

  @override
  String get refundCancelAction => 'Cancel refund';

  @override
  String get refundCancelPrompt =>
      'The refund will be cancelled and can no longer be edited.';

  @override
  String refundConfirmDialogTotal(String total) {
    return '$total will be returned to the customer.';
  }

  @override
  String get refundPayoutCash => 'Cash from the drawer';

  @override
  String get refundPayoutCreditNote => 'Credit note';

  @override
  String get refundConfirmBack => 'Back';

  @override
  String get refundConfirmSubmit => 'Confirm';

  @override
  String get refundSessionBanner =>
      'Open a cash session to confirm the refund.';

  @override
  String get refundSessionOpenAction => 'Go to cash sessions';

  @override
  String get refundSessionStaleAction => 'Close previous session';

  @override
  String get refundPayoutLineLabel => 'Refund method';

  @override
  String get refundPayoutLineCash => 'Paid in cash';

  @override
  String refundPayoutLineCreditNote(int n) {
    return 'Credit note No. $n';
  }

  @override
  String get refundPayoutLineUnknown => 'Refund method not available';

  @override
  String get refundAdjustedBanner =>
      'Some quantities were adjusted because another refund was confirmed first.';

  @override
  String get refundNeedsConfirmerHint =>
      'Someone with permission to confirm must finish this refund.';

  @override
  String apiResourceCashDrawer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cash drawers',
      one: 'cash drawer',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCashDrawer => 'feminine';

  @override
  String apiResourceCashSession(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cash sessions',
      one: 'cash session',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCashSession => 'feminine';

  @override
  String apiResourceCreditNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'credit notes',
      one: 'credit note',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCreditNote => 'feminine';

  @override
  String apiResourceCustomer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'customers',
      one: 'customer',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomer => 'masculine';

  @override
  String apiResourceCustomerDiscount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'customer discounts',
      one: 'customer discount',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerDiscount => 'masculine';

  @override
  String apiResourceCustomerPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'payments',
      one: 'payment',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerPayment => 'masculine';

  @override
  String apiResourceCustomerRefund(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'refunds',
      one: 'refund',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerRefund => 'feminine';

  @override
  String apiResourceDeliveryItinerary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'itineraries',
      one: 'itinerary',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderDeliveryItinerary => 'masculine';

  @override
  String apiResourceDeliveryOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'delivery orders',
      one: 'delivery order',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderDeliveryOrder => 'feminine';

  @override
  String apiResourceDeliveryOrderLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'delivery lines',
      one: 'delivery line',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderDeliveryOrderLine => 'feminine';

  @override
  String apiResourceEmployee(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'employees',
      one: 'employee',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderEmployee => 'masculine';

  @override
  String apiResourceExchangeRate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'exchange rates',
      one: 'exchange rate',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderExchangeRate => 'masculine';

  @override
  String apiResourceExpense(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'expenses',
      one: 'expense',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderExpense => 'masculine';

  @override
  String apiResourceExpenseVoucher(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'expense vouchers',
      one: 'expense voucher',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderExpenseVoucher => 'masculine';

  @override
  String apiResourceFacility(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'facilities',
      one: 'facility',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderFacility => 'feminine';

  @override
  String apiResourceFiscalDocument(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'invoices',
      one: 'invoice',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderFiscalDocument => 'feminine';

  @override
  String apiResourceInventoryIssue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'warehouse issues',
      one: 'warehouse issue',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderInventoryIssue => 'feminine';

  @override
  String apiResourceInventoryReceipt(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'warehouse receipts',
      one: 'warehouse receipt',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderInventoryReceipt => 'feminine';

  @override
  String apiResourceInventoryTransfer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'transfers',
      one: 'transfer',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderInventoryTransfer => 'masculine';

  @override
  String apiResourceLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'labels',
      one: 'label',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderLabel => 'feminine';

  @override
  String apiResourcePaymentMethodOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'payment methods',
      one: 'payment method',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderPaymentMethodOption => 'feminine';

  @override
  String apiResourcePointOfSale(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'points of sale',
      one: 'point of sale',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderPointOfSale => 'masculine';

  @override
  String apiResourcePriceList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'price lists',
      one: 'price list',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderPriceList => 'feminine';

  @override
  String apiResourceProduct(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'products',
      one: 'product',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderProduct => 'masculine';

  @override
  String apiResourceProductPrice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'prices',
      one: 'price',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderProductPrice => 'masculine';

  @override
  String apiResourcePurchaseOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'purchase orders',
      one: 'purchase order',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderPurchaseOrder => 'feminine';

  @override
  String apiResourceSalesOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'orders',
      one: 'order',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesOrder => 'masculine';

  @override
  String apiResourceSalesOrderLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'order lines',
      one: 'order line',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesOrderLine => 'feminine';

  @override
  String apiResourceSalesOrderPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'order payments',
      one: 'order payment',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesOrderPayment => 'masculine';

  @override
  String apiResourceSalesQuote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quotes',
      one: 'quote',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesQuote => 'feminine';

  @override
  String apiResourceSalesQuoteLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quote lines',
      one: 'quote line',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSalesQuoteLine => 'feminine';

  @override
  String apiResourceStockMovement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'stock movements',
      one: 'stock movement',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderStockMovement => 'masculine';

  @override
  String apiResourceSupplier(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'suppliers',
      one: 'supplier',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplier => 'masculine';

  @override
  String apiResourceSupplierPayment(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'supplier payments',
      one: 'supplier payment',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierPayment => 'masculine';

  @override
  String apiResourceTaxpayerCertificate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'certificates',
      one: 'certificate',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderTaxpayerCertificate => 'masculine';

  @override
  String apiResourceTaxpayerIssuer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'issuers',
      one: 'issuer',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderTaxpayerIssuer => 'masculine';

  @override
  String apiResourceTaxpayerRecipient(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipients',
      one: 'recipient',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderTaxpayerRecipient => 'masculine';

  @override
  String apiResourceUser(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'users',
      one: 'user',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderUser => 'masculine';

  @override
  String apiResourceUserProfile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'profiles',
      one: 'profile',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderUserProfile => 'masculine';

  @override
  String apiResourceVehicle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vehicles',
      one: 'vehicle',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderVehicle => 'masculine';

  @override
  String apiResourceVehicleOperator(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vehicle operators',
      one: 'vehicle operator',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderVehicleOperator => 'masculine';

  @override
  String apiResourceWarehouse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'warehouses',
      one: 'warehouse',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderWarehouse => 'masculine';

  @override
  String apiResourceGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'records',
      one: 'record',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderGeneric => 'masculine';

  @override
  String get apiErrorAuthAdministratorRequired =>
      'Only administrators can do this.';

  @override
  String get apiErrorAuthForbidden =>
      'You don\'t have permission for this action.';

  @override
  String get apiErrorAuthIncorrectCurrentPassword =>
      'The current password is incorrect.';

  @override
  String get apiErrorAuthInvalidCredentials => 'Invalid username or password.';

  @override
  String get apiErrorAuthNotAuthenticated =>
      'Your session has expired. Sign in again.';

  @override
  String get apiErrorAuthPasswordChangeRequired =>
      'You must change your password before continuing.';

  @override
  String get apiErrorAuthRecoveryTokenInvalid =>
      'This recovery link is invalid or has expired. Request a new one.';

  @override
  String get apiErrorRequestMalformed =>
      'The app sent a request the server couldn\'t read. Try again.';

  @override
  String get apiErrorRequestMethodNotAllowed =>
      'The server doesn\'t allow this operation here.';

  @override
  String get apiErrorRequestRouteNotFound =>
      'The server doesn\'t offer this function. The app may need an update.';

  @override
  String get apiErrorResourceConflict =>
      'The change conflicts with existing data. Reload and try again.';

  @override
  String get apiErrorServerError =>
      'Something went wrong on the server. Try again later.';

  @override
  String get apiErrorStateTransitionInvalid =>
      'This record can\'t change from its current status to the one requested.';

  @override
  String apiErrorResourceNotFound(String gender, String resource) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine': 'Couldn\'t find the $resource. It may have been deleted.',
      'other': 'Couldn\'t find the $resource. It may have been deleted.',
    });
    return '$_temp0';
  }

  @override
  String apiErrorResourceAlreadyExists(String gender, String resource) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine': 'That value is already in use. Another $resource has it.',
      'other': 'That value is already in use. Another $resource has it.',
    });
    return '$_temp0';
  }

  @override
  String apiErrorResourceStillReferenced(String list) {
    return 'This record can\'t be deleted because it\'s still in use: $list.';
  }

  @override
  String get apiErrorResourceStillReferencedGeneric =>
      'This record is still in use and can\'t be deleted.';

  @override
  String apiReferenceMore(int more) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'and $more others',
      one: 'and 1 other',
    );
    return '$_temp0';
  }

  @override
  String get apiErrorCashSessionAlreadyClosed =>
      'This cash session is already closed.';

  @override
  String get apiErrorCashSessionClosed =>
      'The cash session was closed while you were working. Reload to continue.';

  @override
  String get apiErrorCashSessionDrawerBusy =>
      'That cash drawer already has an open session.';

  @override
  String get apiErrorCashSessionNotClosed =>
      'The cash session is still open. Close it first.';

  @override
  String get apiErrorCashSessionNotOpen =>
      'You need an open cash session for this.';

  @override
  String get apiErrorCashSessionUserBusy =>
      'You already have an open session. Close it before opening another.';

  @override
  String get apiErrorCsdCertificateNotRsa =>
      'The certificate doesn\'t use an RSA key. It isn\'t a valid CSD.';

  @override
  String get apiErrorCsdCertificateUnreadable =>
      'The certificate file (.cer) couldn\'t be read.';

  @override
  String get apiErrorCsdKeyMismatch =>
      'The key (.key) doesn\'t match the certificate (.cer).';

  @override
  String get apiErrorCsdKeyNotEncrypted =>
      'The key has no password, so it isn\'t a SAT CSD key.';

  @override
  String get apiErrorCsdKeyNotRsa => 'The key file doesn\'t hold an RSA key.';

  @override
  String get apiErrorCsdKeyUnreadable =>
      'The key couldn\'t be opened. Check the password and the .key file.';

  @override
  String apiErrorCustomerCreditHold(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue credit orders. Settle them',
      one: '1 overdue credit order. Settle it',
    );
    return 'This customer has $_temp0 before creating a new credit order.';
  }

  @override
  String apiErrorCustomerCreditLimitExceeded(String outstanding, String limit) {
    return 'This order would bring the customer\'s balance to $outstanding, over their credit limit of $limit.';
  }

  @override
  String apiErrorCustomerCreditLimitReached(String outstanding, String limit) {
    return 'The customer owes $outstanding, which reaches their credit limit of $limit. They must pay before buying again.';
  }

  @override
  String get apiErrorCustomerDefaultNotDeletable =>
      'The general public customer can\'t be deleted.';

  @override
  String get apiErrorCustomerNoCreditLimit =>
      'This customer has no credit limit, so they can\'t buy on credit.';

  @override
  String get apiErrorCustomerWalkInNoCredit =>
      'The general public customer can\'t buy on credit.';

  @override
  String get apiErrorCustomerDiscountProductNotFound =>
      'The product for this discount no longer exists.';

  @override
  String get apiErrorDeliveryOrderLineAlreadyPresent =>
      'That line is already on this delivery order.';

  @override
  String get apiErrorDeliveryOrderLineNotDeliverable =>
      'That line can\'t be delivered on this order: it belongs to another sale or was already delivered.';

  @override
  String get apiErrorDeliveryOrderLineRepeated =>
      'The same line was added twice.';

  @override
  String get apiErrorDeliveryOrderMixedNotAllowed =>
      'A delivery order can\'t mix delivery and pickup.';

  @override
  String get apiErrorDeliveryOrderNotEditable =>
      'This delivery order is no longer a draft and can\'t be changed.';

  @override
  String apiErrorDeliveryOrderQuantityExceedsRemaining(
    String requested,
    String remaining,
  ) {
    return 'You asked for $requested, but only $remaining are left to deliver on that line.';
  }

  @override
  String get apiErrorDeliveryOrderReasonRequired =>
      'Enter a reason for this change.';

  @override
  String get apiErrorDeliveryOrderSalesOrderFullyDelivered =>
      'This sale has nothing left to deliver.';

  @override
  String get apiErrorDeliveryOrderSalesOrderNotDeliverable =>
      'This sale can\'t be delivered: it isn\'t completed, or it was cancelled.';

  @override
  String get apiErrorDeliveryOrderSalesOrderUnpaid =>
      'The sale must be paid, or sold on credit, before it can be delivered.';

  @override
  String get apiErrorDocumentNotEditable =>
      'This document is completed or cancelled and can\'t be edited.';

  @override
  String get apiErrorEmailNotConfigured => 'Email isn\'t set up on the server.';

  @override
  String get apiErrorEmailSendFailed =>
      'The email couldn\'t be sent. Try again later.';

  @override
  String get apiErrorFacilityNoDispatchWarehouse =>
      'This facility has no warehouse to dispatch from.';

  @override
  String apiErrorFacilityOtherFacility(String gender, String resource) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine':
          'This $resource belongs to another facility, and you don\'t have access to other facilities.',
      'other':
          'This $resource belongs to another facility, and you don\'t have access to other facilities.',
    });
    return '$_temp0';
  }

  @override
  String get apiErrorFacilityRequired =>
      'Choose a facility. Your user has none assigned.';

  @override
  String apiErrorImageTooLarge(String max) {
    return 'The image is too large. The maximum is $max.';
  }

  @override
  String get apiErrorImageUnsupportedFormat =>
      'The file isn\'t an image the server can read. Try another file.';

  @override
  String get apiErrorIncidenceReasonRequired => 'Enter a reason.';

  @override
  String get apiErrorLockBusy =>
      'Someone else is updating this right now. Try again in a moment.';

  @override
  String get apiErrorPaymentNoTicket =>
      'This kind of payment has no ticket to print.';

  @override
  String apiErrorPaymentExceedsOrderBalance(String amount, String balance) {
    return 'The amount $amount is more than the order\'s balance of $balance.';
  }

  @override
  String apiErrorPaymentExceedsUnapplied(String amount, String unapplied) {
    return 'The amount $amount is more than the $unapplied left on the payment.';
  }

  @override
  String get apiErrorPaymentOrderSettled => 'The order is already paid.';

  @override
  String get apiErrorPaymentOrderCancelled =>
      'The order is cancelled and can\'t take a payment.';

  @override
  String get apiErrorPaymentOrderNotCompleted =>
      'The order isn\'t confirmed. Confirm it before applying a payment.';

  @override
  String apiErrorPaymentCurrencyMismatch(
    String paymentCurrency,
    String orderCurrency,
  ) {
    return 'The payment is in $paymentCurrency and the order in $orderCurrency.';
  }

  @override
  String get apiErrorPaymentCustomerMismatch =>
      'The payment belongs to another customer.';

  @override
  String get apiErrorPaymentApplicationReversed =>
      'This application was already reversed.';

  @override
  String get apiErrorPaymentAlreadyApplied =>
      'This payment is already applied to this order. Reverse that application before applying it again.';

  @override
  String get apiErrorPointOfSaleWarehouseFacilityMismatch =>
      'The warehouse must belong to the same facility as the point of sale.';

  @override
  String get apiErrorPriceListCostNotAssignable =>
      'The cost list can\'t be assigned to a customer or used as a replacement.';

  @override
  String get apiErrorPriceListCostNotDeletable =>
      'The cost list can\'t be deleted.';

  @override
  String get apiErrorPriceListCostReadOnly =>
      'Prices on the cost list can\'t be edited here.';

  @override
  String get apiErrorPriceListReplaceWithItself =>
      'A price list can\'t be replaced with itself.';

  @override
  String get apiErrorProductLookupCriteriaRequired =>
      'Type something to search for.';

  @override
  String apiErrorProductLookupTooMany(String max) {
    return 'Too many products at once. The maximum is $max.';
  }

  @override
  String get apiErrorProductMergeWithItself =>
      'A product can\'t be merged into itself.';

  @override
  String get apiErrorProductPriceDuplicateEntry =>
      'The same price was entered twice.';

  @override
  String apiErrorProductPriceReferencesNotFound(
    String gender,
    String resource,
  ) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine':
          'Some of the $resource in this change no longer exist. Reload and try again.',
      'other':
          'Some of the $resource in this change no longer exist. Reload and try again.',
    });
    return '$_temp0';
  }

  @override
  String get apiErrorQuoteAlreadyCancelled =>
      'This quote is already cancelled.';

  @override
  String get apiErrorQuoteCancelled =>
      'This quote was cancelled and can\'t be converted.';

  @override
  String get apiErrorQuoteExpired => 'This quote has expired.';

  @override
  String get apiErrorQuoteNotConfirmed => 'Confirm the quote first.';

  @override
  String get apiErrorRefundAlreadyCancelled =>
      'This refund is already cancelled.';

  @override
  String get apiErrorRefundCompletedCannotCancel =>
      'A completed refund is final and can\'t be cancelled.';

  @override
  String apiErrorRefundLineInvoiced(String product, String invoice) {
    return '$product is on invoice $invoice. Cancel or adjust that invoice before refunding it.';
  }

  @override
  String apiErrorRefundLineInvoicedNoFolio(String product) {
    return '$product is on a live invoice. Cancel or adjust that invoice before refunding it.';
  }

  @override
  String get apiErrorRefundNoReturnableLines =>
      'Enter a quantity to return on at least one line.';

  @override
  String get apiErrorRefundNotConfirmed =>
      'Only a confirmed refund has a receipt to print.';

  @override
  String get apiErrorRefundNothingRefundable =>
      'Nothing on this order is left to refund.';

  @override
  String get apiErrorRefundOrderNotCompleted =>
      'This order isn\'t completed, so it can\'t be refunded.';

  @override
  String get apiErrorRefundOrderNotPaid =>
      'This order isn\'t paid. Cancel it instead of refunding it.';

  @override
  String get apiErrorSalesOrderAlreadyCancelled =>
      'This order is already cancelled.';

  @override
  String apiErrorSalesOrderBelowMinQuantity(String min) {
    return 'A product is below its minimum order of $min.';
  }

  @override
  String get apiErrorSalesOrderHasPaymentApplications =>
      'This order has payments applied. Reverse them first.';

  @override
  String get apiErrorSalesOrderInsufficientStock =>
      'Some lines don\'t have enough stock';

  @override
  String get apiErrorSalesOrderMissingDeliveryDetails =>
      'Delivery details are missing';

  @override
  String get apiErrorSalesOrderNoLines =>
      'Add at least one line before confirming.';

  @override
  String get apiErrorSalesOrderPaidCannotCancel =>
      'A paid order can\'t be cancelled. Refund it instead.';

  @override
  String get apiErrorSalesOrderZeroPricedLines => 'Some lines have no price';

  @override
  String apiErrorSupplierAgreementEndBeforeStart(String end, String start) {
    return 'The end date ($end) is before the start date ($start).';
  }

  @override
  String apiErrorTaxpayerCertificateHolderMismatch(
    String certificateTaxpayer,
    String taxpayer,
  ) {
    return 'The certificate belongs to $certificateTaxpayer, not to $taxpayer.';
  }

  @override
  String apiErrorTaxpayerIssuerUnknown(String taxpayer) {
    return 'The issuer $taxpayer isn\'t registered.';
  }

  @override
  String get apiErrorUserNoCashDrawer =>
      'Your user has no cash drawer assigned.';

  @override
  String get apiErrorUserNoFacility => 'Your user has no facility assigned.';

  @override
  String get apiErrorUserNoPointOfSale =>
      'Your user has no point of sale assigned.';

  @override
  String get apiErrorUserProfileNotActive =>
      'This profile is inactive and can\'t be applied.';

  @override
  String get apiErrorWarehouseInTransitLocation =>
      'An in-transit warehouse can\'t be used here.';

  @override
  String get apiErrorWarehouseInTransitManaged =>
      'In-transit warehouses are managed by the system and can\'t be edited.';

  @override
  String get apiErrorWarehouseRequired =>
      'Choose a warehouse. Your point of sale has none.';

  @override
  String get apiValidationContactNameBlank => 'The name can\'t be blank.';

  @override
  String get apiValidationEmailAddressInvalid =>
      'That isn\'t a valid email address.';

  @override
  String get apiValidationProductBarcodeInvalid =>
      'The barcode must be empty or exactly 13 digits (EAN-13).';

  @override
  String get apiValidationProductCodeHasWhitespace =>
      'The code can\'t contain spaces.';

  @override
  String get apiValidationProfileDuplicateSystemObject =>
      'A permission appears twice in this profile.';

  @override
  String get apiValidationProfileUnknownSystemObject =>
      'The profile has a permission the server doesn\'t recognize.';

  @override
  String get apiValidationSupplierAgreementEndBeforeStart =>
      'The end date can\'t be before the start date.';

  @override
  String get apiValidationUserIdNotAlphanumeric =>
      'The username can only have letters and numbers.';

  @override
  String apiResourceCustomerAddress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'addresses',
      one: 'address',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerAddress => 'feminine';

  @override
  String apiResourceCustomerContact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'contacts',
      one: 'contact',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerContact => 'masculine';

  @override
  String apiResourceCustomerTaxpayer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tax recipients',
      one: 'tax recipient',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderCustomerTaxpayer => 'masculine';

  @override
  String apiResourceSupplierAddress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'addresses',
      one: 'address',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierAddress => 'feminine';

  @override
  String apiResourceSupplierAgreement(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'agreements',
      one: 'agreement',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierAgreement => 'masculine';

  @override
  String apiResourceSupplierBankAccount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bank accounts',
      one: 'bank account',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierBankAccount => 'feminine';

  @override
  String apiResourceSupplierContact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'contacts',
      one: 'contact',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderSupplierContact => 'masculine';

  @override
  String get paymentReverseTitle => 'Reverse application';

  @override
  String paymentReverseSubject(String amount, String order) {
    return '$amount applied to order #$order.';
  }

  @override
  String get paymentReverseReasonLabel => 'Reason';

  @override
  String get paymentReverseRefundWarning =>
      'This order has refunds. Reversing the payment does not undo the refund.';

  @override
  String get paymentReverseConfirm => 'Reverse';

  @override
  String get paymentReverseDone => 'Application reversed';

  @override
  String get paymentApplyAction => 'Apply to order';

  @override
  String paymentApplyTitle(String payment) {
    return 'Apply payment #$payment';
  }

  @override
  String paymentApplyUnapplied(String amount) {
    return 'Unapplied: $amount';
  }

  @override
  String get paymentApplySearchHint => 'Order or folio…';

  @override
  String get paymentApplyColumnFolio => 'Folio';

  @override
  String get paymentApplyColumnTotal => 'Total';

  @override
  String get paymentApplyColumnBalance => 'Balance';

  @override
  String get paymentApplyAmountLabel => 'Amount to apply';

  @override
  String paymentApplyAmountMax(String amount) {
    return 'Maximum $amount';
  }

  @override
  String paymentApplyAmountTooHigh(String amount) {
    return 'It can\'t be more than $amount.';
  }

  @override
  String get paymentApplyAmountInvalid => 'Enter an amount above zero.';

  @override
  String paymentApplyEmpty(String currency) {
    return 'This customer has no orders to pay in $currency.';
  }

  @override
  String get paymentApplyConfirm => 'Apply';

  @override
  String paymentApplyDone(String order) {
    return 'Payment applied to #$order';
  }

  @override
  String get paymentRecordAction => 'Record payment';

  @override
  String get paymentRecordActionShort => 'Payment';

  @override
  String get paymentRecordCurrencyLabel => 'Currency';

  @override
  String get paymentRecordSave => 'Record';

  @override
  String get paymentRecordSaving => 'Recording…';

  @override
  String get paymentRecordErrorCustomer => 'Choose a customer.';

  @override
  String get paymentRecordErrorWalkIn =>
      'Choose a named customer: the general public can\'t hold advances or credit payments.';

  @override
  String get paymentRecordErrorMethod => 'Choose a payment method.';

  @override
  String get paymentRecordErrorReference => 'This method needs a reference.';

  @override
  String get paymentRecordErrorAmount => 'Enter an amount above zero.';

  @override
  String get paymentRecordErrorCashSession =>
      'To record cash you need a cash session open today.';

  @override
  String get paymentRecordGoToSessions => 'Go to cash sessions';

  @override
  String get paymentRecordUnknownResult =>
      'We don\'t know whether the payment was recorded: the connection was lost. Look for it in Payments before trying again.';

  @override
  String get salesOrderPaymentsButton => 'Payments';

  @override
  String salesOrderPaymentsTitle(String order) {
    return 'Payments on order #$order';
  }

  @override
  String get salesOrderPaymentOpenTooltip => 'Open payment';

  @override
  String get paymentApplyNoMatches => 'No order matches the search.';

  @override
  String get paymentVerificationMenuTitle => 'Payment verification';

  @override
  String get paymentVerificationEmpty =>
      'There are no unverified payments for these filters.';

  @override
  String get paymentVerificationMethodAll => 'All';

  @override
  String get paymentVerificationFacilityAll => 'All';

  @override
  String get paymentVerifyAction => 'Verify';

  @override
  String get paymentRejectAction => 'Reject';

  @override
  String get paymentVerifyTitle => 'Verify payment';

  @override
  String get paymentRejectTitle => 'Reject payment';

  @override
  String get paymentVerifyIrreversible =>
      'Confirm the money is in the bank. This can\'t be undone.';

  @override
  String get paymentRejectReasonLabel => 'Reason';

  @override
  String get paymentRejectNote =>
      'The payment stays unverified; the rejection is recorded with your name and the date.';

  @override
  String paymentVerifiedSnack(String id) {
    return 'Payment $id verified.';
  }

  @override
  String paymentRejectedSnack(String id) {
    return 'Rejection recorded. Payment $id stays unverified and stays in the verification list.';
  }

  @override
  String get paymentVerifyUnknown =>
      'We don\'t know whether it was verified: the connection was lost. The list was refreshed.';

  @override
  String get paymentRejectUnknown =>
      'We don\'t know whether the rejection was recorded: the connection was lost. The list was refreshed.';

  @override
  String get apiErrorPaymentAlreadyVerified =>
      'Someone else already verified this payment.';

  @override
  String get navDeliveryOrders => 'Delivery orders';

  @override
  String deliveryOrderTitle(String serial) {
    return 'Delivery order $serial';
  }

  @override
  String get deliveryOrderTitleDraft => 'Delivery order · Draft';

  @override
  String get deliveryOrderDraftFolio => 'Draft';

  @override
  String get deliveryOrdersEmpty => 'No delivery orders match these filters.';

  @override
  String get deliveryOrdersSearchHint => 'Folio';

  @override
  String get deliveryOrdersNoFacilityTitle => 'No facility configured';

  @override
  String get deliveryOrdersNoFacilityMessage =>
      'Your account has no facility assigned, so delivery orders cannot be listed. Ask your administrator to configure one on your user.';

  @override
  String get deliveryOrderBackToList => 'Back to delivery orders';

  @override
  String get deliveryOrderStatusDraft => 'Draft';

  @override
  String get deliveryOrderStatusPendingApproval => 'Pending approval';

  @override
  String get deliveryOrderStatusApproved => 'Approved';

  @override
  String get deliveryOrderStatusReadyForPickup => 'Ready for pickup';

  @override
  String get deliveryOrderStatusPickedUp => 'Picked up';

  @override
  String get deliveryOrderStatusInPreparation => 'In preparation';

  @override
  String get deliveryOrderStatusInTransit => 'In transit';

  @override
  String get deliveryOrderStatusDelivered => 'Delivered';

  @override
  String get deliveryOrderStatusPartiallyDelivered => 'Partially delivered';

  @override
  String get deliveryOrderStatusFailed => 'Failed';

  @override
  String get deliveryOrderStatusCancelled => 'Cancelled';

  @override
  String get deliveryOrderTypeDelivery => 'Delivery';

  @override
  String get deliveryOrderTypePickup => 'Store pickup';

  @override
  String get deliveryOrderColumnSerial => 'Folio';

  @override
  String get deliveryOrderColumnCustomer => 'Customer';

  @override
  String get deliveryOrderColumnType => 'Type';

  @override
  String get deliveryOrderColumnScheduled => 'Scheduled';

  @override
  String get deliveryOrderColumnDestination => 'Destination';

  @override
  String get deliveryOrderColumnSalesOrders => 'Sales';

  @override
  String get deliveryOrderColumnStatus => 'Status';

  @override
  String get deliveryOrderFactFacility => 'Facility';

  @override
  String get deliveryOrderFactPriority => 'Priority';

  @override
  String get deliveryOrderFactContact => 'Contact';

  @override
  String get deliveryOrderFactComment => 'Comment';

  @override
  String get deliveryOrderFactParent => 'From order';

  @override
  String get deliveryOrderFactChild => 'Derived order';

  @override
  String get deliveryOrderLineColumnCode => 'Code';

  @override
  String get deliveryOrderLineColumnProduct => 'Product';

  @override
  String get deliveryOrderLineColumnWarehouse => 'Warehouse';

  @override
  String get deliveryOrderLineColumnSalesOrder => 'Sale';

  @override
  String get deliveryOrderLineColumnOrdered => 'Ordered';

  @override
  String get deliveryOrderLineColumnCommitted => 'Committed';

  @override
  String get deliveryOrderLineColumnDelivered => 'Delivered';

  @override
  String get deliveryOrderLineColumnReturned => 'Returned';

  @override
  String get deliveryOrderLineColumnOpen => 'Open';

  @override
  String get deliveryOrderLinesTitle => 'Lines';

  @override
  String get deliveryOrderHistoryTitle => 'History';

  @override
  String get deliveryOrderProofTitle => 'Proof of delivery';

  @override
  String get deliveryOrderProofReceiver => 'Received by';

  @override
  String get deliveryOrderProofIdShown => 'Identification shown';

  @override
  String get deliveryOrderProofCapturedAt => 'Captured';

  @override
  String get deliveryOrderProofCapturedBy => 'Captured by';

  @override
  String get deliveryOrderProofLoadFailed => 'The proof could not be loaded';

  @override
  String get deliveryOrderProofEnlargeTooltip => 'Enlarge photo';

  @override
  String get deliveryOrderEventsEmpty => 'No history yet.';

  @override
  String deliveryOrderRejectionBanner(String reason) {
    return 'Rejection reason: $reason';
  }

  @override
  String get deliveryOrderFilterStatus => 'Status';

  @override
  String get deliveryOrderFilterType => 'Type';

  @override
  String get deliveryOrderFilterScheduled => 'Scheduled date';

  @override
  String get deliveryOrderFilterCustomer => 'Customer';

  @override
  String get deliveryOrderFilterSalesOrder => 'Sale';

  @override
  String get deliveryOrderFilterFacility => 'Facility';

  @override
  String get deliveryOrderFilterActiveStatuses => 'Active';

  @override
  String get deliveryOrderFilterAllStatuses => 'All';

  @override
  String get deliveryOrderFilterAllTypes => 'All';

  @override
  String get deliveryOrderFilterMyFacility => 'My facility';

  @override
  String get deliveryOrderFilterSalesOrderHint => 'Sale number';

  @override
  String get deliveryOrderEditHeader => 'Edit header';

  @override
  String get deliveryOrderAddLine => 'Add line';

  @override
  String get deliveryOrderConfirmAction => 'Confirm';

  @override
  String get deliveryOrderCancelAction => 'Cancel order';

  @override
  String get deliveryOrderRequeueAction => 'Reschedule';

  @override
  String get deliveryOrderReadyAction => 'Ready for pickup';

  @override
  String get deliveryOrderPickupAction => 'Hand over to customer';

  @override
  String get deliveryOrderBackButton => 'Back';

  @override
  String get deliveryOrderLineEditTooltip => 'Change quantity';

  @override
  String get deliveryOrderLineRemoveTooltip => 'Remove line';

  @override
  String get deliveryOrderConfirmTitle => 'Confirm delivery order?';

  @override
  String deliveryOrderConfirmSummary(String customer, String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# lines',
      one: '# line',
    );
    return '$customer · Scheduled $date · $_temp0';
  }

  @override
  String get deliveryOrderConfirmIrreversible =>
      'Once confirmed, it can no longer be edited.';

  @override
  String get deliveryOrderConfirmNeedsLines =>
      'Add at least one line to confirm.';

  @override
  String deliveryOrderRequeueTitle(String serial) {
    return 'Reschedule order $serial?';
  }

  @override
  String deliveryOrderRequeueBody(String customer) {
    return '$customer. The order goes back to In preparation and its quantities become open again.';
  }

  @override
  String deliveryOrderReadyTitle(String serial) {
    return 'Mark order $serial ready for pickup?';
  }

  @override
  String deliveryOrderReadyBody(String customer) {
    return '$customer. The customer will be able to come and pick the goods up.';
  }

  @override
  String deliveryOrderCancelTitle(String serial) {
    return 'Cancel order $serial';
  }

  @override
  String deliveryOrderCancelSummary(String customer, String date) {
    return '$customer · Scheduled $date';
  }

  @override
  String get deliveryOrderCancelReasonLabel => 'Reason';

  @override
  String get deliveryOrderAddLineStep1Title => 'Add line · 1 of 2';

  @override
  String deliveryOrderAddLineStep2Title(String serial) {
    return 'Add line · 2 of 2 · Sale $serial';
  }

  @override
  String deliveryOrderAddLineStep1Intro(String customer, String facility) {
    return 'Completed sales of $customer at $facility';
  }

  @override
  String get deliveryOrderAddLineSearchHint => 'Sale folio';

  @override
  String get deliveryOrderAddLineSaleColumnSerial => 'Folio';

  @override
  String get deliveryOrderAddLineSaleColumnDate => 'Date';

  @override
  String get deliveryOrderAddLineSaleColumnTotal => 'Total';

  @override
  String get deliveryOrderAddLineLoadMore => 'Load more';

  @override
  String get deliveryOrderAddLineColumnRemaining => 'Remaining';

  @override
  String get deliveryOrderAddLineColumnQuantity => 'Quantity';

  @override
  String get deliveryOrderAddLineAnotherSale => 'Another sale';

  @override
  String get deliveryOrderAddLineSubmit => 'Add';

  @override
  String get deliveryOrderAddLineEmptySales =>
      'This customer has no sales with goods left to deliver at this facility.';

  @override
  String get deliveryOrderAddLineEmptyLines =>
      'This sale has nothing left to deliver.';

  @override
  String deliveryOrderAddLineQuantityInvalid(String remaining) {
    return 'Enter a quantity greater than 0 and at most $remaining.';
  }

  @override
  String get deliveryOrderLineQuantityTitle => 'Change quantity';

  @override
  String deliveryOrderLineQuantityOrdered(String quantity) {
    return 'Ordered on the sale: $quantity';
  }

  @override
  String get deliveryOrderLineQuantityLabel => 'Quantity';

  @override
  String get deliveryOrderLineQuantityInvalid =>
      'Enter a quantity greater than 0.';

  @override
  String deliveryOrderLineRemoveTitle(String product) {
    return 'Remove $product from the order?';
  }

  @override
  String get deliveryOrderLineRemoveBody =>
      'The quantity becomes available for delivery again.';

  @override
  String get deliveryOrderLineRemoveAction => 'Remove';

  @override
  String deliveryOrderPickupTitle(String serial) {
    return 'Hand over to customer · Order $serial';
  }

  @override
  String get deliveryOrderPickupNameLabel => 'Receiver name';

  @override
  String get deliveryOrderPickupIdLabel => 'Identification shown';

  @override
  String get deliveryOrderPickupPhotoLabel => 'Photo';

  @override
  String get deliveryOrderPickupChooseFile => 'Choose file';

  @override
  String get deliveryOrderPickupClearFile => 'Remove file';

  @override
  String get deliveryOrderPickupSubmit => 'Hand over';

  @override
  String get deliveryOrderHeaderTitle => 'Edit header';

  @override
  String get deliveryOrderHeaderScheduledLabel => 'Scheduled date';

  @override
  String get deliveryOrderHeaderPriorityLabel => 'Priority';

  @override
  String get deliveryOrderHeaderDestinationLabel => 'Destination';

  @override
  String get deliveryOrderHeaderContactLabel => 'Contact';

  @override
  String get deliveryOrderHeaderCommentLabel => 'Comment';

  @override
  String get deliveryOrderHeaderPriorityInvalid =>
      'Enter a whole number, 0 or more.';

  @override
  String deliveryOrderHeaderPickupDestination(String facility) {
    return 'Store $facility';
  }

  @override
  String deliveryOrderSnackConfirmed(String serial) {
    return 'Order $serial confirmed';
  }

  @override
  String deliveryOrderSnackCancelled(String serial) {
    return 'Order $serial cancelled';
  }

  @override
  String deliveryOrderSnackRequeued(String serial) {
    return 'Order $serial rescheduled';
  }

  @override
  String deliveryOrderSnackReady(String serial) {
    return 'Order $serial ready for pickup';
  }

  @override
  String deliveryOrderSnackPickedUp(String serial) {
    return 'Order $serial handed over to the customer';
  }

  @override
  String deliveryOrderSnackHeaderSaved(String serial) {
    return 'Order $serial header saved';
  }

  @override
  String deliveryOrderSnackLineAdded(String serial) {
    return 'Line added to order $serial';
  }

  @override
  String deliveryOrderSnackLineUpdated(String serial) {
    return 'Quantity updated on order $serial';
  }

  @override
  String deliveryOrderSnackLineRemoved(String serial) {
    return 'Line removed from order $serial';
  }

  @override
  String get deliveryOrderActionUnknown =>
      'We don\'t know whether it completed: the connection was lost. The order was refreshed.';

  @override
  String apiErrorDeliveryOrderInsufficientNotice(
    String minHours,
    String earliest,
  ) {
    return 'At least $minHours h of notice are required. Earliest date: $earliest.';
  }

  @override
  String get apiErrorDeliveryOrderNoLines => 'The delivery order has no lines.';

  @override
  String get apiErrorDeliveryOrderNotFailed =>
      'Only a failed order can be rescheduled.';

  @override
  String get apiErrorDeliveryOrderOnItinerary =>
      'This order is on an open delivery itinerary. Remove it from the itinerary before cancelling it.';

  @override
  String get apiErrorDeliveryOrderProofIncomplete =>
      'The proof is incomplete: enter who received the goods and the identification they showed.';

  @override
  String get navDeliveryOrderApproval => 'Delivery approval';

  @override
  String get deliveryOrderApprovalColumnPriority => 'Prio.';

  @override
  String get deliveryOrderApprovalEmpty =>
      'No delivery orders are waiting for approval.';

  @override
  String get deliveryOrderApprovalNoFacilityTitle => 'No facility configured';

  @override
  String get deliveryOrderApprovalNoFacilityMessage =>
      'Your account has no facility assigned. Delivery approval shows your facility\'s orders. Ask your administrator to configure one on your user.';

  @override
  String get deliveryOrderApprovalForbidden =>
      'You don\'t have access to delivery approval.';

  @override
  String get deliveryOrderApproveAction => 'Approve';

  @override
  String get deliveryOrderRejectAction => 'Reject';

  @override
  String deliveryOrderApproveTitle(String serial) {
    return 'Approve delivery order $serial?';
  }

  @override
  String get deliveryOrderApproveNextDelivery =>
      'It will move to In preparation and appear for the warehouse.';

  @override
  String get deliveryOrderApproveNextPickup =>
      'It will move to Approved; then it is marked ready for pickup.';

  @override
  String deliveryOrderRejectTitle(String serial) {
    return 'Reject delivery order $serial';
  }

  @override
  String deliveryOrderRejectSummary(String customer, String date) {
    return '$customer · Scheduled $date';
  }

  @override
  String get deliveryOrderRejectReasonLabel => 'Reason';

  @override
  String get deliveryOrderRejectNote =>
      'The order goes back to its author as a draft so they can fix it and confirm it again. The reason stays on the order.';

  @override
  String deliveryOrderSnackApproved(String serial, String status) {
    return 'Order $serial approved: $status';
  }

  @override
  String deliveryOrderSnackRejected(String serial) {
    return 'Order $serial rejected. It went back to draft with the reason.';
  }

  @override
  String get apiErrorDeliveryOrderNotPendingApproval =>
      'This order is no longer pending approval.';

  @override
  String get navForDelivery => 'For delivery';

  @override
  String get forDeliveryPeriodLabel => 'Period';

  @override
  String get forDeliveryPeriodEarlier => 'Earlier';

  @override
  String get forDeliveryPeriodYesterday => 'Yesterday';

  @override
  String get forDeliveryPeriodToday => 'Today';

  @override
  String get forDeliveryPeriodTomorrow => 'Tomorrow';

  @override
  String get forDeliveryPeriodDayAfter => 'Day after tomorrow';

  @override
  String get forDeliveryPeriodLater => 'Later';

  @override
  String forDeliveryPeriodOptionDated(String label, String date, int total) {
    return '$label · $date ($total)';
  }

  @override
  String forDeliveryPeriodOptionUndated(String label, int total) {
    return '$label ($total)';
  }

  @override
  String get forDeliveryNoDate => 'No date';

  @override
  String get forDeliveryEmpty => 'No deliveries pending for this period.';

  @override
  String get forDeliveryColumnPriority => 'Prio.';

  @override
  String get forDeliveryColumnProduct => 'Product';

  @override
  String get forDeliveryColumnWarehouse => 'Warehouse';

  @override
  String get forDeliveryColumnOpenQuantity => 'Pending';

  @override
  String get deliveryOrderViewTicket => 'View ticket';

  @override
  String get deliveryOrderViewLetter => 'View letter format';

  @override
  String get deliveryTicketScopeTitle => 'Which lines to print?';

  @override
  String get deliveryTicketScopeAll => 'All warehouses';

  @override
  String documentDeliveryTicketTitle(String folio) {
    return 'Delivery ticket · $folio';
  }

  @override
  String documentDeliveryTicketWarehouseTitle(String folio, String warehouse) {
    return 'Delivery ticket · $folio · $warehouse';
  }

  @override
  String documentDeliveryOrderLetterTitle(String folio) {
    return 'Delivery order · $folio (letter)';
  }

  @override
  String get apiErrorDeliveryOrderNotApproved =>
      'The delivery order isn\'t approved yet, so it can\'t be printed.';

  @override
  String get apiErrorDeliveryOrderUnknownWarehouse =>
      'The chosen warehouse doesn\'t exist.';

  @override
  String get apiErrorDeliveryOrderNoLinesFromWarehouse =>
      'No line of this order leaves from the chosen warehouse.';

  @override
  String get taxpayerBatchesSectionTitle => 'Series';

  @override
  String taxpayerBatchesSectionTitleWithCount(int count) {
    return 'Series ($count)';
  }

  @override
  String get taxpayerBatchesEmpty =>
      'This issuer has no series. Without a series of the right type it can\'t issue that document.';

  @override
  String get taxpayerBatchColumnSeries => 'Series';

  @override
  String get taxpayerBatchColumnType => 'Type';

  @override
  String get taxpayerBatchColumnTemplate => 'Template';

  @override
  String get taxpayerBatchColumnInUse => 'In use';

  @override
  String get taxpayerBatchDialogCreateTitle => 'New series';

  @override
  String get taxpayerBatchDialogViewTitle => 'View series';

  @override
  String get taxpayerBatchDialogEditTitle => 'Edit series';

  @override
  String get taxpayerBatchSeriesLabel => 'Series';

  @override
  String get taxpayerBatchTypeLabel => 'Document type';

  @override
  String get taxpayerBatchTemplateNameLabel => 'Template name';

  @override
  String get taxpayerBatchLogoLabel => 'Logo (file name)';

  @override
  String get taxpayerBatchHeaderHeightLabel => 'Header height (mm)';

  @override
  String get taxpayerBatchFooterHeightLabel => 'Footer height (mm)';

  @override
  String get taxpayerBatchInUseNote =>
      'Documents have already been issued with this series; only the template can change.';

  @override
  String get taxpayerBatchAccountsTitle => 'Bank accounts';

  @override
  String get taxpayerBatchAccountBank => 'Bank';

  @override
  String get taxpayerBatchAccountNumber => 'Account';

  @override
  String get taxpayerBatchAccountClabe => 'CLABE';

  @override
  String get taxpayerBatchAccountCurrency => 'Currency';

  @override
  String get taxpayerBatchAddAccount => 'Add account';

  @override
  String get taxpayerBatchMoveAccountUp => 'Move up';

  @override
  String get taxpayerBatchMoveAccountDown => 'Move down';

  @override
  String get taxpayerBatchRemoveAccount => 'Remove account';

  @override
  String get taxpayerBatchNoAccounts => 'No bank accounts';

  @override
  String get taxpayerBatchCloseButton => 'Close';

  @override
  String get taxpayerBatchDeleteTitle => 'Delete series?';

  @override
  String taxpayerBatchDeleteMessage(String series, String type) {
    return 'Series $series ($type) will be deleted.';
  }

  @override
  String get taxpayerBatchSeriesRequiredError => 'Enter the series.';

  @override
  String get taxpayerBatchSeriesTooLongError =>
      'The series can have at most 10 characters.';

  @override
  String get taxpayerBatchTypeRequiredError => 'Choose the document type.';

  @override
  String get taxpayerBatchTemplateNameRequiredError =>
      'Enter the template name.';

  @override
  String get taxpayerBatchTemplateNameTooLongError =>
      'The template name can have at most 50 characters.';

  @override
  String get taxpayerBatchHeightInvalidError =>
      'Enter a whole number, 0 or more.';

  @override
  String get fiscalDocumentKindInvoice => 'Invoice';

  @override
  String get fiscalDocumentKindFeeReceipt => 'Fee receipt';

  @override
  String get fiscalDocumentKindRentReceipt => 'Rent receipt';

  @override
  String get fiscalDocumentKindDebitNote => 'Debit note';

  @override
  String get fiscalDocumentKindCreditNote => 'Credit note';

  @override
  String get fiscalDocumentKindPaymentReceipt => 'Payment receipt';

  @override
  String get fiscalDocumentKindAdvancePaymentsApplied =>
      'Advance payments applied';

  @override
  String fiscalDocumentKindUnknown(int code) {
    return 'Unknown type ($code)';
  }

  @override
  String get apiErrorTaxpayerBatchInUseUpdate =>
      'The series is already used by issued documents; only its template can change.';

  @override
  String get apiErrorTaxpayerBatchInUseDelete =>
      'The series is already used by issued documents and can\'t be deleted.';

  @override
  String get apiValidationTaxpayerBatchSeriesBlank =>
      'The series can\'t be blank.';

  @override
  String apiResourceTaxpayerBatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'series',
      one: 'series',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderTaxpayerBatch => 'feminine';

  @override
  String get taxpayerBatchSaveFailed => 'The series couldn\'t be saved.';

  @override
  String get taxpayerBatchDeleteFailed => 'The series couldn\'t be deleted.';

  @override
  String get navInvoicingGroup => 'Invoicing';

  @override
  String get navFiscalDocuments => 'Invoices';

  @override
  String fiscalDocumentTitle(String folio) {
    return 'Invoice $folio';
  }

  @override
  String fiscalDocumentTitleKind(String kind, String folio) {
    return '$kind $folio';
  }

  @override
  String fiscalDocumentTitleDraft(int id) {
    return 'Draft #$id';
  }

  @override
  String get fiscalDocumentDraftFolio => 'Draft';

  @override
  String get fiscalDocumentsEmpty => 'There are no invoices yet.';

  @override
  String get fiscalDocumentsSearchHint => 'Folio, UUID, recipient RFC or name';

  @override
  String get fiscalDocumentBackToList => 'Back to invoices';

  @override
  String get fiscalDocumentNotFound => 'We could not find this document.';

  @override
  String get fiscalDocumentLoadFailed => 'The document could not be loaded.';

  @override
  String get fiscalDocumentStatusDraft => 'Draft';

  @override
  String get fiscalDocumentStatusSealed => 'Sealed';

  @override
  String get fiscalDocumentStatusIssued => 'Stamped';

  @override
  String get fiscalDocumentStatusCancelled => 'Cancelled';

  @override
  String get fiscalDocumentColFolio => 'Folio';

  @override
  String get fiscalDocumentColType => 'Type';

  @override
  String get fiscalDocumentColIssuer => 'Issuer';

  @override
  String get fiscalDocumentColRecipient => 'Recipient';

  @override
  String get fiscalDocumentColIssued => 'Issue date';

  @override
  String get fiscalDocumentColStatus => 'Status';

  @override
  String get fiscalDocumentColTotal => 'Total';

  @override
  String get fiscalDocumentFacetStatus => 'Status';

  @override
  String get fiscalDocumentFacetType => 'Type';

  @override
  String get fiscalDocumentFacetIssuer => 'Issuer';

  @override
  String get fiscalDocumentFacetIssued => 'Issue date';

  @override
  String get fiscalDocumentFacetAll => 'All';

  @override
  String get fiscalDocumentDateFacetHelper =>
      'Drafts have no issue date and do not appear when filtering by date.';

  @override
  String get fiscalDocumentBannerSealed => 'Sealed, no fiscal validity yet.';

  @override
  String get fiscalDocumentBannerReadOnlyKind =>
      'This type of document can only be viewed.';

  @override
  String fiscalDocumentBannerCancelled(String date) {
    return 'Cancelled on $date.';
  }

  @override
  String get fiscalDocumentNoCustomerNote =>
      'This draft has no customer: the recipient cannot be changed and orders cannot be added.';

  @override
  String get fiscalDocumentFactIssuer => 'Issuer';

  @override
  String get fiscalDocumentFactRecipient => 'Recipient';

  @override
  String get fiscalDocumentFactCustomer => 'Customer';

  @override
  String get fiscalDocumentFactFacility => 'Facility';

  @override
  String get fiscalDocumentFactSeriesFolio => 'Series and folio';

  @override
  String get fiscalDocumentFactIssued => 'Issue date';

  @override
  String get fiscalDocumentFactPaymentTerms => 'Payment method';

  @override
  String get fiscalDocumentFactPaymentForm => 'Payment form';

  @override
  String get fiscalDocumentFactUsage => 'CFDI use';

  @override
  String get fiscalDocumentFactCurrency => 'Currency';

  @override
  String get fiscalDocumentFactReference => 'Reference';

  @override
  String get fiscalDocumentFactComment => 'Notes';

  @override
  String get fiscalDocumentFactUuid => 'UUID';

  @override
  String get fiscalDocumentFactStamped => 'Stamp date';

  @override
  String get fiscalDocumentFactRegime => 'Regime';

  @override
  String get fiscalDocumentFactPostalCode => 'Postal code';

  @override
  String get fiscalDocumentFactIssuedOnConfirm => 'when confirmed';

  @override
  String get fiscalDocumentTermsPue => 'Payment in a single installment (PUE)';

  @override
  String get fiscalDocumentTermsPpd =>
      'Payment in installments or deferred (PPD)';

  @override
  String get fiscalDocumentLinesTitle => 'Lines';

  @override
  String get fiscalDocumentLineQuantity => 'Quantity';

  @override
  String get fiscalDocumentLineUnit => 'Unit';

  @override
  String get fiscalDocumentLineSatKey => 'SAT key';

  @override
  String get fiscalDocumentLineDescription => 'Description';

  @override
  String get fiscalDocumentLinePrice => 'Unit price';

  @override
  String get fiscalDocumentLineDiscount => 'Discount';

  @override
  String get fiscalDocumentLineTax => 'VAT';

  @override
  String get fiscalDocumentLineAmount => 'Amount';

  @override
  String fiscalDocumentLineInternalCode(String code) {
    return 'Internal code: $code';
  }

  @override
  String get fiscalDocumentLineFromOrder => 'Order';

  @override
  String get fiscalDocumentLinesEmpty => 'The document has no lines.';

  @override
  String get fiscalDocumentTaxIva16 => '16 %';

  @override
  String get fiscalDocumentTaxZero => '0 %';

  @override
  String get fiscalDocumentTaxExempt => 'Exempt';

  @override
  String fiscalDocumentTaxOther(String rate) {
    return '$rate';
  }

  @override
  String get fiscalDocumentRelationsTitle => 'Related documents';

  @override
  String get fiscalDocumentTotalSubtotal => 'Subtotal';

  @override
  String get fiscalDocumentTotalDiscount => 'Discount';

  @override
  String get fiscalDocumentTotalTax => 'VAT';

  @override
  String get fiscalDocumentTotalTotal => 'Total';

  @override
  String get fiscalDocumentTotalEstimated => 'Total (estimated)';

  @override
  String get fiscalDocumentRelationSubstitution =>
      '04 · Substitution of a cancelled CFDI';

  @override
  String get fiscalDocumentRelationAdvance => '07 · Application of an advance';

  @override
  String get fiscalDocumentRelationCreditNote => '01 · Credit note';

  @override
  String get fiscalDocumentNewAction => 'New invoice';

  @override
  String get fiscalDocumentEditHeader => 'Edit header';

  @override
  String get fiscalDocumentAddOrder => 'Add order';

  @override
  String get fiscalDocumentAddProduct => 'Add product';

  @override
  String get fiscalDocumentAddRelation => 'Add relation';

  @override
  String get fiscalDocumentConfirmAction => 'Confirm';

  @override
  String get fiscalDocumentReopenAction => 'Reopen';

  @override
  String get fiscalDocumentViewPdf => 'View PDF';

  @override
  String get fiscalDocumentDownloadXml => 'Download XML';

  @override
  String get fiscalDocumentNewTitle => 'New invoice';

  @override
  String get fiscalDocumentNewCustomer => 'Customer';

  @override
  String get fiscalDocumentNewRecipient => 'Recipient RFC';

  @override
  String get fiscalDocumentNewNoTaxpayers =>
      'This customer has no registered RFC.';

  @override
  String get fiscalDocumentNewCreate => 'Create';

  @override
  String get fiscalDocumentHeaderTitle => 'Edit header';

  @override
  String get fiscalDocumentHeaderRecipient => 'Recipient (RFC)';

  @override
  String get fiscalDocumentHeaderSeries => 'Series';

  @override
  String get fiscalDocumentHeaderUsage => 'CFDI use';

  @override
  String get fiscalDocumentHeaderTerms => 'Payment method';

  @override
  String get fiscalDocumentHeaderForm => 'Payment form';

  @override
  String get fiscalDocumentHeaderIssued => 'Issue date';

  @override
  String get fiscalDocumentHeaderFacility => 'Facility';

  @override
  String get fiscalDocumentHeaderReference => 'Reference';

  @override
  String get fiscalDocumentHeaderComment => 'Notes';

  @override
  String get fiscalDocumentHeaderSeriesLocked =>
      'The series cannot change once the folio is assigned.';

  @override
  String get fiscalDocumentHeaderFormPpd => '99 — To be defined';

  @override
  String get fiscalDocumentHeaderIssuedHelper =>
      'Empty: the confirmation date is used. If set, it must be within the last 72 hours.';

  @override
  String get fiscalDocumentHeaderIssuedOutOfRange =>
      'The date must be within the last 72 hours and not in the future.';

  @override
  String get fiscalDocumentHeaderSaved => 'Header updated.';

  @override
  String get fiscalDocumentLineDialogTitle => 'Edit line';

  @override
  String get fiscalDocumentLineFieldQuantity => 'Quantity';

  @override
  String get fiscalDocumentLineFieldPrice => 'Unit price';

  @override
  String get fiscalDocumentLineFieldDiscount => 'Discount %';

  @override
  String get fiscalDocumentLineFieldTax => 'VAT';

  @override
  String get fiscalDocumentLineFieldCode => 'Internal code';

  @override
  String get fiscalDocumentLineFieldName => 'Description';

  @override
  String get fiscalDocumentLineFieldComment => 'Comment';

  @override
  String get fiscalDocumentLineNameHelper =>
      'If left blank, it resets to the product name.';

  @override
  String get fiscalDocumentLineQuantityInvalid =>
      'Enter a quantity greater than 0.';

  @override
  String get fiscalDocumentLinePriceInvalid => 'Enter a price of 0 or more.';

  @override
  String get fiscalDocumentLineDiscountInvalid =>
      'Enter a discount between 0 and 100.';

  @override
  String get fiscalDocumentLineCodeTooLong =>
      'The internal code can be up to 35 characters.';

  @override
  String get fiscalDocumentRemoveLineTitle => 'Remove line';

  @override
  String get fiscalDocumentRemoveLineBody =>
      'Remove this line from the document?';

  @override
  String get fiscalDocumentRemoveAction => 'Remove';

  @override
  String get fiscalDocumentAddOrderTitle => 'Add order';

  @override
  String get fiscalDocumentAddOrderSearch => 'Search orders';

  @override
  String get fiscalDocumentAddOrderEmpty =>
      'The customer has no completed orders.';

  @override
  String fiscalDocumentOrderAdded(String folio) {
    return 'The lines of order $folio were added.';
  }

  @override
  String get fiscalDocumentAddProductTitle => 'Add product';

  @override
  String get fiscalDocumentAddProductPicker => 'Product';

  @override
  String get fiscalDocumentProductAdded => 'Product added.';

  @override
  String get fiscalDocumentAddRelationTitle => 'Add relation';

  @override
  String get fiscalDocumentRelationType => 'Relation type';

  @override
  String get fiscalDocumentRelationDocument => 'Document';

  @override
  String get fiscalDocumentRelationSearch => 'Search documents';

  @override
  String get fiscalDocumentRelationEmpty => 'There are no documents to relate.';

  @override
  String get fiscalDocumentRelationAdded => 'Relation added.';

  @override
  String get fiscalDocumentRemoveRelationTitle => 'Remove relation';

  @override
  String get fiscalDocumentRemoveRelationBody =>
      'Remove this related document?';

  @override
  String get fiscalDocumentConfirmTitle => 'Confirm document';

  @override
  String fiscalDocumentConfirmBody(String series) {
    return 'The next folio of series $series will be assigned and the document will be sealed. After that it can only be reopened while it is not stamped.';
  }

  @override
  String fiscalDocumentConfirmed(String kind, String folio) {
    return '$kind $folio sealed.';
  }

  @override
  String get fiscalDocumentReopenTitle => 'Reopen document';

  @override
  String fiscalDocumentReopenBody(String folio) {
    return 'The document goes back to draft and keeps folio $folio. The seal is discarded.';
  }

  @override
  String fiscalDocumentReopened(String kind, String folio) {
    return '$kind $folio reopened.';
  }

  @override
  String get fiscalDocumentXmlSaved => 'XML saved.';

  @override
  String get fiscalDocumentUnknownResult =>
      'We do not know if it completed: the connection was lost. The document was refreshed.';

  @override
  String get apiErrorFiscalDocumentNotIssued =>
      'This document has not been stamped yet, so it has no PDF or XML and cannot be cancelled.';

  @override
  String apiErrorFiscalDocumentVersionNotPrintable(String version) {
    return 'This document is CFDI version $version and cannot be printed.';
  }

  @override
  String get apiErrorFiscalDocumentNotStamped =>
      'This document is not stamped, so its PDF cannot be generated.';

  @override
  String get apiErrorFiscalDocumentXmlUnavailable =>
      'The XML of this document is not available.';

  @override
  String get apiErrorFiscalDocumentIssuerHasNoSeries =>
      'The issuer has no series for this type of document. Create one on the issuer and try again.';

  @override
  String apiErrorFiscalDocumentSeriesNotOfType(String batch) {
    return 'Series $batch is not for this type of document.';
  }

  @override
  String get apiErrorFiscalDocumentRecipientNotLinked =>
      'That RFC is not registered on the customer.';

  @override
  String get apiErrorFiscalDocumentFieldNotForType =>
      'Some fields do not apply to this type of document.';

  @override
  String get apiErrorFiscalDocumentUnknownFacility =>
      'The chosen facility does not exist.';

  @override
  String get apiErrorFiscalDocumentSeriesLocked =>
      'The series cannot be changed because the invoice already has a folio.';

  @override
  String apiErrorFiscalDocumentUnknownUsage(String usage) {
    return 'CFDI use $usage does not exist.';
  }

  @override
  String get apiErrorFiscalDocumentIssueDateOutOfRange =>
      'The issue date must be within the last 72 hours and not in the future.';

  @override
  String get apiErrorFiscalDocumentNotDraft =>
      'This document is no longer a draft and cannot be changed.';

  @override
  String get apiErrorFiscalDocumentNotSealed =>
      'Only a sealed document that is not being stamped can be stamped or reopened.';

  @override
  String get apiErrorFiscalDocumentTypeNotSupported =>
      'This type of document cannot be changed here.';

  @override
  String get apiErrorFiscalDocumentOrderNotInvoiceable =>
      'That order cannot be invoiced: it must be completed and not cancelled.';

  @override
  String get apiErrorFiscalDocumentNoInvoiceableLines =>
      'That order has no lines left to invoice.';

  @override
  String get apiErrorFiscalDocumentProductUnpriced =>
      'The product is not on the customer’s price list.';

  @override
  String apiErrorFiscalDocumentQuantityExceedsInvoiceable(String remaining) {
    return 'Only $remaining are left to invoice on this order line.';
  }

  @override
  String apiErrorFiscalDocumentQuantityExceedsInvoiceableLine(
    String line,
    String remaining,
  ) {
    return 'Line $line: only $remaining are left to invoice on this order line.';
  }

  @override
  String get apiErrorFiscalDocumentRelationNotAllowed =>
      'That document cannot be related to this invoice: it must have the same issuer and recipient and the status the relation type requires.';

  @override
  String get apiErrorFiscalDocumentAlreadyRelated =>
      'That document is already related to this invoice.';

  @override
  String get apiErrorFiscalDocumentRelationTypesMixed =>
      'An invoice can only have relations of one type.';

  @override
  String get apiErrorFiscalDocumentNoLines => 'The document has no lines.';

  @override
  String apiErrorFiscalDocumentLineMissingSatKey(String line) {
    return 'Line $line: the SAT product key or unit is missing.';
  }

  @override
  String apiErrorFiscalDocumentLineQuantityNotPositive(String line) {
    return 'Line $line: the quantity must be greater than 0.';
  }

  @override
  String get apiErrorFiscalDocumentRecipientIncomplete =>
      'The recipient’s tax data is incomplete (name, regime or postal code).';

  @override
  String get apiErrorFiscalDocumentNoValidCertificate =>
      'The issuer has no valid certificate to seal or cancel with.';

  @override
  String apiErrorFiscalDocumentSeriesMissing(String batch) {
    return 'Series $batch no longer exists.';
  }

  @override
  String get apiErrorFiscalDocumentCertificateCannotSign =>
      'The issuer’s certificate cannot sign this document.';

  @override
  String get apiValidationFiscalDocumentTaxRateInvalid =>
      'The VAT rate must be 16 %, 0 % or exempt.';

  @override
  String get apiValidationFiscalDocumentPaymentFormUnknown =>
      'The payment form is not valid.';

  @override
  String apiResourceFiscalDocumentLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'invoice lines',
      one: 'invoice line',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderFiscalDocumentLine => 'feminine';

  @override
  String apiResourceFiscalDocumentRelation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'related documents',
      one: 'related document',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderFiscalDocumentRelation => 'masculine';

  @override
  String fiscalDocumentAddOrderIntro(String customer) {
    return 'Completed orders of $customer. Pick the one to invoice.';
  }

  @override
  String get fiscalDocumentAddOrderColFolio => 'Order';

  @override
  String get fiscalDocumentAddOrderColDate => 'Date';

  @override
  String get fiscalDocumentAddOrderColTotal => 'Total';

  @override
  String get fiscalDocumentAddOrderLoadMore => 'Load more';

  @override
  String get fiscalDocumentHeaderIssuedOnConfirm => 'When confirmed';

  @override
  String get fiscalDocumentHeaderPickIssued => 'Pick date and time';

  @override
  String get fiscalDocumentHeaderReferenceTooLong =>
      'The reference can be up to 25 characters.';

  @override
  String get fiscalDocumentHeaderCommentTooLong =>
      'The notes can be up to 1000 characters.';

  @override
  String get fiscalDocumentHeaderTermsPue => 'PUE';

  @override
  String get fiscalDocumentHeaderTermsPpd => 'PPD';

  @override
  String get fiscalDocumentLineEditTooltip => 'Edit line';

  @override
  String get fiscalDocumentLineRemoveTooltip => 'Remove line';

  @override
  String get fiscalDocumentRelationRemoveTooltip => 'Remove relation';

  @override
  String get navInventoryGroup => 'Inventory';

  @override
  String get navInventoryReceipts => 'Warehouse receipts';

  @override
  String inventoryReceiptTitle(String folio) {
    return 'Receipt $folio';
  }

  @override
  String inventoryReceiptTitleDraft(String id) {
    return 'Receipt · Draft #$id';
  }

  @override
  String inventoryDocumentDraftFolio(String id) {
    return 'Draft #$id';
  }

  @override
  String get inventoryDocumentStatusDraft => 'Draft';

  @override
  String get inventoryDocumentStatusCompleted => 'Confirmed';

  @override
  String get inventoryDocumentStatusCancelled => 'Cancelled';

  @override
  String get inventoryReceiptColFolio => 'Folio';

  @override
  String get inventoryReceiptColWarehouse => 'Warehouse';

  @override
  String get inventoryReceiptColFacility => 'Facility';

  @override
  String get inventoryReceiptColPurchaseOrder => 'Purchase order';

  @override
  String get inventoryReceiptColStatus => 'Status';

  @override
  String get inventoryReceiptColCreator => 'Created by';

  @override
  String get inventoryReceiptColDate => 'Date';

  @override
  String get inventoryReceiptFacetStatus => 'Status';

  @override
  String get inventoryReceiptFacetWarehouse => 'Warehouse';

  @override
  String get inventoryReceiptFacetAll => 'All';

  @override
  String get inventoryReceiptEmpty => 'There are no warehouse receipts';

  @override
  String get inventoryReceiptFilteredEmpty => 'No receipt matches the filters.';

  @override
  String get inventoryReceiptFactStatus => 'Status';

  @override
  String get inventoryReceiptFactFolio => 'Folio';

  @override
  String get inventoryReceiptFactWarehouse => 'Warehouse';

  @override
  String get inventoryReceiptFactFacility => 'Facility';

  @override
  String get inventoryReceiptFactPurchaseOrder => 'Purchase order';

  @override
  String get inventoryReceiptFactComment => 'Notes';

  @override
  String get inventoryReceiptFactCreatedBy => 'Created by';

  @override
  String get inventoryReceiptFactModifiedBy => 'Modified by';

  @override
  String get inventoryReceiptLinesTitle => 'Lines';

  @override
  String get inventoryReceiptLineColCode => 'Code';

  @override
  String get inventoryReceiptLineColProduct => 'Product';

  @override
  String get inventoryReceiptLineColQuantity => 'Quantity received';

  @override
  String get inventoryReceiptLineColOrdered => 'Ordered';

  @override
  String get inventoryReceiptLineColElsewhere => 'Received in other receipts';

  @override
  String get inventoryReceiptLinesEmpty => 'Add the products received.';

  @override
  String get inventoryDocumentNoFacility =>
      'Your user has no facility assigned.';

  @override
  String get inventoryReceiptNewAction => 'New receipt';

  @override
  String get inventoryReceiptEditHeader => 'Edit header';

  @override
  String get inventoryReceiptAddProduct => 'Add product';

  @override
  String get inventoryReceiptConfirm => 'Confirm';

  @override
  String get inventoryReceiptCancel => 'Cancel receipt';

  @override
  String get inventoryReceiptComplementary => 'Complementary receipt';

  @override
  String get inventoryReceiptLineEditTooltip => 'Edit quantity';

  @override
  String get inventoryReceiptLineRemoveTooltip => 'Remove line';

  @override
  String get inventoryReceiptNewTitle => 'New receipt';

  @override
  String get inventoryReceiptNewSubmit => 'Create';

  @override
  String get inventoryReceiptEditHeaderTitle => 'Edit header';

  @override
  String get inventoryReceiptFieldWarehouse => 'Warehouse';

  @override
  String get inventoryReceiptFieldComment => 'Notes';

  @override
  String get inventoryReceiptFieldProduct => 'Product';

  @override
  String get inventoryReceiptFieldQuantity => 'Quantity';

  @override
  String get inventoryReceiptWarehouseFixed => 'Fixed: purchase order';

  @override
  String get inventoryReceiptAddProductTitle => 'Add product';

  @override
  String get inventoryReceiptAddProductSubmit => 'Add';

  @override
  String get inventoryReceiptLineQuantityTitle => 'Line quantity';

  @override
  String inventoryReceiptRemoveTitle(String product) {
    return 'Remove $product from the receipt?';
  }

  @override
  String get inventoryReceiptRemoveBody =>
      'The line is removed from the draft.';

  @override
  String get inventoryReceiptRemoveAction => 'Remove';

  @override
  String get inventoryReceiptConfirmTitle => 'Confirm receipt';

  @override
  String get inventoryReceiptConfirmBody =>
      'Confirming the receipt assigns a folio and adds the stock to the warehouse. It can\'t be edited afterwards.';

  @override
  String get inventoryReceiptConfirmAction => 'Confirm';

  @override
  String get inventoryReceiptBack => 'Back';

  @override
  String get inventoryReceiptCancelTitle => 'Cancel receipt';

  @override
  String get inventoryReceiptCancelDraftBody =>
      'Cancelling the draft adds no stock to the warehouse.';

  @override
  String get inventoryReceiptCancelCompletedBody =>
      'Cancelling the receipt removes from the warehouse the stock it added.';

  @override
  String get inventoryReceiptCancelAction => 'Cancel receipt';

  @override
  String inventoryReceiptOverReceipt(
    String code,
    String excess,
    String received,
    String ordered,
  ) {
    return 'Over-received $code: $excess (received $received of $ordered ordered)';
  }

  @override
  String get inventoryReceiptCostNotice =>
      'Costs were updated with exceptions.';

  @override
  String get inventoryReceiptCostNoticeClose => 'Close';

  @override
  String inventoryReceiptCostZeroPrice(String code) {
    return '$code is priced at 0; its cost was not changed.';
  }

  @override
  String inventoryReceiptCostNotRestored(String code, String receipt) {
    return 'The cost of $code was not restored: receipt $receipt changed it since.';
  }

  @override
  String inventoryReceiptRefusalProduct(String code) {
    return 'Product: $code';
  }

  @override
  String get inventoryReceiptQuantityInvalid =>
      'Enter a quantity greater than 0.';

  @override
  String get inventoryReceiptBackToList => 'Back to warehouse receipts';

  @override
  String get navInventoryIssues => 'Warehouse issues';

  @override
  String inventoryIssueTitle(String folio) {
    return 'Issue $folio';
  }

  @override
  String inventoryIssueTitleDraft(String id) {
    return 'Issue · Draft #$id';
  }

  @override
  String get inventoryIssueColFolio => 'Folio';

  @override
  String get inventoryIssueColWarehouse => 'Warehouse';

  @override
  String get inventoryIssueColFacility => 'Facility';

  @override
  String get inventoryIssueColStatus => 'Status';

  @override
  String get inventoryIssueColCreator => 'Created by';

  @override
  String get inventoryIssueColDate => 'Date';

  @override
  String get inventoryIssueFacetStatus => 'Status';

  @override
  String get inventoryIssueFacetWarehouse => 'Warehouse';

  @override
  String get inventoryIssueFacetAll => 'All';

  @override
  String get inventoryIssueEmpty => 'There are no warehouse issues';

  @override
  String get inventoryIssueFilteredEmpty => 'No issue matches the filters.';

  @override
  String get inventoryIssueFactStatus => 'Status';

  @override
  String get inventoryIssueFactFolio => 'Folio';

  @override
  String get inventoryIssueFactWarehouse => 'Warehouse';

  @override
  String get inventoryIssueFactFacility => 'Facility';

  @override
  String inventoryIssueFactSupplierReturn(String id) {
    return 'Supplier return #$id';
  }

  @override
  String get inventoryIssueFactComment => 'Reason / notes';

  @override
  String get inventoryIssueFactCreatedBy => 'Created by';

  @override
  String get inventoryIssueFactModifiedBy => 'Modified by';

  @override
  String get inventoryIssueLinesTitle => 'Lines';

  @override
  String get inventoryIssueLineColCode => 'Code';

  @override
  String get inventoryIssueLineColProduct => 'Product';

  @override
  String get inventoryIssueLineColQuantity => 'Quantity';

  @override
  String get inventoryIssueLinesEmpty =>
      'Add the products that leave the warehouse.';

  @override
  String get inventoryIssueNewAction => 'New issue';

  @override
  String get inventoryIssueEditHeader => 'Edit header';

  @override
  String get inventoryIssueAddProduct => 'Add product';

  @override
  String get inventoryIssueConfirm => 'Confirm';

  @override
  String get inventoryIssueCancel => 'Cancel';

  @override
  String get inventoryIssueLineEditTooltip => 'Edit quantity';

  @override
  String get inventoryIssueLineRemoveTooltip => 'Remove line';

  @override
  String get inventoryIssueNewTitle => 'New issue';

  @override
  String get inventoryIssueNewSubmit => 'Create';

  @override
  String get inventoryIssueEditHeaderTitle => 'Edit header';

  @override
  String get inventoryIssueFieldWarehouse => 'Warehouse';

  @override
  String get inventoryIssueFieldComment => 'Reason / notes';

  @override
  String get inventoryIssueFieldCommentHint =>
      'e.g. shrinkage, damage, internal use';

  @override
  String get inventoryIssueFieldProduct => 'Product';

  @override
  String get inventoryIssueFieldQuantity => 'Quantity';

  @override
  String get inventoryIssueAddProductTitle => 'Add product';

  @override
  String get inventoryIssueAddProductSubmit => 'Add';

  @override
  String get inventoryIssueLineQuantityTitle => 'Line quantity';

  @override
  String inventoryIssueRemoveTitle(String product) {
    return 'Remove $product from the issue?';
  }

  @override
  String get inventoryIssueRemoveBody => 'The line is deleted from the draft.';

  @override
  String get inventoryIssueRemoveAction => 'Remove';

  @override
  String get inventoryIssueConfirmTitle => 'Confirm issue';

  @override
  String inventoryIssueConfirmBody(String warehouse) {
    return 'Confirming assigns a folio and takes the stock out of $warehouse. It can\'t be edited afterwards.';
  }

  @override
  String get inventoryIssueConfirmAction => 'Confirm';

  @override
  String get inventoryIssueCancelTitle => 'Cancel issue';

  @override
  String get inventoryIssueCancelDraftBody => 'Cancel the draft';

  @override
  String inventoryIssueCancelCompletedBody(String folio, String warehouse) {
    return 'Cancelling issue $folio puts back into $warehouse the stock it took out.';
  }

  @override
  String get inventoryIssueCancelAction => 'Cancel issue';

  @override
  String inventoryIssueRefusalProductWarehouse(String code, String warehouse) {
    return 'Product: $code · Warehouse: $warehouse';
  }

  @override
  String get inventoryIssueQuantityInvalid =>
      'Enter a quantity greater than 0.';

  @override
  String get inventoryIssueBackToList => 'Back to warehouse issues';

  @override
  String get inventoryIssueBack => 'Back';

  @override
  String get apiErrorInventoryReceiptWarehouseFixed =>
      'A purchase order\'s receipt can\'t move to another warehouse.';

  @override
  String get apiErrorInventoryReceiptComplementaryNoPurchaseOrder =>
      'The receipt isn\'t linked to a purchase order.';

  @override
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderCancelled =>
      'The purchase order is cancelled.';

  @override
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderNotCompleted =>
      'The purchase order isn\'t completed yet.';

  @override
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderFullyReceived =>
      'The purchase order was already fully received in this warehouse.';

  @override
  String get apiErrorInventoryReceiptComplementaryUnavailable =>
      'No complementary receipt can be created for this receipt.';

  @override
  String apiErrorInventoryDocumentInsufficientStock(
    String requested,
    String available,
  ) {
    return 'Not enough stock: $requested required, $available available.';
  }

  @override
  String apiErrorInventoryDocumentNoLines(String gender, String resource) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine': 'The $resource has no lines.',
      'other': 'The $resource has no lines.',
    });
    return '$_temp0';
  }

  @override
  String apiErrorInventoryDocumentLineWithoutQuantity(String product) {
    return 'Line $product has no quantity.';
  }

  @override
  String apiErrorInventoryDocumentAlreadyCancelled(
    String gender,
    String resource,
  ) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'feminine': 'The $resource is already cancelled.',
      'other': 'The $resource is already cancelled.',
    });
    return '$_temp0';
  }

  @override
  String apiErrorProductNotStockable(String product) {
    return 'Product $product isn\'t stockable.';
  }

  @override
  String get apiErrorFacilityNoInTransitLocation =>
      'The facility has no in-transit location configured.';

  @override
  String get apiErrorStatusFilterUnsupported =>
      'The status filter isn\'t valid.';

  @override
  String get apiErrorInventoryTransferSameWarehouse =>
      'The source and destination warehouses must be different.';

  @override
  String get apiErrorInventoryTransferNotInTransit =>
      'The transfer isn\'t in transit.';

  @override
  String apiErrorInventoryTransferOverReceived(
    String product_code,
    String received,
    String outstanding,
  ) {
    return '$product_code: trying to receive $received but only $outstanding are outstanding.';
  }

  @override
  String get apiErrorInventoryTransferLineRepeated =>
      'A line is being received more than once.';

  @override
  String get apiErrorSalesOrderNotConfirmed =>
      'The order isn\'t confirmed or is cancelled.';

  @override
  String get apiValidationInventoryTransferDuplicateLine =>
      'A line is being received more than once.';

  @override
  String get navInventoryTransfers => 'Transfers';

  @override
  String inventoryTransferTitle(String folio) {
    return 'Transfer $folio';
  }

  @override
  String inventoryTransferTitleDraft(String id) {
    return 'Transfer · Draft #$id';
  }

  @override
  String get inventoryTransferStatusDraft => 'Draft';

  @override
  String get inventoryTransferStatusInTransit => 'In transit';

  @override
  String get inventoryTransferStatusReceived => 'Received';

  @override
  String get inventoryTransferStatusCancelled => 'Cancelled';

  @override
  String get inventoryTransferColFolio => 'Folio';

  @override
  String get inventoryTransferColSource => 'Source';

  @override
  String get inventoryTransferColDestination => 'Destination';

  @override
  String get inventoryTransferColFacility => 'Facility';

  @override
  String get inventoryTransferColStatus => 'Status';

  @override
  String get inventoryTransferColCreator => 'Created by';

  @override
  String get inventoryTransferColDate => 'Date';

  @override
  String get inventoryTransferFacetStatus => 'Status';

  @override
  String get inventoryTransferFacetWarehouse =>
      'Warehouse (source or destination)';

  @override
  String get inventoryTransferFacetAll => 'All';

  @override
  String get inventoryTransferEmpty => 'There are no transfers';

  @override
  String get inventoryTransferFilteredEmpty =>
      'No transfer matches the filters.';

  @override
  String get inventoryTransferInTransitAction => 'In transit';

  @override
  String get inventoryTransferNewAction => 'New transfer';

  @override
  String get inventoryTransferFactStatus => 'Status';

  @override
  String get inventoryTransferFactFolio => 'Folio';

  @override
  String get inventoryTransferFactSource => 'Source';

  @override
  String get inventoryTransferFactDestination => 'Destination';

  @override
  String get inventoryTransferFactFacility => 'Facility';

  @override
  String get inventoryTransferFactNotes => 'Notes';

  @override
  String get inventoryTransferFactCreatedBy => 'Created by';

  @override
  String get inventoryTransferFactModifiedBy => 'Modified by';

  @override
  String get inventoryTransferLinesTitle => 'Lines';

  @override
  String get inventoryTransferLineColCode => 'Code';

  @override
  String get inventoryTransferLineColProduct => 'Product';

  @override
  String get inventoryTransferLineColQuantity => 'Quantity';

  @override
  String get inventoryTransferLineColSent => 'Sent';

  @override
  String get inventoryTransferLineColReceived => 'Received';

  @override
  String get inventoryTransferLineColOutstanding => 'Outstanding';

  @override
  String get inventoryTransferLinesEmpty =>
      'Add the products to be transferred.';

  @override
  String get inventoryTransferEditHeader => 'Edit header';

  @override
  String get inventoryTransferAddProduct => 'Add product';

  @override
  String get inventoryTransferAddFromOrder => 'Add from order';

  @override
  String get inventoryTransferDispatch => 'Dispatch';

  @override
  String get inventoryTransferReceive => 'Receive';

  @override
  String get inventoryTransferClose => 'Close outstanding';

  @override
  String get inventoryTransferCancel => 'Cancel';

  @override
  String get inventoryTransferLineEditTooltip => 'Edit quantity';

  @override
  String get inventoryTransferLineRemoveTooltip => 'Remove line';

  @override
  String get inventoryTransferNewTitle => 'New transfer';

  @override
  String get inventoryTransferNewSubmit => 'Create';

  @override
  String get inventoryTransferEditHeaderTitle => 'Edit header';

  @override
  String get inventoryTransferFieldSource => 'Source';

  @override
  String get inventoryTransferFieldDestination => 'Destination';

  @override
  String get inventoryTransferFieldNotes => 'Notes';

  @override
  String get inventoryTransferFieldProduct => 'Product';

  @override
  String get inventoryTransferFieldQuantity => 'Quantity';

  @override
  String get inventoryTransferAddProductTitle => 'Add product';

  @override
  String get inventoryTransferAddProductSubmit => 'Add';

  @override
  String get inventoryTransferLineQuantityTitle => 'Line quantity';

  @override
  String get inventoryTransferQuantityInvalid =>
      'Enter a quantity greater than 0.';

  @override
  String inventoryTransferRemoveTitle(String product) {
    return 'Remove $product from the transfer?';
  }

  @override
  String get inventoryTransferRemoveBody =>
      'The line is deleted from the draft.';

  @override
  String get inventoryTransferRemoveAction => 'Remove';

  @override
  String get inventoryTransferDispatchTitle => 'Dispatch transfer';

  @override
  String inventoryTransferDispatchBody(String source, String destination) {
    return 'Dispatching assigns a folio and takes the stock out of $source. It stays in transit until $destination receives it. It can\'t be edited afterwards.';
  }

  @override
  String get inventoryTransferDispatchAction => 'Dispatch';

  @override
  String get inventoryTransferCloseTitle => 'Close outstanding';

  @override
  String inventoryTransferCloseBody(int count, String source) {
    return 'What is outstanding ($count lines) goes back to $source and the transfer becomes Received. If it was lost, record it afterwards with a warehouse issue.';
  }

  @override
  String get inventoryTransferCloseAction => 'Close outstanding';

  @override
  String get inventoryTransferCancelTitle => 'Cancel transfer';

  @override
  String get inventoryTransferCancelDraftBody => 'Cancel the draft';

  @override
  String inventoryTransferCancelDispatchedBody(String folio, String source) {
    return 'Cancelling transfer $folio puts back into $source what is in transit.';
  }

  @override
  String inventoryTransferCancelDispatchedReceivedBody(
    String folio,
    String source,
    String destination,
  ) {
    return 'Cancelling transfer $folio puts back into $source what is in transit and what $destination already received.';
  }

  @override
  String get inventoryTransferCancelAction => 'Cancel transfer';

  @override
  String get inventoryTransferBack => 'Back';

  @override
  String inventoryTransferRefusalProductWarehouse(
    String code,
    String warehouse,
  ) {
    return 'Product: $code · Warehouse: $warehouse';
  }

  @override
  String get inventoryTransferBackToList => 'Back to transfers';

  @override
  String inventoryTransferReceiveTitle(String folio) {
    return 'Receive transfer $folio';
  }

  @override
  String get inventoryTransferReceiveHint =>
      'Leave 0 for what didn\'t arrive. What is outstanding can be received later.';

  @override
  String get inventoryTransferReceiveColReceive => 'Receive';

  @override
  String inventoryTransferReceiveMax(String outstanding) {
    return 'Maximum $outstanding';
  }

  @override
  String get inventoryTransferReceiveSubmit => 'Receive';

  @override
  String get inventoryTransferReceiveInvalid =>
      'Enter a quantity of 0 or more.';

  @override
  String get inventoryTransferFromOrderTitle => 'Add from order';

  @override
  String get inventoryTransferFromOrderField => 'Order';

  @override
  String inventoryTransferFromOrderOption(
    String folio,
    String customer,
    String date,
  ) {
    return '$folio · $customer · $date';
  }

  @override
  String get inventoryTransferFromOrderSubmit => 'Add';

  @override
  String inventoryTransferFromOrderAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count products to the transfer.',
      one: 'Added 1 product to the transfer.',
    );
    return '$_temp0 Products already on it were left unchanged.';
  }

  @override
  String get inventoryTransferFromOrderNone =>
      'The order\'s products were already on the transfer.';

  @override
  String get inventoryTransferInTransitTitle => 'In transit';

  @override
  String inventoryTransferInTransitTitleFacility(String facility) {
    return 'In transit · $facility';
  }

  @override
  String get inventoryTransferInTransitFacilityField => 'Facility';

  @override
  String get inventoryTransferInTransitMyFacility => 'My facility';

  @override
  String get inventoryTransferInTransitSelectFacility => 'Select a facility.';

  @override
  String get inventoryTransferInTransitByProduct => 'By product';

  @override
  String get inventoryTransferInTransitByTransfer => 'By transfer';

  @override
  String get inventoryTransferInTransitEmpty => 'There is no stock in transit.';

  @override
  String get apiErrorInventoryCountBatchInvalid =>
      'Some products in the list cannot be recorded. Check the marked rows.';

  @override
  String get apiErrorInventoryCountConfirmedCannotCancel =>
      'A confirmed count cannot be cancelled. Correct it with a new count.';

  @override
  String get apiErrorInventoryCountLineProductUnknown =>
      'The product does not exist.';

  @override
  String get apiErrorInventoryCountLineNotStockable =>
      'The product is not stockable.';

  @override
  String get apiErrorInventoryCountLineRepeated =>
      'The product is repeated in the list.';

  @override
  String get apiErrorInventoryCountLineProductReference =>
      'Name the product by its id or by its code, not both.';

  @override
  String apiResourceInventoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'counts',
      one: 'count',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderInventoryCount => 'masculine';

  @override
  String get navInventoryCounts => 'Physical counts';

  @override
  String get inventoryCountStatusDraft => 'Draft';

  @override
  String get inventoryCountStatusCompleted => 'Confirmed';

  @override
  String get inventoryCountStatusCancelled => 'Cancelled';

  @override
  String get inventoryCountColFolio => 'Folio';

  @override
  String get inventoryCountColWarehouse => 'Warehouse';

  @override
  String get inventoryCountColFacility => 'Facility';

  @override
  String get inventoryCountColStatus => 'Status';

  @override
  String get inventoryCountColCreatedBy => 'Created by';

  @override
  String get inventoryCountColDate => 'Date';

  @override
  String get inventoryCountFilterStatus => 'Status';

  @override
  String get inventoryCountFilterWarehouse => 'Warehouse';

  @override
  String get inventoryCountFilterAll => 'All';

  @override
  String get inventoryCountListEmpty => 'There are no physical counts';

  @override
  String inventoryCountDraftFolio(String id) {
    return 'Draft #$id';
  }

  @override
  String inventoryCountTitleDraft(String id) {
    return 'Count · Draft #$id';
  }

  @override
  String inventoryCountTitle(String folio) {
    return 'Count $folio';
  }

  @override
  String get inventoryCountFactComment => 'Comment';

  @override
  String get inventoryCountFactLines => 'Lines';

  @override
  String get inventoryCountLineColCode => 'Code';

  @override
  String get inventoryCountLineColProduct => 'Product';

  @override
  String get inventoryCountLineColCounted => 'Counted';

  @override
  String get inventoryCountLineColExpected => 'Expected';

  @override
  String get inventoryCountLineColDifference => 'Difference';

  @override
  String get inventoryCountLinesSearchHint => 'Search by code or name';

  @override
  String get inventoryCountDraftEmpty =>
      'Record what you counted. Expected stock is shown on confirm.';

  @override
  String get inventoryCountQuickEntryTitle => 'Quick entry';

  @override
  String get inventoryCountQuickEntryCode => 'Code';

  @override
  String get inventoryCountQuickEntryQuantity => 'Quantity';

  @override
  String get inventoryCountQuickEntrySubmit => 'Record';

  @override
  String inventoryCountQuickEntryFeedback(
    String code,
    String name,
    String newQty,
  ) {
    return '$code $name: $newQty';
  }

  @override
  String inventoryCountQuickEntryFeedbackReplaced(
    String code,
    String name,
    String oldQty,
    String newQty,
  ) {
    return '$code $name: $oldQty → $newQty (replaced)';
  }

  @override
  String get inventoryCountActionNew => 'New count';

  @override
  String get inventoryCountActionEditHeader => 'Edit header';

  @override
  String get inventoryCountActionPaste => 'Paste list';

  @override
  String get inventoryCountActionAddProduct => 'Add product';

  @override
  String get inventoryCountActionConfirm => 'Confirm';

  @override
  String get inventoryCountActionCancel => 'Cancel';

  @override
  String get inventoryCountDialogNewTitle => 'New count';

  @override
  String get inventoryCountDialogEditTitle => 'Edit header';

  @override
  String get inventoryCountDialogAddTitle => 'Add product';

  @override
  String get inventoryCountDialogQuantityTitle => 'Counted quantity';

  @override
  String get inventoryCountDialogRemoveTitle => 'Remove line';

  @override
  String inventoryCountDialogRemoveBody(String name) {
    return 'Remove $name from the count?';
  }

  @override
  String get inventoryCountDialogPasteTitle => 'Paste list';

  @override
  String get inventoryCountDialogConfirmTitle => 'Confirm count';

  @override
  String get inventoryCountDialogCancelTitle => 'Cancel draft';

  @override
  String get inventoryCountFieldWarehouse => 'Warehouse';

  @override
  String get inventoryCountFieldComment => 'Comment';

  @override
  String get inventoryCountFieldProduct => 'Product';

  @override
  String get inventoryCountFieldCounted => 'Counted';

  @override
  String get inventoryCountDialogCreate => 'Create';

  @override
  String get inventoryCountDialogSave => 'Save';

  @override
  String get inventoryCountDialogRecord => 'Record';

  @override
  String get inventoryCountDialogBack => 'Back';

  @override
  String get inventoryCountDialogClose => 'Close';

  @override
  String get inventoryCountDialogCancelDraft => 'Cancel draft';

  @override
  String inventoryCountReplaceNote(String qty) {
    return 'Already counted: $qty. It will be replaced.';
  }

  @override
  String inventoryCountConfirmBody(String warehouse) {
    return 'On confirm, the stock of $warehouse is set to the counted quantities and a folio is assigned. A confirmed count cannot be cancelled: correct it with a new count.';
  }

  @override
  String get inventoryCountConfirmIncludeUncounted =>
      'Count as 0 the products with stock that are not in this count';

  @override
  String inventoryCountCancelBody(String id) {
    return 'Cancel draft #$id. No stock is changed.';
  }

  @override
  String get inventoryCountPasteInstructions =>
      'Paste two columns from your spreadsheet: code and quantity.';

  @override
  String inventoryCountPasteSummary(String n, String m) {
    return '$n rows read · $m with problems';
  }

  @override
  String inventoryCountPasteProblemRow(int row, String reason) {
    return 'Row $row: $reason';
  }

  @override
  String get inventoryCountPasteProblemFieldCount =>
      'separate the code and the quantity';

  @override
  String get inventoryCountPasteProblemMissingCode => 'the code is missing';

  @override
  String get inventoryCountPasteProblemNotANumber =>
      'the quantity is not a number';

  @override
  String get inventoryCountPasteProblemNegative => 'the quantity is negative';

  @override
  String get inventoryCountPasteProblemTooManyDecimals =>
      'the quantity has more than 4 decimals';

  @override
  String get inventoryCountPasteProblemRepeatedCode => 'the code is repeated';

  @override
  String get inventoryCountPasteSend => 'Send';

  @override
  String get inventoryCountPasteSending => 'Sending…';

  @override
  String inventoryCountPasteProgress(String sent, String total) {
    return '$sent of $total';
  }

  @override
  String inventoryCountPasteBatch(int k, int n) {
    return 'Batch $k of $n';
  }

  @override
  String inventoryCountPasteStopped(String applied, String total) {
    return 'Sending stopped. $applied of $total rows were applied.';
  }

  @override
  String inventoryCountPasteRejectedHeading(int k) {
    return 'Codes rejected in batch $k:';
  }

  @override
  String inventoryCountPasteRejectedLine(String code, String reason, int row) {
    return '$code  $reason (row $row)';
  }

  @override
  String get inventoryCountPasteSafeNote =>
      'Fix your list and paste it again: quantities are replaced, not added.';

  @override
  String get inventoryCountWarningsTitle => 'Count confirmed with warnings';

  @override
  String get inventoryCountWarningsNegativeHeading =>
      'Counted below what is reserved:';

  @override
  String get inventoryCountWarningsCorrectedHeading =>
      'Also corrected by another count of this warehouse:';

  @override
  String inventoryCountWarningsNegativeLine(
    String code,
    String counted,
    String reserved,
    String available,
  ) {
    return '$code  counted $counted · reserved $reserved · available $available';
  }

  @override
  String inventoryCountWarningsCorrectedLine(String code, String serial) {
    return '$code  count $serial';
  }

  @override
  String get inventoryCountWarningsDismiss => 'Dismiss warnings';

  @override
  String get inventoryCountQuantityInvalid =>
      'Enter a quantity of 0 or more, with up to 4 decimals.';

  @override
  String get inventoryCountLineEditTooltip => 'Edit quantity';

  @override
  String get inventoryCountLineRemoveTooltip => 'Remove line';

  @override
  String get inventoryCountRemoveAction => 'Remove';

  @override
  String get inventoryCountBackToList => 'Back to physical counts';

  @override
  String get inventoryCountFactModifiedBy => 'Modified by';

  @override
  String get apiErrorKardexRangeReversed =>
      'The end date cannot be before the start date.';

  @override
  String apiErrorKardexRangeTooLong(String maxDays) {
    return 'The range cannot exceed $maxDays days.';
  }

  @override
  String get navInventoryStock => 'Stock';

  @override
  String get navInventoryKardex => 'Kardex';

  @override
  String get inventoryStockColumnCode => 'Code';

  @override
  String get inventoryStockColumnProduct => 'Product';

  @override
  String get inventoryStockColumnOnHand => 'On hand';

  @override
  String get inventoryStockColumnReserved => 'Reserved';

  @override
  String get inventoryStockColumnAvailable => 'Available';

  @override
  String get inventoryStockColumnIncoming => 'Incoming';

  @override
  String get inventoryStockFilterWarehouse => 'Warehouse';

  @override
  String get inventoryStockFilterIncludeZero => 'Show out of stock';

  @override
  String get inventoryStockSelectionWarehouse => 'Warehouse';

  @override
  String get inventoryStockPickWarehousePrompt =>
      'Choose a warehouse to see its stock.';

  @override
  String get inventoryStockPickWarehouseButton => 'Choose warehouse';

  @override
  String get inventoryStockEmpty => 'This warehouse has no stock.';

  @override
  String get inventoryStockFilteredEmpty => 'No product matches the search.';

  @override
  String get inventoryStockSearchLabel => 'Search by code or name';

  @override
  String inventoryStockProductTitle(String code, String name) {
    return 'Stock · $code $name';
  }

  @override
  String get inventoryStockColumnWarehouse => 'Warehouse';

  @override
  String get inventoryStockColumnFacility => 'Facility';

  @override
  String get inventoryStockTotalOnHand => 'On hand';

  @override
  String get inventoryStockTotalReserved => 'Reserved';

  @override
  String get inventoryStockTotalAvailable => 'Available';

  @override
  String get inventoryStockTotalIncoming => 'Incoming';

  @override
  String get inventoryStockViewKardex => 'View kardex';

  @override
  String get inventoryStockInTransitHeading => 'In transit';

  @override
  String get inventoryStockProductEmpty =>
      'This product has no stock in any warehouse.';

  @override
  String get inventoryKardexFilterProduct => 'Product';

  @override
  String get inventoryKardexFilterWarehouse => 'Warehouse';

  @override
  String get inventoryKardexFilterRange => 'Range';

  @override
  String get inventoryKardexSelectionProduct => 'Product';

  @override
  String get inventoryKardexSelectionWarehouse => 'Warehouse';

  @override
  String get inventoryKardexSelectionRange => 'Range';

  @override
  String get inventoryKardexSummaryOpening => 'Opening balance';

  @override
  String get inventoryKardexSummaryIn => 'Inflows';

  @override
  String get inventoryKardexSummaryOut => 'Outflows';

  @override
  String get inventoryKardexSummaryClosing => 'Closing balance';

  @override
  String get inventoryKardexColumnDate => 'Date';

  @override
  String get inventoryKardexColumnSource => 'Source';

  @override
  String get inventoryKardexColumnDocument => 'Document';

  @override
  String get inventoryKardexColumnIn => 'In';

  @override
  String get inventoryKardexColumnOut => 'Out';

  @override
  String get inventoryKardexColumnBalance => 'Balance';

  @override
  String get inventoryKardexIncompletePrompt =>
      'Choose a product and a warehouse to see its kardex.';

  @override
  String get inventoryKardexIncompleteButton => 'Choose';

  @override
  String get inventoryKardexRangeReversed =>
      'The end date cannot be before the start date.';

  @override
  String inventoryKardexRangeTooLong(String max) {
    return 'The range cannot exceed $max days.';
  }

  @override
  String get inventoryKardexEmpty => 'No movements in this range.';

  @override
  String get inventoryKardexSourceSalesOrder => 'Order';

  @override
  String get inventoryKardexSourceSalesReturn => 'Return';

  @override
  String get inventoryKardexSourceWarehouseIssue => 'Warehouse issue';

  @override
  String get inventoryKardexSourceWarehouseReceipt => 'Warehouse receipt';

  @override
  String get inventoryKardexSourceTransfer => 'Transfer';

  @override
  String get inventoryKardexSourcePurchaseOrder => 'Purchase order';

  @override
  String get inventoryKardexSourceLegacyAdjustment =>
      'Adjustment (legacy system)';

  @override
  String get inventoryKardexSourceDeliveryItinerary => 'Delivery itinerary';

  @override
  String get inventoryKardexSourceCount => 'Physical count';

  @override
  String get inventoryKardexSourceCounterDelivery => 'Counter delivery';

  @override
  String get inventoryKardexSourceFallback => 'Movement';

  @override
  String get catalogViewStockButton => 'View stock';

  @override
  String get fiscalDocumentStatusStamping => 'Stamping';

  @override
  String get fiscalDocumentStatusCancellationPending => 'Cancellation pending';

  @override
  String get fiscalDocumentBannerSealedStampOrReopen =>
      'Sealed, no fiscal validity yet. Stamp it to give it fiscal validity, or reopen it if it needs correcting (it keeps its folio).';

  @override
  String get fiscalDocumentBannerSealedStamp =>
      'Sealed, no fiscal validity yet. Stamp it to give it fiscal validity.';

  @override
  String fiscalDocumentBannerStamping(String since) {
    return 'Stamping since $since. The PAC has not confirmed the result yet; the system checks every 10 minutes, or you can check now.';
  }

  @override
  String fiscalDocumentBannerStampingNoRefresh(String since) {
    return 'Stamping since $since. The PAC has not confirmed the result yet; the system checks every 10 minutes.';
  }

  @override
  String fiscalDocumentBannerCancellationPending(String requested) {
    return 'Cancellation requested on $requested. SAT is waiting for the receiver to accept it; meanwhile the document remains valid.';
  }

  @override
  String get fiscalDocumentBannerCancellationPendingNoDate =>
      'Cancellation in process. SAT is waiting for the receiver to accept it; meanwhile the document remains valid.';

  @override
  String get fiscalDocumentFactSatCertificate => 'SAT certificate';

  @override
  String get fiscalDocumentFactProviderRfc => 'PAC';

  @override
  String get fiscalDocumentFactSubstitution => 'Replaced by';

  @override
  String get fiscalDocumentSimulatedBadge =>
      'Simulated stamp, no fiscal validity';

  @override
  String get fiscalDocumentStampAction => 'Stamp';

  @override
  String get fiscalDocumentCancelCfdiAction => 'Cancel with SAT';

  @override
  String get fiscalDocumentRefreshAction => 'Check status';

  @override
  String get fiscalDocumentCancelSubmit => 'Send cancellation';

  @override
  String get fiscalDocumentCancelBack => 'Back';

  @override
  String fiscalDocumentStampTitle(String kind, String folio) {
    return 'Stamp $kind $folio?';
  }

  @override
  String get fiscalDocumentStampBody =>
      'It will be sent to the PAC to be stamped with SAT. Once stamped it can no longer be reopened or edited; it can only be cancelled.';

  @override
  String fiscalDocumentStamped(String folio) {
    return '$folio stamped.';
  }

  @override
  String fiscalDocumentStampedSimulated(String folio) {
    return '$folio stamped (simulated).';
  }

  @override
  String fiscalDocumentCancelTitle(String folio) {
    return 'Cancel $folio with SAT';
  }

  @override
  String get fiscalDocumentCancelReasonLabel => 'Reason';

  @override
  String get fiscalDocumentCancelReason01 =>
      'Document issued with errors, with relation';

  @override
  String get fiscalDocumentCancelReason02 =>
      'Document issued with errors, without relation';

  @override
  String get fiscalDocumentCancelReason03 =>
      'The operation was not carried out';

  @override
  String get fiscalDocumentCancelReason04 =>
      'Nominative operation related to a global invoice';

  @override
  String get fiscalDocumentCancelSubstituteLabel => 'Replacement document';

  @override
  String get fiscalDocumentCancelSubstituteHint =>
      'It must be stamped and have the same issuer and recipient.';

  @override
  String get fiscalDocumentCancelSubstituteChange => 'Change';

  @override
  String get fiscalDocumentCancelNoCandidates =>
      'There are no stamped documents for this recipient that could replace it. Cancel with reason 02 and issue the new document afterwards, relating it to the cancelled one (04).';

  @override
  String get fiscalDocumentCancelNote =>
      'The request is sent to SAT and cannot be undone from here. If SAT needs the receiver to accept, it will stay pending.';

  @override
  String fiscalDocumentCancelSent(String state) {
    return 'Cancellation sent: $state.';
  }

  @override
  String fiscalDocumentRefreshMoved(String folio, String state) {
    return '$folio: $state.';
  }

  @override
  String get fiscalDocumentStillInProcess =>
      'Still in process. Check again in a few minutes.';

  @override
  String get fiscalDocumentCancellationStillPending =>
      'The cancellation is still in process. SAT and the receiver can take up to 72 hours to settle it; the document stays valid meanwhile.';

  @override
  String get fiscalDocumentCancellationsTitle => 'Cancellations';

  @override
  String get fiscalDocumentCancellationOutcomeRequested => 'Requested';

  @override
  String get fiscalDocumentCancellationOutcomePending => 'Pending';

  @override
  String get fiscalDocumentCancellationOutcomeAccepted => 'Accepted';

  @override
  String get fiscalDocumentCancellationOutcomeExpired => 'Expired';

  @override
  String get fiscalDocumentCancellationOutcomeRejected => 'Rejected';

  @override
  String get fiscalDocumentCancellationOutcomeNotCancellable =>
      'Not cancellable';

  @override
  String get fiscalDocumentCancellationOutcomeFailed => 'Failed';

  @override
  String fiscalDocumentCancellationOutcomeUnknown(String value) {
    return 'Unknown ($value)';
  }

  @override
  String fiscalDocumentCancellationRequestedBy(String who, String when) {
    return 'Requested by $who · $when';
  }

  @override
  String fiscalDocumentCancellationAnswered(String when) {
    return 'Answered $when';
  }

  @override
  String fiscalDocumentCancellationResolved(String when) {
    return 'Resolved $when';
  }

  @override
  String fiscalDocumentCancellationPac(String detail) {
    return 'PAC $detail';
  }

  @override
  String get fiscalDocumentStampIssueDateHint =>
      'Reopen it, change the issue date (or leave it empty) and confirm it again.';

  @override
  String get apiErrorFiscalDocumentCancellationOpen =>
      'A cancellation is already in process for this document. Check its status.';

  @override
  String apiErrorFiscalDocumentHasLiveDocuments(String documents) {
    return 'It can\'t be cancelled: cancel the documents that depend on it first: $documents.';
  }

  @override
  String get apiErrorFiscalDocumentNotCancellable =>
      'SAT says this document cannot be cancelled.';

  @override
  String get apiErrorFiscalDocumentNothingToRefresh =>
      'Nothing is in process for this document: it has already been resolved.';

  @override
  String get apiErrorFiscalDocumentStamping =>
      'This document is being stamped. Check its status in a few minutes.';

  @override
  String get apiErrorFiscalDocumentSubstitutionInvalid =>
      'The replacement document is not valid: it must be stamped, live, and have the same issuer and recipient.';

  @override
  String get apiErrorFiscalDocumentSubstitutionRequired =>
      'Reason 01 requires the document that replaces the cancelled one.';

  @override
  String apiErrorFiscalDocumentUnknownCancellationReason(String reason) {
    return 'The cancellation reason \"$reason\" is not valid.';
  }

  @override
  String get apiErrorPacNotConfigured =>
      'This system has no PAC configured, so documents can\'t be stamped or cancelled.';

  @override
  String apiErrorPacRejected(String code, String message) {
    return 'The PAC rejected the request: $code · \"$message\".';
  }

  @override
  String get apiErrorPacTimeout =>
      'The PAC did not answer in time. The document is left in process; check its status.';

  @override
  String get apiErrorPacUnavailable =>
      'The PAC could not be reached. Nothing changed; try again.';

  @override
  String get fiscalDocumentIssueCreditNoteAction => 'Issue credit note';

  @override
  String get fiscalDocumentIssueCreditNoteTitle => 'Issue a credit note?';

  @override
  String fiscalDocumentIssueCreditNoteBody(String folio, String recipient) {
    return 'A draft credit note will be created for invoice $folio ($recipient), related with type 01. It takes the invoice\'s customer, recipient, payment form and CFDI use.';
  }

  @override
  String get fiscalDocumentIssueCreditNoteCreate => 'Create';

  @override
  String get fiscalDocumentCopyInvoiceLinesAction => 'Add from invoice';

  @override
  String fiscalDocumentCopyInvoiceLinesTitle(String folio) {
    return 'Lines of invoice $folio';
  }

  @override
  String get fiscalDocumentCopyInvoiceLinesIntro =>
      'Check the lines you are crediting and adjust the quantity; it cannot exceed the invoiced one.';

  @override
  String fiscalDocumentCopyInvoiceLinesSubmit(int count) {
    return 'Add ($count)';
  }

  @override
  String get fiscalDocumentCopyInvoiceLinesEmpty => 'The invoice has no lines.';

  @override
  String fiscalDocumentCopyInvoiceLineMax(String max) {
    return 'Maximum $max (the invoiced quantity)';
  }

  @override
  String get fiscalDocumentCopyInvoiceLineQtyPositive =>
      'Must be greater than 0';

  @override
  String get fiscalDocumentCopyInvoiceLineAdded => 'Added';

  @override
  String fiscalDocumentCopyInvoiceLineFailed(String code, String message) {
    return 'Line $code: $message';
  }

  @override
  String fiscalDocumentCopyInvoiceLinesDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines added',
      one: '1 line added',
    );
    return '$_temp0';
  }

  @override
  String get fiscalDocumentInvoiceQuantity => 'Invoiced qty';

  @override
  String get fiscalDocumentBannerCreditNoteForm =>
      'The payment form is 99 (To be defined). Choose the real payment form in the header before confirming.';

  @override
  String get fiscalDocumentHeaderTermsFixedPue => 'PUE (fixed on credit notes)';

  @override
  String fiscalDocumentCreditExceedsInvoice(String folio, String remaining) {
    return 'The credit note exceeds what is left of invoice $folio: $remaining.';
  }

  @override
  String get apiErrorFiscalDocumentInvoiceNotCreditable =>
      'This invoice no longer accepts credit notes: it must be stamped, valid and without a cancellation in progress.';

  @override
  String apiErrorFiscalDocumentCreditExceedsInvoice(String remaining) {
    return 'The credit note exceeds what is left to credit on the invoice: $remaining.';
  }

  @override
  String apiErrorFiscalDocumentCreditQuantityExceedsLine(String max) {
    return 'The quantity exceeds the invoice\'s: maximum $max.';
  }

  @override
  String get apiErrorFiscalDocumentPaymentFormRequired =>
      'Choose the real payment form; 99 (To be defined) is not accepted on this document.';

  @override
  String get paymentIssueReceiptAction => 'Issue payment receipt';

  @override
  String get fiscalDocumentNewReceiptAction => 'New payment receipt';

  @override
  String get fiscalDocumentNewReceiptTitle => 'New payment receipt';

  @override
  String get fiscalDocumentIssueReceiptTitle => 'Issue payment receipt';

  @override
  String get fiscalDocumentNewReceiptHint =>
      'Enter the payment and the invoices it settles in the draft.';

  @override
  String get fiscalDocumentIssueReceiptHint =>
      'A draft will be created with the payment\'s date, amount, payment form and reference, and the PPD invoices of its orders.';

  @override
  String fiscalDocumentIssueReceiptPaymentSummary(
    int id,
    String customer,
    String amount,
    String date,
  ) {
    return 'Payment #$id · $customer · $amount · $date';
  }

  @override
  String get fiscalDocumentReceiptOpenExisting => 'Open receipt';

  @override
  String get fiscalDocumentReceiptPaymentSection => 'Payment';

  @override
  String get fiscalDocumentReceiptPaymentDate => 'Payment date';

  @override
  String get fiscalDocumentReceiptPaymentAmount => 'Payment amount';

  @override
  String get fiscalDocumentReceiptPaymentForm => 'Payment form';

  @override
  String get fiscalDocumentReceiptOperationNumber => 'Operation no.';

  @override
  String get fiscalDocumentReceiptOrderingBank => 'Ordering bank';

  @override
  String get fiscalDocumentReceiptSourcePayment => 'Source payment';

  @override
  String fiscalDocumentReceiptSourcePaymentValue(int id) {
    return 'Payment #$id';
  }

  @override
  String get fiscalDocumentPaidInvoicesSection => 'Paid invoices';

  @override
  String get fiscalDocumentPaidInvoicesEmpty => 'No invoices.';

  @override
  String get fiscalDocumentPaidInvoicesColumnInvoice => 'Invoice';

  @override
  String get fiscalDocumentPaidInvoicesColumnUuid => 'UUID';

  @override
  String get fiscalDocumentPaidInvoicesColumnInstallment => 'Installment';

  @override
  String get fiscalDocumentPaidInvoicesColumnPreviousBalance =>
      'Previous balance';

  @override
  String get fiscalDocumentPaidInvoicesColumnAmount => 'Amount paid';

  @override
  String get fiscalDocumentPaidInvoicesColumnRemaining => 'Remaining balance';

  @override
  String get fiscalDocumentAddPaidInvoiceAction => 'Add invoice';

  @override
  String get fiscalDocumentReceiptSummaryPayment => 'Payment amount';

  @override
  String get fiscalDocumentReceiptSummaryAssigned => 'Assigned';

  @override
  String get fiscalDocumentReceiptSummaryUnassigned => 'Unassigned';

  @override
  String get fiscalDocumentBannerReceiptNoProposal =>
      'No stamped PPD invoices were found for this payment\'s orders and this recipient. Add them with \"Add invoice\".';

  @override
  String get addPaidInvoiceTitle => 'Add invoice';

  @override
  String addPaidInvoiceIntro(String issuer, String recipient) {
    return 'Stamped invoices of $issuer for $recipient.';
  }

  @override
  String get addPaidInvoiceEmpty =>
      'There are no stamped invoices for this recipient.';

  @override
  String get addPaidInvoiceAmountLabel => 'Amount paid';

  @override
  String get addPaidInvoiceAmountHelper =>
      'Empty = the balance, up to what is left to assign';

  @override
  String get addPaidInvoiceSubmit => 'Add';

  @override
  String editPaidInvoiceTitle(String folio) {
    return 'Amount paid · $folio';
  }

  @override
  String editPaidInvoicePreviousBalance(String amount) {
    return 'Previous balance $amount';
  }

  @override
  String editPaidInvoiceAmountMax(String max) {
    return 'Maximum $max (the previous balance)';
  }

  @override
  String get editPaidInvoiceAmountPositive => 'Must be greater than 0';

  @override
  String get removePaidInvoiceTitle => 'Remove paid invoice';

  @override
  String removePaidInvoiceBody(String folio) {
    return 'Remove invoice $folio from this receipt?';
  }

  @override
  String get fiscalDocumentHeaderPaymentDate => 'Payment date';

  @override
  String get fiscalDocumentHeaderPaymentAmount => 'Payment amount';

  @override
  String get fiscalDocumentHeaderOperationNumber => 'Operation no.';

  @override
  String get fiscalDocumentHeaderOrderingBank => 'Ordering bank';

  @override
  String get fiscalDocumentHeaderOrderingBankHelper =>
      'Only if the ordering bank is foreign';

  @override
  String get fiscalDocumentHeaderReceiptFixed =>
      'CFDI usage CP01 · Currency MXN (fixed on payment receipts)';

  @override
  String get apiErrorFiscalDocumentInvoiceNotPayable =>
      'The invoice cannot be paid by this receipt: it must be PPD, stamped and live, with no cancellation in process, and of the same issuer and recipient.';

  @override
  String get apiErrorFiscalDocumentInvoiceAlreadyOnReceipt =>
      'The invoice is already on this receipt.';

  @override
  String apiErrorFiscalDocumentAmountExceedsBalance(String balance) {
    return 'The amount exceeds the invoice balance: $balance.';
  }

  @override
  String get apiErrorFiscalDocumentAmountsExceedPayment =>
      'The amounts paid exceed the payment amount.';

  @override
  String get apiErrorFiscalDocumentAmountsNotEqualPayment =>
      'The amounts paid must equal the payment amount.';

  @override
  String get apiErrorFiscalDocumentPaymentDateOutOfRange =>
      'The payment date must be between the invoices\' dates and today.';

  @override
  String get apiErrorFiscalDocumentPaymentAlreadyReceipted =>
      'This payment already has a payment receipt.';

  @override
  String get apiErrorFiscalDocumentPaymentOtherCustomer =>
      'The payment belongs to another customer.';

  @override
  String get apiErrorFiscalDocumentReceiptNeedsPaymentData =>
      'Enter the payment date and amount before confirming.';

  @override
  String get apiErrorFiscalDocumentReceiptPaysNoInvoice =>
      'Add at least one paid invoice before confirming.';

  @override
  String get fiscalDocumentPaidInvoiceEditTooltip => 'Edit amount';

  @override
  String get fiscalDocumentPaidInvoiceRemoveTooltip => 'Remove invoice';

  @override
  String get fiscalDocumentHeaderOperationNumberTooLong =>
      'The operation number can have up to 50 characters.';

  @override
  String get fiscalDocumentHeaderOrderingBankTooLong =>
      'The ordering bank can have up to 25 characters.';

  @override
  String get apiErrorItineraryNotOpen =>
      'The itinerary is no longer open and can\'t be changed.';

  @override
  String get apiErrorItineraryNotDeparted => 'The itinerary hasn\'t left yet.';

  @override
  String get apiErrorItineraryCancelled => 'The itinerary is cancelled.';

  @override
  String get apiErrorItineraryNothingCommitted =>
      'Nothing is loaded on this itinerary.';

  @override
  String get apiErrorItineraryLinesOvercommitted =>
      'These lines are loaded beyond what\'s left to deliver';

  @override
  String get apiErrorItineraryStopAlreadyResolved =>
      'This stop is already closed.';

  @override
  String get apiErrorItineraryStopLinesIncomplete =>
      'A line of the stop has no result.';

  @override
  String get apiErrorItineraryStopLinesMalformed =>
      'The lines\' results aren\'t valid.';

  @override
  String apiErrorItineraryStopDeliveredExceedsSent(
    String line,
    String sent,
    String delivered,
  ) {
    return 'Line $line: $sent were sent and $delivered are recorded as delivered.';
  }

  @override
  String apiErrorItineraryStopShortfallNeedsReason(String line) {
    return 'Line $line: give a reason for what wasn\'t delivered.';
  }

  @override
  String apiErrorVehicleOpenItineraryExists(String itinerary) {
    return 'This vehicle already has itinerary $itinerary open.';
  }

  @override
  String get apiErrorDeliveryOrderNotInPreparation =>
      'The delivery order is no longer in preparation; only orders in preparation can be loaded.';

  @override
  String get apiErrorDeliveryOrderPickupNotLoadable =>
      'A store-pickup order can\'t be loaded on an itinerary.';

  @override
  String get apiErrorDeliveryOrderLineNothingToLoad =>
      'This line has nothing left to load.';

  @override
  String apiErrorDeliveryOrderLineQuantityUnavailable(
    String requested,
    String available,
  ) {
    return 'You asked to load $requested, but only $available are available.';
  }

  @override
  String apiResourceDeliveryItineraryStop(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'stops',
      one: 'stop',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderDeliveryItineraryStop => 'feminine';

  @override
  String apiResourceDeliveryItineraryLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'itinerary lines',
      one: 'itinerary line',
    );
    return '$_temp0';
  }

  @override
  String get apiResourceGenderDeliveryItineraryLine => 'feminine';

  @override
  String get navDeliveryItineraries => 'Itineraries';

  @override
  String itineraryTitle(int id) {
    return 'Itinerary $id';
  }

  @override
  String get itinerariesEmpty => 'There are no itineraries yet.';

  @override
  String get itineraryNotFoundBack => 'Back to Itineraries';

  @override
  String get itineraryActionUnknown =>
      'We can\'t tell whether it went through: the connection was lost. The itinerary was refreshed.';

  @override
  String get itineraryColumnNumber => 'No.';

  @override
  String get itineraryColumnDate => 'Date';

  @override
  String get itineraryColumnVehicle => 'Vehicle';

  @override
  String get itineraryColumnOperator => 'Operator';

  @override
  String get itineraryColumnWarehouse => 'Warehouse';

  @override
  String get itineraryColumnStatus => 'Status';

  @override
  String get itineraryColumnDeparture => 'Departure';

  @override
  String get itineraryColumnReturn => 'Return';

  @override
  String itineraryDeparted(String time) {
    return 'Departure $time';
  }

  @override
  String itineraryReturned(String time) {
    return 'Return $time';
  }

  @override
  String get itineraryStatusOpen => 'Open';

  @override
  String get itineraryStatusDeparted => 'On the road';

  @override
  String get itineraryStatusClosed => 'Closed';

  @override
  String get itineraryStatusCancelled => 'Cancelled';

  @override
  String get itineraryStopOutcomePending => 'Pending';

  @override
  String get itineraryStopOutcomeDelivered => 'Delivered';

  @override
  String get itineraryStopOutcomePartiallyDelivered => 'Partially delivered';

  @override
  String get itineraryStopOutcomeFailed => 'Failed';

  @override
  String get itineraryReasonCustomerRefused => 'Customer refused';

  @override
  String get itineraryReasonNobodyPresent => 'Nobody there';

  @override
  String get itineraryReasonWrongAddress => 'Wrong address';

  @override
  String get itineraryReasonDamagedGoods => 'Damaged goods';

  @override
  String get itineraryReasonOther => 'Other';

  @override
  String get itineraryFilterStatus => 'Status';

  @override
  String get itineraryFilterStatusAll => 'All';

  @override
  String get itineraryFilterDate => 'Date';

  @override
  String get itineraryFilterVehicle => 'Vehicle';

  @override
  String get itineraryFilterOperator => 'Operator';

  @override
  String get itineraryFilterWarehouse => 'Dispatch warehouse';

  @override
  String get itineraryFilterAny => 'Any';

  @override
  String get itineraryHeaderComment => 'Comment';

  @override
  String get itineraryEditHeader => 'Edit header';

  @override
  String get itineraryNoOperator => 'No operator';

  @override
  String get itineraryNoneAssigned => '—';

  @override
  String itineraryLicenseExpired(String operator, String date) {
    return '$operator\'s licence expired on $date.';
  }

  @override
  String get itineraryActionNew => 'New itinerary';

  @override
  String get itineraryActionAddStop => 'Add stop';

  @override
  String get itineraryActionCancel => 'Cancel itinerary';

  @override
  String get itineraryActionDepart => 'Depart';

  @override
  String get itineraryActionLoadAll => 'Load all';

  @override
  String get itineraryActionLoadLine => 'Load line';

  @override
  String get itineraryActionRemoveStop => 'Remove stop';

  @override
  String get itineraryActionCloseStop => 'Close stop';

  @override
  String get itineraryActionPrintTicket => 'Print ticket';

  @override
  String get itineraryActionPrintNotes => 'Print delivery notes';

  @override
  String get itineraryDepartGuardNothing => 'Nothing is loaded yet.';

  @override
  String itineraryDepartGuardEmptyStop(int n) {
    return 'Stop $n has nothing loaded.';
  }

  @override
  String get itineraryCancelledNote =>
      'This itinerary was cancelled before departure. What was loaded is pending again.';

  @override
  String itineraryStopTitle(int n) {
    return 'Stop $n';
  }

  @override
  String itineraryStopOrder(int id) {
    return 'Order $id';
  }

  @override
  String itineraryStopOrders(String ids) {
    return 'Orders $ids';
  }

  @override
  String get itineraryStopEmpty => 'Nothing loaded yet.';

  @override
  String itineraryStopClosedAt(String time) {
    return 'closed $time';
  }

  @override
  String get itineraryStopMenuTooltip => 'Stop actions';

  @override
  String get itineraryStopOrderLinkTooltip => 'Open the delivery order';

  @override
  String get itineraryLineCode => 'Code';

  @override
  String get itineraryLineProduct => 'Product';

  @override
  String get itineraryLineUnit => 'Unit';

  @override
  String get itineraryLinePending => 'Pending';

  @override
  String get itineraryLineLoaded => 'Loaded';

  @override
  String get itineraryLineSent => 'Sent';

  @override
  String get itineraryLineDelivered => 'Delivered';

  @override
  String get itineraryLineReturned => 'Returned';

  @override
  String get itineraryLineReason => 'Reason';

  @override
  String get itineraryLineEditTooltip => 'Change the loaded quantity';

  @override
  String get itineraryLineReleaseTooltip => 'Release the line';

  @override
  String get itineraryNewTitle => 'New itinerary';

  @override
  String get itineraryFieldDate => 'Date';

  @override
  String get itineraryFieldVehicle => 'Vehicle';

  @override
  String get itineraryFieldOperator => 'Operator';

  @override
  String get itineraryFieldWarehouse => 'Dispatch warehouse';

  @override
  String get itineraryWarehouseHint =>
      'Empty uses your point of sale\'s warehouse.';

  @override
  String get itineraryFieldComment => 'Comment';

  @override
  String get itineraryCreateButton => 'Create';

  @override
  String itineraryHeaderTitle(int id) {
    return 'Edit header · Itinerary $id';
  }

  @override
  String get itineraryAddStopTitle => 'Add stop';

  @override
  String get itineraryAddStopSearch => 'Folio';

  @override
  String get itineraryAddStopEmpty => 'There are no orders in preparation.';

  @override
  String get itineraryAddStopColumnFolio => 'Folio';

  @override
  String get itineraryAddStopColumnCustomer => 'Customer';

  @override
  String get itineraryAddStopColumnAddress => 'Address';

  @override
  String get itineraryAddStopColumnDate => 'Date';

  @override
  String get itineraryAddStopConfirm => 'Add';

  @override
  String get itineraryPickOrderTitle => 'Choose the stop\'s order';

  @override
  String itineraryLoadLineTitle(int id) {
    return 'Load line · Order $id';
  }

  @override
  String get itineraryLoadLineEmpty => 'This order has no lines left to load.';

  @override
  String itineraryLoadLinePending(String qty) {
    return '$qty pend.';
  }

  @override
  String get itineraryLoadLineConfirm => 'Load';

  @override
  String get itineraryQuantityLabel => 'Quantity';

  @override
  String itineraryQuantityMax(String max) {
    return 'Maximum $max';
  }

  @override
  String itineraryQuantityMaxBreakdown(
    String max,
    String pending,
    String loaded,
  ) {
    return 'Maximum $max ($pending pend. + $loaded loaded)';
  }

  @override
  String get itineraryQuantityInvalid =>
      'Enter a quantity above 0 and no more than the maximum.';

  @override
  String itineraryAdjustTitle(String code) {
    return 'Loaded quantity · $code';
  }

  @override
  String itineraryLoadAllTitle(int id) {
    return 'Load all of order $id?';
  }

  @override
  String get itineraryLoadAllBody =>
      'What is left to deliver of each line is loaded.';

  @override
  String get itineraryLoadAllConfirm => 'Load all';

  @override
  String itineraryReleaseTitle(String code) {
    return 'Release $code?';
  }

  @override
  String get itineraryReleaseBody =>
      'The loaded quantity is pending again on the order.';

  @override
  String get itineraryReleaseConfirm => 'Release';

  @override
  String itineraryRemoveStopTitle(int n) {
    return 'Remove stop $n?';
  }

  @override
  String get itineraryRemoveStopBody =>
      'What is loaded on this stop is released; the order is pending again.';

  @override
  String get itineraryRemoveStopConfirm => 'Remove';

  @override
  String itineraryCancelTitle(int id) {
    return 'Cancel itinerary $id?';
  }

  @override
  String get itineraryCancelBody =>
      'Everything loaded is released and the orders stay in preparation. This can\'t be undone.';

  @override
  String get itineraryCancelConfirm => 'Cancel itinerary';

  @override
  String get itineraryCancelDismiss => 'Keep';

  @override
  String itineraryDepartTitle(int id) {
    return 'Depart itinerary $id?';
  }

  @override
  String itineraryDepartVehicleOperator(String vehicle, String operator) {
    return 'Vehicle $vehicle · Operator $operator';
  }

  @override
  String itineraryDepartCounts(int stops, int lines) {
    String _temp0 = intl.Intl.pluralLogic(
      stops,
      locale: localeName,
      other: '$stops stops',
      one: '1 stop',
    );
    String _temp1 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines lines',
      one: '1 line',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get itineraryDepartWarning =>
      'Once it departs, what is loaded can\'t be changed.';

  @override
  String get itineraryDepartConfirm => 'Depart';

  @override
  String itineraryCloseTitle(int n) {
    return 'Close stop $n';
  }

  @override
  String itineraryCloseSubtitle(String title, String order, String customer) {
    return '$title · Order $order · $customer';
  }

  @override
  String get itineraryCloseReceiverSection => 'Who received';

  @override
  String get itineraryCloseReceiverName => 'Name';

  @override
  String get itineraryCloseReceiverId => 'Identification';

  @override
  String get itineraryCloseLinesSection => 'What they received';

  @override
  String get itineraryCloseAllDelivered => 'All delivered';

  @override
  String get itineraryCloseNothingDelivered => 'Nothing delivered';

  @override
  String itineraryCloseSentLabel(String qty) {
    return 'Sent $qty';
  }

  @override
  String get itineraryCloseDeliveredField => 'Delivered';

  @override
  String get itineraryCloseReasonField => 'Reason';

  @override
  String get itineraryCloseProofSection => 'Proof of delivery';

  @override
  String get itineraryCloseProofImage => 'Image';

  @override
  String get itineraryCloseProofSignature => 'Signature';

  @override
  String get itineraryCloseChooseImage => 'Choose image';

  @override
  String get itineraryCloseRemoveImage => 'Remove';

  @override
  String get itineraryCloseClearSignature => 'Clear';

  @override
  String get itineraryCloseSignatureHint => 'Sign here';

  @override
  String get itineraryCloseSignatureTooltip => 'Signature area';

  @override
  String get itineraryCloseImageTooLarge => 'The image is over 2 MB.';

  @override
  String get itineraryCloseImageFormat => 'Choose a jpg or png image.';

  @override
  String get itineraryCloseMissingTitle => 'Missing:';

  @override
  String get itineraryCloseMissingReceiver => 'the receiver\'s name';

  @override
  String get itineraryCloseMissingId => 'the identification';

  @override
  String get itineraryCloseMissingProof => 'the proof of delivery';

  @override
  String itineraryCloseMissingReason(String product) {
    return 'the reason for $product';
  }

  @override
  String get itineraryCloseConfirm => 'Close stop';

  @override
  String documentItineraryTicketTitle(String id) {
    return 'Itinerary ticket · $id';
  }

  @override
  String documentItineraryNotesTitle(String id) {
    return 'Delivery notes · itinerary $id';
  }
}
