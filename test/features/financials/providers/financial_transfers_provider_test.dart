import 'package:abrag/core/database/database.dart';
import 'package:abrag/core/database/tables.dart';
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

  Future<void> seedCashRevenue(
    double amount, {
    String brokerCommissionType = 'none',
    double brokerCommissionFixedEgp = 0,
    double brokerCommissionPercentage = 10,
    double? brokerCommissionAmountEgp,
    double brokerCommissionPaidCashEgp = 0,
    double brokerCommissionPaidVodafoneEgp = 0,
    double brokerCommissionPaidInstapayEgp = 0,
  }) async {
    final now = DateTime(2026, 5, 17);
    await db
        .into(db.buildings)
        .insert(
          BuildingsCompanion.insert(
            id: 'building-1',
            name: 'برج 1',
            createdAt: now,
          ),
        );
    await db
        .into(db.apartments)
        .insert(
          ApartmentsCompanion.insert(
            id: 'apartment-1',
            buildingId: 'building-1',
            apartmentNumber: '101',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.summerBookings)
        .insert(
          SummerBookingsCompanion.insert(
            id: 'booking-1',
            apartmentId: 'apartment-1',
            guestName: 'أحمد',
            checkInDate: now,
            checkOutDate: now.add(const Duration(days: 2)),
            totalPriceEgp: amount,
            amountPaidEgp: Value(amount),
            paymentMethod: const Value('cash'),
            brokerCommissionType: Value(brokerCommissionType),
            brokerCommissionFixedEgp: Value(brokerCommissionFixedEgp),
            brokerCommissionPercentage: Value(brokerCommissionPercentage),
            brokerCommissionAmountEgp: Value(brokerCommissionAmountEgp),
            brokerCommissionPaidCashEgp: Value(brokerCommissionPaidCashEgp),
            brokerCommissionPaidVodafoneEgp: Value(
              brokerCommissionPaidVodafoneEgp,
            ),
            brokerCommissionPaidInstapayEgp: Value(
              brokerCommissionPaidInstapayEgp,
            ),
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

  test(
    'cash balance uses summer booking payment net of broker commission',
    () async {
      final now = DateTime(2026, 5, 17);
      await seedCashRevenue(
        1000,
        brokerCommissionType: 'fixed',
        brokerCommissionFixedEgp: 120,
      );
      await db
          .into(db.summerBookings)
          .insert(
            SummerBookingsCompanion.insert(
              id: 'booking-2',
              apartmentId: 'apartment-1',
              guestName: 'محمد',
              checkInDate: now,
              checkOutDate: now.add(const Duration(days: 2)),
              totalPriceEgp: 100,
              amountPaidEgp: const Value(100),
              paymentMethod: const Value('cash'),
              brokerCommissionType: const Value('fixed'),
              brokerCommissionFixedEgp: const Value(150),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final balances = await buildTreasuryBalances(db, 'summer_2026');

      expect(balances['cash'], closeTo(880, 0.001));
    },
  );

  test('attributes split summer payments to their actual methods', () async {
    final now = DateTime(2026, 5, 17);
    await seedCashRevenue(
      1500,
      brokerCommissionType: 'fixed',
      brokerCommissionFixedEgp: 100,
      brokerCommissionPaidCashEgp: 20,
      brokerCommissionPaidVodafoneEgp: 30,
      brokerCommissionPaidInstapayEgp: 50,
    );
    await db
        .into(db.bookingPayments)
        .insert(
          BookingPaymentsCompanion.insert(
            id: 'booking-payment-cash',
            bookingId: 'booking-1',
            amountEgp: 500,
            paymentMethod: const Value('cash'),
            paymentDate: now,
            createdAt: now,
          ),
        );
    await db
        .into(db.bookingPayments)
        .insert(
          BookingPaymentsCompanion.insert(
            id: 'booking-payment-vodafone',
            bookingId: 'booking-1',
            amountEgp: 1000,
            paymentMethod: const Value('vodafone_cash'),
            paymentDate: now,
            createdAt: now,
          ),
        );

    final balances = await buildTreasuryBalances(db, 'summer_2026');

    expect(balances['cash'], closeTo(480, 0.001));
    expect(balances['vodafone_cash'], closeTo(970, 0.001));
    expect(balances['instapay'], closeTo(-50, 0.001));
  });

  test('deletes a transfer and records removal', () async {
    final controller = FinancialTransfersController(db);
    await seedCashRevenue(1000);

    await controller.addTransfer(
      fromAccount: 'cash',
      toAccount: 'instapay',
      amount: 300,
      date: DateTime(2026, 5, 17),
    );
    final transfer = (await db.select(db.financialTransfers).get()).single;

    await controller.deleteTransfer(transfer.id);

    // Soft-delete: the row stays locally marked pendingDelete (the sync engine
    // is what removes it from Supabase then locally), but it must vanish from
    // the treasury balances immediately.
    final remaining = (await db.select(db.financialTransfers).get()).single;
    expect(remaining.syncStatus, SyncStatus.pendingDelete);
    final balances = await buildTreasuryBalances(db, 'summer_2026');
    expect(balances['cash'], closeTo(1000, 0.001));
    expect(balances['instapay'], closeTo(0, 0.001));
    final logs = await db.select(db.auditLogs).get();
    expect(logs.any((log) => log.action == 'delete_transfer'), isTrue);
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
