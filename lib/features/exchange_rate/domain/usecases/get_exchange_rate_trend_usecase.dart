import '../../../../core/errors/failures.dart';
import '../entities/currency_pair.dart';
import '../entities/exchange_rate_trend.dart';
import '../repositories/exchange_rate_repository.dart';

class GetExchangeRateTrendUseCase {
  final ExchangeRateRepository repository;

  GetExchangeRateTrendUseCase(this.repository);

  Future<Either<Failure, ExchangeRateTrend>> call({
    required CurrencyPair pair,
    required int days,
  }) {
    return repository.getTrend(pair: pair, days: days);
  }
}
