import '../models/rate_point_model.dart';

abstract class ExchangeRateLocalDataSource {
  List<RatePointModel>? getCachedRates(String key);
  void cacheRates(String key, List<RatePointModel> data);
  void clearCache();
}

class ExchangeRateLocalDataSourceImpl implements ExchangeRateLocalDataSource {
  final Map<String, List<RatePointModel>> _cache = {};

  @override
  List<RatePointModel>? getCachedRates(String key) {
    return _cache[key];
  }

  @override
  void cacheRates(String key, List<RatePointModel> data) {
    _cache[key] = List.unmodifiable(data);
  }

  @override
  void clearCache() {
    _cache.clear();
  }
}
