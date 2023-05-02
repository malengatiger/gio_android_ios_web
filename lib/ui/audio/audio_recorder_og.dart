import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/cloud_storage_bloc.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/project.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:geo_monitor/ui/activity/user_profile_card.dart';
import 'package:geo_monitor/ui/audio/audio_player_og.dart';
import 'package:geo_monitor/ui/audio/recording_controls.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import '../../device_location/device_location_bloc.dart';
import '../../l10n/translation_handler.dart';
import '../../library/bloc/audio_for_upload.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/cache_manager.dart';
import '../../library/data/audio.dart';
import '../../library/data/position.dart';
import '../../library/data/user.dart';
import '../../library/data/video.dart';
import '../../library/generic_functions.dart';

class AudioRecorderOG extends StatefulWidget {
  final void Function() onCloseRequested;

  const AudioRecorderOG(
      {Key? key, required this.onCloseRequested, this.project})
      : super(key: key);
  final Project? project;
  @override
  State<AudioRecorderOG> createState() => AudioRecorderOGState();
}

class AudioRecorderOGState extends State<AudioRecorderOG>
    implements StorageBlocListener {
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  final RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  Amplitude? _amplitude;
  static const mm = '🍐🍐🍐 AudioRecorderOG 🍐🍐🍐: ';
  User? user;
  SettingsModel? settingsModel;
  Project? project;
  bool loading = false;
  @override
  void initState() {
    // _recordSub =
    //     _audioRecorder.onStateChanged().listen((RecordState recordState) {
    //   pp('$mm onStateChanged; record state: $recordState');
    //   setState(() => _recordState = recordState);
    // });
    //
    // _amplitudeSub = _audioRecorder
    //     .onAmplitudeChanged(const Duration(milliseconds: 300))
    //     .listen((amp) {
    //   // pp('$mx onAmplitudeChanged: amp: 🌀🌀 current: ${amp.current} max: ${amp.max}');
    //   setState(() {
    //     _amplitude = amp;
    //   });
    // });

    super.initState();
    _listenToSettingsStream();
    _setTexts();
    _getProject();
    _setRecorderController();
    _setPlayer();
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

  void _getProject() async {
    if (widget.project != null) {
      project = widget.project;
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      user = await prefsOGx.getUser();
      var projects = await organizationBloc.getOrganizationProjects(
          organizationId: user!.organizationId!, forceRefresh: false);
      for (var proj in projects) {
        if (proj.name!.contains('Real')) {
          project = proj;
          break;
        }
      }
    } catch (e) {
      showToast(message: '$e', context: context);
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  final RecorderController _recorderController = RecorderController();
  final PlayerController _playerController = PlayerController();
  String? filePath;

  Future<void> _setRecorderController() async {
    // Check mic permission (also called during record)
    final hasPermission = await _recorderController.checkPermission();
    if (!hasPermission) {
      _noPermission();
    }

    _recorderController.updateFrequency =
        const Duration(milliseconds: 100); // Update speed of new wave
    _recorderController.androidEncoder =
        AndroidEncoder.aac; // Changing android encoder
    _recorderController.androidOutputFormat =
        AndroidOutputFormat.mpeg4; // Changing android output format
    _recorderController.iosEncoder =
        IosEncoder.kAudioFormatMPEG4AAC; // Changing ios encoder
    _recorderController.sampleRate = 44100; // Updating sample rate
    _recorderController.bitRate = 48000; // Updating bitrate
    _recorderController.onRecorderStateChanged
        .listen((state) {
          pp('$mm onRecorderStateChanged : $state');
    }); // Listening to recorder state changes
    _recorderController.onCurrentDuration
        .listen((duration) {
      pp('$mm onCurrentDuration: $duration');
    }); // Listening to current duration updates
    _recorderController.onRecordingEnded
        .listen((duration) {
      pp('$mm onRecordingEnded: $duration');
    }); // Listening to audio file duration
    _recorderController.recordedDuration; // Get recorded audio duration
    _recorderController
        .currentScrolledDuration; // Current duration position notifier

    _recorderController.refresh(); // Refresh waveform to original position
  }

  Future _setPlayer() async {
    _playerController.onPlayerStateChanged
        .listen((state) {
      pp('$mm onPlayerStateChanged: $state');
    }); // Listening to player state changes
    _playerController.onCurrentDurationChanged
        .listen((duration) {
      pp('$mm onCurrentDurationChanged: $duration');
    }); // Listening to current duration changes
    _playerController.onCurrentExtractedWaveformData
        .listen((data) {
      pp('$mm onCurrentExtractedWaveformData ... ');
    }); // Listening to latest extraction data
    _playerController.onExtractionProgress
        .listen((progress) {
      pp('$mm onExtractionProgress: $progress');
    }); // Listening to extraction progress
    _playerController.onCompletion.listen((_) {
      pp('$mm onCompletion ...');
    }); // Listening to audio completion
  }

  Future<void> _pausePlayer() async {
    await _playerController.pausePlayer(); // Pause audio player
  }
  Future<void> _stopPlayer() async {
    await _playerController.stopPlayer(); // Stop audio player

  }
  Future<void> _seekPlayer() async {
    await _playerController.seekTo(5000); // Seek audio
  }
  int playerDuration = 0;
  void _playerStuff() async {
// Extract waveform data
    final waveformData = await _playerController.extractWaveformData(
      path: filePath!,
      noOfSamples: 100,
    );
// Or directly extract from preparePlayer and initialise audio player
    await _playerController.preparePlayer(
      path: filePath!,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    await _playerController.startPlayer(
        finishMode: FinishMode.stop); // Start audio player

    await _playerController.setVolume(1.0); // Set volume level

    playerDuration = await _playerController
        .getDuration(DurationType.max); // Get duration of audio player
    _playerController.updateFrequency =
        UpdateFrequency.low; // Update reporting rate of current duration.

    _playerController.stopAllPlayers(); // Stop all registered audio players
    _playerController.dispose(); // Dispose _playerController
  }

  Future _setTexts() async {
    user = await prefsOGx.getUser();
    settingsModel = await prefsOGx.getSettings();
    var m = settingsModel?.maxAudioLengthInMinutes;
    limitInSeconds = m! * 60;
    title =
        await translator.translate('recordAudioClip', settingsModel!.locale!);
    elapsedTime =
        await translator.translate('elapsedTime', settingsModel!.locale!);

    fileUploadSize =
        await translator.translate('fileSize', settingsModel!.locale!);
    uploadAudioClipText =
        await translator.translate('uploadAudioClip', settingsModel!.locale!);
    locationNotAvailable = await translator.translate(
        'locationNotAvailable', settingsModel!.locale!);

    waitingToRecordAudio = await translator.translate(
        'waitingToRecordAudio', settingsModel!.locale!);
    audioToBeUploaded =
        await translator.translate('audioToBeUploaded', settingsModel!.locale!);
    durationText =
        await translator.translate('duration', settingsModel!.locale!);

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
      final perm = _recorderController.hasPermission;
      if (perm) {
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

        await _recorderController.record(path: audioFile.path);
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

    final path = await _recorderController.stop();
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
    await _recorderController.pause();
  }

  Future<void> _resume() async {
    _startTimer();
    //await _recorderController.re();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorderController.dispose();
    _playerController.dispose();
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
      var loc = await locationBloc.getLocation();
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

      var audioForUpload = AudioForUpload(
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
      const secs = 4 * 60;
      if (_recordDuration < secs) {
        geoUploader.manageMediaUploads();
      } else {
        cloudStorageBloc.uploadAudio(
            listener: this, audioForUpload: audioForUpload);
      }
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
  Audio? audio;
  @override
  onAudioReady(Audio audio) {
    pp('$mm audio is ready : ${audio.toJson()}');
    this.audio = audio;
    setState(() {});
  }

  @override
  onError(String message) {
    pp('$mm message');
  }

  @override
  onFileProgress(int totalByteCount, int bytesTransferred) {
    pp('$mm bytesTransferred $bytesTransferred of $totalByteCount bytes');
  }

  @override
  onFileUploadComplete(String url, int totalByteCount, int bytesTransferred) {
    pp('$mm onFileUploadComplete, bytesTransferred: $bytesTransferred');
    pp('$mm url: $url');
  }

  Video? video;
  @override
  onVideoReady(Video video) {
    pp('$mm video is ready ');
    setState(() {
      this.video = video;
    });
  }

  void _noPermission() {}

  @override
  Widget build(BuildContext context) {
    // if (_amplitude != null) {
    //   itemBloc.addItem(_amplitude!.current);
    // }
    return ScreenTypeLayout(
      mobile: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title == null ? 'Audio Recording' : title!),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: durationText == null
                ? const SizedBox()
                : AudioFileWaveforms(
                    size: Size(MediaQuery.of(context).size.width, 100.0),
                    playerController: _playerController,
                    enableSeekGesture: true,
                    waveformType: WaveformType.long,
                    waveformData: [],
                    playerWaveStyle: const PlayerWaveStyle(
                      fixedWaveColor: Colors.white54,
                      liveWaveColor: Colors.blueAccent,
                      spacing: 6,
                    ),
                  ),
          ),
        ),
      ),
      tablet: durationText == null
          ? const SizedBox()
          : AudioFileWaveforms(
              size: Size(MediaQuery.of(context).size.width, 100.0),
              playerController: _playerController,
              enableSeekGesture: true,
              waveformType: WaveformType.long,
              waveformData: [],
              playerWaveStyle: const PlayerWaveStyle(
                fixedWaveColor: Colors.white54,
                liveWaveColor: Colors.blueAccent,
                spacing: 6,
              ),
            ),
    );
  }

  
}

class AudioRecorderOGCard extends StatelessWidget {
  const AudioRecorderOGCard(
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

  Widget _buildRecordStopControl(BuildContext context) {
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

    return ClipOval(
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
    );
  }

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
    return Card(
      shape: getRoundedBorder(radius: 16),
      elevation: 8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                      deviceType == 'phone'
                          ? const SizedBox()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      close();
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: iconSize!,
                                    )),
                              ],
                            ),
                      Text(
                        projectName,
                        style: myTextStyleLargePrimaryColor(context),
                      ),
                      SizedBox(
                        height: padding,
                      ),
                      UserProfileCard(
                        userName: user.name!,
                        userThumbUrl: user.thumbnailUrl,
                        namePictureHorizontal: false,
                        avatarRadius: 24.0,
                        padding: 8.0,
                        elevation: 4.0,
                      ),
                      SizedBox(
                        height: padding,
                      ),
                      SizedBox(
                        height:
                            timerCardHeight == null ? 120 : timerCardHeight!,
                        child: showWaveForm
                            ? TimerCard(
                                fontSize: 28,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRecordStopControl(context),
                          const SizedBox(width: 48),
                          _buildPauseResumeControl(context),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      readyForUpload
                          ? Card(
                              elevation: 2,
                              shape: getRoundedBorder(radius: 16),
                              child: Column(
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
                                        style:
                                            myTextStyleMediumBoldPrimaryColor(
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
                                      width: 240.0,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            uploadAudioClipText,
                                            style:
                                                myTextStyleSmallBold(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
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
    );
  }
}
