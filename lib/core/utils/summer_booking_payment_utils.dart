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

/// How much broker commission to deduct from each payment-method pool.
/// If the booking has an explicit commission-paid split (any of the 3 paid
/// columns > 0), use it as-is. Otherwise fall back to the previous behavior:
/// deduct the computed [commissionAmount] from the booking's primary payment
/// method, clamped to what the guest actually paid.
Map<String, double> summerBookingCommissionDeductions(
  SummerBooking booking,
  double commissionAmount,
) {
  final cash = booking.brokerCommissionPaidCashEgp;
  final voda = booking.brokerCommissionPaidVodafoneEgp;
  final insta = booking.brokerCommissionPaidInstapayEgp;
  if (cash + voda + insta > 0) {
    return {
      if (cash > 0) 'cash': cash,
      if (voda > 0) 'vodafone_cash': voda,
      if (insta > 0) 'instapay': insta,
    };
  }
  if (commissionAmount <= 0) return const {};
  final clamped = commissionAmount < booking.amountPaidEgp
      ? commissionAmount
      : booking.amountPaidEgp;
  if (clamped <= 0) return const {};
  return {booking.paymentMethod: clamped};
}
