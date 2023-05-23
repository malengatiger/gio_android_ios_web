import 'package:dio/dio.dart';

import '../auth/app_auth.dart';
import '../functions.dart';

late DioService dioService;

class DioService {
  final Dio dio;
  final AppAuth appAuth;

  DioService(this.dio, this.appAuth);

  final mm = '🌎🌎🌎🌎🌎🌎DioService 🌎';

  Future? callGet(
      {required String requestUrl, Map<String, String>? headers}) async {
    configureDio(requestUrl);
    pp('$mm callPost: $requestUrl');
    try {
      final Response response = await dio.get(requestUrl);
      pp(response);
      return response.data;
    } on DioError catch (e) {
      _printError(e);
    }

    return null;
  }

  Future? callPost(
      {required String requestUrl,
      required Map<String, dynamic> body,
      Map<String, String>? headers}) async {
    configureDio(requestUrl);
    final start = DateTime.now();
    pp('$mm callPost: $requestUrl');
    //
    try {
      final Response resp = await dio.post(
        requestUrl,
        data: body,
      );
      //
      final end = DateTime.now();
      pp('$mm resp: $resp');
      pp('$mm elapsed time: ${end.difference(start).inMilliseconds} ms '
          'or ${end.difference(start).inSeconds} seconds');
      return resp.data;
    } on DioError catch (e) {
      _printError(e);
    }
  }

  void _printError(e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      pp('$mm Dio error!');
      pp('$mm STATUS: ${e.response?.statusCode}');
      pp('$mm DATA: ${e.response?.data}');
      pp('$mm HEADERS: ${e.response?.headers}');
    } else {
      // Error due to setting up or sending the request
      pp('$mm Error sending request!');
      pp(e.message);
    }
  }

  void configureDio(String url) {
    // Set default configs
    dio.options.baseUrl = url;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 90);
  }
}
