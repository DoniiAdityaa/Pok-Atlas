import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/dio.dart';

import '../../utility/resource/data_state.dart';

abstract class BaseRepository {
  /// Executes a given network [request] and safely transforms it into a [DataState].
  ///
  /// Returns [DataStateSuccess] with data of type [T] when the HTTP status code is successful (2xx or 304).
  ///
  /// Returns [DataStateError] containing a readable error message, status code, and optional exception
  /// if a [DioException] or unexpected error occurs.
  @protected
  Future<DataState<T>> getStateOf<T>({
    required Future<HttpResponse<T>> Function() request,
  }) async {
    try {
      final httpResponse = await request();
      final statusCode = httpResponse.response.statusCode ?? 200;

      // Successful HTTP responses (200 - 299) and 304 (Not Modified / Cache Hit)
      if ((statusCode >= 200 && statusCode < 300) || statusCode == HttpStatus.notModified) {
        return DataStateSuccess(httpResponse.data);
      } else {
        throw DioException(
          response: httpResponse.response,
          requestOptions: httpResponse.response.requestOptions,
          message: httpResponse.response.statusMessage,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BaseRepository DioException: $error');
        debugPrint(stackTrace.toString());
      }

      return DataStateError<T>(
        mapDioExceptionToMessage(error),
        exception: error,
        statusCode: error.response?.statusCode,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BaseRepository Unexpected Exception: $error');
        debugPrint(stackTrace.toString());
      }

      return DataStateError<T>(
        'Terjadi kesalahan: ${error.toString()}',
      );
    }
  }

  /// Maps [DioException] into a user-friendly error message suitable for UI / BLoC consumption.
  @protected
  String mapDioExceptionToMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Silakan periksa jaringan internet Anda.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Permintaan tidak valid (Bad Request).';
          case 401:
            return 'Sesi tidak valid atau tidak memiliki izin akses.';
          case 403:
            return 'Akses ke data ini ditolak (Forbidden).';
          case 404:
            return 'Data tidak ditemukan (404).';
          case 429:
            return 'Terlalu banyak permintaan (Rate Limit). Silakan tunggu sebentar.';
          case 500:
          case 502:
          case 503:
          case 504:
            return 'Terjadi gangguan pada server. Silakan coba beberapa saat lagi.';
          default:
            return 'Terjadi kesalahan pada server (Kode: $statusCode).';
        }

      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';

      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';

      case DioExceptionType.badCertificate:
        return 'Sertifikat keamanan tidak valid.';

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
        }
        final msg = error.message;
        if (msg != null && msg.isNotEmpty) {
          return msg;
        }
        return 'Terjadi kesalahan yang tidak terduga.';

      default:
        return 'Terjadi kesalahan koneksi (${error.type.name}).';
    }
  }
}
