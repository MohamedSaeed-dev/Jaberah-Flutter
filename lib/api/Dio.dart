import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio = Dio();

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(ApiInterceptors());
  }

  Dio get dio => _dio;
}

class ApiInterceptors extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers["Content-Type"] = 'application/json';
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      if (refreshToken == null) {
        // Redirect to login
        Get.offAll(() => Login());
        return handler.reject(err);
      }

      // Refresh token
      try {
        final newToken = await _refreshToken(refreshToken);
        await prefs.setString('accessToken', newToken);

        // Retry original request
        final response = await _retryRequest(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        Get.offAll(() => Login());
        return handler.reject(err);
      }
    }
    return handler.next(err);
  }

  Future<String> _refreshToken(String refreshToken) async {
    final response = await Dio().post(
      '$baseUrl/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return response.data['accessToken'];
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions options) async {
    final newOptions = Options(
      method: options.method,
      headers: options.headers,
    );
    return Dio().request<dynamic>(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: newOptions,
    );
  }
}
