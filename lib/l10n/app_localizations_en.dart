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
  String get employeeIdLabel => 'Employee (optional)';

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
  String suppliersLoadError(Object error) {
    return 'Failed to load suppliers: $error';
  }

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
  String labelsLoadError(Object error) {
    return 'Failed to load labels: $error';
  }

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
  String expensesLoadError(Object error) {
    return 'Failed to load expenses: $error';
  }

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
  String vehiclesLoadError(Object error) {
    return 'Failed to load vehicles: $error';
  }

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
  String vehicleOperatorsLoadError(Object error) {
    return 'Failed to load vehicle operators: $error';
  }

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
  String employeesLoadError(Object error) {
    return 'Failed to load employees: $error';
  }

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
  String get shippingLabel => 'Shipping';

  @override
  String get shippingRequiredDocumentLabel => 'Shipping requires document';

  @override
  String get columnSalesperson => 'Salesperson';

  @override
  String get customersSearchLabel => 'Search by code or name';

  @override
  String get newCustomerTooltip => 'New customer';

  @override
  String get noCustomersFound => 'No customers found.';

  @override
  String customersLoadError(Object error) {
    return 'Failed to load customers: $error';
  }

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
  String get customerCodeRequiredError => 'Code is required.';

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
  String taxpayerRecipientsLoadError(Object error) {
    return 'Failed to load taxpayer recipients: $error';
  }

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
}
