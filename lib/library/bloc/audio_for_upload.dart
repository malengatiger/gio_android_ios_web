import 'dart:typed_data';

import 'package:geo_monitor/library/bloc/photo_for_upload.dart';
import 'package:hive/hive.dart';

import '../data/position.dart';
import '../data/project.dart';

part 'audio_for_upload.g.dart';

@HiveType(typeId: 35)
class AudioForUpload extends HiveObject {
  @HiveField(0)
  String? filePath;

  @HiveField(2)
  Project? project;

  @HiveField(5)
  Position? position;
  @HiveField(6)
  String? date;
  @HiveField(7)
  String? audioId;
  @HiveField(8)
  String? userId;
  @HiveField(9)
  String? userName;
  @HiveField(10)
  String? organizationId;
  @HiveField(11)
  String? userThumbnailUrl;
  @HiveField(12)
  int? durationInSeconds;
  @HiveField(13)
  Uint8List? fileBytes;

  AudioForUpload(
      {required this.filePath,
      required this.project,
      required this.position,
      required this.audioId,
      required this.userId,
      required this.userName,
      required this.userThumbnailUrl,
      required this.organizationId,
      required this.durationInSeconds,
      required this.fileBytes,
      required this.date});

  AudioForUpload.fromJson(Map data) {
    audioId = data['audioId'];
    filePath = data['filePath'];
    date = data['date'];
    durationInSeconds = data['durationInSeconds'];

    userId = data['userId'];
    userName = data['userName'];
    organizationId = data['organizationId'];
    userThumbnailUrl = data['userThumbnailUrl'];

    if (data['fileBytes'] != null) {
      fileBytes = getImageBinary(data['fileBytes']);
    }

    if (data['project'] != null) {
      project = Project.fromJson(data['project']);
    }

    if (data['position'] != null) {
      position = Position.fromJson(data['position']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'audioId': audioId,
      'filePath': filePath,
      'project': project == null ? null : project!.toJson(),
      'date': date,
      'organizationId': organizationId,
      'userName': userName,
      'userId': userId,
      'fileBytes': fileBytes,
      'durationInSeconds': durationInSeconds,
      'userThumbnailUrl': userThumbnailUrl,
      'position': position == null ? null : position!.toJson(),
    };
    return map;
  }
}
