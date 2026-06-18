// lib/model/result.dart
//
// Sealed result type used across repository → viewmodel boundary.
// No more try/catch scattered in ViewModels.

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success<T> s => s.data,
    Failure<T> _ => null,
  };

  String? get errorOrNull => switch (this) {
    Success<T> _ => null,
    Failure<T> f => f.message,
  };
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}
