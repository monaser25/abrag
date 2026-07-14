import '../database/database.dart';
import '../database/tables.dart';

Map<String, List<BookingPayment>> indexActiveBookingPayments(
  Iterable<BookingPayment> payments,
) {
  final paymentsByBookingId = <String, List<BookingPayment>>{};
  for (final payment in payments) {
    if (payment.syncStatus == SyncStatus.pendingDelete) continue;
    paymentsByBookingId
        .putIfAbsent(payment.bookingId, () => <BookingPayment>[])
        .add(payment);
  }
  return paymentsByBookingId;
}

Map<String, double> summerBookingPaymentBreakdown(
  SummerBooking booking,
  Iterable<BookingPayment> payments,
) {
  final breakdown = <String, double>{};
  var recordedAmount = 0.0;
  for (final payment in payments) {
    breakdown[payment.paymentMethod] =
        (breakdown[payment.paymentMethod] ?? 0) + payment.amountEgp;
    recordedAmount += payment.amountEgp;
  }

  final remainder = booking.amountPaidEgp - recordedAmount;
  if (remainder != 0) {
    breakdown[booking.paymentMethod] =
        (breakdown[booking.paymentMethod] ?? 0) + remainder;
  }
  return breakdown;
}
