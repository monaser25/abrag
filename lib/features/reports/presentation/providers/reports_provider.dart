import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/providers/database_provider.dart';

class FinancialSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final List<Transaction> transactions;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.transactions,
  });
}

class Transaction {
  final DateTime date;
  final String description;
  final double amount;
  final bool isRevenue;
  final String paymentMethod;
  final String? buildingId;

  Transaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.isRevenue,
    required this.paymentMethod,
    this.buildingId,
  });
}

final financialReportProvider = StreamProvider<FinancialSummary>((ref) {
  final db = ref.watch(databaseProvider);

  return Stream.periodic(const Duration(milliseconds: 500)).asyncMap((_) async {
    final expenses = await db.select(db.expenses).get();
    final summerBookings = await db.select(db.summerBookings).get();
    final apartments = await db.select(db.apartments).get();
    Map<String, String> aptToBuildingMap = {
      for (var a in apartments) a.id: a.buildingId
    };
    
    final winterContracts = await db.select(db.winterContracts).get();
    Map<String, String> contractToBuildingMap = {
      for (var c in winterContracts) c.id: aptToBuildingMap[c.apartmentId] ?? ''
    };

    final winterPayments = await db.select(db.winterPayments).get();

    double totalRevenue = 0;
    double totalExpenses = 0;
    List<Transaction> transactions = [];

    for (var e in expenses) {
      final actualAmount = e.amountEgp - e.discountEgp;
      totalExpenses += actualAmount;
      transactions.add(Transaction(
        date: e.expenseDate,
        description: 'مصروف: ${e.expenseType}',
        amount: actualAmount,
        isRevenue: false,
        paymentMethod: 'cash', // Expenses default to cash for now
        buildingId: e.buildingId,
      ));
    }

    for (var b in summerBookings) {
      totalRevenue += b.amountPaidEgp;
      transactions.add(Transaction(
        date: b.createdAt,
        description: 'حجز صيفي: ${b.guestName}',
        amount: b.amountPaidEgp,
        isRevenue: true,
        paymentMethod: b.paymentMethod,
        buildingId: aptToBuildingMap[b.apartmentId],
      ));
    }

    for (var p in winterPayments) {
      totalRevenue += p.amountEgp;
      transactions.add(Transaction(
        date: p.paymentDate,
        description: 'دفعة شتوية',
        amount: p.amountEgp,
        isRevenue: true,
        paymentMethod: p.paymentMethod,
        buildingId: contractToBuildingMap[p.contractId],
      ));
    }

    transactions.sort((a, b) => b.date.compareTo(a.date));

    return FinancialSummary(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: totalRevenue - totalExpenses,
      transactions: transactions,
    );
  });
});
