
import '../data/interfaces.dart';
import '../data/position.dart';
class RatingContent {
  String? userId, created;
  String? comment;
  Position? position;
  Rating? rating;

  RatingContent(
      {
      required this.userId,
      this.comment,
      required this.position,
      required this.rating});

  RatingContent.fromJson(Map data) {
    userId = data['userId'];
    comment = data['comment'];
    created = data['created'];
    position = data['position'];
    rating = data['rating'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'userId': userId,
      'comment': comment,
      'created': created,
      'position': position,
      'rating': rating,
    };
    return map;
  }
}
