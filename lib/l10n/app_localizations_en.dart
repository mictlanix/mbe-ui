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
  String get usersMenuTitle => 'Users';

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
}
