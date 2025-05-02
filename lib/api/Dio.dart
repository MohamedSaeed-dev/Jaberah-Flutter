import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:jaberah/api/URLs.dart';
import 'package:jaberah/login.dart';

class ApiClient {
  final Dio _dio = Dio();
  late final CookieJar _cookieJar;

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers["Content-Type"] = 'application/json';

    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(ApiInterceptors(_cookieJar));
  }

  Dio get dio => _dio;
}

class ApiInterceptors extends Interceptor {
  final CookieJar cookieJar;
  ApiInterceptors(this.cookieJar);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
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
      final isRefreshing = err.requestOptions.path.contains('/auth/refresh');
      if (isRefreshing) {
        Get.offAll(() => Login());
        return handler.reject(err);
      }

      try {
        final newAccessToken = await _refreshToken();
        if (newAccessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', newAccessToken);

          final retryResponse =
              await _retryRequest(err.requestOptions, newAccessToken);
          return handler.resolve(retryResponse);
        } else {
          Get.offAll(() => Login());
          return handler.reject(err);
        }
      } catch (e) {
        Get.offAll(() => Login());
        return handler.reject(err);
      }
    }
    return handler.next(err);
  }

  Future<String?> _refreshToken() async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(CookieManager(cookieJar));

    final response = await dio.post(
      '/auth/refresh',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode == 200) {
      return response.data['accessToken'];
    }
    return null;
  }

  Future<Response<dynamic>> _retryRequest(
      RequestOptions requestOptions, String accessToken) async {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(CookieManager(cookieJar));

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
