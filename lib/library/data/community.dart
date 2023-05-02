import 'package:hive/hive.dart';

import '../data/city.dart';
import '../data/photo.dart';
import '../data/rating_content.dart';
import '../data/position.dart';
import '../data/video.dart';
part 'community.g.dart';

@HiveType(typeId: 13)
class Community extends HiveObject {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? countryId;
  @HiveField(2)
  String? communityId;
  @HiveField(3)
  String? email;
  @HiveField(4)
  String? countryName;
  @HiveField(5)
  String? created;
  @HiveField(6)
  int? population = 7;
  @HiveField(8)
  List<Position>? polygon = [];
  @HiveField(9)
  List<Photo>? photoUrls = [];
  @HiveField(10)
  List<Video>? videoUrls = [];
  @HiveField(11)
  List<RatingContent>? ratings = [];
  @HiveField(12)
  List<City>? nearestCities = [];

  Community(
      {required this.name,
      this.countryId,
      this.email,
      required this.countryName,
      this.polygon,
      required this.created,
      required this.population,
      this.nearestCities,
      this.communityId});

  Community.fromJson(Map data) {
    name = data['name'];
    countryId = data['countryId'];
    communityId = data['communityId'];
    email = data['email'];
    countryName = data['countryName'];
    communityId = data['communityId'];
    created = data['created'];
    population = data['population'];
    polygon = [];
    if (data['polygon'] != null) {
      List list = data['polygon'];
      for (var p in list) {
        polygon!.add(Position.fromJson(p));
      }
    }
    photoUrls = [];
    if (data['photoUrls'] != null) {
      List list = data['photoUrls'];
      for (var p in list) {
        photoUrls!.add(Photo.fromJson(p));
      }
    }
    videoUrls = [];
    if (data['videoUrls'] != null) {
      List list = data['videoUrls'];
      for (var p in list) {
        videoUrls?.add(Video.fromJson(p));
      }
    }
    ratings = [];
    if (data['ratings'] != null) {
      List list = data['ratings'];
      for (var p in list) {
        ratings?.add(RatingContent.fromJson(p));
      }
    }
    nearestCities = [];
    if (data['nearestCities'] != null) {
      List list = data['nearestCities'];
      for (var p in list) {
        nearestCities?.add(City.fromJson(p));
      }
    }
  }
  Map<String, dynamic> toJson() {
    List mPolygon = [];
    if (polygon != null) {
      for (var pos in polygon!) {
        mPolygon.add(pos.toJson());
      }
    }
    List mPhotos = [];
    if (photoUrls != null) {
      for (var photo in photoUrls!) {
        mPhotos.add(photo.toJson());
      }
    }
    List mVideos = [];
    if (videoUrls != null) {
      for (var photo in videoUrls!) {
        mVideos.add(photo.toJson());
      }
    }
    List mRatings = [];
    if (ratings != null) {
      for (var r in ratings!) {
        mRatings.add(r.toJson());
      }
    }
    List mCities = [];
    if (nearestCities != null) {
      for (var r in nearestCities!) {
        mCities.add(r.toJson());
      }
    }
    Map<String, dynamic> map = {
      'name': name,
      'countryId': countryId,
      'communityId': communityId,
      'email': email,
      'countryName': countryName,
      'polygon': mPolygon,
      'population': population,
      'created': created,
      'photoUrls': mPhotos,
      'videoUrls': mVideos,
      'ratings': mRatings,
      'nearestCities': mCities,
    };
    return map;
  }
}
