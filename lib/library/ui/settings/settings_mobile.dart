import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/ui/settings/settings_form.dart';
import 'package:geo_monitor/library/ui/settings/settings_form_monitor.dart';

import '../../../l10n/translation_handler.dart';
import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/fcm_bloc.dart';
import '../../bloc/organization_bloc.dart';
import '../../cache_manager.dart';
import '../../data/project.dart';
import '../../data/settings_model.dart';
import '../../data/user.dart';
import '../../functions.dart';
import '../../generic_functions.dart';

class SettingsMobile extends StatefulWidget {
  const SettingsMobile(
      {Key? key,
      required this.isolateHandler,
      required this.dataApiDog,
      required this.prefsOGx,
      required this.organizationBloc})
      : super(key: key);

  final IsolateDataHandler isolateHandler;
  final DataApiDog dataApiDog;

  final PrefsOGx prefsOGx;
  final OrganizationBloc organizationBloc;
  @override
  SettingsMobileState createState() => SettingsMobileState();
}

class SettingsMobileState extends State<SettingsMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  SettingsModel? settingsModel;
  var distController = TextEditingController(text: '500');
  var videoController = TextEditingController(text: '20');
  var audioController = TextEditingController(text: '60');
  var activityController = TextEditingController(text: '24');

  late StreamSubscription<SettingsModel> settingsSubscriptionFCM;

  var orgSettings = <SettingsModel>[];

  int photoSize = 0;
  int currentThemeIndex = 0;
  int groupValue = 0;
  bool busy = false;
  bool busyWritingToDB = false;
  Project? selectedProject;
  User? user;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _listenToFCM();
    _getOrganizationSettings();
  }

  String? title;
  bool showMonitorForm = false;
  void _handleOnLocaleChanged(String locale) async {
    pp('SettingsForm 😎😎😎😎 _handleOnLocaleChanged: $locale');
    _setTexts();
  }

  Future _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
    title = await translator.translate('settings', settingsModel!.locale!);
    user = await prefsOGx.getUser();
    if (user!.userType! == UserType.fieldMonitor) {
      showMonitorForm = true;
    }
    setState(() {});
  }

  void _listenToFCM() async {
    settingsSubscriptionFCM =
        fcmBloc.settingsStream.listen((SettingsModel event) async {
      if (mounted) {
        await _setTexts();
      }
    });
  }

  void _getOrganizationSettings() async {
    pp('🍎🍎 ............. getting user from prefs ...');
    user = await prefsOGx.getUser();
    setState(() {
      busy = true;
    });
    try {
      orgSettings = await cacheManager.getOrganizationSettings();
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            duration: const Duration(seconds: 5),
            message: '$e',
            context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    settingsSubscriptionFCM.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final  color = getTextColorForBackground(Theme.of(context).primaryColor);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          title == null ? 'Settings' : title!,
          style: myTitleTextStyle(context, color),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(showMonitorForm ? 12 : 8),
          child: const SizedBox(),
        ),
      ),
          backgroundColor: isDarkMode?Theme.of(context).canvasColor: Colors.brown[50],
          body: busy
          ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Colors.pink,
                    )),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: showMonitorForm
                  ? SettingsFormMonitor(
                      onLocaleChanged: (locale) {
                        _handleOnLocaleChanged(locale);
                      },
                      padding: 20)
                  : SettingsForm(
                      padding: 8,
                      onLocaleChanged: (String locale) {
                        _handleOnLocaleChanged(locale);
                      },
                      dataApiDog: widget.dataApiDog,
                      prefsOGx: widget.prefsOGx,
                      organizationBloc: widget.organizationBloc,
                      dataHandler: widget.isolateHandler,
                    ),
            ),
    ));
  }
}
