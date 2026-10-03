import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper around [Dio] that:
///  - attaches the JWT to every request (same token the Angular app gets
///    back from POST /auth/login)
///  - normalizes every failure into an [ApiException] with the message the
///    .NET API sent back (e.g. `{ "message": "Invalid credentials" }`)
///  - calls [onUnauthorized] once on a 401 so the app can log the user out
class ApiClient {
  ApiClient({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage,
        _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Set from the auth layer; fired once whenever the backend rejects the
  /// current token (expired / revoked) so the app can route back to login.
  void Function()? onUnauthorized;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: _clean(query));
      return _asMap(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// For list endpoints that return a raw JSON array at the top level.
  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: _clean(query));
      if (res.data is List) return res.data as List<dynamic>;
      return const [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    try {
      final res = await _dio.post(path, data: data);
      return _asMap(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {Object? data}) async {
    try {
      final res = await _dio.put(path, data: data);
      return _asMap(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final res = await _dio.delete(path);
      return _asMap(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Multipart upload for POST /files/upload-pdf (matches FilesController's
  /// `IFormFile file` parameter name exactly).
  Future<String> uploadPdf(String filePath, String fileName) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final res = await _dio.post(ApiConstants.uploadPdf, data: form);
      final map = _asMap(res.data);
      return map['fileUrl'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// For endpoints that return a binary file (the /reports/* endpoints
  /// return .xlsx / .pdf bytes directly, not JSON).
  Future<List<int>> downloadBytes(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get<List<int>>(
        path,
        queryParameters: _clean(query),
        options: Options(responseType: ResponseType.bytes),
      );
      return res.data ?? const [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Map<String, dynamic> _clean(Map<String, dynamic>? query) {
    if (query == null) return {};
    final out = <String, dynamic>{};
    query.forEach((k, v) {
      if (v != null) out[k] = v;
    });
    return out;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
