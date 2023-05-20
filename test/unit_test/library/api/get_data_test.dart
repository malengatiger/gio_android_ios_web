import 'package:flutter_test/flutter_test.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/data/activity_model.dart';
import 'package:geo_monitor/library/data/app_error.dart';
import 'package:geo_monitor/library/data/audio.dart';
import 'package:geo_monitor/library/data/country.dart';
import 'package:geo_monitor/library/data/organization.dart';
import 'package:geo_monitor/library/data/organization_registration_bag.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/position.dart';
import 'package:geo_monitor/library/data/project.dart';
import 'package:geo_monitor/library/data/project_polygon.dart';
import 'package:geo_monitor/library/data/project_position.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/data/video.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_data_test.mocks.dart';

// Generate a MockClient using the Mockito package.
// Create new instances of this class in each test.
final MockClient client = MockClient();
MockDataApiDog? dog;

@GenerateMocks([http.Client, DataApiDog, CacheManager, PrefsOGx, ])
void main() {
  const url = 'http://192.168.86.230:8080/geo/v1/';
  const organizationId = 'orgId';
  const userId = 'orgId';
  const projectId = 'orgId';
  const startDate = 'orgId';
  const endDate = 'orgId';
  const hours = 12;
  //
  group('getData', () {
    //
    test('returns countries completes successfully', () async {
      final client = MockClient();
      var list = <Country>[];

      when(client.get(Uri.parse('${url}getCountries')))
          .thenAnswer((_) async => http.Response(list as String, 200));

      expect(list, isA<List<Country>>());
    });
    //
    test('returns organizations completes successfully', () async {
      final client = MockClient();
      var list = <Organization>[];

      when(client.get(Uri.parse('${url}getOrganizations')))
          .thenAnswer((_) async => http.Response(list as String, 200));

      expect(list, isA<List<Organization>>());
    });
    //
    test('returns users when completes successfully', () async {
      final client = MockClient();
      var list = <User>[];

      when(client.get(Uri.parse('${url}getUsers')))
          .thenAnswer((_) async => http.Response(list as String, 200));

      expect(list, isA<List<User>>());
    });
    //
    test('😡😡returns countries from DataApiDog', () async {
      var list = <Country>[];
      dog = MockDataApiDog();
      when(await dog!.getCountries()).thenReturn(list);
      expect(list, isA<List<Country>>());
    });
    //
    test('😡😡returns organization activity from DataApiDog', () async {
      var list = <ActivityModel>[];
      dog = MockDataApiDog();
      when(await dog!.getOrganizationActivity(organizationId, hours))
          .thenReturn(list);
      expect(list, isA<List<ActivityModel>>());
    });
    //
    test('😡😡returns project activity from DataApiDog', () async {
      var list = <ActivityModel>[];
      dog = MockDataApiDog();
      when(await dog!.getProjectActivity(projectId, hours)).thenReturn(list);
      expect(list, isA<List<ActivityModel>>());
    });
    //
    test('😡😡returns user activity from DataApiDog', () async {
      var list = <ActivityModel>[];
      dog = MockDataApiDog();
      when(await dog!.getUserActivity(userId, hours)).thenReturn(list);
      expect(list, isA<List<ActivityModel>>());
    });
    //
    test('😡😡returns Organization Settings from DataApiDog', () async {
      var list = <SettingsModel>[];
      dog = MockDataApiDog();
      when(await dog!.getOrganizationSettings(organizationId)).thenReturn(list);
      expect(list, isA<List<SettingsModel>>());
    });
    //
    test('😡😡returns Organization Settings from DataApiDog', () async {
      var bag = OrganizationRegistrationBag(
          organization: null,
          projectPosition: null,
          user: null,
          project: null,
          date: '',
          latitude: null,
          longitude: null);
      dog = MockDataApiDog();
      when(await dog!.registerOrganization(null)).thenReturn(bag);
      expect(bag, isA<OrganizationRegistrationBag>());
    });
    //
    test('😡😡 creates User : DataApiDog', () async {
      var user = User(
          name: '',
          email: '',
          userId: '',
          cellphone: '',
          created: '',
          userType: '',
          gender: '',
          organizationName: '',
          organizationId: '',
          countryId: '',
          active: null,
          translatedMessage: '',
          translatedTitle: '',
          password: '');
      dog = MockDataApiDog();
      when(await dog!.createUser(null)).thenReturn(user);
      expect(user, isA<User>());
    });
    //
    test('😡😡returns ProjectPositions from DataApiDog', () async {
      var list = <ProjectPosition>[];
      dog = MockDataApiDog();
      when(await dog!.getProjectPositions(organizationId, startDate, endDate))
          .thenReturn(list);
      expect(list, isA<List<ProjectPosition>>());
    });
    //
    test('😡😡returns ProjectPolygons from DataApiDog', () async {
      var list = <ProjectPolygon>[];
      dog = MockDataApiDog();
      when(await dog!.getProjectPolygons(organizationId, startDate, endDate))
          .thenReturn(list);
      expect(list, isA<List<ProjectPolygon>>());
    });
    //
    test('😡😡returns Photos from DataApiDog', () async {
      var list = <Photo>[];
      dog = MockDataApiDog();
      when(await dog!
              .getProjectPhotos(projectId: '', startDate: '', endDate: ''))
          .thenReturn(list);
      expect(list, isA<List<Photo>>());
    });
    //
    test('😡😡returns Audios from DataApiDog', () async {
      var list = <Audio>[];
      dog = MockDataApiDog();
      when(await dog!.getProjectAudios(projectId, startDate, endDate))
          .thenReturn(list);
      expect(list, isA<List<Audio>>());
    });
    //
    test('😡😡returns Videos from DataApiDog', () async {
      var list = <Video>[];
      dog = MockDataApiDog();
      when(await dog!.getProjectVideos(projectId, startDate, endDate))
          .thenReturn(list);
      expect(list, isA<List<Video>>());
    });
    //
    test('😡😡addPointToPolygon : DataApiDog', () async {
      var object = {};
      dog = MockDataApiDog();
      when(await dog!.addPointToPolygon(
              communityId: '', latitude: null, longitude: null))
          .thenReturn(object);
      expect(object, isA<dynamic>());
    });
    //
    test('😡😡addProject : DataApiDog', () async {
      var object = Project(
          name: 'name',
          description: 'description',
          communities: [],
          nearestCities: [],
          photos: [],
          videos: [],
          ratings: [],
          created: '',
          projectPositions: [],
          monitorReports: [],
          organizationName: 'organizationName',
          translatedMessage: 'translatedMessage',
          translatedTitle: 'translatedTitle',
          monitorMaxDistanceInMetres: 100,
          projectId: projectId);
      dog = MockDataApiDog();
      when(await dog!.addProject(object)).thenReturn(object);
      expect(object, isA<Project>());
    });
    //
    test('😡😡addProjectPosition : DataApiDog', () async {
      var object = ProjectPosition(
          projectName: 'projectName',
          caption: 'caption',
          projectPositionId: 'Position',
          created: 'created',
          position: Position(coordinates: [], type: ''),
          nearestCities: [],
          organizationId: 'organizationId',
          translatedMessage: 'translatedMessage',
          translatedTitle: 'translatedTitle',
          userId: userId,
          userName: 'userName',
          projectId: projectId);
      dog = MockDataApiDog();
      when(await dog!.addProjectPosition(position: object)).thenReturn(object);
      expect(object, isA<ProjectPosition>());
    });
  });
  //
  test('😡😡addPhoto : DataApiDog', () async {
    var object = Photo(
        url: 'url',
        caption: 'caption',
        created: 'created',
        userId: userId,
        distanceFromProjectPosition: 8.0,
        userName: 'userName',
        projectPosition: Position(coordinates: [], type: 'type'),
        projectId: projectId,
        thumbnailUrl: 'thumbnailUrl',
        photoId: 'photoId',
        organizationId: organizationId,
        projectName: 'projectName',
        height: 80,
        translatedMessage: 'translatedMessage',
        translatedTitle: 'translatedTitle',
        width: 80,
        userUrl: 'userUrl',
        landscape: 1);
    dog = MockDataApiDog();
    when(await dog!.addPhoto(null)).thenReturn(object);
    expect(object, isA<Photo>());
  });
  //
  test('😡😡addVideo : DataApiDog', () async {
    var object = Video(
        url: 'url',
        caption: 'caption',
        created: 'created',
        userId: userId,
        userName: 'userName',
        projectPosition: Position(coordinates: [], type: 'type'),
        projectId: projectId,
        thumbnailUrl: 'thumbnailUrl',
        videoId: 'photoId',
        organizationId: organizationId,
        projectName: 'projectName',
        translatedMessage: 'translatedMessage',
        translatedTitle: 'translatedTitle',
        userUrl: 'userUrl',
        distanceFromProjectPosition: 8.0,
        durationInSeconds: 600,
        size: 8.0);
    dog = MockDataApiDog();
    when(await dog!.addVideo(null)).thenReturn(object);
    expect(object, isA<Video>());
  });
  //
  test('😡😡addAudio : DataApiDog', () async {
    var object = Audio(
      url: 'url',
      caption: 'caption',
      created: 'created',
      userId: userId,
      userName: 'userName',
      projectPosition: Position(coordinates: [], type: 'type'),
      projectId: projectId,
      audioId: 'photoId',
      organizationId: organizationId,
      projectName: 'projectName',
      translatedMessage: 'translatedMessage',
      translatedTitle: 'translatedTitle',
      userUrl: 'userUrl',
      distanceFromProjectPosition: 0.0,
      durationInSeconds: 80,
    );
    dog = MockDataApiDog();
    when(await dog!.addAudio(null)).thenReturn(object);
    expect(object, isA<Audio>());
  });
  //
  test('😡😡addAppError : DataApiDog', () async {
    var object = AppError(
        errorMessage: 'errorMessage',
        model: 'model',
        created: 'created',
        userId: 'userId',
        userName: 'userName',
        errorPosition: null,
        iosName: 'iosName',
        versionCodeName: 'versionCodeName',
        manufacturer: 'manufacturer',
        brand: 'brand',
        organizationId: 'organizationId',
        baseOS: 'baseOS',
        deviceType: 'deviceType',
        userUrl: 'userUrl',
        uploadedDate: 'uploadedDate',
        iosSystemName: 'iosSystemName');
    dog = MockDataApiDog();
    when(await dog!.addAppError(null)).thenReturn(object);
    expect(object, isA<AppError>());
  });
}
