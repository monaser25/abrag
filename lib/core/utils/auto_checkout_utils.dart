import '../database/database.dart';
import 'occupancy_utils.dart';

/// الساعة الافتراضية اللي بعدها الخروج بيتسجّل تلقائيًا يوم الخروج.
/// المالك بيستلم الشقة ٨ الصبح، والساعتين دول مهلة قبل ما التطبيق يقفلها لوحده.
const kDefaultAutoCheckoutHour = 10;

/// ليه حجز معيّن ما اتسجّلش خروجه تلقائيًا.
enum AutoCheckoutSkipReason {
  /// لسه بدري: ميعاد الخروج ما وصلش، أو وصل واللساعة ما عدّتش الساعة المحددة.
  notDueYet,

  /// العميل لسه عليه فلوس. مبنقفلش الحجز عشان الدين ما يضيعش من قدام عينه.
  unpaid,
}

/// وقت الإقفال التلقائي لحجز: يوم خروجه الساعة [hour].
DateTime summerBookingAutoCheckoutAt(SummerBooking booking, int hour) {
  final end = dateOnly(summerBookingEndDate(booking));
  return DateTime(end.year, end.month, end.day, hour);
}

/// الحجز ده يتسجّل خروجه تلقائيًا دلوقتي؟ و[null] معناها أيوه.
///
/// بيرجّع سبب التخطي بدل `bool` عشان الواجهة تعرف تفرّق بين "لسه بدري"
/// و"عليه فلوس" — التانية دي محتاجة تظهر للمالك.
AutoCheckoutSkipReason? summerBookingAutoCheckoutSkipReason(
  SummerBooking booking,
  DateTime now, {
  int hour = kDefaultAutoCheckoutHour,
}) {
  // الحجوزات اللي مش حيّة (ملغي/متسجّل خروجه/محذوف) مش بتوصل هنا أصلاً.
  if (now.isBefore(summerBookingAutoCheckoutAt(booking, hour))) {
    return AutoCheckoutSkipReason.notDueYet;
  }
  if (booking.amountPaidEgp + 0.01 < booking.totalPriceEgp) {
    return AutoCheckoutSkipReason.unpaid;
  }
  return null;
}
