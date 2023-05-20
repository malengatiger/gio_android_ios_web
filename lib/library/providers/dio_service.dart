import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/app_auth.dart';
import '../functions.dart';

final DioService dioService = DioService(Dio(), AppAuth(FirebaseAuth.instance));

class DioService {
  final Dio dio;
  final AppAuth appAuth;

  DioService(this.dio, this.appAuth) {
    configureDio();
  }

  Future? callGet(
      {required String requestUrl, Map<String, String>? headers}) async {
    final response = await dio.get(requestUrl);
    pp(response);

    return null;
  }

  Future? callPost(
      {required String requestUrl,
      required Map<String, String> body,
      Map<String, String>? headers}) {}

  void configureDio() {
    // Set default configs
    dio.options.baseUrl = getUrl();
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 90);

    // Or create `Dio` with a `BaseOptions` instance.
    // final options = BaseOptions(
    //   baseUrl: getUrl(),
    //   connectTimeout: const Duration(seconds: 5),
    //   receiveTimeout: const Duration(seconds: 3),
    // );
    // final anotherDio = Dio(options);
  }
}
