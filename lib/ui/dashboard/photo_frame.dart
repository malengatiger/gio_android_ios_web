import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/project_bloc.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/maps/photo_map.dart';
import 'package:geo_monitor/library/ui/media/time_line/project_media_timeline.dart';
import 'package:geo_monitor/library/ui/message/monitor_message.dart';
import 'package:geo_monitor/library/ui/ratings/rating_adder.dart';
import 'package:geo_monitor/ui/activity/user_profile_card.dart';
import 'package:geo_monitor/utilities/transitions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/data_api_og.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/data/photo.dart';
import '../../library/data/project.dart';
import '../../library/data/user.dart';
import '../../library/emojis.dart';
import '../../library/functions.dart';

class PhotoCard extends StatelessWidget {
  const PhotoCard(
      {Key? key,
      required this.photo,
      required this.onMapRequested,
      required this.onRatingRequested,
      required this.elevation,
      required this.onPhotoCardClose,
      required this.translatedDate})
      : super(key: key);

  final Photo photo;
  final Function(Photo) onMapRequested;
  final Function(Photo) onRatingRequested;
  final Function onPhotoCardClose;
  final double elevation;
  final String translatedDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: getRoundedBorder(radius: 16),
      elevation: elevation,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      onMapRequested(photo);
                    },
                    icon: Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    )),
                TextButton(
                  onPressed: () {
                    onRatingRequested(photo);
                  },
                  child: Text(
                    E.heartRed,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      onPhotoCardClose();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                    )),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: getRoundedBorder(radius: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        '${photo.projectName}',
                        style: myTextStyleMediumLargePrimaryColor(context),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UserProfileCard(
                              userName: photo.userName!,
                              userThumbUrl: photo.userUrl,
                              elevation: 3,
                              padding: 0.0,
                              avatarRadius: 16,
                              textStyle: myTextStyleSmall(context),
                              namePictureHorizontal: true),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            translatedDate,
                            style: myTextStyleTinyBold(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
              child: SingleChildScrollView(
                child: InteractiveViewer(
                    child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        backgroundColor: Colors.pink,
                                        value: downloadProgress.progress))),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fadeInDuration: const Duration(milliseconds: 1500),
                        fadeInCurve: Curves.easeInOutCirc,
                        placeholderFadeInDuration:
                            const Duration(milliseconds: 1500),
                        imageUrl: photo.url!)),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class Headline extends StatelessWidget {
  const Headline({Key? key, required this.user, required this.paddingLeft})
      : super(key: key);
  final User user;
  final double paddingLeft;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          user.organizationName == null
              ? const SizedBox()
              : Text(
                  '${user.organizationName}',
                  style: myTextStyleMediumLargePrimaryColor(context)),
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: EdgeInsets.only(left: paddingLeft),
            child: Row(
              children: [
                user.thumbnailUrl == null
                    ? const CircleAvatar(
                        radius: 24,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(user.thumbnailUrl!),
                        radius: 24,
                      ),
                const SizedBox(
                  width: 28,
                ),
                Text(
                  '${user.name}',
                  style: myTextStyleMediumBold(context),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 0,
          ),
        ],
      ),
    );
  }
}

///Full screen photo viewer
class PhotoFrame extends StatefulWidget {
  const PhotoFrame(
      {Key? key,
      required this.photo,
      required this.onMapRequested,
      required this.onRatingRequested,
      required this.elevation,
      required this.onPhotoCardClose,
      required this.translatedDate,
      required this.locale,
      required this.cacheManager,
      required this.dataApiDog,
      required this.prefsOGx,
      required this.fcmBloc,
      required this.projectBloc,
      required this.organizationBloc, required this.geoUploader, required this.cloudStorageBloc})
      : super(key: key);

  final Photo photo;
  final Function(Photo) onMapRequested;
  final Function(Photo) onRatingRequested;
  final Function onPhotoCardClose;
  final double elevation;
  final String translatedDate;
  final String locale;
  final CacheManager cacheManager;
  final DataApiDog dataApiDog;
  final PrefsOGx prefsOGx;
  final FCMBloc fcmBloc;
  final ProjectBloc projectBloc;
  final OrganizationBloc organizationBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  @override
  State<PhotoFrame> createState() => PhotoFrameState();
}

class PhotoFrameState extends State<PhotoFrame> {
  String? photoUserThumbnailUrl, photoUserUrl;

  String? timeLine,
      seeLocationDetails,
      ratePhoto,
      createdBy,
      sendMemberMessage,
      close, title,
      actionsOnPhoto;
  late SettingsModel settings;
  @override
  void initState() {
    super.initState();
    _setTexts();
    _getUser();
  }

  Future _setTexts() async {
    settings = await widget.prefsOGx.getSettings();
    final locale = settings.locale!;
    timeLine = await translator.translate('timeLine', locale);
    seeLocationDetails =
        await translator.translate('seeLocationDetails', locale);
    ratePhoto = await translator.translate('ratePhoto', locale);
    createdBy = await translator.translate('createdBy', locale);
    close = await translator.translate('close', locale);
    actionsOnPhoto = await translator.translate('actionsOnPhoto', locale);
    sendMemberMessage = await translator.translate('sendMemberMessage', locale);
    title = await translator.translate('photos', locale);

  }
  late Project project;
  void _getUser() async {
    final photoUser = await cacheManager.getUserById(widget.photo.userId!);
    if (photoUser != null) {
      photoUserThumbnailUrl = photoUser.thumbnailUrl!;
      photoUserUrl = photoUser.imageUrl!;
    }
    var p = await widget.cacheManager.getProjectById(projectId: widget.photo.projectId!);
    if (p != null) {
      project = p;
    }
    setState(() {});
  }

  void _navigateToTimeline() async {

    navigateWithScale(
        ProjectMediaTimeline(
            project: project,
            projectBloc: widget.projectBloc,
            prefsOGx: widget.prefsOGx,
            organizationBloc: widget.organizationBloc,
            cacheManager: widget.cacheManager,
            dataApiDog: widget.dataApiDog,
            geoUploader: widget.geoUploader,
            cloudStorageBloc: widget.cloudStorageBloc,
            fcmBloc: widget.fcmBloc),
        context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photo.landscape == 0) {
      pp('🌸🌸🌸🌸🌸🌸 photoCover landscape photo: ${widget.photo.photoId} '
          '- ${widget.photo.created}');
    }
    var leftPadding = 100.0;
    var rightPadding = 100.0;
    final deviceType = getThisDeviceType();
    if (deviceType == 'phone') {
      leftPadding = 20;
      rightPadding = 20;
    }
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(title == null?'Photo': title!, style: myTextStyleLargeWithColor(context, color),),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(96),
            child: Column(
              children: [
                PhotoHeader(
                  title: widget.photo.projectName!,
                  date: widget.photo.created!,
                  locale: widget.locale,
                  color: color,
                  userUrl: widget.photo.userUrl,
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            )),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //        Navigator.of(context).pop();
        //       },
        //       icon: Icon(
        //         Icons.view_list_sharp,
        //         color: color,
        //       ))
        // ],
      ),
      body: Stack(
        children: [
          InteractiveViewer(
              child: GestureDetector(
            onTap: _showSheet,
            child: RotatedBox(
              quarterTurns: widget.photo.landscape == 0 ? 1 : 0,
              child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  backgroundColor: Colors.pink,
                                  value: downloadProgress.progress))),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fadeInDuration: const Duration(milliseconds: 1500),
                  fadeInCurve: Curves.easeInOutCirc,
                  placeholderFadeInDuration: const Duration(milliseconds: 1500),
                  imageUrl: widget.photo.url!),
            ),
          )),
          showPhotoCreator
              ? Positioned(
                  child: Card(
                  shape: getRoundedBorder(radius: 16),
                  color: Colors.black38,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 480,
                      height: 640,
                      child: GestureDetector(
                        onTap: _hideCreator,
                        child: CachedNetworkImage(
                            fit: BoxFit.cover, imageUrl: photoUserUrl!),
                      ),
                    ),
                  ),
                ))
              : const SizedBox(),
          showRatingAdder
              ? Positioned(
                  left: leftPadding,
                  right: rightPadding,
                  bottom: 100,
                  child: RatingAdder(
                    photo: widget.photo,
                    onDone: onRatingDone,
                    elevation: 8,
                    dataApiDog: widget.dataApiDog,
                  ))
              : const SizedBox(),
          showMessage
              ? Positioned(
                  left: 100,
                  right: 100,
                  child: MonitorMessage(
                    projectId: widget.photo.projectId!,
                    userId: widget.photo.userId!,
                    cacheManager: widget.cacheManager,
                    dataApiDog: widget.dataApiDog,
                  ))
              : const SizedBox(),
        ],
      ),
    ));
  }

  bool sheetIsShowing = false;

  void _showSheet() {
    pp('................... _showSheet');

    showModalBottomSheet(
        elevation: 4,
        context: context,
        builder: (context) {
          return SizedBox(
            height: 400,
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Text(
                  actionsOnPhoto == null ? 'Actions on Photo' : actionsOnPhoto!,
                  style: myTextStyleMediumLarge(context),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextButton(
                    onPressed: () {
                      _navigateToMap();
                    },
                    child: Text(seeLocationDetails == null
                        ? 'See location details of photo'
                        : seeLocationDetails!)),
                const SizedBox(
                  height: 12,
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        showMessage = true;
                      });
                    },
                    child: Text(sendMemberMessage == null
                        ? 'Send message to creator'
                        : sendMemberMessage!)),
                const SizedBox(
                  height: 12,
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        showRatingAdder = true;
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text(ratePhoto == null ? 'Rate Photo' : ratePhoto!)),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   createdBy == null ? 'Created By' : createdBy!,
                    //   style: myTextStyleTiny(context),
                    // ),
                    // const SizedBox(
                    //   width: 20,
                    // ),
                    GestureDetector(
                      onTap: _showCreator,
                      child: UserProfileCard(
                          userName: widget.photo.userName!,
                          // width: 300,
                          avatarRadius: 14,
                          userThumbUrl: photoUserThumbnailUrl,
                          textStyle: myTextStyleSmallBlackBold(context),
                          namePictureHorizontal: true),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child:
                            Text(close == null ? 'Close the photo' : close!)),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
    sheetIsShowing = true;
  }

  _navigateToMap() {
    pp('_navigateToMap .... ');
    if (mounted) {
      Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1000),
            child: PhotoMap(photo: widget.photo),
          ));
    }
  }

  bool showPhotoCreator = false;
  bool showMessage = false;
  bool showRatingAdder = false;

  void _showCreator() {
    pp('show creator .........');
    setState(() {
      showPhotoCreator = true;
    });
  }

  void _hideCreator() {
    pp('hide creator .........');
    setState(() {
      showPhotoCreator = false;
    });
  }

  onRatingDone() {
    setState(() {
      showRatingAdder = false;
    });
  }
}

class PhotoHeader extends StatelessWidget {
  const PhotoHeader({
    Key? key,
    required this.title,
    required this.date,
    required this.locale,
    required this.userUrl, required this.color,
  }) : super(key: key);
  final String title;
  final String date, locale;
  final String? userUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final mStart = getFmtDate(date, locale);
    var vertical = false;
    final type = getThisDeviceType();
    if (type == 'phone') {
      vertical = true;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: vertical
          ? Column(
              children: [
                Text(
                  title,
                  style: myTextStyleMediumBoldWithColor(context, color),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mStart,
                      style: myTextStyleSmallWithColor(context, color),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    userUrl == null
                        ? const CircleAvatar(
                            radius: 12,
                          )
                        : CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(userUrl!),
                          ),
                  ],
                )
              ],
            )
          : Row(
              children: [
                Text(
                  title,
                  style: myTextStyleMediumBoldPrimaryColor(context),
                ),
                const SizedBox(
                  width: 48,
                ),
                Text(
                  mStart,
                  style: myTextStyleSmall(context),
                ),
              ],
            ),
    );
  }
}
