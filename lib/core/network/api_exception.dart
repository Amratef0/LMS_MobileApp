import 'package:dio/dio.dart';

/// Wraps a failed API call with the human-readable message the .NET backend
/// sent back, e.g. `BadRequest(new { message = "Already submitted" })`.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map && data['message'] is String) {
      return ApiException(data['message'] as String, statusCode: status);
    }
    if (data is Map && data['title'] is String) {
      // ASP.NET's default ValidationProblemDetails shape.
      return ApiException(data['title'] as String, statusCode: status);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection to the server timed out. Please try again.');
      case DioExceptionType.connectionError:
        return ApiException(
            'Could not reach the server. Make sure the API is running and the address in ApiConstants.baseUrl is correct.');
      default:
        break;
    }

    if (status == 401) return ApiException('Invalid credentials or your session has expired.', statusCode: 401);
    if (status == 403) return ApiException('You do not have permission to do this.', statusCode: 403);
    if (status == 404) return ApiException('Item not found.', statusCode: 404);
    return ApiException('Something went wrong. Please try again.', statusCode: status);
  }

  @override
  String toString() => message;
}
