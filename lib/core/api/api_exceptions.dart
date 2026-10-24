import 'package:dio/dio.dart';

/// Structured application exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timed out. Please check your internet connection.',
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Unable to connect to server. Ensure backend is running.',
          statusCode: 503,
        );

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String errorMessage = 'Something went wrong. Please try again.';

        if (data is Map<String, dynamic>) {
          if (data['error'] != null) {
            errorMessage = data['error'].toString();
          } else if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }

        switch (status) {
          case 400:
            return ApiException(
              message: errorMessage.isNotEmpty ? errorMessage : 'Invalid request data.',
              statusCode: 400,
              details: data,
            );
          case 401:
            return const ApiException(
              message: 'Session expired or invalid credentials. Please log in again.',
              statusCode: 401,
            );
          case 403:
            return const ApiException(
              message: 'Access denied. Administrator privileges required.',
              statusCode: 403,
            );
          case 404:
            return ApiException(
              message: errorMessage.isNotEmpty ? errorMessage : 'Requested resource not found.',
              statusCode: 404,
            );
          case 409:
            return ApiException(
              message: errorMessage.isNotEmpty ? errorMessage : 'Conflict occurred.',
              statusCode: 409,
            );
          case 500:
            return const ApiException(
              message: 'Internal server error. Please try again later.',
              statusCode: 500,
            );
          default:
            return ApiException(
              message: errorMessage,
              statusCode: status,
              details: data,
            );
        }

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
        );

      case DioExceptionType.unknown:
      default:
        return const ApiException(
          message: 'Network error. Please check your connection.',
        );
    }
  }

  @override
  String toString() => message;
}
