import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/cloud_storage_bloc.dart';
import 'package:geo_monitor/library/data/project.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:geo_monitor/ui/activity/user_profile_card.dart';
import 'package:geo_monitor/ui/audio/gio_audio_player.dart';
import 'package:geo_monitor/ui/audio/recording_controls.dart';
import 'package:geo_monitor/ui/visualizer/audio_visualizer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import '../../device_location/device_location_bloc.dart';
import '../../l10n/translation_handler.dart';
import '../../library/bloc/audio_for_upload.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/cache_manager.dart';
import '../../library/data/audio.dart';
import '../../library/data/position.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/generic_functions.dart';

class AudioRecorder extends StatefulWidget {
  final void Function() onCloseRequested;

  const AudioRecorder(
      {Key? key, required this.onCloseRequested, required this.project, required this.cloudStorageBloc})
      : super(key: key);
  final Project project;
  final CloudStorageBloc cloudStorageBloc;
  @override
  State<AudioRecorder> createState() => AudioRecorderState();
}

class AudioRecorderState extends State<AudioRecorder> {
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  Amplitude? _amplitude;
  static const mm = '🍐🍐🍐 AudioRecorder 🍐🍐🍐: ';
  User? user;
  SettingsModel? settingsModel;
  @override
  void initState() {
    _recordSub =
        _audioRecorder.onStateChanged().listen((RecordState recordState) {
      pp('$mm onStateChanged; record state: $recordState');
      setState(() => _recordState = recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {
      // pp('$mx onAmplitudeChanged: amp: 🌀🌀 current: ${amp.current} max: ${amp.max}');
      setState(() {
        _amplitude = amp;
      });
    });

    super.initState();
    _listenToSettingsStream();
    _setTexts();
  }

  String? fileUploadSize,
      uploadAudioClipText,
      locationNotAvailable,
      elapsedTime,
      title,
      durationText,
      audioToBeUploaded,
      waitingToRecordAudio;
  int limitInSeconds = 0;
  int fileSize = 0;
  bool showWaveForm = false;

  Future _setTexts() async {
    user = await prefsOGx.getUser();
    settingsModel = await prefsOGx.getSettings();
      var m = settingsModel?.maxAudioLengthInMinutes;
      limitInSeconds = m! * 60;
      title = await translator.translate('recordAudioClip', settingsModel!.locale!);
      elapsedTime = await translator.translate('elapsedTime', settingsModel!.locale!);

      fileUploadSize = await translator.translate('fileSize', settingsModel!.locale!);
      uploadAudioClipText =
          await translator.translate('uploadAudioClip', settingsModel!.locale!);
      locationNotAvailable =
          await translator.translate('locationNotAvailable', settingsModel!.locale!);

      waitingToRecordAudio =
          await translator.translate('waitingToRecordAudio', settingsModel!.locale!);
      audioToBeUploaded =
          await translator.translate('audioToBeUploaded', settingsModel!.locale!);
      durationText = await translator.translate('duration', settingsModel!.locale!);


    setState(() {});
  }

  void _listenToSettingsStream() async {
    settingsSubscriptionFCM = fcmBloc.settingsStream.listen((event) async {
      if (mounted) {
        await _setTexts();
      }
    });
  }

  Future<void> _start() async {
    try {
      setState(() {
        _readyForUpload = false;
        showWaveForm = true;
      });
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        if (kDebugMode) {
          pp('$mm AudioEncoder.aacLc: ${AudioEncoder.aacLc.name} supported: $isSupported');
        }

        var directory = await getApplicationDocumentsDirectory();
        pp('$mm _start: 🔆🔆🔆 directory: ${directory.path}');
        File audioFile = File(
            '${directory.path}/audio${DateTime.now().millisecondsSinceEpoch}.m4a');

        await _audioRecorder.start(path: audioFile.path);
        pp('$mm _audioRecorder has started ...');
        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  File? fileToUpload;
  Future<void> _stop() async {
    _timer?.cancel();

    final path = await _audioRecorder.stop();
    pp('$mm onStop: file path: $path');

    if (path != null) {
      fileToUpload = File(path);
      var length = await fileToUpload?.length();
      pp('$mm onStop: file length: 🍎🍎🍎 $length bytes, ready for upload');
      fileSize = length!;

      setState(() {
        _readyForUpload = true;
        showWaveForm = false;
      });
    }
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    settingsSubscriptionFCM.cancel();
    super.dispose();
  }

  int _seconds = 0;

  void _startTimer() {
    _timer?.cancel();
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _seconds = t.tick;
      setState(() => _recordDuration++);
    });
  }

  bool _readyForUpload = false;

  Future<void> _uploadFile() async {
    pp('\n\n$mm Start file upload .....................');
    setState(() {
      _readyForUpload = false;
    });
    showToast(
        message: audioToBeUploaded == null
            ? 'Audio clip will be uploaded'
            : audioToBeUploaded!,
        context: context,
        textStyle: myTextStyleMediumBold(context),
        padding: 20.0,
        toastGravity: ToastGravity.TOP,
        backgroundColor: Theme.of(context).primaryColor);
    try {
      Position? position;
      final loc = await locationBloc.getLocation();
      if (loc != null) {
        position =
            Position(coordinates: [loc.longitude, loc.latitude], type: 'Point');
      } else {
        if (mounted) {
          showToast(message: 'Device Location unavailable', context: context);
          return;
        }
      }
      pp('$mm about to create audioForUpload ....${fileToUpload!.path} ');
      if (user == null) {
        pp('$mm user is null, WTF!!');
        return;
      }

      final audioForUpload = AudioForUpload(
          fileBytes: null,
          userName: user!.name,
          userThumbnailUrl: user!.thumbnailUrl,
          userId: user!.userId,
          organizationId: user!.organizationId,
          filePath: fileToUpload!.path,
          project: widget.project,
          position: position,
          durationInSeconds: _recordDuration,
          audioId: const Uuid().v4(),
          date: DateTime.now().toUtc().toIso8601String());

      await cacheManager.addAudioForUpload(audio: audioForUpload);
      widget.cloudStorageBloc.uploadEverything();

    } catch (e) {
      pp("something amiss here: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }

    setState(() {
      _readyForUpload = false;
      _seconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_amplitude != null) {
      itemBloc.addItem(_amplitude!.current);
    }
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return ScreenTypeLayout(
      mobile: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title == null ? 'Audio Recording' : title!),
            bottom: PreferredSize(preferredSize: const Size.fromHeight(48), child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Align(
                    child: Text(
                      widget.project.name!,
                      style: myTextStyleMediumWithColor(context, color),
                    ),
                  ),
                ),
                const SizedBox(height: 12,)
              ],
            )),
          ),
          backgroundColor: isDarkMode?Theme.of(context).canvasColor: Colors.brown[50],
          body: durationText == null
              ? const SizedBox()
              : AudioRecorderCard(
                  user: user!,
                  recordState: _recordState,
                  start: _start,
                  stop: _stop,
                  pause: _pause,
                  resume: _resume,
                  showWaveForm: showWaveForm,
                  projectName: widget.project.name!,
                  durationText: durationText!,
                  elapsedTimeText: elapsedTime!,
                  fileUploadSizeText: fileUploadSize!,
                  seconds: _seconds,
                  fileSize: fileSize,
                  readyForUpload: _readyForUpload,
                  uploadFile: _uploadFile,
                  padding: 12,
                  iconSize: 48,
                  uploadAudioClipText: uploadAudioClipText!,
                  close: widget.onCloseRequested,
                ),
        ),
      ),
      tablet: durationText == null
          ? const SizedBox()
          : AudioRecorderCard(
              recordState: _recordState,
              user: user!,
              start: _start,
              stop: _stop,
              pause: _pause,
              resume: _resume,
              close: widget.onCloseRequested,
              showWaveForm: showWaveForm,
              projectName: widget.project.name!,
              durationText: durationText!,
              elapsedTimeText: elapsedTime!,
              fileUploadSizeText: fileUploadSize!,
              seconds: _seconds,
              fileSize: fileSize,
              readyForUpload: _readyForUpload,
              uploadFile: _uploadFile,
              padding: 20,
              iconSize: 48,
              uploadAudioClipText: uploadAudioClipText!),
    );
  }

  Audio? audio;
  Video? video;

}

class AudioRecorderCard extends StatelessWidget {
  const AudioRecorderCard(
      {Key? key,
      required this.recordState,
      required this.start,
      required this.stop,
      required this.pause,
      required this.resume,
      required this.projectName,
      required this.durationText,
      required this.elapsedTimeText,
      required this.fileUploadSizeText,
      required this.seconds,
      required this.fileSize,
      required this.readyForUpload,
      required this.uploadFile,
      required this.uploadAudioClipText,
      this.timerCardHeight,
      required this.padding,
      this.iconSize,
      required this.showWaveForm,
      required this.user,
      required this.close})
      : super(key: key);

  final RecordState recordState;
  final Function start, stop, pause, resume, uploadFile, close;
  final String projectName,
      durationText,
      uploadAudioClipText,
      elapsedTimeText,
      fileUploadSizeText;
  final int seconds, fileSize;
  final bool readyForUpload;
  final double? timerCardHeight, iconSize;
  final double padding;
  final bool showWaveForm;
  final User user;

  Widget _buildPauseResumeControl(BuildContext context) {
    if (recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (recordState == RecordState.record) {
      icon = Icon(Icons.pause,
          color: Theme.of(context).primaryColor,
          size: iconSize == null ? 60 : iconSize!);
      color = Theme.of(context).primaryColor.withOpacity(0.1);
    } else {
      icon = Icon(Icons.play_arrow,
          color: Theme.of(context).primaryColor,
          size: iconSize == null ? 60 : iconSize!);
      color = Theme.of(context).primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(
              width: iconSize == null ? 60 : iconSize!,
              height: iconSize == null ? 60 : iconSize!,
              child: icon),
          onTap: () {
            (recordState == RecordState.pause) ? resume() : pause();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var deviceType = getThisDeviceType();
    late Icon icon;
    late Color color;
    final theme = Theme.of(context);
    if (recordState != RecordState.stop) {
      icon = Icon(Icons.stop, color: theme.primaryColor, size: 30);
      color = theme.primaryColorLight.withOpacity(0.1);
    } else {
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color2 = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color2 = Colors.white;
    }
    return SizedBox(height: 600,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48,),
            Expanded(
              child: Card(
                shape: getRoundedBorder(radius: 16),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 20,
                        ),
                        deviceType == 'phone'
                            ? const SizedBox()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        close();
                                      },
                                      icon:  Icon(Icons.close, size: iconSize!,)),
                                ],
                              ),

                        SizedBox(
                          height: padding,
                        ),
                        UserProfileCard(
                          userName: user.name!,
                          userThumbUrl: user.thumbnailUrl,
                          namePictureHorizontal: true,
                          avatarRadius: 18.0,
                          padding: 8.0,
                          elevation: 4.0,
                        ),
                        SizedBox(
                          height: padding,
                        ),
                        SizedBox(
                          height: timerCardHeight == null ? 120 : timerCardHeight!,
                          child: showWaveForm
                              ? TimerCard(
                                  fontSize: 24,
                                  seconds: seconds,
                                  elapsedTime: elapsedTimeText,
                                )
                              : const SizedBox(),
                        ),
                        SizedBox(
                          height: padding,
                        ),
                        showWaveForm ? SiriCard() : const SizedBox(),
                        showWaveForm
                            ? const SizedBox(
                                height: 24,
                              )
                            : const SizedBox(),
                        Padding(
                          padding: const EdgeInsets.only(left:48.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // _buildRecordStopControl(context),
                              ClipOval(
                                child: Material(
                                  color: color,
                                  child: InkWell(
                                    child: SizedBox(
                                        width: iconSize == null ? 56 : iconSize!,
                                        height: iconSize == null ? 56 : iconSize!,
                                        child: icon),
                                    onTap: () {
                                      (recordState != RecordState.stop) ? stop() : start();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                              _buildPauseResumeControl(context),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        readyForUpload
                            ? Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      fileUploadSizeText,
                                      style: myTextStyleSmall(context),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      ((fileSize / 1024 / 1024)
                                          .toStringAsFixed(2)),
                                      style: myTextStyleMediumBoldPrimaryColor(
                                          context),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'MB',
                                      style: myTextStyleSmall(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    uploadFile();
                                  },
                                  child: SizedBox(
                                    width: 280.0,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          uploadAudioClipText,
                                          style: myTextStyleSmallWithColor(context, color2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                              ],
                            )
                            : const SizedBox(),
                        const SizedBox(height: 20),
                      ],
                    ),
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
