import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    group('formatYMD', () {
      test('TC-2.1: formatYMD: should format DateTime to YYYY-MM-DD with zero-padding', () {
        // Arrange
        final date = DateTime(2026, 9, 5);

        // Act
        final formatted = DateFormatter.formatYMD(date);

        // Assert
        expect(formatted, '2026-09-05');
      });

      test('formatYMD: should format two-digit month and day correctly', () {
        // Arrange
        final date = DateTime(2026, 12, 25);

        // Act
        final formatted = DateFormatter.formatYMD(date);

        // Assert
        expect(formatted, '2026-12-25');
      });
    });

    group('calculateDateRange', () {
      test('TC-2.2: calculateDateRange: should return correct from/to for 30 days (default)', () {
        // Arrange
        final fixedNow = DateTime(2026, 10, 29);

        // Act
        final result = DateFormatter.calculateDateRange(days: 30, now: fixedNow);

        // Assert
        expect(result.from, '2026-09-29');
        expect(result.to, '2026-10-29');
      });

      test('TC-2.3: calculateDateRange: should return correct from/to for 7 days', () {
        // Arrange
        final fixedNow = DateTime(2026, 10, 29);

        // Act
        final result = DateFormatter.calculateDateRange(days: 7, now: fixedNow);

        // Assert
        expect(result.from, '2026-10-22');
        expect(result.to, '2026-10-29');
      });

      test('TC-2.4: calculateDateRange: should return correct from/to for 90 days', () {
        // Arrange
        final fixedNow = DateTime(2026, 10, 29);

        // Act
        final result = DateFormatter.calculateDateRange(days: 90, now: fixedNow);

        // Assert
        expect(result.from, '2026-07-31');
        expect(result.to, '2026-10-29');
      });

      test('TC-2.5: calculateDateRange: should cross year/month boundaries accurately', () {
        // Arrange
        final fixedNow = DateTime(2026, 1, 15);

        // Act
        final result = DateFormatter.calculateDateRange(days: 30, now: fixedNow);

        // Assert
        expect(result.from, '2025-12-16');
        expect(result.to, '2026-01-15');
      });
    });
  });
}
