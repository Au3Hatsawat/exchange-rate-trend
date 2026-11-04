import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter.formatThaiShortDate (TC-Unit-1)', () {
    test('TC-Unit-1.1: formatThaiShortDate: should format single-digit day and middle month correctly', () {
      // Given: 5 กันยายน 2026
      final date = DateTime(2026, 9, 5);

      // When: formatThaiShortDate ถูกเรียก
      final result = DateFormatter.formatThaiShortDate(date);

      // Then: ได้ผลลัพธ์เป็น '5 ก.ย.' (วันที่หลักเดียวไม่มี 0 นำหน้า และเดือนย่อถูกต้อง)
      expect(result, '5 ก.ย.');
    });

    test('TC-Unit-1.2: formatThaiShortDate: should format AC-3 benchmark date 10 Oct accurately', () {
      // Given: 10 ตุลาคม 2026 (Benchmark Date ของ AC-3 / Screen 15-1a)
      final date = DateTime(2026, 10, 10);

      // When: formatThaiShortDate ถูกเรียก
      final result = DateFormatter.formatThaiShortDate(date);

      // Then: ได้ผลลัพธ์เป็น '10 ต.ค.' ตรงตามเกณฑ์ AC-3
      expect(result, '10 ต.ค.');
    });

    test('TC-Unit-1.3: formatThaiShortDate: should map all 12 Thai months accurately', () {
      // Given: รายการชื่อเดือนย่อภาษาไทยทั้ง 12 เดือนตามลำดับ (ม.ค. - ธ.ค.)
      const expectedMonths = [
        'ม.ค.',
        'ก.พ.',
        'มี.ค.',
        'เม.ย.',
        'พ.ค.',
        'มิ.ย.',
        'ก.ค.',
        'ส.ค.',
        'ก.ย.',
        'ต.ค.',
        'พ.ย.',
        'ธ.ค.',
      ];

      // When & Then: ตรวจสอบทุกเดือนตั้งแต่มกราคมถึงธันวาคม
      for (int m = 1; m <= 12; m++) {
        final date = DateTime(2026, m, 15);
        final result = DateFormatter.formatThaiShortDate(date);
        expect(result, '15 ${expectedMonths[m - 1]}');
      }
    });

    test('TC-Unit-1.4: formatThaiShortDate: should format leap year date 29 Feb accurately', () {
      // Given: วันที่ 29 กุมภาพันธ์ ของปีอธิกสุรทิน (Leap Year 2024)
      final date = DateTime(2024, 2, 29);

      // When: formatThaiShortDate ถูกเรียก
      final result = DateFormatter.formatThaiShortDate(date);

      // Then: ได้ผลลัพธ์เป็น '29 ก.พ.'
      expect(result, '29 ก.พ.');
    });

    test('TC-Unit-1.5: formatThaiShortDate: should format start and end of year dates accurately', () {
      // Given: วันแรกของปี (1 ม.ค.) และวันสิ้นปี (31 ธ.ค.)
      final newYearDay = DateTime(2026, 1, 1);
      final newYearEve = DateTime(2026, 12, 31);

      // When: formatThaiShortDate ถูกเรียก
      final resultStart = DateFormatter.formatThaiShortDate(newYearDay);
      final resultEnd = DateFormatter.formatThaiShortDate(newYearEve);

      // Then: แสดงผลถูกต้องทั้งสองกรณี
      expect(resultStart, '1 ม.ค.');
      expect(resultEnd, '31 ธ.ค.');
    });
  });
}
