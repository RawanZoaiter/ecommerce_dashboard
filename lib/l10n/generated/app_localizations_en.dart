// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'E-Commerce Admin';

  @override
  String get appTitleShort => 'Admin';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProducts => 'Products';

  @override
  String get navOrders => 'Orders';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionClose => 'Close';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionViewAll => 'View all';

  @override
  String get actionBack => 'Back';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get commonAll => 'All';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonActions => 'Actions';

  @override
  String get commonCreatedAt => 'Created';

  @override
  String get commonOptional => 'optional';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get emptyMessage =>
      'Once data arrives it will show up on this screen.';

  @override
  String get emptyNoResultsTitle => 'No results';

  @override
  String get emptyNoResultsMessage => 'Try changing or clearing the filters.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorGeneric => 'An error occurred. Please try again later.';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get errorForbidden => 'You do not have permission for this action.';

  @override
  String get errorUnauthenticated =>
      'Your session expired. Please sign in again.';

  @override
  String get errorNetwork =>
      'Cannot reach the server. Check that it is running.';

  @override
  String get errorTimeout =>
      'The server is taking too long to answer. Please try again.';

  @override
  String paginationPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String paginationShowing(int from, int to, int total) {
    return '$from–$to of $total';
  }

  @override
  String get paginationRowsPerPage => 'Rows per page';

  @override
  String get paginationNext => 'Next page';

  @override
  String get paginationPrevious => 'Previous page';

  @override
  String get prefsLanguage => 'Language';

  @override
  String get prefsLanguageArabic => 'العربية';

  @override
  String get prefsLanguageEnglish => 'English';

  @override
  String get prefsTheme => 'Theme';

  @override
  String get prefsThemeLight => 'Light';

  @override
  String get prefsThemeDark => 'Dark';

  @override
  String get prefsThemeSystem => 'System';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountRoleAdmin => 'Administrator';

  @override
  String get accountRoleCustomer => 'Customer';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Administrator access to the store dashboard.';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginEmailHint => 'admin@example.com';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginErrorEmailRequired => 'Email is required.';

  @override
  String get loginErrorEmailInvalid => 'Enter a valid email address.';

  @override
  String get loginErrorPasswordRequired => 'Password is required.';

  @override
  String get loginErrorPasswordTooShort =>
      'Password must be at least 8 characters.';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String loginErrorThrottled(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s.';
  }

  @override
  String get loginErrorNotAdmin => 'This dashboard is for administrators only.';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardGreeting(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get dashboardSubtitle =>
      'Here is what is happening in your store today.';

  @override
  String get dashboardMetricOrders => 'Total orders';

  @override
  String get dashboardMetricProducts => 'Products';

  @override
  String get dashboardOrdersByStatus => 'Orders by status';

  @override
  String get dashboardRecentOrders => 'Recent orders';

  @override
  String get productsTitle => 'Products';

  @override
  String get productsSubtitle => 'Everything listed in the store.';

  @override
  String get productsAdd => 'Add product';

  @override
  String get productsFilterCategory => 'Category';

  @override
  String get productsColumnImage => 'Image';

  @override
  String get productsColumnName => 'Name';

  @override
  String get productsColumnCategory => 'Category';

  @override
  String get productsColumnPrice => 'Price';

  @override
  String get productsColumnQuantity => 'Available';

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyMessage =>
      'Add your first product to see it listed here.';

  @override
  String get productDetailsTitle => 'Product details';

  @override
  String get productDetailsDescription => 'Description';

  @override
  String get productDetailsAvailability => 'Availability';

  @override
  String productInStock(int count) {
    return '$count in stock';
  }

  @override
  String get productOutOfStock => 'Out of stock';

  @override
  String get productQuantityUnknown => 'Quantity unknown';

  @override
  String get productQuantityUnknownHint =>
      'Either the inventory service is down, or this product has no stock record yet.';

  @override
  String get productNoStockRecord => 'No stock record';

  @override
  String get productNoStockRecordHint =>
      'This product cannot be ordered until stock is registered for it.';

  @override
  String get productFormTitle => 'Add product';

  @override
  String get productFormSubtitle =>
      'The product becomes visible in the store immediately.';

  @override
  String get productFormName => 'Product name';

  @override
  String get productFormNameHint => 'Lenovo ThinkPad E14';

  @override
  String get productFormDescription => 'Description';

  @override
  String get productFormDescriptionHint =>
      '14-inch business laptop, 16GB RAM, 512GB SSD';

  @override
  String get productFormPrice => 'Price';

  @override
  String get productFormPriceHint => '899.50';

  @override
  String get productFormCategory => 'Category';

  @override
  String get productFormCategoryHint => 'Pick a category';

  @override
  String get productFormImage => 'Product image';

  @override
  String get productFormImagePick => 'Choose an image';

  @override
  String get productFormImageReplace => 'Replace image';

  @override
  String get productFormImageRemove => 'Remove image';

  @override
  String get productFormImageRules => 'JPG, JPEG, PNG or WEBP · up to 5 MB';

  @override
  String get productFormSubmit => 'Add product';

  @override
  String get productFormErrorName => 'Product name is required.';

  @override
  String get productFormErrorNameTooLong =>
      'Name must be 255 characters or fewer.';

  @override
  String get productFormErrorDescription => 'Description is required.';

  @override
  String get productFormErrorDescriptionTooLong =>
      'Description must be 5000 characters or fewer.';

  @override
  String get productFormErrorPrice => 'Price is required.';

  @override
  String get productFormErrorPriceFormat =>
      'Use digits only, with at most two decimals.';

  @override
  String get productFormErrorPriceZero => 'Price must be greater than zero.';

  @override
  String get productFormErrorCategory => 'Pick a category.';

  @override
  String get productFormErrorImage => 'A product image is required.';

  @override
  String get productFormErrorImageType =>
      'Allowed types: JPG, JPEG, PNG, WEBP.';

  @override
  String get productFormErrorImageSize => 'The image must be 5 MB or smaller.';

  @override
  String get productFormSuccess => 'Product added.';

  @override
  String get productFormStockWarning =>
      'Newly added products have no stock record, so they cannot be ordered until the inventory team registers a quantity.';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersSubtitle => 'Every order placed in the store.';

  @override
  String get ordersColumnId => 'Order';

  @override
  String get ordersColumnCustomer => 'Customer';

  @override
  String get ordersColumnItems => 'Items';

  @override
  String get ordersColumnTotal => 'Total';

  @override
  String get ordersColumnStatus => 'Status';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyMessage =>
      'Orders placed by customers will appear here.';

  @override
  String get ordersFilterStatus => 'Status';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String orderDetailsTitle(int id) {
    return 'Order #$id';
  }

  @override
  String get orderDetailsItems => 'Items';

  @override
  String get orderDetailsCustomer => 'Customer';

  @override
  String get orderDetailsSummary => 'Summary';

  @override
  String get orderDetailsTotal => 'Total';

  @override
  String orderDetailsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get orderDetailsUnitPrice => 'Unit price';

  @override
  String get orderDetailsQuantity => 'Qty';

  @override
  String get orderDetailsLineTotal => 'Line total';

  @override
  String get orderDetailsTimeline => 'Timeline';

  @override
  String get orderActionConfirm => 'Confirm order';

  @override
  String get orderActionShip => 'Mark as shipped';

  @override
  String get orderActionDeliver => 'Mark as delivered';

  @override
  String get orderActionCancel => 'Cancel order';

  @override
  String get orderActionFinalTitle => 'This order is final';

  @override
  String get orderActionFinalMessage =>
      'Delivered and cancelled orders cannot change status.';

  @override
  String get orderConfirmDialogTitle => 'Change order status?';

  @override
  String orderConfirmDialogMessage(int id, String from, String to) {
    return 'Order #$id moves from $from to $to. The customer is notified.';
  }

  @override
  String orderCancelDialogMessage(int id) {
    return 'Order #$id will be cancelled and the reserved stock returned. This cannot be undone.';
  }

  @override
  String get orderStatusUpdated => 'Order status updated.';

  @override
  String get orderErrorInsufficientTitle => 'Not enough stock';

  @override
  String get orderErrorInsufficientMessage =>
      'Reduce the quantities and try again.';

  @override
  String get orderErrorInsufficientRequested => 'Requested';

  @override
  String get orderErrorInsufficientAvailable => 'Available';

  @override
  String get orderErrorUnavailableTitle => 'Product not available for ordering';

  @override
  String get orderErrorUnavailableMessage =>
      'One or more products have no stock record.';

  @override
  String get orderErrorInventoryDownTitle => 'Inventory service busy';

  @override
  String get orderErrorInventoryDownMessage =>
      'No order was created. Retrying sends the exact same request.';

  @override
  String get productFormQuantity => 'Opening stock';

  @override
  String get productFormQuantityHint => '25';

  @override
  String get productFormQuantityHelp =>
      'Sent to the inventory service. 0 is allowed.';

  @override
  String get productFormErrorQuantity => 'Opening stock is required.';

  @override
  String get productFormErrorQuantityInvalid =>
      'Enter a whole number, 0 or more.';

  @override
  String get productFormPendingTitle => 'Saved, but stock is not set up';

  @override
  String get productFormPendingMessage =>
      'The product exists but the inventory service did not confirm its stock, so nobody can order it yet. It needs to be retried.';

  @override
  String get errorInventoryConflict =>
      'The inventory service already holds a different stock record for this product. Someone has to resolve that before it can be sold.';
}
