


import '../data/data_bag.dart';
import '../functions.dart';



void printDataBag(DataBag bag) {
  final projects = bag.projects!.length;
  final users = bag.users!.length;
  final positions = bag.projectPositions!.length;
  final polygons = bag.projectPolygons!.length;
  final photos = bag.photos!.length;
  final videos = bag.videos!.length;
  final audios = bag.audios!.length;
  final schedules = bag.fieldMonitorSchedules!.length;
  final activities = bag.activityModels!.length;

  const xz = '👌👌👌 DataBag print 👌';
  pp('$xz activities: $activities');
  pp('$xz projects: $projects');
  pp('$xz users: $users');
  pp('$xz positions: $positions');
  pp('$xz polygons: $polygons');
  pp('$xz photos: $photos');
  pp('$xz videos: $videos');
  pp('$xz audios: $audios');
  pp('$xz schedules: $schedules');
  pp('$xz data from backend listed above: 🔵🔵🔵 ${bag.date}');
}
