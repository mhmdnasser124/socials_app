import 'types.dart';

/// Base contract for declarative use cases.
abstract class UseCase<T, P> {
  FutureEither<T> call(P params);
}

/// Empty params marker for use cases that do not require input.
class NoParams {
  const NoParams();
}
