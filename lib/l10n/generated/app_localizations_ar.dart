// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لوحة إدارة المتجر';

  @override
  String get appTitleShort => 'اللوحة';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionFilter => 'تصفية';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionApply => 'تطبيق';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionViewAll => 'عرض الكل';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get commonAll => 'الكل';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonActions => 'إجراءات';

  @override
  String get commonCreatedAt => 'أُنشئ';

  @override
  String get commonOptional => 'اختياري';

  @override
  String get emptyTitle => 'ما في شي هون بعد';

  @override
  String get emptyMessage => 'أول ما تجي البيانات رح تظهر بهاي الشاشة.';

  @override
  String get emptyNoResultsTitle => 'ما في نتائج';

  @override
  String get emptyNoResultsMessage => 'جرّب تغيّر التصفية أو تمسحها.';

  @override
  String get errorTitle => 'صار في خطأ';

  @override
  String get errorGeneric => 'حدث خطأ، حاول مرة ثانية لاحقًا.';

  @override
  String get errorNotFound => 'غير موجود';

  @override
  String get errorForbidden => 'ما عندك صلاحية لهذا الإجراء.';

  @override
  String get errorUnauthenticated => 'انتهت الجلسة. سجّل الدخول من جديد.';

  @override
  String get errorNetwork => 'ما قدرنا نوصل للسيرفر. تأكد إنه شغّال.';

  @override
  String paginationPageOf(int current, int total) {
    return 'صفحة $current من $total';
  }

  @override
  String paginationShowing(int from, int to, int total) {
    return '$from–$to من $total';
  }

  @override
  String get paginationRowsPerPage => 'صفوف بالصفحة';

  @override
  String get paginationNext => 'الصفحة التالية';

  @override
  String get paginationPrevious => 'الصفحة السابقة';

  @override
  String get prefsLanguage => 'اللغة';

  @override
  String get prefsLanguageArabic => 'العربية';

  @override
  String get prefsLanguageEnglish => 'English';

  @override
  String get prefsTheme => 'المظهر';

  @override
  String get prefsThemeLight => 'فاتح';

  @override
  String get prefsThemeDark => 'داكن';

  @override
  String get prefsThemeSystem => 'حسب النظام';

  @override
  String get accountSignOut => 'تسجيل الخروج';

  @override
  String get accountRoleAdmin => 'مسؤول';

  @override
  String get accountRoleCustomer => 'زبون';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'دخول المسؤولين إلى لوحة إدارة المتجر.';

  @override
  String get loginEmail => 'البريد الإلكتروني';

  @override
  String get loginEmailHint => 'admin@example.com';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginPasswordHint => 'أدخل كلمة المرور';

  @override
  String get loginSubmit => 'دخول';

  @override
  String get loginShowPassword => 'إظهار كلمة المرور';

  @override
  String get loginHidePassword => 'إخفاء كلمة المرور';

  @override
  String get loginErrorEmailRequired => 'البريد الإلكتروني مطلوب.';

  @override
  String get loginErrorEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get loginErrorPasswordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get loginErrorPasswordTooShort => 'كلمة المرور 8 أحرف على الأقل.';

  @override
  String get loginErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String loginErrorThrottled(int seconds) {
    return 'محاولات كثيرة. جرّب بعد $seconds ثانية.';
  }

  @override
  String get loginErrorNotAdmin => 'هذه اللوحة للمسؤولين فقط.';

  @override
  String get dashboardTitle => 'الرئيسية';

  @override
  String dashboardGreeting(String name) {
    return 'أهلًا بعودتك، $name';
  }

  @override
  String get dashboardSubtitle => 'هذا ملخّص ما يجري في متجرك اليوم.';

  @override
  String get dashboardMetricOrders => 'إجمالي الطلبات';

  @override
  String get dashboardMetricProducts => 'المنتجات';

  @override
  String get dashboardOrdersByStatus => 'الطلبات حسب الحالة';

  @override
  String get dashboardRecentOrders => 'آخر الطلبات';

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get productsSubtitle => 'كل ما هو معروض في المتجر.';

  @override
  String get productsAdd => 'إضافة منتج';

  @override
  String get productsFilterCategory => 'التصنيف';

  @override
  String get productsColumnImage => 'الصورة';

  @override
  String get productsColumnName => 'الاسم';

  @override
  String get productsColumnCategory => 'التصنيف';

  @override
  String get productsColumnPrice => 'السعر';

  @override
  String get productsColumnQuantity => 'المتوفر';

  @override
  String get productsEmptyTitle => 'ما في منتجات بعد';

  @override
  String get productsEmptyMessage => 'أضف أول منتج ليظهر في هذه القائمة.';

  @override
  String get productDetailsTitle => 'تفاصيل المنتج';

  @override
  String get productDetailsDescription => 'الوصف';

  @override
  String get productDetailsAvailability => 'التوفّر';

  @override
  String productInStock(int count) {
    return 'متوفر منه $count';
  }

  @override
  String get productOutOfStock => 'غير متوفر';

  @override
  String get productQuantityUnknown => 'الكمية غير معروفة';

  @override
  String get productQuantityUnknownHint =>
      'إما خدمة المخزون متوقفة، أو هذا المنتج ما إله سجل مخزون بعد.';

  @override
  String get productNoStockRecord => 'بلا سجل مخزون';

  @override
  String get productNoStockRecordHint =>
      'ما بينفع يُطلب هذا المنتج قبل ما تنسجّل له كمية.';

  @override
  String get productFormTitle => 'إضافة منتج';

  @override
  String get productFormSubtitle => 'المنتج بيصير ظاهر في المتجر فورًا.';

  @override
  String get productFormName => 'اسم المنتج';

  @override
  String get productFormNameHint => 'Lenovo ThinkPad E14';

  @override
  String get productFormDescription => 'الوصف';

  @override
  String get productFormDescriptionHint =>
      'لابتوب 14 إنش، ذاكرة 16 غيغابايت، قرص 512 غيغابايت';

  @override
  String get productFormPrice => 'السعر';

  @override
  String get productFormPriceHint => '899.50';

  @override
  String get productFormCategory => 'التصنيف';

  @override
  String get productFormCategoryHint => 'اختر تصنيفًا';

  @override
  String get productFormImage => 'صورة المنتج';

  @override
  String get productFormImagePick => 'اختر صورة';

  @override
  String get productFormImageReplace => 'تغيير الصورة';

  @override
  String get productFormImageRemove => 'إزالة الصورة';

  @override
  String get productFormImageRules =>
      'JPG أو JPEG أو PNG أو WEBP · حتى 5 ميغابايت';

  @override
  String get productFormSubmit => 'إضافة المنتج';

  @override
  String get productFormErrorName => 'اسم المنتج مطلوب.';

  @override
  String get productFormErrorNameTooLong => 'الاسم 255 حرفًا كحد أقصى.';

  @override
  String get productFormErrorDescription => 'الوصف مطلوب.';

  @override
  String get productFormErrorDescriptionTooLong => 'الوصف 5000 حرف كحد أقصى.';

  @override
  String get productFormErrorPrice => 'السعر مطلوب.';

  @override
  String get productFormErrorPriceFormat =>
      'أرقام فقط، ومنزلتان عشريتان كحد أقصى.';

  @override
  String get productFormErrorPriceZero => 'السعر لازم يكون أكبر من صفر.';

  @override
  String get productFormErrorCategory => 'اختر تصنيفًا.';

  @override
  String get productFormErrorImage => 'صورة المنتج مطلوبة.';

  @override
  String get productFormErrorImageType =>
      'الأنواع المسموحة: JPG، JPEG، PNG، WEBP.';

  @override
  String get productFormErrorImageSize => 'حجم الصورة 5 ميغابايت كحد أقصى.';

  @override
  String get productFormSuccess => 'تمت إضافة المنتج.';

  @override
  String get productFormStockWarning =>
      'المنتج الجديد ما إله سجل مخزون، فما بينفع يُطلب لحد ما يسجّل له فريق المخزون كمية.';

  @override
  String get ordersTitle => 'الطلبات';

  @override
  String get ordersSubtitle => 'كل الطلبات في المتجر.';

  @override
  String get ordersColumnId => 'الطلب';

  @override
  String get ordersColumnCustomer => 'الزبون';

  @override
  String get ordersColumnItems => 'العناصر';

  @override
  String get ordersColumnTotal => 'الإجمالي';

  @override
  String get ordersColumnStatus => 'الحالة';

  @override
  String get ordersEmptyTitle => 'ما في طلبات بعد';

  @override
  String get ordersEmptyMessage => 'طلبات الزبائن رح تظهر هون.';

  @override
  String get ordersFilterStatus => 'الحالة';

  @override
  String get orderStatusPending => 'قيد الانتظار';

  @override
  String get orderStatusConfirmed => 'مؤكّد';

  @override
  String get orderStatusShipped => 'تم الشحن';

  @override
  String get orderStatusDelivered => 'تم التسليم';

  @override
  String get orderStatusCancelled => 'ملغي';

  @override
  String orderDetailsTitle(int id) {
    return 'الطلب رقم $id';
  }

  @override
  String get orderDetailsItems => 'العناصر';

  @override
  String get orderDetailsCustomer => 'الزبون';

  @override
  String get orderDetailsSummary => 'الملخّص';

  @override
  String get orderDetailsTotal => 'الإجمالي';

  @override
  String orderDetailsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصرًا',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
    );
    return '$_temp0';
  }

  @override
  String get orderDetailsUnitPrice => 'سعر الوحدة';

  @override
  String get orderDetailsQuantity => 'الكمية';

  @override
  String get orderDetailsLineTotal => 'إجمالي السطر';

  @override
  String get orderDetailsTimeline => 'المسار';

  @override
  String get orderActionConfirm => 'تأكيد الطلب';

  @override
  String get orderActionShip => 'تعليمه كمشحون';

  @override
  String get orderActionDeliver => 'تعليمه كمُسلَّم';

  @override
  String get orderActionCancel => 'إلغاء الطلب';

  @override
  String get orderActionFinalTitle => 'هذا الطلب نهائي';

  @override
  String get orderActionFinalMessage =>
      'الطلبات المُسلَّمة والملغاة ما بتتغيّر حالتها.';

  @override
  String get orderConfirmDialogTitle => 'تغيير حالة الطلب؟';

  @override
  String orderConfirmDialogMessage(int id, String from, String to) {
    return 'الطلب رقم $id رح ينتقل من $from إلى $to، وبينبعت إشعار للزبون.';
  }

  @override
  String orderCancelDialogMessage(int id) {
    return 'الطلب رقم $id رح ينلغى وترجع الكمية المحجوزة للمخزون. ما بينفع التراجع.';
  }

  @override
  String get orderStatusUpdated => 'تم تحديث حالة الطلب.';

  @override
  String get orderErrorInsufficientTitle => 'الكمية غير كافية';

  @override
  String get orderErrorInsufficientMessage => 'قلّل الكميات وحاول من جديد.';

  @override
  String get orderErrorInsufficientRequested => 'المطلوب';

  @override
  String get orderErrorInsufficientAvailable => 'المتوفر';

  @override
  String get orderErrorUnavailableTitle => 'منتج غير متاح للطلب';

  @override
  String get orderErrorUnavailableMessage =>
      'في منتج أو أكثر ما إله سجل مخزون.';

  @override
  String get orderErrorInventoryDownTitle => 'خدمة المخزون مشغولة';

  @override
  String get orderErrorInventoryDownMessage =>
      'ما انعمل أي طلب. إعادة المحاولة بتبعت نفس الطلب تمامًا.';
}
