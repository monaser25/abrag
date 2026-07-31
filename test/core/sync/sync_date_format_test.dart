import 'package:flutter_test/flutter_test.dart';

import 'package:abrag/core/sync/sync_engine.dart';

/// Regression tests for the date-only sync columns.
///
/// `check_in_date`, `check_out_date` and friends are Postgres `date` columns,
/// so the server drops any time part. Sending `.toUtc().toIso8601String()`
/// silently moved the day backwards for any local time inside the UTC offset
/// (a 01:00 Cairo booking became the previous day), which showed up as guests
/// being asked to check out a day early.
void main() {
  String expectedFor(DateTime local) {
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  test('keeps the local calendar day for an after-midnight booking', () {
    // The case that broke: booked at 01:00, which used to serialise as the
    // previous day once converted to UTC.
    final checkIn = DateTime(2026, 7, 31, 1, 0);
    expect(formatLocalDateOnly(checkIn), expectedFor(checkIn));
    expect(formatLocalDateOnly(checkIn), '2026-07-31');
  });

  test('keeps the local calendar day across the whole 24 hours', () {
    for (var hour = 0; hour < 24; hour++) {
      final value = DateTime(2026, 7, 31, hour, 30);
      expect(
        formatLocalDateOnly(value),
        '2026-07-31',
        reason: 'hour $hour must not roll the day over',
      );
    }
  });

  test('round trip is stable, so repeated edits never drift', () {
    // A pulled `date` comes back as local midnight. Re-pushing it must produce
    // the same day, otherwise every edit walks the booking one day backwards.
    var value = DateTime(2026, 7, 31);
    for (var i = 0; i < 5; i++) {
      final pushed = formatLocalDateOnly(value);
      expect(pushed, '2026-07-31', reason: 'drifted on round trip $i');
      value = DateTime.parse(pushed); // what the pull does
    }
  });

  test('a UTC instant is reported as its local calendar day', () {
    final utc = DateTime.utc(2026, 7, 30, 22, 0);
    expect(formatLocalDateOnly(utc), expectedFor(utc.toLocal()));
  });

  test('pads single-digit months and days', () {
    expect(formatLocalDateOnly(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
  });
}
