import 'package:hive/hive.dart';

class ErrorBag extends HiveObject {
  String? message;
  String? translationKey;
  String? errorType;
  String? url;


  ErrorBag(
      {required this.message,
        required this.translationKey,
        required this.url,
        required this.errorType,});

  ErrorBag.fromJson(Map data) {
    message = data['message'];
    translationKey = data['translationKey'];
    errorType = data['errorType'];
    url = data['url'];


  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'message': message,
      'translationKey': translationKey,
      'errorType': errorType,
      'url': url,

    };
    return map;
  }
}
