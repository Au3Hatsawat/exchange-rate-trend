import 'package:equatable/equatable.dart';

class RatePoint extends Equatable {
  final DateTime date;
  final double rate;
  final String base;
  final String quote;

  const RatePoint({
    required this.date,
    required this.rate,
    required this.base,
    required this.quote,
  });

  @override
  List<Object?> get props => [date, rate, base, quote];
}
