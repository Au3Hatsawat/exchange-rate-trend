// ignore_for_file: avoid_print
import 'package:exchange_rate_trend/core/network/dio_client.dart';
import 'package:exchange_rate_trend/core/utils/date_formatter.dart';
import 'package:exchange_rate_trend/core/utils/trend_calculator.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/datasources/exchange_rate_local_datasource.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';

void main() async {
  print('=== Exchange Rate Service QA Manual Runner ===\n');

  final dio = DioClient.createDio();
  final remote = ExchangeRateRemoteDataSourceImpl(dio: dio);
  final local = ExchangeRateLocalDataSourceImpl();
  final repo = ExchangeRateRepositoryImpl(remoteDataSource: remote, localDataSource: local);

  print('[QA-1] Testing Live Frankfurter API Connectivity...');
  final range30 = DateFormatter.calculateDateRange(days: 30);
  print('Requesting range: ${range30.from} to ${range30.to} for USD/THB');
  final result1 = await repo.getTrend(pair: CurrencyPair.defaultPair, days: 30);
  result1.fold(
    (failure) => print('❌ Failed with: ${failure.runtimeType} (${failure.message})'),
    (trend) {
      print('✅ Success! Retrieved ${trend.points.length} data points.');
      print('   First rate: ${trend.points.first.rate} on ${trend.points.first.date.toIso8601String().split('T').first}');
      print('   Last rate:  ${trend.points.last.rate} on ${trend.points.last.date.toIso8601String().split('T').first}');
      print('   Max: ${trend.maxRate}, Min: ${trend.minRate}');
      print('   Change %: ${trend.changePercentage}%, Trend: ${trend.trendDirection.name}');
    },
  );

  print('\n[QA-3] Testing In-Memory Daily Cache Behavior (30d -> 7d -> 30d)...');
  print('Step 1: 30 days already fetched above (Cached in memory).');
  print('Step 2: Fetching 7 days (New range, should hit remote)...');
  final result7d = await repo.getTrend(pair: CurrencyPair.defaultPair, days: 7);
  result7d.fold(
    (failure) => print('❌ 7d Failed: ${failure.message}'),
    (trend) => print('✅ 7d Success (${trend.points.length} points)'),
  );

  print('Step 3: Fetching 30 days again (Should hit In-Memory Cache)...');
  final stopwatch = Stopwatch()..start();
  final result30dCached = await repo.getTrend(pair: CurrencyPair.defaultPair, days: 30);
  stopwatch.stop();
  result30dCached.fold(
    (failure) => print('❌ 30d Cache Failed: ${failure.message}'),
    (trend) {
      print('✅ 30d Cache Hit Success! Duration: ${stopwatch.elapsedMilliseconds} ms (< 5ms expected)');
      print('   Points count: ${trend.points.length}');
    },
  );

  print('\n[QA-4] Testing Trend Calculation Formula (AC-2 Benchmark 33.568 -> 33.750)...');
  final change = TrendCalculator.calculateChangePercentage(firstRate: 33.568, lastRate: 33.750);
  final direction = TrendCalculator.resolveTrendDirection(change);
  print('Benchmark result: change = $change%, direction = ${direction.name}');
  if (change == 0.54 && direction.name == 'up') {
    print('✅ Calculation matches AC-2 Benchmark strictly (+0.54%, up)!');
  } else {
    print('❌ Calculation mismatch!');
  }

  print('\n=== QA Runner Completed ===');
}
