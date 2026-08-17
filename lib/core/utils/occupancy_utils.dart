import '../database/database.dart';
import '../database/tables.dart';

/// قواعد إشغال الشقة بحجز صيفي — مكان واحد بدل ما تتكرر (وتغلط) في كل شاشة.
///
/// المالك بيستلم الشقة الساعة ٨ الصبح، وساعات بينسى يسجّل الخروج في التطبيق
/// ويسجّله بعدين وهو بيضيف الحجز الجديد. فالقاعدة مبنية على **تاريخ الخروج**
/// مش على زرار تسجيل الخروج: أول ما يوم الخروج يعدّي، الشقة تبقى فاضية حتى لو
/// الحالة لسه مش `checked_out` — وبنعلّم عليها إن الخروج متأخر التسجيل عشان
/// المالك ياخد باله ويسجّله.
///
/// المقارنة باليوم (مش بالساعة) عن قصد: البيانات القديمة متخزّنة ١٢ صباحاً
/// والحجوزات الجديدة ٨ صباحاً، والمقارنة اليومية بتتصرف صح مع الاتنين.

/// الحجز ده لسه شايل الشقة فعليًا؟ (دخل وما وصلش ليوم خروجه)
/// يوم الخروج نفسه **مش** محسوب إشغال — عشان الشقة بتتأجر لعميل جديد نفس اليوم
/// (خروج ٨ صباحاً ودخول ٢ الضهر).
bool summerBookingHoldsApartment(SummerBooking booking, DateTime now) {
  if (!_isLiveBooking(booking)) return false;
  final today = dateOnly(now);
  if (dateOnly(booking.checkInDate).isAfter(today)) return false;
  return dateOnly(summerBookingEndDate(booking)).isAfter(today);
}

/// يوم خروج الحجز ده هو النهاردة (اليوم المحدد).
bool summerBookingChecksOutOn(SummerBooking booking, DateTime day) {
  if (!_isLiveBooking(booking)) return false;
  return dateOnly(summerBookingEndDate(booking)) == dateOnly(day);
}

/// ميعاد الخروج عدّى ولسه محدش سجّل الخروج في التطبيق — الشقة فاضية بس
/// محتاجة تسجيل خروج عشان الحسابات والنظافة تتقفل صح.
bool summerBookingCheckoutIsOverdue(SummerBooking booking, DateTime now) {
  if (!_isLiveBooking(booking)) return false;
  return dateOnly(summerBookingEndDate(booking)).isBefore(dateOnly(now));
}

/// تاريخ نهاية الحجز الفعلي (الخروج المبكر لو موجود).
DateTime summerBookingEndDate(SummerBooking booking) =>
    booking.earlyCheckoutDate ?? booking.checkOutDate;

/// العقد الشتوي شايل الشقة دلوقتي؟
bool winterContractHoldsApartment(WinterContract contract, DateTime now) {
  if (!contract.isActive) return false;
  if (dateOnly(contract.startDate).isAfter(dateOnly(now))) return false;
  return contract.endDate.isAfter(now);
}

/// حجز "حيّ": مش ملغي ولا متسجّل خروجه ولا محذوف.
bool _isLiveBooking(SummerBooking booking) {
  return booking.status != 'cancelled' &&
      booking.status != 'checked_out' &&
      booking.status != 'deleted' &&
      booking.syncStatus != SyncStatus.pendingDelete;
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
