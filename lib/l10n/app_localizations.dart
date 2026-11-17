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

  /// Generic CreditHoldError message shown when the server sent no detail
  ///
  /// In en, this message translates to:
  /// **'This customer cannot be placed on credit right now.'**
  String get errorCreditHoldGeneric;

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

  /// Navigation group for delivery orders, vehicles and vehicle operators.
  ///
  /// In en, this message translates to:
  /// **'Logistics'**
  String get logisticsGroupTitle;

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

  /// No description provided for @productsPerishableFilter.
  ///
  /// In en, this message translates to:
  /// **'Perishable'**
  String get productsPerishableFilter;

  /// No description provided for @productsSeriableFilter.
  ///
  /// In en, this message translates to:
  /// **'Seriable'**
  String get productsSeriableFilter;

  /// No description provided for @productsInvoiceableFilter.
  ///
  /// In en, this message translates to:
  /// **'Invoiceable'**
  String get productsInvoiceableFilter;

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

  /// Button on ProductSearchField that opens the Advanced search screen (spec 038 FR-001)
  ///
  /// In en, this message translates to:
  /// **'Advanced search'**
  String get advancedSearchButton;

  /// App bar title of the Advanced search screen (spec 038)
  ///
  /// In en, this message translates to:
  /// **'Advanced search'**
  String get advancedSearchTitle;

  /// Confirm button on the Advanced search screen (spec 038 FR-018), showing the number of selected products
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String advancedSearchAddButton(int count);

  /// Running count of selected products on the Advanced search screen (spec 038 FR-017)
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String advancedSearchSelectionCount(int count);

  /// Clears every selected product on the Advanced search screen without leaving it (spec 038 FR-017)
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get advancedSearchClearSelection;

  /// Shown beside the disabled confirm action when the Advanced search screen has no sale to return to (spec 038 research R8)
  ///
  /// In en, this message translates to:
  /// **'Open this from a sale to add products'**
  String get advancedSearchNoSaleHint;

  /// Heading above the list of products that could not be priced/added from an Advanced search selection (spec 038 FR-021)
  ///
  /// In en, this message translates to:
  /// **'These products could not be added:'**
  String get advancedSearchSkipped;

  /// Progress text while the Advanced search screen's selection is being priced and added (spec 038 FR-022, SC-005)
  ///
  /// In en, this message translates to:
  /// **'Adding {done} of {total}…'**
  String advancedSearchAdding(int done, int total);

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

  /// Banner shown when saving a supplier is refused with a 409 conflict.
  ///
  /// In en, this message translates to:
  /// **'Another supplier already uses that code, or one of the linked records no longer exists. Check the code and the links, then save again.'**
  String get supplierSaveConflictError;

  /// Banner shown when deleting a supplier is refused with a 409 conflict.
  ///
  /// In en, this message translates to:
  /// **'This supplier can\'t be deleted while it has addresses, contacts, bank accounts or agreements. Unlink them and remove the agreements first.'**
  String get supplierDeleteConflictError;

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

  /// No description provided for @licensePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'License photo'**
  String get licensePhotoLabel;

  /// No description provided for @licensePhotoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo unavailable'**
  String get licensePhotoUnavailable;

  /// No description provided for @licensePhotoInvalidTypeError.
  ///
  /// In en, this message translates to:
  /// **'Photo must be a JPEG or PNG file.'**
  String get licensePhotoInvalidTypeError;

  /// No description provided for @licensePhotoTooLargeError.
  ///
  /// In en, this message translates to:
  /// **'Photo must be 2 MB or smaller.'**
  String get licensePhotoTooLargeError;

  /// No description provided for @licensePhotoSaveFailedError.
  ///
  /// In en, this message translates to:
  /// **'The operator was saved, but the license photo could not be saved. Press Save to try again.'**
  String get licensePhotoSaveFailedError;

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

  /// No description provided for @facilityLogoUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload logo'**
  String get facilityLogoUploadButton;

  /// No description provided for @facilityLogoReplaceButton.
  ///
  /// In en, this message translates to:
  /// **'Replace logo'**
  String get facilityLogoReplaceButton;

  /// No description provided for @facilityLogoRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove logo'**
  String get facilityLogoRemoveButton;

  /// No description provided for @facilityLogoInvalidTypeError.
  ///
  /// In en, this message translates to:
  /// **'The logo must be a JPEG or PNG file.'**
  String get facilityLogoInvalidTypeError;

  /// No description provided for @facilityLogoTooLargeError.
  ///
  /// In en, this message translates to:
  /// **'The logo must be 2 MB or smaller.'**
  String get facilityLogoTooLargeError;

  /// No description provided for @facilityLogoUploadFailedError.
  ///
  /// In en, this message translates to:
  /// **'The facility was saved, but the logo could not be uploaded. Try again.'**
  String get facilityLogoUploadFailedError;

  /// No description provided for @facilityLogoRemoveFailedError.
  ///
  /// In en, this message translates to:
  /// **'The facility was saved, but the logo could not be removed. Try again.'**
  String get facilityLogoRemoveFailedError;

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

  /// No description provided for @salesQuotesMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Quotes'**
  String get salesQuotesMenuTitle;

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

  /// No description provided for @salesQuoteConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm quote'**
  String get salesQuoteConfirmAction;

  /// No description provided for @salesQuoteStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get salesQuoteStatusDraft;

  /// No description provided for @salesQuoteStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get salesQuoteStatusCompleted;

  /// No description provided for @salesQuoteStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get salesQuoteStatusCancelled;

  /// No description provided for @salesQuoteReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get salesQuoteReferenceLabel;

  /// No description provided for @salesQuoteStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get salesQuoteStatusLabel;

  /// No description provided for @salesQuoteDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get salesQuoteDateLabel;

  /// No description provided for @salesQuoteMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get salesQuoteMoreDetails;

  /// No description provided for @salesQuoteFewerDetails.
  ///
  /// In en, this message translates to:
  /// **'Fewer details'**
  String get salesQuoteFewerDetails;

  /// No description provided for @salesQuoteExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get salesQuoteExpiryLabel;

  /// No description provided for @salesQuoteCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get salesQuoteCurrencyLabel;

  /// No description provided for @salesQuoteCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get salesQuoteCommentLabel;

  /// No description provided for @salesQuoteConvertAction.
  ///
  /// In en, this message translates to:
  /// **'Convert to order'**
  String get salesQuoteConvertAction;

  /// No description provided for @salesQuoteDuplicateAction.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get salesQuoteDuplicateAction;

  /// No description provided for @salesQuoteNewAction.
  ///
  /// In en, this message translates to:
  /// **'New quote'**
  String get salesQuoteNewAction;

  /// No description provided for @salesQuotesColumnReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get salesQuotesColumnReference;

  /// No description provided for @salesQuotesColumnCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get salesQuotesColumnCustomer;

  /// No description provided for @salesQuotesColumnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get salesQuotesColumnDate;

  /// No description provided for @salesQuotesColumnExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get salesQuotesColumnExpiry;

  /// No description provided for @salesQuotesColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get salesQuotesColumnStatus;

  /// No description provided for @salesQuotesColumnTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get salesQuotesColumnTotal;

  /// No description provided for @salesQuotesSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search quotes'**
  String get salesQuotesSearchLabel;

  /// No description provided for @salesQuotesStatusFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get salesQuotesStatusFilterLabel;

  /// No description provided for @salesQuotesCustomerFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get salesQuotesCustomerFilterLabel;

  /// No description provided for @salesQuoteExpiredBadge.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get salesQuoteExpiredBadge;

  /// No description provided for @salesQuoteCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel quote'**
  String get salesQuoteCancelAction;

  /// No description provided for @salesQuoteCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this quote?'**
  String get salesQuoteCancelDialogTitle;

  /// No description provided for @salesQuoteCancelDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. The quote will be marked cancelled.'**
  String get salesQuoteCancelDialogMessage;

  /// No description provided for @salesQuoteCancelDialogKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get salesQuoteCancelDialogKeepEditing;

  /// No description provided for @salesQuoteCancelDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel quote'**
  String get salesQuoteCancelDialogConfirm;

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

  /// Back-office order workspace step label — the capture step
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get salesOrderStepVenta;

  /// Back-office order workspace step label — the delivery step
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get salesOrderStepEntrega;

  /// Back-office order workspace step progress announcement
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String salesOrderStepProgress(int current, int total);

  /// Venta step's forward action label (spec 039 FR-022) — replaces CaptureStep's default POS label for this host
  ///
  /// In en, this message translates to:
  /// **'Continue to delivery'**
  String get salesOrderContinueToDeliveryAction;

  /// Entrega step's close action label (spec 039 contracts/order-workspace.md §7) — replaces DeliveryStep's default POS label ("Finish sale") for this host
  ///
  /// In en, this message translates to:
  /// **'Complete order'**
  String get salesOrderCompleteDeliveryAction;

  /// Headline of the declined state shown when the back-office workspace is asked to open an order raised at the register (spec 039 FR-053, research R5)
  ///
  /// In en, this message translates to:
  /// **'This order cannot be edited here'**
  String get salesOrderForeignOrderTitle;

  /// Body of the declined foreign-order state — says where the order belongs rather than only refusing (spec 039 FR-053)
  ///
  /// In en, this message translates to:
  /// **'It was raised at the point of sale. Open it from Ventas instead.'**
  String get salesOrderForeignOrderMessage;

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
  /// **'Advisory only: the opening amount plus this shift\'s cash sales net of change given, minus expenses and cash refunds.'**
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
  /// **'Counted {counted}, expected {expected}, difference {difference}.'**
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

  /// spec 044: the document preview's print button
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get documentPrintAction;

  /// spec 044: the document preview's download button (saves the PDF)
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get documentDownloadAction;

  /// No description provided for @documentLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading document…'**
  String get documentLoadingMessage;

  /// spec 044: heading above the server's own reason when a document fetch fails
  ///
  /// In en, this message translates to:
  /// **'The document could not be loaded.'**
  String get documentLoadFailedError;

  /// No description provided for @documentCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get documentCloseTooltip;

  /// No description provided for @documentZoomOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get documentZoomOutTooltip;

  /// No description provided for @documentZoomInTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get documentZoomInTooltip;

  /// No description provided for @documentZoomFitTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fit to width'**
  String get documentZoomFitTooltip;

  /// spec 044 FR-011: the page in view out of the total; both are strings so a loading document can show a dash
  ///
  /// In en, this message translates to:
  /// **'Page {current} / {total}'**
  String documentPageIndicator(String current, String total);

  /// No description provided for @documentTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket · Reference #{reference}'**
  String documentTicketTitle(String reference);

  /// No description provided for @documentSalesOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales order · {reference}'**
  String documentSalesOrderTitle(String reference);

  /// No description provided for @documentCashCutTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash cut · {reference}'**
  String documentCashCutTitle(String reference);

  /// No description provided for @documentSalesQuoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote · {reference}'**
  String documentSalesQuoteTitle(String reference);

  /// spec 044 FR-002: the completed-sale dialog's direct-print button
  ///
  /// In en, this message translates to:
  /// **'Print ticket'**
  String get posSalePrintTicketAction;

  /// spec 044 US1-4: heading above the server's reason when printing the ticket fails
  ///
  /// In en, this message translates to:
  /// **'The ticket could not be printed.'**
  String get posSalePrintTicketError;

  /// spec 044 FR-005/FR-006: opens a closed cash session's cut (corte de caja) in the document preview
  ///
  /// In en, this message translates to:
  /// **'View cut'**
  String get cashSessionViewCutAction;

  /// spec 044 FR-003: the POS sales list row action that opens a sale's ticket in the document preview
  ///
  /// In en, this message translates to:
  /// **'View ticket'**
  String get posSaleViewTicketTooltip;

  /// spec 044 FR-004: opens the order's letter-size document (pedido) in the document preview, from the order workspace header
  ///
  /// In en, this message translates to:
  /// **'View sales order'**
  String get salesOrderViewDocumentAction;

  /// spec 053 FR-001: opens the quote's letter-size document in the document preview, from the quote header
  ///
  /// In en, this message translates to:
  /// **'View quote'**
  String get salesQuoteViewDocumentAction;

  /// spec 053 FR-006: opens the email dialog from the quote header (confirmed quotes only)
  ///
  /// In en, this message translates to:
  /// **'Send by email'**
  String get salesQuoteEmailAction;

  /// spec 053 FR-015a: tooltip of the overflow menu that holds the quote's document actions on a phone
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get salesQuoteMoreActionsTooltip;

  /// No description provided for @salesQuoteEmailDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Send quote {reference}'**
  String salesQuoteEmailDialogTitle(String reference);

  /// spec 053: heading above the recipient chips
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get salesQuoteEmailRecipientsLabel;

  /// spec 053 FR-009a: label of the field for an address that is not among the chips
  ///
  /// In en, this message translates to:
  /// **'Another email address'**
  String get salesQuoteEmailOtherAddressLabel;

  /// spec 053 FR-009a: adds the typed address as a selected chip
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get salesQuoteEmailAddAction;

  /// spec 053: sends the quote to the selected recipients
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get salesQuoteEmailSendAction;

  /// spec 053 FR-011: the send button's label while the server answers
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get salesQuoteEmailSendingLabel;

  /// spec 053 FR-010: shown while no recipient is selected
  ///
  /// In en, this message translates to:
  /// **'Up to 10 recipients.'**
  String get salesQuoteEmailLimitHint;

  /// No description provided for @salesQuoteEmailCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} of 10 recipients.'**
  String salesQuoteEmailCounter(int count);

  /// spec 053 FR-010: shown once ten recipients are selected
  ///
  /// In en, this message translates to:
  /// **'10 of 10 recipients. No more can be added.'**
  String get salesQuoteEmailLimitReached;

  /// spec 053 FR-010: field error for a typed address that fails the check
  ///
  /// In en, this message translates to:
  /// **'That is not a valid email address.'**
  String get salesQuoteEmailInvalidAddress;

  /// spec 053 edge case: shown when the customer has no contact or fiscal-recipient emails
  ///
  /// In en, this message translates to:
  /// **'This customer has no email addresses on file.'**
  String get salesQuoteEmailNoKnownAddresses;

  /// spec 053: shown while the customer's addresses load
  ///
  /// In en, this message translates to:
  /// **'Loading the customer\'s email addresses…'**
  String get salesQuoteEmailSuggestionsLoading;

  /// spec 053: shown, with a retry, when the customer's addresses fail to load
  ///
  /// In en, this message translates to:
  /// **'The customer\'s email addresses could not be loaded.'**
  String get salesQuoteEmailSuggestionsFailed;

  /// spec 053 FR-013: the server refused with 409 — the quote is no longer confirmed
  ///
  /// In en, this message translates to:
  /// **'This quote can no longer be sent.'**
  String get salesQuoteEmailNotSendable;

  /// spec 053 FR-013: the server answered 502 — the mail server refused the send
  ///
  /// In en, this message translates to:
  /// **'The mail server rejected the message. Try again, or download the quote instead.'**
  String get salesQuoteEmailMailRefused;

  /// spec 053 FR-013: the server answered 503 — mail is not configured
  ///
  /// In en, this message translates to:
  /// **'Sending email is not available. Download the quote to send it yourself.'**
  String get salesQuoteEmailMailUnavailable;

  /// No description provided for @salesQuoteEmailSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Quote sent to {recipients}'**
  String salesQuoteEmailSentMessage(String recipients);

  /// spec 046: customer form section listing the addresses linked to the customer
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get customerAddressesSection;

  /// spec 046: customer form section listing the contacts linked to the customer
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get customerContactsSection;

  /// spec 046: customer form section listing the taxpayer recipients (RFCs) linked to the customer
  ///
  /// In en, this message translates to:
  /// **'Tax recipients'**
  String get customerTaxpayersSection;

  /// No description provided for @customerAddressesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No addresses linked.'**
  String get customerAddressesEmpty;

  /// No description provided for @customerContactsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No contacts linked.'**
  String get customerContactsEmpty;

  /// No description provided for @customerTaxpayersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tax recipients linked.'**
  String get customerTaxpayersEmpty;

  /// No description provided for @customerAddressLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link an existing address'**
  String get customerAddressLinkLabel;

  /// No description provided for @customerContactLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link an existing contact'**
  String get customerContactLinkLabel;

  /// No description provided for @customerTaxpayerLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link an existing tax recipient'**
  String get customerTaxpayerLinkLabel;

  /// spec 046: removes a link from the customer without deleting the record itself
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get linkedRecordUnlinkTooltip;

  /// spec 046: creates a record from a customer form section and links it
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get linkedRecordNewAction;

  /// spec 046 FR-021: note on the POS default customer's form
  ///
  /// In en, this message translates to:
  /// **'This is the walk-in customer: its only tax recipient is {rfc} (general public), and nothing else can be linked to it.'**
  String customerGenericTaxpayerNote(String rfc);

  /// spec 047 FR-003: snackbar shown when an expired session sends the cashier to its close screen
  ///
  /// In en, this message translates to:
  /// **'Your cash session has expired. Close it to keep selling.'**
  String get posSessionExpiredRedirect;

  /// spec 047 FR-004: blocking banner on the payment step
  ///
  /// In en, this message translates to:
  /// **'The cash session has expired. Close it to take payments.'**
  String get posSessionExpiredPaymentsBlocked;

  /// spec 047: banner action that opens the expired session's close screen
  ///
  /// In en, this message translates to:
  /// **'Close session'**
  String get posSessionCloseAction;

  /// spec 047 FR-010: reason shown while Continue is blocked
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line without enough stock} other{{count} lines without enough stock}}'**
  String posCaptureShortLines(int count);

  /// spec 047 FR-012: title of the warehouse pop-up
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get posWarehousePickerTitle;

  /// Note at the top of the warehouse pop-up when the product is not checked against stock.
  ///
  /// In en, this message translates to:
  /// **'This product is not stock-tracked, so any warehouse is valid.'**
  String get posWarehousePickerNotTracked;

  /// spec 047: shown when a payment method is tapped with no amount
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get posPaymentAmountRequired;

  /// spec 047 FR-019
  ///
  /// In en, this message translates to:
  /// **'Only cash can exceed the balance.'**
  String get posPaymentOverpayNonCash;

  /// spec 047 FR-005: shown when the pre-payment session re-read finds it expired or closed
  ///
  /// In en, this message translates to:
  /// **'The cash session is no longer valid. Close it and open a new one to take payments.'**
  String get posPaymentSessionInvalid;

  /// spec 047 FR-020: label of the change card
  ///
  /// In en, this message translates to:
  /// **'Change to hand back'**
  String get posPaymentChangeDue;

  /// spec 047: dismisses the change card
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get posPaymentDismissChange;

  /// spec 047 FR-015: title of the reference dialog
  ///
  /// In en, this message translates to:
  /// **'Payment reference'**
  String get posPaymentReferenceTitle;

  /// spec 047 FR-015: confirm button of the reference dialog
  ///
  /// In en, this message translates to:
  /// **'Apply payment'**
  String get posPaymentReferenceConfirm;

  /// spec 047: shown when stock could not be loaded for some lines; offers a retry
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line with unverified stock} other{{count} lines with unverified stock}}'**
  String posCaptureUnknownStock(int count);

  /// spec 048 FR-001: confirmation field label on the admin create-user form
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// spec 048 FR-001: confirmation field label on the change, recovery and forced-change forms
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// spec 048 FR-002: shown on the confirmation field and as a form error when the two entries differ
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordMismatchError;

  /// spec 048 FR-010: AppBar title of the read-only sale detail (constitution VI: a read-only surface labels itself a View)
  ///
  /// In en, this message translates to:
  /// **'View sale'**
  String get posSaleDetailTitle;

  /// spec 048 FR-011: sale date in the read-only sale detail
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get posSaleDetailDateLabel;

  /// spec 048 FR-011: point of sale in the read-only sale detail
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get posSaleDetailRegisterLabel;

  /// spec 048 FR-013: shown instead of the payments list without customer-payments read access
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to see this sale\'s payments.'**
  String get posSaleDetailPaymentsForbidden;

  /// spec 048 FR-011: date column of an applied payment in the read-only sale detail
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get posPaymentDateLabel;

  /// spec 048 FR-020: section header in the warehouse pop-up for other facilities' warehouses
  ///
  /// In en, this message translates to:
  /// **'Other facilities'**
  String get posWarehousePickerOtherFacilities;

  /// spec 048 FR-023: shown when no other facility has the product available
  ///
  /// In en, this message translates to:
  /// **'Not available in other facilities.'**
  String get posWarehousePickerOtherNone;

  /// spec 048 FR-031: password rule checklist row
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String passwordRuleMinLength(int count);

  /// spec 048 FR-031: password rule checklist row
  ///
  /// In en, this message translates to:
  /// **'An uppercase letter'**
  String get passwordRuleUpper;

  /// spec 048 FR-031: password rule checklist row
  ///
  /// In en, this message translates to:
  /// **'A lowercase letter'**
  String get passwordRuleLower;

  /// spec 048 FR-031: password rule checklist row
  ///
  /// In en, this message translates to:
  /// **'A number'**
  String get passwordRuleDigit;

  /// spec 048 FR-031: password rule checklist row
  ///
  /// In en, this message translates to:
  /// **'A symbol'**
  String get passwordRuleSymbol;

  /// spec 048 R2: shown in place of the checklist when the policy fails to load
  ///
  /// In en, this message translates to:
  /// **'The password rules couldn\'t be loaded. The server will check your password.'**
  String get passwordRulesUnavailable;

  /// spec 048 FR-041: title of the forced-change screen
  ///
  /// In en, this message translates to:
  /// **'Change your password'**
  String get passwordRequiredTitle;

  /// spec 048 FR-040: explanation on the forced-change screen
  ///
  /// In en, this message translates to:
  /// **'An administrator set your password. Choose a new one to continue.'**
  String get passwordRequiredExplanation;

  /// spec 050: supplier form section listing the supplier's addresses
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get supplierAddressesSection;

  /// spec 050: empty state of the supplier addresses section
  ///
  /// In en, this message translates to:
  /// **'This supplier has no addresses.'**
  String get supplierAddressesEmpty;

  /// spec 050: supplier form section listing the supplier's contacts
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get supplierContactsSection;

  /// spec 050: empty state of the supplier contacts section
  ///
  /// In en, this message translates to:
  /// **'This supplier has no contacts.'**
  String get supplierContactsEmpty;

  /// spec 050: supplier form section listing the supplier's bank accounts
  ///
  /// In en, this message translates to:
  /// **'Bank accounts'**
  String get supplierBankAccountsSection;

  /// spec 050: empty state of the supplier bank accounts section
  ///
  /// In en, this message translates to:
  /// **'This supplier has no bank accounts.'**
  String get supplierBankAccountsEmpty;

  /// spec 050: supplier form section listing the supplier's dated agreements
  ///
  /// In en, this message translates to:
  /// **'Agreements'**
  String get supplierAgreementsSection;

  /// spec 050: empty state of the supplier agreements section
  ///
  /// In en, this message translates to:
  /// **'This supplier has no agreements.'**
  String get supplierAgreementsEmpty;

  /// spec 050 FR-015: shown in place of the agreements table while creating a supplier
  ///
  /// In en, this message translates to:
  /// **'You can add agreements after saving the supplier.'**
  String get supplierAgreementsAfterSaveNote;

  /// spec 050: agreements table column, the agreement's start date
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get supplierAgreementColumnStart;

  /// spec 050: agreements table column, the agreement's end date
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get supplierAgreementColumnEnd;

  /// spec 050: agreements table column, the agreement's comment
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get supplierAgreementColumnNotes;

  /// spec 050 FR-005: picker label for linking an address to a supplier
  ///
  /// In en, this message translates to:
  /// **'Link an existing address'**
  String get supplierAddressLinkLabel;

  /// spec 050 FR-005: picker label for linking a contact to a supplier
  ///
  /// In en, this message translates to:
  /// **'Link an existing contact'**
  String get supplierContactLinkLabel;

  /// spec 050 FR-005: picker label for linking a bank account to a supplier
  ///
  /// In en, this message translates to:
  /// **'Link an existing bank account'**
  String get supplierBankAccountLinkLabel;

  /// spec 050 FR-006: title of the inline bank-account create dialog
  ///
  /// In en, this message translates to:
  /// **'New bank account'**
  String get newBankAccountDialogTitle;

  /// spec 050: bank account bank name field
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankAccountBankNameLabel;

  /// spec 050: bank account number field
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get bankAccountNumberLabel;

  /// spec 050: bank account reference field
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get bankAccountReferenceLabel;

  /// spec 050: bank account routing number field
  ///
  /// In en, this message translates to:
  /// **'CLABE / routing'**
  String get bankAccountRoutingLabel;

  /// spec 050 FR-007: bank account field exceeds its maximum length
  ///
  /// In en, this message translates to:
  /// **'Must be at most {max} characters.'**
  String bankAccountFieldTooLongError(int max);

  /// spec 050 FR-007: shown when creating a bank account fails
  ///
  /// In en, this message translates to:
  /// **'Could not create the bank account.'**
  String get bankAccountCreateFailedError;

  /// spec 050 FR-013: opens the new-agreement dialog
  ///
  /// In en, this message translates to:
  /// **'Add agreement'**
  String get addAgreementButton;

  /// spec 050: title of the agreement dialog in add mode
  ///
  /// In en, this message translates to:
  /// **'New agreement'**
  String get newAgreementDialogTitle;

  /// spec 050: title of the agreement dialog in edit mode
  ///
  /// In en, this message translates to:
  /// **'Edit agreement'**
  String get editAgreementDialogTitle;

  /// spec 050 FR-014: shown under the End field when it precedes Start
  ///
  /// In en, this message translates to:
  /// **'The end date cannot be before the start date.'**
  String get supplierAgreementEndBeforeStartError;

  /// spec 050: agreement notes exceed the maximum length
  ///
  /// In en, this message translates to:
  /// **'Notes must be at most {max} characters.'**
  String agreementCommentTooLongError(int max);

  /// spec 050 FR-013: removes the agreement being edited
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAgreementButton;

  /// spec 050: title of the agreement delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete agreement?'**
  String get deleteAgreementConfirmTitle;

  /// spec 050: body of the agreement delete confirmation
  ///
  /// In en, this message translates to:
  /// **'This will delete the agreement from {start} to {end}. This cannot be undone.'**
  String deleteAgreementConfirmMessage(String start, String end);

  /// spec 050: shown when saving an agreement fails
  ///
  /// In en, this message translates to:
  /// **'Could not save the agreement.'**
  String get agreementSaveFailedError;

  /// spec 050: shown when deleting an agreement fails
  ///
  /// In en, this message translates to:
  /// **'Could not delete the agreement.'**
  String get agreementDeleteFailedError;

  /// spec 052: customer form section listing the customer's per-product discounts
  ///
  /// In en, this message translates to:
  /// **'Discounts'**
  String get customerDiscountsSection;

  /// spec 052: empty state of the customer discounts section
  ///
  /// In en, this message translates to:
  /// **'No product discounts.'**
  String get customerDiscountsEmpty;

  /// spec 052 FR-007: shown in place of the discounts table while creating a customer
  ///
  /// In en, this message translates to:
  /// **'Discounts can be added once the customer is saved.'**
  String get customerDiscountsAfterSaveNote;

  /// spec 052: customer discounts table, product code column
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get customerDiscountColumnCode;

  /// spec 052: customer discounts table, product name column
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get customerDiscountColumnProduct;

  /// spec 052: customer discounts table, discount percentage column
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get customerDiscountColumnDiscount;

  /// spec 052: title of the add-discount dialog
  ///
  /// In en, this message translates to:
  /// **'New discount'**
  String get newCustomerDiscountDialogTitle;

  /// spec 052: label of the product field in the discount dialog
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get customerDiscountProductLabel;

  /// spec 052: label of the percentage field in the discount dialog
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get customerDiscountPercentLabel;

  /// spec 052 FR-006: the discount percentage is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a percentage.'**
  String get customerDiscountPercentRequiredError;

  /// spec 052 FR-006: the discount percentage is not a number
  ///
  /// In en, this message translates to:
  /// **'Enter a number, e.g. 12.5.'**
  String get customerDiscountPercentInvalidError;

  /// spec 052 FR-006: the discount percentage is below 0 or above 100
  ///
  /// In en, this message translates to:
  /// **'Must be between 0 and 100.'**
  String get customerDiscountPercentOutOfRangeError;

  /// spec 052 FR-006: the discount percentage has more than 6 decimal places
  ///
  /// In en, this message translates to:
  /// **'At most 6 decimal places.'**
  String get customerDiscountPercentTooPreciseError;

  /// spec 052 FR-011: a discount for the product already exists (409)
  ///
  /// In en, this message translates to:
  /// **'This customer already has a discount on that product.'**
  String get customerDiscountDuplicateError;

  /// spec 052 FR-011: the chosen product was deleted before saving (422)
  ///
  /// In en, this message translates to:
  /// **'The product no longer exists.'**
  String get customerDiscountProductMissingError;

  /// spec 052: generic failure saving a customer discount
  ///
  /// In en, this message translates to:
  /// **'The discount could not be saved.'**
  String get customerDiscountSaveFailedError;

  /// spec 052: title of the edit-discount dialog
  ///
  /// In en, this message translates to:
  /// **'Edit discount'**
  String get editCustomerDiscountDialogTitle;

  /// spec 052 FR-011: the discount was removed elsewhere before saving or removing it (404)
  ///
  /// In en, this message translates to:
  /// **'This discount no longer exists.'**
  String get customerDiscountMissingError;

  /// spec 052: generic failure removing a customer discount
  ///
  /// In en, this message translates to:
  /// **'The discount could not be removed.'**
  String get customerDiscountDeleteFailedError;

  /// spec 052 FR-009: remove action inside the edit-discount dialog
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get deleteCustomerDiscountButton;

  /// spec 052 FR-009: title of the remove-discount confirmation
  ///
  /// In en, this message translates to:
  /// **'Remove discount'**
  String get deleteCustomerDiscountConfirmTitle;

  /// spec 052 FR-009: body of the remove-discount confirmation
  ///
  /// In en, this message translates to:
  /// **'Remove the discount on {code} — {name}? Lines already entered keep their discount.'**
  String deleteCustomerDiscountConfirmMessage(String code, String name);

  /// spec 052: clears the product picked in the add-discount dialog so another can be searched
  ///
  /// In en, this message translates to:
  /// **'Change product'**
  String get customerDiscountChangeProductTooltip;

  /// spec 054: Sales navigation entry and list title for customer payments
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsMenuTitle;

  /// spec 054 FR-017: payment type NA
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get paymentTypeNa;

  /// spec 054 FR-017: payment type IMMEDIATE (legacy Contado)
  ///
  /// In en, this message translates to:
  /// **'Cash sale'**
  String get paymentTypeImmediate;

  /// spec 054 FR-017: payment type CREDIT_PAYMENT
  ///
  /// In en, this message translates to:
  /// **'Credit payment'**
  String get paymentTypeCreditPayment;

  /// spec 054 FR-017: payment type PAYMENT_IN_ADVANCE
  ///
  /// In en, this message translates to:
  /// **'Payment in advance'**
  String get paymentTypePaymentInAdvance;

  /// spec 054 FR-017: payment type CREDIT_NOTE
  ///
  /// In en, this message translates to:
  /// **'Credit note'**
  String get paymentTypeCreditNote;

  /// spec 054 FR-017: payment type EXPENSE
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get paymentTypeExpense;

  /// spec 054: status chip for a payment someone has verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get paymentVerified;

  /// spec 054: status chip for a payment nobody has verified
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get paymentUnverified;

  /// spec 054 FR-014: status chip on a reversed payment application
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get paymentApplicationReversed;

  /// spec 054 FR-005: payment number column
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get paymentsColumnFolio;

  /// spec 054 FR-005: payment date column
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get paymentsColumnDate;

  /// spec 054 FR-005: customer column
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get paymentsColumnCustomer;

  /// spec 054 FR-005: payment amount column
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentsColumnAmount;

  /// spec 054 FR-005: method (and option) column
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentsColumnMethod;

  /// spec 054 FR-005: reference column
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get paymentsColumnReference;

  /// spec 054 FR-005: payment type column
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get paymentsColumnType;

  /// spec 054 FR-005: unapplied amount column
  ///
  /// In en, this message translates to:
  /// **'Unapplied'**
  String get paymentsColumnUnapplied;

  /// spec 054 FR-005: verified state column
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get paymentsColumnVerified;

  /// spec 054 FR-006: customer filter label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get paymentsFilterCustomer;

  /// spec 054 FR-006: date range filter label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get paymentsFilterDate;

  /// spec 054 FR-006: payment method filter label
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentsFilterMethod;

  /// spec 054 FR-006: no payment method selected
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get paymentsFilterMethodAll;

  /// spec 054 FR-007: verified tri-state filter label
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get paymentsFilterVerified;

  /// spec 054 FR-007: verified filter, any state
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get paymentsVerifiedAny;

  /// spec 054 FR-007: verified filter, only verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get paymentsVerifiedYes;

  /// spec 054 FR-007: verified filter, only unverified
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get paymentsVerifiedNo;

  /// spec 054 FR-006a: cash session filter label
  ///
  /// In en, this message translates to:
  /// **'Cash session'**
  String get paymentsFilterCashSession;

  /// spec 054: empty state with no filters
  ///
  /// In en, this message translates to:
  /// **'There are no payments yet.'**
  String get paymentsListEmpty;

  /// spec 054: DateRangeFilterChip label when no date range is set
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get dateRangeFilterAny;

  /// spec 054: AppBar title of the read-only payment screen
  ///
  /// In en, this message translates to:
  /// **'View payment'**
  String get paymentViewTitle;

  /// spec 054: heading of the payment screen
  ///
  /// In en, this message translates to:
  /// **'Payment {id}'**
  String paymentHeaderTitle(int id);

  /// spec 054 FR-013a: the payment amount in the header summary
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentSummaryAmount;

  /// spec 054 FR-013a: sum of the non-reversed applications
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get paymentSummaryApplied;

  /// spec 054 FR-013a: the unapplied amount
  ///
  /// In en, this message translates to:
  /// **'Unapplied'**
  String get paymentSummaryUnapplied;

  /// spec 054 FR-013: payment option field
  ///
  /// In en, this message translates to:
  /// **'Payment option'**
  String get paymentFieldPaymentOption;

  /// spec 054 FR-013: facility field
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get paymentFieldFacility;

  /// spec 054 FR-013: cash session field
  ///
  /// In en, this message translates to:
  /// **'Cash session'**
  String get paymentFieldCashSession;

  /// spec 054 FR-013: verifier field
  ///
  /// In en, this message translates to:
  /// **'Verified by'**
  String get paymentFieldVerifier;

  /// spec 060: payment verification, mbe-api#310 rejections
  ///
  /// In en, this message translates to:
  /// **'Last rejection'**
  String get paymentFieldLastRejection;

  /// spec 060: payment verification, mbe-api#310 rejections
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get paymentRejected;

  /// spec 060: payment verification, mbe-api#310 rejections
  ///
  /// In en, this message translates to:
  /// **'Rejections'**
  String get paymentVerificationFilterRejected;

  /// spec 060: payment verification, mbe-api#310 rejections
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get paymentVerificationRejectedAny;

  /// spec 060: payment verification, mbe-api#310 rejections
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get paymentVerificationRejectedYes;

  /// spec 060: payment verification, mbe-api#310 rejections
  ///
  /// In en, this message translates to:
  /// **'Never rejected'**
  String get paymentVerificationRejectedNo;

  /// spec 054 FR-014: applications section title
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get paymentApplicationsTitle;

  /// spec 054 Story 2 scenario 3: no applications
  ///
  /// In en, this message translates to:
  /// **'This payment hasn\'t been applied to any order.'**
  String get paymentApplicationsEmpty;

  /// spec 054 FR-014: order column
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get paymentApplicationsColumnOrder;

  /// spec 054 FR-014: applied amount column
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get paymentApplicationsColumnApplied;

  /// spec 054 FR-014: change returned column
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get paymentApplicationsColumnChange;

  /// spec 054 FR-014: applier column
  ///
  /// In en, this message translates to:
  /// **'Applied by'**
  String get paymentApplicationsColumnApplier;

  /// spec 054 FR-014: application date column
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get paymentApplicationsColumnDate;

  /// spec 054 FR-014: reversed marker column
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get paymentApplicationsColumnStatus;

  /// spec 054 FR-013b: not-found state
  ///
  /// In en, this message translates to:
  /// **'Payment {id} doesn\'t exist.'**
  String paymentNotFound(int id);

  /// spec 054: button on the not-found state
  ///
  /// In en, this message translates to:
  /// **'Back to Payments'**
  String get paymentBackToList;

  /// spec 054 FR-002: scope switch, the user's own facility
  ///
  /// In en, this message translates to:
  /// **'This facility'**
  String get paymentsScopeFacility;

  /// spec 054 FR-002: scope switch, across facilities (Payments Editor only)
  ///
  /// In en, this message translates to:
  /// **'All facilities'**
  String get paymentsScopeAll;

  /// spec 054 FR-010: reference search box, all-facilities scope
  ///
  /// In en, this message translates to:
  /// **'Search reference…'**
  String get paymentsSearchReferenceHint;

  /// spec 054 FR-011: facility column, all-facilities scope
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get paymentsColumnFacility;

  /// spec 055 FR-009: customer-name search box, facility scope
  ///
  /// In en, this message translates to:
  /// **'Search customer…'**
  String get paymentsSearchCustomerHint;

  /// spec 055 FR-016: the server refused the payments list (403); no retry
  ///
  /// In en, this message translates to:
  /// **'You aren\'t allowed to see these payments.'**
  String get paymentsListForbidden;

  /// spec 055 FR-002: ticket icon on a payments list row
  ///
  /// In en, this message translates to:
  /// **'View ticket'**
  String get paymentViewTicketTooltip;

  /// spec 055 FR-001: ticket button on the payment view
  ///
  /// In en, this message translates to:
  /// **'View ticket'**
  String get paymentViewTicketAction;

  /// spec 055: title of the payment ticket preview
  ///
  /// In en, this message translates to:
  /// **'Payment ticket · #{id}'**
  String documentPaymentTicketTitle(int id);

  /// spec 057: title of the refund receipt preview
  ///
  /// In en, this message translates to:
  /// **'Refund receipt · #{id}'**
  String documentRefundReceiptTitle(int id);

  /// spec 056: Sales navigation entry and list title for credit notes
  ///
  /// In en, this message translates to:
  /// **'Credit notes'**
  String get creditNotesMenuTitle;

  /// spec 056 FR-010: credit note date column
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get creditNotesColumnDate;

  /// spec 056 FR-010: credit note customer column
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get creditNotesColumnCustomer;

  /// spec 056 FR-010: the refund and order a credit note came from
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get creditNotesColumnOrigin;

  /// spec 056 FR-010: amount issued column
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get creditNotesColumnIssued;

  /// spec 056 FR-010: amount remaining column
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get creditNotesColumnRemaining;

  /// spec 056 FR-010: origin cell of a credit note row
  ///
  /// In en, this message translates to:
  /// **'Refund #{refund} · Order #{order}'**
  String creditNotesOrigin(int refund, int order);

  /// spec 056 FR-011: switch limiting the list to notes a customer can spend from their balance (mbe-api open_only: something left, not paid back in cash, not the walk-in customer's)
  ///
  /// In en, this message translates to:
  /// **'Only spendable'**
  String get creditNotesOpenOnlyFilter;

  /// spec 056 FR-011: customer filter in the credit notes drawer
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get creditNotesCustomerFilter;

  /// spec 056: empty state of the credit notes list
  ///
  /// In en, this message translates to:
  /// **'There are no credit notes.'**
  String get creditNotesEmpty;

  /// spec 056 FR-013: shown when the server answers 403 to the list
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to credit notes.'**
  String get creditNotesForbidden;

  /// spec 056 FR-001: payment step tile spending the customer's credit notes
  ///
  /// In en, this message translates to:
  /// **'Credit note'**
  String get paymentCreditNoteTile;

  /// spec 056 FR-001: second line of the credit tile
  ///
  /// In en, this message translates to:
  /// **'Balance {amount}'**
  String paymentCreditNoteBalance(String amount);

  /// spec 056 FR-005: walk-in tile opening the ticket dialog
  ///
  /// In en, this message translates to:
  /// **'Redeem credit note'**
  String get paymentCreditNoteRedeemTile;

  /// spec 056 FR-005: second line of the redeem tile
  ///
  /// In en, this message translates to:
  /// **'Scan the ticket'**
  String get paymentCreditNoteRedeemHint;

  /// spec 056: some notes were applied before one failed
  ///
  /// In en, this message translates to:
  /// **'{amount} of credit was applied; the rest could not be applied.'**
  String paymentCreditPartlyApplied(String amount);

  /// spec 056 FR-009: ticket number on an applied credit-note row
  ///
  /// In en, this message translates to:
  /// **'No. {number}'**
  String appliedPaymentCreditNoteNumber(int number);

  /// spec 056: ticket dialog title
  ///
  /// In en, this message translates to:
  /// **'Redeem credit note'**
  String get creditNoteTicketTitle;

  /// spec 056: ticket number field
  ///
  /// In en, this message translates to:
  /// **'Ticket number'**
  String get creditNoteTicketInput;

  /// spec 056: help under the ticket number field
  ///
  /// In en, this message translates to:
  /// **'Scan the ticket\'s barcode or type the number.'**
  String get creditNoteTicketHelp;

  /// spec 056: shown while the ticket lookup runs
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get creditNoteTicketSearching;

  /// spec 056: confirm button of the ticket dialog
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get creditNoteTicketConfirm;

  /// spec 056: heading of the found-note card
  ///
  /// In en, this message translates to:
  /// **'Credit note No. {number} · {date}'**
  String creditNoteTicketHeading(int number, String date);

  /// spec 056 FR-005: the found note's remaining amount
  ///
  /// In en, this message translates to:
  /// **'Available balance {amount}'**
  String creditNoteTicketAvailable(String amount);

  /// spec 056: the capped amount that confirming applies
  ///
  /// In en, this message translates to:
  /// **'Will apply {amount}'**
  String creditNoteTicketWillApply(String amount);

  /// spec 056 FR-006: unknown number, not a credit note, or another store's
  ///
  /// In en, this message translates to:
  /// **'No credit note has that number at this store.'**
  String get creditNoteNotFound;

  /// spec 056 FR-006: nothing remaining
  ///
  /// In en, this message translates to:
  /// **'This credit note has been fully used.'**
  String get creditNoteUsedUp;

  /// spec 056 FR-006: already among the sale's applications
  ///
  /// In en, this message translates to:
  /// **'This credit note is already applied to this sale.'**
  String get creditNoteAlreadyOnSale;

  /// spec 056 FR-006a: note issued to another customer
  ///
  /// In en, this message translates to:
  /// **'This credit note belongs to {name}. Make the sale out to them to use it.'**
  String creditNoteOtherCustomer(String name);

  /// spec 057: Sales navigation entry and list title for customer refunds
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get refundsMenuTitle;

  /// spec 057: Refunds list: folio column
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get refundsColumnNumber;

  /// spec 057: Refunds list: date column
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get refundsColumnDate;

  /// spec 057: Refunds list: customer column
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get refundsColumnCustomer;

  /// spec 057: Refunds list: order column
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get refundsColumnOrder;

  /// spec 057: Refunds list: status column
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get refundsColumnStatus;

  /// spec 057: Refunds list: total column
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get refundsColumnTotal;

  /// spec 057: Refunds filter sheet: status facet label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get refundsFilterStatus;

  /// spec 057: Refunds filter sheet: order number field label
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get refundsFilterOrder;

  /// spec 057 mbe-api#285: hint of the Refunds list search box (matches refund folio, order number or customer name)
  ///
  /// In en, this message translates to:
  /// **'Folio, order or customer…'**
  String get refundsSearchHint;

  /// spec 057 mbe-api#285: switch limiting the Refunds list to refunds the user created or last updated
  ///
  /// In en, this message translates to:
  /// **'Only my refunds'**
  String get refundsFilterMine;

  /// spec 057: Refunds status filter: no filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get refundsFilterAll;

  /// spec 057: Refunds status filter: drafts
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get refundsFilterOpen;

  /// spec 057: Refunds status filter: completed
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get refundsFilterConfirmed;

  /// spec 057: Refunds status filter: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get refundsFilterCancelled;

  /// spec 057: Refund status chip: draft
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get refundStatusDraft;

  /// spec 057: Refund status chip: completed
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get refundStatusCompleted;

  /// spec 057: Refund status chip: cancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get refundStatusCancelled;

  /// spec 057: Refunds list: new refund button and dialog title
  ///
  /// In en, this message translates to:
  /// **'New refund'**
  String get refundsNew;

  /// spec 057: Refunds list: new refund button label on compact screens
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get refundsNewShort;

  /// spec 057: Refunds list: empty state
  ///
  /// In en, this message translates to:
  /// **'There are no refunds.'**
  String get refundsEmpty;

  /// spec 057: Refunds list: 403 state
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view refunds.'**
  String get refundsForbidden;

  /// spec 057: Refunds list: load error
  ///
  /// In en, this message translates to:
  /// **'The refunds could not be loaded.'**
  String get refundsLoadError;

  /// spec 057: New-refund dialog: order number field label
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get refundNewOrderLabel;

  /// spec 057: New-refund dialog: submit button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get refundNewContinue;

  /// spec 057: Refusal: order not found
  ///
  /// In en, this message translates to:
  /// **'Order {n} does not exist.'**
  String refundRefusalOrderNotFound(int n);

  /// spec 057: Refusal: order is a draft or cancelled
  ///
  /// In en, this message translates to:
  /// **'Order {n} is not confirmed.'**
  String refundRefusalNotCompleted(int n);

  /// spec 057: Refusal: order is not paid
  ///
  /// In en, this message translates to:
  /// **'Order {n} is not paid. Cancel it instead of refunding it.'**
  String refundRefusalNotPaid(int n);

  /// spec 057: Refusal: nothing refundable remains; the server detail follows
  ///
  /// In en, this message translates to:
  /// **'Order {n} has nothing left to return.'**
  String refundRefusalNothingToReturn(int n);

  /// spec 057: Button on a paid order that opens or resumes a refund
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refundAction;

  /// spec 057: Refund detail: title
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get refundDetailTitle;

  /// spec 057: Refund detail: title once the refund has a folio
  ///
  /// In en, this message translates to:
  /// **'Refund {n}'**
  String refundDetailTitleWithNumber(int n);

  /// spec 057: Refund detail: folio fact label
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get refundFieldNumber;

  /// spec 057: Refund detail: date fact label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get refundFieldDate;

  /// spec 057: Refund detail: customer fact label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get refundFieldCustomer;

  /// spec 057: Refund detail: order fact label
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get refundFieldOrder;

  /// spec 057: Refund detail: status fact label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get refundFieldStatus;

  /// spec 057: Refund detail: folio of a refund that has none yet
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get refundDraftNumber;

  /// spec 057: Placeholder for a folio, date or customer a refund does not have
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get refundNoValue;

  /// spec 057: Refund lines: product column
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get refundColumnProduct;

  /// spec 057: Refund lines: price column
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get refundColumnPrice;

  /// spec 057: Refund lines: discount column
  ///
  /// In en, this message translates to:
  /// **'Disc.'**
  String get refundColumnDiscount;

  /// spec 057: Refund lines: tax column
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get refundColumnTax;

  /// spec 057: Refund lines: refundable quantity column
  ///
  /// In en, this message translates to:
  /// **'Refundable'**
  String get refundColumnRefundable;

  /// spec 057: Refund lines: refundable quantity, short label
  ///
  /// In en, this message translates to:
  /// **'Refundable'**
  String get refundColumnRefundableShort;

  /// spec 057: Refund lines: return quantity column on a draft
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get refundColumnReturn;

  /// spec 057: Refund lines: return quantity column once confirmed
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get refundColumnReturned;

  /// spec 057: Refund lines: return-to warehouse column
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get refundColumnWarehouse;

  /// spec 057: Refund lines: total column
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get refundColumnTotal;

  /// spec 057: Refund totals: subtotal
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get refundSubtotal;

  /// spec 057: Refund totals: tax
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get refundTax;

  /// spec 057: Refund totals: total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get refundTotal;

  /// spec 057: Refund detail: 404
  ///
  /// In en, this message translates to:
  /// **'Refund {id} does not exist.'**
  String refundNotFound(int id);

  /// spec 057: Refund detail: confirm button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm refund'**
  String get refundConfirmAction;

  /// spec 057: Refund detail: cancel button and prompt title
  ///
  /// In en, this message translates to:
  /// **'Cancel refund'**
  String get refundCancelAction;

  /// spec 057: Cancel prompt body
  ///
  /// In en, this message translates to:
  /// **'The refund will be cancelled and can no longer be edited.'**
  String get refundCancelPrompt;

  /// spec 057: Confirm dialog: amount owed back
  ///
  /// In en, this message translates to:
  /// **'{total} will be returned to the customer.'**
  String refundConfirmDialogTotal(String total);

  /// spec 057: Confirm dialog: cash payout choice
  ///
  /// In en, this message translates to:
  /// **'Cash from the drawer'**
  String get refundPayoutCash;

  /// spec 057: Confirm dialog: credit note payout choice
  ///
  /// In en, this message translates to:
  /// **'Credit note'**
  String get refundPayoutCreditNote;

  /// spec 057: Confirm and cancel dialogs: dismiss button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get refundConfirmBack;

  /// spec 057: Confirm dialog: submit button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get refundConfirmSubmit;

  /// spec 057: Banner when no open cash session
  ///
  /// In en, this message translates to:
  /// **'Open a cash session to confirm the refund.'**
  String get refundSessionBanner;

  /// spec 057: Session banner button: no session
  ///
  /// In en, this message translates to:
  /// **'Go to cash sessions'**
  String get refundSessionOpenAction;

  /// spec 057: Session banner button: stale session
  ///
  /// In en, this message translates to:
  /// **'Close previous session'**
  String get refundSessionStaleAction;

  /// spec 057: Completed refund: payout line label
  ///
  /// In en, this message translates to:
  /// **'Refund method'**
  String get refundPayoutLineLabel;

  /// spec 057: Completed refund: cash payout
  ///
  /// In en, this message translates to:
  /// **'Paid in cash'**
  String get refundPayoutLineCash;

  /// spec 057: Completed refund: credit note payout
  ///
  /// In en, this message translates to:
  /// **'Credit note No. {n}'**
  String refundPayoutLineCreditNote(int n);

  /// spec 057: Completed refund: payout could not be determined
  ///
  /// In en, this message translates to:
  /// **'Refund method not available'**
  String get refundPayoutLineUnknown;

  /// spec 057: Banner right after a confirm that changed quantities
  ///
  /// In en, this message translates to:
  /// **'Some quantities were adjusted because another refund was confirmed first.'**
  String get refundAdjustedBanner;

  /// spec 057: Hint shown to users who can edit but not confirm a refund
  ///
  /// In en, this message translates to:
  /// **'Someone with permission to confirm must finish this refund.'**
  String get refundNeedsConfirmerHint;

  /// Record noun for the API resource name `cash_drawer` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{cash drawer} other{cash drawers}}'**
  String apiResourceCashDrawer(int count);

  /// Grammatical gender of the noun for `cash_drawer` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderCashDrawer;

  /// Record noun for the API resource name `cash_session` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{cash session} other{cash sessions}}'**
  String apiResourceCashSession(int count);

  /// Grammatical gender of the noun for `cash_session` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderCashSession;

  /// Record noun for the API resource name `credit_note` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{credit note} other{credit notes}}'**
  String apiResourceCreditNote(int count);

  /// Grammatical gender of the noun for `credit_note` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderCreditNote;

  /// Record noun for the API resource name `customer` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{customer} other{customers}}'**
  String apiResourceCustomer(int count);

  /// Grammatical gender of the noun for `customer` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderCustomer;

  /// Record noun for the API resource name `customer_discount` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{customer discount} other{customer discounts}}'**
  String apiResourceCustomerDiscount(int count);

  /// Grammatical gender of the noun for `customer_discount` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderCustomerDiscount;

  /// Record noun for the API resource name `customer_payment` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{payment} other{payments}}'**
  String apiResourceCustomerPayment(int count);

  /// Grammatical gender of the noun for `customer_payment` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderCustomerPayment;

  /// Record noun for the API resource name `customer_refund` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{refund} other{refunds}}'**
  String apiResourceCustomerRefund(int count);

  /// Grammatical gender of the noun for `customer_refund` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderCustomerRefund;

  /// Record noun for the API resource name `delivery_itinerary` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{delivery route} other{delivery routes}}'**
  String apiResourceDeliveryItinerary(int count);

  /// Grammatical gender of the noun for `delivery_itinerary` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderDeliveryItinerary;

  /// Record noun for the API resource name `delivery_order` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{delivery order} other{delivery orders}}'**
  String apiResourceDeliveryOrder(int count);

  /// Grammatical gender of the noun for `delivery_order` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderDeliveryOrder;

  /// Record noun for the API resource name `delivery_order_line` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{delivery line} other{delivery lines}}'**
  String apiResourceDeliveryOrderLine(int count);

  /// Grammatical gender of the noun for `delivery_order_line` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderDeliveryOrderLine;

  /// Record noun for the API resource name `employee` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{employee} other{employees}}'**
  String apiResourceEmployee(int count);

  /// Grammatical gender of the noun for `employee` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderEmployee;

  /// Record noun for the API resource name `exchange_rate` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{exchange rate} other{exchange rates}}'**
  String apiResourceExchangeRate(int count);

  /// Grammatical gender of the noun for `exchange_rate` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderExchangeRate;

  /// Record noun for the API resource name `expense` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{expense} other{expenses}}'**
  String apiResourceExpense(int count);

  /// Grammatical gender of the noun for `expense` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderExpense;

  /// Record noun for the API resource name `expense_voucher` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{expense voucher} other{expense vouchers}}'**
  String apiResourceExpenseVoucher(int count);

  /// Grammatical gender of the noun for `expense_voucher` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderExpenseVoucher;

  /// Record noun for the API resource name `facility` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{facility} other{facilities}}'**
  String apiResourceFacility(int count);

  /// Grammatical gender of the noun for `facility` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderFacility;

  /// Record noun for the API resource name `fiscal_document` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{invoice} other{invoices}}'**
  String apiResourceFiscalDocument(int count);

  /// Grammatical gender of the noun for `fiscal_document` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderFiscalDocument;

  /// Record noun for the API resource name `inventory_issue` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{warehouse issue} other{warehouse issues}}'**
  String apiResourceInventoryIssue(int count);

  /// Grammatical gender of the noun for `inventory_issue` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderInventoryIssue;

  /// Record noun for the API resource name `inventory_receipt` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{warehouse receipt} other{warehouse receipts}}'**
  String apiResourceInventoryReceipt(int count);

  /// Grammatical gender of the noun for `inventory_receipt` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderInventoryReceipt;

  /// Record noun for the API resource name `inventory_transfer` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{transfer} other{transfers}}'**
  String apiResourceInventoryTransfer(int count);

  /// Grammatical gender of the noun for `inventory_transfer` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderInventoryTransfer;

  /// Record noun for the API resource name `label` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{label} other{labels}}'**
  String apiResourceLabel(int count);

  /// Grammatical gender of the noun for `label` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderLabel;

  /// Record noun for the API resource name `payment_method_option` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{payment method} other{payment methods}}'**
  String apiResourcePaymentMethodOption(int count);

  /// Grammatical gender of the noun for `payment_method_option` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderPaymentMethodOption;

  /// Record noun for the API resource name `point_of_sale` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{point of sale} other{points of sale}}'**
  String apiResourcePointOfSale(int count);

  /// Grammatical gender of the noun for `point_of_sale` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderPointOfSale;

  /// Record noun for the API resource name `price_list` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{price list} other{price lists}}'**
  String apiResourcePriceList(int count);

  /// Grammatical gender of the noun for `price_list` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderPriceList;

  /// Record noun for the API resource name `product` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{product} other{products}}'**
  String apiResourceProduct(int count);

  /// Grammatical gender of the noun for `product` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderProduct;

  /// Record noun for the API resource name `product_price` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{price} other{prices}}'**
  String apiResourceProductPrice(int count);

  /// Grammatical gender of the noun for `product_price` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderProductPrice;

  /// Record noun for the API resource name `purchase_order` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{purchase order} other{purchase orders}}'**
  String apiResourcePurchaseOrder(int count);

  /// Grammatical gender of the noun for `purchase_order` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderPurchaseOrder;

  /// Record noun for the API resource name `sales_order` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{order} other{orders}}'**
  String apiResourceSalesOrder(int count);

  /// Grammatical gender of the noun for `sales_order` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderSalesOrder;

  /// Record noun for the API resource name `sales_order_line` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{order line} other{order lines}}'**
  String apiResourceSalesOrderLine(int count);

  /// Grammatical gender of the noun for `sales_order_line` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderSalesOrderLine;

  /// Record noun for the API resource name `sales_order_payment` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{order payment} other{order payments}}'**
  String apiResourceSalesOrderPayment(int count);

  /// Grammatical gender of the noun for `sales_order_payment` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderSalesOrderPayment;

  /// Record noun for the API resource name `sales_quote` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{quote} other{quotes}}'**
  String apiResourceSalesQuote(int count);

  /// Grammatical gender of the noun for `sales_quote` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderSalesQuote;

  /// Record noun for the API resource name `sales_quote_line` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{quote line} other{quote lines}}'**
  String apiResourceSalesQuoteLine(int count);

  /// Grammatical gender of the noun for `sales_quote_line` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderSalesQuoteLine;

  /// Record noun for the API resource name `stock_movement` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{stock movement} other{stock movements}}'**
  String apiResourceStockMovement(int count);

  /// Grammatical gender of the noun for `stock_movement` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderStockMovement;

  /// Record noun for the API resource name `supplier` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{supplier} other{suppliers}}'**
  String apiResourceSupplier(int count);

  /// Grammatical gender of the noun for `supplier` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderSupplier;

  /// Record noun for the API resource name `supplier_payment` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{supplier payment} other{supplier payments}}'**
  String apiResourceSupplierPayment(int count);

  /// Grammatical gender of the noun for `supplier_payment` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderSupplierPayment;

  /// Record noun for the API resource name `taxpayer_certificate` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{certificate} other{certificates}}'**
  String apiResourceTaxpayerCertificate(int count);

  /// Grammatical gender of the noun for `taxpayer_certificate` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderTaxpayerCertificate;

  /// Record noun for the API resource name `taxpayer_issuer` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{issuer} other{issuers}}'**
  String apiResourceTaxpayerIssuer(int count);

  /// Grammatical gender of the noun for `taxpayer_issuer` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderTaxpayerIssuer;

  /// Record noun for the API resource name `taxpayer_recipient` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{recipient} other{recipients}}'**
  String apiResourceTaxpayerRecipient(int count);

  /// Grammatical gender of the noun for `taxpayer_recipient` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderTaxpayerRecipient;

  /// Record noun for the API resource name `user` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{user} other{users}}'**
  String apiResourceUser(int count);

  /// Grammatical gender of the noun for `user` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderUser;

  /// Record noun for the API resource name `user_profile` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{profile} other{profiles}}'**
  String apiResourceUserProfile(int count);

  /// Grammatical gender of the noun for `user_profile` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderUserProfile;

  /// Record noun for the API resource name `vehicle` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{vehicle} other{vehicles}}'**
  String apiResourceVehicle(int count);

  /// Grammatical gender of the noun for `vehicle` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderVehicle;

  /// Record noun for the API resource name `vehicle_operator` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{vehicle operator} other{vehicle operators}}'**
  String apiResourceVehicleOperator(int count);

  /// Grammatical gender of the noun for `vehicle_operator` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderVehicleOperator;

  /// Record noun for the API resource name `warehouse` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{warehouse} other{warehouses}}'**
  String apiResourceWarehouse(int count);

  /// Grammatical gender of the noun for `warehouse` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderWarehouse;

  /// Generic record noun for an API resource name the app has no noun for (spec 058)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{record} other{records}}'**
  String apiResourceGeneric(int count);

  /// Grammatical gender of the generic record noun in Spanish (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderGeneric;

  /// mbe-api error code `auth.administrator_required` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Only administrators can do this.'**
  String get apiErrorAuthAdministratorRequired;

  /// mbe-api error code `auth.forbidden` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission for this action.'**
  String get apiErrorAuthForbidden;

  /// mbe-api error code `auth.incorrect_current_password` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect.'**
  String get apiErrorAuthIncorrectCurrentPassword;

  /// mbe-api error code `auth.invalid_credentials` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get apiErrorAuthInvalidCredentials;

  /// mbe-api error code `auth.not_authenticated` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get apiErrorAuthNotAuthenticated;

  /// mbe-api error code `auth.password_change_required` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'You must change your password before continuing.'**
  String get apiErrorAuthPasswordChangeRequired;

  /// mbe-api error code `auth.recovery_token_invalid` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This recovery link is invalid or has expired. Request a new one.'**
  String get apiErrorAuthRecoveryTokenInvalid;

  /// mbe-api error code `request.malformed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The app sent a request the server couldn\'t read. Try again.'**
  String get apiErrorRequestMalformed;

  /// mbe-api error code `request.method_not_allowed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The server doesn\'t allow this operation here.'**
  String get apiErrorRequestMethodNotAllowed;

  /// mbe-api error code `request.route_not_found` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The server doesn\'t offer this function. The app may need an update.'**
  String get apiErrorRequestRouteNotFound;

  /// mbe-api error code `resource.conflict` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The change conflicts with existing data. Reload and try again.'**
  String get apiErrorResourceConflict;

  /// mbe-api error code `server.error` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server. Try again later.'**
  String get apiErrorServerError;

  /// mbe-api error code `state.transition_invalid` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This record can\'t change from its current status to the one requested.'**
  String get apiErrorStateTransitionInvalid;

  /// mbe-api error code `resource.not_found` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'{gender, select, feminine{Couldn\'t find the {resource}. It may have been deleted.} other{Couldn\'t find the {resource}. It may have been deleted.}}'**
  String apiErrorResourceNotFound(String gender, String resource);

  /// mbe-api error code `resource.already_exists` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'{gender, select, feminine{That value is already in use. Another {resource} has it.} other{That value is already in use. Another {resource} has it.}}'**
  String apiErrorResourceAlreadyExists(String gender, String resource);

  /// mbe-api error code `resource.still_referenced` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This record can\'t be deleted because it\'s still in use: {list}.'**
  String apiErrorResourceStillReferenced(String list);

  /// mbe-api error code `resource.still_referenced` (spec 058), when the blockers are not readable
  ///
  /// In en, this message translates to:
  /// **'This record is still in use and can\'t be deleted.'**
  String get apiErrorResourceStillReferencedGeneric;

  /// Tail of a list of records that still reference one being deleted: how many more there are (spec 058)
  ///
  /// In en, this message translates to:
  /// **'{more, plural, one{and 1 other} other{and {more} others}}'**
  String apiReferenceMore(int more);

  /// mbe-api error code `cash_session.already_closed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This cash session is already closed.'**
  String get apiErrorCashSessionAlreadyClosed;

  /// mbe-api error code `cash_session.closed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The cash session was closed while you were working. Reload to continue.'**
  String get apiErrorCashSessionClosed;

  /// mbe-api error code `cash_session.drawer_busy` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'That cash drawer already has an open session.'**
  String get apiErrorCashSessionDrawerBusy;

  /// mbe-api error code `cash_session.not_closed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The cash session is still open. Close it first.'**
  String get apiErrorCashSessionNotClosed;

  /// mbe-api error code `cash_session.not_open` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'You need an open cash session for this.'**
  String get apiErrorCashSessionNotOpen;

  /// mbe-api error code `cash_session.user_busy` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'You already have an open session. Close it before opening another.'**
  String get apiErrorCashSessionUserBusy;

  /// mbe-api error code `csd.certificate_not_rsa` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The certificate doesn\'t use an RSA key. It isn\'t a valid CSD.'**
  String get apiErrorCsdCertificateNotRsa;

  /// mbe-api error code `csd.certificate_unreadable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The certificate file (.cer) couldn\'t be read.'**
  String get apiErrorCsdCertificateUnreadable;

  /// mbe-api error code `csd.key_mismatch` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The key (.key) doesn\'t match the certificate (.cer).'**
  String get apiErrorCsdKeyMismatch;

  /// mbe-api error code `csd.key_not_encrypted` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The key has no password, so it isn\'t a SAT CSD key.'**
  String get apiErrorCsdKeyNotEncrypted;

  /// mbe-api error code `csd.key_not_rsa` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The key file doesn\'t hold an RSA key.'**
  String get apiErrorCsdKeyNotRsa;

  /// mbe-api error code `csd.key_unreadable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The key couldn\'t be opened. Check the password and the .key file.'**
  String get apiErrorCsdKeyUnreadable;

  /// mbe-api error code `customer.credit_hold` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This customer has {count, plural, one{1 overdue credit order. Settle it} other{{count} overdue credit orders. Settle them}} before creating a new credit order.'**
  String apiErrorCustomerCreditHold(int count);

  /// mbe-api error code `customer.credit_limit_exceeded` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This order would bring the customer\'s balance to {outstanding}, over their credit limit of {limit}.'**
  String apiErrorCustomerCreditLimitExceeded(String outstanding, String limit);

  /// mbe-api error code `customer.credit_limit_reached` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The customer owes {outstanding}, which reaches their credit limit of {limit}. They must pay before buying again.'**
  String apiErrorCustomerCreditLimitReached(String outstanding, String limit);

  /// mbe-api error code `customer.default_not_deletable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The general public customer can\'t be deleted.'**
  String get apiErrorCustomerDefaultNotDeletable;

  /// mbe-api error code `customer.no_credit_limit` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This customer has no credit limit, so they can\'t buy on credit.'**
  String get apiErrorCustomerNoCreditLimit;

  /// mbe-api error code `customer.walk_in_no_credit` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The general public customer can\'t buy on credit.'**
  String get apiErrorCustomerWalkInNoCredit;

  /// mbe-api error code `customer_discount.product_not_found` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The product for this discount no longer exists.'**
  String get apiErrorCustomerDiscountProductNotFound;

  /// mbe-api error code `delivery_order.line_already_present` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'That line is already on this delivery order.'**
  String get apiErrorDeliveryOrderLineAlreadyPresent;

  /// mbe-api error code `delivery_order.line_not_deliverable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'That line can\'t be delivered on this order: it belongs to another sale or was already delivered.'**
  String get apiErrorDeliveryOrderLineNotDeliverable;

  /// mbe-api error code `delivery_order.line_repeated` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The same line was added twice.'**
  String get apiErrorDeliveryOrderLineRepeated;

  /// mbe-api error code `delivery_order.mixed_not_allowed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'A delivery order can\'t mix delivery and pickup.'**
  String get apiErrorDeliveryOrderMixedNotAllowed;

  /// mbe-api error code `delivery_order.not_editable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This delivery order is no longer a draft and can\'t be changed.'**
  String get apiErrorDeliveryOrderNotEditable;

  /// mbe-api error code `delivery_order.quantity_exceeds_remaining` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'You asked for {requested}, but only {remaining} are left to deliver on that line.'**
  String apiErrorDeliveryOrderQuantityExceedsRemaining(
    String requested,
    String remaining,
  );

  /// mbe-api error code `delivery_order.reason_required` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Enter a reason for this change.'**
  String get apiErrorDeliveryOrderReasonRequired;

  /// mbe-api error code `delivery_order.sales_order_fully_delivered` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This sale has nothing left to deliver.'**
  String get apiErrorDeliveryOrderSalesOrderFullyDelivered;

  /// mbe-api error code `delivery_order.sales_order_not_deliverable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This sale can\'t be delivered: it isn\'t completed, or it was cancelled.'**
  String get apiErrorDeliveryOrderSalesOrderNotDeliverable;

  /// mbe-api error code `delivery_order.sales_order_unpaid` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The sale must be paid, or sold on credit, before it can be delivered.'**
  String get apiErrorDeliveryOrderSalesOrderUnpaid;

  /// mbe-api error code `document.not_editable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This document is completed or cancelled and can\'t be edited.'**
  String get apiErrorDocumentNotEditable;

  /// mbe-api error code `email.not_configured` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Email isn\'t set up on the server.'**
  String get apiErrorEmailNotConfigured;

  /// mbe-api error code `email.send_failed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The email couldn\'t be sent. Try again later.'**
  String get apiErrorEmailSendFailed;

  /// mbe-api error code `facility.no_dispatch_warehouse` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This facility has no warehouse to dispatch from.'**
  String get apiErrorFacilityNoDispatchWarehouse;

  /// mbe-api error code `facility.other_facility` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'{gender, select, feminine{This {resource} belongs to another facility, and you don\'t have access to other facilities.} other{This {resource} belongs to another facility, and you don\'t have access to other facilities.}}'**
  String apiErrorFacilityOtherFacility(String gender, String resource);

  /// mbe-api error code `facility.required` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Choose a facility. Your user has none assigned.'**
  String get apiErrorFacilityRequired;

  /// mbe-api error code `image.too_large` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The image is too large. The maximum is {max}.'**
  String apiErrorImageTooLarge(String max);

  /// mbe-api error code `image.unsupported_format` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The file isn\'t an image the server can read. Try another file.'**
  String get apiErrorImageUnsupportedFormat;

  /// mbe-api error code `incidence.reason_required` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Enter a reason.'**
  String get apiErrorIncidenceReasonRequired;

  /// mbe-api error code `lock.busy` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Someone else is updating this right now. Try again in a moment.'**
  String get apiErrorLockBusy;

  /// mbe-api error code `payment.no_ticket` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This kind of payment has no ticket to print.'**
  String get apiErrorPaymentNoTicket;

  /// mbe-api error code `payment.exceeds_order_balance` (spec 059)
  ///
  /// In en, this message translates to:
  /// **'The amount {amount} is more than the order\'s balance of {balance}.'**
  String apiErrorPaymentExceedsOrderBalance(String amount, String balance);

  /// mbe-api error code `payment.exceeds_unapplied` (spec 059)
  ///
  /// In en, this message translates to:
  /// **'The amount {amount} is more than the {unapplied} left on the payment.'**
  String apiErrorPaymentExceedsUnapplied(String amount, String unapplied);

  /// mbe-api error code `payment.order_settled` (spec 059)
  ///
  /// In en, this message translates to:
  /// **'The order is already paid.'**
  String get apiErrorPaymentOrderSettled;

  /// mbe-api error code `payment.order_cancelled` (spec 059)
  ///
  /// In en, this message translates to:
  /// **'The order is cancelled and can\'t take a payment.'**
  String get apiErrorPaymentOrderCancelled;

  /// mbe-api error code `payment.order_not_completed` (spec 059)
  ///
  /// In en, this message translates to:
  /// **'The order isn\'t confirmed. Confirm it before applying a payment.'**
  String get apiErrorPaymentOrderNotCompleted;

  /// mbe-api error code `payment.currency_mismatch` (spec 059)
  ///
  /// In en, this message translates to:
  /// **'The payment is in {paymentCurrency} and the order in {orderCurrency}.'**
  String apiErrorPaymentCurrencyMismatch(
    String paymentCurrency,
    String orderCurrency,
  );

  /// mbe-api error code `payment.customer_mismatch` (spec 059)
  ///
  /// In en, this message translates to:
  /// **'The payment belongs to another customer.'**
  String get apiErrorPaymentCustomerMismatch;

  /// mbe-api error code `payment.application_reversed` (spec 059)
  ///
  /// In en, this message translates to:
  /// **'This application was already reversed.'**
  String get apiErrorPaymentApplicationReversed;

  /// mbe-api error code `payment.already_applied` (mbe-api#309)
  ///
  /// In en, this message translates to:
  /// **'This payment is already applied to this order. Reverse that application before applying it again.'**
  String get apiErrorPaymentAlreadyApplied;

  /// mbe-api error code `point_of_sale.warehouse_facility_mismatch` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The warehouse must belong to the same facility as the point of sale.'**
  String get apiErrorPointOfSaleWarehouseFacilityMismatch;

  /// mbe-api error code `price_list.cost_not_assignable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The cost list can\'t be assigned to a customer or used as a replacement.'**
  String get apiErrorPriceListCostNotAssignable;

  /// mbe-api error code `price_list.cost_not_deletable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The cost list can\'t be deleted.'**
  String get apiErrorPriceListCostNotDeletable;

  /// mbe-api error code `price_list.cost_read_only` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Prices on the cost list can\'t be edited here.'**
  String get apiErrorPriceListCostReadOnly;

  /// mbe-api error code `price_list.replace_with_itself` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'A price list can\'t be replaced with itself.'**
  String get apiErrorPriceListReplaceWithItself;

  /// mbe-api error code `product.lookup_criteria_required` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Type something to search for.'**
  String get apiErrorProductLookupCriteriaRequired;

  /// mbe-api error code `product.lookup_too_many` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Too many products at once. The maximum is {max}.'**
  String apiErrorProductLookupTooMany(String max);

  /// mbe-api error code `product.merge_with_itself` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'A product can\'t be merged into itself.'**
  String get apiErrorProductMergeWithItself;

  /// mbe-api error code `product_price.duplicate_entry` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The same price was entered twice.'**
  String get apiErrorProductPriceDuplicateEntry;

  /// mbe-api error code `product_price.references_not_found` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'{gender, select, feminine{Some of the {resource} in this change no longer exist. Reload and try again.} other{Some of the {resource} in this change no longer exist. Reload and try again.}}'**
  String apiErrorProductPriceReferencesNotFound(String gender, String resource);

  /// mbe-api error code `quote.already_cancelled` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This quote is already cancelled.'**
  String get apiErrorQuoteAlreadyCancelled;

  /// mbe-api error code `quote.cancelled` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This quote was cancelled and can\'t be converted.'**
  String get apiErrorQuoteCancelled;

  /// mbe-api error code `quote.expired` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This quote has expired.'**
  String get apiErrorQuoteExpired;

  /// mbe-api error code `quote.not_confirmed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Confirm the quote first.'**
  String get apiErrorQuoteNotConfirmed;

  /// mbe-api error code `refund.already_cancelled` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This refund is already cancelled.'**
  String get apiErrorRefundAlreadyCancelled;

  /// mbe-api error code `refund.completed_cannot_cancel` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'A completed refund is final and can\'t be cancelled.'**
  String get apiErrorRefundCompletedCannotCancel;

  /// mbe-api error code `refund.line_invoiced` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'{product} is on invoice {invoice}. Cancel or adjust that invoice before refunding it.'**
  String apiErrorRefundLineInvoiced(String product, String invoice);

  /// mbe-api error code `refund.line_invoiced` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'{product} is on a live invoice. Cancel or adjust that invoice before refunding it.'**
  String apiErrorRefundLineInvoicedNoFolio(String product);

  /// mbe-api error code `refund.no_returnable_lines` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity to return on at least one line.'**
  String get apiErrorRefundNoReturnableLines;

  /// mbe-api error code `refund.not_confirmed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Only a confirmed refund has a receipt to print.'**
  String get apiErrorRefundNotConfirmed;

  /// mbe-api error code `refund.nothing_refundable` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Nothing on this order is left to refund.'**
  String get apiErrorRefundNothingRefundable;

  /// mbe-api error code `refund.order_not_completed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This order isn\'t completed, so it can\'t be refunded.'**
  String get apiErrorRefundOrderNotCompleted;

  /// mbe-api error code `refund.order_not_paid` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This order isn\'t paid. Cancel it instead of refunding it.'**
  String get apiErrorRefundOrderNotPaid;

  /// mbe-api error code `sales_order.already_cancelled` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This order is already cancelled.'**
  String get apiErrorSalesOrderAlreadyCancelled;

  /// mbe-api error code `sales_order.below_min_quantity` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'A product is below its minimum order of {min}.'**
  String apiErrorSalesOrderBelowMinQuantity(String min);

  /// mbe-api error code `sales_order.has_payment_applications` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This order has payments applied. Reverse them first.'**
  String get apiErrorSalesOrderHasPaymentApplications;

  /// mbe-api error code `sales_order.insufficient_stock` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Some lines don\'t have enough stock'**
  String get apiErrorSalesOrderInsufficientStock;

  /// mbe-api error code `sales_order.missing_delivery_details` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Delivery details are missing'**
  String get apiErrorSalesOrderMissingDeliveryDetails;

  /// mbe-api error code `sales_order.no_lines` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Add at least one line before confirming.'**
  String get apiErrorSalesOrderNoLines;

  /// mbe-api error code `sales_order.paid_cannot_cancel` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'A paid order can\'t be cancelled. Refund it instead.'**
  String get apiErrorSalesOrderPaidCannotCancel;

  /// mbe-api error code `sales_order.zero_priced_lines` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Some lines have no price'**
  String get apiErrorSalesOrderZeroPricedLines;

  /// mbe-api error code `supplier_agreement.end_before_start` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The end date ({end}) is before the start date ({start}).'**
  String apiErrorSupplierAgreementEndBeforeStart(String end, String start);

  /// mbe-api error code `taxpayer_certificate.holder_mismatch` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The certificate belongs to {certificateTaxpayer}, not to {taxpayer}.'**
  String apiErrorTaxpayerCertificateHolderMismatch(
    String certificateTaxpayer,
    String taxpayer,
  );

  /// mbe-api error code `taxpayer_issuer.unknown` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The issuer {taxpayer} isn\'t registered.'**
  String apiErrorTaxpayerIssuerUnknown(String taxpayer);

  /// mbe-api error code `user.no_cash_drawer` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Your user has no cash drawer assigned.'**
  String get apiErrorUserNoCashDrawer;

  /// mbe-api error code `user.no_facility` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Your user has no facility assigned.'**
  String get apiErrorUserNoFacility;

  /// mbe-api error code `user.no_point_of_sale` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Your user has no point of sale assigned.'**
  String get apiErrorUserNoPointOfSale;

  /// mbe-api error code `user_profile.not_active` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'This profile is inactive and can\'t be applied.'**
  String get apiErrorUserProfileNotActive;

  /// mbe-api error code `warehouse.in_transit_location` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'An in-transit warehouse can\'t be used here.'**
  String get apiErrorWarehouseInTransitLocation;

  /// mbe-api error code `warehouse.in_transit_managed` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'In-transit warehouses are managed by the system and can\'t be edited.'**
  String get apiErrorWarehouseInTransitManaged;

  /// mbe-api error code `warehouse.required` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'Choose a warehouse. Your point of sale has none.'**
  String get apiErrorWarehouseRequired;

  /// mbe-api request-validation type `contact_name_blank` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The name can\'t be blank.'**
  String get apiValidationContactNameBlank;

  /// mbe-api request-validation type `email_address_invalid` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'That isn\'t a valid email address.'**
  String get apiValidationEmailAddressInvalid;

  /// mbe-api request-validation type `product_barcode_invalid` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The barcode must be empty or exactly 13 digits (EAN-13).'**
  String get apiValidationProductBarcodeInvalid;

  /// mbe-api request-validation type `product_code_has_whitespace` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The code can\'t contain spaces.'**
  String get apiValidationProductCodeHasWhitespace;

  /// mbe-api request-validation type `profile_duplicate_system_object` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'A permission appears twice in this profile.'**
  String get apiValidationProfileDuplicateSystemObject;

  /// mbe-api request-validation type `profile_unknown_system_object` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The profile has a permission the server doesn\'t recognize.'**
  String get apiValidationProfileUnknownSystemObject;

  /// mbe-api request-validation type `supplier_agreement_end_before_start` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The end date can\'t be before the start date.'**
  String get apiValidationSupplierAgreementEndBeforeStart;

  /// mbe-api request-validation type `user_id_not_alphanumeric` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'The username can only have letters and numbers.'**
  String get apiValidationUserIdNotAlphanumeric;

  /// Record noun for the API resource name `customer_address` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{address} other{addresses}}'**
  String apiResourceCustomerAddress(int count);

  /// Grammatical gender of the noun for `customer_address` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderCustomerAddress;

  /// Record noun for the API resource name `customer_contact` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{contact} other{contacts}}'**
  String apiResourceCustomerContact(int count);

  /// Grammatical gender of the noun for `customer_contact` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderCustomerContact;

  /// Record noun for the API resource name `customer_taxpayer` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{tax recipient} other{tax recipients}}'**
  String apiResourceCustomerTaxpayer(int count);

  /// Grammatical gender of the noun for `customer_taxpayer` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderCustomerTaxpayer;

  /// Record noun for the API resource name `supplier_address` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{address} other{addresses}}'**
  String apiResourceSupplierAddress(int count);

  /// Grammatical gender of the noun for `supplier_address` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderSupplierAddress;

  /// Record noun for the API resource name `supplier_agreement` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{agreement} other{agreements}}'**
  String apiResourceSupplierAgreement(int count);

  /// Grammatical gender of the noun for `supplier_agreement` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderSupplierAgreement;

  /// Record noun for the API resource name `supplier_bank_account` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{bank account} other{bank accounts}}'**
  String apiResourceSupplierBankAccount(int count);

  /// Grammatical gender of the noun for `supplier_bank_account` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderSupplierBankAccount;

  /// Record noun for the API resource name `supplier_contact` (spec 058), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{contact} other{contacts}}'**
  String apiResourceSupplierContact(int count);

  /// Grammatical gender of the noun for `supplier_contact` in Spanish: `feminine` or `masculine` (spec 058)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderSupplierContact;

  /// spec 059: Reverse dialog title, and the table action tooltip
  ///
  /// In en, this message translates to:
  /// **'Reverse application'**
  String get paymentReverseTitle;

  /// spec 059: Reverse dialog: names what is being reversed
  ///
  /// In en, this message translates to:
  /// **'{amount} applied to order #{order}.'**
  String paymentReverseSubject(String amount, String order);

  /// spec 059: Reverse dialog: mandatory reason field label
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get paymentReverseReasonLabel;

  /// spec 059: Reverse dialog: refund caution (FR-004)
  ///
  /// In en, this message translates to:
  /// **'This order has refunds. Reversing the payment does not undo the refund.'**
  String get paymentReverseRefundWarning;

  /// spec 059: Reverse dialog: confirm button
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get paymentReverseConfirm;

  /// spec 059: Snackbar after a reversal
  ///
  /// In en, this message translates to:
  /// **'Application reversed'**
  String get paymentReverseDone;

  /// spec 059: Payment view: apply button
  ///
  /// In en, this message translates to:
  /// **'Apply to order'**
  String get paymentApplyAction;

  /// spec 059: Apply dialog title
  ///
  /// In en, this message translates to:
  /// **'Apply payment #{payment}'**
  String paymentApplyTitle(String payment);

  /// spec 059: Apply dialog header
  ///
  /// In en, this message translates to:
  /// **'Unapplied: {amount}'**
  String paymentApplyUnapplied(String amount);

  /// spec 059: Apply dialog: search hint
  ///
  /// In en, this message translates to:
  /// **'Order or folio…'**
  String get paymentApplySearchHint;

  /// spec 059: Apply dialog: folio column
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get paymentApplyColumnFolio;

  /// spec 059: Apply dialog: total column
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get paymentApplyColumnTotal;

  /// spec 059: Apply dialog: balance column
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get paymentApplyColumnBalance;

  /// spec 059: Apply dialog: amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount to apply'**
  String get paymentApplyAmountLabel;

  /// spec 059: Apply dialog: amount bound hint
  ///
  /// In en, this message translates to:
  /// **'Maximum {amount}'**
  String paymentApplyAmountMax(String amount);

  /// spec 059: Apply dialog: amount above the bound
  ///
  /// In en, this message translates to:
  /// **'It can\'t be more than {amount}.'**
  String paymentApplyAmountTooHigh(String amount);

  /// spec 059: Apply dialog: amount missing or zero
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero.'**
  String get paymentApplyAmountInvalid;

  /// spec 059: Apply dialog: empty state
  ///
  /// In en, this message translates to:
  /// **'This customer has no orders to pay in {currency}.'**
  String paymentApplyEmpty(String currency);

  /// spec 059: Apply dialog: confirm button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get paymentApplyConfirm;

  /// spec 059: Snackbar after an application
  ///
  /// In en, this message translates to:
  /// **'Payment applied to #{order}'**
  String paymentApplyDone(String order);

  /// spec 059: Pagos list: record button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get paymentRecordAction;

  /// spec 059: Pagos list: record button on compact screens
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentRecordActionShort;

  /// spec 059: Record dialog: currency label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get paymentRecordCurrencyLabel;

  /// spec 059: Record dialog: save button
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get paymentRecordSave;

  /// spec 059: Record dialog: save button while busy
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get paymentRecordSaving;

  /// spec 059: Record dialog: no customer
  ///
  /// In en, this message translates to:
  /// **'Choose a customer.'**
  String get paymentRecordErrorCustomer;

  /// spec 059: Record dialog: walk-in customer refused (FR-012)
  ///
  /// In en, this message translates to:
  /// **'Choose a named customer: the general public can\'t hold advances or credit payments.'**
  String get paymentRecordErrorWalkIn;

  /// spec 059: Record dialog: no method
  ///
  /// In en, this message translates to:
  /// **'Choose a payment method.'**
  String get paymentRecordErrorMethod;

  /// spec 059: Record dialog: reference required
  ///
  /// In en, this message translates to:
  /// **'This method needs a reference.'**
  String get paymentRecordErrorReference;

  /// spec 059: Record dialog: amount missing or zero
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero.'**
  String get paymentRecordErrorAmount;

  /// spec 059: Record dialog: cash without an open session (FR-015)
  ///
  /// In en, this message translates to:
  /// **'To record cash you need a cash session open today.'**
  String get paymentRecordErrorCashSession;

  /// spec 059: Record dialog: link next to the cash-session error
  ///
  /// In en, this message translates to:
  /// **'Go to cash sessions'**
  String get paymentRecordGoToSessions;

  /// spec 059: Record dialog: network failure after saving
  ///
  /// In en, this message translates to:
  /// **'We don\'t know whether the payment was recorded: the connection was lost. Look for it in Payments before trying again.'**
  String get paymentRecordUnknownResult;

  /// spec 059: Pedidos order header: payments button
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get salesOrderPaymentsButton;

  /// spec 059: Pedidos payments dialog title
  ///
  /// In en, this message translates to:
  /// **'Payments on order #{order}'**
  String salesOrderPaymentsTitle(String order);

  /// spec 059: Pedidos payments dialog: open the payment view
  ///
  /// In en, this message translates to:
  /// **'Open payment'**
  String get salesOrderPaymentOpenTooltip;

  /// spec 059: Apply dialog: search found nothing
  ///
  /// In en, this message translates to:
  /// **'No order matches the search.'**
  String get paymentApplyNoMatches;

  /// spec 060: nav label of the payment verification queue
  ///
  /// In en, this message translates to:
  /// **'Payment verification'**
  String get paymentVerificationMenuTitle;

  /// spec 060: queue empty state
  ///
  /// In en, this message translates to:
  /// **'There are no unverified payments for these filters.'**
  String get paymentVerificationEmpty;

  /// spec 060: queue method filter: every method
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get paymentVerificationMethodAll;

  /// spec 060: queue facility filter: every facility
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get paymentVerificationFacilityAll;

  /// spec 060: verify action (row icon tooltip and payment view button)
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get paymentVerifyAction;

  /// spec 060: reject action (row icon tooltip and payment view button)
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get paymentRejectAction;

  /// spec 060: verify dialog title
  ///
  /// In en, this message translates to:
  /// **'Verify payment'**
  String get paymentVerifyTitle;

  /// spec 060: reject dialog title
  ///
  /// In en, this message translates to:
  /// **'Reject payment'**
  String get paymentRejectTitle;

  /// spec 060: verify dialog: irreversibility notice
  ///
  /// In en, this message translates to:
  /// **'Confirm the money is in the bank. This can\'t be undone.'**
  String get paymentVerifyIrreversible;

  /// spec 060: reject dialog: reason field label
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get paymentRejectReasonLabel;

  /// spec 060: reject dialog: what a rejection does
  ///
  /// In en, this message translates to:
  /// **'The payment stays unverified; the rejection is recorded with your name and the date.'**
  String get paymentRejectNote;

  /// spec 060: snackbar after a verification
  ///
  /// In en, this message translates to:
  /// **'Payment {id} verified.'**
  String paymentVerifiedSnack(String id);

  /// spec 060: snackbar after a rejection
  ///
  /// In en, this message translates to:
  /// **'Rejection recorded. Payment {id} stays unverified and stays in the verification list.'**
  String paymentRejectedSnack(String id);

  /// spec 060: verify dialog: network failure, result unknown
  ///
  /// In en, this message translates to:
  /// **'We don\'t know whether it was verified: the connection was lost. The list was refreshed.'**
  String get paymentVerifyUnknown;

  /// spec 060: reject dialog: network failure, result unknown
  ///
  /// In en, this message translates to:
  /// **'We don\'t know whether the rejection was recorded: the connection was lost. The list was refreshed.'**
  String get paymentRejectUnknown;

  /// spec 060: mbe-api error code `payment.already_verified`
  ///
  /// In en, this message translates to:
  /// **'Someone else already verified this payment.'**
  String get apiErrorPaymentAlreadyVerified;

  /// spec 061: navigation entry under Ventas (C1)
  ///
  /// In en, this message translates to:
  /// **'Delivery orders'**
  String get navDeliveryOrders;

  /// spec 061: detail app bar title (C4)
  ///
  /// In en, this message translates to:
  /// **'Delivery order {serial}'**
  String deliveryOrderTitle(String serial);

  /// spec 061: detail app bar title of a draft (C4)
  ///
  /// In en, this message translates to:
  /// **'Delivery order · Draft'**
  String get deliveryOrderTitleDraft;

  /// spec 061: folio shown when the order has no serial yet (C2)
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get deliveryOrderDraftFolio;

  /// spec 061: list empty state (C2)
  ///
  /// In en, this message translates to:
  /// **'No delivery orders match these filters.'**
  String get deliveryOrdersEmpty;

  /// spec 061: list search hint, digits only (C2)
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get deliveryOrdersSearchHint;

  /// spec 061: list notice title when the user has no facility (C2)
  ///
  /// In en, this message translates to:
  /// **'No facility configured'**
  String get deliveryOrdersNoFacilityTitle;

  /// spec 061: list notice message when the user has no facility (C2)
  ///
  /// In en, this message translates to:
  /// **'Your account has no facility assigned, so delivery orders cannot be listed. Ask your administrator to configure one on your user.'**
  String get deliveryOrdersNoFacilityMessage;

  /// spec 061: detail not-found / error action (C4)
  ///
  /// In en, this message translates to:
  /// **'Back to delivery orders'**
  String get deliveryOrderBackToList;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get deliveryOrderStatusDraft;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get deliveryOrderStatusPendingApproval;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get deliveryOrderStatusApproved;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get deliveryOrderStatusReadyForPickup;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get deliveryOrderStatusPickedUp;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'In preparation'**
  String get deliveryOrderStatusInPreparation;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get deliveryOrderStatusInTransit;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveryOrderStatusDelivered;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Partially delivered'**
  String get deliveryOrderStatusPartiallyDelivered;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get deliveryOrderStatusFailed;

  /// spec 061: delivery order status label (C11)
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get deliveryOrderStatusCancelled;

  /// spec 061: delivery order type label (C11)
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get deliveryOrderTypeDelivery;

  /// spec 061: delivery order type label (C11)
  ///
  /// In en, this message translates to:
  /// **'Store pickup'**
  String get deliveryOrderTypePickup;

  /// spec 061: list column and detail fact label (C2, C4)
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get deliveryOrderColumnSerial;

  /// spec 061: list column and detail fact label (C2, C4)
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get deliveryOrderColumnCustomer;

  /// spec 061: list column and detail fact label (C2, C4)
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get deliveryOrderColumnType;

  /// spec 061: list column and detail fact label (C2, C4)
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get deliveryOrderColumnScheduled;

  /// spec 061: list column and detail fact label (C2, C4)
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get deliveryOrderColumnDestination;

  /// spec 061: list column and detail fact label (C2, C4)
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get deliveryOrderColumnSalesOrders;

  /// spec 061: list column and detail fact label (C2, C4)
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get deliveryOrderColumnStatus;

  /// spec 061: detail fact / band label (C4)
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get deliveryOrderFactFacility;

  /// spec 061: detail fact / band label (C4)
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get deliveryOrderFactPriority;

  /// spec 061: detail fact / band label (C4)
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get deliveryOrderFactContact;

  /// spec 061: detail fact / band label (C4)
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get deliveryOrderFactComment;

  /// spec 061: detail fact / band label (C4)
  ///
  /// In en, this message translates to:
  /// **'From order'**
  String get deliveryOrderFactParent;

  /// spec 061: detail fact / band label (C4)
  ///
  /// In en, this message translates to:
  /// **'Derived order'**
  String get deliveryOrderFactChild;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get deliveryOrderLineColumnCode;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get deliveryOrderLineColumnProduct;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get deliveryOrderLineColumnWarehouse;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get deliveryOrderLineColumnSalesOrder;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get deliveryOrderLineColumnOrdered;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get deliveryOrderLineColumnCommitted;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveryOrderLineColumnDelivered;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get deliveryOrderLineColumnReturned;

  /// spec 061: detail lines table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get deliveryOrderLineColumnOpen;

  /// spec 061: detail section title (C4)
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get deliveryOrderLinesTitle;

  /// spec 061: detail section title (C4)
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get deliveryOrderHistoryTitle;

  /// spec 061: detail section title (C4)
  ///
  /// In en, this message translates to:
  /// **'Proof of delivery'**
  String get deliveryOrderProofTitle;

  /// spec 061: proof section: receiver name label (C4)
  ///
  /// In en, this message translates to:
  /// **'Received by'**
  String get deliveryOrderProofReceiver;

  /// spec 061: proof section and pickup dialog field label (C4, C9)
  ///
  /// In en, this message translates to:
  /// **'Identification shown'**
  String get deliveryOrderProofIdShown;

  /// spec 061: proof section: capture time label (C4)
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get deliveryOrderProofCapturedAt;

  /// spec 061: proof section: who captured it (C4)
  ///
  /// In en, this message translates to:
  /// **'Captured by'**
  String get deliveryOrderProofCapturedBy;

  /// spec 061: proof section load failure (C4)
  ///
  /// In en, this message translates to:
  /// **'The proof could not be loaded'**
  String get deliveryOrderProofLoadFailed;

  /// spec 061: proof thumbnail tooltip (C4)
  ///
  /// In en, this message translates to:
  /// **'Enlarge photo'**
  String get deliveryOrderProofEnlargeTooltip;

  /// spec 061: history section empty state (C4)
  ///
  /// In en, this message translates to:
  /// **'No history yet.'**
  String get deliveryOrderEventsEmpty;

  /// spec 061: detail rejection banner (C4)
  ///
  /// In en, this message translates to:
  /// **'Rejection reason: {reason}'**
  String deliveryOrderRejectionBanner(String reason);

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get deliveryOrderFilterStatus;

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get deliveryOrderFilterType;

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'Scheduled date'**
  String get deliveryOrderFilterScheduled;

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get deliveryOrderFilterCustomer;

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get deliveryOrderFilterSalesOrder;

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get deliveryOrderFilterFacility;

  /// spec 061 FR-003: the status filter's default, every non-terminal status (mbe-api#312)
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get deliveryOrderFilterActiveStatuses;

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get deliveryOrderFilterAllStatuses;

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get deliveryOrderFilterAllTypes;

  /// spec 061: list filter sheet label (C3)
  ///
  /// In en, this message translates to:
  /// **'My facility'**
  String get deliveryOrderFilterMyFacility;

  /// spec 061: list filter sheet: sale field hint (C3)
  ///
  /// In en, this message translates to:
  /// **'Sale number'**
  String get deliveryOrderFilterSalesOrderHint;

  /// spec 061: detail action (C4, C10)
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get deliveryOrderEditHeader;

  /// spec 061: detail action (C4, C7)
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get deliveryOrderAddLine;

  /// spec 061: detail primary action (C4)
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get deliveryOrderConfirmAction;

  /// spec 061: detail action (C4)
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get deliveryOrderCancelAction;

  /// spec 061: detail primary action (C4)
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get deliveryOrderRequeueAction;

  /// spec 061: detail primary action (C4)
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get deliveryOrderReadyAction;

  /// spec 061: detail primary action (C4, C9)
  ///
  /// In en, this message translates to:
  /// **'Hand over to customer'**
  String get deliveryOrderPickupAction;

  /// spec 061: dialog dismiss button (C5-C10)
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get deliveryOrderBackButton;

  /// spec 061: line row action tooltip (C4, C8)
  ///
  /// In en, this message translates to:
  /// **'Change quantity'**
  String get deliveryOrderLineEditTooltip;

  /// spec 061: line row action tooltip (C4, C8)
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get deliveryOrderLineRemoveTooltip;

  /// spec 061: confirm dialog title (C5)
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery order?'**
  String get deliveryOrderConfirmTitle;

  /// spec 061: confirm dialog summary (C5)
  ///
  /// In en, this message translates to:
  /// **'{customer} · Scheduled {date} · {count, plural, one{# line} other{# lines}}'**
  String deliveryOrderConfirmSummary(String customer, String date, int count);

  /// spec 061: confirm dialog warning (C5)
  ///
  /// In en, this message translates to:
  /// **'Once confirmed, it can no longer be edited.'**
  String get deliveryOrderConfirmIrreversible;

  /// spec 061: hint beside the disabled Confirm button (C4, FR-016)
  ///
  /// In en, this message translates to:
  /// **'Add at least one line to confirm.'**
  String get deliveryOrderConfirmNeedsLines;

  /// spec 061: requeue dialog title (C5)
  ///
  /// In en, this message translates to:
  /// **'Reschedule order {serial}?'**
  String deliveryOrderRequeueTitle(String serial);

  /// spec 061: requeue dialog body (C5)
  ///
  /// In en, this message translates to:
  /// **'{customer}. The order goes back to In preparation and its quantities become open again.'**
  String deliveryOrderRequeueBody(String customer);

  /// spec 061: ready dialog title (C5)
  ///
  /// In en, this message translates to:
  /// **'Mark order {serial} ready for pickup?'**
  String deliveryOrderReadyTitle(String serial);

  /// spec 061: ready dialog body (C5)
  ///
  /// In en, this message translates to:
  /// **'{customer}. The customer will be able to come and pick the goods up.'**
  String deliveryOrderReadyBody(String customer);

  /// spec 061: cancel dialog title (C6)
  ///
  /// In en, this message translates to:
  /// **'Cancel order {serial}'**
  String deliveryOrderCancelTitle(String serial);

  /// spec 061: cancel dialog summary (C6)
  ///
  /// In en, this message translates to:
  /// **'{customer} · Scheduled {date}'**
  String deliveryOrderCancelSummary(String customer, String date);

  /// spec 061: cancel dialog reason field (C6)
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get deliveryOrderCancelReasonLabel;

  /// spec 061: add-line dialog title, step 1 (C7)
  ///
  /// In en, this message translates to:
  /// **'Add line · 1 of 2'**
  String get deliveryOrderAddLineStep1Title;

  /// spec 061: add-line dialog title, step 2 (C7)
  ///
  /// In en, this message translates to:
  /// **'Add line · 2 of 2 · Sale {serial}'**
  String deliveryOrderAddLineStep2Title(String serial);

  /// spec 061: add-line step 1 intro (C7)
  ///
  /// In en, this message translates to:
  /// **'Completed sales of {customer} at {facility}'**
  String deliveryOrderAddLineStep1Intro(String customer, String facility);

  /// spec 061: add-line step 1 search hint (C7)
  ///
  /// In en, this message translates to:
  /// **'Sale folio'**
  String get deliveryOrderAddLineSearchHint;

  /// spec 061: add-line step 1 table column (C7)
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get deliveryOrderAddLineSaleColumnSerial;

  /// spec 061: add-line step 1 table column (C7)
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get deliveryOrderAddLineSaleColumnDate;

  /// spec 061: add-line step 1 table column (C7)
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get deliveryOrderAddLineSaleColumnTotal;

  /// spec 061: add-line step 1 pagination (C7)
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get deliveryOrderAddLineLoadMore;

  /// spec 061: add-line step 2 table column (C7)
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get deliveryOrderAddLineColumnRemaining;

  /// spec 061: add-line step 2 table column (C7)
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get deliveryOrderAddLineColumnQuantity;

  /// spec 061: add-line step 2 back button (C7)
  ///
  /// In en, this message translates to:
  /// **'Another sale'**
  String get deliveryOrderAddLineAnotherSale;

  /// spec 061: add-line step 2 submit button (C7)
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get deliveryOrderAddLineSubmit;

  /// spec 061: add-line step 1 empty state (C7)
  ///
  /// In en, this message translates to:
  /// **'This customer has no sales with goods left to deliver at this facility.'**
  String get deliveryOrderAddLineEmptySales;

  /// spec 061: add-line step 2 empty state (C7)
  ///
  /// In en, this message translates to:
  /// **'This sale has nothing left to deliver.'**
  String get deliveryOrderAddLineEmptyLines;

  /// spec 061: add-line quantity field validation (C7)
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0 and at most {remaining}.'**
  String deliveryOrderAddLineQuantityInvalid(String remaining);

  /// spec 061: line quantity dialog title (C8)
  ///
  /// In en, this message translates to:
  /// **'Change quantity'**
  String get deliveryOrderLineQuantityTitle;

  /// spec 061: line quantity dialog hint above the field (C8)
  ///
  /// In en, this message translates to:
  /// **'Ordered on the sale: {quantity}'**
  String deliveryOrderLineQuantityOrdered(String quantity);

  /// spec 061: line quantity dialog field label (C8)
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get deliveryOrderLineQuantityLabel;

  /// spec 061: line quantity field validation (C8)
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0.'**
  String get deliveryOrderLineQuantityInvalid;

  /// spec 061: remove-line confirmation title (C8)
  ///
  /// In en, this message translates to:
  /// **'Remove {product} from the order?'**
  String deliveryOrderLineRemoveTitle(String product);

  /// spec 061: remove-line confirmation body (C8)
  ///
  /// In en, this message translates to:
  /// **'The quantity becomes available for delivery again.'**
  String get deliveryOrderLineRemoveBody;

  /// spec 061: remove-line confirmation button (C8)
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get deliveryOrderLineRemoveAction;

  /// spec 061: pickup dialog title (C9)
  ///
  /// In en, this message translates to:
  /// **'Hand over to customer · Order {serial}'**
  String deliveryOrderPickupTitle(String serial);

  /// spec 061: pickup dialog field label (C9)
  ///
  /// In en, this message translates to:
  /// **'Receiver name'**
  String get deliveryOrderPickupNameLabel;

  /// spec 061: pickup dialog field label (C9)
  ///
  /// In en, this message translates to:
  /// **'Identification shown'**
  String get deliveryOrderPickupIdLabel;

  /// spec 061: pickup dialog field label (C9)
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get deliveryOrderPickupPhotoLabel;

  /// spec 061: pickup dialog photo button (C9)
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get deliveryOrderPickupChooseFile;

  /// spec 061: pickup dialog clear-file tooltip (C9)
  ///
  /// In en, this message translates to:
  /// **'Remove file'**
  String get deliveryOrderPickupClearFile;

  /// spec 061: pickup dialog confirm button (C9)
  ///
  /// In en, this message translates to:
  /// **'Hand over'**
  String get deliveryOrderPickupSubmit;

  /// spec 061: header dialog title (C10)
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get deliveryOrderHeaderTitle;

  /// spec 061: header dialog field label (C10)
  ///
  /// In en, this message translates to:
  /// **'Scheduled date'**
  String get deliveryOrderHeaderScheduledLabel;

  /// spec 061: header dialog field label (C10)
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get deliveryOrderHeaderPriorityLabel;

  /// spec 061: header dialog field label (C10)
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get deliveryOrderHeaderDestinationLabel;

  /// spec 061: header dialog field label (C10)
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get deliveryOrderHeaderContactLabel;

  /// spec 061: header dialog field label (C10)
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get deliveryOrderHeaderCommentLabel;

  /// spec 061: header dialog priority validation (C10)
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number, 0 or more.'**
  String get deliveryOrderHeaderPriorityInvalid;

  /// spec 061: header dialog: read-only destination of a pickup order (C10)
  ///
  /// In en, this message translates to:
  /// **'Store {facility}'**
  String deliveryOrderHeaderPickupDestination(String facility);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Order {serial} confirmed'**
  String deliveryOrderSnackConfirmed(String serial);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Order {serial} cancelled'**
  String deliveryOrderSnackCancelled(String serial);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Order {serial} rescheduled'**
  String deliveryOrderSnackRequeued(String serial);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Order {serial} ready for pickup'**
  String deliveryOrderSnackReady(String serial);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Order {serial} handed over to the customer'**
  String deliveryOrderSnackPickedUp(String serial);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Order {serial} header saved'**
  String deliveryOrderSnackHeaderSaved(String serial);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Line added to order {serial}'**
  String deliveryOrderSnackLineAdded(String serial);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Quantity updated on order {serial}'**
  String deliveryOrderSnackLineUpdated(String serial);

  /// spec 061: snackbar after the action succeeds
  ///
  /// In en, this message translates to:
  /// **'Line removed from order {serial}'**
  String deliveryOrderSnackLineRemoved(String serial);

  /// spec 061: action network failure, result unknown (FR-022)
  ///
  /// In en, this message translates to:
  /// **'We don\'t know whether it completed: the connection was lost. The order was refreshed.'**
  String get deliveryOrderActionUnknown;

  /// spec 061: mbe-api error code `delivery_order.insufficient_notice` (R10)
  ///
  /// In en, this message translates to:
  /// **'At least {minHours} h of notice are required. Earliest date: {earliest}.'**
  String apiErrorDeliveryOrderInsufficientNotice(
    String minHours,
    String earliest,
  );

  /// spec 061: mbe-api error code `delivery_order.no_lines` (R10)
  ///
  /// In en, this message translates to:
  /// **'The delivery order has no lines.'**
  String get apiErrorDeliveryOrderNoLines;

  /// spec 061: mbe-api error code `delivery_order.not_failed` (R10)
  ///
  /// In en, this message translates to:
  /// **'Only a failed order can be rescheduled.'**
  String get apiErrorDeliveryOrderNotFailed;

  /// mbe-api error code `delivery_order.on_itinerary` (mbe-api#311)
  ///
  /// In en, this message translates to:
  /// **'This order is on an open delivery itinerary. Remove it from the itinerary before cancelling it.'**
  String get apiErrorDeliveryOrderOnItinerary;

  /// spec 061: mbe-api error code `delivery_order.proof_incomplete` (R10)
  ///
  /// In en, this message translates to:
  /// **'The proof is incomplete: enter who received the goods and the identification they showed.'**
  String get apiErrorDeliveryOrderProofIncomplete;

  /// spec 062: navigation entry under Logística (C1)
  ///
  /// In en, this message translates to:
  /// **'Delivery approval'**
  String get navDeliveryOrderApproval;

  /// spec 062: queue column (C2)
  ///
  /// In en, this message translates to:
  /// **'Prio.'**
  String get deliveryOrderApprovalColumnPriority;

  /// spec 062: queue empty state (C2)
  ///
  /// In en, this message translates to:
  /// **'No delivery orders are waiting for approval.'**
  String get deliveryOrderApprovalEmpty;

  /// spec 062: queue notice title when the user has no facility (FR-004)
  ///
  /// In en, this message translates to:
  /// **'No facility configured'**
  String get deliveryOrderApprovalNoFacilityTitle;

  /// spec 062: queue notice message when the user has no facility (FR-004)
  ///
  /// In en, this message translates to:
  /// **'Your account has no facility assigned. Delivery approval shows your facility\'s orders. Ask your administrator to configure one on your user.'**
  String get deliveryOrderApprovalNoFacilityMessage;

  /// spec 062: queue not-allowed state after a 403 (C2)
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to delivery approval.'**
  String get deliveryOrderApprovalForbidden;

  /// spec 062: row tooltip, detail button and dialog confirm (C2, C3, C7)
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get deliveryOrderApproveAction;

  /// spec 062: row tooltip, detail button and dialog confirm (C2, C4, C7)
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get deliveryOrderRejectAction;

  /// spec 062: approve dialog title (C3)
  ///
  /// In en, this message translates to:
  /// **'Approve delivery order {serial}?'**
  String deliveryOrderApproveTitle(String serial);

  /// spec 062: approve dialog note for a delivery (FR-008)
  ///
  /// In en, this message translates to:
  /// **'It will move to In preparation and appear for the warehouse.'**
  String get deliveryOrderApproveNextDelivery;

  /// spec 062: approve dialog note for a pickup (FR-008)
  ///
  /// In en, this message translates to:
  /// **'It will move to Approved; then it is marked ready for pickup.'**
  String get deliveryOrderApproveNextPickup;

  /// spec 062: reject dialog title (C4)
  ///
  /// In en, this message translates to:
  /// **'Reject delivery order {serial}'**
  String deliveryOrderRejectTitle(String serial);

  /// spec 062: reject dialog summary (C4)
  ///
  /// In en, this message translates to:
  /// **'{customer} · Scheduled {date}'**
  String deliveryOrderRejectSummary(String customer, String date);

  /// spec 062: reject dialog reason field (C4)
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get deliveryOrderRejectReasonLabel;

  /// spec 062: reject dialog note (FR-011)
  ///
  /// In en, this message translates to:
  /// **'The order goes back to its author as a draft so they can fix it and confirm it again. The reason stays on the order.'**
  String get deliveryOrderRejectNote;

  /// spec 062: snackbar after an approval (FR-009)
  ///
  /// In en, this message translates to:
  /// **'Order {serial} approved: {status}'**
  String deliveryOrderSnackApproved(String serial, String status);

  /// spec 062: snackbar after a rejection (FR-012)
  ///
  /// In en, this message translates to:
  /// **'Order {serial} rejected. It went back to draft with the reason.'**
  String deliveryOrderSnackRejected(String serial);

  /// spec 062: mbe-api error code `delivery_order.not_pending_approval` (R9)
  ///
  /// In en, this message translates to:
  /// **'This order is no longer pending approval.'**
  String get apiErrorDeliveryOrderNotPendingApproval;

  /// spec 063: navigation entry under Logística (C1) and screen title
  ///
  /// In en, this message translates to:
  /// **'For delivery'**
  String get navForDelivery;

  /// spec 063: label of the period filter (C3)
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get forDeliveryPeriodLabel;

  /// spec 063: period option, before yesterday
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get forDeliveryPeriodEarlier;

  /// spec 063: period option
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get forDeliveryPeriodYesterday;

  /// spec 063: period option, the default
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get forDeliveryPeriodToday;

  /// spec 063: period option
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get forDeliveryPeriodTomorrow;

  /// spec 063: period option
  ///
  /// In en, this message translates to:
  /// **'Day after tomorrow'**
  String get forDeliveryPeriodDayAfter;

  /// spec 063: period option, later than the day after tomorrow or with no date
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get forDeliveryPeriodLater;

  /// spec 063: single-day period option with its date and line count (C3)
  ///
  /// In en, this message translates to:
  /// **'{label} · {date} ({total})'**
  String forDeliveryPeriodOptionDated(String label, String date, int total);

  /// spec 063: open-ended period option with its line count (C3)
  ///
  /// In en, this message translates to:
  /// **'{label} ({total})'**
  String forDeliveryPeriodOptionUndated(String label, int total);

  /// spec 063: scheduled date of a line whose order has none (FR-005)
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get forDeliveryNoDate;

  /// spec 063: empty state (C5)
  ///
  /// In en, this message translates to:
  /// **'No deliveries pending for this period.'**
  String get forDeliveryEmpty;

  /// spec 063: table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Prio.'**
  String get forDeliveryColumnPriority;

  /// spec 063: table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get forDeliveryColumnProduct;

  /// spec 063: table column (C4)
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get forDeliveryColumnWarehouse;

  /// spec 063: table column, quantity still to load (C4)
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get forDeliveryColumnOpenQuantity;

  /// spec 064: detail button and list row action that open the delivery ticket (U1, U2)
  ///
  /// In en, this message translates to:
  /// **'View ticket'**
  String get deliveryOrderViewTicket;

  /// spec 064: detail button that opens the Letter-size delivery order (U1)
  ///
  /// In en, this message translates to:
  /// **'View letter format'**
  String get deliveryOrderViewLetter;

  /// spec 064: title of the warehouse chooser (U5)
  ///
  /// In en, this message translates to:
  /// **'Which lines to print?'**
  String get deliveryTicketScopeTitle;

  /// spec 064: chooser option that prints every line (U5)
  ///
  /// In en, this message translates to:
  /// **'All warehouses'**
  String get deliveryTicketScopeAll;

  /// spec 064: preview title of the delivery or pickup ticket
  ///
  /// In en, this message translates to:
  /// **'Delivery ticket · {folio}'**
  String documentDeliveryTicketTitle(String folio);

  /// spec 064: preview title of a ticket limited to one warehouse
  ///
  /// In en, this message translates to:
  /// **'Delivery ticket · {folio} · {warehouse}'**
  String documentDeliveryTicketWarehouseTitle(String folio, String warehouse);

  /// spec 064: preview title of the Letter-size delivery order
  ///
  /// In en, this message translates to:
  /// **'Delivery order · {folio} (letter)'**
  String documentDeliveryOrderLetterTitle(String folio);

  /// spec 064: mbe-api error code `delivery_order.not_approved` (R9)
  ///
  /// In en, this message translates to:
  /// **'The delivery order isn\'t approved yet, so it can\'t be printed.'**
  String get apiErrorDeliveryOrderNotApproved;

  /// spec 064: mbe-api error code `delivery_order.unknown_warehouse` (R9)
  ///
  /// In en, this message translates to:
  /// **'The chosen warehouse doesn\'t exist.'**
  String get apiErrorDeliveryOrderUnknownWarehouse;

  /// spec 064: mbe-api error code `delivery_order.no_lines_from_warehouse` (R9)
  ///
  /// In en, this message translates to:
  /// **'No line of this order leaves from the chosen warehouse.'**
  String get apiErrorDeliveryOrderNoLinesFromWarehouse;

  /// spec 065: Series section title on the taxpayer issuer detail
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get taxpayerBatchesSectionTitle;

  /// spec 065: Series section title with the number of series
  ///
  /// In en, this message translates to:
  /// **'Series ({count})'**
  String taxpayerBatchesSectionTitleWithCount(int count);

  /// spec 065: empty state of the Series section
  ///
  /// In en, this message translates to:
  /// **'This issuer has no series. Without a series of the right type it can\'t issue that document.'**
  String get taxpayerBatchesEmpty;

  /// spec 065: Series table column
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get taxpayerBatchColumnSeries;

  /// spec 065: Series table column: the document type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get taxpayerBatchColumnType;

  /// spec 065: Series table column: the print template name
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get taxpayerBatchColumnTemplate;

  /// spec 065: Series table column and tooltip: documents already use the series
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get taxpayerBatchColumnInUse;

  /// spec 065: series dialog title in create mode
  ///
  /// In en, this message translates to:
  /// **'New series'**
  String get taxpayerBatchDialogCreateTitle;

  /// spec 065: series dialog title in read-only mode
  ///
  /// In en, this message translates to:
  /// **'View series'**
  String get taxpayerBatchDialogViewTitle;

  /// spec 065: series dialog title in edit mode
  ///
  /// In en, this message translates to:
  /// **'Edit series'**
  String get taxpayerBatchDialogEditTitle;

  /// spec 065: series field label
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get taxpayerBatchSeriesLabel;

  /// spec 065: document type field label
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get taxpayerBatchTypeLabel;

  /// spec 065: template name field label
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get taxpayerBatchTemplateNameLabel;

  /// spec 065: logo file name field label
  ///
  /// In en, this message translates to:
  /// **'Logo (file name)'**
  String get taxpayerBatchLogoLabel;

  /// spec 065: header height field label
  ///
  /// In en, this message translates to:
  /// **'Header height (mm)'**
  String get taxpayerBatchHeaderHeightLabel;

  /// spec 065: footer height field label
  ///
  /// In en, this message translates to:
  /// **'Footer height (mm)'**
  String get taxpayerBatchFooterHeightLabel;

  /// spec 065: note shown when the series is locked
  ///
  /// In en, this message translates to:
  /// **'Documents have already been issued with this series; only the template can change.'**
  String get taxpayerBatchInUseNote;

  /// spec 065: bank accounts group title
  ///
  /// In en, this message translates to:
  /// **'Bank accounts'**
  String get taxpayerBatchAccountsTitle;

  /// spec 065: bank account field label
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get taxpayerBatchAccountBank;

  /// spec 065: bank account number field label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get taxpayerBatchAccountNumber;

  /// spec 065: bank account CLABE field label
  ///
  /// In en, this message translates to:
  /// **'CLABE'**
  String get taxpayerBatchAccountClabe;

  /// spec 065: bank account currency field label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get taxpayerBatchAccountCurrency;

  /// spec 065: button to add a bank account row
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get taxpayerBatchAddAccount;

  /// spec 065: tooltip to move a bank account up
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get taxpayerBatchMoveAccountUp;

  /// spec 065: tooltip to move a bank account down
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get taxpayerBatchMoveAccountDown;

  /// spec 065: tooltip to remove a bank account row
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get taxpayerBatchRemoveAccount;

  /// spec 065: bank accounts group when empty in read-only mode
  ///
  /// In en, this message translates to:
  /// **'No bank accounts'**
  String get taxpayerBatchNoAccounts;

  /// spec 065: close button of the read-only series dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get taxpayerBatchCloseButton;

  /// spec 065: delete confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete series?'**
  String get taxpayerBatchDeleteTitle;

  /// spec 065: delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Series {series} ({type}) will be deleted.'**
  String taxpayerBatchDeleteMessage(String series, String type);

  /// spec 065: client validation: series blank
  ///
  /// In en, this message translates to:
  /// **'Enter the series.'**
  String get taxpayerBatchSeriesRequiredError;

  /// spec 065: client validation: series longer than 10
  ///
  /// In en, this message translates to:
  /// **'The series can have at most 10 characters.'**
  String get taxpayerBatchSeriesTooLongError;

  /// spec 065: client validation: no document type
  ///
  /// In en, this message translates to:
  /// **'Choose the document type.'**
  String get taxpayerBatchTypeRequiredError;

  /// spec 065: client validation: template name blank
  ///
  /// In en, this message translates to:
  /// **'Enter the template name.'**
  String get taxpayerBatchTemplateNameRequiredError;

  /// spec 065: client validation: template name longer than 50
  ///
  /// In en, this message translates to:
  /// **'The template name can have at most 50 characters.'**
  String get taxpayerBatchTemplateNameTooLongError;

  /// spec 065: client validation: height not a whole number >= 0
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number, 0 or more.'**
  String get taxpayerBatchHeightInvalidError;

  /// spec 065: label of the fiscal document kind Invoice
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get fiscalDocumentKindInvoice;

  /// spec 065: label of the fiscal document kind FeeReceipt
  ///
  /// In en, this message translates to:
  /// **'Fee receipt'**
  String get fiscalDocumentKindFeeReceipt;

  /// spec 065: label of the fiscal document kind RentReceipt
  ///
  /// In en, this message translates to:
  /// **'Rent receipt'**
  String get fiscalDocumentKindRentReceipt;

  /// spec 065: label of the fiscal document kind DebitNote
  ///
  /// In en, this message translates to:
  /// **'Debit note'**
  String get fiscalDocumentKindDebitNote;

  /// spec 065: label of the fiscal document kind CreditNote
  ///
  /// In en, this message translates to:
  /// **'Credit note'**
  String get fiscalDocumentKindCreditNote;

  /// spec 065: label of the fiscal document kind PaymentReceipt
  ///
  /// In en, this message translates to:
  /// **'Payment receipt'**
  String get fiscalDocumentKindPaymentReceipt;

  /// spec 065: label of the fiscal document kind AdvancePaymentsApplied
  ///
  /// In en, this message translates to:
  /// **'Advance payments applied'**
  String get fiscalDocumentKindAdvancePaymentsApplied;

  /// spec 065: label of a fiscal document type code this app does not know
  ///
  /// In en, this message translates to:
  /// **'Unknown type ({code})'**
  String fiscalDocumentKindUnknown(int code);

  /// spec 065: mbe-api error code `taxpayer_batch.in_use` with action `update`
  ///
  /// In en, this message translates to:
  /// **'The series is already used by issued documents; only its template can change.'**
  String get apiErrorTaxpayerBatchInUseUpdate;

  /// spec 065: mbe-api error code `taxpayer_batch.in_use` with action `delete`
  ///
  /// In en, this message translates to:
  /// **'The series is already used by issued documents and can\'t be deleted.'**
  String get apiErrorTaxpayerBatchInUseDelete;

  /// spec 065: mbe-api request-validation type `taxpayer_batch_series_blank`
  ///
  /// In en, this message translates to:
  /// **'The series can\'t be blank.'**
  String get apiValidationTaxpayerBatchSeriesBlank;

  /// Record noun for the API resource name `taxpayer_batch` (spec 065), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{series} other{series}}'**
  String apiResourceTaxpayerBatch(int count);

  /// Grammatical gender of the noun for `taxpayer_batch` in Spanish: `feminine` or `masculine` (spec 065)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderTaxpayerBatch;

  /// spec 065: banner headline when saving a series fails
  ///
  /// In en, this message translates to:
  /// **'The series couldn\'t be saved.'**
  String get taxpayerBatchSaveFailed;

  /// spec 065: banner headline when deleting a series fails
  ///
  /// In en, this message translates to:
  /// **'The series couldn\'t be deleted.'**
  String get taxpayerBatchDeleteFailed;

  /// spec 066: navInvoicingGroup
  ///
  /// In en, this message translates to:
  /// **'Invoicing'**
  String get navInvoicingGroup;

  /// spec 066: navFiscalDocuments
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get navFiscalDocuments;

  /// spec 066: fiscalDocumentTitle
  ///
  /// In en, this message translates to:
  /// **'Invoice {folio}'**
  String fiscalDocumentTitle(String folio);

  /// spec 066: fiscalDocumentTitleKind
  ///
  /// In en, this message translates to:
  /// **'{kind} {folio}'**
  String fiscalDocumentTitleKind(String kind, String folio);

  /// spec 066: fiscalDocumentTitleDraft
  ///
  /// In en, this message translates to:
  /// **'Draft #{id}'**
  String fiscalDocumentTitleDraft(int id);

  /// spec 066: fiscalDocumentDraftFolio
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get fiscalDocumentDraftFolio;

  /// spec 066: fiscalDocumentsEmpty
  ///
  /// In en, this message translates to:
  /// **'There are no invoices yet.'**
  String get fiscalDocumentsEmpty;

  /// spec 066: fiscalDocumentsSearchHint
  ///
  /// In en, this message translates to:
  /// **'Folio, UUID, recipient RFC or name'**
  String get fiscalDocumentsSearchHint;

  /// spec 066: fiscalDocumentBackToList
  ///
  /// In en, this message translates to:
  /// **'Back to invoices'**
  String get fiscalDocumentBackToList;

  /// spec 066: fiscalDocumentNotFound
  ///
  /// In en, this message translates to:
  /// **'We could not find this document.'**
  String get fiscalDocumentNotFound;

  /// spec 066: fiscalDocumentLoadFailed
  ///
  /// In en, this message translates to:
  /// **'The document could not be loaded.'**
  String get fiscalDocumentLoadFailed;

  /// spec 066: fiscalDocumentStatusDraft
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get fiscalDocumentStatusDraft;

  /// spec 066: fiscalDocumentStatusSealed
  ///
  /// In en, this message translates to:
  /// **'Sealed'**
  String get fiscalDocumentStatusSealed;

  /// spec 066: fiscalDocumentStatusIssued
  ///
  /// In en, this message translates to:
  /// **'Stamped'**
  String get fiscalDocumentStatusIssued;

  /// spec 066: fiscalDocumentStatusCancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get fiscalDocumentStatusCancelled;

  /// spec 066: fiscalDocumentColFolio
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get fiscalDocumentColFolio;

  /// spec 066: fiscalDocumentColType
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fiscalDocumentColType;

  /// spec 066: fiscalDocumentColIssuer
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get fiscalDocumentColIssuer;

  /// spec 066: fiscalDocumentColRecipient
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get fiscalDocumentColRecipient;

  /// spec 066: fiscalDocumentColIssued
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get fiscalDocumentColIssued;

  /// spec 066: fiscalDocumentColStatus
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fiscalDocumentColStatus;

  /// spec 066: fiscalDocumentColTotal
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get fiscalDocumentColTotal;

  /// spec 066: fiscalDocumentFacetStatus
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fiscalDocumentFacetStatus;

  /// spec 066: fiscalDocumentFacetType
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fiscalDocumentFacetType;

  /// spec 066: fiscalDocumentFacetIssuer
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get fiscalDocumentFacetIssuer;

  /// spec 066: fiscalDocumentFacetIssued
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get fiscalDocumentFacetIssued;

  /// spec 066: fiscalDocumentFacetAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get fiscalDocumentFacetAll;

  /// spec 066: fiscalDocumentDateFacetHelper
  ///
  /// In en, this message translates to:
  /// **'Drafts have no issue date and do not appear when filtering by date.'**
  String get fiscalDocumentDateFacetHelper;

  /// spec 066: fiscalDocumentBannerSealed
  ///
  /// In en, this message translates to:
  /// **'Sealed, waiting to be stamped. Stamping is not available in this system yet.'**
  String get fiscalDocumentBannerSealed;

  /// spec 066: fiscalDocumentBannerReadOnlyKind
  ///
  /// In en, this message translates to:
  /// **'This type of document can only be viewed.'**
  String get fiscalDocumentBannerReadOnlyKind;

  /// spec 066: fiscalDocumentBannerCancelled
  ///
  /// In en, this message translates to:
  /// **'Cancelled on {date}.'**
  String fiscalDocumentBannerCancelled(String date);

  /// spec 066: fiscalDocumentNoCustomerNote
  ///
  /// In en, this message translates to:
  /// **'This draft has no customer: the recipient cannot be changed and orders cannot be added.'**
  String get fiscalDocumentNoCustomerNote;

  /// spec 066: fiscalDocumentFactIssuer
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get fiscalDocumentFactIssuer;

  /// spec 066: fiscalDocumentFactRecipient
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get fiscalDocumentFactRecipient;

  /// spec 066: fiscalDocumentFactCustomer
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get fiscalDocumentFactCustomer;

  /// spec 066: fiscalDocumentFactFacility
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get fiscalDocumentFactFacility;

  /// spec 066: fiscalDocumentFactSeriesFolio
  ///
  /// In en, this message translates to:
  /// **'Series and folio'**
  String get fiscalDocumentFactSeriesFolio;

  /// spec 066: fiscalDocumentFactIssued
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get fiscalDocumentFactIssued;

  /// spec 066: fiscalDocumentFactPaymentTerms
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get fiscalDocumentFactPaymentTerms;

  /// spec 066: fiscalDocumentFactPaymentForm
  ///
  /// In en, this message translates to:
  /// **'Payment form'**
  String get fiscalDocumentFactPaymentForm;

  /// spec 066: fiscalDocumentFactUsage
  ///
  /// In en, this message translates to:
  /// **'CFDI use'**
  String get fiscalDocumentFactUsage;

  /// spec 066: fiscalDocumentFactCurrency
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get fiscalDocumentFactCurrency;

  /// spec 066: fiscalDocumentFactReference
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get fiscalDocumentFactReference;

  /// spec 066: fiscalDocumentFactComment
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fiscalDocumentFactComment;

  /// spec 066: fiscalDocumentFactUuid
  ///
  /// In en, this message translates to:
  /// **'UUID'**
  String get fiscalDocumentFactUuid;

  /// spec 066: fiscalDocumentFactStamped
  ///
  /// In en, this message translates to:
  /// **'Stamp date'**
  String get fiscalDocumentFactStamped;

  /// spec 066: fiscalDocumentFactRegime
  ///
  /// In en, this message translates to:
  /// **'Regime'**
  String get fiscalDocumentFactRegime;

  /// spec 066: fiscalDocumentFactPostalCode
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get fiscalDocumentFactPostalCode;

  /// spec 066: fiscalDocumentFactIssuedOnConfirm
  ///
  /// In en, this message translates to:
  /// **'when confirmed'**
  String get fiscalDocumentFactIssuedOnConfirm;

  /// spec 066: fiscalDocumentTermsPue
  ///
  /// In en, this message translates to:
  /// **'Payment in a single installment (PUE)'**
  String get fiscalDocumentTermsPue;

  /// spec 066: fiscalDocumentTermsPpd
  ///
  /// In en, this message translates to:
  /// **'Payment in installments or deferred (PPD)'**
  String get fiscalDocumentTermsPpd;

  /// spec 066: fiscalDocumentLinesTitle
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get fiscalDocumentLinesTitle;

  /// spec 066: fiscalDocumentLineQuantity
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get fiscalDocumentLineQuantity;

  /// spec 066: fiscalDocumentLineUnit
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get fiscalDocumentLineUnit;

  /// spec 066: fiscalDocumentLineSatKey
  ///
  /// In en, this message translates to:
  /// **'SAT key'**
  String get fiscalDocumentLineSatKey;

  /// spec 066: fiscalDocumentLineDescription
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fiscalDocumentLineDescription;

  /// spec 066: fiscalDocumentLinePrice
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get fiscalDocumentLinePrice;

  /// spec 066: fiscalDocumentLineDiscount
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get fiscalDocumentLineDiscount;

  /// spec 066: fiscalDocumentLineTax
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get fiscalDocumentLineTax;

  /// spec 066: fiscalDocumentLineAmount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get fiscalDocumentLineAmount;

  /// spec 066: fiscalDocumentLineInternalCode
  ///
  /// In en, this message translates to:
  /// **'Internal code: {code}'**
  String fiscalDocumentLineInternalCode(String code);

  /// spec 066: fiscalDocumentLineFromOrder
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get fiscalDocumentLineFromOrder;

  /// spec 066: fiscalDocumentLinesEmpty
  ///
  /// In en, this message translates to:
  /// **'The invoice has no lines.'**
  String get fiscalDocumentLinesEmpty;

  /// spec 066: fiscalDocumentTaxIva16
  ///
  /// In en, this message translates to:
  /// **'16 %'**
  String get fiscalDocumentTaxIva16;

  /// spec 066: fiscalDocumentTaxZero
  ///
  /// In en, this message translates to:
  /// **'0 %'**
  String get fiscalDocumentTaxZero;

  /// spec 066: fiscalDocumentTaxExempt
  ///
  /// In en, this message translates to:
  /// **'Exempt'**
  String get fiscalDocumentTaxExempt;

  /// spec 066: fiscalDocumentTaxOther
  ///
  /// In en, this message translates to:
  /// **'{rate}'**
  String fiscalDocumentTaxOther(String rate);

  /// spec 066: fiscalDocumentRelationsTitle
  ///
  /// In en, this message translates to:
  /// **'Related documents'**
  String get fiscalDocumentRelationsTitle;

  /// spec 066: fiscalDocumentTotalSubtotal
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get fiscalDocumentTotalSubtotal;

  /// spec 066: fiscalDocumentTotalDiscount
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get fiscalDocumentTotalDiscount;

  /// spec 066: fiscalDocumentTotalTax
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get fiscalDocumentTotalTax;

  /// spec 066: fiscalDocumentTotalTotal
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get fiscalDocumentTotalTotal;

  /// spec 066: fiscalDocumentTotalEstimated
  ///
  /// In en, this message translates to:
  /// **'Total (estimated)'**
  String get fiscalDocumentTotalEstimated;

  /// spec 066: fiscalDocumentRelationSubstitution
  ///
  /// In en, this message translates to:
  /// **'04 · Substitution of a cancelled CFDI'**
  String get fiscalDocumentRelationSubstitution;

  /// spec 066: fiscalDocumentRelationAdvance
  ///
  /// In en, this message translates to:
  /// **'07 · Application of an advance'**
  String get fiscalDocumentRelationAdvance;

  /// spec 066: fiscalDocumentRelationCreditNote
  ///
  /// In en, this message translates to:
  /// **'01 · Credit note'**
  String get fiscalDocumentRelationCreditNote;

  /// spec 066: fiscalDocumentNewAction
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get fiscalDocumentNewAction;

  /// spec 066: fiscalDocumentEditHeader
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get fiscalDocumentEditHeader;

  /// spec 066: fiscalDocumentAddOrder
  ///
  /// In en, this message translates to:
  /// **'Add order'**
  String get fiscalDocumentAddOrder;

  /// spec 066: fiscalDocumentAddProduct
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get fiscalDocumentAddProduct;

  /// spec 066: fiscalDocumentAddRelation
  ///
  /// In en, this message translates to:
  /// **'Add relation'**
  String get fiscalDocumentAddRelation;

  /// spec 066: fiscalDocumentConfirmAction
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get fiscalDocumentConfirmAction;

  /// spec 066: fiscalDocumentReopenAction
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get fiscalDocumentReopenAction;

  /// spec 066: fiscalDocumentViewPdf
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get fiscalDocumentViewPdf;

  /// spec 066: fiscalDocumentDownloadXml
  ///
  /// In en, this message translates to:
  /// **'Download XML'**
  String get fiscalDocumentDownloadXml;

  /// spec 066: fiscalDocumentNewTitle
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get fiscalDocumentNewTitle;

  /// spec 066: fiscalDocumentNewCustomer
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get fiscalDocumentNewCustomer;

  /// spec 066: fiscalDocumentNewRecipient
  ///
  /// In en, this message translates to:
  /// **'Recipient RFC'**
  String get fiscalDocumentNewRecipient;

  /// spec 066: fiscalDocumentNewNoTaxpayers
  ///
  /// In en, this message translates to:
  /// **'This customer has no registered RFC.'**
  String get fiscalDocumentNewNoTaxpayers;

  /// spec 066: fiscalDocumentNewCreate
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get fiscalDocumentNewCreate;

  /// spec 066: fiscalDocumentHeaderTitle
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get fiscalDocumentHeaderTitle;

  /// spec 066: fiscalDocumentHeaderRecipient
  ///
  /// In en, this message translates to:
  /// **'Recipient (RFC)'**
  String get fiscalDocumentHeaderRecipient;

  /// spec 066: fiscalDocumentHeaderSeries
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get fiscalDocumentHeaderSeries;

  /// spec 066: fiscalDocumentHeaderUsage
  ///
  /// In en, this message translates to:
  /// **'CFDI use'**
  String get fiscalDocumentHeaderUsage;

  /// spec 066: fiscalDocumentHeaderTerms
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get fiscalDocumentHeaderTerms;

  /// spec 066: fiscalDocumentHeaderForm
  ///
  /// In en, this message translates to:
  /// **'Payment form'**
  String get fiscalDocumentHeaderForm;

  /// spec 066: fiscalDocumentHeaderIssued
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get fiscalDocumentHeaderIssued;

  /// spec 066: fiscalDocumentHeaderFacility
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get fiscalDocumentHeaderFacility;

  /// spec 066: fiscalDocumentHeaderReference
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get fiscalDocumentHeaderReference;

  /// spec 066: fiscalDocumentHeaderComment
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fiscalDocumentHeaderComment;

  /// spec 066: fiscalDocumentHeaderSeriesLocked
  ///
  /// In en, this message translates to:
  /// **'The series cannot change once the folio is assigned.'**
  String get fiscalDocumentHeaderSeriesLocked;

  /// spec 066: fiscalDocumentHeaderFormPpd
  ///
  /// In en, this message translates to:
  /// **'99 — To be defined'**
  String get fiscalDocumentHeaderFormPpd;

  /// spec 066: fiscalDocumentHeaderIssuedHelper
  ///
  /// In en, this message translates to:
  /// **'Empty: the confirmation date is used. If set, it must be within the last 72 hours.'**
  String get fiscalDocumentHeaderIssuedHelper;

  /// spec 066: fiscalDocumentHeaderIssuedOutOfRange
  ///
  /// In en, this message translates to:
  /// **'The date must be within the last 72 hours and not in the future.'**
  String get fiscalDocumentHeaderIssuedOutOfRange;

  /// spec 066: fiscalDocumentHeaderSaved
  ///
  /// In en, this message translates to:
  /// **'Header updated.'**
  String get fiscalDocumentHeaderSaved;

  /// spec 066: fiscalDocumentLineDialogTitle
  ///
  /// In en, this message translates to:
  /// **'Edit line'**
  String get fiscalDocumentLineDialogTitle;

  /// spec 066: fiscalDocumentLineFieldQuantity
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get fiscalDocumentLineFieldQuantity;

  /// spec 066: fiscalDocumentLineFieldPrice
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get fiscalDocumentLineFieldPrice;

  /// spec 066: fiscalDocumentLineFieldDiscount
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get fiscalDocumentLineFieldDiscount;

  /// spec 066: fiscalDocumentLineFieldTax
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get fiscalDocumentLineFieldTax;

  /// spec 066: fiscalDocumentLineFieldCode
  ///
  /// In en, this message translates to:
  /// **'Internal code'**
  String get fiscalDocumentLineFieldCode;

  /// spec 066: fiscalDocumentLineFieldName
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fiscalDocumentLineFieldName;

  /// spec 066: fiscalDocumentLineFieldComment
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get fiscalDocumentLineFieldComment;

  /// spec 066: fiscalDocumentLineNameHelper
  ///
  /// In en, this message translates to:
  /// **'If left blank, it resets to the product name.'**
  String get fiscalDocumentLineNameHelper;

  /// spec 066: fiscalDocumentLineQuantityInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0.'**
  String get fiscalDocumentLineQuantityInvalid;

  /// spec 066: fiscalDocumentLinePriceInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a price of 0 or more.'**
  String get fiscalDocumentLinePriceInvalid;

  /// spec 066: fiscalDocumentLineDiscountInvalid
  ///
  /// In en, this message translates to:
  /// **'Enter a discount between 0 and 100.'**
  String get fiscalDocumentLineDiscountInvalid;

  /// spec 066: fiscalDocumentLineCodeTooLong
  ///
  /// In en, this message translates to:
  /// **'The internal code can be up to 35 characters.'**
  String get fiscalDocumentLineCodeTooLong;

  /// spec 066: fiscalDocumentRemoveLineTitle
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get fiscalDocumentRemoveLineTitle;

  /// spec 066: fiscalDocumentRemoveLineBody
  ///
  /// In en, this message translates to:
  /// **'Remove this line from the invoice?'**
  String get fiscalDocumentRemoveLineBody;

  /// spec 066: fiscalDocumentRemoveAction
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get fiscalDocumentRemoveAction;

  /// spec 066: fiscalDocumentAddOrderTitle
  ///
  /// In en, this message translates to:
  /// **'Add order'**
  String get fiscalDocumentAddOrderTitle;

  /// spec 066: fiscalDocumentAddOrderSearch
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get fiscalDocumentAddOrderSearch;

  /// spec 066: fiscalDocumentAddOrderEmpty
  ///
  /// In en, this message translates to:
  /// **'The customer has no completed orders.'**
  String get fiscalDocumentAddOrderEmpty;

  /// spec 066: fiscalDocumentOrderAdded
  ///
  /// In en, this message translates to:
  /// **'The lines of order {folio} were added.'**
  String fiscalDocumentOrderAdded(String folio);

  /// spec 066: fiscalDocumentAddProductTitle
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get fiscalDocumentAddProductTitle;

  /// spec 066: fiscalDocumentAddProductPicker
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get fiscalDocumentAddProductPicker;

  /// spec 066: fiscalDocumentProductAdded
  ///
  /// In en, this message translates to:
  /// **'Product added.'**
  String get fiscalDocumentProductAdded;

  /// spec 066: fiscalDocumentAddRelationTitle
  ///
  /// In en, this message translates to:
  /// **'Add relation'**
  String get fiscalDocumentAddRelationTitle;

  /// spec 066: fiscalDocumentRelationType
  ///
  /// In en, this message translates to:
  /// **'Relation type'**
  String get fiscalDocumentRelationType;

  /// spec 066: fiscalDocumentRelationDocument
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get fiscalDocumentRelationDocument;

  /// spec 066: fiscalDocumentRelationSearch
  ///
  /// In en, this message translates to:
  /// **'Search documents'**
  String get fiscalDocumentRelationSearch;

  /// spec 066: fiscalDocumentRelationEmpty
  ///
  /// In en, this message translates to:
  /// **'There are no documents to relate.'**
  String get fiscalDocumentRelationEmpty;

  /// spec 066: fiscalDocumentRelationAdded
  ///
  /// In en, this message translates to:
  /// **'Relation added.'**
  String get fiscalDocumentRelationAdded;

  /// spec 066: fiscalDocumentRemoveRelationTitle
  ///
  /// In en, this message translates to:
  /// **'Remove relation'**
  String get fiscalDocumentRemoveRelationTitle;

  /// spec 066: fiscalDocumentRemoveRelationBody
  ///
  /// In en, this message translates to:
  /// **'Remove this related document?'**
  String get fiscalDocumentRemoveRelationBody;

  /// spec 066: fiscalDocumentConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Confirm invoice'**
  String get fiscalDocumentConfirmTitle;

  /// spec 066: fiscalDocumentConfirmBody
  ///
  /// In en, this message translates to:
  /// **'The next folio of series {series} will be assigned and the invoice will be sealed. After that it can only be reopened while it is not stamped.'**
  String fiscalDocumentConfirmBody(String series);

  /// spec 066: fiscalDocumentConfirmed
  ///
  /// In en, this message translates to:
  /// **'Invoice {folio} sealed.'**
  String fiscalDocumentConfirmed(String folio);

  /// spec 066: fiscalDocumentReopenTitle
  ///
  /// In en, this message translates to:
  /// **'Reopen invoice'**
  String get fiscalDocumentReopenTitle;

  /// spec 066: fiscalDocumentReopenBody
  ///
  /// In en, this message translates to:
  /// **'The invoice goes back to draft and keeps folio {folio}. The seal is discarded.'**
  String fiscalDocumentReopenBody(String folio);

  /// spec 066: fiscalDocumentReopened
  ///
  /// In en, this message translates to:
  /// **'Invoice {folio} reopened.'**
  String fiscalDocumentReopened(String folio);

  /// spec 066: fiscalDocumentXmlSaved
  ///
  /// In en, this message translates to:
  /// **'XML saved.'**
  String get fiscalDocumentXmlSaved;

  /// spec 066: fiscalDocumentUnknownResult
  ///
  /// In en, this message translates to:
  /// **'We do not know if it completed: the connection was lost. The document was refreshed.'**
  String get fiscalDocumentUnknownResult;

  /// mbe-api error code `fiscal_document.not_issued` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'This document has not been stamped yet, so it has no PDF or XML.'**
  String get apiErrorFiscalDocumentNotIssued;

  /// mbe-api error code `fiscal_document.version_not_printable` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'This document is CFDI version {version} and cannot be printed.'**
  String apiErrorFiscalDocumentVersionNotPrintable(String version);

  /// mbe-api error code `fiscal_document.not_stamped` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'This document is not stamped, so its PDF cannot be generated.'**
  String get apiErrorFiscalDocumentNotStamped;

  /// mbe-api error code `fiscal_document.xml_unavailable` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The XML of this document is not available.'**
  String get apiErrorFiscalDocumentXmlUnavailable;

  /// mbe-api error code `fiscal_document.issuer_has_no_series` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The issuer has no series for this type of document. Create one on the issuer and try again.'**
  String get apiErrorFiscalDocumentIssuerHasNoSeries;

  /// mbe-api error code `fiscal_document.series_not_of_type` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'Series {batch} is not for this type of document.'**
  String apiErrorFiscalDocumentSeriesNotOfType(String batch);

  /// mbe-api error code `fiscal_document.recipient_not_linked` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'That RFC is not registered on the customer.'**
  String get apiErrorFiscalDocumentRecipientNotLinked;

  /// mbe-api error code `fiscal_document.field_not_for_type` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'Some fields do not apply to this type of document.'**
  String get apiErrorFiscalDocumentFieldNotForType;

  /// mbe-api error code `fiscal_document.unknown_facility` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The chosen facility does not exist.'**
  String get apiErrorFiscalDocumentUnknownFacility;

  /// mbe-api error code `fiscal_document.series_locked` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The series cannot be changed because the invoice already has a folio.'**
  String get apiErrorFiscalDocumentSeriesLocked;

  /// mbe-api error code `fiscal_document.unknown_usage` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'CFDI use {usage} does not exist.'**
  String apiErrorFiscalDocumentUnknownUsage(String usage);

  /// mbe-api error code `fiscal_document.issue_date_out_of_range` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The issue date must be within the last 72 hours and not in the future.'**
  String get apiErrorFiscalDocumentIssueDateOutOfRange;

  /// mbe-api error code `fiscal_document.not_draft` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'This invoice is no longer a draft and cannot be changed.'**
  String get apiErrorFiscalDocumentNotDraft;

  /// mbe-api error code `fiscal_document.not_sealed` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'Only a sealed invoice that is not stamped yet can be reopened.'**
  String get apiErrorFiscalDocumentNotSealed;

  /// mbe-api error code `fiscal_document.type_not_supported` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'This type of document cannot be changed here.'**
  String get apiErrorFiscalDocumentTypeNotSupported;

  /// mbe-api error code `fiscal_document.order_not_invoiceable` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'That order cannot be invoiced: it must be completed and not cancelled.'**
  String get apiErrorFiscalDocumentOrderNotInvoiceable;

  /// mbe-api error code `fiscal_document.no_invoiceable_lines` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'That order has no lines left to invoice.'**
  String get apiErrorFiscalDocumentNoInvoiceableLines;

  /// mbe-api error code `fiscal_document.product_unpriced` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The product is not on the customer’s price list.'**
  String get apiErrorFiscalDocumentProductUnpriced;

  /// mbe-api error code `fiscal_document.quantity_exceeds_invoiceable` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'Only {remaining} are left to invoice on this order line.'**
  String apiErrorFiscalDocumentQuantityExceedsInvoiceable(String remaining);

  /// mbe-api error code `fiscal_document.quantity_exceeds_invoiceable` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'Line {line}: only {remaining} are left to invoice on this order line.'**
  String apiErrorFiscalDocumentQuantityExceedsInvoiceableLine(
    String line,
    String remaining,
  );

  /// mbe-api error code `fiscal_document.relation_not_allowed` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'That document cannot be related to this invoice: it must have the same issuer and recipient and the status the relation type requires.'**
  String get apiErrorFiscalDocumentRelationNotAllowed;

  /// mbe-api error code `fiscal_document.already_related` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'That document is already related to this invoice.'**
  String get apiErrorFiscalDocumentAlreadyRelated;

  /// mbe-api error code `fiscal_document.relation_types_mixed` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'An invoice can only have relations of one type.'**
  String get apiErrorFiscalDocumentRelationTypesMixed;

  /// mbe-api error code `fiscal_document.no_lines` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The invoice has no lines.'**
  String get apiErrorFiscalDocumentNoLines;

  /// mbe-api error code `fiscal_document.line_missing_sat_key` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'Line {line}: the SAT product key or unit is missing.'**
  String apiErrorFiscalDocumentLineMissingSatKey(String line);

  /// mbe-api error code `fiscal_document.line_quantity_not_positive` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'Line {line}: the quantity must be greater than 0.'**
  String apiErrorFiscalDocumentLineQuantityNotPositive(String line);

  /// mbe-api error code `fiscal_document.recipient_incomplete` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The recipient’s tax data is incomplete (name, regime or postal code).'**
  String get apiErrorFiscalDocumentRecipientIncomplete;

  /// mbe-api error code `fiscal_document.no_valid_certificate` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The issuer has no valid certificate to seal with.'**
  String get apiErrorFiscalDocumentNoValidCertificate;

  /// mbe-api error code `fiscal_document.series_missing` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'Series {batch} no longer exists.'**
  String apiErrorFiscalDocumentSeriesMissing(String batch);

  /// mbe-api error code `fiscal_document.certificate_cannot_sign` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The issuer’s certificate cannot sign this document.'**
  String get apiErrorFiscalDocumentCertificateCannotSign;

  /// mbe-api request-validation type `fiscal_document_tax_rate_invalid` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The VAT rate must be 16 %, 0 % or exempt.'**
  String get apiValidationFiscalDocumentTaxRateInvalid;

  /// mbe-api request-validation type `fiscal_document_payment_form_unknown` (spec 066)
  ///
  /// In en, this message translates to:
  /// **'The payment form is not valid.'**
  String get apiValidationFiscalDocumentPaymentFormUnknown;

  /// Record noun for the API resource name `fiscal_document_line` (spec 066), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{invoice line} other{invoice lines}}'**
  String apiResourceFiscalDocumentLine(int count);

  /// Grammatical gender of the noun for `fiscal_document_line` in Spanish (spec 066)
  ///
  /// In en, this message translates to:
  /// **'feminine'**
  String get apiResourceGenderFiscalDocumentLine;

  /// Record noun for the API resource name `fiscal_document_relation` (spec 066), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{related document} other{related documents}}'**
  String apiResourceFiscalDocumentRelation(int count);

  /// Grammatical gender of the noun for `fiscal_document_relation` in Spanish (spec 066)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderFiscalDocumentRelation;

  /// spec 066: fiscalDocumentAddOrderIntro
  ///
  /// In en, this message translates to:
  /// **'Completed orders of {customer}. Pick the one to invoice.'**
  String fiscalDocumentAddOrderIntro(String customer);

  /// spec 066: fiscalDocumentAddOrderColFolio
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get fiscalDocumentAddOrderColFolio;

  /// spec 066: fiscalDocumentAddOrderColDate
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fiscalDocumentAddOrderColDate;

  /// spec 066: fiscalDocumentAddOrderColTotal
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get fiscalDocumentAddOrderColTotal;

  /// spec 066: fiscalDocumentAddOrderLoadMore
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get fiscalDocumentAddOrderLoadMore;

  /// spec 066: fiscalDocumentHeaderIssuedOnConfirm
  ///
  /// In en, this message translates to:
  /// **'When confirmed'**
  String get fiscalDocumentHeaderIssuedOnConfirm;

  /// spec 066: fiscalDocumentHeaderPickIssued
  ///
  /// In en, this message translates to:
  /// **'Pick date and time'**
  String get fiscalDocumentHeaderPickIssued;

  /// spec 066: fiscalDocumentHeaderReferenceTooLong
  ///
  /// In en, this message translates to:
  /// **'The reference can be up to 25 characters.'**
  String get fiscalDocumentHeaderReferenceTooLong;

  /// spec 066: fiscalDocumentHeaderCommentTooLong
  ///
  /// In en, this message translates to:
  /// **'The notes can be up to 1000 characters.'**
  String get fiscalDocumentHeaderCommentTooLong;

  /// spec 066: fiscalDocumentHeaderTermsPue
  ///
  /// In en, this message translates to:
  /// **'PUE'**
  String get fiscalDocumentHeaderTermsPue;

  /// spec 066: fiscalDocumentHeaderTermsPpd
  ///
  /// In en, this message translates to:
  /// **'PPD'**
  String get fiscalDocumentHeaderTermsPpd;

  /// spec 066: fiscalDocumentLineEditTooltip
  ///
  /// In en, this message translates to:
  /// **'Edit line'**
  String get fiscalDocumentLineEditTooltip;

  /// spec 066: fiscalDocumentLineRemoveTooltip
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get fiscalDocumentLineRemoveTooltip;

  /// spec 066: fiscalDocumentRelationRemoveTooltip
  ///
  /// In en, this message translates to:
  /// **'Remove relation'**
  String get fiscalDocumentRelationRemoveTooltip;

  /// spec 067: navigation group
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventoryGroup;

  /// spec 067: navigation destination
  ///
  /// In en, this message translates to:
  /// **'Warehouse receipts'**
  String get navInventoryReceipts;

  /// spec 067: detail title, confirmed or cancelled
  ///
  /// In en, this message translates to:
  /// **'Receipt {folio}'**
  String inventoryReceiptTitle(String folio);

  /// spec 067: detail title of a draft
  ///
  /// In en, this message translates to:
  /// **'Receipt · Draft #{id}'**
  String inventoryReceiptTitleDraft(String id);

  /// spec 067: list folio of a draft
  ///
  /// In en, this message translates to:
  /// **'Draft #{id}'**
  String inventoryDocumentDraftFolio(String id);

  /// spec 067: status label
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get inventoryDocumentStatusDraft;

  /// spec 067: status label
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get inventoryDocumentStatusCompleted;

  /// spec 067: status label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get inventoryDocumentStatusCancelled;

  /// spec 067: list column
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get inventoryReceiptColFolio;

  /// spec 067: list column
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryReceiptColWarehouse;

  /// spec 067: list column
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get inventoryReceiptColFacility;

  /// spec 067: list column
  ///
  /// In en, this message translates to:
  /// **'Purchase order'**
  String get inventoryReceiptColPurchaseOrder;

  /// spec 067: list column
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryReceiptColStatus;

  /// spec 067: list column
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get inventoryReceiptColCreator;

  /// spec 067: list column
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get inventoryReceiptColDate;

  /// spec 067: filter facet
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryReceiptFacetStatus;

  /// spec 067: filter facet
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryReceiptFacetWarehouse;

  /// spec 067: filter facet, no selection
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inventoryReceiptFacetAll;

  /// spec 067: list empty state
  ///
  /// In en, this message translates to:
  /// **'There are no warehouse receipts'**
  String get inventoryReceiptEmpty;

  /// spec 067: list filtered-empty state
  ///
  /// In en, this message translates to:
  /// **'No receipt matches the filters.'**
  String get inventoryReceiptFilteredEmpty;

  /// spec 067: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryReceiptFactStatus;

  /// spec 067: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get inventoryReceiptFactFolio;

  /// spec 067: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryReceiptFactWarehouse;

  /// spec 067: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get inventoryReceiptFactFacility;

  /// spec 067: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Purchase order'**
  String get inventoryReceiptFactPurchaseOrder;

  /// spec 067: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get inventoryReceiptFactComment;

  /// spec 067: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get inventoryReceiptFactCreatedBy;

  /// spec 067: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Modified by'**
  String get inventoryReceiptFactModifiedBy;

  /// spec 067: detail lines section title
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get inventoryReceiptLinesTitle;

  /// spec 067: lines table header
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get inventoryReceiptLineColCode;

  /// spec 067: lines table header
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get inventoryReceiptLineColProduct;

  /// spec 067: lines table header
  ///
  /// In en, this message translates to:
  /// **'Quantity received'**
  String get inventoryReceiptLineColQuantity;

  /// spec 067: lines table header, linked receipts
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get inventoryReceiptLineColOrdered;

  /// spec 067: lines table header, linked receipts
  ///
  /// In en, this message translates to:
  /// **'Received in other receipts'**
  String get inventoryReceiptLineColElsewhere;

  /// spec 067: empty draft lines text
  ///
  /// In en, this message translates to:
  /// **'Add the products received.'**
  String get inventoryReceiptLinesEmpty;

  /// spec 067: shown when the user has no facility
  ///
  /// In en, this message translates to:
  /// **'Your user has no facility assigned.'**
  String get inventoryDocumentNoFacility;

  /// spec 067: list action
  ///
  /// In en, this message translates to:
  /// **'New receipt'**
  String get inventoryReceiptNewAction;

  /// spec 067: detail action
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get inventoryReceiptEditHeader;

  /// spec 067: detail action
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get inventoryReceiptAddProduct;

  /// spec 067: detail action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get inventoryReceiptConfirm;

  /// spec 067: detail action
  ///
  /// In en, this message translates to:
  /// **'Cancel receipt'**
  String get inventoryReceiptCancel;

  /// spec 067: detail action
  ///
  /// In en, this message translates to:
  /// **'Complementary receipt'**
  String get inventoryReceiptComplementary;

  /// spec 067: line row icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit quantity'**
  String get inventoryReceiptLineEditTooltip;

  /// spec 067: line row icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get inventoryReceiptLineRemoveTooltip;

  /// spec 067: new-receipt dialog title
  ///
  /// In en, this message translates to:
  /// **'New receipt'**
  String get inventoryReceiptNewTitle;

  /// spec 067: new-receipt dialog submit
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get inventoryReceiptNewSubmit;

  /// spec 067: header dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get inventoryReceiptEditHeaderTitle;

  /// spec 067: dialog field label
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryReceiptFieldWarehouse;

  /// spec 067: dialog field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get inventoryReceiptFieldComment;

  /// spec 067: dialog field label
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get inventoryReceiptFieldProduct;

  /// spec 067: dialog field label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get inventoryReceiptFieldQuantity;

  /// spec 067: read-only warehouse hint on a linked receipt
  ///
  /// In en, this message translates to:
  /// **'Fixed: purchase order'**
  String get inventoryReceiptWarehouseFixed;

  /// spec 067: add-line dialog title
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get inventoryReceiptAddProductTitle;

  /// spec 067: add-line dialog submit
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get inventoryReceiptAddProductSubmit;

  /// spec 067: line quantity dialog title
  ///
  /// In en, this message translates to:
  /// **'Line quantity'**
  String get inventoryReceiptLineQuantityTitle;

  /// spec 067: remove-line prompt title
  ///
  /// In en, this message translates to:
  /// **'Remove {product} from the receipt?'**
  String inventoryReceiptRemoveTitle(String product);

  /// spec 067: remove-line prompt body
  ///
  /// In en, this message translates to:
  /// **'The line is removed from the draft.'**
  String get inventoryReceiptRemoveBody;

  /// spec 067: remove-line prompt button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get inventoryReceiptRemoveAction;

  /// spec 067: confirm prompt title
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt'**
  String get inventoryReceiptConfirmTitle;

  /// spec 067: confirm prompt body (R11)
  ///
  /// In en, this message translates to:
  /// **'Confirming the receipt assigns a folio and adds the stock to the warehouse. It can\'t be edited afterwards.'**
  String get inventoryReceiptConfirmBody;

  /// spec 067: confirm prompt button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get inventoryReceiptConfirmAction;

  /// spec 067: prompt dismiss button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get inventoryReceiptBack;

  /// spec 067: cancel prompt title
  ///
  /// In en, this message translates to:
  /// **'Cancel receipt'**
  String get inventoryReceiptCancelTitle;

  /// spec 067: cancel prompt body for a draft (R11)
  ///
  /// In en, this message translates to:
  /// **'Cancelling the draft adds no stock to the warehouse.'**
  String get inventoryReceiptCancelDraftBody;

  /// spec 067: cancel prompt body for a confirmed receipt (R11)
  ///
  /// In en, this message translates to:
  /// **'Cancelling the receipt removes from the warehouse the stock it added.'**
  String get inventoryReceiptCancelCompletedBody;

  /// spec 067: cancel prompt button
  ///
  /// In en, this message translates to:
  /// **'Cancel receipt'**
  String get inventoryReceiptCancelAction;

  /// spec 067: over-receipt warning line
  ///
  /// In en, this message translates to:
  /// **'Over-received {code}: {excess} (received {received} of {ordered} ordered)'**
  String inventoryReceiptOverReceipt(
    String code,
    String excess,
    String received,
    String ordered,
  );

  /// spec 067: cost notice after confirm or cancel
  ///
  /// In en, this message translates to:
  /// **'Costs were updated with exceptions.'**
  String get inventoryReceiptCostNotice;

  /// spec 067: cost notice close tooltip
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get inventoryReceiptCostNoticeClose;

  /// mbe-api#322: purchase_cost.zero_price warning
  ///
  /// In en, this message translates to:
  /// **'{code} is priced at 0; its cost was not changed.'**
  String inventoryReceiptCostZeroPrice(String code);

  /// mbe-api#322: purchase_cost.not_restored warning
  ///
  /// In en, this message translates to:
  /// **'The cost of {code} was not restored: receipt {receipt} changed it since.'**
  String inventoryReceiptCostNotRestored(String code, String receipt);

  /// spec 067: product added to the insufficient-stock refusal
  ///
  /// In en, this message translates to:
  /// **'Product: {code}'**
  String inventoryReceiptRefusalProduct(String code);

  /// spec 067: error under a receipt quantity field that is not above 0
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0.'**
  String get inventoryReceiptQuantityInvalid;

  /// spec 067: button on the receipt not-found and load-failed views
  ///
  /// In en, this message translates to:
  /// **'Back to warehouse receipts'**
  String get inventoryReceiptBackToList;

  /// spec 068: navigation destination
  ///
  /// In en, this message translates to:
  /// **'Warehouse issues'**
  String get navInventoryIssues;

  /// spec 068: detail title, confirmed or cancelled
  ///
  /// In en, this message translates to:
  /// **'Issue {folio}'**
  String inventoryIssueTitle(String folio);

  /// spec 068: detail title of a draft
  ///
  /// In en, this message translates to:
  /// **'Issue · Draft #{id}'**
  String inventoryIssueTitleDraft(String id);

  /// spec 068: list column
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get inventoryIssueColFolio;

  /// spec 068: list column
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryIssueColWarehouse;

  /// spec 068: list column
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get inventoryIssueColFacility;

  /// spec 068: list column
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryIssueColStatus;

  /// spec 068: list column
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get inventoryIssueColCreator;

  /// spec 068: list column
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get inventoryIssueColDate;

  /// spec 068: filter facet
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryIssueFacetStatus;

  /// spec 068: filter facet
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryIssueFacetWarehouse;

  /// spec 068: filter facet: no value
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inventoryIssueFacetAll;

  /// spec 068: empty list
  ///
  /// In en, this message translates to:
  /// **'There are no warehouse issues'**
  String get inventoryIssueEmpty;

  /// spec 068: filtered-empty list
  ///
  /// In en, this message translates to:
  /// **'No issue matches the filters.'**
  String get inventoryIssueFilteredEmpty;

  /// spec 068: detail fact
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryIssueFactStatus;

  /// spec 068: detail fact
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get inventoryIssueFactFolio;

  /// spec 068: detail fact
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryIssueFactWarehouse;

  /// spec 068: detail fact
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get inventoryIssueFactFacility;

  /// spec 068: detail fact, only when the issue is linked to a supplier return
  ///
  /// In en, this message translates to:
  /// **'Supplier return #{id}'**
  String inventoryIssueFactSupplierReturn(String id);

  /// spec 068: detail fact
  ///
  /// In en, this message translates to:
  /// **'Reason / notes'**
  String get inventoryIssueFactComment;

  /// spec 068: detail fact
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get inventoryIssueFactCreatedBy;

  /// spec 068: detail fact
  ///
  /// In en, this message translates to:
  /// **'Modified by'**
  String get inventoryIssueFactModifiedBy;

  /// spec 068: lines table title
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get inventoryIssueLinesTitle;

  /// spec 068: lines table column
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get inventoryIssueLineColCode;

  /// spec 068: lines table column
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get inventoryIssueLineColProduct;

  /// spec 068: lines table column
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get inventoryIssueLineColQuantity;

  /// spec 068: empty draft lines
  ///
  /// In en, this message translates to:
  /// **'Add the products that leave the warehouse.'**
  String get inventoryIssueLinesEmpty;

  /// spec 068: list action
  ///
  /// In en, this message translates to:
  /// **'New issue'**
  String get inventoryIssueNewAction;

  /// spec 068: detail action
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get inventoryIssueEditHeader;

  /// spec 068: detail action
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get inventoryIssueAddProduct;

  /// spec 068: detail action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get inventoryIssueConfirm;

  /// spec 068: detail action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inventoryIssueCancel;

  /// spec 068: line action tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit quantity'**
  String get inventoryIssueLineEditTooltip;

  /// spec 068: line action tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get inventoryIssueLineRemoveTooltip;

  /// spec 068: new-issue dialog title
  ///
  /// In en, this message translates to:
  /// **'New issue'**
  String get inventoryIssueNewTitle;

  /// spec 068: new-issue dialog submit
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get inventoryIssueNewSubmit;

  /// spec 068: header dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get inventoryIssueEditHeaderTitle;

  /// spec 068: dialog field
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryIssueFieldWarehouse;

  /// spec 068: dialog field
  ///
  /// In en, this message translates to:
  /// **'Reason / notes'**
  String get inventoryIssueFieldComment;

  /// spec 068: hint of the notes field
  ///
  /// In en, this message translates to:
  /// **'e.g. shrinkage, damage, internal use'**
  String get inventoryIssueFieldCommentHint;

  /// spec 068: dialog field
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get inventoryIssueFieldProduct;

  /// spec 068: dialog field
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get inventoryIssueFieldQuantity;

  /// spec 068: add-line dialog title
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get inventoryIssueAddProductTitle;

  /// spec 068: add-line dialog submit
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get inventoryIssueAddProductSubmit;

  /// spec 068: quantity dialog title
  ///
  /// In en, this message translates to:
  /// **'Line quantity'**
  String get inventoryIssueLineQuantityTitle;

  /// spec 068: remove-line prompt title
  ///
  /// In en, this message translates to:
  /// **'Remove {product} from the issue?'**
  String inventoryIssueRemoveTitle(String product);

  /// spec 068: remove-line prompt body
  ///
  /// In en, this message translates to:
  /// **'The line is deleted from the draft.'**
  String get inventoryIssueRemoveBody;

  /// spec 068: remove-line prompt action
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get inventoryIssueRemoveAction;

  /// spec 068: confirm prompt title
  ///
  /// In en, this message translates to:
  /// **'Confirm issue'**
  String get inventoryIssueConfirmTitle;

  /// spec 068: confirm prompt body
  ///
  /// In en, this message translates to:
  /// **'Confirming assigns a folio and takes the stock out of {warehouse}. It can\'t be edited afterwards.'**
  String inventoryIssueConfirmBody(String warehouse);

  /// spec 068: confirm prompt action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get inventoryIssueConfirmAction;

  /// spec 068: cancel prompt title
  ///
  /// In en, this message translates to:
  /// **'Cancel issue'**
  String get inventoryIssueCancelTitle;

  /// spec 068: cancel prompt body for a draft
  ///
  /// In en, this message translates to:
  /// **'Cancel the draft'**
  String get inventoryIssueCancelDraftBody;

  /// spec 068: cancel prompt body for a confirmed issue
  ///
  /// In en, this message translates to:
  /// **'Cancelling issue {folio} puts back into {warehouse} the stock it took out.'**
  String inventoryIssueCancelCompletedBody(String folio, String warehouse);

  /// spec 068: cancel prompt action
  ///
  /// In en, this message translates to:
  /// **'Cancel issue'**
  String get inventoryIssueCancelAction;

  /// spec 068: product and warehouse added to the insufficient-stock refusal
  ///
  /// In en, this message translates to:
  /// **'Product: {code} · Warehouse: {warehouse}'**
  String inventoryIssueRefusalProductWarehouse(String code, String warehouse);

  /// spec 068: error under an issue quantity field that is not above 0
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0.'**
  String get inventoryIssueQuantityInvalid;

  /// spec 068: button on the issue not-found and load-failed views
  ///
  /// In en, this message translates to:
  /// **'Back to warehouse issues'**
  String get inventoryIssueBackToList;

  /// spec 068: prompt dismiss button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get inventoryIssueBack;

  /// spec 067: mbe-api error code `inventory_receipt.warehouse_fixed`
  ///
  /// In en, this message translates to:
  /// **'A purchase order\'s receipt can\'t move to another warehouse.'**
  String get apiErrorInventoryReceiptWarehouseFixed;

  /// spec 067: mbe-api error code `inventory_receipt.complementary_unavailable`, reason no_purchase_order
  ///
  /// In en, this message translates to:
  /// **'The receipt isn\'t linked to a purchase order.'**
  String get apiErrorInventoryReceiptComplementaryNoPurchaseOrder;

  /// spec 067: mbe-api error code `inventory_receipt.complementary_unavailable`, reason purchase_order_cancelled
  ///
  /// In en, this message translates to:
  /// **'The purchase order is cancelled.'**
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderCancelled;

  /// spec 067: mbe-api error code `inventory_receipt.complementary_unavailable`, reason purchase_order_not_completed
  ///
  /// In en, this message translates to:
  /// **'The purchase order isn\'t completed yet.'**
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderNotCompleted;

  /// spec 067: mbe-api error code `inventory_receipt.complementary_unavailable`, reason purchase_order_fully_received
  ///
  /// In en, this message translates to:
  /// **'The purchase order was already fully received in this warehouse.'**
  String get apiErrorInventoryReceiptComplementaryPurchaseOrderFullyReceived;

  /// spec 067: mbe-api error code `inventory_receipt.complementary_unavailable`, unknown or missing reason
  ///
  /// In en, this message translates to:
  /// **'No complementary receipt can be created for this receipt.'**
  String get apiErrorInventoryReceiptComplementaryUnavailable;

  /// spec 067: mbe-api error code `inventory_document.insufficient_stock`
  ///
  /// In en, this message translates to:
  /// **'Not enough stock: {requested} required, {available} available.'**
  String apiErrorInventoryDocumentInsufficientStock(
    String requested,
    String available,
  );

  /// spec 067: mbe-api error code `inventory_document.no_lines`
  ///
  /// In en, this message translates to:
  /// **'{gender, select, feminine{The {resource} has no lines.} other{The {resource} has no lines.}}'**
  String apiErrorInventoryDocumentNoLines(String gender, String resource);

  /// spec 067: mbe-api error code `inventory_document.line_without_quantity`
  ///
  /// In en, this message translates to:
  /// **'Line {product} has no quantity.'**
  String apiErrorInventoryDocumentLineWithoutQuantity(String product);

  /// spec 067: mbe-api error code `inventory_document.already_cancelled`
  ///
  /// In en, this message translates to:
  /// **'{gender, select, feminine{The {resource} is already cancelled.} other{The {resource} is already cancelled.}}'**
  String apiErrorInventoryDocumentAlreadyCancelled(
    String gender,
    String resource,
  );

  /// spec 067: mbe-api error code `product.not_stockable`
  ///
  /// In en, this message translates to:
  /// **'Product {product} isn\'t stockable.'**
  String apiErrorProductNotStockable(String product);

  /// spec 067: mbe-api error code `facility.no_in_transit_location`
  ///
  /// In en, this message translates to:
  /// **'The facility has no in-transit location configured.'**
  String get apiErrorFacilityNoInTransitLocation;

  /// spec 067: mbe-api error code `status_filter.unsupported`
  ///
  /// In en, this message translates to:
  /// **'The status filter isn\'t valid.'**
  String get apiErrorStatusFilterUnsupported;

  /// spec 069: mbe-api error code `inventory_transfer.same_warehouse`
  ///
  /// In en, this message translates to:
  /// **'The source and destination warehouses must be different.'**
  String get apiErrorInventoryTransferSameWarehouse;

  /// spec 069: mbe-api error code `inventory_transfer.not_in_transit`
  ///
  /// In en, this message translates to:
  /// **'The transfer isn\'t in transit.'**
  String get apiErrorInventoryTransferNotInTransit;

  /// spec 069: mbe-api error code `inventory_transfer.over_received`
  ///
  /// In en, this message translates to:
  /// **'{product_code}: trying to receive {received} but only {outstanding} are outstanding.'**
  String apiErrorInventoryTransferOverReceived(
    String product_code,
    String received,
    String outstanding,
  );

  /// spec 069: mbe-api error code `inventory_transfer.line_repeated`
  ///
  /// In en, this message translates to:
  /// **'A line is being received more than once.'**
  String get apiErrorInventoryTransferLineRepeated;

  /// spec 069: mbe-api error code `sales_order.not_confirmed`
  ///
  /// In en, this message translates to:
  /// **'The order isn\'t confirmed or is cancelled.'**
  String get apiErrorSalesOrderNotConfirmed;

  /// spec 069: mbe-api request-validation type `inventory_transfer_duplicate_line`
  ///
  /// In en, this message translates to:
  /// **'A line is being received more than once.'**
  String get apiValidationInventoryTransferDuplicateLine;

  /// spec 069: navigation destination
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get navInventoryTransfers;

  /// spec 069: detail title, dispatched or cancelled
  ///
  /// In en, this message translates to:
  /// **'Transfer {folio}'**
  String inventoryTransferTitle(String folio);

  /// spec 069: detail title of a draft
  ///
  /// In en, this message translates to:
  /// **'Transfer · Draft #{id}'**
  String inventoryTransferTitleDraft(String id);

  /// spec 069: status label (masculine in es, so not the shared inventoryDocumentStatusDraft)
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get inventoryTransferStatusDraft;

  /// spec 069: status label
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get inventoryTransferStatusInTransit;

  /// spec 069: status label
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get inventoryTransferStatusReceived;

  /// spec 069: status label (masculine in es: Cancelado)
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get inventoryTransferStatusCancelled;

  /// spec 069: list column
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get inventoryTransferColFolio;

  /// spec 069: list column
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get inventoryTransferColSource;

  /// spec 069: list column
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get inventoryTransferColDestination;

  /// spec 069: list column
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get inventoryTransferColFacility;

  /// spec 069: list column
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryTransferColStatus;

  /// spec 069: list column
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get inventoryTransferColCreator;

  /// spec 069: list column
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get inventoryTransferColDate;

  /// spec 069: filter facet
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryTransferFacetStatus;

  /// spec 069: filter facet, matches either end
  ///
  /// In en, this message translates to:
  /// **'Warehouse (source or destination)'**
  String get inventoryTransferFacetWarehouse;

  /// spec 069: filter facet: no value
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inventoryTransferFacetAll;

  /// spec 069: empty list
  ///
  /// In en, this message translates to:
  /// **'There are no transfers'**
  String get inventoryTransferEmpty;

  /// spec 069: filtered-empty list
  ///
  /// In en, this message translates to:
  /// **'No transfer matches the filters.'**
  String get inventoryTransferFilteredEmpty;

  /// spec 069: list action opening the in-transit view
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get inventoryTransferInTransitAction;

  /// spec 069: list action
  ///
  /// In en, this message translates to:
  /// **'New transfer'**
  String get inventoryTransferNewAction;

  /// spec 069: detail fact
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryTransferFactStatus;

  /// spec 069: detail fact
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get inventoryTransferFactFolio;

  /// spec 069: detail fact
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get inventoryTransferFactSource;

  /// spec 069: detail fact
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get inventoryTransferFactDestination;

  /// spec 069: detail fact
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get inventoryTransferFactFacility;

  /// spec 069: detail fact
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get inventoryTransferFactNotes;

  /// spec 069: detail fact
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get inventoryTransferFactCreatedBy;

  /// spec 069: detail fact
  ///
  /// In en, this message translates to:
  /// **'Modified by'**
  String get inventoryTransferFactModifiedBy;

  /// spec 069: lines table title
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get inventoryTransferLinesTitle;

  /// spec 069: lines table column
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get inventoryTransferLineColCode;

  /// spec 069: lines table column
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get inventoryTransferLineColProduct;

  /// spec 069: lines table column of a draft
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get inventoryTransferLineColQuantity;

  /// spec 069: lines table column of a dispatched transfer
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get inventoryTransferLineColSent;

  /// spec 069: lines table column of a dispatched transfer
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get inventoryTransferLineColReceived;

  /// spec 069: lines table column of a dispatched transfer
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get inventoryTransferLineColOutstanding;

  /// spec 069: empty draft lines
  ///
  /// In en, this message translates to:
  /// **'Add the products to be transferred.'**
  String get inventoryTransferLinesEmpty;

  /// spec 069: detail action
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get inventoryTransferEditHeader;

  /// spec 069: detail action
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get inventoryTransferAddProduct;

  /// spec 069: detail action
  ///
  /// In en, this message translates to:
  /// **'Add from order'**
  String get inventoryTransferAddFromOrder;

  /// spec 069: detail action
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get inventoryTransferDispatch;

  /// spec 069: detail action
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get inventoryTransferReceive;

  /// spec 069: detail action
  ///
  /// In en, this message translates to:
  /// **'Close outstanding'**
  String get inventoryTransferClose;

  /// spec 069: detail action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inventoryTransferCancel;

  /// spec 069: line action tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit quantity'**
  String get inventoryTransferLineEditTooltip;

  /// spec 069: line action tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get inventoryTransferLineRemoveTooltip;

  /// spec 069: new-transfer dialog title
  ///
  /// In en, this message translates to:
  /// **'New transfer'**
  String get inventoryTransferNewTitle;

  /// spec 069: new-transfer dialog submit
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get inventoryTransferNewSubmit;

  /// spec 069: header dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get inventoryTransferEditHeaderTitle;

  /// spec 069: dialog field
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get inventoryTransferFieldSource;

  /// spec 069: dialog field
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get inventoryTransferFieldDestination;

  /// spec 069: dialog field
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get inventoryTransferFieldNotes;

  /// spec 069: dialog field
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get inventoryTransferFieldProduct;

  /// spec 069: dialog field
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get inventoryTransferFieldQuantity;

  /// spec 069: add-line dialog title
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get inventoryTransferAddProductTitle;

  /// spec 069: add-line dialog submit
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get inventoryTransferAddProductSubmit;

  /// spec 069: quantity dialog title
  ///
  /// In en, this message translates to:
  /// **'Line quantity'**
  String get inventoryTransferLineQuantityTitle;

  /// spec 069: error under a quantity field that is not above 0
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0.'**
  String get inventoryTransferQuantityInvalid;

  /// spec 069: remove-line prompt title
  ///
  /// In en, this message translates to:
  /// **'Remove {product} from the transfer?'**
  String inventoryTransferRemoveTitle(String product);

  /// spec 069: remove-line prompt body
  ///
  /// In en, this message translates to:
  /// **'The line is deleted from the draft.'**
  String get inventoryTransferRemoveBody;

  /// spec 069: remove-line prompt action
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get inventoryTransferRemoveAction;

  /// spec 069: dispatch prompt title
  ///
  /// In en, this message translates to:
  /// **'Dispatch transfer'**
  String get inventoryTransferDispatchTitle;

  /// spec 069: dispatch prompt body
  ///
  /// In en, this message translates to:
  /// **'Dispatching assigns a folio and takes the stock out of {source}. It stays in transit until {destination} receives it. It can\'t be edited afterwards.'**
  String inventoryTransferDispatchBody(String source, String destination);

  /// spec 069: dispatch prompt action
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get inventoryTransferDispatchAction;

  /// spec 069: close prompt title
  ///
  /// In en, this message translates to:
  /// **'Close outstanding'**
  String get inventoryTransferCloseTitle;

  /// spec 069: close prompt body
  ///
  /// In en, this message translates to:
  /// **'What is outstanding ({count} lines) goes back to {source} and the transfer becomes Received. If it was lost, record it afterwards with a warehouse issue.'**
  String inventoryTransferCloseBody(int count, String source);

  /// spec 069: close prompt action
  ///
  /// In en, this message translates to:
  /// **'Close outstanding'**
  String get inventoryTransferCloseAction;

  /// spec 069: cancel prompt title
  ///
  /// In en, this message translates to:
  /// **'Cancel transfer'**
  String get inventoryTransferCancelTitle;

  /// spec 069: cancel prompt body for a draft
  ///
  /// In en, this message translates to:
  /// **'Cancel the draft'**
  String get inventoryTransferCancelDraftBody;

  /// spec 069: cancel prompt body for a dispatched transfer with nothing received
  ///
  /// In en, this message translates to:
  /// **'Cancelling transfer {folio} puts back into {source} what is in transit.'**
  String inventoryTransferCancelDispatchedBody(String folio, String source);

  /// spec 069: cancel prompt body for a dispatched transfer with some quantity received
  ///
  /// In en, this message translates to:
  /// **'Cancelling transfer {folio} puts back into {source} what is in transit and what {destination} already received.'**
  String inventoryTransferCancelDispatchedReceivedBody(
    String folio,
    String source,
    String destination,
  );

  /// spec 069: cancel prompt action
  ///
  /// In en, this message translates to:
  /// **'Cancel transfer'**
  String get inventoryTransferCancelAction;

  /// spec 069: prompt dismiss button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get inventoryTransferBack;

  /// spec 069: product and warehouse added to the insufficient-stock refusal
  ///
  /// In en, this message translates to:
  /// **'Product: {code} · Warehouse: {warehouse}'**
  String inventoryTransferRefusalProductWarehouse(
    String code,
    String warehouse,
  );

  /// spec 069: button on the transfer not-found and load-failed views
  ///
  /// In en, this message translates to:
  /// **'Back to transfers'**
  String get inventoryTransferBackToList;

  /// spec 069: receive dialog title
  ///
  /// In en, this message translates to:
  /// **'Receive transfer {folio}'**
  String inventoryTransferReceiveTitle(String folio);

  /// spec 069: receive dialog hint
  ///
  /// In en, this message translates to:
  /// **'Leave 0 for what didn\'t arrive. What is outstanding can be received later.'**
  String get inventoryTransferReceiveHint;

  /// spec 069: receive dialog column and field label
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get inventoryTransferReceiveColReceive;

  /// spec 069: receive dialog hint of the quantity field
  ///
  /// In en, this message translates to:
  /// **'Maximum {outstanding}'**
  String inventoryTransferReceiveMax(String outstanding);

  /// spec 069: receive dialog submit
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get inventoryTransferReceiveSubmit;

  /// spec 069: receive dialog field error for an empty, unreadable or negative quantity
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity of 0 or more.'**
  String get inventoryTransferReceiveInvalid;

  /// spec 069: add-from-order dialog title
  ///
  /// In en, this message translates to:
  /// **'Add from order'**
  String get inventoryTransferFromOrderTitle;

  /// spec 069: add-from-order dialog field
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get inventoryTransferFromOrderField;

  /// spec 069: add-from-order picker option
  ///
  /// In en, this message translates to:
  /// **'{folio} · {customer} · {date}'**
  String inventoryTransferFromOrderOption(
    String folio,
    String customer,
    String date,
  );

  /// spec 069: add-from-order dialog submit
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get inventoryTransferFromOrderSubmit;

  /// spec 069: snackbar after adding lines from a sales order
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 product to the transfer.} other{Added {count} products to the transfer.}} Products already on it were left unchanged.'**
  String inventoryTransferFromOrderAdded(int count);

  /// spec 069: snackbar when the order added nothing
  ///
  /// In en, this message translates to:
  /// **'The order\'s products were already on the transfer.'**
  String get inventoryTransferFromOrderNone;

  /// spec 069: in-transit screen title for an administrator
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get inventoryTransferInTransitTitle;

  /// spec 069: in-transit screen title with the facility name
  ///
  /// In en, this message translates to:
  /// **'In transit · {facility}'**
  String inventoryTransferInTransitTitleFacility(String facility);

  /// spec 069: in-transit facility picker label
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get inventoryTransferInTransitFacilityField;

  /// spec 069: in-transit facility reset
  ///
  /// In en, this message translates to:
  /// **'My facility'**
  String get inventoryTransferInTransitMyFacility;

  /// spec 069: in-transit prompt for an administrator with no facility
  ///
  /// In en, this message translates to:
  /// **'Select a facility.'**
  String get inventoryTransferInTransitSelectFacility;

  /// spec 069: in-transit table title
  ///
  /// In en, this message translates to:
  /// **'By product'**
  String get inventoryTransferInTransitByProduct;

  /// spec 069: in-transit table title
  ///
  /// In en, this message translates to:
  /// **'By transfer'**
  String get inventoryTransferInTransitByTransfer;

  /// spec 069: in-transit empty state
  ///
  /// In en, this message translates to:
  /// **'There is no stock in transit.'**
  String get inventoryTransferInTransitEmpty;

  /// spec 070: inventory_count.batch_invalid
  ///
  /// In en, this message translates to:
  /// **'Some products in the list cannot be recorded. Check the marked rows.'**
  String get apiErrorInventoryCountBatchInvalid;

  /// spec 070: inventory_count.confirmed_cannot_cancel
  ///
  /// In en, this message translates to:
  /// **'A confirmed count cannot be cancelled. Correct it with a new count.'**
  String get apiErrorInventoryCountConfirmedCannotCancel;

  /// spec 070: inventory_count_line.product_unknown
  ///
  /// In en, this message translates to:
  /// **'The product does not exist.'**
  String get apiErrorInventoryCountLineProductUnknown;

  /// spec 070: inventory_count_line.not_stockable
  ///
  /// In en, this message translates to:
  /// **'The product is not stockable.'**
  String get apiErrorInventoryCountLineNotStockable;

  /// spec 070: inventory_count_line.repeated
  ///
  /// In en, this message translates to:
  /// **'The product is repeated in the list.'**
  String get apiErrorInventoryCountLineRepeated;

  /// spec 070: inventory_count_line.product_reference
  ///
  /// In en, this message translates to:
  /// **'Name the product by its id or by its code, not both.'**
  String get apiErrorInventoryCountLineProductReference;

  /// Record noun for the API resource name `inventory_count` (spec 070), singular or plural
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{count} other{counts}}'**
  String apiResourceInventoryCount(int count);

  /// Grammatical gender of the noun for `inventory_count` in Spanish: `feminine` or `masculine` (spec 070)
  ///
  /// In en, this message translates to:
  /// **'masculine'**
  String get apiResourceGenderInventoryCount;

  /// spec 070: navigation destination
  ///
  /// In en, this message translates to:
  /// **'Physical counts'**
  String get navInventoryCounts;

  /// spec 070: status label
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get inventoryCountStatusDraft;

  /// spec 070: status label
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get inventoryCountStatusCompleted;

  /// spec 070: status label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get inventoryCountStatusCancelled;

  /// spec 070: list column
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get inventoryCountColFolio;

  /// spec 070: list column
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryCountColWarehouse;

  /// spec 070: list column
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get inventoryCountColFacility;

  /// spec 070: list column
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryCountColStatus;

  /// spec 070: list column
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get inventoryCountColCreatedBy;

  /// spec 070: list column
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get inventoryCountColDate;

  /// spec 070: filter facet
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get inventoryCountFilterStatus;

  /// spec 070: filter facet
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryCountFilterWarehouse;

  /// spec 070: filter facet: no selection
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inventoryCountFilterAll;

  /// spec 070: list empty state
  ///
  /// In en, this message translates to:
  /// **'There are no physical counts'**
  String get inventoryCountListEmpty;

  /// spec 070: list folio of a count with no serial
  ///
  /// In en, this message translates to:
  /// **'Draft #{id}'**
  String inventoryCountDraftFolio(String id);

  /// spec 070: detail title of a draft
  ///
  /// In en, this message translates to:
  /// **'Count · Draft #{id}'**
  String inventoryCountTitleDraft(String id);

  /// spec 070: detail title, completed
  ///
  /// In en, this message translates to:
  /// **'Count {folio}'**
  String inventoryCountTitle(String folio);

  /// spec 070: detail fact label
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get inventoryCountFactComment;

  /// spec 070: detail fact label: number of lines
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get inventoryCountFactLines;

  /// spec 070: lines table column
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get inventoryCountLineColCode;

  /// spec 070: lines table column
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get inventoryCountLineColProduct;

  /// spec 070: lines table column
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get inventoryCountLineColCounted;

  /// spec 070: lines table column, completed only
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get inventoryCountLineColExpected;

  /// spec 070: lines table column, completed only
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get inventoryCountLineColDifference;

  /// spec 070: line search hint
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get inventoryCountLinesSearchHint;

  /// spec 070: empty draft text
  ///
  /// In en, this message translates to:
  /// **'Record what you counted. Expected stock is shown on confirm.'**
  String get inventoryCountDraftEmpty;

  /// spec 070: quick entry label
  ///
  /// In en, this message translates to:
  /// **'Quick entry'**
  String get inventoryCountQuickEntryTitle;

  /// spec 070: quick entry field
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get inventoryCountQuickEntryCode;

  /// spec 070: quick entry field
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get inventoryCountQuickEntryQuantity;

  /// spec 070: quick entry button
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get inventoryCountQuickEntrySubmit;

  /// spec 070: quick entry feedback, new line
  ///
  /// In en, this message translates to:
  /// **'{code} {name}: {newQty}'**
  String inventoryCountQuickEntryFeedback(
    String code,
    String name,
    String newQty,
  );

  /// spec 070: quick entry feedback, replaced quantity
  ///
  /// In en, this message translates to:
  /// **'{code} {name}: {oldQty} → {newQty} (replaced)'**
  String inventoryCountQuickEntryFeedbackReplaced(
    String code,
    String name,
    String oldQty,
    String newQty,
  );

  /// spec 070: action
  ///
  /// In en, this message translates to:
  /// **'New count'**
  String get inventoryCountActionNew;

  /// spec 070: action
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get inventoryCountActionEditHeader;

  /// spec 070: action
  ///
  /// In en, this message translates to:
  /// **'Paste list'**
  String get inventoryCountActionPaste;

  /// spec 070: action
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get inventoryCountActionAddProduct;

  /// spec 070: action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get inventoryCountActionConfirm;

  /// spec 070: action: cancel the draft
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inventoryCountActionCancel;

  /// spec 070: dialog title
  ///
  /// In en, this message translates to:
  /// **'New count'**
  String get inventoryCountDialogNewTitle;

  /// spec 070: dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit header'**
  String get inventoryCountDialogEditTitle;

  /// spec 070: dialog title
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get inventoryCountDialogAddTitle;

  /// spec 070: dialog title
  ///
  /// In en, this message translates to:
  /// **'Counted quantity'**
  String get inventoryCountDialogQuantityTitle;

  /// spec 070: dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get inventoryCountDialogRemoveTitle;

  /// spec 070: remove-line prompt
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the count?'**
  String inventoryCountDialogRemoveBody(String name);

  /// spec 070: dialog title
  ///
  /// In en, this message translates to:
  /// **'Paste list'**
  String get inventoryCountDialogPasteTitle;

  /// spec 070: dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm count'**
  String get inventoryCountDialogConfirmTitle;

  /// spec 070: dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel draft'**
  String get inventoryCountDialogCancelTitle;

  /// spec 070: field label
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get inventoryCountFieldWarehouse;

  /// spec 070: field label
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get inventoryCountFieldComment;

  /// spec 070: field label
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get inventoryCountFieldProduct;

  /// spec 070: field label
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get inventoryCountFieldCounted;

  /// spec 070: dialog button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get inventoryCountDialogCreate;

  /// spec 070: dialog button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get inventoryCountDialogSave;

  /// spec 070: dialog button
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get inventoryCountDialogRecord;

  /// spec 070: dialog button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get inventoryCountDialogBack;

  /// spec 070: dialog button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get inventoryCountDialogClose;

  /// spec 070: dialog button
  ///
  /// In en, this message translates to:
  /// **'Cancel draft'**
  String get inventoryCountDialogCancelDraft;

  /// spec 070: add-line dialog note
  ///
  /// In en, this message translates to:
  /// **'Already counted: {qty}. It will be replaced.'**
  String inventoryCountReplaceNote(String qty);

  /// spec 070: confirm prompt
  ///
  /// In en, this message translates to:
  /// **'On confirm, the stock of {warehouse} is set to the counted quantities and a folio is assigned. A confirmed count cannot be cancelled: correct it with a new count.'**
  String inventoryCountConfirmBody(String warehouse);

  /// spec 070: confirm checkbox
  ///
  /// In en, this message translates to:
  /// **'Count as 0 the products with stock that are not in this count'**
  String get inventoryCountConfirmIncludeUncounted;

  /// spec 070: cancel-draft prompt
  ///
  /// In en, this message translates to:
  /// **'Cancel draft #{id}. No stock is changed.'**
  String inventoryCountCancelBody(String id);

  /// spec 070: paste dialog instructions
  ///
  /// In en, this message translates to:
  /// **'Paste two columns from your spreadsheet: code and quantity.'**
  String get inventoryCountPasteInstructions;

  /// spec 070: paste dialog live summary
  ///
  /// In en, this message translates to:
  /// **'{n} rows read · {m} with problems'**
  String inventoryCountPasteSummary(String n, String m);

  /// spec 070: paste dialog problem line
  ///
  /// In en, this message translates to:
  /// **'Row {row}: {reason}'**
  String inventoryCountPasteProblemRow(int row, String reason);

  /// spec 070: paste problem: wrong field count
  ///
  /// In en, this message translates to:
  /// **'separate the code and the quantity'**
  String get inventoryCountPasteProblemFieldCount;

  /// spec 070: paste problem
  ///
  /// In en, this message translates to:
  /// **'the code is missing'**
  String get inventoryCountPasteProblemMissingCode;

  /// spec 070: paste problem
  ///
  /// In en, this message translates to:
  /// **'the quantity is not a number'**
  String get inventoryCountPasteProblemNotANumber;

  /// spec 070: paste problem
  ///
  /// In en, this message translates to:
  /// **'the quantity is negative'**
  String get inventoryCountPasteProblemNegative;

  /// spec 070: paste problem
  ///
  /// In en, this message translates to:
  /// **'the quantity has more than 4 decimals'**
  String get inventoryCountPasteProblemTooManyDecimals;

  /// spec 070: paste problem
  ///
  /// In en, this message translates to:
  /// **'the code is repeated'**
  String get inventoryCountPasteProblemRepeatedCode;

  /// spec 070: paste dialog button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get inventoryCountPasteSend;

  /// spec 070: paste dialog progress title
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get inventoryCountPasteSending;

  /// spec 070: paste dialog progress count
  ///
  /// In en, this message translates to:
  /// **'{sent} of {total}'**
  String inventoryCountPasteProgress(String sent, String total);

  /// spec 070: paste dialog batch progress
  ///
  /// In en, this message translates to:
  /// **'Batch {k} of {n}'**
  String inventoryCountPasteBatch(int k, int n);

  /// spec 070: paste dialog stop text
  ///
  /// In en, this message translates to:
  /// **'Sending stopped. {applied} of {total} rows were applied.'**
  String inventoryCountPasteStopped(String applied, String total);

  /// spec 070: paste dialog rejected heading
  ///
  /// In en, this message translates to:
  /// **'Codes rejected in batch {k}:'**
  String inventoryCountPasteRejectedHeading(int k);

  /// spec 070: paste dialog rejected code line
  ///
  /// In en, this message translates to:
  /// **'{code}  {reason} (row {row})'**
  String inventoryCountPasteRejectedLine(String code, String reason, int row);

  /// spec 070: paste dialog safe-to-repaste note
  ///
  /// In en, this message translates to:
  /// **'Fix your list and paste it again: quantities are replaced, not added.'**
  String get inventoryCountPasteSafeNote;

  /// spec 070: warnings band title
  ///
  /// In en, this message translates to:
  /// **'Count confirmed with warnings'**
  String get inventoryCountWarningsTitle;

  /// spec 070: warnings band heading
  ///
  /// In en, this message translates to:
  /// **'Counted below what is reserved:'**
  String get inventoryCountWarningsNegativeHeading;

  /// spec 070: warnings band heading
  ///
  /// In en, this message translates to:
  /// **'Also corrected by another count of this warehouse:'**
  String get inventoryCountWarningsCorrectedHeading;

  /// spec 070: warnings band negative-available line
  ///
  /// In en, this message translates to:
  /// **'{code}  counted {counted} · reserved {reserved} · available {available}'**
  String inventoryCountWarningsNegativeLine(
    String code,
    String counted,
    String reserved,
    String available,
  );

  /// spec 070: warnings band corrected-by-other line
  ///
  /// In en, this message translates to:
  /// **'{code}  count {serial}'**
  String inventoryCountWarningsCorrectedLine(String code, String serial);

  /// spec 070: warnings band dismiss tooltip
  ///
  /// In en, this message translates to:
  /// **'Dismiss warnings'**
  String get inventoryCountWarningsDismiss;

  /// spec 070: counted quantity validation
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity of 0 or more, with up to 4 decimals.'**
  String get inventoryCountQuantityInvalid;

  /// spec 070: line edit icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit quantity'**
  String get inventoryCountLineEditTooltip;

  /// spec 070: line remove icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get inventoryCountLineRemoveTooltip;

  /// spec 070: remove-line prompt button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get inventoryCountRemoveAction;

  /// spec 070: not-found back button
  ///
  /// In en, this message translates to:
  /// **'Back to physical counts'**
  String get inventoryCountBackToList;

  /// spec 070: detail fact
  ///
  /// In en, this message translates to:
  /// **'Modified by'**
  String get inventoryCountFactModifiedBy;
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
