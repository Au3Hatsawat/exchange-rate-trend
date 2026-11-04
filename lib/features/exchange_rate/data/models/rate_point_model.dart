import '../../domain/entities/rate_point.dart';

class RatePointModel extends RatePoint {
  const RatePointModel({
    required super.date,
    required super.rate,
    required super.base,
    required super.quote,
  });

  factory RatePointModel.fromJson(Map<String, dynamic> json) {
    return RatePointModel(
      date: DateTime.parse(json['date'] as String),
      rate: (json['rate'] as num).toDouble(),
      base: (json['base'] as String?) ?? '',
      quote: (json['quote'] as String?) ?? '',
    );
  }

  static List<RatePointModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => RatePointModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return {
      'date': '$y-$m-$d',
      'rate': rate,
      'base': base,
      'quote': quote,
    };
  }
}
