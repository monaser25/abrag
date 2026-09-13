import '../database/database.dart';

/// ليالي الإقامة: من تاريخ الدخول لتاريخ الخروج (أو الخروج المبكر لو موجود).
/// بنقارن بالتاريخ من غير الوقت لأن الدخول والخروج بيحملوا ساعة.
int summerBookingStayDays(SummerBooking booking) {
  final checkIn = booking.checkInDate;
  final checkOut = booking.earlyCheckoutDate ?? booking.checkOutDate;
  final startDate = DateTime(checkIn.year, checkIn.month, checkIn.day);
  final endDate = DateTime(checkOut.year, checkOut.month, checkOut.day);
  return endDate.difference(startDate).inDays.clamp(1, 10000);
}

/// السعر اليومي = **إجمالي الحجز كله ÷ كل الليالي**.
///
/// الإجمالي شامل رسوم التمديد، والليالي شاملة أيام التمديد — يعني الرقم ده
/// متوسط اللي دفعه الضيف في الليلة. مثال شقة ١٦: ٧٤٠٠ ج.م على ١٨ ليلة = ٤١١.
///
/// مهم: مبنطرحش رسوم التمديد من الإجمالي. الطرح ده هو اللي كان بيخلّي كل
/// تمديد ينزّل السعر (١٨٠٠ ÷ ١٨ = ١٠٠)، وبيطلّع سعر بالسالب لو تعديل ساب
/// الرسوم مكانها وقلّل الإجمالي.
double summerBookingDailyRate(SummerBooking booking) {
  final total = booking.totalPriceEgp.clamp(0.0, double.infinity);
  return total / summerBookingStayDays(booking);
}
