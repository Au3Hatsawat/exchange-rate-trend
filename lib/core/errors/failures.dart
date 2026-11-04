import 'package:equatable/equatable.dart';

/// Lightweight Either implementation รองรับ Pattern Matching ใน Dart 3
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) => onLeft(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) => onRight(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'ดึงข้อมูลไม่สำเร็จ']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้']);
}

class EmptyDataFailure extends Failure {
  const EmptyDataFailure([super.message = 'ไม่มีข้อมูลในช่วงนี้']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'เกิดข้อผิดพลาดของระบบแคช']);
}
