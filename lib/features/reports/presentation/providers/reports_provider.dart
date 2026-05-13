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

  Transaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.isRevenue,
  });
}

final financialReportProvider = StreamProvider<FinancialSummary>((ref) {
  final db = ref.watch(databaseProvider);

  // Combine streams using RxDart if needed, or just watch them directly
  // For simplicity without rxdart, we can query them together in an async generator.
  
  return Stream.periodic(const Duration(milliseconds: 500)).asyncMap((_) async {
    final expenses = await db.select(db.expenses).get();
    final summerBookings = await db.select(db.summerBookings).get();
    final winterPayments = await db.select(db.winterPayments).get();

    double totalRevenue = 0;
    double totalExpenses = 0;
    List<Transaction> transactions = [];

    for (var e in expenses) {
      totalExpenses += e.amountEgp;
      transactions.add(Transaction(
        date: e.expenseDate,
        description: 'مصروف: ${e.expenseType}',
        amount: e.amountEgp,
        isRevenue: false,
      ));
    }

    for (var b in summerBookings) {
      totalRevenue += b.totalPriceEgp; // or amountPaidEgp
      transactions.add(Transaction(
        date: b.createdAt, // Or checkout date
        description: 'حجز صيفي: ${b.guestName}',
        amount: b.totalPriceEgp,
        isRevenue: true,
      ));
    }

    for (var p in winterPayments) {
      totalRevenue += p.amountEgp;
      transactions.add(Transaction(
        date: p.paymentDate,
        description: 'دفعة شتوية',
        amount: p.amountEgp,
        isRevenue: true,
      ));
    }

    // Sort transactions by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return FinancialSummary(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: totalRevenue - totalExpenses,
      transactions: transactions,
    );
  });
});
