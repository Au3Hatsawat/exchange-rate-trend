import 'package:equatable/equatable.dart';

import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/exchange_rate_trend.dart';
import '../../domain/entities/rate_point.dart';

enum ExchangeRateStatus { initial, loading, success, empty, error }

class ExchangeRateState extends Equatable {
  final ExchangeRateStatus status;
  final CurrencyPair pair;
  final int selectedDays;
  final ExchangeRateTrend? trend;
  final RatePoint? selectedPoint;
  final String? errorMessage;

  const ExchangeRateState({
    this.status = ExchangeRateStatus.initial,
    this.pair = CurrencyPair.defaultPair,
    this.selectedDays = 30,
    this.trend,
    this.selectedPoint,
    this.errorMessage,
  });

  ExchangeRateState copyWith({
    ExchangeRateStatus? status,
    CurrencyPair? pair,
    int? selectedDays,
    ExchangeRateTrend? trend,
    RatePoint? Function()? selectedPoint,
    String? errorMessage,
  }) {
    return ExchangeRateState(
      status: status ?? this.status,
      pair: pair ?? this.pair,
      selectedDays: selectedDays ?? this.selectedDays,
      trend: trend ?? this.trend,
      selectedPoint: selectedPoint != null
          ? selectedPoint()
          : this.selectedPoint,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    pair,
    selectedDays,
    trend,
    selectedPoint,
    errorMessage,
  ];
}
