import '../database/database.dart';

/// Calendar nights of the stay: checkInDate -> (earlyCheckoutDate ?? checkOutDate), minimum 1.
int summerBookingStayDays(SummerBooking booking) {
  final checkIn = booking.checkInDate;
  final startDate = DateTime(checkIn.year, checkIn.month, checkIn.day);

  final checkOut = booking.earlyCheckoutDate ?? booking.checkOutDate;
  final endDate = DateTime(checkOut.year, checkOut.month, checkOut.day);

  return endDate.difference(startDate).inDays.clamp(1, 10000);
}

/// Nights of the ORIGINAL stay, excluding extension days. Always >= 1.
int summerBookingBaseDays(SummerBooking booking) {
  final stayDays = summerBookingStayDays(booking);
  return (stayDays - booking.overstayDays).clamp(1, stayDays);
}

/// Per-night price of the original stay = base total / base days.
double summerBookingBaseDailyRate(SummerBooking booking) {
  final baseTotal = (booking.totalPriceEgp - booking.overstayFeeEgp).clamp(
    0.0,
    double.infinity,
  );
  final baseDays = summerBookingBaseDays(booking);
  return baseTotal / baseDays;
}
