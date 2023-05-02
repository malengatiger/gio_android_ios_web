

import '../data/city.dart';
import '../data/community.dart';
import '../data/condition.dart';
import '../data/field_monitor_schedule.dart';
import '../data/monitor_report.dart';
import '../data/org_message.dart';
import '../data/organization.dart';
import '../data/photo.dart';
import '../data/project.dart';
import '../data/project_position.dart';
import '../data/section.dart';
import '../data/user.dart';
import '../data/video.dart';

abstract class LocalDatabase {
  Future<int> addCities({required List<City> cities});
  Future<int> addCity({required City city});
  Future<int> addOrganization({required Organization organization});
  Future<int> addCommunities({required List<Community> communities});
  Future<int> addCommunity({required Community community});
  Future<int> addMonitorReports({required List<MonitorReport> monitorReports});
  Future<int> addMonitorReport({required MonitorReport monitorReport});
  Future<int> addUsers({required List<User> users});
  Future<int> addUser({required User user});
  Future<int> addProjects({required List<Project> projects});
  Future<int> addProject({required Project project});
  Future<int> addPhotos({required List<Photo> photos});
  Future<int> addPhoto({required Photo photo});
  Future<int> addVideos({required List<Video> videos});
  Future<int> addVideo({required Video video});
  Future<int> addCondition({required Condition condition});
  Future<int> addOrgMessage({required OrgMessage message});
  Future<int> addSection({required Section section});
  Future<int> addProjectPositions(
      {required List<ProjectPosition> positions});
  Future<int> addProjectPosition(
      {required ProjectPosition projectPosition});
  Future<int> addFieldMonitorSchedules(
      {required List<FieldMonitorSchedule> schedules});
  Future<int> addFieldMonitorSchedule(
      {required FieldMonitorSchedule schedule});

  Future<List<ProjectPosition>> findProjectPositionsByLocation(
      {required latitude, required longitude, required radiusInKM});
  Future<List<Project>> findProjectsByLocation(
      {required latitude, required longitude, required radiusInKM});
  Future<List<Photo>> findPhotosByLocation(
      {required latitude, required longitude, required radiusInKM});
  Future<List<Video>> findVideosByLocation(
      {required latitude, required longitude, required radiusInKM});
  Future<List<MonitorReport>> findMonitorReportsByLocation(
      {required latitude, required longitude, required radiusInKM});
  Future<List<City>> findCitiesByLocation(
      {required latitude, required longitude, required radiusInKM});

  Future<List<Community>> getCommunities();
  Future<List<Organization>> getOrganizations();
  Future<List<Project>> getProjects();
  Future<List<Photo>> getPhotos();
  Future<List<Video>> getVideos();
  Future<List<Photo>> getProjectPhotos(String projectId);
  Future<List<ProjectPosition>> getProjectPositions(String projectId);
  Future<List<Photo>> getSections(String questionnaireId);
  Future<List<Photo>> getUserPhotos(String userId);
  Future<List<Video>> getUserVideos(String userId);
  Future<List<Video>> getProjectVideos(String projectId);
  Future<List<FieldMonitorSchedule>> getProjectMonitorSchedules(String projectId);
  Future<List<FieldMonitorSchedule>> getFieldMonitorSchedules(String userId);
  Future<List<FieldMonitorSchedule>> getOrganizationMonitorSchedules(String organizationId);
  List<FieldMonitorSchedule> filterSchedulesByProject(
      List<FieldMonitorSchedule> mList, String projectId);
  Future<List<User>> getUsers();
}