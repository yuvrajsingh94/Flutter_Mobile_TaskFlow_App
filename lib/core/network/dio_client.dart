import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:taskflow_flutter/core/config/api_config.dart';
import 'package:taskflow_flutter/core/constants/api_endpoints.dart';
import 'package:taskflow_flutter/core/storage/storage_service.dart';

typedef UnauthorizedCallback = void Function();

class DioClient {
  late final Dio _dio;
  final StorageService _storage;
  UnauthorizedCallback? onUnauthorized;

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshQueue = [];

  DioClient({required StorageService storage}) : _storage = storage {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Dynamic base URL check in case user modified it at runtime
          if (!options.path.startsWith('http')) {
            options.baseUrl = ApiConfig.baseUrl;
          }

          // Inject token if available
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final response = error.response;

          // Check for account blocked/deleted status
          if (response?.statusCode == 401 || response?.statusCode == 403) {
            final data = response?.data;
            if (data is Map<String, dynamic>) {
              final msg = data['message']?.toString().toLowerCase() ?? '';
              if (msg.contains('no longer exists') ||
                  msg.contains('blocked') ||
                  msg.contains('suspended')) {
                await _storage.clearSession();
                onUnauthorized?.call();
                return handler.next(error);
              }
            }
          }

          // Silent token refresh on 401
          if (response?.statusCode == 401 && !error.requestOptions.path.contains('/refresh')) {
            try {
              final newToken = await _handleTokenRefresh();
              if (newToken != null && newToken.isNotEmpty) {
                // Retry the original failed request with the new token
                final retryOptions = error.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $newToken';
                final retryRes = await _dio.fetch(retryOptions);
                return handler.resolve(retryRes);
              }
            } catch (refreshErr) {
              debugPrint('Token refresh failed: $refreshErr');
              await _storage.clearSession();
              onUnauthorized?.call();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => _dio.get<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  /// Handles 401 token refresh queue
  Future<String?> _handleTokenRefresh() async {
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }

      final refreshDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-refresh-token': refreshToken,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String? newToken;
        String? newRefreshToken;
        if (data is Map<String, dynamic>) {
          newToken = data['token']?.toString();
          newRefreshToken = data['refreshToken']?.toString();
        }

        if (newToken != null && newToken.isNotEmpty) {
          await _storage.saveToken(newToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _storage.saveRefreshToken(newRefreshToken);
          }
          for (final c in _refreshQueue) {
            c.complete(newToken);
          }
          _refreshQueue.clear();
          return newToken;
        }
      }

      for (final c in _refreshQueue) {
        c.complete(null);
      }
      _refreshQueue.clear();
      return null;
    } catch (e) {
      for (final c in _refreshQueue) {
        c.complete(null);
      }
      _refreshQueue.clear();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Helper to convert DioException into human-readable user message
  static String extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Check that backend is reachable.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return kReleaseMode
            ? 'Cannot reach backend server. Check your network connection.'
            : 'Cannot reach backend at ${ApiConfig.baseUrl}. Check Wi-Fi / IP settings.';
      }
      if (error.response?.data is Map<String, dynamic>) {
        final map = error.response!.data as Map<String, dynamic>;
        return map['message']?.toString() ?? 'An error occurred on the server.';
      }
      if (error.response?.statusCode != null) {
        return 'Request failed with status ${error.response!.statusCode}.';
      }
    }
    // Strip raw Dart "Exception:" prefix so users never see technical strings
    final raw = error?.toString() ?? 'An unexpected error occurred.';
    return raw.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}
