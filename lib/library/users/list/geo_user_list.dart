import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/photo.dart';
import 'package:geo_monitor/library/data/video.dart';
import 'package:geo_monitor/library/users/edit/user_edit_main.dart';
import 'package:geo_monitor/library/users/edit/user_edit_tablet.dart';
import 'package:geo_monitor/library/users/list/user_list_card.dart';
import 'package:geo_monitor/ui/activity/geo_activity.dart';
import 'package:geo_monitor/ui/dashboard/user_dashboard.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/translation_handler.dart';
import '../../../ui/audio/gio_audio_player.dart';
import '../../../ui/dashboard/photo_frame.dart';
import '../../bloc/cloud_storage_bloc.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/geo_exception.dart';
import '../../bloc/geo_uploader.dart';
import '../../bloc/location_request_handler.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/audio.dart';
import '../../data/location_response.dart';
import '../../data/settings_model.dart';
import '../../data/user.dart';
import '../../errors/error_handler.dart';
import '../../functions.dart';
import '../../generic_functions.dart';
import '../../ui/camera/gio_video_player.dart';
import '../../ui/maps/location_response_map.dart';
import '../../ui/maps_field_monitor/field_monitor_map_mobile.dart';
import '../../ui/message/message_mobile.dart';
import '../../ui/schedule/scheduler_mobile.dart';
import '../kill_user_page.dart';
import '../user_batch_control.dart';

class GioUserList extends StatefulWidget {
  const GioUserList({
    Key? key,
    required this.dataApiDog,
    required this.prefsOGx,
    required this.cacheManager,
    required this.projectBloc,
    required this.organizationBloc,
    required this.fcmBloc,
    required this.geoUploader,
    required this.cloudStorageBloc,
  }) : super(key: key);

  final DataApiDog dataApiDog;
  final PrefsOGx prefsOGx;
  final CacheManager cacheManager;
  final ProjectBloc projectBloc;
  final OrganizationBloc organizationBloc;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  @override
  State<GioUserList> createState() => _GioUserListState();
}

class _GioUserListState extends State<GioUserList> {
  var users = <User>[];
  User? user;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _getData(false);
    _listen();
  }

  late StreamSubscription<User> _streamSubscription;
  late StreamSubscription<LocationResponse> _locationResponseSubscription;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  LocationResponse? locationResponse;

  String? title;

  void _listen() {
    settingsSubscriptionFCM = fcmBloc.settingsStream.listen((event) async {
      if (mounted) {
        await _setTexts();
        _getData(false);
      }
    });
    _streamSubscription = fcmBloc.userStream.listen((User user) {
      pp('$mm new user just arrived: ${user.toJson()}');
      if (mounted) {
        _getData(false);
      }
    });
    _locationResponseSubscription =
        fcmBloc.locationResponseStream.listen((LocationResponse event) {
      pp('$mm locationResponseStream delivered ... response: ${event.toJson()}');
      locationResponse = event;
      if (mounted) {
        setState(() {});
        _showLocationResponseDialog();
      }
    });
  }

  void _showLocationResponseDialog() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              shape: getRoundedBorder(radius: 16),
              title: Text(
                "Location Response",
                style: myTextStyleMediumBold(context),
              ),
              content: SizedBox(
                height: 260.0,
                width: 440.0,
                child: Card(
                  shape: getRoundedBorder(radius: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          locationResponse == null
                              ? ''
                              : locationResponse!.userName!,
                          style: myTextStyleLargePrimaryColor(context),
                        ),
                        const SizedBox(
                          height: 48,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Your location request has received a response. Do you want to see the response on a map?'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'NO',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text(
                    'YES',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToLocationResponseMap();
                  },
                ),
              ],
            ));
  }

  void _navigateToLocationResponseMap() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: LocationResponseMap(
              locationResponse: locationResponse!,
            )));
  }

  final mm = '🔵🔵🔵🔵🔵🔵 UserListTabletLandscape: ';
  String? subTitle;
  Future _setTexts() async {
    var sett = await prefsOGx.getSettings();
    title = await translator.translate('members', sett!.locale!);
    subTitle =
        await translator.translate('administratorsMembers', sett!.locale!);
    setState(() {});
  }

  void _getData(bool forceRefresh) async {
    setState(() {
      busy = true;
    });
    try {
      user = await prefsOGx.getUser();

      users = await organizationBloc.getUsers(
          organizationId: user!.organizationId!, forceRefresh: forceRefresh);
      p('$mm data refreshed, users: ${users.length}');
    } catch (e) {
      pp(e);
      if (mounted) {
        setState(() {
          busy = false;
        });
        if (e is GeoException) {
          var sett = await prefsOGx.getSettings();
          errorHandler.handleError(exception: e);
          final msg =
              await translator.translate(e.geTranslationKey(), sett.locale!);
          if (mounted) {
            showToast(
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: myTextStyleMedium(context),
                padding: 16,
                duration: const Duration(seconds: 10),
                message: msg,
                context: context);
          }
        }
      }
    }
    setState(() {
      busy = false;
    });
  }

  void navigateToUserReport(User user) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: UserDashboard(
              fcmBloc: widget.fcmBloc,
              organizationBloc: widget.organizationBloc,
              projectBloc: widget.projectBloc,
              dataApiDog: widget.dataApiDog,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
              user: user,
            )));
  }

  void navigateToUserBatchUpload(User? user) async {
    if (user != null) {
      if (user!.userType == UserType.fieldMonitor) {
        if (user.userId != user.userId!) {
          return;
        }
      }
    }
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: const UserBatchControl()));

    _getData(false);
  }

  void navigateToMessaging(User user) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.bottomLeft,
            duration: const Duration(seconds: 1),
            child: MessageMobile(
              user: user,
            )));
  }

  Future<void> navigateToPhone(User user) async {
    pp('💛️💛️💛 ... starting phone call ....');
    final Uri phoneUri = Uri(scheme: "tel", path: user.cellphone!);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (error) {
      throw ("Cannot dial");
    }
  }

  void navigateToMap(User user) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.bottomLeft,
            duration: const Duration(seconds: 1),
            child: FieldMonitorMapMobile(user)));
  }

  void navigateToScheduler(User user) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.bottomLeft,
            duration: const Duration(seconds: 1),
            child: SchedulerMobile(user)));
  }

  bool sortedByName = false;

  void navigateToUserEdit(User? user) async {
    if (user != null) {
      if (user!.userType == UserType.fieldMonitor) {
        if (user.userId != user.userId!) {
          return;
        }
      }
    }
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: UserEditMain(
              user,
              fcmBloc: widget.fcmBloc,
              organizationBloc: widget.organizationBloc,
              projectBloc: widget.projectBloc,
              dataApiDog: widget.dataApiDog,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
            )));
  }

  Future<void> navigateToKillPage(User user) async {
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.bottomLeft,
            duration: const Duration(seconds: 1),
            child: KillUserPage(
              user: user,
            )));
    pp('💛️💛️💛 ... back from KillPage; will refresh user list ....');
  }

  void _sendLocationRequest(User otherUser) async {
    setState(() {
      busy = true;
    });
    try {
      var user = await prefsOGx.getUser();
      await locationRequestHandler.sendLocationRequest(
          requesterId: user!.userId!,
          requesterName: user.name!,
          userId: otherUser.userId!,
          userName: otherUser.name!);
      if (mounted) {
        showToast(message: 'Location request sent', context: context);
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showToast(message: '$e', context: context);
      }
    }

    setState(() {
      busy = false;
    });
  }

  void navigateToUserDashboard(User user) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: UserDashboard(
              fcmBloc: widget.fcmBloc,
              organizationBloc: widget.organizationBloc,
              projectBloc: widget.projectBloc,
              dataApiDog: widget.dataApiDog,
              geoUploader: widget.geoUploader,
              cloudStorageBloc: widget.cloudStorageBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
              user: user,
            )));
  }

  void _sort() {
    if (sortedByName) {
      _sortByNameDesc();
    } else {
      _sortByName();
    }
  }

  void _sortByName() {
    users.sort((a, b) => a.name!.compareTo(b.name!));
    sortedByName = true;
    setState(() {});
  }

  void _sortByNameDesc() {
    users.sort((a, b) => b.name!.compareTo(a.name!));
    sortedByName = false;
    setState(() {});
  }

  List<Widget> _getActions() {
    final type = getThisDeviceType();
    if (type == 'phone') {
      return [
        PopupMenuButton(itemBuilder: (ctx) {
          return [
            PopupMenuItem(
                value: 0,
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                )),
            PopupMenuItem(
                value: 1,
                child: Icon(
                  Icons.people,
                  color: Theme.of(context).primaryColor,
                )),
            PopupMenuItem(
                value: 2,
                child: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                )),
          ];
        }, onSelected: (index) {
          pp('$mm ...................... action index: $index');
          switch (index) {
            case 0:
              navigateToUserEdit(null);
              break;
            case 1:
              navigateToUserBatchUpload(null);
              break;
            case 2:
              _getData(true);
              break;
          }
        }),
      ];
    } else {
      return [
        IconButton(
            onPressed: () {
              navigateToUserEdit(null);
            },
            icon: Icon(
              Icons.add,
              color: Theme.of(context).primaryColor,
            )),
        IconButton(
            onPressed: () {
              navigateToUserBatchUpload(null);
            },
            icon: Icon(
              Icons.people,
              color: Theme.of(context).primaryColor,
            )),
        IconButton(
            onPressed: () {
              _getData(true);
            },
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).primaryColor,
            ))
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    var amInPortrait = false;
    final ori = MediaQuery.of(context).orientation.name;
    var style = myTextStyleLarge(context);
    final type = getThisDeviceType();
    if (type == 'phone') {
      style = myTextStyleMediumLarge(context);
    }
    if (ori == 'portrait') {
      amInPortrait = true;
    }
    var mWidth = MediaQuery.of(context).size.width;
    var color = getTextColorForBackground(Theme.of(context).primaryColor);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (!isDarkMode) {
      color = Colors.white;
    } else {
      color = Theme.of(context).primaryColor;
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            title == null ? 'Members' : title!,
            style: myTitleTextStyle(context, color),
          ),
          actions: _getActions(),
        ),
        backgroundColor: isDarkMode?Theme.of(context).canvasColor: Colors.brown[50],
        body: Stack(
          children: [
            ScreenTypeLayout(
              mobile: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    user == null
                        ? const SizedBox()
                        : Expanded(
                            child: UserListCard(
                              subTitle: subTitle == null
                                  ? 'Admins & Monitors'
                                  : subTitle!,
                              amInLandscape: true,
                              users: users,
                              avatarRadius: 20,
                              deviceUser: user!,
                              navigateToLocationRequest: (mUser) {
                                _sendLocationRequest(mUser);
                              },
                              navigateToPhone: (mUser) {
                                navigateToPhone(mUser);
                              },
                              navigateToMessaging: (user) {
                                navigateToMessaging(user);
                              },
                              navigateToUserDashboard: (user) {
                                navigateToUserDashboard(user);
                              },
                              navigateToUserEdit: (user) {
                                navigateToUserEdit(user);
                              },
                              navigateToScheduler: (user) {
                                navigateToScheduler(user);
                              },
                              navigateToKillPage: (user) {
                                navigateToKillPage(user);
                              },
                              badgeTapped: () {
                                _sort();
                              },
                            ),
                          ),
                  ],
                ),
              ),
              tablet: OrientationLayoutBuilder(landscape: (ctx) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 48.0, right: 24.0, top: 24.0, bottom: 24),
                  child: Row(
                    children: [
                      user == null
                          ? const SizedBox()
                          : SizedBox(
                              width: (mWidth / 2) - 80,
                              child: UserListCard(
                                subTitle: subTitle == null
                                    ? 'Admins & Monitors'
                                    : subTitle!,
                                amInLandscape: true,
                                avatarRadius: 20,
                                users: users,
                                deviceUser: user!,
                                navigateToLocationRequest: (mUser) {
                                  _sendLocationRequest(mUser);
                                },
                                navigateToPhone: (mUser) {
                                  navigateToPhone(mUser);
                                },
                                navigateToMessaging: (user) {
                                  navigateToMessaging(user);
                                },
                                navigateToUserDashboard: (user) {
                                  navigateToUserReport(user);
                                },
                                navigateToUserEdit: (user) {
                                  navigateToUserEdit(user);
                                },
                                navigateToScheduler: (user) {
                                  navigateToScheduler(user);
                                },
                                navigateToKillPage: (user) {
                                  navigateToKillPage(user);
                                },
                                badgeTapped: () {
                                  _sort();
                                },
                              )),
                      GeoActivity(
                          width: mWidth / 2,
                          thinMode: false,
                          prefsOGx: widget.prefsOGx,
                          cacheManager: widget.cacheManager,
                          showPhoto: showPhoto,
                          showVideo: showVideo,
                          showAudio: showAudio,
                          fcmBloc: widget.fcmBloc,
                          organizationBloc: widget.organizationBloc,
                          projectBloc: widget.projectBloc,
                          project: null,
                          dataApiDog: widget.dataApiDog,
                          geoUploader: widget.geoUploader,
                          cloudStorageBloc: widget.cloudStorageBloc,
                          showUser: (user) {},
                          showLocationRequest: (req) {},
                          showLocationResponse: (resp) {
                            locationResponse = resp;
                            _navigateToLocationResponseMap();
                          },
                          showGeofenceEvent: (event) {},
                          showProjectPolygon: (polygon) {},
                          showProjectPosition: (position) {},
                          showOrgMessage: (message) {},
                          forceRefresh: false),
                    ],
                  ),
                );
              }, portrait: (ctx) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16.0, top: 48, bottom: 48),
                  child: Row(
                    children: [
                      user == null
                          ? const SizedBox()
                          : SizedBox(
                              width: (mWidth / 2) - 40,
                              child: UserListCard(
                                subTitle: subTitle == null
                                    ? 'Admins & Monitors'
                                    : subTitle!,
                                amInLandscape: true,
                                avatarRadius: 20,
                                users: users,
                                deviceUser: user!,
                                navigateToLocationRequest: (mUser) {
                                  _sendLocationRequest(mUser);
                                },
                                navigateToPhone: (mUser) {
                                  navigateToPhone(mUser);
                                },
                                navigateToMessaging: (user) {
                                  navigateToMessaging(user);
                                },
                                navigateToUserDashboard: (user) {
                                  navigateToUserReport(user);
                                },
                                navigateToUserEdit: (user) {
                                  navigateToUserEdit(user);
                                },
                                navigateToScheduler: (user) {
                                  navigateToScheduler(user);
                                },
                                navigateToKillPage: (user) {
                                  navigateToKillPage(user);
                                },
                                badgeTapped: () {
                                  _sort();
                                },
                              ),
                            ),
                      const SizedBox(
                        width: 8,
                      ),
                      GeoActivity(
                          width: (mWidth / 2),
                          thinMode: true,
                          prefsOGx: widget.prefsOGx,
                          cacheManager: widget.cacheManager,
                          showPhoto: showPhoto,
                          showVideo: showVideo,
                          showAudio: showAudio,
                          fcmBloc: widget.fcmBloc,
                          organizationBloc: widget.organizationBloc,
                          projectBloc: widget.projectBloc,
                          geoUploader: widget.geoUploader,
                          cloudStorageBloc: widget.cloudStorageBloc,
                          project: null,
                          dataApiDog: widget.dataApiDog,
                          showUser: (user) {},
                          showLocationRequest: (req) {},
                          showLocationResponse: (resp) {
                            locationResponse = resp;
                            _navigateToLocationResponseMap();
                          },
                          showGeofenceEvent: (event) {},
                          showProjectPolygon: (polygon) {},
                          showProjectPosition: (position) {},
                          showOrgMessage: (message) {},
                          forceRefresh: false),
                    ],
                  ),
                );
              }),
            ),
            _showPhoto
                ? Positioned(
                    left: amInPortrait ? 160 : 300,
                    right: amInPortrait ? 160 : 300,
                    child: PhotoCard(
                        photo: selectedPhoto!,
                        translatedDate: translatedDate!,
                        onPhotoCardClose: () {
                          setState(() {
                            _showPhoto = false;
                          });
                        },
                        elevation: 12.0,
                        onMapRequested: onMapRequested,
                        onRatingRequested: onRatingRequested),
                  )
                : const SizedBox(),
            _playAudio
                ? Positioned(
                    left: amInPortrait ? 200 : 300,
                    right: amInPortrait ? 200 : 300,
                    child: GioAudioPlayer(
                      cacheManager: widget.cacheManager,
                      prefsOGx: widget.prefsOGx,
                      audio: selectedAudio!,
                      onCloseRequested: () {
                        setState(() {
                          _playAudio = false;
                        });
                      },
                      dataApiDog: widget.dataApiDog,
                    ),
                  )
                : const SizedBox(),
            _playVideo
                ? Positioned(
                    child: GioVideoPlayer(
                    video: selectedVideo!,
                    onCloseRequested: () {
                      setState(() {
                        _playVideo = false;
                      });
                    },
                    width: 400,
                    dataApiDog: widget.dataApiDog,
                  ))
                : const SizedBox(),
          ],
        ));
  }

  bool _showPhoto = false;
  bool _playAudio = false;
  bool _playVideo = false;
  Photo? selectedPhoto;
  Video? selectedVideo;
  Audio? selectedAudio;

  Audio? audio;
  String? translatedDate;
  showPhoto(Photo p1) async {
    selectedPhoto = p1;
    final settings = await prefsOGx.getSettings();
    translatedDate = getFmtDate(p1.created!, settings!.locale!);
    setState(() {
      _showPhoto = true;
      _playAudio = false;
      _playVideo = false;
    });
  }

  showVideo(Video p1) {
    selectedVideo = p1;
    setState(() {
      _showPhoto = false;
      _playAudio = false;
      _playVideo = true;
    });
  }

  showAudio(Audio p1) {
    selectedAudio = p1;
    setState(() {
      _showPhoto = false;
      _playAudio = true;
      _playVideo = false;
    });
  }

  onMapRequested(Photo p1) {}

  onRatingRequested(Photo p1) {}
}
