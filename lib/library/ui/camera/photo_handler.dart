import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/library/bloc/geo_uploader.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/media/time_line/project_media_timeline.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import '../../../device_location/device_location_bloc.dart';
import '../../../l10n/translation_handler.dart';
import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/cloud_storage_bloc.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/organization_bloc.dart';
import '../../bloc/photo_for_upload.dart';
import '../../bloc/project_bloc.dart';
import '../../cache_manager.dart';
import '../../data/audio.dart';
import '../../data/position.dart';
import '../../data/project.dart';
import '../../data/project_polygon.dart';
import '../../data/project_position.dart';
import '../../data/user.dart';
import '../../data/video.dart';
import '../../emojis.dart';
import '../../functions.dart';
import '../../generic_functions.dart';

class PhotoHandler extends StatefulWidget {
  const PhotoHandler(
      {Key? key,
      required this.project,
      this.projectPosition,
      required this.projectBloc,
      required this.prefsOGx,
      required this.organizationBloc,
      required this.cacheManager,
      required this.dataApiDog, required this.fcmBloc, required this.geoUploader, required this.cloudStorageBloc})
      : super(key: key);
  final Project project;
  final ProjectPosition? projectPosition;
  final ProjectBloc projectBloc;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final CacheManager cacheManager;
  final DataApiDog dataApiDog;
  final FCMBloc fcmBloc;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;

  @override
  PhotoHandlerState createState() => PhotoHandlerState();
}

class PhotoHandlerState extends State<PhotoHandler>
    with SingleTickerProviderStateMixin {
  final mm =
      '${E.blueDot}${E.blueDot}${E.blueDot}${E.blueDot} PhotoHandler: 🌿';

  late AnimationController _controller;
  final ImagePicker _picker = ImagePicker();
  late StreamSubscription orientStreamSubscription;
  late StreamSubscription<String> killSubscription;

  NativeDeviceOrientation? _deviceOrientation;
  var polygons = <ProjectPolygon>[];
  var positions = <ProjectPosition>[];
  User? user;
  String? fileSavedWillUpload;
  String? totalByteCount, bytesTransferred;
  String? fileUrl, thumbnailUrl, takePicture;
  late SettingsModel sett;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _observeOrientation();
    _getData();
    _startPhoto();
  }

  Future _setTexts() async {
    sett = await widget.prefsOGx.getSettings();
    fileSavedWillUpload =
        await translator.translate('fileSavedWillUpload', sett.locale!);
    takePicture = await translator.translate('takePicture', sett.locale!);
  }

  Future<void> _observeOrientation() async {
    pp('${E.blueDot} ........ _observeOrientation ... ');
    Stream<NativeDeviceOrientation> stream =
        NativeDeviceOrientationCommunicator()
            .onOrientationChanged(useSensor: true);
    orientStreamSubscription = stream.listen((event) {
      // pp('${E.blueDot}${E.blueDot} orientation, name: ${event.name} index: ${event.index}');
      _deviceOrientation = event;
    });
  }

  void _getData() async {
    setState(() {
      busy = true;
    });
    try {
      pp('$mm .......... getting project positions and polygons');
      user = await widget.prefsOGx.getUser();
      polygons = await widget.projectBloc.getProjectPolygons(
          projectId: widget.project.projectId!, forceRefresh: false);
      var map = await getStartEndDates();
      final startDate = map['startDate'];
      final endDate = map['endDate'];
      positions = await widget.projectBloc.getProjectPositions(
          projectId: widget.project.projectId!,
          forceRefresh: false,
          startDate: startDate!,
          endDate: endDate!);
      pp('$mm positions: ${positions.length} polygons: ${polygons.length} found');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }

    setState(() {
      busy = false;
    });
  }

  void _startPhoto() async {
    pp('$mm photo taking started ....');
    var settings = await prefsOGx.getSettings();
    var height = 640.0, width = 480.0;
    switch (settings.photoSize) {
      case 0:
        height = 640;
        width = 480;
        break;
      case 1:
        height = 720;
        width = 1280;
        break;
      case 2:
        height = 1080;
        width = 1920;
        break;
    }
    final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: height,
        maxWidth: width,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear);

    if (file != null) {
      await _processFile(file);
      setState(() {});
    }
    // file.saveTo(path);
  }

  File? finalFile;
  Future<void> _processFile(XFile file) async {
    File mImageFile = File(file.path);
    pp('$mm _processFile 🔵🔵🔵 file to upload, '
        'size: ${await mImageFile.length()} bytes🔵');

    var thumbnailFile = await getPhotoThumbnail(file: mImageFile);
    bool isLandscape = false;
    if (_deviceOrientation != null) {
      switch (_deviceOrientation!.name) {
        case 'landscapeLeft':
          isLandscape = true;
          break;
        case 'landscapeRight':
          isLandscape = true;
          break;
      }
    } else {
      pp('_deviceOrientation is null, wtf?? means that user did not change device orientation ..........');
    }
    pp('$mm ... isLandscape: $isLandscape - check if true!  🍎');
    final Directory directory = await getApplicationDocumentsDirectory();
    const x = '/photo_';
    final File mFile =
        File('${directory.path}$x${DateTime.now().millisecondsSinceEpoch}.jpg');
    const z = '/photo_thumbnail';
    final File tFile =
        File('${directory.path}$z${DateTime.now().millisecondsSinceEpoch}.jpg');
    await thumbnailFile.copy(tFile.path);
    //can i force
    if (_deviceOrientation != null) {
      final finalFile =
          await _processOrientation(mImageFile, _deviceOrientation!);
      await finalFile.copy(mFile.path);
    } else {
      await mImageFile.copy(mFile.path);
    }
    setState(() {
      finalFile = mFile;
    });

    pp('$mm check file upload names: \n💚 ${mFile.path} length: ${await mFile.length()} '
        '\n💚thumb: ${tFile.path} length: ${await tFile.length()}');

    final loc = await locationBloc.getLocation();
    if (loc != null) {
      final position =
          Position(type: 'Point', coordinates: [loc.longitude, loc.latitude]);
      // var bytes = await mFile.readAsBytes();
      // var tBytes = await tFile.readAsBytes();
      final photoForUpload = PhotoForUpload(
          userThumbnailUrl: user!.thumbnailUrl,
          userName: user!.name,
          organizationId: user!.organizationId,
          filePath: mFile.path,
          thumbnailPath: tFile.path,
          fileBytes: null,
          thumbnailBytes: null,
          project: widget.project,
          position: position,
          photoId: const Uuid().v4(),
          date: DateTime.now().toUtc().toIso8601String(),
          userId: user!.userId!);

      await cacheManager.addPhotoForUpload(photo: photoForUpload);
      widget.cloudStorageBloc.uploadEverything();
    }

    var size = await mFile.length();
    var m = (size / 1024 / 1024).toStringAsFixed(2);
    pp('$mm Picture taken is $m MB in size');
    if (mounted) {
      showToast(
          context: context,
          message: fileSavedWillUpload == null
              ? 'Picture file saved on device, size: $m MB'
              : fileSavedWillUpload!,
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: Styles.whiteSmall,
          toastGravity: ToastGravity.TOP,
          duration: const Duration(seconds: 2));
    }
  }

  void _startNextPhoto() {
    pp('$mm _startNextPhoto');
    _startPhoto();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<File> _processOrientation(
      File file, NativeDeviceOrientation deviceOrientation) async {
    pp('$mm _processOrientation: attempt to rotate image file ...');
    switch (deviceOrientation.name) {
      case 'landscapeLeft':
        pp('$mm landscapeLeft ....');
        break;
      case 'landscapeRight':
        pp('$mm landscapeRight ....');
        break;
      case 'portraitUp':
        return file;
      case 'portraitDown':
        return file;
    }
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    final File mFile = File(
        '${appDocumentDirectory.path}/rotatedImageFile${DateTime.now().millisecondsSinceEpoch}.jpg');

    final img.Image? capturedImage = img.decodeImage(await file.readAsBytes());
    var orientedImage = img.copyRotate(capturedImage!, angle: 270);

    await File(mFile.path).writeAsBytes(img.encodeJpg(orientedImage));

    final heightOrig = capturedImage.height;
    final widthOrig = capturedImage.width;

    final height = orientedImage.height;
    final width = orientedImage.width;

    pp('$mm _processOrientation: rotated file has 😡height: $height 😡width: $width, 🔵 '
        'original file size: height: $heightOrig width: $widthOrig');
    return mFile;
  }

  void _navigateTimeline() {
    Navigator.of(context).pop();
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(milliseconds: 1500),
            child: ProjectMediaTimeline(
              project: widget.project,
              projectBloc: widget.projectBloc,
              organizationBloc: widget.organizationBloc,
              prefsOGx: widget.prefsOGx,
              cacheManager: widget.cacheManager,
              cloudStorageBloc: widget.cloudStorageBloc,
              dataApiDog: widget.dataApiDog, fcmBloc: widget.fcmBloc, geoUploader: widget.geoUploader,
            )));
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: Text(
            '${widget.project.name}',
            style: myTextStyleMediumWithColor(context, color),
          ),
          // actions: [
          //   IconButton(
          //       onPressed: _navigateTimeline,
          //       icon: Icon(
          //         Icons.list,
          //         color: Theme.of(context).primaryColor,
          //       )),
          // ],
        ),
        body: Stack(
          children: [
            finalFile == null
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/intro/pic2.jpg'),
                          opacity: 0.1,
                          fit: BoxFit.cover),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(finalFile!), fit: BoxFit.cover),
                    ),
                  ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 20,
              child: SizedBox(
                width: 240,
                height: 80,
                child: Card(
                  elevation: 4,
                  color: Colors.black38,
                  shape: getRoundedBorder(radius: 16),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      TextButton(
                          onPressed: _startNextPhoto,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(takePicture == null
                                ? 'Take Picture'
                                : takePicture!, style: myTextStyleMediumWithColor(context, color),),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
