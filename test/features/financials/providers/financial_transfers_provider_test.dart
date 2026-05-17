import 'package:abrag/core/database/database.dart';
import 'package:abrag/features/financials/presentation/providers/expenses_controller.dart';
import 'package:abrag/features/financials/presentation/providers/financial_transfers_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedCashRevenue(double amount) async {
    final now = DateTime(2026, 5, 17);
    await db.into(db.buildings).insert(
          BuildingsCompanion.insert(
            id: 'building-1',
            name: 'برج 1',
            createdAt: now,
          ),
        );
    await db.into(db.apartments).insert(
          ApartmentsCompanion.insert(
            id: 'apartment-1',
            buildingId: 'building-1',
            apartmentNumber: '101',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.summerBookings).insert(
          SummerBookingsCompanion.insert(
            id: 'booking-1',
            apartmentId: 'apartment-1',
            guestName: 'أحمد',
            checkInDate: now,
            checkOutDate: now.add(const Duration(days: 2)),
            totalPriceEgp: amount,
            amountPaidEgp: Value(amount),
            paymentMethod: const Value('cash'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('adds internal transfer between payment accounts', () async {
    final controller = FinancialTransfersController(db);
    await seedCashRevenue(1000);

    await controller.addTransfer(
      fromAccount: 'cash',
      toAccount: 'instapay',
      amount: 750,
      date: DateTime(2026, 5, 17),
      notes: 'نقل نقدية للخزنة',
    );

    final transfers = await db.select(db.financialTransfers).get();
    expect(transfers, hasLength(1));
    expect(transfers.single.fromAccount, 'cash');
    expect(transfers.single.toAccount, 'instapay');
    expect(transfers.single.amountEgp, 750);
  });

  test('rejects transfer to the same account', () async {
    final controller = FinancialTransfersController(db);

    await controller.addTransfer(
      fromAccount: 'cash',
      toAccount: 'cash',
      amount: 100,
      date: DateTime(2026, 5, 17),
    );

    expect(await db.select(db.financialTransfers).get(), isEmpty);
    expect(controller.state.toString(), contains('AsyncError'));
  });

  test('rejects transfer when source balance is insufficient', () async {
    final controller = FinancialTransfersController(db);

    await controller.addTransfer(
      fromAccount: 'cash',
      toAccount: 'instapay',
      amount: 100,
      date: DateTime(2026, 5, 17),
    );

    expect(await db.select(db.financialTransfers).get(), isEmpty);
    expect(controller.state.toString(), contains('AsyncError'));
  });

  test('stores expense payment method', () async {
    final controller = ExpensesController(db);

    await controller.addExpense(
      expenseType: 'cleaning',
      amount: 250,
      paymentMethod: 'vodafone_cash',
      date: DateTime(2026, 5, 17),
      description: 'أدوات نظافة',
    );

    final expenses = await db.select(db.expenses).get();
    expect(expenses, hasLength(1));
    expect(expenses.single.paymentMethod, 'vodafone_cash');
  });
}
