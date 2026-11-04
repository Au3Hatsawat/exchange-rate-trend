import 'package:equatable/equatable.dart';

class CurrencyPair extends Equatable {
  final String base;
  final String quote;

  const CurrencyPair({
    required this.base,
    required this.quote,
  });

  static const defaultPair = CurrencyPair(base: 'USD', quote: 'THB');

  @override
  List<Object?> get props => [base, quote];
}
