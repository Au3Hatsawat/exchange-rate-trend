import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/core/errors/exceptions.dart';
import 'package:exchange_rate_trend/core/errors/failures.dart';

void main() {
  group('Exceptions toString', () {
    test('ServerException toString', () {
      const e = ServerException('error');
      expect(e.toString(), 'ServerException: error');
    });

    test('NetworkException toString', () {
      const e = NetworkException('network error');
      expect(e.toString(), 'NetworkException: network error');
    });

    test('EmptyDataException toString', () {
      const e = EmptyDataException('no data');
      expect(e.toString(), 'EmptyDataException: no data');
    });

    test('CacheException toString', () {
      const e = CacheException('cache error');
      expect(e.toString(), 'CacheException: cache error');
    });
  });

  group('Failures and Either', () {
    test('Failures props and default messages', () {
      const sf = ServerFailure();
      const nf = NetworkFailure();
      const ef = EmptyDataFailure();
      const cf = CacheFailure();

      expect(sf.props, ['ดึงข้อมูลไม่สำเร็จ']);
      expect(nf.props, ['ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้']);
      expect(ef.props, ['ไม่มีข้อมูลในช่วงนี้']);
      expect(cf.props, ['เกิดข้อผิดพลาดของระบบแคช']);
    });

    test('Either Left and Right methods', () {
      const left = Left<String, int>('error');
      const right = Right<String, int>(42);

      expect(left.isLeft, isTrue);
      expect(left.isRight, isFalse);
      expect(left.toString(), 'Left(error)');
      expect(left.hashCode, 'error'.hashCode);
      expect(left == const Left<String, int>('error'), isTrue);

      expect(right.isLeft, isFalse);
      expect(right.isRight, isTrue);
      expect(right.toString(), 'Right(42)');
      expect(right.hashCode, 42.hashCode);
      expect(right == const Right<String, int>(42), isTrue);
    });
  });
}
