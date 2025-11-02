import 'package:equatable/equatable.dart';

abstract class BaseError extends Equatable {}

class StringError extends BaseError {
  final String error;
  StringError({required this.error});
  @override
  List<Object?> get props => [error];
}
