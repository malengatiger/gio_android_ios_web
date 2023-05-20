import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/bloc/geo_exception.dart';
import 'package:geo_monitor/library/cache_manager.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/translation_handler.dart';
import '../api/data_api_og.dart';
import '../data/settings_model.dart';
import '../data/user.dart';
import '../generic_functions.dart';

class UserProfilePictureEditor extends StatefulWidget {
  const UserProfilePictureEditor(
      {Key? key, required this.user, required this.goToDashboardWhenDone})
      : super(key: key);
  final User user;
  final bool goToDashboardWhenDone;
  @override
  UserProfilePictureEditorState createState() => UserProfilePictureEditorState();
}

class UserProfilePictureEditorState extends State<UserProfilePictureEditor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ImagePicker _picker = ImagePicker();
  final mm = '🐳🐳🐳🐳🐳🐳 AvatarEditor: ';
  final height = 800.0, width = 600.0;
  File? finalFile;

  bool _showOldPhoto = false;
  bool _showNewPhoto = false;
  String? memberProfilePicture,
      useCamera,
      pickFromGallery,
      memberProfileUploaded,
      memberProfileUploadFailed,
      profileInstruction;
  late StreamSubscription<SettingsModel> settingsStreamSubscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _listen();
    if (widget.user.thumbnailUrl != null) {
      _showOldPhoto = true;
    }
  }

  void _listen() async {
    settingsStreamSubscription = fcmBloc.settingsStream.listen((event) {
      _setTexts();
    });
  }

  @override
  void dispose() {
    settingsStreamSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  late SettingsModel sett;
  Future _setTexts() async {
    sett = await prefsOGx.getSettings();
    profileInstruction =
        await translator.translate('profileInstruction', sett.locale!);
    useCamera = await translator.translate('useCamera', sett.locale!);
    pickFromGallery =
        await translator.translate('pickFromGallery', sett.locale!);
    memberProfilePicture =
        await translator.translate('memberProfilePicture', sett.locale!);
    memberProfileUploaded =
        await translator.translate('memberProfileUploaded', sett.locale!);
    memberProfileUploadFailed =
    await translator.translate('memberProfileUploadFailed', sett.locale!);
    if (mounted) {
      setState(() {});
    }
  }

  void _pickPhotoFromGallery() async {
    pp('$mm photo picking from gallery started ....');
    xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: height,
        maxWidth: width,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear);

    imageFile = File(xFile!.path);
    setState(() {});
  }

  XFile? xFile;
  File? imageFile;
  bool busy = false;

  void _takePhoto() async {
    pp('$mm photo taking started ....');

    xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: height,
        maxWidth: width,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear);

    imageFile = File(xFile!.path);

    setState(() {
      _showNewPhoto = true;
    });
  }

  Future<void> _processFile() async {
    File mImageFile = File(xFile!.path);
    pp('$mm _processFile 🔵🔵🔵 ....... file to upload, '
        'size: ${await mImageFile.length()} bytes🔵');
    setState(() {
      busy = true;
    });
    var thumbnailFile = await getPhotoThumbnail(file: mImageFile);

    final Directory directory = await getApplicationDocumentsDirectory();
    const x = '/photo_';
    final File mFile =
        File('${directory.path}$x${DateTime.now().millisecondsSinceEpoch}.jpg');
    const z = '/photo_thumbnail';
    final File tFile =
        File('${directory.path}$z${DateTime.now().millisecondsSinceEpoch}.jpg');

    await thumbnailFile.copy(tFile.path);
    await mImageFile.copy(mFile.path);

    setState(() {
      finalFile = mFile;
    });

    pp('$mm check file upload names: \n💚 ${mFile.path} length: ${await mFile.length()} '
        '\n💚thumb: ${tFile.path} length: ${await tFile.length()}');

    var size = await mFile.length();
    var m = (size / 1024 / 1024).toStringAsFixed(2);
    pp('$mm Picture taken is $m MB in size');

    var res = await _uploadToCloud(mFile.path, tFile.path);
    if (res == 9) {
      setState(() {
        busy = false;
      });
      if (mounted) {
        showToast(
            context: context,
            message: memberProfileUploadFailed == null?
            'Photo upload failed, please try again in a minute':memberProfileUploadFailed!,
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: myTextStyleMedium(context),
            toastGravity: ToastGravity.TOP,
            duration: const Duration(seconds: 5));
      }
      return;
    }

    pp('\n\n$mm Picture taken has been uploaded OK');
    setState(() {
      _showOldPhoto = false;
      _showNewPhoto = true;
    });

  }


  final photoStorageName = 'geoUserPhotos';
  String? url, thumbUrl;

  Future _uploadToCloud(String filePath, String thumbnailPath) async {
    late UploadTask uploadTask;
    late TaskSnapshot taskSnapshot;
    setState(() {
      busy = true;
    });
    try {
      //upload main file
      var fileName = 'photo@${widget.user.organizationId}@${widget.user.userId}'
          '@${DateTime.now().toUtc().toIso8601String()}.${'jpg'}';
      var firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child(photoStorageName)
          .child(fileName);
      var file = File(filePath);
      pp('$mm️ photo to be uploaded ☕️☕️☕️☕️☕️☕️☕️file path: \n${file.path}');

      uploadTask = firebaseStorageRef.putFile(file);
      taskSnapshot = await uploadTask.whenComplete(() {});
      url = await taskSnapshot.ref.getDownloadURL();
      pp('$mm file url is available, meaning that upload is complete: \n$url');
      _printSnapshot(taskSnapshot, 'PHOTO');
      // upload thumbnail here
      final thumbName =
          'thumbnail@${widget.user.organizationId}@${widget.user.userId}@${DateTime.now().toUtc().toIso8601String()}.${'jpg'}';
      final firebaseStorageRef2 = FirebaseStorage.instance
          .ref()
          .child(photoStorageName)
          .child(thumbName);

      var thumbnailFile = File(thumbnailPath);
      final thumbUploadTask = firebaseStorageRef2.putFile(thumbnailFile);
      final thumbTaskSnapshot = await thumbUploadTask.whenComplete(() {});
      thumbUrl = await thumbTaskSnapshot.ref.getDownloadURL();
      pp('$mm thumbnail file url is available, meaning that upload is complete: \n$thumbUrl');
      _printSnapshot(thumbTaskSnapshot, 'PHOTO THUMBNAIL');
      widget.user.imageUrl = url;
      widget.user.thumbnailUrl = thumbUrl;
      widget.user.updated = DateTime.now().toUtc().toIso8601String();
      await _updateDatabase();
      return 0;
    } catch (e) {
      pp(e);
      if (e is GeoException) {
        errorHandler.handleError(exception: e);
        final msg =
            await translator.translate(e.geTranslationKey(), sett.locale!);
        if (mounted) {
          showToast(
              padding: 16,
              textStyle: myTextStyleMedium(context),
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 5),
              message: msg,
              context: context);
          setState(() {
            busy = false;
          });
        }
      }
    }
  }

  Future _updateDatabase() async {
    pp('\n\n$mm User database entry to be updated: ${widget.user.name}\n');

    try {
      await dataApiDog.updateUser(widget.user);
      var me = await prefsOGx.getUser();
      if (widget.user.userId == me!.userId) {
        await prefsOGx.saveUser(widget.user);
      }
      await cacheManager.addUser(user: widget.user);
      pp('\n\n$mm User photo and thumbnail uploaded and database updated\n');
      if (mounted) {
        showToast(
            padding: 16,
            textStyle: myTextStyleMedium(context),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 3),
            message: memberProfileUploaded!,
            context: context);
      }
    } catch (e) {
      pp(e);
      if (e is GeoException) {
        errorHandler.handleError(exception: e);
        final msg =
            await translator.translate(e.geTranslationKey(), sett.locale!);
        if (mounted) {
          showToast(
              padding: 16,
              textStyle: myTextStyleMedium(context),
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 5),
              message: msg,
              context: context);
        }
      }
    }

    setState(() {
      busy = false;
    });
  }

  void _printSnapshot(TaskSnapshot taskSnapshot, String type) {
    var totalByteCount = taskSnapshot.totalBytes;
    var bytesTransferred = taskSnapshot.bytesTransferred;
    var bt = '${(bytesTransferred / 1024).toStringAsFixed(2)} KB';
    var tot = '${(totalByteCount / 1024).toStringAsFixed(2)} KB';
    pp('$mm uploadTask $type: 💚💚 '
        ' upload complete '
        ' 🧩 $bt of $tot 🧩 transferred.'
        ' date: ${DateTime.now().toIso8601String()}\n');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          memberProfilePicture == null
              ? 'Member Profile Picture'
              : memberProfilePicture!,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 4,
              shape: getRoundedBorder(radius: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '${widget.user.name}',
                          style: myTextStyleMediumBoldPrimaryColor(context),
                        ),
                        imageFile == null
                            ? const SizedBox()
                            : busy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      backgroundColor: Colors.pink,
                                    ),
                                  )
                                : IconButton(
                                    onPressed: _processFile,
                                    icon: Icon(
                                      Icons.check,
                                      size: 36.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Text(
                        profileInstruction == null
                            ? 'Please set up your profile picture. You can use an existing photo or take a new one with the camera'
                            : profileInstruction!,
                        style: myTextStyleSmall(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _showNewPhoto
                        ? SizedBox(
                            width: 320,
                            height: 360,
                            child: Image.file(
                              imageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const SizedBox(),
                    _showOldPhoto
                        ? SizedBox(
                            width: 320,
                            height: 340,
                            child: CachedNetworkImage(
                                imageUrl: widget.user.imageUrl!,
                                fit: BoxFit.cover,
                                fadeInDuration:
                                    const Duration(milliseconds: 500)),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 24,
                    ),
                    busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              backgroundColor: Colors.pink,
                            ),
                          )
                        : SizedBox(
                            height: 240,
                            width: 400,
                            child: Column(
                              children: [
                                TextButton(
                                    onPressed: _takePhoto,
                                    child: Text(
                                      useCamera == null
                                          ? 'Use Camera'
                                          : useCamera!,
                                      style: myTextStyleMedium(context),
                                    )),
                                const SizedBox(
                                  height: 0,
                                ),
                                TextButton(
                                    onPressed: _pickPhotoFromGallery,
                                    child: Text(
                                      pickFromGallery == null
                                          ? 'Pick from Gallery'
                                          : pickFromGallery!,
                                      style: myTextStyleMedium(context),
                                    )),
                                const SizedBox(
                                  height: 0,
                                ),
                                imageFile == null
                                    ? const SizedBox()
                                    : IconButton(
                                        onPressed: _processFile,
                                        icon: Icon(
                                          Icons.check,
                                          size: 36.0,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          imageFile == null
              ? const SizedBox()
              : thumbUrl == null
                  ? const SizedBox()
                  : Positioned(
                      right: 4,
                      top: 100,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(thumbUrl!),
                      ),
                    ),
          busy
              ? const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Colors.pink,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    ));
  }
}
