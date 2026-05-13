// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أبراج';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'مرحباً بك في نظام إدارة أبراج';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get loginButton => 'دخول';

  @override
  String get requiredField => 'مطلوب';

  @override
  String loginError(String error) {
    return 'خطأ في تسجيل الدخول: $error';
  }

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get dashboardWelcome => 'مرحباً بك في لوحة التحكم';

  @override
  String get syncConflicts => 'تعارضات المزامنة';

  @override
  String get summerBookings => 'حجوزات الصيف';

  @override
  String get winterContracts => 'عقود الشتاء';

  @override
  String get buildings => 'المباني';

  @override
  String get apartments => 'الشقق';

  @override
  String get noData => 'لا توجد بيانات متاحة';

  @override
  String get addBooking => 'إضافة حجز صيفي';

  @override
  String get guestName => 'اسم الضيف';

  @override
  String get guestPhone => 'رقم الهاتف';

  @override
  String get checkInDate => 'تاريخ الدخول';

  @override
  String get checkOutDate => 'تاريخ الخروج';

  @override
  String get totalPrice => 'السعر الإجمالي';

  @override
  String get save => 'حفظ';

  @override
  String get addContract => 'إضافة عقد شتوي';

  @override
  String get studentName => 'اسم الطالب';

  @override
  String get university => 'الجامعة';

  @override
  String get monthlyRent => 'الإيجار الشهري';

  @override
  String get deposit => 'التأمين';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get expenses => 'المصروفات';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get expenseType => 'نوع المصروف';

  @override
  String get amount => 'المبلغ';

  @override
  String get description => 'الوصف';

  @override
  String get meterReadings => 'قراءات العدادات';

  @override
  String get buildingRent => 'إيجار المبنى';

  @override
  String get maintenance => 'الصيانة';

  @override
  String get sharedExpense => 'مصروف مشترك';

  @override
  String get individualExpense => 'مصروف فردي';

  @override
  String get previousReading => 'القراءة السابقة';

  @override
  String get currentReading => 'القراءة الحالية';
}
