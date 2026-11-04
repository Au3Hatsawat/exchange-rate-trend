import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/trend_calculator.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/exchange_rate_trend.dart';
import '../../domain/entities/rate_point.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../datasources/exchange_rate_local_datasource.dart';
import '../datasources/exchange_rate_remote_datasource.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final ExchangeRateRemoteDataSource remoteDataSource;
  final ExchangeRateLocalDataSource localDataSource;

  ExchangeRateRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ExchangeRateTrend>> getTrend({
    required CurrencyPair pair,
    required int days,
  }) async {
    final range = DateFormatter.calculateDateRange(days: days);
    final cacheKey = '${pair.base}_${pair.quote}_${days}_${range.to}';

    // 1. Try Cache
    try {
      final cached = localDataSource.getCachedRates(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return Right(_buildTrend(pair: pair, days: days, points: cached));
      }
    } catch (_) {
      // Graceful fallback to remote on CacheException (TC-6.7)
    }

    // 2. Fetch from Remote
    try {
      final remotePoints = await remoteDataSource.getRates(
        pair: pair,
        from: range.from,
        to: range.to,
      );

      // Save to cache
      try {
        localDataSource.cacheRates(cacheKey, remotePoints);
      } catch (_) {
        // Silently continue if caching fails
      }

      return Right(_buildTrend(pair: pair, days: days, points: remotePoints));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on EmptyDataException catch (e) {
      return Left(EmptyDataFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  ExchangeRateTrend _buildTrend({
    required CurrencyPair pair,
    required int days,
    required List<RatePoint> points,
  }) {
    final firstRate = points.first.rate;
    final lastRate = points.last.rate;
    final changePercentage = TrendCalculator.calculateChangePercentage(
      firstRate: firstRate,
      lastRate: lastRate,
    );
    final trendDirection = TrendCalculator.resolveTrendDirection(changePercentage);
    final maxRate = TrendCalculator.findMaxRate(points);
    final minRate = TrendCalculator.findMinRate(points);

    return ExchangeRateTrend(
      pair: pair,
      days: days,
      points: points,
      maxRate: maxRate,
      minRate: minRate,
      changePercentage: changePercentage,
      trendDirection: trendDirection,
    );
  }
}
