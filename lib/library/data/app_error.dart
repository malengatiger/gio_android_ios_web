import 'package:hive/hive.dart';

import '../data/position.dart';

part 'app_error.g.dart';

@HiveType(typeId: 66)
class AppError extends HiveObject {
  @HiveField(0)
  String? errorMessage;
  @HiveField(1)
  String? manufacturer;
  @HiveField(2)
  String? model;
  @HiveField(3)
  String? created;
  @HiveField(4)
  String? brand;
  @HiveField(5)
  String? userId;
  @HiveField(6)
  String? organizationId;
  @HiveField(7)
  String? userName;
  @HiveField(8)
  Position? errorPosition;
  @HiveField(9)
  String? iosName;
  @HiveField(10)
  String? versionCodeName;

  @HiveField(11)
  String? baseOS;
  @HiveField(12)
  String? deviceType;

  @HiveField(13)
  String? iosSystemName;

  @HiveField(14)
  String? userUrl;

  @HiveField(15)
  String? uploadedDate;

  AppError(
      {required this.errorMessage,
      required this.model,
      required this.created,
      required this.userId,
      required this.userName,
      required this.errorPosition,
      required this.iosName,
      required this.versionCodeName,
      required this.manufacturer,
      required this.brand,
      required this.organizationId,
      required this.baseOS,
      required this.deviceType,
      required this.userUrl,
      required this.uploadedDate,
      required this.iosSystemName});

  AppError.fromJson(Map data) {
    userUrl = data['userUrl'];
    errorMessage = data['errorMessage'];
    manufacturer = data['manufacturer'];
    model = data['model'];
    baseOS = data['baseOS'];
    deviceType = data['deviceType'];
    created = data['created'];
    created = data['created'];
    organizationId = data['organizationId'];
    iosSystemName = data['iosSystemName'];
    uploadedDate = data['uploadedDate'];

    userId = data['userId'];
    brand = data['brand'];
    userName = data['userName'];
    iosName = data['iosName'];
    versionCodeName = data['versionCodeName'];
    if (data['errorPosition'] != null) {
      errorPosition = Position.fromJson(data['errorPosition']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'errorMessage': errorMessage,
      'userUrl': userUrl,
      'iosSystemName': iosSystemName,
      'model': model,
      'created': created,
      'deviceType': deviceType,
      'baseOS': baseOS,
      'userId': userId,
      'organizationId': organizationId,
      'brand': brand,
      'uploadedDate': uploadedDate,
      'userName': userName,
      'iosName': iosName,
      'versionCodeName': versionCodeName,
      'manufacturer': manufacturer,
      'errorPosition': errorPosition == null ? null : errorPosition!.toJson()
    };
    return map;
  }
}
