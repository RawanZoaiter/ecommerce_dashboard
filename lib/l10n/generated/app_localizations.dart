import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Commerce Admin'**
  String get appTitle;

  /// No description provided for @appTitleShort.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get appTitleShort;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get actionViewAll;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get commonActions;

  /// No description provided for @commonCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get commonCreatedAt;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get commonOptional;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Once data arrives it will show up on this screen.'**
  String get emptyMessage;

  /// No description provided for @emptyNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get emptyNoResultsTitle;

  /// No description provided for @emptyNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing or clearing the filters.'**
  String get emptyNoResultsMessage;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get errorGeneric;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errorNotFound;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get errorForbidden;

  /// No description provided for @errorUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errorUnauthenticated;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check that it is running.'**
  String get errorNetwork;

  /// No description provided for @paginationPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String paginationPageOf(int current, int total);

  /// No description provided for @paginationShowing.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} of {total}'**
  String paginationShowing(int from, int to, int total);

  /// No description provided for @paginationRowsPerPage.
  ///
  /// In en, this message translates to:
  /// **'Rows per page'**
  String get paginationRowsPerPage;

  /// No description provided for @paginationNext.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get paginationNext;

  /// No description provided for @paginationPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get paginationPrevious;

  /// No description provided for @prefsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get prefsLanguage;

  /// No description provided for @prefsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get prefsLanguageArabic;

  /// No description provided for @prefsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get prefsLanguageEnglish;

  /// No description provided for @prefsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get prefsTheme;

  /// No description provided for @prefsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get prefsThemeLight;

  /// No description provided for @prefsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get prefsThemeDark;

  /// No description provided for @prefsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get prefsThemeSystem;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get accountRoleAdmin;

  /// No description provided for @accountRoleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get accountRoleCustomer;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Administrator access to the store dashboard.'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'admin@example.com'**
  String get loginEmailHint;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get loginHidePassword;

  /// No description provided for @loginErrorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get loginErrorEmailRequired;

  /// No description provided for @loginErrorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get loginErrorEmailInvalid;

  /// No description provided for @loginErrorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get loginErrorPasswordRequired;

  /// No description provided for @loginErrorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get loginErrorPasswordTooShort;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorThrottled.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s.'**
  String loginErrorThrottled(int seconds);

  /// No description provided for @loginErrorNotAdmin.
  ///
  /// In en, this message translates to:
  /// **'This dashboard is for administrators only.'**
  String get loginErrorNotAdmin;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is what is happening in your store today.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardMetricOrders.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get dashboardMetricOrders;

  /// No description provided for @dashboardMetricProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get dashboardMetricProducts;

  /// No description provided for @dashboardOrdersByStatus.
  ///
  /// In en, this message translates to:
  /// **'Orders by status'**
  String get dashboardOrdersByStatus;

  /// No description provided for @dashboardRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get dashboardRecentOrders;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @productsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything listed in the store.'**
  String get productsSubtitle;

  /// No description provided for @productsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get productsAdd;

  /// No description provided for @productsFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productsFilterCategory;

  /// No description provided for @productsColumnImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get productsColumnImage;

  /// No description provided for @productsColumnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get productsColumnName;

  /// No description provided for @productsColumnCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productsColumnCategory;

  /// No description provided for @productsColumnPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productsColumnPrice;

  /// No description provided for @productsColumnQuantity.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get productsColumnQuantity;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to see it listed here.'**
  String get productsEmptyMessage;

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetailsTitle;

  /// No description provided for @productDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDetailsDescription;

  /// No description provided for @productDetailsAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get productDetailsAvailability;

  /// No description provided for @productInStock.
  ///
  /// In en, this message translates to:
  /// **'{count} in stock'**
  String productInStock(int count);

  /// No description provided for @productOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get productOutOfStock;

  /// No description provided for @productQuantityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Quantity unknown'**
  String get productQuantityUnknown;

  /// No description provided for @productQuantityUnknownHint.
  ///
  /// In en, this message translates to:
  /// **'Either the inventory service is down, or this product has no stock record yet.'**
  String get productQuantityUnknownHint;

  /// No description provided for @productNoStockRecord.
  ///
  /// In en, this message translates to:
  /// **'No stock record'**
  String get productNoStockRecord;

  /// No description provided for @productNoStockRecordHint.
  ///
  /// In en, this message translates to:
  /// **'This product cannot be ordered until stock is registered for it.'**
  String get productNoStockRecordHint;

  /// No description provided for @productFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get productFormTitle;

  /// No description provided for @productFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The product becomes visible in the store immediately.'**
  String get productFormSubtitle;

  /// No description provided for @productFormName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productFormName;

  /// No description provided for @productFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'Lenovo ThinkPad E14'**
  String get productFormNameHint;

  /// No description provided for @productFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productFormDescription;

  /// No description provided for @productFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'14-inch business laptop, 16GB RAM, 512GB SSD'**
  String get productFormDescriptionHint;

  /// No description provided for @productFormPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productFormPrice;

  /// No description provided for @productFormPriceHint.
  ///
  /// In en, this message translates to:
  /// **'899.50'**
  String get productFormPriceHint;

  /// No description provided for @productFormCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productFormCategory;

  /// No description provided for @productFormCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get productFormCategoryHint;

  /// No description provided for @productFormImage.
  ///
  /// In en, this message translates to:
  /// **'Product image'**
  String get productFormImage;

  /// No description provided for @productFormImagePick.
  ///
  /// In en, this message translates to:
  /// **'Choose an image'**
  String get productFormImagePick;

  /// No description provided for @productFormImageReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace image'**
  String get productFormImageReplace;

  /// No description provided for @productFormImageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get productFormImageRemove;

  /// No description provided for @productFormImageRules.
  ///
  /// In en, this message translates to:
  /// **'JPG, JPEG, PNG or WEBP · up to 5 MB'**
  String get productFormImageRules;

  /// No description provided for @productFormSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get productFormSubmit;

  /// No description provided for @productFormErrorName.
  ///
  /// In en, this message translates to:
  /// **'Product name is required.'**
  String get productFormErrorName;

  /// No description provided for @productFormErrorNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be 255 characters or fewer.'**
  String get productFormErrorNameTooLong;

  /// No description provided for @productFormErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'Description is required.'**
  String get productFormErrorDescription;

  /// No description provided for @productFormErrorDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Description must be 5000 characters or fewer.'**
  String get productFormErrorDescriptionTooLong;

  /// No description provided for @productFormErrorPrice.
  ///
  /// In en, this message translates to:
  /// **'Price is required.'**
  String get productFormErrorPrice;

  /// No description provided for @productFormErrorPriceFormat.
  ///
  /// In en, this message translates to:
  /// **'Use digits only, with at most two decimals.'**
  String get productFormErrorPriceFormat;

  /// No description provided for @productFormErrorPriceZero.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than zero.'**
  String get productFormErrorPriceZero;

  /// No description provided for @productFormErrorCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category.'**
  String get productFormErrorCategory;

  /// No description provided for @productFormErrorImage.
  ///
  /// In en, this message translates to:
  /// **'A product image is required.'**
  String get productFormErrorImage;

  /// No description provided for @productFormErrorImageType.
  ///
  /// In en, this message translates to:
  /// **'Allowed types: JPG, JPEG, PNG, WEBP.'**
  String get productFormErrorImageType;

  /// No description provided for @productFormErrorImageSize.
  ///
  /// In en, this message translates to:
  /// **'The image must be 5 MB or smaller.'**
  String get productFormErrorImageSize;

  /// No description provided for @productFormSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product added.'**
  String get productFormSuccess;

  /// No description provided for @productFormStockWarning.
  ///
  /// In en, this message translates to:
  /// **'Newly added products have no stock record, so they cannot be ordered until the inventory team registers a quantity.'**
  String get productFormStockWarning;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every order placed in the store.'**
  String get ordersSubtitle;

  /// No description provided for @ordersColumnId.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get ordersColumnId;

  /// No description provided for @ordersColumnCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get ordersColumnCustomer;

  /// No description provided for @ordersColumnItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get ordersColumnItems;

  /// No description provided for @ordersColumnTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersColumnTotal;

  /// No description provided for @ordersColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ordersColumnStatus;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Orders placed by customers will appear here.'**
  String get ordersEmptyMessage;

  /// No description provided for @ordersFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ordersFilterStatus;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderDetailsTitle(int id);

  /// No description provided for @orderDetailsItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderDetailsItems;

  /// No description provided for @orderDetailsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get orderDetailsCustomer;

  /// No description provided for @orderDetailsSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get orderDetailsSummary;

  /// No description provided for @orderDetailsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderDetailsTotal;

  /// No description provided for @orderDetailsItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String orderDetailsItemCount(int count);

  /// No description provided for @orderDetailsUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get orderDetailsUnitPrice;

  /// No description provided for @orderDetailsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get orderDetailsQuantity;

  /// No description provided for @orderDetailsLineTotal.
  ///
  /// In en, this message translates to:
  /// **'Line total'**
  String get orderDetailsLineTotal;

  /// No description provided for @orderDetailsTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get orderDetailsTimeline;

  /// No description provided for @orderActionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get orderActionConfirm;

  /// No description provided for @orderActionShip.
  ///
  /// In en, this message translates to:
  /// **'Mark as shipped'**
  String get orderActionShip;

  /// No description provided for @orderActionDeliver.
  ///
  /// In en, this message translates to:
  /// **'Mark as delivered'**
  String get orderActionDeliver;

  /// No description provided for @orderActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderActionCancel;

  /// No description provided for @orderActionFinalTitle.
  ///
  /// In en, this message translates to:
  /// **'This order is final'**
  String get orderActionFinalTitle;

  /// No description provided for @orderActionFinalMessage.
  ///
  /// In en, this message translates to:
  /// **'Delivered and cancelled orders cannot change status.'**
  String get orderActionFinalMessage;

  /// No description provided for @orderConfirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change order status?'**
  String get orderConfirmDialogTitle;

  /// No description provided for @orderConfirmDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Order #{id} moves from {from} to {to}. The customer is notified.'**
  String orderConfirmDialogMessage(int id, String from, String to);

  /// No description provided for @orderCancelDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Order #{id} will be cancelled and the reserved stock returned. This cannot be undone.'**
  String orderCancelDialogMessage(int id);

  /// No description provided for @orderStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order status updated.'**
  String get orderStatusUpdated;

  /// No description provided for @orderErrorInsufficientTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock'**
  String get orderErrorInsufficientTitle;

  /// No description provided for @orderErrorInsufficientMessage.
  ///
  /// In en, this message translates to:
  /// **'Reduce the quantities and try again.'**
  String get orderErrorInsufficientMessage;

  /// No description provided for @orderErrorInsufficientRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get orderErrorInsufficientRequested;

  /// No description provided for @orderErrorInsufficientAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get orderErrorInsufficientAvailable;

  /// No description provided for @orderErrorUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Product not available for ordering'**
  String get orderErrorUnavailableTitle;

  /// No description provided for @orderErrorUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'One or more products have no stock record.'**
  String get orderErrorUnavailableMessage;

  /// No description provided for @orderErrorInventoryDownTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory service busy'**
  String get orderErrorInventoryDownTitle;

  /// No description provided for @orderErrorInventoryDownMessage.
  ///
  /// In en, this message translates to:
  /// **'No order was created. Retrying sends the exact same request.'**
  String get orderErrorInventoryDownMessage;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
