import 'package:dio/dio.dart';

/// Sealed class representing the result of a network/data operation.
sealed class DataState<T> {
  final T? data;
  final String? message;
  final DioException? exception;
  final int? statusCode;

  const DataState({
    this.data,
    this.message,
    this.exception,
    this.statusCode,
  });

  /// True if the operation succeeded.
  bool get isSuccess => this is DataStateSuccess<T>;

  /// True if the operation failed.
  bool get isError => this is DataStateError<T>;
}

/// Represents a successful data state holding data of type [T].
class DataStateSuccess<T> extends DataState<T> {
  const DataStateSuccess(T data) : super(data: data);

  @override
  T get data => super.data as T;
}

/// Represents an error state holding a user-friendly [message],
/// optional underlying [exception], and HTTP [statusCode].
class DataStateError<T> extends DataState<T> {
  DataStateError(
    String message, {
    super.exception,
    int? statusCode,
  }) : super(
          message: message,
          statusCode: statusCode ?? exception?.response?.statusCode,
        );

  @override
  String get message => super.message ?? 'Terjadi kesalahan';
}

