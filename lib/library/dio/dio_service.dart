import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

Future<Map<String, dynamic>> makeRequest(String url,
    {required Duration timeout, String? authToken}) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('No internet connection');
  }
  try {
    final dio = Dio(BaseOptions(
        connectTimeout: timeout,
        headers: {'Authorization': 'Bearer $authToken'}));
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  } on DioError catch (e) {
    if (e.type == DioErrorType.connectionTimeout ||
        e.type == DioErrorType.receiveTimeout ||
        e.type == DioErrorType.sendTimeout) {
      throw TimeoutException('Request timed out: $e');
    } else if (e.type == DioErrorType.badResponse) {
      throw Exception('Failed to load data: ${e.response?.statusCode}');
    } else {
      throw Exception('Failed to connect to server: $e');
    }
  } on Exception catch (e) {
    throw Exception('Error occurred: $e');
  }
}
