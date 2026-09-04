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

  /// Generic ValidationError message shown when no field-level errors are provided
  ///
  /// In en, this message translates to:
  /// **'Please correct the highlighted fields.'**
  String get errorValidationGeneric;

  /// Generic AuthError message
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get errorAuthGeneric;

  /// Generic NotFoundError message
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get errorNotFoundGeneric;

  /// Generic ServerError message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server. Please try again later.'**
  String get errorServerGeneric;

  /// Generic NetworkError message
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection and try again.'**
  String get errorNetworkGeneric;

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

  /// XBE default-branding login screen headline (spec 019 FR-014)
  ///
  /// In en, this message translates to:
  /// **'All your operations, in one place.'**
  String get loginTagline;

  /// XBE default-branding login screen subhead (spec 019 FR-014)
  ///
  /// In en, this message translates to:
  /// **'Catalogs, price lists, facilities, and sales for all your branches, synced in real time.'**
  String get loginSubhead;

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

  /// XBE default-branding dashboard greeting (spec 019 FR-015)
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// XBE default-branding dashboard summary line — static placeholder copy (spec 019 FR-016)
  ///
  /// In en, this message translates to:
  /// **'You have price lists pending approval and facilities with yesterday\'s cash cut still open.'**
  String get homeSummary;

  /// XBE default-branding dashboard hero action button
  ///
  /// In en, this message translates to:
  /// **'Review pending'**
  String get homeReviewPendingButton;

  /// XBE default-branding dashboard hero action button
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get homeNewSaleButton;

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

  /// User menu entry opening the user settings screen (spec 027 FR-016)
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsMenuTitle;

  /// User settings screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// User settings: appearance control label
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceLabel;

  /// No description provided for @settingsAppearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsAppearanceLight;

  /// No description provided for @settingsAppearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsAppearanceDark;

  /// No description provided for @settingsAppearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsAppearanceSystem;

  /// User settings: text-size control label (spec 027 FR-019)
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSizeLabel;

  /// No description provided for @settingsTextSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settingsTextSizeSmall;

  /// No description provided for @settingsTextSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsTextSizeNormal;

  /// No description provided for @settingsTextSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingsTextSizeLarge;

  /// No description provided for @settingsTextSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get settingsTextSizeExtraLarge;

  /// User settings: language control label (spec 027 FR-018)
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsLanguageSystem;

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

  /// No description provided for @productsAttributesFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Product attributes'**
  String get productsAttributesFilterLabel;

  /// No description provided for @productsSupplierFilter.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get productsSupplierFilter;

  /// Field label inside the filter drawer's Supplier section — the section already carries the noun as its heading, so the field says what to do (spec 033 US6)
  ///
  /// In en, this message translates to:
  /// **'Search suppliers…'**
  String get productsSupplierSearchHint;

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

  /// Shared list `failed` state's retry action (017-ui-consistency-filters US5)
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Shared list `filteredEmpty` state's clear-filters action (017-ui-consistency-filters US5)
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFiltersButton;

  /// Shared list `filteredEmpty` state's title, shown when a filtered/searched list has zero results
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get filteredEmptyTitle;

  /// Shared list `filteredEmpty` state's subtitle
  ///
  /// In en, this message translates to:
  /// **'Try adjusting or clearing your filters.'**
  String get filteredEmptyMessage;

  /// Shared list `failed` state's title, shown above the mapped ErrorBanner
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this list'**
  String get loadErrorTitle;

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
  /// **'\"{canonicalName}\" ({canonicalCode}) is kept.\n\"{duplicateName}\" ({duplicateCode}) is deleted and its history moves to the kept product. This cannot be undone.'**
  String mergeConfirmMessage(
    String canonicalName,
    String canonicalCode,
    String duplicateName,
    String duplicateCode,
  );

  /// No description provided for @mergeConfirmTotalLine.
  ///
  /// In en, this message translates to:
  /// **'Records that will move: {total}.'**
  String mergeConfirmTotalLine(int total);

  /// No description provided for @mergeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Products merged successfully.'**
  String get mergeSuccess;

  /// No description provided for @mergeKeptLabel.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get mergeKeptLabel;

  /// No description provided for @mergeDeletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get mergeDeletedLabel;

  /// No description provided for @mergeSwapTooltip.
  ///
  /// In en, this message translates to:
  /// **'Swap which product is kept and which is deleted'**
  String get mergeSwapTooltip;

  /// No description provided for @mergeComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Data comparison'**
  String get mergeComparisonTitle;

  /// No description provided for @mergeComparisonFieldHeader.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get mergeComparisonFieldHeader;

  /// No description provided for @mergeDiffBadge.
  ///
  /// In en, this message translates to:
  /// **'Differs'**
  String get mergeDiffBadge;

  /// No description provided for @mergeAcknowledgeLabel.
  ///
  /// In en, this message translates to:
  /// **'I understand \"{duplicateName}\" will be permanently deleted.'**
  String mergeAcknowledgeLabel(String duplicateName);

  /// No description provided for @mergeFieldId.
  ///
  /// In en, this message translates to:
  /// **'Internal ID'**
  String get mergeFieldId;

  /// No description provided for @mergeFieldCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get mergeFieldCode;

  /// No description provided for @mergeFieldSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get mergeFieldSku;

  /// No description provided for @mergeFieldModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get mergeFieldModel;

  /// No description provided for @mergeFieldBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get mergeFieldBrand;

  /// No description provided for @mergeFieldUom.
  ///
  /// In en, this message translates to:
  /// **'Unit of measurement'**
  String get mergeFieldUom;

  /// No description provided for @mergeFieldTaxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax rate'**
  String get mergeFieldTaxRate;

  /// No description provided for @mergeFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get mergeFieldStatus;

  /// No description provided for @mergeRelatedRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Records attached to the product being deleted'**
  String get mergeRelatedRecordsTitle;

  /// No description provided for @mergeRelatedDestroyedNote.
  ///
  /// In en, this message translates to:
  /// **'deleted, not moved'**
  String get mergeRelatedDestroyedNote;

  /// No description provided for @mergeRelatedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get mergeRelatedTotalLabel;

  /// No description provided for @mergeCategorySalesOrderDetail.
  ///
  /// In en, this message translates to:
  /// **'Sales order lines'**
  String get mergeCategorySalesOrderDetail;

  /// No description provided for @mergeCategoryPurchaseOrderDetail.
  ///
  /// In en, this message translates to:
  /// **'Purchase order lines'**
  String get mergeCategoryPurchaseOrderDetail;

  /// No description provided for @mergeCategoryInventoryReceiptDetail.
  ///
  /// In en, this message translates to:
  /// **'Inventory receipt lines'**
  String get mergeCategoryInventoryReceiptDetail;

  /// No description provided for @mergeCategoryInventoryIssueDetail.
  ///
  /// In en, this message translates to:
  /// **'Inventory issue lines'**
  String get mergeCategoryInventoryIssueDetail;

  /// No description provided for @mergeCategoryInventoryTransferDetail.
  ///
  /// In en, this message translates to:
  /// **'Inventory transfer lines'**
  String get mergeCategoryInventoryTransferDetail;

  /// No description provided for @mergeCategoryLotSerialTracking.
  ///
  /// In en, this message translates to:
  /// **'Lot and serial tracking'**
  String get mergeCategoryLotSerialTracking;

  /// No description provided for @mergeCategoryProductPrice.
  ///
  /// In en, this message translates to:
  /// **'Price lists'**
  String get mergeCategoryProductPrice;

  /// No description provided for @mergeCategoryProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get mergeCategoryProductLabel;

  /// No description provided for @mergeCategoryFiscalDocumentDetail.
  ///
  /// In en, this message translates to:
  /// **'Fiscal document lines'**
  String get mergeCategoryFiscalDocumentDetail;

  /// No description provided for @mergeCategoryCommissionProduct.
  ///
  /// In en, this message translates to:
  /// **'Commissions'**
  String get mergeCategoryCommissionProduct;

  /// No description provided for @mergeCategoryCustomerDiscount.
  ///
  /// In en, this message translates to:
  /// **'Customer discounts'**
  String get mergeCategoryCustomerDiscount;

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
  /// **'Employee'**
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

  /// No description provided for @userEmployeeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Employee is required.'**
  String get userEmployeeRequiredError;

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

  /// No description provided for @pricingGridHint.
  ///
  /// In en, this message translates to:
  /// **'Click any price to edit · Enter saves and drops down · Tab moves right · Escape cancels'**
  String get pricingGridHint;

  /// No description provided for @pricingGridReadOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Read-only — your profile has no update right on Pricing.'**
  String get pricingGridReadOnlyHint;

  /// No description provided for @pricingGridColumnsFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Price lists shown'**
  String get pricingGridColumnsFilterLabel;

  /// No description provided for @pricingGridWorklistAll.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get pricingGridWorklistAll;

  /// Pricing grid worklist chip: products with no price on this list (spec 033 US2)
  ///
  /// In en, this message translates to:
  /// **'Missing {priceListName} ({count})'**
  String pricingGridWorklistMissing(String priceListName, int count);

  /// No description provided for @pricingGridColumnActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Column actions'**
  String get pricingGridColumnActionsTooltip;

  /// No description provided for @pricingGridFillDown.
  ///
  /// In en, this message translates to:
  /// **'Fill down from first row'**
  String get pricingGridFillDown;

  /// Pricing grid column action: copy the deployment's cost list into this column (spec 033 FR-013)
  ///
  /// In en, this message translates to:
  /// **'Copy from {costListName}'**
  String pricingGridCopyFromCost(String costListName);

  /// No description provided for @pricingGridAdjustLabel.
  ///
  /// In en, this message translates to:
  /// **'Adjust every shown row by'**
  String get pricingGridAdjustLabel;

  /// No description provided for @pricingGridAdjustApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get pricingGridAdjustApply;

  /// Pricing grid: how many rows a column action changed (spec 033 FR-014)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No prices changed} =1{1 price changed} other{{count} prices changed}}'**
  String pricingGridRowsChanged(int count);

  /// No description provided for @pricingGridColumnActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not apply the action. No prices changed.'**
  String get pricingGridColumnActionFailed;

  /// No description provided for @pricingGridCellSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get pricingGridCellSaving;

  /// Pricing grid cell tooltip after a stored change (spec 033 FR-022)
  ///
  /// In en, this message translates to:
  /// **'Saved · was {previous}'**
  String pricingGridCellSaved(String previous);

  /// Pricing grid cell tooltip for a cell that had no price before this session (spec 033 FR-022)
  ///
  /// In en, this message translates to:
  /// **'Saved · newly priced'**
  String get pricingGridCellSavedNew;

  /// Pricing grid change-summary bar count (spec 033 FR-023)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 price changed} other{{count} prices changed}}'**
  String pricingGridSummary(int count);

  /// Pricing grid change-summary bar rejected count (spec 033 FR-023)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rejected} other{{count} rejected}}'**
  String pricingGridSummaryRejected(int count);

  /// No description provided for @pricingGridUndoLast.
  ///
  /// In en, this message translates to:
  /// **'Undo last'**
  String get pricingGridUndoLast;

  /// No description provided for @pricingGridRevertAll.
  ///
  /// In en, this message translates to:
  /// **'Revert all'**
  String get pricingGridRevertAll;

  /// Pricing grid summary bar: clears the refused edits without touching the accepted ones (spec 033 FR-023a)
  ///
  /// In en, this message translates to:
  /// **'Dismiss rejected'**
  String get pricingGridDismissRejected;

  /// No description provided for @pricingGridDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard outstanding changes?'**
  String get pricingGridDiscardTitle;

  /// No description provided for @pricingGridDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'The undo history and any rejected text will be lost. Prices already saved are unaffected.'**
  String get pricingGridDiscardBody;

  /// No description provided for @pricingGridDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave anyway'**
  String get pricingGridDiscardConfirm;

  /// No description provided for @pricingGridDiscardCancel.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get pricingGridDiscardCancel;

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

  /// No description provided for @priceListNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get priceListNameLabel;

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

  /// No description provided for @priceListDeleteLead.
  ///
  /// In en, this message translates to:
  /// **'{name} #{id} will be permanently deleted. This cannot be undone.'**
  String priceListDeleteLead(String name, int id);

  /// No description provided for @priceListDeleteRelatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Records attached to this price list'**
  String get priceListDeleteRelatedTitle;

  /// No description provided for @priceListDeleteTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get priceListDeleteTotalLabel;

  /// No description provided for @priceListDeleteTotalCaption.
  ///
  /// In en, this message translates to:
  /// **'Records this deletion touches — not all of them are deleted.'**
  String get priceListDeleteTotalCaption;

  /// No description provided for @priceListDeleteFateDestroyed.
  ///
  /// In en, this message translates to:
  /// **'deleted permanently'**
  String get priceListDeleteFateDestroyed;

  /// No description provided for @priceListDeleteFateMoved.
  ///
  /// In en, this message translates to:
  /// **'moved to the replacement'**
  String get priceListDeleteFateMoved;

  /// No description provided for @priceListDeleteFateBlocking.
  ///
  /// In en, this message translates to:
  /// **'blocks deletion — clear these first'**
  String get priceListDeleteFateBlocking;

  /// No description provided for @priceListDeleteCategoryProductPrice.
  ///
  /// In en, this message translates to:
  /// **'Product prices'**
  String get priceListDeleteCategoryProductPrice;

  /// No description provided for @priceListDeleteCategoryCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get priceListDeleteCategoryCustomer;

  /// No description provided for @priceListDeleteViewCustomers.
  ///
  /// In en, this message translates to:
  /// **'View customers'**
  String get priceListDeleteViewCustomers;

  /// No description provided for @priceListDeleteCleanNote.
  ///
  /// In en, this message translates to:
  /// **'No prices and no customers depend on this list.'**
  String get priceListDeleteCleanNote;

  /// No description provided for @priceListDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get priceListDeleteConfirm;

  /// No description provided for @priceListDeleteConfirmPrices.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete list and 1 price} other{Delete list and {formatted} prices}}'**
  String priceListDeleteConfirmPrices(int count, String formatted);

  /// No description provided for @priceListDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Price list deleted.'**
  String get priceListDeletedMessage;

  /// No description provided for @priceListDeleteReplacementLabel.
  ///
  /// In en, this message translates to:
  /// **'Replacement price list'**
  String get priceListDeleteReplacementLabel;

  /// No description provided for @priceListDeleteReplacementLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Replacement price list (optional)'**
  String get priceListDeleteReplacementLabelOptional;

  /// No description provided for @priceListDeleteReplacementRequiredHelper.
  ///
  /// In en, this message translates to:
  /// **'Required — every customer on this list moves here.'**
  String get priceListDeleteReplacementRequiredHelper;

  /// No description provided for @priceListDeleteReplacementOptionalHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional — used only if customers turn out to be assigned.'**
  String get priceListDeleteReplacementOptionalHelper;

  /// No description provided for @priceListDeleteReplacementChosenHelper.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{All 1 customer moves to {name}.} other{All {formatted} customers move to {name}.}}'**
  String priceListDeleteReplacementChosenHelper(
    int count,
    String formatted,
    String name,
  );

  /// No description provided for @priceListDeleteConfirmCustomers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete list and move 1 customer} other{Delete list and move {formatted} customers}}'**
  String priceListDeleteConfirmCustomers(int count, String formatted);

  /// No description provided for @priceListDeletedWithMoveMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Price list deleted. 1 customer moved to {name}.} other{Price list deleted. {formatted} customers moved to {name}.}}'**
  String priceListDeletedWithMoveMessage(
    int count,
    String formatted,
    String name,
  );

  /// No description provided for @priceListDeleteAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'I understand this cannot be undone and that this list\'s prices are deleted with it.'**
  String get priceListDeleteAcknowledge;

  /// No description provided for @priceListDeleteBlockedBanner.
  ///
  /// In en, this message translates to:
  /// **'This list is still in use by records the deletion cannot touch. Clear them first, then delete the list.'**
  String get priceListDeleteBlockedBanner;

  /// No description provided for @priceListDeletePreviewFailedNote.
  ///
  /// In en, this message translates to:
  /// **'Could not load what depends on this list. You can still delete it — if customers are assigned, the deletion will be refused.'**
  String get priceListDeletePreviewFailedNote;

  /// No description provided for @priceListDeleteClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get priceListDeleteClose;

  /// No description provided for @priceListNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get priceListNameRequiredError;

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

  /// No description provided for @facilitiesExpandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get facilitiesExpandAll;

  /// No description provided for @facilitiesCollapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get facilitiesCollapseAll;

  /// No description provided for @noWarehousesInFacility.
  ///
  /// In en, this message translates to:
  /// **'No warehouses registered.'**
  String get noWarehousesInFacility;

  /// No description provided for @noPointsOfSaleInFacility.
  ///
  /// In en, this message translates to:
  /// **'No points of sale.'**
  String get noPointsOfSaleInFacility;

  /// No description provided for @noCashDrawersInFacility.
  ///
  /// In en, this message translates to:
  /// **'No cash drawers registered.'**
  String get noCashDrawersInFacility;

  /// No description provided for @productionSiteChildrenNote.
  ///
  /// In en, this message translates to:
  /// **'Production sites only manage warehouses: they have no points of sale or cash drawers.'**
  String get productionSiteChildrenNote;

  /// No description provided for @pointSaleForeignFacilityBadge.
  ///
  /// In en, this message translates to:
  /// **'Other facility'**
  String get pointSaleForeignFacilityBadge;

  /// No description provided for @newWarehouseInFacility.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get newWarehouseInFacility;

  /// No description provided for @newPointSaleInFacility.
  ///
  /// In en, this message translates to:
  /// **'Point of sale'**
  String get newPointSaleInFacility;

  /// No description provided for @newCashDrawerInFacility.
  ///
  /// In en, this message translates to:
  /// **'Cash drawer'**
  String get newCashDrawerInFacility;

  /// No description provided for @facilityChildrenLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this facility\'s items.'**
  String get facilityChildrenLoadFailed;

  /// No description provided for @facilitiesPaginationSummary.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end} of {total} facilities'**
  String facilitiesPaginationSummary(int start, int end, int total);

  /// No description provided for @previousPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPageTooltip;

  /// No description provided for @nextPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPageTooltip;

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

  /// No description provided for @paymentMethodOptionsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Method Options'**
  String get paymentMethodOptionsMenuTitle;

  /// No description provided for @columnPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get columnPaymentMethod;

  /// No description provided for @columnNumberOfPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get columnNumberOfPayments;

  /// No description provided for @paymentMethodFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethodFieldLabel;

  /// No description provided for @numberOfPaymentsFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of payments'**
  String get numberOfPaymentsFieldLabel;

  /// No description provided for @displayOnTicketFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Show on ticket'**
  String get displayOnTicketFieldLabel;

  /// No description provided for @commissionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commissionFieldLabel;

  /// No description provided for @newPaymentMethodOptionTooltip.
  ///
  /// In en, this message translates to:
  /// **'New payment method option'**
  String get newPaymentMethodOptionTooltip;

  /// No description provided for @paymentMethodOptionsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get paymentMethodOptionsSearchLabel;

  /// No description provided for @noPaymentMethodOptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No payment method options found.'**
  String get noPaymentMethodOptionsFound;

  /// No description provided for @viewPaymentMethodOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'View Payment Method Option'**
  String get viewPaymentMethodOptionTitle;

  /// No description provided for @editPaymentMethodOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Method Option'**
  String get editPaymentMethodOptionTitle;

  /// No description provided for @newPaymentMethodOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'New Payment Method Option'**
  String get newPaymentMethodOptionTitle;

  /// No description provided for @deletePaymentMethodOptionButton.
  ///
  /// In en, this message translates to:
  /// **'Delete payment method option'**
  String get deletePaymentMethodOptionButton;

  /// No description provided for @deletePaymentMethodOptionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete payment method option?'**
  String get deletePaymentMethodOptionConfirmTitle;

  /// No description provided for @deletePaymentMethodOptionConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deletePaymentMethodOptionConfirmMessage(String name);

  /// No description provided for @paymentMethodOptionLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment method option.'**
  String get paymentMethodOptionLoadFailedError;

  /// No description provided for @paymentMethodOptionCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create payment method option.'**
  String get paymentMethodOptionCreateFailedError;

  /// No description provided for @paymentMethodOptionUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update payment method option.'**
  String get paymentMethodOptionUpdateFailedError;

  /// No description provided for @paymentMethodOptionDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete payment method option.'**
  String get paymentMethodOptionDeleteFailedError;

  /// No description provided for @paymentMethodOptionCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create payment method options.'**
  String get paymentMethodOptionCreatePermissionDeniedError;

  /// No description provided for @paymentMethodOptionUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to update payment method options.'**
  String get paymentMethodOptionUpdatePermissionDeniedError;

  /// No description provided for @paymentMethodOptionDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete payment method options.'**
  String get paymentMethodOptionDeletePermissionDeniedError;

  /// No description provided for @paymentMethodOptionFacilityRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Facility is required.'**
  String get paymentMethodOptionFacilityRequiredError;

  /// No description provided for @paymentMethodOptionNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get paymentMethodOptionNameRequiredError;

  /// No description provided for @paymentMethodOptionPaymentMethodRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Payment method is required.'**
  String get paymentMethodOptionPaymentMethodRequiredError;

  /// No description provided for @paymentMethodOptionNumberOfPaymentsInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Number of payments must be at least 1.'**
  String get paymentMethodOptionNumberOfPaymentsInvalidError;

  /// No description provided for @paymentMethodOptionCommissionInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Commission must be a non-negative number.'**
  String get paymentMethodOptionCommissionInvalidError;

  /// No description provided for @paymentMethodNa.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get paymentMethodNa;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get paymentMethodCheck;

  /// No description provided for @paymentMethodEft.
  ///
  /// In en, this message translates to:
  /// **'Electronic funds transfer'**
  String get paymentMethodEft;

  /// No description provided for @paymentMethodCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get paymentMethodCreditCard;

  /// No description provided for @paymentMethodElectronicPurse.
  ///
  /// In en, this message translates to:
  /// **'Electronic purse'**
  String get paymentMethodElectronicPurse;

  /// No description provided for @paymentMethodElectronicMoney.
  ///
  /// In en, this message translates to:
  /// **'Electronic money'**
  String get paymentMethodElectronicMoney;

  /// No description provided for @paymentMethodFoodVouchers.
  ///
  /// In en, this message translates to:
  /// **'Food vouchers'**
  String get paymentMethodFoodVouchers;

  /// No description provided for @paymentMethodGiving.
  ///
  /// In en, this message translates to:
  /// **'Payment in kind'**
  String get paymentMethodGiving;

  /// No description provided for @paymentMethodCreditorSatisfaction.
  ///
  /// In en, this message translates to:
  /// **'To the satisfaction of the creditor'**
  String get paymentMethodCreditorSatisfaction;

  /// No description provided for @paymentMethodDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit card'**
  String get paymentMethodDebitCard;

  /// No description provided for @paymentMethodServiceCard.
  ///
  /// In en, this message translates to:
  /// **'Service card'**
  String get paymentMethodServiceCard;

  /// No description provided for @paymentMethodAdvancePayments.
  ///
  /// In en, this message translates to:
  /// **'Advance payments'**
  String get paymentMethodAdvancePayments;

  /// No description provided for @paymentMethodToBeDefined.
  ///
  /// In en, this message translates to:
  /// **'To be defined'**
  String get paymentMethodToBeDefined;

  /// No description provided for @paymentMethodGovernmentFunding.
  ///
  /// In en, this message translates to:
  /// **'Government funding'**
  String get paymentMethodGovernmentFunding;

  /// No description provided for @taxpayerIssuersMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Taxpayer Issuers'**
  String get taxpayerIssuersMenuTitle;

  /// No description provided for @columnRfc.
  ///
  /// In en, this message translates to:
  /// **'RFC'**
  String get columnRfc;

  /// No description provided for @columnPostalCodeShort.
  ///
  /// In en, this message translates to:
  /// **'C.P.'**
  String get columnPostalCodeShort;

  /// No description provided for @columnRegime.
  ///
  /// In en, this message translates to:
  /// **'Fiscal Regime'**
  String get columnRegime;

  /// No description provided for @rfcFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'RFC'**
  String get rfcFieldLabel;

  /// No description provided for @providerFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Certification provider'**
  String get providerFieldLabel;

  /// No description provided for @newTaxpayerIssuerTooltip.
  ///
  /// In en, this message translates to:
  /// **'New taxpayer issuer'**
  String get newTaxpayerIssuerTooltip;

  /// No description provided for @taxpayerIssuersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by RFC or name'**
  String get taxpayerIssuersSearchLabel;

  /// No description provided for @noTaxpayerIssuersFound.
  ///
  /// In en, this message translates to:
  /// **'No taxpayer issuers found.'**
  String get noTaxpayerIssuersFound;

  /// No description provided for @viewTaxpayerIssuerTitle.
  ///
  /// In en, this message translates to:
  /// **'View Taxpayer Issuer'**
  String get viewTaxpayerIssuerTitle;

  /// No description provided for @editTaxpayerIssuerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Taxpayer Issuer'**
  String get editTaxpayerIssuerTitle;

  /// No description provided for @newTaxpayerIssuerTitle.
  ///
  /// In en, this message translates to:
  /// **'New Taxpayer Issuer'**
  String get newTaxpayerIssuerTitle;

  /// No description provided for @deleteTaxpayerIssuerButton.
  ///
  /// In en, this message translates to:
  /// **'Delete taxpayer issuer'**
  String get deleteTaxpayerIssuerButton;

  /// No description provided for @deleteTaxpayerIssuerConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete taxpayer issuer?'**
  String get deleteTaxpayerIssuerConfirmTitle;

  /// No description provided for @deleteTaxpayerIssuerConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\". This cannot be undone.'**
  String deleteTaxpayerIssuerConfirmMessage(String name);

  /// No description provided for @taxpayerIssuerLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load taxpayer issuer.'**
  String get taxpayerIssuerLoadFailedError;

  /// No description provided for @taxpayerIssuerCreateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create taxpayer issuer.'**
  String get taxpayerIssuerCreateFailedError;

  /// No description provided for @taxpayerIssuerUpdateFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update taxpayer issuer.'**
  String get taxpayerIssuerUpdateFailedError;

  /// No description provided for @taxpayerIssuerDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete taxpayer issuer.'**
  String get taxpayerIssuerDeleteFailedError;

  /// No description provided for @taxpayerIssuerCreatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to create taxpayer issuers.'**
  String get taxpayerIssuerCreatePermissionDeniedError;

  /// No description provided for @taxpayerIssuerUpdatePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to update taxpayer issuers.'**
  String get taxpayerIssuerUpdatePermissionDeniedError;

  /// No description provided for @taxpayerIssuerDeletePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to delete taxpayer issuers.'**
  String get taxpayerIssuerDeletePermissionDeniedError;

  /// No description provided for @taxpayerIssuerRfcRequiredError.
  ///
  /// In en, this message translates to:
  /// **'RFC is required.'**
  String get taxpayerIssuerRfcRequiredError;

  /// No description provided for @taxpayerIssuerNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get taxpayerIssuerNameRequiredError;

  /// No description provided for @taxpayerIssuerRegimeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Fiscal regime is required.'**
  String get taxpayerIssuerRegimeRequiredError;

  /// No description provided for @fiscalCertificationProviderNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get fiscalCertificationProviderNone;

  /// No description provided for @fiscalCertificationProviderDiverza.
  ///
  /// In en, this message translates to:
  /// **'Diverza'**
  String get fiscalCertificationProviderDiverza;

  /// No description provided for @fiscalCertificationProviderFiscoClic.
  ///
  /// In en, this message translates to:
  /// **'FiscoClic'**
  String get fiscalCertificationProviderFiscoClic;

  /// No description provided for @fiscalCertificationProviderServisim.
  ///
  /// In en, this message translates to:
  /// **'Servisim'**
  String get fiscalCertificationProviderServisim;

  /// No description provided for @fiscalCertificationProviderProFact.
  ///
  /// In en, this message translates to:
  /// **'ProFact'**
  String get fiscalCertificationProviderProFact;

  /// No description provided for @certificatesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificatesSectionTitle;

  /// No description provided for @columnCertificateNumber.
  ///
  /// In en, this message translates to:
  /// **'Certificate Number'**
  String get columnCertificateNumber;

  /// No description provided for @columnValidFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid From'**
  String get columnValidFrom;

  /// No description provided for @columnValidTo.
  ///
  /// In en, this message translates to:
  /// **'Valid To'**
  String get columnValidTo;

  /// No description provided for @addCertificateButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addCertificateButton;

  /// No description provided for @noCertificatesFound.
  ///
  /// In en, this message translates to:
  /// **'No certificates registered.'**
  String get noCertificatesFound;

  /// No description provided for @newCertificateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Certificate'**
  String get newCertificateDialogTitle;

  /// No description provided for @certificateFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Certificate file (.cer)'**
  String get certificateFileLabel;

  /// No description provided for @keyFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Key file (.key)'**
  String get keyFileLabel;

  /// No description provided for @keyPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Key password'**
  String get keyPasswordLabel;

  /// No description provided for @chooseFileButton.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFileButton;

  /// No description provided for @uploadCertificateButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get uploadCertificateButton;

  /// No description provided for @certificateFileRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Select a certificate (.cer) file.'**
  String get certificateFileRequiredError;

  /// No description provided for @keyFileRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Select a key (.key) file.'**
  String get keyFileRequiredError;

  /// No description provided for @keyPasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Key password is required.'**
  String get keyPasswordRequiredError;

  /// No description provided for @certificateUploadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to register certificate.'**
  String get certificateUploadFailedError;

  /// No description provided for @cashSessionsMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Sessions'**
  String get cashSessionsMenuTitle;

  /// No description provided for @posMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get posMenuTitle;

  /// No description provided for @salesOrdersMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Orders'**
  String get salesOrdersMenuTitle;

  /// No description provided for @salesOrdersScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Orders'**
  String get salesOrdersScreenTitle;

  /// No description provided for @salesOrderNewAction.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get salesOrderNewAction;

  /// No description provided for @salesOrdersColumnReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get salesOrdersColumnReference;

  /// No description provided for @salesOrdersColumnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get salesOrdersColumnDate;

  /// No description provided for @salesOrdersColumnCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get salesOrdersColumnCustomer;

  /// No description provided for @salesOrdersColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get salesOrdersColumnStatus;

  /// No description provided for @salesOrdersColumnTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get salesOrdersColumnTotal;

  /// No description provided for @salesOrdersColumnBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get salesOrdersColumnBalance;

  /// No description provided for @salesOrdersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get salesOrdersSearchLabel;

  /// No description provided for @salesOrderReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get salesOrderReferenceLabel;

  /// No description provided for @salesOrderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get salesOrderStatusLabel;

  /// No description provided for @salesOrderDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get salesOrderDateLabel;

  /// No description provided for @salesOrderDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get salesOrderDueDateLabel;

  /// No description provided for @salesOrderExchangeRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate'**
  String get salesOrderExchangeRateLabel;

  /// No description provided for @salesOrderPaymentTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment terms'**
  String get salesOrderPaymentTermsLabel;

  /// No description provided for @salesOrderPromiseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Promise date'**
  String get salesOrderPromiseDateLabel;

  /// No description provided for @salesOrderCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get salesOrderCurrencyLabel;

  /// No description provided for @salesOrderPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get salesOrderPriorityLabel;

  /// No description provided for @salesOrderSalespersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Salesperson'**
  String get salesOrderSalespersonLabel;

  /// No description provided for @salesOrderContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get salesOrderContactLabel;

  /// No description provided for @salesOrderShipToLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get salesOrderShipToLabel;

  /// No description provided for @salesOrderRecipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get salesOrderRecipientLabel;

  /// No description provided for @salesOrderCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get salesOrderCommentLabel;

  /// No description provided for @salesOrderMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get salesOrderMoreDetails;

  /// No description provided for @salesOrderFewerDetails.
  ///
  /// In en, this message translates to:
  /// **'Fewer details'**
  String get salesOrderFewerDetails;

  /// No description provided for @salesOrderPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get salesOrderPriorityLow;

  /// No description provided for @salesOrderPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get salesOrderPriorityNormal;

  /// No description provided for @salesOrderPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get salesOrderPriorityHigh;

  /// No description provided for @salesOrderPriorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get salesOrderPriorityCritical;

  /// No description provided for @salesOrderNoRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'No point of sale configured'**
  String get salesOrderNoRegisterTitle;

  /// No description provided for @salesOrderNoRegisterMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has no point of sale assigned, so you cannot create new orders. Ask your administrator to configure one on your user.'**
  String get salesOrderNoRegisterMessage;

  /// No description provided for @salesOrderNoFacilityTitle.
  ///
  /// In en, this message translates to:
  /// **'No facility configured'**
  String get salesOrderNoFacilityTitle;

  /// No description provided for @salesOrderNoFacilityMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has no facility assigned, so orders cannot be listed. Ask your administrator to configure one on your user.'**
  String get salesOrderNoFacilityMessage;

  /// No description provided for @salesOrderConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get salesOrderConfirmAction;

  /// No description provided for @salesOrderNoLinesYet.
  ///
  /// In en, this message translates to:
  /// **'Add at least one product before confirming the order.'**
  String get salesOrderNoLinesYet;

  /// No description provided for @salesOrderChooseCustomerFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a customer to start the order.'**
  String get salesOrderChooseCustomerFirst;

  /// No description provided for @salesOrdersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No orders yet in this period.'**
  String get salesOrdersEmptyMessage;

  /// No description provided for @salesOrderCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get salesOrderCancelAction;

  /// No description provided for @salesOrderCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get salesOrderCancelDialogTitle;

  /// No description provided for @salesOrderCancelDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. The order will be marked cancelled.'**
  String get salesOrderCancelDialogMessage;

  /// No description provided for @salesOrderCancelDialogKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get salesOrderCancelDialogKeepEditing;

  /// No description provided for @salesOrderCancelDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get salesOrderCancelDialogConfirm;

  /// No description provided for @salesOrderSalespersonEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get salesOrderSalespersonEveryone;

  /// No description provided for @salesOrderCrossFacilityNotice.
  ///
  /// In en, this message translates to:
  /// **'The order will be created in your own facility, regardless of the facility you are viewing.'**
  String get salesOrderCrossFacilityNotice;

  /// No description provided for @cashSessionStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get cashSessionStatusOpen;

  /// No description provided for @cashSessionStatusStale.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get cashSessionStatusStale;

  /// No description provided for @cashSessionStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get cashSessionStatusClosed;

  /// No description provided for @cashSessionDrawerFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash drawer'**
  String get cashSessionDrawerFieldLabel;

  /// No description provided for @cashSessionCashierFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashSessionCashierFieldLabel;

  /// No description provided for @cashSessionStartFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get cashSessionStartFieldLabel;

  /// No description provided for @cashSessionEndFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get cashSessionEndFieldLabel;

  /// No description provided for @cashSessionOpenButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Open session'**
  String get cashSessionOpenButtonLabel;

  /// No description provided for @cashSessionOpeningAmountFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening amount'**
  String get cashSessionOpeningAmountFieldLabel;

  /// No description provided for @cashSessionNoOpenSessionMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no open cash session.'**
  String get cashSessionNoOpenSessionMessage;

  /// No description provided for @cashSessionDrawerBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'A cash drawer must be assigned to your user before you can open a session. Contact your administrator.'**
  String get cashSessionDrawerBlockedMessage;

  /// No description provided for @cashSessionDrawerBusyError.
  ///
  /// In en, this message translates to:
  /// **'That cash drawer already has an open session. Choose a different drawer.'**
  String get cashSessionDrawerBusyError;

  /// No description provided for @cashSessionCashierBusyError.
  ///
  /// In en, this message translates to:
  /// **'You already have an open session. Close it before opening another.'**
  String get cashSessionCashierBusyError;

  /// No description provided for @cashSessionCloseButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Close session'**
  String get cashSessionCloseButtonLabel;

  /// Title of the open/close-shift sheet (spec 027 US5)
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get cashSessionShiftSheetTitle;

  /// Tooltip on the toolbar action opening the shift sheet while its state is loading or errored (spec 027 US5)
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get cashSessionShiftButtonTooltip;

  /// No description provided for @cashSessionPaymentsByMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payments taken this shift'**
  String get cashSessionPaymentsByMethodLabel;

  /// No description provided for @cashSessionStaleWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This session was opened on an earlier day and must be closed before you can continue selling.'**
  String get cashSessionStaleWarningMessage;

  /// No description provided for @cashSessionOpenFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open the cash session.'**
  String get cashSessionOpenFailedError;

  /// No description provided for @cashSessionOpenPermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to open a cash session.'**
  String get cashSessionOpenPermissionDeniedError;

  /// No description provided for @cashSessionCountedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Counted total'**
  String get cashSessionCountedTotalLabel;

  /// No description provided for @cashSessionExpectedCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected cash'**
  String get cashSessionExpectedCashLabel;

  /// No description provided for @cashSessionDifferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get cashSessionDifferenceLabel;

  /// No description provided for @cashSessionDifferenceOver.
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get cashSessionDifferenceOver;

  /// No description provided for @cashSessionDifferenceShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get cashSessionDifferenceShort;

  /// No description provided for @cashSessionDifferenceZero.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get cashSessionDifferenceZero;

  /// No description provided for @cashSessionAdvisoryNote.
  ///
  /// In en, this message translates to:
  /// **'Advisory only: covers the opening amount and cash payments taken this shift. Does not account for expense vouchers or other cash movements out of the drawer.'**
  String get cashSessionAdvisoryNote;

  /// No description provided for @cashSessionEmptyCountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm empty drawer'**
  String get cashSessionEmptyCountConfirmTitle;

  /// No description provided for @cashSessionEmptyCountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Every denomination is at zero. Confirm the drawer was counted and found empty before closing.'**
  String get cashSessionEmptyCountConfirmMessage;

  /// No description provided for @cashSessionConfirmEmptyCountButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm empty'**
  String get cashSessionConfirmEmptyCountButton;

  /// No description provided for @cashSessionAlreadyClosedError.
  ///
  /// In en, this message translates to:
  /// **'This session is already closed.'**
  String get cashSessionAlreadyClosedError;

  /// No description provided for @cashSessionSupervisorRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'A user with closing rights must close this session.'**
  String get cashSessionSupervisorRequiredMessage;

  /// No description provided for @cashSessionClosedByFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Closed by'**
  String get cashSessionClosedByFieldLabel;

  /// No description provided for @cashSessionQuantityInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid, non-negative whole number for each denomination.'**
  String get cashSessionQuantityInvalidError;

  /// No description provided for @cashSessionSessionNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This session no longer exists.'**
  String get cashSessionSessionNotFoundError;

  /// No description provided for @cashSessionCloseFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to close the cash session.'**
  String get cashSessionCloseFailedError;

  /// No description provided for @cashSessionClosePermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'You no longer have permission to close a cash session.'**
  String get cashSessionClosePermissionDeniedError;

  /// No description provided for @cashSessionCloseSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Session closed'**
  String get cashSessionCloseSuccessTitle;

  /// No description provided for @cashSessionCloseSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Counted {counted}, expected {expected}, difference {difference}. These figures will not be shown again.'**
  String cashSessionCloseSuccessMessage(
    String counted,
    String expected,
    String difference,
  );

  /// No description provided for @cashSessionViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash session'**
  String get cashSessionViewTitle;

  /// No description provided for @cashSessionLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the cash session.'**
  String get cashSessionLoadFailedError;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @cashSessionsListEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No cash sessions found.'**
  String get cashSessionsListEmptyMessage;

  /// No description provided for @cashSessionsFilterDrawerLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash drawer'**
  String get cashSessionsFilterDrawerLabel;

  /// No description provided for @cashSessionsFilterCashierLabel.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashSessionsFilterCashierLabel;

  /// No description provided for @cashSessionsFilterStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get cashSessionsFilterStatusLabel;

  /// No description provided for @cashSessionColumnDrawer.
  ///
  /// In en, this message translates to:
  /// **'Drawer'**
  String get cashSessionColumnDrawer;

  /// No description provided for @cashSessionColumnCashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashSessionColumnCashier;

  /// No description provided for @cashSessionColumnStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get cashSessionColumnStart;

  /// No description provided for @cashSessionColumnEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get cashSessionColumnEnd;

  /// No description provided for @cashSessionColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get cashSessionColumnStatus;

  /// No description provided for @cashSessionOtherSessionsWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'You may have other open sessions that need attention. Check the history below.'**
  String get cashSessionOtherSessionsWarningMessage;

  /// No description provided for @posGateNoSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'No cash session is open'**
  String get posGateNoSessionTitle;

  /// No description provided for @posGateNoSessionBody.
  ///
  /// In en, this message translates to:
  /// **'You must open a cash session before starting a sale.'**
  String get posGateNoSessionBody;

  /// No description provided for @posGateOpenSessionAction.
  ///
  /// In en, this message translates to:
  /// **'Go to cash sessions'**
  String get posGateOpenSessionAction;

  /// No description provided for @posStaleSessionBanner.
  ///
  /// In en, this message translates to:
  /// **'The cash session is stale.'**
  String get posStaleSessionBanner;

  /// No description provided for @posStepVenta.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get posStepVenta;

  /// No description provided for @posStepCobro.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get posStepCobro;

  /// No description provided for @posStepEntrega.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get posStepEntrega;

  /// No description provided for @posSaleCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale completed'**
  String get posSaleCompletedTitle;

  /// No description provided for @posSaleReference.
  ///
  /// In en, this message translates to:
  /// **'Reference #{reference}'**
  String posSaleReference(String reference);

  /// No description provided for @posNewSaleAction.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get posNewSaleAction;

  /// No description provided for @posCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get posCustomerLabel;

  /// No description provided for @posPaymentTermsImmediate.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get posPaymentTermsImmediate;

  /// No description provided for @posPaymentTermsCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get posPaymentTermsCredit;

  /// No description provided for @posFulfillmentCounter.
  ///
  /// In en, this message translates to:
  /// **'In store'**
  String get posFulfillmentCounter;

  /// No description provided for @posFulfillmentDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get posFulfillmentDelivery;

  /// No description provided for @posFulfillmentMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get posFulfillmentMixed;

  /// No description provided for @posProductSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search or scan a product'**
  String get posProductSearchLabel;

  /// No description provided for @posProductSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get posProductSearchNoResults;

  /// No description provided for @posRemoveLineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get posRemoveLineTooltip;

  /// No description provided for @posLineQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty.'**
  String get posLineQuantityLabel;

  /// No description provided for @posLineQuantityWithUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty. ({unit})'**
  String posLineQuantityWithUnitLabel(String unit);

  /// No description provided for @posLinePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get posLinePriceLabel;

  /// No description provided for @posLineDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Disc. %'**
  String get posLineDiscountLabel;

  /// No description provided for @posLineTaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax %'**
  String get posLineTaxLabel;

  /// No description provided for @posLineWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get posLineWarehouseLabel;

  /// No description provided for @posLineNoStock.
  ///
  /// In en, this message translates to:
  /// **'No stock in this warehouse'**
  String get posLineNoStock;

  /// No description provided for @posLineShortfall.
  ///
  /// In en, this message translates to:
  /// **'Only {available} available'**
  String posLineShortfall(String available);

  /// No description provided for @posLineAdjustToAvailable.
  ///
  /// In en, this message translates to:
  /// **'Adjust to available'**
  String get posLineAdjustToAvailable;

  /// No description provided for @posLineWarehouseStockUnknown.
  ///
  /// In en, this message translates to:
  /// **'Stock not checked'**
  String get posLineWarehouseStockUnknown;

  /// No description provided for @posLineWarehouseStockShort.
  ///
  /// In en, this message translates to:
  /// **'Only {available} left'**
  String posLineWarehouseStockShort(String available);

  /// No description provided for @posLineWarehouseStockNone.
  ///
  /// In en, this message translates to:
  /// **'No stock'**
  String get posLineWarehouseStockNone;

  /// `units` is the formatted quantity (it may be fractional, e.g. 2.5); `unitsValue` is the same figure as a number, carried only so the noun can agree with it.
  ///
  /// In en, this message translates to:
  /// **'{lines, plural, =1{{lines} line} other{{lines} lines}} · {units} {unitsValue, plural, =1{unit} other{units}}'**
  String posTotalsCounts(int lines, String units, num unitsValue);

  /// No description provided for @posTotalsArticlesLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get posTotalsArticlesLabel;

  /// No description provided for @posTotalsSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get posTotalsSubtotalLabel;

  /// No description provided for @posTotalsDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get posTotalsDiscountLabel;

  /// No description provided for @posTotalsTaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get posTotalsTaxLabel;

  /// No description provided for @posTotalsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get posTotalsTotalLabel;

  /// No description provided for @posSaleReadOnlyBanner.
  ///
  /// In en, this message translates to:
  /// **'The sale is already confirmed; its details are read-only.'**
  String get posSaleReadOnlyBanner;

  /// No description provided for @posSalesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search sales'**
  String get posSalesSearchLabel;

  /// No description provided for @posSalesStatusFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get posSalesStatusFilterLabel;

  /// No description provided for @posSalesStatusFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get posSalesStatusFilterAll;

  /// No description provided for @posSalesNewSaleAction.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get posSalesNewSaleAction;

  /// No description provided for @posSalesColumnReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get posSalesColumnReference;

  /// No description provided for @posSalesColumnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get posSalesColumnDate;

  /// No description provided for @posSalesColumnCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get posSalesColumnCustomer;

  /// No description provided for @posSalesColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get posSalesColumnStatus;

  /// No description provided for @posSalesColumnTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get posSalesColumnTotal;

  /// No description provided for @posSalesColumnBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get posSalesColumnBalance;

  /// No description provided for @posSalesEmptyToday.
  ///
  /// In en, this message translates to:
  /// **'No sales on this register today'**
  String get posSalesEmptyToday;

  /// No description provided for @posSalesNoRegister.
  ///
  /// In en, this message translates to:
  /// **'This account has no register assigned.'**
  String get posSalesNoRegister;

  /// No description provided for @posSalesNewSaleBlockedNoSession.
  ///
  /// In en, this message translates to:
  /// **'You must open a cash session before starting a sale.'**
  String get posSalesNewSaleBlockedNoSession;

  /// No description provided for @dateRangeFilterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateRangeFilterToday;

  /// No description provided for @dateRangeFilterRange.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to}'**
  String dateRangeFilterRange(String from, String to);

  /// No description provided for @dateRangeFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get dateRangeFilterClear;

  /// No description provided for @posSaleStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Capturing'**
  String get posSaleStatusDraft;

  /// No description provided for @posSaleStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment due'**
  String get posSaleStatusCompleted;

  /// No description provided for @posSaleStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get posSaleStatusPaid;

  /// No description provided for @posSaleStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get posSaleStatusCancelled;

  /// No description provided for @posSaleUnreachableTitle.
  ///
  /// In en, this message translates to:
  /// **'This sale can\'t be opened'**
  String get posSaleUnreachableTitle;

  /// No description provided for @posSaleUnreachableUnknown.
  ///
  /// In en, this message translates to:
  /// **'This sale could not be found.'**
  String get posSaleUnreachableUnknown;

  /// No description provided for @posSaleUnreachableCancelled.
  ///
  /// In en, this message translates to:
  /// **'This sale was cancelled and can no longer be opened.'**
  String get posSaleUnreachableCancelled;

  /// No description provided for @posSaleUnreachableOtherRegister.
  ///
  /// In en, this message translates to:
  /// **'This sale belongs to a different register.'**
  String get posSaleUnreachableOtherRegister;

  /// No description provided for @posSaleBackToListAction.
  ///
  /// In en, this message translates to:
  /// **'Back to sales'**
  String get posSaleBackToListAction;

  /// No description provided for @posNoLinesHint.
  ///
  /// In en, this message translates to:
  /// **'No lines — search or scan a product'**
  String get posNoLinesHint;

  /// No description provided for @posAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get posAmountLabel;

  /// No description provided for @posQuickAmountRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get posQuickAmountRemaining;

  /// No description provided for @posQuickAmountHalf.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get posQuickAmountHalf;

  /// No description provided for @posPaymentTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get posPaymentTotal;

  /// No description provided for @posPaymentPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get posPaymentPaid;

  /// No description provided for @posPaymentBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get posPaymentBalance;

  /// No description provided for @posPaymentReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get posPaymentReferenceLabel;

  /// No description provided for @posPaymentChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get posPaymentChangeLabel;

  /// No description provided for @posPaymentGateHint.
  ///
  /// In en, this message translates to:
  /// **'Opens once the balance is settled'**
  String get posPaymentGateHint;

  /// No description provided for @posPaymentMethodRequiresReference.
  ///
  /// In en, this message translates to:
  /// **'Requires a reference'**
  String get posPaymentMethodRequiresReference;

  /// No description provided for @posPaymentMethodNoReference.
  ///
  /// In en, this message translates to:
  /// **'No reference needed'**
  String get posPaymentMethodNoReference;

  /// No description provided for @posPaymentMethodSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get posPaymentMethodSectionLabel;

  /// No description provided for @posApplyPayment.
  ///
  /// In en, this message translates to:
  /// **'Apply payment'**
  String get posApplyPayment;

  /// No description provided for @posContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get posContinue;

  /// No description provided for @posAppliedPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Applied payments'**
  String get posAppliedPaymentsTitle;

  /// No description provided for @posNoAppliedPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments applied'**
  String get posNoAppliedPayments;

  /// No description provided for @posAppliedPaymentsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Applied payments could not be loaded'**
  String get posAppliedPaymentsLoadError;

  /// No description provided for @posPaymentReferenceValue.
  ///
  /// In en, this message translates to:
  /// **'Ref. {reference}'**
  String posPaymentReferenceValue(String reference);

  /// No description provided for @posPaymentPendingValidation.
  ///
  /// In en, this message translates to:
  /// **'Pending validation'**
  String get posPaymentPendingValidation;

  /// No description provided for @posPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get posPaymentCancelled;

  /// No description provided for @posReverseAction.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get posReverseAction;

  /// No description provided for @posReversePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Reverse payment'**
  String get posReversePaymentTitle;

  /// No description provided for @posReversalReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get posReversalReasonLabel;

  /// No description provided for @posCustomerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get posCustomerNameLabel;

  /// No description provided for @posCustomerCreditLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit line'**
  String get posCustomerCreditLabel;

  /// No description provided for @posCustomerPriceListLabel.
  ///
  /// In en, this message translates to:
  /// **'Price list'**
  String get posCustomerPriceListLabel;

  /// No description provided for @posCustomerSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get posCustomerSearchAction;

  /// No description provided for @posCustomerCreateAction.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get posCustomerCreateAction;

  /// No description provided for @posCustomerSearchCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel search'**
  String get posCustomerSearchCancelAction;

  /// No description provided for @posCustomerNoCreditHint.
  ///
  /// In en, this message translates to:
  /// **'No credit line'**
  String get posCustomerNoCreditHint;

  /// No description provided for @newContactDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get newContactDialogTitle;

  /// No description provided for @contactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactNameLabel;

  /// No description provided for @contactMobileLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get contactMobileLabel;

  /// No description provided for @contactPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhoneLabel;

  /// No description provided for @contactJobTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get contactJobTitleLabel;

  /// No description provided for @contactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmailLabel;

  /// No description provided for @contactMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a mobile or a phone number.'**
  String get contactMethodRequired;

  /// No description provided for @posDeliveryAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get posDeliveryAddressTitle;

  /// No description provided for @posDeliveryContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get posDeliveryContactTitle;

  /// No description provided for @posNoAddressesOnFile.
  ///
  /// In en, this message translates to:
  /// **'This customer has no addresses on file.'**
  String get posNoAddressesOnFile;

  /// No description provided for @posNoContactsOnFile.
  ///
  /// In en, this message translates to:
  /// **'This customer has no contacts on file.'**
  String get posNoContactsOnFile;

  /// No description provided for @posNewAddressAction.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get posNewAddressAction;

  /// No description provided for @posNewContactAction.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get posNewContactAction;

  /// No description provided for @posDeliveryNotPermitted.
  ///
  /// In en, this message translates to:
  /// **'This customer is not set up to receive deliveries.'**
  String get posDeliveryNotPermitted;

  /// No description provided for @posGenericCustomerResetToPickup.
  ///
  /// In en, this message translates to:
  /// **'This customer cannot receive deliveries — the sale was switched to counter pickup.'**
  String get posGenericCustomerResetToPickup;

  /// No description provided for @posCounterPickupRemainder.
  ///
  /// In en, this message translates to:
  /// **'Collected at the counter'**
  String get posCounterPickupRemainder;

  /// No description provided for @posDeliveryAddressPending.
  ///
  /// In en, this message translates to:
  /// **'Address pending'**
  String get posDeliveryAddressPending;

  /// No description provided for @posDestinationCounts.
  ///
  /// In en, this message translates to:
  /// **'{lines} lines · {units} units'**
  String posDestinationCounts(int lines, String units);

  /// No description provided for @posRemoveDestination.
  ///
  /// In en, this message translates to:
  /// **'Remove destination'**
  String get posRemoveDestination;

  /// No description provided for @posRemoveDestinationReason.
  ///
  /// In en, this message translates to:
  /// **'Removed by the cashier during capture'**
  String get posRemoveDestinationReason;

  /// No description provided for @posDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get posDistributionTitle;

  /// No description provided for @posDistributionOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered: {quantity}'**
  String posDistributionOrdered(String quantity);

  /// No description provided for @posDistributionAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned: {quantity}'**
  String posDistributionAssigned(String quantity);

  /// No description provided for @posDistributionAtCounter.
  ///
  /// In en, this message translates to:
  /// **'At counter: {quantity}'**
  String posDistributionAtCounter(String quantity);

  /// No description provided for @posDistributionClaimable.
  ///
  /// In en, this message translates to:
  /// **'Available: {quantity}'**
  String posDistributionClaimable(String quantity);

  /// No description provided for @posDistributionOverClaimed.
  ///
  /// In en, this message translates to:
  /// **'More than is left'**
  String get posDistributionOverClaimed;

  /// No description provided for @posDistributionClaimAll.
  ///
  /// In en, this message translates to:
  /// **'Take everything left'**
  String get posDistributionClaimAll;

  /// No description provided for @posDestinationBadge.
  ///
  /// In en, this message translates to:
  /// **'D{ordinal}'**
  String posDestinationBadge(int ordinal);

  /// No description provided for @posDeliveryDestinationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery destinations'**
  String get posDeliveryDestinationsTitle;

  /// No description provided for @posDistributionRailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{lines} lines · {destinations} destinations'**
  String posDistributionRailSubtitle(int lines, int destinations);

  /// No description provided for @posDeliveryAssignedUnits.
  ///
  /// In en, this message translates to:
  /// **'{assigned} / {total} units assigned'**
  String posDeliveryAssignedUnits(String assigned, String total);

  /// No description provided for @posDestinationLinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quantity to deliver from this destination'**
  String get posDestinationLinesTitle;

  /// No description provided for @posAddDestinationSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get posAddDestinationSheetTitle;

  /// No description provided for @posEditDestinationSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit destination'**
  String get posEditDestinationSheetTitle;

  /// No description provided for @posUnconfirmedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed changes'**
  String get posUnconfirmedChangesTitle;

  /// No description provided for @posUnconfirmedChangesBody.
  ///
  /// In en, this message translates to:
  /// **'There are typed values that were never confirmed. What would you like to do?'**
  String get posUnconfirmedChangesBody;

  /// No description provided for @posUnconfirmedChangesKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get posUnconfirmedChangesKeep;

  /// No description provided for @posUnconfirmedChangesDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get posUnconfirmedChangesDiscard;

  /// No description provided for @posUnconfirmedChangesKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get posUnconfirmedChangesKeepEditing;

  /// No description provided for @posCounterPickupLinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quantity staying at the store'**
  String get posCounterPickupLinesTitle;

  /// No description provided for @posDestinationCounterChip.
  ///
  /// In en, this message translates to:
  /// **'Counter {units}'**
  String posDestinationCounterChip(String units);

  /// No description provided for @posDeliveryAssignmentRefused.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t assign: {reason}'**
  String posDeliveryAssignmentRefused(String reason);

  /// No description provided for @posAddDestinationNothingLeft.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to assign'**
  String get posAddDestinationNothingLeft;

  /// No description provided for @posDeliverRestAtCounter.
  ///
  /// In en, this message translates to:
  /// **'Leave the rest at the counter'**
  String get posDeliverRestAtCounter;

  /// No description provided for @posDeliveryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get posDeliveryDateLabel;

  /// No description provided for @posDeliveryInstructions.
  ///
  /// In en, this message translates to:
  /// **'Delivery instructions'**
  String get posDeliveryInstructions;

  /// No description provided for @posAddDestination.
  ///
  /// In en, this message translates to:
  /// **'Add destination'**
  String get posAddDestination;

  /// No description provided for @posNoDestinationsYet.
  ///
  /// In en, this message translates to:
  /// **'No destinations yet — add the first one.'**
  String get posNoDestinationsYet;

  /// No description provided for @posDeliveryOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Still unassigned: {lines}'**
  String posDeliveryOutstanding(String lines);

  /// No description provided for @posFinishSale.
  ///
  /// In en, this message translates to:
  /// **'Finish sale'**
  String get posFinishSale;

  /// No description provided for @posCustomerBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get posCustomerBalanceLabel;

  /// No description provided for @posNoOpenSales.
  ///
  /// In en, this message translates to:
  /// **'No other open sales'**
  String get posNoOpenSales;

  /// No description provided for @posOpenSalesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 open} other{{count} open}}'**
  String posOpenSalesCount(int count);

  /// No description provided for @posOpenSaleDraft.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get posOpenSaleDraft;

  /// No description provided for @posOpenSaleUndelivered.
  ///
  /// In en, this message translates to:
  /// **'Awaiting delivery'**
  String get posOpenSaleUndelivered;

  /// No description provided for @posCreateCustomerAction.
  ///
  /// In en, this message translates to:
  /// **'Create customer'**
  String get posCreateCustomerAction;

  /// No description provided for @posStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String posStepProgress(int current, int total);

  /// No description provided for @posLineDecreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get posLineDecreaseQuantity;

  /// No description provided for @posLineIncreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get posLineIncreaseQuantity;

  /// No description provided for @numberPadBackspace.
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get numberPadBackspace;

  /// No description provided for @dismissErrorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissErrorTooltip;

  /// No description provided for @posOpenSaleId.
  ///
  /// In en, this message translates to:
  /// **'Id {id}'**
  String posOpenSaleId(int id);

  /// No description provided for @posOpenSaleSerial.
  ///
  /// In en, this message translates to:
  /// **'Serial {serial}'**
  String posOpenSaleSerial(int serial);

  /// No description provided for @taxpayerRecipientFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax recipient (RFC)'**
  String get taxpayerRecipientFieldLabel;

  /// No description provided for @userProfilesMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profiles'**
  String get userProfilesMenuTitle;

  /// No description provided for @newUserProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get newUserProfileTooltip;

  /// No description provided for @userProfilesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get userProfilesSearchLabel;

  /// No description provided for @noUserProfilesYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No user profiles yet — create the first one.'**
  String get noUserProfilesYetMessage;

  /// The profile catalog's own name column — distinct from columnProfile, which heads the users list's origin-profile column
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get columnProfileName;

  /// Users list column: the profile an account was provisioned from
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get columnProfile;

  /// No description provided for @columnProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get columnProfileDescription;

  /// No description provided for @newUserProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get newUserProfileTitle;

  /// No description provided for @editUserProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editUserProfileTitle;

  /// No description provided for @viewUserProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewUserProfileTitle;

  /// No description provided for @userProfileNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get userProfileNameFieldLabel;

  /// No description provided for @userProfileDescriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get userProfileDescriptionFieldLabel;

  /// No description provided for @userProfileNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get userProfileNameRequiredError;

  /// No description provided for @userProfileLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the profile.'**
  String get userProfileLoadFailedError;

  /// No description provided for @userProfileSaveFailedError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the profile.'**
  String get userProfileSaveFailedError;

  /// No description provided for @userProfileDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the profile.'**
  String get userProfileDeleteFailedError;

  /// No description provided for @deleteUserProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get deleteUserProfileTooltip;

  /// No description provided for @deleteUserProfileConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile?'**
  String get deleteUserProfileConfirmTitle;

  /// No description provided for @deleteUserProfileConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteUserProfileConfirmMessage(String name);

  /// No description provided for @userProfilePickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get userProfilePickerLabel;

  /// No description provided for @applyProfileButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply profile'**
  String get applyProfileButtonLabel;

  /// No description provided for @applyProfileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply Profile'**
  String get applyProfileDialogTitle;

  /// No description provided for @applyProfileReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'This replaces every permission this account currently holds.'**
  String get applyProfileReplaceWarning;

  /// No description provided for @applyProfileSessionWarning.
  ///
  /// In en, this message translates to:
  /// **'The account\'s active sessions will end and it must sign in again.'**
  String get applyProfileSessionWarning;

  /// No description provided for @applyProfileSelfWarning.
  ///
  /// In en, this message translates to:
  /// **'This is your own account — your own session will end too.'**
  String get applyProfileSelfWarning;

  /// No description provided for @applyProfileConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyProfileConfirmLabel;

  /// No description provided for @applyProfileSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile applied.'**
  String get applyProfileSuccessMessage;

  /// No description provided for @userFormApplyFailedError.
  ///
  /// In en, this message translates to:
  /// **'Could not apply the profile.'**
  String get userFormApplyFailedError;

  /// No description provided for @userProvisionedFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Provisioned from {profileName}'**
  String userProvisionedFromLabel(String profileName);

  /// spec 035 FR-032: shown when a record panel with an unsaved edit is dismissed (barrier tap, Escape, or the close button)
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get recordSheetDiscardTitle;

  /// No description provided for @recordSheetDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this record have not been saved.'**
  String get recordSheetDiscardBody;

  /// No description provided for @recordSheetDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get recordSheetDiscardConfirm;

  /// No description provided for @recordSheetDiscardCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get recordSheetDiscardCancel;
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
