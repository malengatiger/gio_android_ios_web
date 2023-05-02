import '../data/position.dart';

class Content {
  String? url;
  String? userId, created;
  Position? position;
  Content(
      {required this.url,
      required this.userId,
      required this.position,
      this.created});

  Content.fromJson(Map data) {
    url = data['url'];
    userId = data['userId'];
    created = data['created'];
    if (data['position'] != null) {
      position = Position.fromJson(data['position']);
    }
  }
  
  Map<String, dynamic> toJson() {
    Map pos = {};
    if (position != null) {
      pos = position!.toJson();
    }
    Map<String, dynamic> map = {
      'userId': userId,
      'url': url,
      'created': created,
      'position': pos,
    };
    return map;
  }
}
