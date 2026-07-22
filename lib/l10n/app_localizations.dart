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

  /// No description provided for @viewActionTooltip.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewActionTooltip;

  /// No description provided for @editActionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editActionTooltip;

  /// No description provided for @deleteActionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteActionTooltip;

  /// No description provided for @moreActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActionsTooltip;

  /// No description provided for @searchButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButtonTooltip;

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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mictlanix Business Essentials'**
  String get appTitle;

  /// No description provided for @homeMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeMenuTitle;

  /// No description provided for @homeWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeWelcomeMessage;

  /// No description provided for @catalogsGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalogs'**
  String get catalogsGroupTitle;

  /// No description provided for @salesGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesGroupTitle;

  /// No description provided for @usersMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersMenuTitle;

  /// No description provided for @userMenuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get userMenuLogout;

  /// No description provided for @userMenuFacilityFallback.
  ///
  /// In en, this message translates to:
  /// **'Facility {id}'**
  String userMenuFacilityFallback(int id);

  /// No description provided for @userMenuPosFallback.
  ///
  /// In en, this message translates to:
  /// **'POS {id}'**
  String userMenuPosFallback(int id);

  /// No description provided for @userMenuDrawerFallback.
  ///
  /// In en, this message translates to:
  /// **'Drawer {id}'**
  String userMenuDrawerFallback(int id);

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

  /// No description provided for @usersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by username or email'**
  String get usersSearchLabel;

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

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// Label for the status filter that maps to mbe-api's uniform ?status= query param
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusFilterLabel;

  /// Status filter option that applies no ?status= filter, showing every lifecycle state
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusFilterAll;

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

  /// No description provided for @uploadPhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhotoButton;

  /// No description provided for @replacePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Replace photo'**
  String get replacePhotoButton;

  /// No description provided for @removePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhotoButton;

  /// No description provided for @productsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by code, name, brand, or model'**
  String get productsSearchLabel;

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

  /// No description provided for @productsLabelFilter.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get productsLabelFilter;

  /// Tooltip on a disabled label filter chip that would return no products if selected
  ///
  /// In en, this message translates to:
  /// **'No matching products'**
  String get labelUnavailableTooltip;

  /// A label filter chip's text when the matching product count is known
  ///
  /// In en, this message translates to:
  /// **'{name} ({count})'**
  String labelWithCount(String name, int count);

  /// Label/title of the catalog filter panel and its trigger button
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersButton;

  /// Tooltip on the filter panel trigger icon button
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTooltip;

  /// Filter panel action that resets every facet filter
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllFilters;

  /// Filter panel primary action that dismisses the panel
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

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

  /// No description provided for @columnPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get columnPhoto;

  /// No description provided for @columnCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get columnCode;

  /// No description provided for @copyCodeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCodeTooltip;

  /// No description provided for @codeCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedMessage;

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

  /// No description provided for @viewProductTitle.
  ///
  /// In en, this message translates to:
  /// **'View Product'**
  String get viewProductTitle;

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

  /// No description provided for @skuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get skuLabel;

  /// No description provided for @unitOfMeasurementLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit of Measurement'**
  String get unitOfMeasurementLabel;

  /// No description provided for @supplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierLabel;

  /// No description provided for @satKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'SAT Product/Service Key'**
  String get satKeyLabel;

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

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

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

  /// No description provided for @labelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labelsLabel;

  /// No description provided for @deleteProductButton.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProductButton;

  /// No description provided for @deleteProductConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product permanently?'**
  String get deleteProductConfirmTitle;

  /// No description provided for @deleteProductConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete \"{code}\"? This cannot be undone — the product and its history will be removed entirely, not just hidden.'**
  String deleteProductConfirmMessage(String code);

  /// No description provided for @mergeProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge Products'**
  String get mergeProductsTitle;

  /// No description provided for @mergeProductsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Merge products'**
  String get mergeProductsTooltip;

  /// No description provided for @mergeProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get mergeProductLabel;

  /// No description provided for @duplicatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicatedLabel;

  /// No description provided for @mergeButton.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mergeButton;

  /// No description provided for @mergeBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get mergeBackTooltip;

  /// No description provided for @mergeBothRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a product and a duplicate to continue.'**
  String get mergeBothRequiredMessage;

  /// No description provided for @mergeSameProductMessage.
  ///
  /// In en, this message translates to:
  /// **'You can\'t merge a product with itself.'**
  String get mergeSameProductMessage;

  /// No description provided for @mergeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge products permanently?'**
  String get mergeConfirmTitle;

  /// No description provided for @mergeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to merge \"{duplicateName}\" into \"{canonicalName}\"? This cannot be undone — \"{duplicateName}\" will be permanently deleted and its history transferred to \"{canonicalName}\".'**
  String mergeConfirmMessage(String canonicalName, String duplicateName);

  /// No description provided for @mergeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Products merged successfully.'**
  String get mergeSuccess;

  /// No description provided for @editUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUserTitle;

  /// No description provided for @viewUserTitle.
  ///
  /// In en, this message translates to:
  /// **'View User'**
  String get viewUserTitle;

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

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @editRecordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch to the editable form'**
  String get editRecordTooltip;

  /// No description provided for @viewPricingButton.
  ///
  /// In en, this message translates to:
  /// **'View pricing'**
  String get viewPricingButton;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @employeeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee (optional)'**
  String get employeeIdLabel;

  /// No description provided for @administratorLabel.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administratorLabel;

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

  /// No description provided for @productPhotoInvalidTypeError.
  ///
  /// In en, this message translates to:
  /// **'Photo must be a JPEG or PNG file.'**
  String get productPhotoInvalidTypeError;

  /// No description provided for @productPhotoTooLargeError.
  ///
  /// In en, this message translates to:
  /// **'Photo must be 2 MB or smaller.'**
  String get productPhotoTooLargeError;

  /// No description provided for @productPhotoUploadFailedError.
  ///
  /// In en, this message translates to:
  /// **'The product was saved, but the photo failed to upload. Try again.'**
  String get productPhotoUploadFailedError;

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

  /// No description provided for @productDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product.'**
  String get productDeleteFailedError;

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

  /// No description provided for @productDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete products.'**
  String get productDeletePermissionDeniedError;

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

  /// No description provided for @priceListsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Price Lists'**
  String get priceListsMenuTitle;

  /// No description provided for @pricingMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricingMenuTitle;

  /// No description provided for @exchangeRatesMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rates'**
  String get exchangeRatesMenuTitle;

  /// No description provided for @priceListsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get priceListsSearchLabel;

  /// No description provided for @newPriceListTooltip.
  ///
  /// In en, this message translates to:
  /// **'New price list'**
  String get newPriceListTooltip;

  /// No description provided for @noPriceListsFound.
  ///
  /// In en, this message translates to:
  /// **'No price lists found.'**
  String get noPriceListsFound;

  /// No description provided for @priceListsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load price lists: {error}'**
  String priceListsLoadError(Object error);

  /// No description provided for @columnHighProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'High margin'**
  String get columnHighProfitMargin;

  /// No description provided for @columnLowProfitMargin.
  ///
  /// In en, this message translates to:
  /// **'Low margin'**
  String get columnLowProfitMargin;

  /// No description provided for @priceListNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get priceListNameLabel;

  /// No description provided for @priceListHighProfitMarginLabel.
  ///
  /// In en, this message translates to:
  /// **'High profit margin'**
  String get priceListHighProfitMarginLabel;

  /// No description provided for @priceListLowProfitMarginLabel.
  ///
  /// In en, this message translates to:
  /// **'Low profit margin'**
  String get priceListLowProfitMarginLabel;

  /// No description provided for @newPriceListTitle.
  ///
  /// In en, this message translates to:
  /// **'New price list'**
  String get newPriceListTitle;

  /// No description provided for @editPriceListTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit price list'**
  String get editPriceListTitle;

  /// No description provided for @viewPriceListTitle.
  ///
  /// In en, this message translates to:
  /// **'View price list'**
  String get viewPriceListTitle;

  /// No description provided for @deletePriceListButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePriceListButton;

  /// No description provided for @deletePriceListConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete price list?'**
  String get deletePriceListConfirmTitle;

  /// No description provided for @deletePriceListConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deletePriceListConfirmMessage(String name);

  /// No description provided for @priceListNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get priceListNameRequiredError;

  /// No description provided for @priceListMarginInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative percentage.'**
  String get priceListMarginInvalidError;

  /// No description provided for @priceListLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load price list.'**
  String get priceListLoadFailedError;

  /// No description provided for @priceListCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create price list.'**
  String get priceListCreateFailedError;

  /// No description provided for @priceListUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update price list.'**
  String get priceListUpdateFailedError;

  /// No description provided for @priceListDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete price list.'**
  String get priceListDeleteFailedError;

  /// No description provided for @priceListCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create price lists.'**
  String get priceListCreatePermissionDeniedError;

  /// No description provided for @priceListUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit price lists.'**
  String get priceListUpdatePermissionDeniedError;

  /// No description provided for @priceListDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete price lists.'**
  String get priceListDeletePermissionDeniedError;

  /// No description provided for @pricingProductPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get pricingProductPickerLabel;

  /// No description provided for @pricingSelectProductPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a product to see and edit its prices.'**
  String get pricingSelectProductPrompt;

  /// No description provided for @pricingNoPriceListsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No price lists exist yet. Create one first.'**
  String get pricingNoPriceListsEmptyState;

  /// No description provided for @pricingPriceNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get pricingPriceNotSet;

  /// No description provided for @pricingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prices: {error}'**
  String pricingLoadError(Object error);

  /// No description provided for @pricingSaveFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save price.'**
  String get pricingSaveFailedError;

  /// No description provided for @pricingUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit prices.'**
  String get pricingUpdatePermissionDeniedError;

  /// No description provided for @pricingInvalidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative amount.'**
  String get pricingInvalidAmountError;

  /// No description provided for @columnPriceList.
  ///
  /// In en, this message translates to:
  /// **'Price list'**
  String get columnPriceList;

  /// No description provided for @columnPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get columnPrice;

  /// No description provided for @columnLowProfit.
  ///
  /// In en, this message translates to:
  /// **'Low profit'**
  String get columnLowProfit;

  /// No description provided for @columnHighProfit.
  ///
  /// In en, this message translates to:
  /// **'High profit'**
  String get columnHighProfit;

  /// No description provided for @editPriceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit price'**
  String get editPriceTooltip;

  /// No description provided for @savePriceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get savePriceTooltip;

  /// No description provided for @cancelPriceEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelPriceEditTooltip;

  /// No description provided for @newExchangeRateTooltip.
  ///
  /// In en, this message translates to:
  /// **'New exchange rate'**
  String get newExchangeRateTooltip;

  /// No description provided for @noExchangeRatesFound.
  ///
  /// In en, this message translates to:
  /// **'No exchange rates found.'**
  String get noExchangeRatesFound;

  /// No description provided for @exchangeRatesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exchange rates: {error}'**
  String exchangeRatesLoadError(Object error);

  /// No description provided for @columnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get columnDate;

  /// No description provided for @columnBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get columnBaseCurrency;

  /// No description provided for @columnTargetCurrency.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get columnTargetCurrency;

  /// No description provided for @columnRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get columnRate;

  /// No description provided for @exchangeRateDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get exchangeRateDateLabel;

  /// No description provided for @exchangeRateBaseCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get exchangeRateBaseCurrencyLabel;

  /// No description provided for @exchangeRateTargetCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Target currency'**
  String get exchangeRateTargetCurrencyLabel;

  /// No description provided for @exchangeRateRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get exchangeRateRateLabel;

  /// No description provided for @newExchangeRateTitle.
  ///
  /// In en, this message translates to:
  /// **'New exchange rate'**
  String get newExchangeRateTitle;

  /// No description provided for @editExchangeRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit exchange rate'**
  String get editExchangeRateTitle;

  /// No description provided for @viewExchangeRateTitle.
  ///
  /// In en, this message translates to:
  /// **'View exchange rate'**
  String get viewExchangeRateTitle;

  /// No description provided for @deleteExchangeRateButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteExchangeRateButton;

  /// No description provided for @deleteExchangeRateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete exchange rate?'**
  String get deleteExchangeRateConfirmTitle;

  /// No description provided for @deleteExchangeRateConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this exchange rate. This cannot be undone.'**
  String get deleteExchangeRateConfirmMessage;

  /// No description provided for @exchangeRateDateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Date is required.'**
  String get exchangeRateDateRequiredError;

  /// No description provided for @exchangeRateRateInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive rate.'**
  String get exchangeRateRateInvalidError;

  /// No description provided for @exchangeRateCurrencyRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Select a currency.'**
  String get exchangeRateCurrencyRequiredError;

  /// No description provided for @exchangeRateLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exchange rate.'**
  String get exchangeRateLoadFailedError;

  /// No description provided for @exchangeRateCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create exchange rate.'**
  String get exchangeRateCreateFailedError;

  /// No description provided for @exchangeRateUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update exchange rate.'**
  String get exchangeRateUpdateFailedError;

  /// No description provided for @exchangeRateDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete exchange rate.'**
  String get exchangeRateDeleteFailedError;

  /// No description provided for @exchangeRateCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create exchange rates.'**
  String get exchangeRateCreatePermissionDeniedError;

  /// No description provided for @exchangeRateUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit exchange rates.'**
  String get exchangeRateUpdatePermissionDeniedError;

  /// No description provided for @exchangeRateDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete exchange rates.'**
  String get exchangeRateDeletePermissionDeniedError;

  /// No description provided for @dateRangeFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRangeFilterLabel;

  /// No description provided for @currencyFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency pair'**
  String get currencyFilterLabel;

  /// No description provided for @clearDateRangeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear date range'**
  String get clearDateRangeTooltip;

  /// No description provided for @currencyMxnLabel.
  ///
  /// In en, this message translates to:
  /// **'MXN — Mexican Peso'**
  String get currencyMxnLabel;

  /// No description provided for @currencyUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'USD — US Dollar'**
  String get currencyUsdLabel;

  /// No description provided for @currencyEurLabel.
  ///
  /// In en, this message translates to:
  /// **'EUR — Euro'**
  String get currencyEurLabel;

  /// No description provided for @suppliersMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersMenuTitle;

  /// No description provided for @labelsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labelsMenuTitle;

  /// No description provided for @employeesMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employeesMenuTitle;

  /// No description provided for @customersMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersMenuTitle;

  /// No description provided for @taxpayerRecipientsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Taxpayer Recipients'**
  String get taxpayerRecipientsMenuTitle;

  /// No description provided for @expensesMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesMenuTitle;

  /// No description provided for @vehiclesMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehiclesMenuTitle;

  /// No description provided for @vehicleOperatorsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Operators'**
  String get vehicleOperatorsMenuTitle;

  /// No description provided for @zoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zoneLabel;

  /// No description provided for @creditLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit limit'**
  String get creditLimitLabel;

  /// No description provided for @creditDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit days'**
  String get creditDaysLabel;

  /// No description provided for @creditLimitInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative amount.'**
  String get creditLimitInvalidError;

  /// No description provided for @creditDaysInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative whole number.'**
  String get creditDaysInvalidError;

  /// No description provided for @suppliersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get suppliersSearchLabel;

  /// No description provided for @newSupplierTooltip.
  ///
  /// In en, this message translates to:
  /// **'New supplier'**
  String get newSupplierTooltip;

  /// No description provided for @noSuppliersFound.
  ///
  /// In en, this message translates to:
  /// **'No suppliers found.'**
  String get noSuppliersFound;

  /// No description provided for @suppliersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suppliers: {error}'**
  String suppliersLoadError(Object error);

  /// No description provided for @newSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'New supplier'**
  String get newSupplierTitle;

  /// No description provided for @editSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit supplier'**
  String get editSupplierTitle;

  /// No description provided for @viewSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'View supplier'**
  String get viewSupplierTitle;

  /// No description provided for @deleteSupplierButton.
  ///
  /// In en, this message translates to:
  /// **'Delete supplier'**
  String get deleteSupplierButton;

  /// No description provided for @deleteSupplierConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete supplier?'**
  String get deleteSupplierConfirmTitle;

  /// No description provided for @deleteSupplierConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteSupplierConfirmMessage(String name);

  /// No description provided for @supplierLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load supplier.'**
  String get supplierLoadFailedError;

  /// No description provided for @supplierCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create supplier.'**
  String get supplierCreateFailedError;

  /// No description provided for @supplierUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update supplier.'**
  String get supplierUpdateFailedError;

  /// No description provided for @supplierDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete supplier.'**
  String get supplierDeleteFailedError;

  /// No description provided for @supplierCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create suppliers.'**
  String get supplierCreatePermissionDeniedError;

  /// No description provided for @supplierUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit suppliers.'**
  String get supplierUpdatePermissionDeniedError;

  /// No description provided for @supplierDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete suppliers.'**
  String get supplierDeletePermissionDeniedError;

  /// No description provided for @supplierCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Code is required.'**
  String get supplierCodeRequiredError;

  /// No description provided for @supplierNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get supplierNameRequiredError;

  /// No description provided for @labelsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get labelsSearchLabel;

  /// No description provided for @newLabelTooltip.
  ///
  /// In en, this message translates to:
  /// **'New label'**
  String get newLabelTooltip;

  /// No description provided for @noLabelsFound.
  ///
  /// In en, this message translates to:
  /// **'No labels found.'**
  String get noLabelsFound;

  /// No description provided for @labelsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load labels: {error}'**
  String labelsLoadError(Object error);

  /// No description provided for @newLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'New label'**
  String get newLabelTitle;

  /// No description provided for @editLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit label'**
  String get editLabelTitle;

  /// No description provided for @viewLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'View label'**
  String get viewLabelTitle;

  /// No description provided for @deleteLabelButton.
  ///
  /// In en, this message translates to:
  /// **'Delete label'**
  String get deleteLabelButton;

  /// No description provided for @deleteLabelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete label?'**
  String get deleteLabelConfirmTitle;

  /// No description provided for @deleteLabelConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteLabelConfirmMessage(String name);

  /// No description provided for @labelLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load label.'**
  String get labelLoadFailedError;

  /// No description provided for @labelCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create label.'**
  String get labelCreateFailedError;

  /// No description provided for @labelUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update label.'**
  String get labelUpdateFailedError;

  /// No description provided for @labelDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete label.'**
  String get labelDeleteFailedError;

  /// No description provided for @labelCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create labels.'**
  String get labelCreatePermissionDeniedError;

  /// No description provided for @labelUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit labels.'**
  String get labelUpdatePermissionDeniedError;

  /// No description provided for @labelDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete labels.'**
  String get labelDeletePermissionDeniedError;

  /// No description provided for @labelNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get labelNameRequiredError;

  /// No description provided for @expensesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get expensesSearchLabel;

  /// No description provided for @newExpenseTooltip.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newExpenseTooltip;

  /// No description provided for @noExpensesFound.
  ///
  /// In en, this message translates to:
  /// **'No expenses found.'**
  String get noExpensesFound;

  /// No description provided for @expensesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load expenses: {error}'**
  String expensesLoadError(Object error);

  /// No description provided for @newExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newExpenseTitle;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpenseTitle;

  /// No description provided for @viewExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'View expense'**
  String get viewExpenseTitle;

  /// No description provided for @deleteExpenseButton.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get deleteExpenseButton;

  /// No description provided for @deleteExpenseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get deleteExpenseConfirmTitle;

  /// No description provided for @deleteExpenseConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteExpenseConfirmMessage(String name);

  /// No description provided for @expenseLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load expense.'**
  String get expenseLoadFailedError;

  /// No description provided for @expenseCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create expense.'**
  String get expenseCreateFailedError;

  /// No description provided for @expenseUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update expense.'**
  String get expenseUpdateFailedError;

  /// No description provided for @expenseDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete expense.'**
  String get expenseDeleteFailedError;

  /// No description provided for @expenseCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create expenses.'**
  String get expenseCreatePermissionDeniedError;

  /// No description provided for @expenseUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit expenses.'**
  String get expenseUpdatePermissionDeniedError;

  /// No description provided for @expenseDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete expenses.'**
  String get expenseDeletePermissionDeniedError;

  /// No description provided for @expenseNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get expenseNameRequiredError;

  /// No description provided for @licensePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get licensePlateLabel;

  /// No description provided for @tonsCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Tons capacity'**
  String get tonsCapacityLabel;

  /// No description provided for @vehiclesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by plate, name, or nickname'**
  String get vehiclesSearchLabel;

  /// No description provided for @newVehicleTooltip.
  ///
  /// In en, this message translates to:
  /// **'New vehicle'**
  String get newVehicleTooltip;

  /// No description provided for @noVehiclesFound.
  ///
  /// In en, this message translates to:
  /// **'No vehicles found.'**
  String get noVehiclesFound;

  /// No description provided for @vehiclesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicles: {error}'**
  String vehiclesLoadError(Object error);

  /// No description provided for @newVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'New vehicle'**
  String get newVehicleTitle;

  /// No description provided for @editVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit vehicle'**
  String get editVehicleTitle;

  /// No description provided for @viewVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'View vehicle'**
  String get viewVehicleTitle;

  /// No description provided for @deleteVehicleButton.
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle'**
  String get deleteVehicleButton;

  /// No description provided for @deleteVehicleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle?'**
  String get deleteVehicleConfirmTitle;

  /// No description provided for @deleteVehicleConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteVehicleConfirmMessage(String name);

  /// No description provided for @vehicleLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicle.'**
  String get vehicleLoadFailedError;

  /// No description provided for @vehicleCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create vehicle.'**
  String get vehicleCreateFailedError;

  /// No description provided for @vehicleUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update vehicle.'**
  String get vehicleUpdateFailedError;

  /// No description provided for @vehicleDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete vehicle.'**
  String get vehicleDeleteFailedError;

  /// No description provided for @vehicleCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create vehicles.'**
  String get vehicleCreatePermissionDeniedError;

  /// No description provided for @vehicleUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit vehicles.'**
  String get vehicleUpdatePermissionDeniedError;

  /// No description provided for @vehicleDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete vehicles.'**
  String get vehicleDeletePermissionDeniedError;

  /// No description provided for @vehicleLicensePlateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'License plate is required.'**
  String get vehicleLicensePlateRequiredError;

  /// No description provided for @vehicleNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get vehicleNameRequiredError;

  /// No description provided for @vehicleNicknameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Nickname is required.'**
  String get vehicleNicknameRequiredError;

  /// No description provided for @vehicleTonsCapacityInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative whole number.'**
  String get vehicleTonsCapacityInvalidError;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverLabel;

  /// No description provided for @licenseTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'License type'**
  String get licenseTypeLabel;

  /// No description provided for @driverLicenseNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get driverLicenseNumberLabel;

  /// No description provided for @issueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get issueDateLabel;

  /// No description provided for @expirationDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get expirationDateLabel;

  /// No description provided for @issuingLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Issuing location'**
  String get issuingLocationLabel;

  /// No description provided for @daysUntilExpiryColumn.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get daysUntilExpiryColumn;

  /// No description provided for @expiresInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String expiresInDays(int days);

  /// No description provided for @expiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get expiresToday;

  /// No description provided for @expiredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {days} days ago'**
  String expiredDaysAgo(int days);

  /// No description provided for @vehicleOperatorsDriverFilter.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get vehicleOperatorsDriverFilter;

  /// No description provided for @vehicleOperatorsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by driver or license number'**
  String get vehicleOperatorsSearchLabel;

  /// No description provided for @newVehicleOperatorTooltip.
  ///
  /// In en, this message translates to:
  /// **'New vehicle operator'**
  String get newVehicleOperatorTooltip;

  /// No description provided for @noVehicleOperatorsFound.
  ///
  /// In en, this message translates to:
  /// **'No vehicle operators found.'**
  String get noVehicleOperatorsFound;

  /// No description provided for @vehicleOperatorsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicle operators: {error}'**
  String vehicleOperatorsLoadError(Object error);

  /// No description provided for @newVehicleOperatorTitle.
  ///
  /// In en, this message translates to:
  /// **'New vehicle operator'**
  String get newVehicleOperatorTitle;

  /// No description provided for @editVehicleOperatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit vehicle operator'**
  String get editVehicleOperatorTitle;

  /// No description provided for @viewVehicleOperatorTitle.
  ///
  /// In en, this message translates to:
  /// **'View vehicle operator'**
  String get viewVehicleOperatorTitle;

  /// No description provided for @deleteVehicleOperatorButton.
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle operator'**
  String get deleteVehicleOperatorButton;

  /// No description provided for @deleteVehicleOperatorConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle operator?'**
  String get deleteVehicleOperatorConfirmTitle;

  /// No description provided for @deleteVehicleOperatorConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteVehicleOperatorConfirmMessage(String name);

  /// No description provided for @vehicleOperatorLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vehicle operator.'**
  String get vehicleOperatorLoadFailedError;

  /// No description provided for @vehicleOperatorCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create vehicle operator.'**
  String get vehicleOperatorCreateFailedError;

  /// No description provided for @vehicleOperatorUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update vehicle operator.'**
  String get vehicleOperatorUpdateFailedError;

  /// No description provided for @vehicleOperatorDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete vehicle operator.'**
  String get vehicleOperatorDeleteFailedError;

  /// No description provided for @vehicleOperatorCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create vehicle operators.'**
  String get vehicleOperatorCreatePermissionDeniedError;

  /// No description provided for @vehicleOperatorUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit vehicle operators.'**
  String get vehicleOperatorUpdatePermissionDeniedError;

  /// No description provided for @vehicleOperatorDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete vehicle operators.'**
  String get vehicleOperatorDeletePermissionDeniedError;

  /// No description provided for @vehicleOperatorDriverRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Driver is required.'**
  String get vehicleOperatorDriverRequiredError;

  /// No description provided for @vehicleOperatorLicenseTypeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'License type is required.'**
  String get vehicleOperatorLicenseTypeRequiredError;

  /// No description provided for @vehicleOperatorDriverLicenseNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'License number is required.'**
  String get vehicleOperatorDriverLicenseNumberRequiredError;

  /// No description provided for @vehicleOperatorIssueDateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Issue date is required.'**
  String get vehicleOperatorIssueDateRequiredError;

  /// No description provided for @vehicleOperatorExpirationDateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Expiration date is required.'**
  String get vehicleOperatorExpirationDateRequiredError;

  /// No description provided for @vehicleOperatorExpirationBeforeIssueError.
  ///
  /// In en, this message translates to:
  /// **'Expiration date must not be before the issue date.'**
  String get vehicleOperatorExpirationBeforeIssueError;

  /// No description provided for @vehicleOperatorIssuingLocationRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Issuing location is required.'**
  String get vehicleOperatorIssuingLocationRequiredError;

  /// No description provided for @genderFemaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemaleLabel;

  /// No description provided for @genderMaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMaleLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @birthdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthdayLabel;

  /// No description provided for @taxpayerIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Taxpayer ID (RFC)'**
  String get taxpayerIdLabel;

  /// No description provided for @salesPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales person'**
  String get salesPersonLabel;

  /// No description provided for @personalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal ID'**
  String get personalIdLabel;

  /// No description provided for @startJobDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startJobDateLabel;

  /// No description provided for @enrollNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Enrollment number'**
  String get enrollNumberLabel;

  /// No description provided for @columnFullName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get columnFullName;

  /// No description provided for @employeesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name or nickname'**
  String get employeesSearchLabel;

  /// No description provided for @newEmployeeTooltip.
  ///
  /// In en, this message translates to:
  /// **'New employee'**
  String get newEmployeeTooltip;

  /// No description provided for @noEmployeesFound.
  ///
  /// In en, this message translates to:
  /// **'No employees found.'**
  String get noEmployeesFound;

  /// No description provided for @employeesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load employees: {error}'**
  String employeesLoadError(Object error);

  /// No description provided for @employeesSalesPersonFilter.
  ///
  /// In en, this message translates to:
  /// **'Sales person'**
  String get employeesSalesPersonFilter;

  /// No description provided for @newEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'New employee'**
  String get newEmployeeTitle;

  /// No description provided for @editEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get editEmployeeTitle;

  /// No description provided for @viewEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'View employee'**
  String get viewEmployeeTitle;

  /// No description provided for @deleteEmployeeButton.
  ///
  /// In en, this message translates to:
  /// **'Delete employee'**
  String get deleteEmployeeButton;

  /// No description provided for @deleteEmployeeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete employee?'**
  String get deleteEmployeeConfirmTitle;

  /// No description provided for @deleteEmployeeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteEmployeeConfirmMessage(String name);

  /// No description provided for @employeeLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load employee.'**
  String get employeeLoadFailedError;

  /// No description provided for @employeeCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create employee.'**
  String get employeeCreateFailedError;

  /// No description provided for @employeeUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update employee.'**
  String get employeeUpdateFailedError;

  /// No description provided for @employeeDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete employee.'**
  String get employeeDeleteFailedError;

  /// No description provided for @employeeCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create employees.'**
  String get employeeCreatePermissionDeniedError;

  /// No description provided for @employeeUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit employees.'**
  String get employeeUpdatePermissionDeniedError;

  /// No description provided for @employeeDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete employees.'**
  String get employeeDeletePermissionDeniedError;

  /// No description provided for @employeeFirstNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get employeeFirstNameRequiredError;

  /// No description provided for @employeeLastNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Last name is required.'**
  String get employeeLastNameRequiredError;

  /// No description provided for @employeeNicknameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Nickname is required.'**
  String get employeeNicknameRequiredError;

  /// No description provided for @employeeGenderRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Gender is required.'**
  String get employeeGenderRequiredError;

  /// No description provided for @employeeBirthdayRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Birthday is required.'**
  String get employeeBirthdayRequiredError;

  /// No description provided for @employeeStartJobDateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Start date is required.'**
  String get employeeStartJobDateRequiredError;

  /// No description provided for @employeeEnrollNumberInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative whole number.'**
  String get employeeEnrollNumberInvalidError;

  /// No description provided for @priceListFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Price list'**
  String get priceListFieldLabel;

  /// No description provided for @noneAssignedLabel.
  ///
  /// In en, this message translates to:
  /// **'None assigned'**
  String get noneAssignedLabel;

  /// No description provided for @shippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shippingLabel;

  /// No description provided for @shippingRequiredDocumentLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping requires document'**
  String get shippingRequiredDocumentLabel;

  /// No description provided for @columnSalesperson.
  ///
  /// In en, this message translates to:
  /// **'Salesperson'**
  String get columnSalesperson;

  /// No description provided for @customersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get customersSearchLabel;

  /// No description provided for @newCustomerTooltip.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomerTooltip;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found.'**
  String get noCustomersFound;

  /// No description provided for @customersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customers: {error}'**
  String customersLoadError(Object error);

  /// No description provided for @customersPriceListFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Price list'**
  String get customersPriceListFilterLabel;

  /// No description provided for @customersSalespersonFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Salesperson'**
  String get customersSalespersonFilterLabel;

  /// No description provided for @newCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomerTitle;

  /// No description provided for @editCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomerTitle;

  /// No description provided for @viewCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'View customer'**
  String get viewCustomerTitle;

  /// No description provided for @deleteCustomerButton.
  ///
  /// In en, this message translates to:
  /// **'Delete customer'**
  String get deleteCustomerButton;

  /// No description provided for @deleteCustomerConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete customer?'**
  String get deleteCustomerConfirmTitle;

  /// No description provided for @deleteCustomerConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteCustomerConfirmMessage(String name);

  /// No description provided for @customerLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customer.'**
  String get customerLoadFailedError;

  /// No description provided for @customerCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create customer.'**
  String get customerCreateFailedError;

  /// No description provided for @customerUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update customer.'**
  String get customerUpdateFailedError;

  /// No description provided for @customerDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete customer.'**
  String get customerDeleteFailedError;

  /// No description provided for @customerCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create customers.'**
  String get customerCreatePermissionDeniedError;

  /// No description provided for @customerUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit customers.'**
  String get customerUpdatePermissionDeniedError;

  /// No description provided for @customerDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete customers.'**
  String get customerDeletePermissionDeniedError;

  /// No description provided for @customerCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Code is required.'**
  String get customerCodeRequiredError;

  /// No description provided for @customerNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get customerNameRequiredError;

  /// No description provided for @customerPriceListRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Price list is required.'**
  String get customerPriceListRequiredError;

  /// No description provided for @taxpayerRecipientIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax ID (RFC)'**
  String get taxpayerRecipientIdLabel;

  /// No description provided for @postalCodeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCodeFieldLabel;

  /// No description provided for @regimeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax regime'**
  String get regimeFieldLabel;

  /// No description provided for @unresolvedFallbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unresolvedFallbackLabel;

  /// No description provided for @taxpayerRecipientsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get taxpayerRecipientsSearchLabel;

  /// No description provided for @newTaxpayerRecipientTooltip.
  ///
  /// In en, this message translates to:
  /// **'New taxpayer recipient'**
  String get newTaxpayerRecipientTooltip;

  /// No description provided for @noTaxpayerRecipientsFound.
  ///
  /// In en, this message translates to:
  /// **'No taxpayer recipients found.'**
  String get noTaxpayerRecipientsFound;

  /// No description provided for @taxpayerRecipientsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load taxpayer recipients: {error}'**
  String taxpayerRecipientsLoadError(Object error);

  /// No description provided for @newTaxpayerRecipientTitle.
  ///
  /// In en, this message translates to:
  /// **'New taxpayer recipient'**
  String get newTaxpayerRecipientTitle;

  /// No description provided for @editTaxpayerRecipientTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit taxpayer recipient'**
  String get editTaxpayerRecipientTitle;

  /// No description provided for @viewTaxpayerRecipientTitle.
  ///
  /// In en, this message translates to:
  /// **'View taxpayer recipient'**
  String get viewTaxpayerRecipientTitle;

  /// No description provided for @deleteTaxpayerRecipientButton.
  ///
  /// In en, this message translates to:
  /// **'Delete taxpayer recipient'**
  String get deleteTaxpayerRecipientButton;

  /// No description provided for @deleteTaxpayerRecipientConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete taxpayer recipient?'**
  String get deleteTaxpayerRecipientConfirmTitle;

  /// No description provided for @deleteTaxpayerRecipientConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteTaxpayerRecipientConfirmMessage(String name);

  /// No description provided for @taxpayerRecipientLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load taxpayer recipient.'**
  String get taxpayerRecipientLoadFailedError;

  /// No description provided for @taxpayerRecipientCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create taxpayer recipient.'**
  String get taxpayerRecipientCreateFailedError;

  /// No description provided for @taxpayerRecipientUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update taxpayer recipient.'**
  String get taxpayerRecipientUpdateFailedError;

  /// No description provided for @taxpayerRecipientDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete taxpayer recipient.'**
  String get taxpayerRecipientDeleteFailedError;

  /// No description provided for @taxpayerRecipientCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create taxpayer recipients.'**
  String get taxpayerRecipientCreatePermissionDeniedError;

  /// No description provided for @taxpayerRecipientUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit taxpayer recipients.'**
  String get taxpayerRecipientUpdatePermissionDeniedError;

  /// No description provided for @taxpayerRecipientDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete taxpayer recipients.'**
  String get taxpayerRecipientDeletePermissionDeniedError;

  /// No description provided for @taxpayerRecipientIdRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Tax ID is required.'**
  String get taxpayerRecipientIdRequiredError;

  /// No description provided for @taxpayerRecipientNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get taxpayerRecipientNameRequiredError;

  /// No description provided for @taxpayerRecipientEmailRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get taxpayerRecipientEmailRequiredError;

  /// No description provided for @facilityTypeStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get facilityTypeStore;

  /// No description provided for @facilityTypeProductionSite.
  ///
  /// In en, this message translates to:
  /// **'Production Site'**
  String get facilityTypeProductionSite;

  /// No description provided for @columnFacility.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get columnFacility;

  /// No description provided for @columnWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get columnWarehouse;

  /// No description provided for @columnComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get columnComment;

  /// No description provided for @columnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get columnType;

  /// No description provided for @columnTaxpayer.
  ///
  /// In en, this message translates to:
  /// **'Taxpayer'**
  String get columnTaxpayer;

  /// No description provided for @columnAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get columnAddress;

  /// No description provided for @columnLocation.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get columnLocation;

  /// No description provided for @facilityFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get facilityFieldLabel;

  /// No description provided for @warehouseFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouseFieldLabel;

  /// No description provided for @unknownFacilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown facility'**
  String get unknownFacilityLabel;

  /// No description provided for @unknownWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown warehouse'**
  String get unknownWarehouseLabel;

  /// No description provided for @warehousesMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Warehouses'**
  String get warehousesMenuTitle;

  /// No description provided for @warehousesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get warehousesSearchLabel;

  /// No description provided for @newWarehouseTooltip.
  ///
  /// In en, this message translates to:
  /// **'New warehouse'**
  String get newWarehouseTooltip;

  /// No description provided for @warehousesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load warehouses: {error}'**
  String warehousesLoadError(Object error);

  /// No description provided for @noWarehousesFound.
  ///
  /// In en, this message translates to:
  /// **'No warehouses found.'**
  String get noWarehousesFound;

  /// No description provided for @viewWarehouseTitle.
  ///
  /// In en, this message translates to:
  /// **'View Warehouse'**
  String get viewWarehouseTitle;

  /// No description provided for @editWarehouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Warehouse'**
  String get editWarehouseTitle;

  /// No description provided for @newWarehouseTitle.
  ///
  /// In en, this message translates to:
  /// **'New Warehouse'**
  String get newWarehouseTitle;

  /// No description provided for @deleteWarehouseButton.
  ///
  /// In en, this message translates to:
  /// **'Delete warehouse'**
  String get deleteWarehouseButton;

  /// No description provided for @deleteWarehouseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete warehouse?'**
  String get deleteWarehouseConfirmTitle;

  /// No description provided for @deleteWarehouseConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteWarehouseConfirmMessage(String name);

  /// No description provided for @warehouseLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load warehouse.'**
  String get warehouseLoadFailedError;

  /// No description provided for @warehouseCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create warehouse.'**
  String get warehouseCreateFailedError;

  /// No description provided for @warehouseUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update warehouse.'**
  String get warehouseUpdateFailedError;

  /// No description provided for @warehouseDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete warehouse.'**
  String get warehouseDeleteFailedError;

  /// No description provided for @warehouseCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create warehouses.'**
  String get warehouseCreatePermissionDeniedError;

  /// No description provided for @warehouseUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit warehouses.'**
  String get warehouseUpdatePermissionDeniedError;

  /// No description provided for @warehouseDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete warehouses.'**
  String get warehouseDeletePermissionDeniedError;

  /// No description provided for @warehouseFacilityRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Facility is required.'**
  String get warehouseFacilityRequiredError;

  /// No description provided for @warehouseCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Code is required.'**
  String get warehouseCodeRequiredError;

  /// No description provided for @warehouseNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get warehouseNameRequiredError;

  /// No description provided for @cashDrawersMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Drawers'**
  String get cashDrawersMenuTitle;

  /// No description provided for @cashDrawersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get cashDrawersSearchLabel;

  /// No description provided for @newCashDrawerTooltip.
  ///
  /// In en, this message translates to:
  /// **'New cash drawer'**
  String get newCashDrawerTooltip;

  /// No description provided for @cashDrawersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cash drawers: {error}'**
  String cashDrawersLoadError(Object error);

  /// No description provided for @noCashDrawersFound.
  ///
  /// In en, this message translates to:
  /// **'No cash drawers found.'**
  String get noCashDrawersFound;

  /// No description provided for @viewCashDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'View Cash Drawer'**
  String get viewCashDrawerTitle;

  /// No description provided for @editCashDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Cash Drawer'**
  String get editCashDrawerTitle;

  /// No description provided for @newCashDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'New Cash Drawer'**
  String get newCashDrawerTitle;

  /// No description provided for @deleteCashDrawerButton.
  ///
  /// In en, this message translates to:
  /// **'Delete cash drawer'**
  String get deleteCashDrawerButton;

  /// No description provided for @deleteCashDrawerConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete cash drawer?'**
  String get deleteCashDrawerConfirmTitle;

  /// No description provided for @deleteCashDrawerConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteCashDrawerConfirmMessage(String name);

  /// No description provided for @cashDrawerLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cash drawer.'**
  String get cashDrawerLoadFailedError;

  /// No description provided for @cashDrawerCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create cash drawer.'**
  String get cashDrawerCreateFailedError;

  /// No description provided for @cashDrawerUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update cash drawer.'**
  String get cashDrawerUpdateFailedError;

  /// No description provided for @cashDrawerDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete cash drawer.'**
  String get cashDrawerDeleteFailedError;

  /// No description provided for @cashDrawerCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create cash drawers.'**
  String get cashDrawerCreatePermissionDeniedError;

  /// No description provided for @cashDrawerUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit cash drawers.'**
  String get cashDrawerUpdatePermissionDeniedError;

  /// No description provided for @cashDrawerDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete cash drawers.'**
  String get cashDrawerDeletePermissionDeniedError;

  /// No description provided for @cashDrawerFacilityRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Facility is required.'**
  String get cashDrawerFacilityRequiredError;

  /// No description provided for @cashDrawerCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Code is required.'**
  String get cashDrawerCodeRequiredError;

  /// No description provided for @cashDrawerNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get cashDrawerNameRequiredError;

  /// No description provided for @pointsOfSaleMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Points of Sale'**
  String get pointsOfSaleMenuTitle;

  /// No description provided for @pointsOfSaleSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get pointsOfSaleSearchLabel;

  /// No description provided for @newPointSaleTooltip.
  ///
  /// In en, this message translates to:
  /// **'New point of sale'**
  String get newPointSaleTooltip;

  /// No description provided for @pointsOfSaleLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load points of sale: {error}'**
  String pointsOfSaleLoadError(Object error);

  /// No description provided for @noPointsOfSaleFound.
  ///
  /// In en, this message translates to:
  /// **'No points of sale found.'**
  String get noPointsOfSaleFound;

  /// No description provided for @viewPointSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'View Point of Sale'**
  String get viewPointSaleTitle;

  /// No description provided for @editPointSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Point of Sale'**
  String get editPointSaleTitle;

  /// No description provided for @newPointSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'New Point of Sale'**
  String get newPointSaleTitle;

  /// No description provided for @deletePointSaleButton.
  ///
  /// In en, this message translates to:
  /// **'Delete point of sale'**
  String get deletePointSaleButton;

  /// No description provided for @deletePointSaleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete point of sale?'**
  String get deletePointSaleConfirmTitle;

  /// No description provided for @deletePointSaleConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deletePointSaleConfirmMessage(String name);

  /// No description provided for @pointSaleLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load point of sale.'**
  String get pointSaleLoadFailedError;

  /// No description provided for @pointSaleCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create point of sale.'**
  String get pointSaleCreateFailedError;

  /// No description provided for @pointSaleUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update point of sale.'**
  String get pointSaleUpdateFailedError;

  /// No description provided for @pointSaleDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete point of sale.'**
  String get pointSaleDeleteFailedError;

  /// No description provided for @pointSaleCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create points of sale.'**
  String get pointSaleCreatePermissionDeniedError;

  /// No description provided for @pointSaleUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit points of sale.'**
  String get pointSaleUpdatePermissionDeniedError;

  /// No description provided for @pointSaleDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete points of sale.'**
  String get pointSaleDeletePermissionDeniedError;

  /// No description provided for @pointSaleFacilityRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Facility is required.'**
  String get pointSaleFacilityRequiredError;

  /// No description provided for @pointSaleCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Code is required.'**
  String get pointSaleCodeRequiredError;

  /// No description provided for @pointSaleNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get pointSaleNameRequiredError;

  /// No description provided for @pointSaleWarehouseRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Warehouse is required.'**
  String get pointSaleWarehouseRequiredError;

  /// No description provided for @facilitiesMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilitiesMenuTitle;

  /// No description provided for @facilitiesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get facilitiesSearchLabel;

  /// No description provided for @newFacilityTooltip.
  ///
  /// In en, this message translates to:
  /// **'New facility'**
  String get newFacilityTooltip;

  /// No description provided for @facilitiesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load facilities: {error}'**
  String facilitiesLoadError(Object error);

  /// No description provided for @noFacilitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No facilities found.'**
  String get noFacilitiesFound;

  /// No description provided for @viewFacilityTitle.
  ///
  /// In en, this message translates to:
  /// **'View Facility'**
  String get viewFacilityTitle;

  /// No description provided for @editFacilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Facility'**
  String get editFacilityTitle;

  /// No description provided for @newFacilityTitle.
  ///
  /// In en, this message translates to:
  /// **'New Facility'**
  String get newFacilityTitle;

  /// No description provided for @facilityReceiptMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt message'**
  String get facilityReceiptMessageLabel;

  /// No description provided for @facilityDefaultBatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Default batch'**
  String get facilityDefaultBatchLabel;

  /// No description provided for @facilityLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get facilityLogoLabel;

  /// No description provided for @deleteFacilityButton.
  ///
  /// In en, this message translates to:
  /// **'Delete facility'**
  String get deleteFacilityButton;

  /// No description provided for @deleteFacilityConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete facility?'**
  String get deleteFacilityConfirmTitle;

  /// No description provided for @deleteFacilityConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteFacilityConfirmMessage(String name);

  /// No description provided for @facilityLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load facility.'**
  String get facilityLoadFailedError;

  /// No description provided for @facilityCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create facility.'**
  String get facilityCreateFailedError;

  /// No description provided for @facilityUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update facility.'**
  String get facilityUpdateFailedError;

  /// No description provided for @facilityDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete facility.'**
  String get facilityDeleteFailedError;

  /// No description provided for @facilityCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create facilities.'**
  String get facilityCreatePermissionDeniedError;

  /// No description provided for @facilityUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to edit facilities.'**
  String get facilityUpdatePermissionDeniedError;

  /// No description provided for @facilityDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete facilities.'**
  String get facilityDeletePermissionDeniedError;

  /// No description provided for @facilityCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Code is required.'**
  String get facilityCodeRequiredError;

  /// No description provided for @facilityNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get facilityNameRequiredError;

  /// No description provided for @facilityLocationRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Postal code is required.'**
  String get facilityLocationRequiredError;

  /// No description provided for @facilityAddressRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Address is required.'**
  String get facilityAddressRequiredError;

  /// No description provided for @facilityTaxpayerRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Taxpayer is required.'**
  String get facilityTaxpayerRequiredError;

  /// No description provided for @facilityTaxpayerInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid RFC (up to 13 characters).'**
  String get facilityTaxpayerInvalidError;

  /// No description provided for @newAddressTooltip.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get newAddressTooltip;

  /// No description provided for @newAddressDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Address'**
  String get newAddressDialogTitle;

  /// No description provided for @createAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Create address'**
  String get createAddressButton;

  /// No description provided for @addressStreetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get addressStreetLabel;

  /// No description provided for @addressExteriorNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Exterior number'**
  String get addressExteriorNumberLabel;

  /// No description provided for @addressInteriorNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Interior number'**
  String get addressInteriorNumberLabel;

  /// No description provided for @addressPostalCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get addressPostalCodeLabel;

  /// No description provided for @addressNeighborhoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get addressNeighborhoodLabel;

  /// No description provided for @addressLocalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Locality'**
  String get addressLocalityLabel;

  /// No description provided for @addressBoroughLabel.
  ///
  /// In en, this message translates to:
  /// **'Borough'**
  String get addressBoroughLabel;

  /// No description provided for @addressStateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get addressStateLabel;

  /// No description provided for @addressCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get addressCityLabel;

  /// No description provided for @addressCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get addressCountryLabel;

  /// No description provided for @addressNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get addressNicknameLabel;

  /// No description provided for @addressCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create address.'**
  String get addressCreateFailedError;

  /// No description provided for @addressStreetRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Street is required.'**
  String get addressStreetRequiredError;

  /// No description provided for @addressExteriorNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Exterior number is required.'**
  String get addressExteriorNumberRequiredError;

  /// No description provided for @addressPostalCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Postal code is required.'**
  String get addressPostalCodeRequiredError;

  /// No description provided for @addressNeighborhoodRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood is required.'**
  String get addressNeighborhoodRequiredError;

  /// No description provided for @addressBoroughRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Borough is required.'**
  String get addressBoroughRequiredError;

  /// No description provided for @addressStateRequiredError.
  ///
  /// In en, this message translates to:
  /// **'State is required.'**
  String get addressStateRequiredError;

  /// No description provided for @addressCountryRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Country is required.'**
  String get addressCountryRequiredError;
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
