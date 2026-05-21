import 'package:flutter_test/flutter_test.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';

void main() {
  test('empty wedding data starts with zero totals', () {
    final data = WeddingData.empty();

    expect(data.totalBudget, 0);
    expect(data.paid, 0);
    expect(data.pending, 0);
    expect(data.openReminders, 0);
  });

  test('daysUntilDate compares calendar days only', () {
    final now = DateTime(2026, 5, 19, 23, 30);

    expect(daysUntilDate(DateTime(2026, 5, 19), from: now), 0);
    expect(daysUntilDate(DateTime(2026, 5, 20), from: now), 1);
    expect(daysUntilDate(DateTime(2026, 7, 18), from: now), 60);
  });
}
