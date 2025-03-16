// From Flutter's example at https://github.com/flutter/samples/blob/main/compass_app/app/lib/utils/result.dart
/// Unified interface for returning result of an action. Can be either [Ok] or [Error];
sealed class Result<T> {
  const Result();

  /// Creates a [Result] with the desired data.
  const factory Result.ok(T value) = Ok._;

  /// Creates a [Result] which is an error.
  const factory Result.error(Exception error) = Error._;
}

final class Ok<T> extends Result<T> {
  final T value;

  const Ok._(this.value);

  @override
  String toString() => 'Result<$T>, ok => $value';
}

final class Error<T> extends Result<T> {
  final Exception error;

  const Error._(this.error);

  @override
  String toString() => 'Result<$T>, error => $error';
}
