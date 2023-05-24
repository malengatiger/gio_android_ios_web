import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/audio.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/video.dart';
import 'package:geo_monitor/library/users/edit/user_form.dart';
import 'package:geo_monitor/ui/activity/geo_activity.dart';
import 'package:geo_monitor/ui/activity/user_profile_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../l10n/translation_handler.dart';
import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/cloud_storage_bloc.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/geo_uploader.dart';
import '../../bloc/organization_bloc.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/country.dart';
import '../../data/location_response.dart';
import '../../data/project.dart';
import '../../data/user.dart' as ar;
import '../../functions.dart';
import '../../ui/maps/location_response_map.dart';

class UserEditor extends StatefulWidget {
  final ar.User? user;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final Project? project;
  final OrganizationBloc organizationBloc;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  const UserEditor(
      {super.key,
      this.user,
      required this.prefsOGx,
      required this.cacheManager,
      required this.projectBloc,
      this.project,
      required this.organizationBloc,
      required this.dataApiDog,
      required this.fcmBloc,
      required this.geoUploader,
      required this.cloudStorageBloc});

  @override
  UserEditorState createState() => UserEditorState();
}

class UserEditorState extends State<UserEditor>
    with SingleTickerProviderStateMixin {
  ar.User? admin;
  final _key = GlobalKey<ScaffoldState>();
  var isBusy = false;
  Country? country;
  String? title, subTitle;

  @override
  void initState() {
    super.initState();
    _getAdministrator();
  }

  void _getAdministrator() async {
    admin = await prefsOGx.getUser();
    var sett = await prefsOGx.getSettings();
    title = await translator.translate('editMember', sett.locale!);

    setState(() {});
  }

  void _navigateToLocationResponseMap(LocationResponse locationResponse) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: LocationResponseMap(
              locationResponse: locationResponse,
            )));
  }

  showPhoto(Photo p1) {}

  showVideo(Video p1) {}

  showAudio(Audio p1) {}

  @override
  Widget build(BuildContext context) {
    final ori = MediaQuery.of(context).orientation;
    if (ori.name == 'portrait') {
    } else {}
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            title == null ? 'Geo Member Editor' : title!,
            style: myTextStyleLarge(context),
          ),
        ),
        body: OrientationLayoutBuilder(
          portrait: (ctx) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: (width / 2) - 24,
                        child: widget.user == null
                            ? UserForm(
                                width: width / 2,
                                internalPadding: 24,
                                user: widget.user,
                              )
                            : bd.Badge(
                                position: bd.BadgePosition.topStart(
                                    top: -48, start: -24),
                                badgeStyle: const bd.BadgeStyle(
                                    badgeColor: Colors.transparent,
                                    shape: bd.BadgeShape.square,
                                    elevation: 16),
                                badgeContent: widget.user == null
                                    ? const SizedBox()
                                    : UserProfileCard(
                                        userName: widget.user!.name!,
                                        userThumbUrl: widget.user!.thumbnailUrl,
                                        namePictureHorizontal: true,
                                        avatarRadius: 20,
                                        elevation: 8,
                                        textStyle: myTextStyleMedium(context),
                                      ),
                                child: UserForm(
                                  width: width / 2,
                                  internalPadding: 24,
                                  user: widget.user,
                                ),
                              ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      GeoActivity(
                          width: (width / 2) - 40,
                          thinMode: true,
                          prefsOGx: widget.prefsOGx,
                          cacheManager: widget.cacheManager,
                          showPhoto: showPhoto,
                          showVideo: showVideo,
                          showAudio: showAudio,
                          showUser: (user) {},
                          fcmBloc: widget.fcmBloc,
                          organizationBloc: widget.organizationBloc,
                          projectBloc: widget.projectBloc,
                          geoUploader: widget.geoUploader,
                          cloudStorageBloc: widget.cloudStorageBloc,
                          project: widget.project,
                          dataApiDog: widget.dataApiDog,
                          showLocationRequest: (req) {},
                          showLocationResponse: (resp) {
                            _navigateToLocationResponseMap(resp);
                          },
                          showGeofenceEvent: (event) {},
                          showProjectPolygon: (polygon) {},
                          showProjectPosition: (position) {},
                          showOrgMessage: (message) {},
                          forceRefresh: false)
                    ],
                  ),
                ),
              ],
            );
          },
          landscape: (ctx) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      bd.Badge(
                        position:
                            bd.BadgePosition.topStart(top: -28, start: -20),
                        badgeStyle: const bd.BadgeStyle(
                            badgeColor: Colors.transparent,
                            shape: bd.BadgeShape.square,
                            elevation: 16),
                        badgeContent: widget.user == null
                            ? const SizedBox()
                            : UserProfileCard(
                                userName: widget.user!.name!,
                                userThumbUrl: widget.user!.thumbnailUrl,
                                namePictureHorizontal: true,
                                elevation: 8,
                                textStyle: myTextStyleMedium(context),
                              ),
                        child: UserForm(
                          width: width / 2,
                          internalPadding: 36,
                          user: widget.user,
                        ),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      GeoActivity(
                          width: (width / 2) - 100,
                          thinMode: true,
                          prefsOGx: widget.prefsOGx,
                          cacheManager: widget.cacheManager,
                          showPhoto: showPhoto,
                          showVideo: showVideo,
                          showAudio: showAudio,
                          showUser: (user) {},
                          fcmBloc: widget.fcmBloc,
                          organizationBloc: widget.organizationBloc,
                          projectBloc: widget.projectBloc,
                          project: widget.project,
                          dataApiDog: widget.dataApiDog,
                          geoUploader: widget.geoUploader,
                          cloudStorageBloc: widget.cloudStorageBloc,
                          showLocationRequest: (req) {},
                          showLocationResponse: (resp) {
                            _navigateToLocationResponseMap(resp);
                          },
                          showGeofenceEvent: (event) {},
                          showProjectPolygon: (polygon) {},
                          showProjectPosition: (position) {},
                          showOrgMessage: (message) {},
                          forceRefresh: false)
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
