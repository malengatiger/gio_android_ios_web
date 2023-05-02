import 'dart:async';

import 'package:geo_monitor/library/cache_manager.dart';

import '../../device_location/device_location_bloc.dart';
import '../api/data_api.dart';
import '../api/prefs_og.dart';
import '../data/community.dart';
import '../data/country.dart';
import '../data/position.dart';
import '../data/project.dart';
import '../data/questionnaire.dart';
import '../data/section.dart';
import '../data/user.dart';
import '../functions.dart';

final AdminBloc adminBloc = AdminBloc();

class AdminBloc {
  final StreamController<List<Community>> _settController =
      StreamController.broadcast();
  final StreamController<List<Questionnaire>> _questController =
      StreamController.broadcast();
  final StreamController<List<Project>> _projController =
      StreamController.broadcast();
  final StreamController<List<Country>> _cntryController =
      StreamController.broadcast();
  final StreamController<Questionnaire> _activeQuestionnaireController =
      StreamController.broadcast();
  final StreamController<User> _activeUserController =
      StreamController.broadcast();

  Stream get settlementStream => _settController.stream;
  Stream<List<Questionnaire>> get questionnaireStream =>
      _questController.stream;
  Stream<List<Project>> get projectStream => _projController.stream;
  Stream<List<Country>> get countryStream => _cntryController.stream;
  Stream<User> get activeUserStream => _activeUserController.stream;
  Stream<List<User>> get usersStream => _userController.stream;
  Stream<Questionnaire> get activeQuestionnaireStream =>
      _activeQuestionnaireController.stream;

  final StreamController<List<User>> _userController =
      StreamController.broadcast();
  final List<Community> _communities = [];
  final List<Questionnaire> _questionnaires = [];
  final List<Project> _projects = [];
  final List<User> _users = [];
  final List<Country> _countries = [];

  AdminBloc() {
    _setActiveQuestionnaire();
    setActiveUser();
  }

  setActiveUser() async {
    var user = await prefsOGx.getUser();
    if (user != null) {
      pp('setting active user .... 🤟🤟');
      _activeUserController.sink.add(user);
    }
  }

  _setActiveQuestionnaire() async {
    // var q = await prefsOGx.getQuestionnaire();
    // if (q != null) {
    //   updateActiveQuestionnaire(q);
    // }
  }

  updateActiveQuestionnaire(Questionnaire q) {
    _activeQuestionnaireController.sink.add(q);
    pp('🍅 🍅 🍅 🍅 active questionnaire has been set');
    prettyPrint(
        q.toJson(), '🅿️ 🅿️ 🅿️ 🅿️ 🅿️ ACTIVE QUESTIONNAIRE 🍅 🍅 🍅 🍅 ');
  }

  Future<Position> getCurrentPosition() async {
    try {
      var mLocation = await locationBloc.getLocation();
      return Position.fromJson({
        'coordinates': [mLocation?.longitude, mLocation?.latitude],
        'type': 'Point',
      });
    } catch (e) {
      throw Exception('Permission denied');
    }
  }

  Future addToPolygon(
      {required String settlementId,
      required double latitude,
      required double longitude}) async {
    var res = await DataAPI.addPointToPolygon(
        communityId: settlementId, latitude: latitude, longitude: longitude);
    pp('Bloc: 🐬 🐬 addToPolygon ... check response below');

    var country = await prefsOGx.getCountry();
    if (country != null) {
      pp('Bloc: 🐬 🐬 addToPolygon ... 🐷 🐷 🐷 refreshing settlement list');
//      _settlements = await findSettlementsByCountry(country.countryId);
//      _settController.sink.add(_settlements);
    }
    return res;
  }

  Future addQuestionnaireSection(
      {required String questionnaireId, required Section section}) async {
    var res = await DataAPI.addQuestionnaireSection(
        questionnaireId: questionnaireId, section: section);
    var user = await prefsOGx.getUser();
    if (user != null) {
      await getQuestionnairesByOrganization(user.organizationId!);
      pp('🤟🤟🤟 Org questionnaires refreshed 🌹');
    }

    return res;
  }

  Future addCommunity(Community community) async {
    var res = await DataAPI.addCommunity(community);
    _communities.add(res);
    _settController.sink.add(_communities);
    await findCommunitiesByCountry(community.countryId!);
  }

  Future updateCommunity(Community sett) async {
    var res = await DataAPI.updateCommunity(sett);
    _communities.add(res);
    _settController.sink.add(_communities);
    await findCommunitiesByCountry(sett.countryId!);
  }

  Future<List<Community>> findCommunitiesByCountry(String countryId) async {
    _communities.clear();
    var res = await DataAPI.findCommunitiesByCountry(countryId);
    _communities.addAll(res);
    _settController.sink.add(_communities);
    pp('adminBloc:  🧩 🧩 🧩 _settController.sink.added 🏈 🏈 ${_communities.length} settlements  ');
    return _communities;
  }

  Future addQuestionnaire(Questionnaire quest) async {
    var res = await DataAPI.addQuestionnaire(quest);
    _questionnaires.add(res);
    _questController.sink.add(_questionnaires);

    var user = await prefsOGx.getUser();
    if (user != null) {
      await getQuestionnairesByOrganization(user.organizationId!);
      pp('🤟🤟🤟 Org questionnaires refreshed after 🤟 successful addition to DB 🌹');
    }
  }

  Future<List<Questionnaire>> getQuestionnairesByOrganization(
      String organizationId) async {
    _questionnaires.clear();
    var res = await DataAPI.getQuestionnairesByOrganization(organizationId);
    _questionnaires.addAll(res);
    _questController.sink.add(_questionnaires);
    return _questionnaires;
  }

  Future<List<Country>> getCountries() async {
    _countries.clear();
    var res = await DataAPI.getCountries();
    _countries.addAll(res);
    _cntryController.sink.add(_countries);
    return _countries;
  }

  Future updateUser(User user) async {
    //todo - sort out user update - check backend api
    var res = await DataAPI.updateUser(user);
    await cacheManager.addUser(user: res);
    var users = await cacheManager.getUsers();
    _userController.sink.add(users);
  }

  Future<List<User>> findUsersByOrganization(String organizationId) async {
    _users.clear();
    var res = await DataAPI.findUsersByOrganization(organizationId);
    _users.addAll(res);
    _userController.sink.add(_users);
    return _users;
  }

  Future<List<Project>> findProjectsByOrganization(
      String organizationId) async {
    _projects.clear();
    var res = await DataAPI.findProjectsByOrganization(organizationId);
    _projects.addAll(res);
    _projController.sink.add(_projects);
    return _projects;
  }

  Future<Project> findProjectById(String projectId) async {
    var res = await DataAPI.findProjectById(projectId);
    prettyPrint(res.toJson(), '❤️ 🧡 💛 RESULT: findProjectById: ❤️ 🧡 💛');
    pp('\n\n❤️ 🧡 💛');
    return res;
  }

  Future<Project> addProject(Project project) async {
    var res = await DataAPI.addProject(project);
    pp('🎽 🎽 🎽 adminBloc: addProject: Project adding to stream ...');
    _projects.add(res);
    _projController.sink.add(_projects);
    findProjectsByOrganization(project.organizationId!);
    return res;
  }

  Future<Project> updateProject(Project project) async {
    var res = await DataAPI.updateProject(project);
    pp('🎽 🎽 🎽 adminBloc: updateProject done. findProjectsByOrganization ...');
    findProjectsByOrganization(project.organizationId!);
    return res;
  }

  close() {
    _settController.close();
    _questController.close();
    _projController.close();
    _userController.close();
    _cntryController.close();
    _activeQuestionnaireController.close();
    _activeUserController.close();
  }
}
