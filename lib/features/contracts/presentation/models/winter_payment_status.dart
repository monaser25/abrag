import '../../../../core/database/database.dart';

class UnpaidInstallment {
  final DateTime dueDate;
  final double remainingAmount;
  final int daysLate;

  const UnpaidInstallment({
    required this.dueDate,
    required this.remainingAmount,
    required this.daysLate,
  });

  bool get isLate => daysLate > 0;
}

class WinterRentStatus {
  final int dueInstallments;
  final double expectedAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? nextUnpaidDueDate;
  final int daysLate;
  final int previousMonthsDue;
  final List<UnpaidInstallment> unpaidInstallments;

  const WinterRentStatus({
    required this.dueInstallments,
    required this.expectedAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.nextUnpaidDueDate,
    required this.daysLate,
    required this.previousMonthsDue,
    required this.unpaidInstallments,
  });

  bool get hasOverdue => remainingAmount > 0 && nextUnpaidDueDate != null;

  String? get statusTitle {
    if (!hasOverdue) return null;
    if (previousMonthsDue > 0) return 'إجمالي المتأخرات';
    if (daysLate > 0) return 'متأخر $daysLate يوم';
    return 'مستحق اليوم';
  }

  String? get statusDetails {
    if (!hasOverdue) return null;
    final due = nextUnpaidDueDate!.toLocal().toString().split(' ')[0];
    if (daysLate > 0) return 'مستحق من $due - متأخر $daysLate يوم';
    return 'مستحق في $due';
  }
}

class WinterPaymentLateInfo {
  final DateTime dueDate;
  final int daysLate;

  const WinterPaymentLateInfo({required this.dueDate, required this.daysLate});

  bool get isLate => daysLate > 0;

  String get label => isLate ? 'دفع متأخر $daysLate يوم' : 'دفع في الميعاد';
}

List<DateTime> winterRentDueDates(WinterContract contract) {
  final dates = <DateTime>[];
  var current = _dateOnly(contract.startDate);
  final end = _dateOnly(contract.endDate);
  final preferredDay = contract.startDate.day;

  while (current.isBefore(end)) {
    dates.add(current);
    current = _addOneMonth(current, preferredDay);
  }

  return dates;
}

WinterRentStatus calculateWinterRentStatus(
  WinterContract contract,
  List<WinterPayment> payments, {
  DateTime? today,
}) {
  final now = _dateOnly(today ?? DateTime.now());
  final dueDates = winterRentDueDates(
    contract,
  ).where((date) => !date.isAfter(now)).toList();
  final paidAmount = payments.fold<double>(0, (sum, p) => sum + p.amountEgp);
  final expectedAmount = dueDates.length * contract.monthlyRentEgp;
  final remainingAmount = expectedAmount - paidAmount;

  if (remainingAmount <= 0 || dueDates.isEmpty) {
    return WinterRentStatus(
      dueInstallments: dueDates.length,
      expectedAmount: expectedAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount <= 0 ? 0 : remainingAmount,
      nextUnpaidDueDate: null,
      daysLate: 0,
      previousMonthsDue: 0,
      unpaidInstallments: const [],
    );
  }

  final paidInstallments = (paidAmount / contract.monthlyRentEgp).floor();
  final nextIndex = paidInstallments.clamp(0, dueDates.length - 1);
  final nextUnpaidDueDate = dueDates[nextIndex];
  final daysLate = now.difference(nextUnpaidDueDate).inDays.clamp(0, 99999);
  final currentMonthStart = DateTime(now.year, now.month);
  final previousMonthsDue = dueDates
      .skip(nextIndex)
      .where((date) => date.isBefore(currentMonthStart))
      .length;

  final unpaidInstallments = <UnpaidInstallment>[];
  double remainingToAllocate = remainingAmount;
  int currentIndex = nextIndex;

  // Account for partial payment of the next index
  final remainderFromPaid =
      paidAmount - (paidInstallments * contract.monthlyRentEgp);

  while (remainingToAllocate > 0.01 && currentIndex < dueDates.length) {
    final dueDate = dueDates[currentIndex];
    var amountForThisInstallment = contract.monthlyRentEgp;
    if (currentIndex == nextIndex && remainderFromPaid > 0) {
      amountForThisInstallment -= remainderFromPaid;
    }

    if (amountForThisInstallment > remainingToAllocate) {
      amountForThisInstallment = remainingToAllocate;
    }

    final lateDays = now.difference(dueDate).inDays.clamp(0, 99999);

    unpaidInstallments.add(
      UnpaidInstallment(
        dueDate: dueDate,
        remainingAmount: amountForThisInstallment,
        daysLate: lateDays,
      ),
    );

    remainingToAllocate -= amountForThisInstallment;
    currentIndex++;
  }

  return WinterRentStatus(
    dueInstallments: dueDates.length,
    expectedAmount: expectedAmount,
    paidAmount: paidAmount,
    remainingAmount: remainingAmount,
    nextUnpaidDueDate: nextUnpaidDueDate,
    daysLate: daysLate,
    previousMonthsDue: previousMonthsDue,
    unpaidInstallments: unpaidInstallments,
  );
}

WinterPaymentLateInfo? lateInfoForWinterPayment(
  WinterContract contract,
  List<WinterPayment> allPayments,
  WinterPayment payment,
) {
  final dueDates = winterRentDueDates(contract);
  if (dueDates.isEmpty || contract.monthlyRentEgp <= 0) return null;

  final previousPaid = allPayments
      .where((item) {
        if (item.id == payment.id) return false;
        if (item.paymentDate.isBefore(payment.paymentDate)) return true;
        if (item.paymentDate.isAtSameMomentAs(payment.paymentDate)) {
          return item.createdAt.isBefore(payment.createdAt);
        }
        return false;
      })
      .fold<double>(0, (sum, item) => sum + item.amountEgp);

  final dueIndex = (previousPaid / contract.monthlyRentEgp).floor();
  if (dueIndex < 0 || dueIndex >= dueDates.length) return null;

  final dueDate = dueDates[dueIndex];
  final paidDate = _dateOnly(payment.paymentDate);
  final daysLate = paidDate.difference(dueDate).inDays.clamp(0, 99999);
  return WinterPaymentLateInfo(dueDate: dueDate, daysLate: daysLate);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _addOneMonth(DateTime date, int preferredDay) {
  var year = date.year;
  var month = date.month + 1;
  if (month > 12) {
    month = 1;
    year += 1;
  }
  final maxDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, preferredDay > maxDay ? maxDay : preferredDay);
}
