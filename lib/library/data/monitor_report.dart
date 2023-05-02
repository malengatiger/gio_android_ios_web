import 'package:geo_monitor/library/data/user.dart';
import 'package:hive/hive.dart';

import 'interfaces.dart';
import '../data/photo.dart';
import '../data/video.dart';
import '../data/user.dart' as mon;

part 'monitor_report.g.dart';

@HiveType(typeId: 9)
class MonitorReport extends HiveObject {
  @HiveField(0)
  String? projectId;
  @HiveField(1)
  String? created;
  @HiveField(2)
  String? monitorReportId;
  @HiveField(3)
  Rating? rating;
  @HiveField(4)
  String? description;
  @HiveField(5)
  List<Photo> photos = [];
  @HiveField(6)
  List<Video> videos = [];
  @HiveField(7)
  mon.User? user;

  @HiveField(8)
  String? organizationId;

  MonitorReport(
      {required this.projectId,
      required this.monitorReportId,
      this.description,
      required this.created,
      required this.user,
      required this.photos,
      required this.videos,
      required this.rating,
      required this.organizationId});

  MonitorReport.fromJson(Map data) {
    monitorReportId = data['monitorReportId'];
    projectId = data['projectId'];
    organizationId = data['organizationId'];
    rating = data['rating'];
    created = data['created'];
    description = data['description'];
    photos = [];
    if (data['user'] != null) {
      user = mon.User.fromJson(data['user']);
    }
    if (data['photos'] != null) {
      if (data['photos'] is List) {
        List mList = data['photos'];
        for (var photo in mList) {
          photos.add(Photo.fromJson(photo));
        }
      }
    }
    if (data['videos'] != null) {
      if (data['videos'] is List) {
        List mList = data['videos'];
        for (var video in mList) {
          videos.add(Video.fromJson(video));
        }
      }
    }
    rating = data['rating'];
  }
  Map<String, dynamic> toJson() {
    //todo - handle the photos and videos!!!
    Map<String, dynamic> map = {
      'projectId': projectId,
      'organizationId': organizationId,
      'rating': rating,
      'created': created,
      'description': description,
      'monitorReportId': monitorReportId,
    };
    return map;
  }
}
