import '../../../../core/errors/failures.dart';
import '../entities/currency_pair.dart';
import '../entities/exchange_rate_trend.dart';

abstract class ExchangeRateRepository {
  Future<Either<Failure, ExchangeRateTrend>> getTrend({
    required CurrencyPair pair,
    required int days,
  });
}
