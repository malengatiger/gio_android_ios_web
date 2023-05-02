import 'package:hive/hive.dart';

import '../data/position.dart';

part 'user.g.dart';

@HiveType(typeId: 11)
class User extends HiveObject {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? userId;
  @HiveField(2)
  String? email;
  @HiveField(3)
  String? gender;
  @HiveField(4)
  String? cellphone;
  @HiveField(5)
  String? created;
  @HiveField(6)
  String? userType;
  @HiveField(7)
  String? organizationName;
  @HiveField(8)
  String? fcmRegistration;
  @HiveField(9)
  String? countryId;
  @HiveField(10)
  String? organizationId;
  @HiveField(11)
  Position? position;
  @HiveField(12)
  String? password;
  @HiveField(13)
  String? updated;
  @HiveField(14)
  int? active = 0;
  //imageUrl, thumbnailUrl
  @HiveField(15)
  String? imageUrl;
  @HiveField(16)
  String? thumbnailUrl;

  @HiveField(17)
  String? translatedMessage;

  @HiveField(18)
  String? translatedTitle;

  User(
      {required this.name,
      required this.email,
      required this.userId,
      required this.cellphone,
      required this.created,
      required this.userType,
      required this.gender,
      required this.organizationName,
      required this.organizationId,
      required this.countryId,
        required this.active, this.imageUrl, this.thumbnailUrl,
        required this.translatedMessage,
        required this.translatedTitle,
      this.position,
      this.fcmRegistration,
        required this.password});

  User.fromJson(Map data) {
    name = data['name'];
    userId = data['userId'];
    password = data['password'];
    imageUrl = data['imageUrl'];
    thumbnailUrl = data['thumbnailUrl'];
    active = data['active'];
    updated = data['updated'];
    countryId = data['countryId'];
    gender = data['gender'];
    fcmRegistration = data['fcmRegistration'];
    email = data['email'];
    cellphone = data['cellphone'];
    created = data['created'];
    userType = data['userType'];
    translatedMessage = data['translatedMessage'];
    translatedTitle = data['translatedTitle'];
    organizationId = data['organizationId'];
    organizationName = data['organizationName'];
    if (data['position'] != null) {
      position = Position.fromJson(data['position']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'userId': userId,
      'countryId': countryId,
      'gender': gender,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'password': password,
      'fcmRegistration': fcmRegistration,
      'email': email,
      'updated': updated,
      'active': active,
      'cellphone': cellphone,
      'translatedMessage': translatedMessage,
      'translatedTitle': translatedTitle,
      'created': created,
      'userType': userType,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'position': position == null ? null : position!.toJson(),
    };
    return map;
  }
}



const monitorOnceADay = 'Once Every Day';
const monitorTwiceADay = 'Twice A Day';
const monitorThriceADay = 'Three Times A Day';
const monitorOnceAWeek = 'Once A Week';

const labels = [
  'Once Every Day',
  'Twice A Day',
  'Three Times A Day',
  'Once A Week',
  'Once A Month',
  'Whenever Necessary'
];



class UserType {
  static const String fieldMonitor = 'FIELD_MONITOR';
  static const String orgAdministrator = 'ORG_ADMINISTRATOR';
  static const String orgExecutive = 'ORG_EXECUTIVE';
  static const String networkAdministrator = 'NETWORK_ADMINISTRATOR';
  static const String orgOwner = 'ORG_OWNER';
}
