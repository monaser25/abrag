// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Abrag';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Welcome to Abrag Management System';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get requiredField => 'Required';

  @override
  String loginError(String error) {
    return 'Login error: $error';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardWelcome => 'Welcome to the Dashboard';

  @override
  String get syncConflicts => 'Sync Conflicts';

  @override
  String get summerBookings => 'Summer Bookings';

  @override
  String get winterContracts => 'Winter Contracts';

  @override
  String get buildings => 'Buildings';

  @override
  String get apartments => 'Apartments';

  @override
  String get noData => 'No data available';

  @override
  String get addBooking => 'Add Summer Booking';

  @override
  String get guestName => 'Guest Name';

  @override
  String get guestPhone => 'Phone Number';

  @override
  String get checkInDate => 'Check-in Date';

  @override
  String get checkOutDate => 'Check-out Date';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get save => 'Save';

  @override
  String get addContract => 'Add Winter Contract';

  @override
  String get studentName => 'Student Name';

  @override
  String get university => 'University';

  @override
  String get monthlyRent => 'Monthly Rent';

  @override
  String get deposit => 'Deposit';

  @override
  String get selectDate => 'Select Date';

  @override
  String get expenses => 'Expenses';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get expenseType => 'Expense Type';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get meterReadings => 'Meter Readings';

  @override
  String get buildingRent => 'Building Rent';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get sharedExpense => 'Shared Expense';

  @override
  String get individualExpense => 'Individual Expense';

  @override
  String get previousReading => 'Previous Reading';

  @override
  String get currentReading => 'Current Reading';
}
