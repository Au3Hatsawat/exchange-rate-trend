class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์']);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้']);

  @override
  String toString() => 'NetworkException: $message';
}

class EmptyDataException implements Exception {
  final String message;
  const EmptyDataException([this.message = 'ไม่มีข้อมูลในช่วงนี้']);

  @override
  String toString() => 'EmptyDataException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'เกิดข้อผิดพลาดในการเข้าถึงแคช']);

  @override
  String toString() => 'CacheException: $message';
}
