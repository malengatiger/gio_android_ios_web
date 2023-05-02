import 'package:hive/hive.dart';

part 'location_request.g.dart';

@HiveType(typeId: 23)
class LocationRequest extends HiveObject {
  @HiveField(0)
  String? organizationId;
  @HiveField(1)
  String? requesterId;
  @HiveField(2)
  String? created;
  @HiveField(3)
  String? requesterName;
  @HiveField(4)
  String? userId;
  @HiveField(5)
  String? userName;
  @HiveField(6)
  String? organizationName;
  @HiveField(7)
  String? translatedMessage;

  @HiveField(8)
  String? translatedTitle;

  //private String , , , ;
  //     private String , userName, organizationName;

  LocationRequest(
      {required this.organizationId,
      this.requesterId,
      required this.created,
      required this.requesterName,
      required this.userName,
      required this.userId,
        required this.translatedMessage,
        required this.translatedTitle,
      required this.organizationName}); // LocationRequest({required this.organizationId, this.userId, required this.created});

  LocationRequest.fromJson(Map data) {
    // pp(data);
    organizationId = data['organizationId'];
    requesterId = data['requesterId'];
    translatedMessage = data['translatedMessage'];
    translatedTitle = data['translatedTitle'];

    userId = data['userId'];
    userName = data['userName'];
    organizationName = data['organizationName'];
    created = data['created'];
    requesterName = data['requesterName'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'organizationId': organizationId,
      'requesterId': requesterId,
      'created': created,
      'translatedMessage': translatedMessage,
      'translatedTitle': translatedTitle,
      'userId': userId,
      'userName': userName,
      'requesterName': requesterName,
    };
    return map;
  }
}
