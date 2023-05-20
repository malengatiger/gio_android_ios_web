import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/l10n/translation_handler.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import '../../../device_location/device_location_bloc.dart';
import '../../api/prefs_og.dart';
import '../../cache_manager.dart';
import '../../data/audio.dart';
import '../../data/photo.dart';
import '../../data/position.dart';
import '../../data/rating.dart';
import '../../data/user.dart';
import '../../data/video.dart';
import '../../functions.dart';
import '../../generic_functions.dart';

class RatingAdder extends StatefulWidget {
  const RatingAdder({
    Key? key,
    this.audio,
    this.video,
    this.photo,
    // required this.width,
    required this.onDone,
    required this.elevation,
    required this.dataApiDog,
  }) : super(key: key);

  final Audio? audio;
  final Video? video;
  final Photo? photo;
  // final double width;
  final double elevation;
  final DataApiDog dataApiDog;

  final Function() onDone;

  @override
  RatingAdderState createState() => RatingAdderState();
}

class RatingAdderState extends State<RatingAdder>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool busy = false;
  final mm = '🌀🌀🌀🌀Rating Adder, snake? : ';
  User? user;
  String? addAudioRating,
      addVideoRating,
      addPhotoRating,
      date,
      ratingAddedThanks;
  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    _checkMedia();
    _setTexts();
  }

  void _setTexts() async {
    var sett = await prefsOGx.getSettings();
    addAudioRating = await translator.translate('addAudioRating', sett.locale!);
    addVideoRating = await translator.translate('addVideoRating', sett.locale!);
    addPhotoRating = await translator.translate('addPhotoRating', sett.locale!);
    ratingAddedThanks =
        await translator.translate('ratingAddedThanks', sett.locale!);

    if (widget.video != null) {
      date = getFmtDate(widget.video!.created!, sett.locale!);
    }
    if (widget.audio != null) {
      date = getFmtDate(widget.audio!.created!, sett.locale!);
    }
    if (widget.photo != null) {
      date = getFmtDate(widget.photo!.created!, sett.locale!);
    }
  }

  Future _getUser() async {
    if (widget.video != null) {
      user = await cacheManager.getUserById(widget.video!.userId!);
    }
    if (widget.photo != null) {
      user = await cacheManager.getUserById(widget.photo!.userId!);
    }
    if (widget.audio != null) {
      user = await cacheManager.getUserById(widget.audio!.userId!);
    }
  }

  void _checkMedia() async {
    if (widget.video == null && widget.audio == null && widget.photo == null) {
      throw Exception('You need one of audio, video or photo ');
    }
    await _getUser();
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendRating(double ratingSelected) async {
    pp('$mm _submitRating .... ratingSelected: $ratingSelected');
    setState(() {
      busy = true;
    });
    try {
      var user = await prefsOGx.getUser();
      var loc = await locationBloc.getLocation();

      var projectId = '', projectName = '', organizationId = '';
      if (widget.photo != null) {
        projectId = widget.photo!.projectId!;
        projectName = widget.photo!.projectName!;
        organizationId = widget.photo!.organizationId!;
      }
      if (widget.video != null) {
        projectId = widget.video!.projectId!;
        projectName = widget.video!.projectName!;
        organizationId = widget.video!.organizationId!;
      }
      if (widget.audio != null) {
        projectId = widget.audio!.projectId!;
        projectName = widget.audio!.projectName!;
        organizationId = widget.audio!.organizationId!;
      }

      var rating = Rating(
          remarks: null,
          created: DateTime.now().toUtc().toIso8601String(),
          position: loc == null
              ? null
              : Position(
                  coordinates: [loc.longitude, loc.latitude], type: 'Point'),
          userId: user!.userId,
          userName: user.name,
          ratingCode: ratingSelected.round(),
          projectId: projectId,
          audioId: widget.audio == null ? null : widget.audio!.audioId,
          videoId: widget.video == null ? null : widget.video!.videoId,
          photoId: widget.photo == null ? null : widget.photo!.photoId,
          ratingId: const Uuid().v4(),
          organizationId: organizationId,
          projectName: projectName);

      var res = await widget.dataApiDog.addRating(rating);
      pp('$mm rating added; ${res.toJson()}');
      if (mounted) {
        showToast(
            textStyle: myTextStyleMedium(context),
            padding: 8,
            duration: const Duration(seconds: 6),
            toastGravity: ToastGravity.TOP,
            backgroundColor: Theme.of(context).primaryColor,
            message: ratingAddedThanks == null
                ? "Rating added, thank you!"
                : ratingAddedThanks!,
            context: context);
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
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    var title = '';
    var projectName = '', userName = '';
    if (widget.photo != null) {
      title = addPhotoRating == null ? 'Rate Photo' : addPhotoRating!;
      projectName = widget.photo!.projectName!;
      userName = widget.photo!.userName!;
    }
    if (widget.video != null) {
      title = addVideoRating == null ? 'Rate Video' : addVideoRating!;
      projectName = widget.video!.projectName!;
      userName = widget.video!.userName!;
    }
    if (widget.audio != null) {
      title = addAudioRating == null ? 'Rate Audio' : addAudioRating!;
      projectName = widget.audio!.projectName!;
      userName = widget.audio!.userName!;
    }
    final width = MediaQuery.of(context).size.width;
    var mWidth = width;
    final type = getThisDeviceType();
    if (type == 'phone') {
      mWidth = mWidth - 48;
    } else {
      mWidth = mWidth / 2;
    }
    return Stack(
      children: [
        ScreenTypeLayout(
          mobile: RatingCard(
            width: mWidth,
            height: 360,
            padding: 24,
            projectName: projectName,
            date: date == null ? '' : date!,
            title: title,
            onRatingSelected: _sendRating,
            userName: userName,
            userThumbnailUrl: user == null ? null : user!.thumbnailUrl!,
            elevation: 8.0,
          ),
          tablet: RatingCard(
            width: mWidth,
            height: 460,
            padding: 24,
            projectName: projectName,
            date: date == null ? '' : date!,
            title: title,
            onRatingSelected: _sendRating,
            userName: userName,
            userThumbnailUrl: user == null ? null : user!.thumbnailUrl!,
            elevation: 8.0,
          ),
        ),
        busy
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.pink,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class RatingCard extends StatelessWidget {
  const RatingCard(
      {Key? key,
      required this.width,
      required this.height,
      required this.onRatingSelected,
      required this.title,
      required this.padding,
      required this.projectName,
      required this.date,
      required this.userName,
      required this.userThumbnailUrl,
      required this.elevation})
      : super(key: key);

  final Function(double) onRatingSelected;
  final double width, height, padding, elevation;
  final String title, projectName, date, userName;
  final String? userThumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: elevation,
        shape: getRoundedBorder(radius: 16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: padding,
              ),
              Text(
                projectName,
                style: myTextStyleMediumBold(context),
              ),
              const SizedBox(
                height: 28,
              ),
              Text(
                title,
                style: myTextStyleMediumLarge(context),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                date,
                style: myTextStyleSmall(context),
              ),
              const SizedBox(
                height: 28,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userName,
                    style: myTextStyleMediumPrimaryColor(context),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  userThumbnailUrl == null
                      ? const CircleAvatar(
                          radius: 20,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(userThumbnailUrl!),
                          radius: 20,
                        )
                ],
              ),
              const SizedBox(
                height: 48,
              ),
              RatingBar.builder(
                initialRating: 1,
                minRating: 1,
                maxRating: 5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemSize: 32,
                glow: true,
                glowColor: Colors.teal,
                glowRadius: 8,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                onRatingUpdate: (rating) {
                  pp('🎽🎽🎽 $rating is the rating picked!');
                  onRatingSelected(rating);
                },
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
