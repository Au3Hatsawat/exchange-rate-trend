import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/currency_pair.dart';
import '../models/rate_point_model.dart';

abstract class ExchangeRateRemoteDataSource {
  Future<List<RatePointModel>> getRates({
    required CurrencyPair pair,
    required String from,
    required String to,
  });
}

class ExchangeRateRemoteDataSourceImpl implements ExchangeRateRemoteDataSource {
  final Dio _dio;

  ExchangeRateRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? DioClient.createDio();

  @override
  Future<List<RatePointModel>> getRates({
    required CurrencyPair pair,
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.rates,
        queryParameters: {
          'from': from,
          'to': to,
          'base': pair.base,
          'quotes': pair.quote,
        },
      );

      final data = response.data;
      if (data is List) {
        if (data.isEmpty) {
          throw const EmptyDataException('ไม่มีข้อมูลในช่วงนี้');
        }
        return RatePointModel.fromJsonList(data);
      } else {
        throw const ServerException('รูปแบบข้อมูลไม่ถูกต้อง');
      }
    } on EmptyDataException {
      rethrow;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          throw const NetworkException('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
        case DioExceptionType.badResponse:
          final message = (e.response?.data is Map && (e.response?.data['message'] != null))
              ? e.response?.data['message'].toString() ?? 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์'
              : 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์';
          throw ServerException(message);
        case DioExceptionType.cancel:
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
        default:
          throw ServerException(e.message ?? 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
