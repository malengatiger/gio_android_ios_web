import 'dart:async';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/translation_handler.dart';
import '../../api/prefs_og.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/theme_bloc.dart';
import '../../cache_manager.dart';
import '../../data/project.dart';
import '../../data/user.dart';
import '../../functions.dart';
import '../../generic_functions.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm(
      {Key? key,
      required this.padding,
      required this.onLocaleChanged,
      required this.dataApiDog, required this.prefsOGx, required this.organizationBloc, required this.dataHandler})
      : super(key: key);
  final double padding;
  final Function(String locale) onLocaleChanged;
  final DataApiDog dataApiDog;
  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  final IsolateDataHandler dataHandler;
  @override
  State<SettingsForm> createState() => SettingsFormState();
}

class SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final mm = '🥨🥨🥨🥨🥨 SettingsForm: ';
  User? user;
  var orgSettings = <SettingsModel>[];
  Project? selectedProject;
  SettingsModel? settingsModel;
  SettingsModel? oldSettingsModel;

  var distController = TextEditingController(text: '500');
  var videoController = TextEditingController(text: '120');
  var audioController = TextEditingController(text: '20');
  var activityController = TextEditingController(text: '24');
  var daysController = TextEditingController(text: '14');

  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  int photoSize = 0;
  int currentThemeIndex = 0;
  int groupValue = 0;
  bool busy = false;
  bool busyWritingToDB = false;

  String? currentLocale;

  @override
  void initState() {
    super.initState();
    _setTexts();
    _listenToFCM();
    _getUser();
  }

  void _getUser() async {
    pp('$mm 🍎🍎 ............. getting user from prefs ...');
    user = await prefsOGx.getUser();
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
      maxAudioLessThan,
      maxVideoLessThan,
      numberOfDaysForDashboardData,
      selectLanguage,
      hint;

  Future _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
    oldSettingsModel = await prefsOGx.getSettings();
    currentLocale = settingsModel!.locale!;

    pp('$mm 🍎🍎 user is here, huh? 🌎 ${user!.name!}');
    _setExistingSettings();
    final m1 =
        await translator.translate('maxVideoLessThan', settingsModel!.locale!);
    maxVideoLessThan = m1.replaceAll('\$count', '120');

    final m2 =
        await translator.translate('maxAudioLessThan', settingsModel!.locale!);
    maxAudioLessThan = m2.replaceAll('\$count', '30');
    fieldMonitorInstruction = await translator.translate(
        'fieldMonitorInstruction', settingsModel!.locale!);
    maximumMonitoringDistance = await translator.translate(
        'maximumMonitoringDistance', settingsModel!.locale!);
    numberOfDaysForDashboardData = await translator.translate(
        'numberOfDaysForDashboardData', settingsModel!.locale!);
    maximumVideoLength = await translator.translate(
        'maximumVideoLength', settingsModel!.locale!);
    maximumAudioLength = await translator.translate(
        'maximumAudioLength', settingsModel!.locale!);
    activityStreamHours = await translator.translate(
        'activityStreamHours', settingsModel!.locale!);
    selectSizePhotos =
        await translator.translate('selectSizePhotos', settingsModel!.locale!);
    pleaseSelectCountry = await translator.translate(
        'pleaseSelectCountry', settingsModel!.locale!);
    tapForColorScheme =
        await translator.translate('tapForColorScheme', settingsModel!.locale!);
    numberOfDays =
        await translator.translate('numberOfDays', settingsModel!.locale!);
    settings = await translator.translate('settings', settingsModel!.locale!);
    small = await translator.translate('small', settingsModel!.locale!);
    medium = await translator.translate('medium', settingsModel!.locale!);
    large = await translator.translate('large', settingsModel!.locale!);
    selectLanguage =
        await translator.translate('selectLanguage', settingsModel!.locale!);
    hint = await translator.translate('selectLanguage', settingsModel!.locale!);
    settingsChanged =
        await translator.translate('settingsChanged', settingsModel!.locale!);

    translatedLanguage = await translator.translate(
        settingsModel!.locale!, settingsModel!.locale!);

    setState(() {});
  }

  void _listenToFCM() async {
    pp('$mm ... _listenToFCM settingsSubscriptionFCM ...');

    settingsSubscriptionFCM =
        fcmBloc.settingsStream.listen((SettingsModel event) async {
      if (mounted) {
        await _setTexts();
      }
    });
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
    settingsModel!.organizationId = user!.organizationId!;

    currentThemeIndex = settingsModel!.themeIndex!;
    distController.text = '${settingsModel?.distanceFromProject}';
    videoController.text = '${settingsModel?.maxVideoLengthInSeconds}';
    audioController.text = '${settingsModel?.maxAudioLengthInMinutes}';
    activityController.text = '${settingsModel?.activityStreamHours}';
    daysController.text = '${settingsModel?.numberOfDays}';

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

    setState(() {});
  }

  void _writeSettingsToDatabase() async {
    if (user == null) {
      pp('\n\n\n\n🌀🌀🌀🌀 user is null, what the fuck?\n');
      return;
    }
    if (_formKey.currentState!.validate()) {
      var date = DateTime.now().toUtc().toIso8601String();
      pp('$mm 🔵🔵🔵 writing settings to remote database ... '
          'currentThemeIndex: $currentThemeIndex 🔆🔆🔆 and date: $date} 🔆 stream hours: ${activityController.value.text}');
      var len = int.parse(videoController.value.text);
      if (len > 120) {
        showToast(
            padding: 16,
            textStyle: myTextStyleMedium(context),
            backgroundColor: Theme.of(context).primaryColor,
            message: maxVideoLessThan == null
                ? 'The maximum video length should be 120 seconds or less'
                : maxVideoLessThan!,
            context: context);
        return;
      }
      var len2 = int.parse(audioController.value.text);
      if (len2 > 30) {
        showToast(
            padding: 16,
            textStyle: myTextStyleMedium(context),
            backgroundColor: Theme.of(context).primaryColor,
            message: maxAudioLessThan == null
                ? 'The maximum audio clip length should be 30 minutes or less'
                : maxAudioLessThan!,
            context: context);
        return;
      }
      if (selectedLocale == null) {
        showToast(
            message: selectLanguage == null
                ? 'Please select language'
                : selectLanguage!,
            context: context);
        return;
      }
      final sett = await cacheManager.getSettings();
      final settingsChanged =
          await translator.translate('settingsChanged', sett!.locale!);
      final messageFromGeo =
          await translator.translate('messageFromGeo', sett!.locale!);

      settingsModel = SettingsModel(
        locale: selectedLocale.toString(),
        distanceFromProject: int.parse(distController.value.text),
        photoSize: groupValue,
        translatedMessage: settingsChanged,
        translatedTitle: messageFromGeo,
        maxVideoLengthInSeconds: int.parse(videoController.value.text),
        maxAudioLengthInMinutes: int.parse(audioController.value.text),
        numberOfDays: int.parse(daysController.value.text),
        themeIndex: currentThemeIndex,
        settingsId: const Uuid().v4(),
        created: date,
        organizationId: user!.organizationId,
        projectId: selectedProject == null ? null : selectedProject!.projectId,
        activityStreamHours: int.parse(activityController.value.text),
      );

      pp('🌸 🌸 🌸 🌸 🌸 ... about to save settings: ${settingsModel!.toJson()}');

      await prefsOGx.saveSettings(settingsModel!);
      Locale newLocale = Locale(settingsModel!.locale!);
      final m = LocaleAndTheme(
          themeIndex: settingsModel!.themeIndex!, locale: newLocale);
      themeBloc.themeStreamController.sink.add(m);

      await cacheManager.addSettings(settings: settingsModel!);
      await _sendSettings();
    }
    if (mounted) {
      showToast(
          backgroundColor: Theme.of(context).primaryColor,
          message: settingsChanged == null
              ? 'Settings have been saved'
              : settingsChanged!,
          context: context);
    }
  }

  Future _sendSettings() async {
    pp('\n\n$mm sendSettings: 🔵🔵🔵 settings sent to database: ${settingsModel!.toJson()}');
    setState(() {
      busyWritingToDB = true;
    });
    try {
      var s = await widget.dataApiDog.addSettings(settingsModel!);
      pp('\n\n🔵🔵🔵 settings sent to database: ${s.toJson()}');

      await widget.prefsOGx.saveSettings(s);
      widget.organizationBloc.settingsController.sink.add(s);
      themeBloc.changeToTheme(s.themeIndex!);
      await widget.dataHandler.getOrganizationData();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            duration: const Duration(seconds: 10),
            message: '$e',
            backgroundColor: Theme.of(context).primaryColorDark,
            context: context);
      }
    }

    setState(() {
      busyWritingToDB = false;
    });
  }

  void _handlePhotoSizeValueChange(Object? value) {
    pp('🌸 🌸 🌸 🌸 🌸 _handlePhotoSizeValueChange: 🌸 $value');
    groupValue = value as int;
    setState(() {
      switch (value) {
        case 0:
          photoSize = 0;
          break;
        case 1:
          photoSize = 1;
          break;
        case 2:
          photoSize = 2;
          break;
      }
    });
  }

  Locale? selectedLocale;
  String? selectSizePhotos, settingsChanged;
  bool showColorPicker = false;

  @override
  Widget build(BuildContext context) {
    // final  color = getTextColorForBackground(Theme.of(context).primaryColor);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Colors.white;
    }
    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: getRoundedBorder(radius: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(widget.padding),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              pp('$mm tapped color picker button ... set showColorPicker to true');
                              setState(() {
                                showColorPicker = true;
                              });
                            },
                            child: Card(
                              elevation: 8,
                              shape: getRoundedBorder(radius: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 48,
                                  width: 220,
                                  child: Container(
                                    color: Theme.of(context).primaryColor,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          tapForColorScheme == null
                                              ? 'Tap Me for Colour Scheme'
                                              : tapForColorScheme!,
                                          style: TextStyle(
                                            color: color,
                                          ),
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
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    backgroundColor: Colors.pink,
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(
                            width: 2,
                          ),
                          IconButton(
                              onPressed: () {
                                _writeSettingsToDatabase();
                              },
                              icon: Icon(
                                Icons.check,
                                size: 28,
                                color: Theme.of(context).primaryColor,
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Card(
                        shape: getRoundedBorder(radius: 12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            fieldMonitorInstruction == null
                                ? 'instruction'
                                : fieldMonitorInstruction!,
                            style: myTextStyleSmall(context),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
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
                        height: 24,
                      ),
                      SizedBox(
                        width: 400,
                        child: TextFormField(
                          controller: distController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return maximumMonitoringDistance == null
                                  ? 'Please enter maximum distance from project in metres'
                                  : maximumMonitoringDistance!;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: maximumMonitoringDistance == null
                                ? 'Enter maximum distance from project in metres'
                                : maximumMonitoringDistance!,
                            label: Text(
                              maximumMonitoringDistance == null
                                  ? 'sentence'
                                  : maximumMonitoringDistance!,
                              style: myTextStyleSmall(context),
                            ),
                            hintStyle: myTextStyleSmall(context),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 400,
                        child: TextFormField(
                          controller: videoController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return maximumVideoLength == null
                                  ? 'Please enter maximum video length in seconds'
                                  : maximumVideoLength!;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: maximumVideoLength == null
                                ? 'Enter maximum video length in seconds'
                                : maximumVideoLength!,
                            label: Text(
                              maximumVideoLength == null
                                  ? 'Maximum Video Length in Seconds'
                                  : maximumVideoLength!,
                              style: myTextStyleSmall(context),
                            ),
                            hintStyle: myTextStyleSmall(context),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 400,
                        child: TextFormField(
                          controller: audioController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return maximumAudioLength == null
                                  ? 'Please enter maximum audio length in minutes'
                                  : maximumVideoLength!;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: maximumAudioLength == null
                                ? 'Enter maximum audio length in minutes'
                                : maximumAudioLength!,
                            label: Text(
                              maximumAudioLength == null
                                  ? 'Maximum Audio Length in Minutes'
                                  : maximumAudioLength!,
                              style: myTextStyleSmall(context),
                            ),
                            hintStyle: myTextStyleSmall(context),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 400,
                        child: TextFormField(
                          controller: activityController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return activityStreamHours == null
                                  ? 'Please enter the number of hours your activity stream must show'
                                  : activityStreamHours!;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: activityStreamHours == null
                                ? 'Enter activity stream length in hours'
                                : activityStreamHours!,
                            label: Text(
                              activityStreamHours == null
                                  ? 'Activity Stream Audio Length in Hours'
                                  : activityStreamHours!,
                              style: myTextStyleSmall(context),
                            ),
                            hintStyle: myTextStyleSmall(context),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 400,
                        child: TextFormField(
                          controller: daysController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return numberOfDays == null
                                  ? 'Please enter the number of days your dashboard must show'
                                  : numberOfDays!;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Enter the number of days your dashboard must show',
                            label: Text(
                              numberOfDaysForDashboardData == null
                                  ? 'Number of Dashboard Days'
                                  : numberOfDaysForDashboardData!,
                              style: myTextStyleSmall(context),
                            ),
                            hintStyle: myTextStyleSmall(context),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            selectSizePhotos == null
                                ? 'Select size of photos'
                                : selectSizePhotos!,
                            style: myTextStyleSmall(context),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Radio(
                            value: 0,
                            groupValue: groupValue,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: _handlePhotoSizeValueChange,
                          ),
                          Text(
                            small == null ? 'Small' : small!,
                            style: myTextStyleTiny(context),
                          ),
                          Radio(
                            value: 1,
                            groupValue: groupValue,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: _handlePhotoSizeValueChange,
                          ),
                          Text(medium == null ? 'Medium' : medium!,
                              style: myTextStyleTiny(context)),
                          Radio(
                            value: 2,
                            groupValue: groupValue,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: _handlePhotoSizeValueChange,
                          ),
                          Text(large == null ? 'Large' : large!,
                              style: myTextStyleTiny(context)),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),

                      busyWritingToDB
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                backgroundColor: Colors.pink,
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        showColorPicker
            ? Positioned(
                top: 24,
                left: 20,
                right: 20,
                child: SizedBox(
                  width: 240,
                  height: 360,
                  child: ColorSchemePicker(
                    onColorScheme: (index) async {
                      currentThemeIndex = index;
                      themeBloc.changeToTheme(currentThemeIndex);
                      setState(() {
                        showColorPicker = false;
                      });
                      if (settingsModel != null) {
                        settingsModel!.themeIndex = currentThemeIndex;
                        prefsOGx.saveSettings(settingsModel!);
                      }
                    },
                    crossAxisCount: 6,
                    itemWidth: 60,
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
    pp('$mm onLocaleChange ... going to ${locale.languageCode}');
    settingsModel!.locale = locale.languageCode;
    await prefsOGx.saveSettings(settingsModel!);
    await translator.translate('settings', settingsModel!.locale!);
    await _setTexts();
    themeBloc.changeToLocale(locale.languageCode);
    fcmBloc.settingsStreamController.sink.add(settingsModel!);

    setState(() {
      selectedLocale = locale;
      this.translatedLanguage = translatedLanguage;
    });

    widget.onLocaleChanged(locale.languageCode);
  }
}

///select supported locale
class LocaleChooser extends StatefulWidget {
  const LocaleChooser({Key? key, required this.onSelected, required this.hint, required this.color})
      : super(key: key);

  final Function(Locale, String) onSelected;
  final String hint;
  final Color color;

  @override
  State<LocaleChooser> createState() => LocaleChooserState();
}

class LocaleChooserState extends State<LocaleChooser> {
  String? english,
      french,
      portuguese,
      lingala,
      sotho,
      spanish,
      shona,
      swahili,
      tsonga,
      xhosa,
      zulu,
      yoruba,
      afrikaans,
      german,
      chinese;

  SettingsModel? settingsModel;
  @override
  void initState() {
    super.initState();
    setTexts();
  }

  Future setTexts() async {
    settingsModel = await prefsOGx.getSettings();
    settingsModel ??= getBaseSettings();
    english = await translator.translate('en', settingsModel!.locale!);
    afrikaans = await translator.translate('af', settingsModel!.locale!);
    french = await translator.translate('fr', settingsModel!.locale!);
    portuguese = await translator.translate('pt', settingsModel!.locale!);
    lingala = await translator.translate('ig', settingsModel!.locale!);
    sotho = await translator.translate('st', settingsModel!.locale!);
    spanish = await translator.translate('es', settingsModel!.locale!);
    swahili = await translator.translate('sw', settingsModel!.locale!);
    tsonga = await translator.translate('ts', settingsModel!.locale!);
    xhosa = await translator.translate('xh', settingsModel!.locale!);
    zulu = await translator.translate('zu', settingsModel!.locale!);
    yoruba = await translator.translate('yo', settingsModel!.locale!);
    german = await translator.translate('de', settingsModel!.locale!);
    chinese = await translator.translate('zh', settingsModel!.locale!);
    shona = await translator.translate('sn', settingsModel!.locale!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return settingsModel == null
        ? const SizedBox()
        : DropdownButton<Locale>(
            hint: Text(
              widget.hint,
              style: myTextStyleSmallWithColor(context, widget.color),
            ),
            items: [
              DropdownMenuItem(
                value: const Locale('en'),
                child: Text(english == null ? 'English' : english!,
                    style: myTextStyleSmall(context)),
              ),
              DropdownMenuItem(
                  value: const Locale('zh'),
                  child: Text(chinese == null ? 'Chinese' : chinese!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('af'),
                  child: Text(afrikaans == null ? 'Afrikaans' : afrikaans!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('fr'),
                  child: Text(french == null ? 'French' : french!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('de'),
                  child: Text(german == null ? 'German' : german!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('pt'),
                  child: Text(portuguese == null ? 'Portuguese' : portuguese!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('ig'),
                  child: Text(lingala == null ? 'Lingala' : lingala!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('st'),
                  child: Text(sotho == null ? 'Sotho' : sotho!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('es'),
                  child: Text(spanish == null ? 'Spanish' : spanish!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('sn'),
                  child: Text(shona == null ? 'Shona' : shona!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('sw'),
                  child: Text(swahili == null ? 'Swahili' : swahili!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('ts'),
                  child: Text(tsonga == null ? 'Tsonga' : tsonga!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('xh'),
                  child: Text(xhosa == null ? 'Xhosa' : xhosa!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('yo'),
                  child: Text(yoruba == null ? 'Yoruba' : yoruba!,
                      style: myTextStyleSmall(context))),
              DropdownMenuItem(
                  value: const Locale('zu'),
                  child: Text(zulu == null ? 'Zulu' : zulu!,
                      style: myTextStyleSmall(context))),
            ],
            onChanged: onChanged);
  }

  void onChanged(Locale? locale) async {
    pp('LocaleChooser 🌀🌀🌀🌀:onChanged: selected locale: '
        '${locale.toString()}');
    settingsModel = await prefsOGx.getSettings();
    settingsModel!.locale = locale!.languageCode;

    await prefsOGx.saveSettings(settingsModel!);
    await setTexts();

    var language = 'English';
    switch (locale.languageCode) {
      case 'eng':
        language = english!;
        break;
      case 'af':
        language = afrikaans!;
        break;
      case 'fr':
        language = french!;
        break;
      case 'pt':
        language = portuguese!;
        break;
      case 'ig':
        language = lingala!;
        break;
      case 'es':
        language = spanish!;
        break;
      case 'st':
        language = sotho!;
        break;
      case 'sw':
        language = swahili!;
        break;
      case 'xh':
        language = xhosa!;
        break;
      case 'zu':
        language = zulu!;
        break;
      case 'yo':
        language = yoruba!;
        break;
      case 'de':
        language = german!;
        break;
      case 'zh':
        language = chinese!;
        break;
    }
    await setTexts();
    widget.onSelected(locale, language);
  }
}

class GeoPlaceHolder extends StatelessWidget {
  const GeoPlaceHolder({Key? key, required this.width}) : super(key: key);
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Card(
          elevation: 4,
          shape: getRoundedBorder(radius: 16),
          child: SizedBox(
            height: 140,
            width: 300,
            child: Column(
              children: [
                const SizedBox(
                  height: 28,
                ),
                Text(
                  'Geo PlaceHolder',
                  style: myNumberStyleLarge(context),
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  'Geo content coming soon!',
                  style: myTextStyleMedium(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorSchemePicker extends StatelessWidget {
  const ColorSchemePicker(
      {Key? key,
      required this.onColorScheme,
      required this.crossAxisCount,
      required this.itemWidth,
      required this.elevation})
      : super(key: key);

  final Function(int) onColorScheme;
  final int crossAxisCount;
  final double itemWidth, elevation;


  @override
  Widget build(BuildContext context) {
    var colors = <ColorBag>[
      ColorBag(
        color: const Color(0xFF424343),
        index: 0,
      ),
      ColorBag(
        color: FlexColor.redWineDarkPrimary,
        index: 1,
      ),
      ColorBag(
        color: FlexColor.barossaDarkPrimary,
        index: 2,
      ),
      ColorBag(
        color: FlexColor.greenDarkPrimary,
        index: 3,
      ),
      ColorBag(
        color: FlexColor.mallardGreenDarkPrimary,
        index: 4,
      ),
      ColorBag(
        color: FlexColor.mandyRedDarkPrimary,
        index: 5,
      ),
      ColorBag(
        color: FlexColor.redDarkPrimary,
        index: 6,
      ),
      ColorBag(
        color: FlexColor.blueDarkPrimary,
        index: 7,
      ),
      ColorBag(
        color: FlexColor.mangoDarkPrimary,
        index: 8,
      ),
      ColorBag(
        color: FlexColor.indigoDarkPrimary,
        index: 9,
      ),
      ColorBag(
        color: FlexColor.deepBlueDarkPrimary,
        index: 10,
      ),
      ColorBag(
        color: FlexColor.hippieBlueDarkPrimary,
        index: 11,
      ),
      ColorBag(
        color: FlexColor.deepPurpleDarkPrimary,
        index: 12,
      ),
      ColorBag(
        color: FlexColor.espressoDarkPrimary,
        index: 13,
      ),
      ColorBag(
        color: FlexColor.barossaDarkPrimary,
        index: 14,
      ),
      ColorBag(
        color: FlexColor.bigStoneDarkPrimary,
        index: 15,
      ),
      ColorBag(
        color: FlexColor.damaskDarkPrimary,
        index: 16,
      ),
      ColorBag(
        color: FlexColor.purpleBrownDarkPrimary,
        index: 17,
      ),
      ColorBag(
        color: FlexColor.wasabiDarkPrimary,
        index: 18,
      ),
      ColorBag(
        color: FlexColor.rosewoodDarkPrimary,
        index: 19,
      ),
      ColorBag(
        color: FlexColor.sanJuanBlueDarkPrimary,
        index: 20,
      ),
      ColorBag(
        color: FlexColor.amberDarkPrimary,
        index: 21,
      ),
      ColorBag(
        color: FlexColor.dellGenoaGreenDarkPrimary,
        index: 22,
      ),
      ColorBag(
        color: FlexColor.goldDarkPrimary,
        index: 23,
      ),
      ColorBag(
        color: FlexColor.blueWhaleDarkPrimary,
        index: 24,
      ),
      ColorBag(
        color: FlexColor.ebonyClayDarkPrimary,
        index: 25,
      ),
      ColorBag(
        color: FlexColor.moneyDarkPrimary,
        index: 26,
      ),
      ColorBag(
        color: FlexColor.aquaBlueDarkPrimary,
        index: 27,
      ),
    ];

    var itemElevation = 0.0;
    return SizedBox(
      width: 400,
      height: 400,
      child: Card(
          shape: getRoundedBorder(radius: 16),
          elevation: elevation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 1,
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 1),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  var colorBag = colors.elementAt(index);
                  return SizedBox(
                    width: itemWidth,
                    height: itemWidth,
                    child: GestureDetector(
                      onTap: () {
                        onColorScheme(colorBag.index);
                        itemElevation = 8.0;
                      },
                      child: Card(
                        elevation: itemElevation,
                        child: Container(
                          width: itemWidth,
                          height: itemWidth,
                          color: colorBag.color,
                        ),
                      ),
                    ),
                  );
                }),
          )),
    );
  }
}

class ColorBag {
  late Color color;
  late int index;

  ColorBag({required this.color, required this.index});
}
