
import 'package:hive/hive.dart';

import '../data/monitor_report.dart';
import '../data/photo.dart';
import '../data/project_position.dart';
import '../data/rating_content.dart';
import '../data/video.dart';
import 'city.dart';
import 'community.dart';

part 'project.g.dart';

@HiveType(typeId: 5)
class Project extends HiveObject {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? projectId;
  @HiveField(2)
  String? description;
  @HiveField(3)
  String? organizationId;
  @HiveField(4)
  String? created;
  @HiveField(5)
  String? organizationName;
  @HiveField(6)
  List<City>? nearestCities;
  @HiveField(7)
  List<ProjectPosition>? projectPositions;
  @HiveField(8)
  List<Photo>? photos;
  @HiveField(9)
  List<Video>? videos;
  @HiveField(10)
  List<RatingContent>? ratings;
  @HiveField(11)
  List<Community>? communities;
  @HiveField(12)
  List<MonitorReport>? monitorReports;
  @HiveField(13)
  double? monitorMaxDistanceInMetres;

  @HiveField(14)
  String? translatedMessage;

  @HiveField(15)
  String? translatedTitle;

  Project(
      {required this.name,
      required this.description,
      this.organizationId,
      required this.communities,
      required this.nearestCities,
      required this.photos,
      required this.videos,
      required this.ratings,
      required this.created,
      required this.projectPositions,
      required this.monitorReports,
      required this.organizationName,
        required this.translatedMessage,
        required this.translatedTitle,
      required this.monitorMaxDistanceInMetres,
      required this.projectId});

  Project.fromJson(Map data) {
    name = data['name'];

    projectId = data['projectId'];
    description = data['description'];
    organizationId = data['organizationId'];
    created = data['created'];
    organizationName = data['organizationName'];
    // //pp('Project.fromJson 😑 😑 😑 log 1 ...');
    monitorMaxDistanceInMetres = data['monitorMaxDistanceInMetres'];
    translatedMessage = data['translatedMessage'];
    translatedTitle = data['translatedTitle'];
    //pp('Project.fromJson 😑 😑 😑 log 2 ...');
    monitorReports = [];
    if (data['monitorReports'] != null) {
      List list = data['monitorReports'];
      for (var m in list) {
        monitorReports!.add(MonitorReport.fromJson(m));
      }
    }
    communities = [];
    if (data['communities'] != null) {
      List list = data['communities'];
      for (var m in list) {
        communities!.add(Community.fromJson(m));
      }
    }
    //pp('Project.fromJson 😑 😑 😑 log 3 ...');
    nearestCities = [];
    if (data['nearestCities'] != null) {
      List list = data['nearestCities'];
      for (var m in list) {
        nearestCities!.add(City.fromJson(m));
      }
    }
    //pp('Project.fromJson 😑 😑 😑 log 4 ...');
    projectPositions = [];
    if (data['projectPositions'] != null) {
      List list = data['projectPositions'];
      for (var m in list) {
        projectPositions!.add(ProjectPosition.fromJson(m));
      }
    }
    //pp('Project.fromJson 😑 😑 😑 log 5 ...');
    photos = [];
    if (data['photos'] != null) {
      List list = data['photos'];
      for (var m in list) {
        photos!.add(Photo.fromJson(m));
      }
    }
    //pp('Project.fromJson 😑 😑 😑 log 6 ...');
    videos = [];
    if (data['videos'] != null) {
      List list = data['videos'];
      for (var m in list) {
        videos!.add(Video.fromJson(m));
      }
    }
    //pp('Project.fromJson 😑 😑 😑 log 7 ...');
    ratings = [];
    if (data['ratings'] != null) {
      List list = data['ratings'];
      for (var m in list) {
        ratings!.add(RatingContent.fromJson(m));
      }
    }
    //pp('Project.fromJson 😑 😑 😑 logs end ...');
  }
  Map<String, dynamic> toJson() {
    List mProjectPositions = [];
    if (projectPositions != null) {
      for (var pos in projectPositions!) {
        mProjectPositions.add(pos.toJson());
      }
    }
    List mPhotos = [];
    if (photos != null) {
      for (var photo in photos!) {
        mPhotos.add(photo.toJson());
      }
    }
    List mVideos = [];
    if (videos != null) {
      for (var photo in videos!) {
        mVideos.add(photo.toJson());
      }
    }
    List mRatings = [];
    if (ratings != null) {
      for (var r in ratings!) {
        mRatings.add(r.toJson());
      }
    }
    List mSett = [];
    if (communities != null) {
      for (var r in communities!) {
        mSett.add(r.toJson());
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
      'projectId': projectId,
      'description': description,
      'organizationId': organizationId,
      'monitorMaxDistanceInMetres': monitorMaxDistanceInMetres,
      'communities': mSett,
      'organizationName': organizationName,
      'nearestCities': mCities,
      'photos': mPhotos,
      'translatedMessage': translatedMessage,
      'translatedTitle': translatedTitle,
      'videos': mVideos,
      'ratings': mRatings,
      'created': created,
      'projectPositions': mProjectPositions,
    };
    return map;
  }
}
