import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Error shape returned by the Go backend's httpx.Fail helper.
class ApiException implements Exception {
  ApiException(this.statusCode, this.code, this.message);

  final int? statusCode;
  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Thin dio wrapper for the public customer endpoints (`/app/...`).
/// No auth yet: the customer menu is readable without login.
class ApiClient {
  ApiClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onError: (err, handler) => handler.reject(_normalize(err)),
      ),
    );
  }

  final Dio dio;

  static DioException _normalize(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      final body = data['error'] as Map<String, dynamic>;
      return err.copyWith(
        error: ApiException(
          status,
          body['code']?.toString() ?? 'error',
          _messageFor(status, body['message']?.toString()),
        ),
      );
    }
    if (status != null) {
      return err.copyWith(
        error: ApiException(status, 'http_$status', _messageFor(status, null)),
      );
    }
    return err.copyWith(
      error: ApiException(
        null,
        'network',
        'Không kết nối được máy chủ, kiểm tra mạng và thử lại.',
      ),
    );
  }

  static String _messageFor(int? status, String? fallback) => switch (status) {
    400 || 404 => 'Không tìm thấy quán này. Hãy quét lại mã QR tại quầy.',
    _ when status != null && status >= 500 =>
      'Máy chủ đang bận, vui lòng thử lại sau.',
    _ => fallback ?? 'Đã có lỗi xảy ra, vui lòng thử lại.',
  };
}

/// Unwraps the ApiException that [ApiClient] attaches to dio errors.
Object unwrapApiError(Object error) =>
    error is DioException && error.error is ApiException ? error.error! : error;
