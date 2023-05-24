import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/settings/settings_form.dart';

import '../../../l10n/translation_handler.dart';
import '../../api/prefs_og.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/theme_bloc.dart';
import '../../data/project.dart';
import '../../data/user.dart';
import '../../functions.dart';

class SettingsFormMonitor extends StatefulWidget {
  const SettingsFormMonitor(
      {Key? key, required this.padding, required this.onLocaleChanged})
      : super(key: key);
  final double padding;
  final Function(String locale) onLocaleChanged;

  @override
  State<SettingsFormMonitor> createState() => SettingsFormMonitorState();
}

class SettingsFormMonitorState extends State<SettingsFormMonitor> {
  final _formKey = GlobalKey<FormState>();
  final mm = '🥨🥨🥨🥨🥨 SettingsFormMonitor: ';
  User? user;
  var orgSettings = <SettingsModel>[];
  Project? selectedProject;
  SettingsModel? settingsModel;
  SettingsModel? oldSettingsModel;
  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;
  int photoSize = 0;
  int currentThemeIndex = 0;
  int groupValue = 0;
  bool busy = false;
  bool busyWritingToDB = false;
  String? currentLocale;
  Locale? selectedLocale;
  String? selectSizePhotos, settingsChanged;
  bool showColorPicker = false;

  @override
  void initState() {
    super.initState();
    _listenToFCM();
    _getSettings();
  }

  void _listenToFCM() async {
    settingsSubscriptionFCM =
        fcmBloc.settingsStream.listen((SettingsModel event) async {
      if (mounted) {
        await _getSettings();
      }
    });
  }

  Future _getSettings() async {
    pp('$mm 🍎🍎 ............. getting user from prefs ...');
    user = await prefsOGx.getUser();
    settingsModel = await prefsOGx.getSettings();
      currentLocale = settingsModel!.locale!;

    _setExistingSettings();
    _setTexts();
  }

  String? fieldMonitorInstruction,
      maximumMonitoringDistance,
      maximumVideoLength,
      maximumAudioLength,
      activityStreamHours,
      numberOfDays,
      pleaseSelectCountry,
      tapForColorScheme,
      settings,
      small,
      medium,
      large,
      maxVideoLessThan,
      maxAudioLessThan,
      numberOfDaysForDashboardData,
      selectLanguage,
      title,
      hint;

  Future _setTexts() async {
    title = await translator.translate('settings', settingsModel!.locale!);
    maxVideoLessThan =
        await translator.translate('maxVideoLessThan', settingsModel!.locale!);
    maxAudioLessThan =
        await translator.translate('maxAudioLessThan', settingsModel!.locale!);
    fieldMonitorInstruction =
        await translator.translate('fieldMonitorInstruction', settingsModel!.locale!);
    maximumMonitoringDistance = await translator.translate(
        'maximumMonitoringDistance', settingsModel!.locale!);
    numberOfDaysForDashboardData = await translator.translate(
        'numberOfDaysForDashboardData', settingsModel!.locale!);
    maximumVideoLength =
        await translator.translate('maximumVideoLength', settingsModel!.locale!);
    maximumAudioLength =
        await translator.translate('maximumAudioLength', settingsModel!.locale!);
    activityStreamHours =
        await translator.translate('activityStreamHours', settingsModel!.locale!);
    selectSizePhotos =
        await translator.translate('selectSizePhotos', settingsModel!.locale!);
    pleaseSelectCountry =
        await translator.translate('pleaseSelectCountry', settingsModel!.locale!);
    tapForColorScheme =
        await translator.translate('tapForColorScheme', settingsModel!.locale!);
    numberOfDays = await translator.translate('numberOfDays', settingsModel!.locale!);
    settings = await translator.translate('settings', settingsModel!.locale!);
    small = await translator.translate('small', settingsModel!.locale!);
    medium = await translator.translate('medium', settingsModel!.locale!);
    large = await translator.translate('large', settingsModel!.locale!);
    selectLanguage =
        await translator.translate('selectLanguage', settingsModel!.locale!);
    hint = await translator.translate('selectLanguage', settingsModel!.locale!);
    settingsChanged =
        await translator.translate('settingsChanged', settingsModel!.locale!);

    translatedLanguage =
        await translator.translate(settingsModel!.locale!, settingsModel!.locale!);

    setState(() {});
  }

  void onSelected(Project p1) {
    setState(() {
      selectedProject = p1;
    });
  }

  void _setExistingSettings() async {
    if (settingsModel != null) {
      if (settingsModel!.activityStreamHours == null ||
          settingsModel!.activityStreamHours == 0) {
        settingsModel!.activityStreamHours = 24;
        await prefsOGx.saveSettings(settingsModel!);
      }
    }
    settingsModel ??= getBaseSettings();
    settingsModel!.organizationId = user!.organizationId;

    currentThemeIndex = settingsModel!.themeIndex!;
    if (settingsModel?.locale != null) {
      Locale newLocale = Locale(settingsModel!.locale!);
      selectedLocale = newLocale;
      final m = LocaleAndTheme(
          themeIndex: settingsModel!.themeIndex!, locale: newLocale);
      themeBloc.changeToLocale(m.locale.toString());
    }

    if (settingsModel?.photoSize == 0) {
      photoSize = 0;
      groupValue = 0;
    }
    if (settingsModel?.photoSize == 1) {
      photoSize = 1;
      groupValue = 1;
    }
    if (settingsModel?.photoSize == 2) {
      photoSize = 0;
      groupValue = 2;
    }

    widget.onLocaleChanged(settingsModel!.locale!);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: getRoundedBorder(radius: 16),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(widget.padding),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showColorPicker = true;
                              });
                            },
                            child: Card(
                              elevation: 8,
                              shape: getRoundedBorder(radius: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  height: 48,
                                  width: 240,
                                  child: Container(
                                    color: Theme.of(context).primaryColor,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          tapForColorScheme == null
                                              ? 'Tap Me for Colour Scheme'
                                              : tapForColorScheme!,
                                          style: myTextStyleSmallWithColor(context, color),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          busyWritingToDB
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    backgroundColor: Colors.pink,
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 48,
                      ),
                      Text(
                        fieldMonitorInstruction == null
                            ? 'instruction'
                            : fieldMonitorInstruction!,
                        style: myTextStyleSmall(context),
                      ),
                      const SizedBox(
                        height: 48,
                      ),
                      SizedBox(
                        width: 400,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            LocaleChooser(
                              onSelected: (locale, language) {
                                _handleLocaleChange(locale, language);
                              },
                              hint: hint == null ? 'Select Language' : hint!, color: color,
                            ),
                            const SizedBox(
                              width: 32,
                            ),
                            translatedLanguage == null
                                ? const Text('No language')
                                : Text(
                              translatedLanguage!,
                              style: myTextStyleMediumBoldPrimaryColor(
                                  context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(
                                settingsModel == null
                                    ? '0'
                                    : '${settingsModel!.distanceFromProject!}',
                                style: myNumberStyleMediumPrimaryColor(context),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                maximumMonitoringDistance == null
                                    ? ''
                                    : maximumMonitoringDistance!,
                                style: myTextStyleSmall(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(
                                settingsModel == null
                                    ? '0'
                                    : '${settingsModel!.maxVideoLengthInSeconds!}',
                                style: myNumberStyleMediumPrimaryColor(context),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                maximumVideoLength == null
                                    ? ''
                                    : maximumVideoLength!,
                                style: myTextStyleSmall(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(
                                settingsModel == null
                                    ? '0'
                                    : '${settingsModel!.maxAudioLengthInMinutes!}',
                                style: myNumberStyleMediumPrimaryColor(context),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                maximumAudioLength == null
                                    ? ''
                                    : maximumAudioLength!,
                                style: myTextStyleSmall(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(
                                settingsModel == null
                                    ? '0'
                                    : '${settingsModel!.activityStreamHours!}',
                                style: myNumberStyleMediumPrimaryColor(context),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                activityStreamHours == null
                                    ? ''
                                    : activityStreamHours!,
                                style: myTextStyleSmall(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(
                                settingsModel == null
                                    ? '0'
                                    : '${settingsModel!.numberOfDays!}',
                                style: myNumberStyleMediumPrimaryColor(context),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                numberOfDaysForDashboardData == null
                                    ? ''
                                    : numberOfDaysForDashboardData!,
                                style: myTextStyleSmall(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        showColorPicker
            ? Positioned(
                top: 20,
                left: 12,
                right: 12,
                child: SizedBox(
                  height: 300,
                  child: ColorSchemePicker(
                    onColorScheme: (index) async {
                      currentThemeIndex = index;
                      themeBloc.changeToTheme(currentThemeIndex);
                      if (settingsModel != null) {
                        settingsModel!.themeIndex = currentThemeIndex;
                        final msg =
                            await translator.translate('messageFromGeo', settingsModel!.locale!);
                        final msg2 =
                        await translator.translate('settingsArrived', settingsModel!.locale!);
                        final messageFromGeo = msg.replaceAll('\$geo', 'Gio');
                        settingsModel!.translatedTitle = messageFromGeo;
                        settingsModel!.translatedMessage = msg2;
                        prefsOGx.saveSettings(settingsModel!);
                      }
                      setState(() {
                        showColorPicker = false;
                      });
                    },
                    crossAxisCount: 6,
                    itemWidth: 28,
                    elevation: 16,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  String? translatedLanguage;

  void _handleLocaleChange(Locale locale, String translatedLanguage) async {
    pp('$mm onLocaleChange ... going to ${locale.languageCode} : $translatedLanguage');

    settingsModel = await prefsOGx.getSettings();

      settingsModel!.locale = locale.languageCode;
      await prefsOGx.saveSettings(settingsModel!);
      await translator.translate('settings', settingsModel!.locale!);
      fcmBloc.settingsStreamController.sink.add(settingsModel!);
      themeBloc.changeToLocale(locale.languageCode);

    setState(() {
      selectedLocale = locale;
      this.translatedLanguage = translatedLanguage;
    });
    _setTexts();

    widget.onLocaleChanged(locale.languageCode);
  }
}
