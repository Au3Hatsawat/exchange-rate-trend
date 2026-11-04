import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/models/rate_point_model.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/rate_point.dart';

void main() {
  group('RatePointModel', () {
    final tRatePointModel = RatePointModel(
      date: DateTime(2026, 9, 29),
      rate: 33.568,
      base: 'USD',
      quote: 'THB',
    );

    test('TC-3.6: inheritance: should be a subclass of RatePoint entity with Equatable equality', () {
      final model1 = RatePointModel(
        date: DateTime(2026, 9, 29),
        rate: 33.568,
        base: 'USD',
        quote: 'THB',
      );
      final model2 = RatePointModel(
        date: DateTime(2026, 9, 29),
        rate: 33.568,
        base: 'USD',
        quote: 'THB',
      );

      expect(tRatePointModel, isA<RatePoint>());
      expect(model1, equals(model2));
    });

    group('fromJson', () {
      test('TC-3.1: fromJson: should parse valid Map with double rate correctly', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'date': '2026-09-29',
          'base': 'USD',
          'quote': 'THB',
          'rate': 33.568,
        };

        // Act
        final result = RatePointModel.fromJson(jsonMap);

        // Assert
        expect(result.date, DateTime(2026, 9, 29));
        expect(result.rate, 33.568);
        expect(result.base, 'USD');
        expect(result.quote, 'THB');
      });

      test('TC-3.2: fromJson: should safely convert integer rate to double', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'date': '2026-09-29',
          'rate': 34,
        };

        // Act
        final result = RatePointModel.fromJson(jsonMap);

        // Assert
        expect(result.rate, 34.0);
        expect(result.rate, isA<double>());
      });

      test('TC-3.3: fromJson: should fallback base and quote to empty string if null', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'date': '2026-09-29',
          'rate': 33.5,
        };

        // Act
        final result = RatePointModel.fromJson(jsonMap);

        // Assert
        expect(result.base, '');
        expect(result.quote, '');
      });
    });

    group('fromJsonList', () {
      test('TC-3.4: fromJsonList: should parse JSON array into List<RatePointModel> preserving order', () {
        // Arrange
        final List<dynamic> rawList = [
          {
            'date': '2026-09-29',
            'base': 'USD',
            'quote': 'THB',
            'rate': 33.568,
          },
          {
            'date': '2026-09-30',
            'base': 'USD',
            'quote': 'THB',
            'rate': 33.551,
          },
          {
            'date': '2026-10-01',
            'base': 'USD',
            'quote': 'THB',
            'rate': 33.750,
          },
        ];

        // Act
        final list = RatePointModel.fromJsonList(rawList);

        // Assert
        expect(list.length, 3);
        expect(list[0].date, DateTime(2026, 9, 29));
        expect(list[0].rate, 33.568);
        expect(list[1].date, DateTime(2026, 9, 30));
        expect(list[1].rate, 33.551);
        expect(list[2].date, DateTime(2026, 10, 1));
        expect(list[2].rate, 33.750);
      });
    });

    group('toJson', () {
      test('TC-3.5: toJson: should convert model back to Map with YYYY-MM-DD date', () {
        // Act
        final json = tRatePointModel.toJson();

        // Assert
        expect(json['date'], '2026-09-29');
        expect(json['rate'], 33.568);
        expect(json['base'], 'USD');
        expect(json['quote'], 'THB');
      });
    });
  });
}
