import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/exchange_rate_local_datasource.dart';
import '../../data/datasources/exchange_rate_remote_datasource.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/rate_point.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../domain/usecases/get_exchange_rate_trend_usecase.dart';
import 'exchange_rate_state.dart';

// --- Dependency Injection Providers ---

/// 1. Dio Provider (Core Network)
final dioProvider = Provider<Dio>((ref) {
  return DioClient.createDio();
});

/// 2. Remote Data Source Provider
final remoteDataSourceProvider = Provider<ExchangeRateRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ExchangeRateRemoteDataSourceImpl(dio: dio);
});

/// 3. Local Data Source Provider (In-Memory Cache)
final localDataSourceProvider = Provider<ExchangeRateLocalDataSource>((ref) {
  return ExchangeRateLocalDataSourceImpl();
});

/// 4. Repository Provider
final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  final localDataSource = ref.watch(localDataSourceProvider);
  return ExchangeRateRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// 5. Domain Use Case Provider
final getExchangeRateTrendUseCaseProvider =
    Provider<GetExchangeRateTrendUseCase>((ref) {
      final repository = ref.watch(exchangeRateRepositoryProvider);
      return GetExchangeRateTrendUseCase(repository);
    });

/// 6. Presentation StateNotifier Provider
final exchangeRateNotifierProvider =
    StateNotifierProvider<ExchangeRateNotifier, ExchangeRateState>((ref) {
      final useCase = ref.watch(getExchangeRateTrendUseCaseProvider);
      return ExchangeRateNotifier(getExchangeRateTrendUseCase: useCase);
    });

// --- StateNotifier Implementation ---

class ExchangeRateNotifier extends StateNotifier<ExchangeRateState> {
  final GetExchangeRateTrendUseCase getExchangeRateTrendUseCase;

  ExchangeRateNotifier({required this.getExchangeRateTrendUseCase})
    : super(const ExchangeRateState());

  /// โหลดข้อมูลแนวโน้มอัตราแลกเปลี่ยน
  Future<void> loadTrend({CurrencyPair? pair, int? days}) async {
    final targetPair = pair ?? state.pair;
    final targetDays = days ?? state.selectedDays;

    state = state.copyWith(
      status: ExchangeRateStatus.loading,
      pair: targetPair,
      selectedDays: targetDays,
      selectedPoint: () => null,
      errorMessage: null,
    );

    final result = await getExchangeRateTrendUseCase(
      pair: targetPair,
      days: targetDays,
    );

    result.fold(
      (failure) {
        if (failure is EmptyDataFailure) {
          state = state.copyWith(
            status: ExchangeRateStatus.empty,
            errorMessage: failure.message,
          );
        } else {
          state = state.copyWith(
            status: ExchangeRateStatus.error,
            errorMessage: failure.message,
          );
        }
      },
      (trend) {
        state = state.copyWith(
          status: ExchangeRateStatus.success,
          trend: trend,
          selectedPoint: () => null,
          errorMessage: null,
        );
      },
    );
  }

  /// สลับช่วงเวลา 7, 30, 90 วัน (BR-2)
  void changePeriod(int days) {
    if (state.status == ExchangeRateStatus.loading) {
      return;
    }
    if (state.selectedDays == days &&
        state.status == ExchangeRateStatus.success) {
      return;
    }
    loadTrend(days: days);
  }

  /// แตะเลือกจุดบนกราฟ (Screen 15-1a / AC-3)
  void selectPoint(RatePoint? point) {
    state = state.copyWith(selectedPoint: () => point);
  }

  /// ลองดึงข้อมูลใหม่อีกครั้ง (Retry)
  void retry() {
    loadTrend(pair: state.pair, days: state.selectedDays);
  }
}
