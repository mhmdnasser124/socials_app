import 'package:dartz/dartz.dart';
import '../error/base_error.dart';

typedef FutureEither<T> = Future<Either<BaseError, T>>;
typedef ErrorDictionary = List<MapEntry<String, String?>>;

class Entry<T, S> {
  final T? first;
  final S? second;
  Entry(this.first, this.second);
}