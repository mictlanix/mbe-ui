import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Generic required-field validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// Password minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Must be at least 6 characters'**
  String get fieldMinLength6;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordLink;

  /// No description provided for @changePasswordMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordMenuTitle;

  /// No description provided for @usersMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersMenuTitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordButton;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @recoverPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover Password'**
  String get recoverPasswordTitle;

  /// No description provided for @recoveryHelpText.
  ///
  /// In en, this message translates to:
  /// **'Ask your administrator to generate a recovery token for your account, then enter it below along with your new password.'**
  String get recoveryHelpText;

  /// No description provided for @recoveryTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery token'**
  String get recoveryTokenLabel;

  /// No description provided for @setNewPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get setNewPasswordButton;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. You can now sign in.'**
  String get passwordResetSuccess;

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTitle;

  /// No description provided for @newUserTooltip.
  ///
  /// In en, this message translates to:
  /// **'New user'**
  String get newUserTooltip;

  /// No description provided for @usersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load users: {error}'**
  String usersLoadError(Object error);

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @columnUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get columnUsername;

  /// No description provided for @columnEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get columnEmail;

  /// No description provided for @columnAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get columnAdmin;

  /// No description provided for @columnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get columnStatus;

  /// No description provided for @statusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get statusDisabled;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @newProductTooltip.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get newProductTooltip;

  /// No description provided for @productsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by code, name, brand, or model'**
  String get productsSearchLabel;

  /// No description provided for @productsShowInactiveFilter.
  ///
  /// In en, this message translates to:
  /// **'Show inactive'**
  String get productsShowInactiveFilter;

  /// No description provided for @productsStockableFilter.
  ///
  /// In en, this message translates to:
  /// **'Stockable'**
  String get productsStockableFilter;

  /// No description provided for @productsSalableFilter.
  ///
  /// In en, this message translates to:
  /// **'Salable'**
  String get productsSalableFilter;

  /// No description provided for @productsPurchasableFilter.
  ///
  /// In en, this message translates to:
  /// **'Purchasable'**
  String get productsPurchasableFilter;

  /// No description provided for @productsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products: {error}'**
  String productsLoadError(Object error);

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @columnCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get columnCode;

  /// No description provided for @columnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get columnName;

  /// No description provided for @columnBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get columnBrand;

  /// No description provided for @columnUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get columnUnit;

  /// No description provided for @loadMoreButton.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMoreButton;

  /// No description provided for @newProductTitle.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get newProductTitle;

  /// No description provided for @editProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProductTitle;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @unitOfMeasurementLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit of Measurement'**
  String get unitOfMeasurementLabel;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @barCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barCodeLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Bin Location'**
  String get locationLabel;

  /// No description provided for @taxRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate'**
  String get taxRateLabel;

  /// No description provided for @commentLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commentLabel;

  /// No description provided for @stockableLabel.
  ///
  /// In en, this message translates to:
  /// **'Stockable'**
  String get stockableLabel;

  /// No description provided for @perishableLabel.
  ///
  /// In en, this message translates to:
  /// **'Perishable'**
  String get perishableLabel;

  /// No description provided for @seriableLabel.
  ///
  /// In en, this message translates to:
  /// **'Seriable'**
  String get seriableLabel;

  /// No description provided for @purchasableLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchasable'**
  String get purchasableLabel;

  /// No description provided for @salableLabel.
  ///
  /// In en, this message translates to:
  /// **'Salable'**
  String get salableLabel;

  /// No description provided for @invoiceableLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoiceable'**
  String get invoiceableLabel;

  /// No description provided for @deactivateProductTooltip.
  ///
  /// In en, this message translates to:
  /// **'Deactivate product'**
  String get deactivateProductTooltip;

  /// No description provided for @deactivateProductConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate product?'**
  String get deactivateProductConfirmTitle;

  /// No description provided for @deactivateProductConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate \"{code}\"? It will be hidden from new sales, purchases, and inventory transactions, but its history is kept.'**
  String deactivateProductConfirmMessage(String code);

  /// No description provided for @deactivateButton.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateButton;

  /// No description provided for @statusInactiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactiveBadge;

  /// No description provided for @editUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUserTitle;

  /// No description provided for @newUserTitle.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get newUserTitle;

  /// No description provided for @recoverPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get recoverPasswordTooltip;

  /// No description provided for @deleteUserTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get deleteUserTooltip;

  /// No description provided for @deleteUserConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete user?'**
  String get deleteUserConfirmTitle;

  /// No description provided for @deleteUserConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{userId}\"? This action cannot be undone.'**
  String deleteUserConfirmMessage(String userId);

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @employeeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee ID (optional)'**
  String get employeeIdLabel;

  /// No description provided for @administratorLabel.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administratorLabel;

  /// No description provided for @disabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledLabel;

  /// No description provided for @permissionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @recoveryTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery Token'**
  String get recoveryTokenTitle;

  /// No description provided for @recoveryExpiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires: {expiresAt}'**
  String recoveryExpiresAt(String expiresAt);

  /// Username length validation (4–20 chars)
  ///
  /// In en, this message translates to:
  /// **'4–20 characters'**
  String get userIdLengthError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @privilegesModuleColumn.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get privilegesModuleColumn;

  /// Create column header in permissions grid
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get privilegesCreateColumn;

  /// Read column header in permissions grid
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get privilegesReadColumn;

  /// Update column header in permissions grid
  ///
  /// In en, this message translates to:
  /// **'U'**
  String get privilegesUpdateColumn;

  /// Delete column header in permissions grid
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get privilegesDeleteColumn;

  /// Tooltip for Create column in permissions grid
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get privilegesCreateTooltip;

  /// Tooltip for Read column in permissions grid
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get privilegesReadTooltip;

  /// Tooltip for Update column in permissions grid
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get privilegesUpdateTooltip;

  /// Tooltip for Delete column in permissions grid
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get privilegesDeleteTooltip;

  /// No description provided for @productCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Code is required.'**
  String get productCodeRequiredError;

  /// No description provided for @productCodeWhitespaceError.
  ///
  /// In en, this message translates to:
  /// **'Code must not contain whitespace.'**
  String get productCodeWhitespaceError;

  /// No description provided for @productCodeTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Code must be at most 25 characters.'**
  String get productCodeTooLongError;

  /// No description provided for @productNameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be between 4 and 250 characters.'**
  String get productNameLengthError;

  /// No description provided for @productUnitRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Unit of measurement is required.'**
  String get productUnitRequiredError;

  /// No description provided for @productBarCodeInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Barcode must be empty or exactly 13 digits.'**
  String get productBarCodeInvalidError;

  /// No description provided for @productLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load product.'**
  String get productLoadFailedError;

  /// No description provided for @productCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create product.'**
  String get productCreateFailedError;

  /// No description provided for @productUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update product.'**
  String get productUpdateFailedError;

  /// No description provided for @productDeactivateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to deactivate product.'**
  String get productDeactivateFailedError;

  /// No description provided for @productCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create products.'**
  String get productCreatePermissionDeniedError;

  /// No description provided for @productUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit products.'**
  String get productUpdatePermissionDeniedError;

  /// No description provided for @productDeactivatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to deactivate products.'**
  String get productDeactivatePermissionDeniedError;

  /// No description provided for @userEmailRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get userEmailRequiredError;

  /// No description provided for @userUsernameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Username is required.'**
  String get userUsernameRequiredError;

  /// No description provided for @userPasswordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get userPasswordLengthError;

  /// No description provided for @userLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user.'**
  String get userLoadFailedError;

  /// No description provided for @userSaveFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save user.'**
  String get userSaveFailedError;

  /// No description provided for @userDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user.'**
  String get userDeleteFailedError;

  /// No description provided for @userRecoveryFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate recovery token.'**
  String get userRecoveryFailedError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
