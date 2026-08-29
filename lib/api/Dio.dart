import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/api/tokenStorage.dart';
import 'package:jaberah/login.dart';

class ApiClient {
  final Dio _dio = Dio();
  late final CookieJar _cookieJar;

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers["Content-Type"] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 20);
    _dio.options.receiveTimeout = const Duration(seconds: 20);

    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(ApiInterceptors(_cookieJar));
  }

  Dio get dio => _dio;
}

class ApiInterceptors extends Interceptor {
  final CookieJar cookieJar;
  
  // Lock mechanism to prevent multiple simultaneous refresh token requests
  static Completer<String?>? _refreshCompleter;
  static bool _isRefreshing = false;

  ApiInterceptors(this.cookieJar);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final accessToken = await TokenStorage.read();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      return handler.next(options);
    } catch (e) {
      return handler.next(options);
    }
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final isRefreshRequest = err.requestOptions.path.contains('/auth/refresh');
      
      if (isRefreshRequest) {
        await _logout();
        return handler.reject(err);
      }

      try {
        // If a refresh is already in progress, wait for it
        if (_isRefreshing && _refreshCompleter != null) {
          final newAccessToken = await _refreshCompleter!.future;
          if (newAccessToken != null) {
            final retryResponse = await _retryRequest(err.requestOptions, newAccessToken);
            return handler.resolve(retryResponse);
          } else {
            await _logout();
            return handler.reject(err);
          }
        }

        // Start a new refresh process
        _isRefreshing = true;
        _refreshCompleter = Completer<String?>();

        final newAccessToken = await _refreshToken();
        
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await TokenStorage.write(newAccessToken);
          
          _refreshCompleter!.complete(newAccessToken);
          _isRefreshing = false;

          final retryResponse = await _retryRequest(err.requestOptions, newAccessToken);
          return handler.resolve(retryResponse);
        } else {
          _refreshCompleter!.complete(null);
          _isRefreshing = false;
          await _logout();
          return handler.reject(err);
        }
      } catch (e) {
        _refreshCompleter?.complete(null);
        _isRefreshing = false;
        await _logout();
        return handler.reject(err);
      }
    }
    return handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));
      dio.interceptors.add(CookieManager(cookieJar));

      final response = await dio.post(
        '/auth/refresh',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['accessToken'];
        if (accessToken != null && accessToken is String && accessToken.isNotEmpty) {
          return accessToken;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Response<dynamic>> _retryRequest(
      RequestOptions requestOptions, String accessToken) async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: requestOptions.connectTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
    ));
    dio.interceptors.add(CookieManager(cookieJar));

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      extra: requestOptions.extra,
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // prefs.clear() لا يمسّ المخزن المشفَّر.
      await TokenStorage.clear();
      await cookieJar.deleteAll();
      Get.offAll(() => Login());
    } catch (e) {
      Get.offAll(() => Login());
    }
  }
}
