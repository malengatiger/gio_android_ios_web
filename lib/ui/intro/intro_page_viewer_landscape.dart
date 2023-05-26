import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/auth/auth_registration_main.dart';
import 'package:geo_monitor/ui/auth/auth_signin_main.dart';
import 'package:geo_monitor/ui/dashboard/dashboard_main.dart';
import 'package:page_transition/page_transition.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/cloud_storage_bloc.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/geo_uploader.dart';
import '../../library/bloc/isolate_handler.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/bloc/project_bloc.dart';
import '../../library/bloc/refresh_bloc.dart';
import '../../library/bloc/theme_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/settings_model.dart';
import '../../library/data/user.dart' as ur;
import '../../library/emojis.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../../library/ui/settings/settings_form.dart';
import '../../stitch/stitch_service.dart';
import 'intro_page_one_landscape.dart';

class IntroPageViewerLandscape extends StatefulWidget {
  const IntroPageViewerLandscape(
      {Key? key,
      required this.prefsOGx,
      required this.dataApiDog,
      required this.cacheManager,
      required this.fcmBloc,
      required this.organizationBloc,
      required this.projectBloc,
      required this.dataHandler,
      required this.geoUploader,
      required this.cloudStorageBloc,
      required this.firebaseAuth, required this.stitchService, required this.refreshBloc})
      : super(key: key);
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final FCMBloc fcmBloc;
  final OrganizationBloc organizationBloc;
  final ProjectBloc projectBloc;
  final IsolateDataHandler dataHandler;
  final GeoUploader geoUploader;
  final CloudStorageBloc cloudStorageBloc;
  final FirebaseAuth firebaseAuth;
  final StitchService stitchService;
  final RefreshBloc refreshBloc;



  @override
  State<IntroPageViewerLandscape> createState() =>
      IntroPageViewerLandscapeState();
}

class IntroPageViewerLandscapeState extends State<IntroPageViewerLandscape>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  fb.FirebaseAuth firebaseAuth = fb.FirebaseAuth.instance;
  ur.User? user;
  bool authed = false;
  String? organizations,
      managementPeople,
      fieldWorkers,
      executives,
      information,
      thankYou,
      thankYouMessage,
      infrastructure,
      govt,
      youth,
      community,
      hint,
      registerOrganization;

  final mm =
      '${E.pear}${E.pear}${E.pear}${E.pear} IntroPageViewerLandscape: ${E.pear} ';
  late SettingsModel settingsModel;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _getAuthenticationStatus();
  }

  Future _setTexts() async {
    settingsModel = await widget.prefsOGx.getSettings();
    late String locale;
    locale = settingsModel.locale!;

    hint = await translator.translate('selectLanguage', locale);
    organizations = await translator.translate('organizations', locale);
    managementPeople = await translator.translate('managementPeople', locale);
    fieldWorkers = await translator.translate('fieldWorkers', locale);
    executives = await translator.translate('executives', locale);
    information = await translator.translate('information', locale);
    thankYou = await translator.translate('thankYou', locale);
    thankYouMessage = await translator.translate('thankYouMessage', locale);

    infrastructure = await translator.translate('infrastructure', locale);
    govt = await translator.translate('govt', locale);
    youth = await translator.translate('youth', locale);
    community = await translator.translate('community', locale);
    registerOrganization =
        await translator.translate('registerOrganization', locale);
    setState(() {});
  }

  void _getAuthenticationStatus() async {
    pp('\n\n$mm _getAuthenticationStatus ....... '
        'check both Firebase user ang Geo user');
    var user = await widget.prefsOGx.getUser();
    var firebaseUser = firebaseAuth.currentUser;

    if (user != null && firebaseUser != null) {
      pp('$mm _getAuthenticationStatus .......  '
          '🥬🥬🥬auth is DEFINITELY authenticated and OK');
      authed = true;
    } else {
      pp('$mm _getAuthenticationStatus ....... NOT AUTHENTICATED! '
          '${E.redDot}${E.redDot}${E.redDot} ... will clean house!!');
      authed = false;
      //todo - ensure that the right thing gets done!
      prefsOGx.deleteUser();
      firebaseAuth.signOut();
      cacheManager.initialize();
      pp('$mm _getAuthenticationStatus .......  '
          '${E.redDot}${E.redDot}${E.redDot}'
          'the device should be ready for sign in or registration');
    }
    pp('$mm _getAuthenticationStatus ....... setting state ');
    setState(() {});
  }

  Future<void> _navigateToDashboard() async {
    user = await prefsOGx.getUser();
    if (user != null) {
      if (mounted) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.scale,
                alignment: Alignment.topLeft,
                duration: const Duration(milliseconds: 2000),
                child: DashboardMain(
                  dataApiDog: widget.dataApiDog,
                  fcmBloc: widget.fcmBloc,
                  dataHandler: widget.dataHandler,
                  organizationBloc: widget.organizationBloc,
                  projectBloc: widget.projectBloc,
                  cloudStorageBloc: cloudStorageBloc,
                  geoUploader: geoUploader,
                  refreshBloc: widget.refreshBloc,
                  prefsOGx: widget.prefsOGx,
                  firebaseAuth: widget.firebaseAuth,
                  stitchService: widget.stitchService,
                  cacheManager: widget.cacheManager,
                )));
      } else {
        pp('$mm User is null,  🔆 🔆 🔆 🔆 cannot navigate to Dashboard');
      }
    }
  }

  Future<void> _navigateToSignIn() async {
    pp('$mm _navigateToSignIn ....... ');
    var result = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: AuthSignIn(
              prefsOGx: prefsOGx,
              dataApiDog: dataApiDog,
              cacheManager: cacheManager,
            )));

    if (result is ur.User) {
      pp('\n\n\n$mm _navigateToSignIn ....... back from AuthSignInMain with a user '
          '... 🔵🔵🔵🔵 ${result.toJson()} ');
    }
    user = await prefsOGx.getUser();
    pp('\n\n$mm 😡😡 Returned from sign in, checking if login succeeded bu getting user from cache 😡');

    if (user != null) {
      pp('$mm _navigateToSignIn: 👌👌👌 Returned from sign in; '
          'will navigate to Dashboard : 👌👌👌 ${user!.toJson()}');
      setState(() {});
      _navigateToDashboard();
    } else {
      pp('$mm 😡😡 Returned from sign in; cached user not found. '
          '${E.redDot}${E.redDot} NOT GOOD! ${E.redDot}');
      if (mounted) {
        showToast(
            message: 'Email Sign In Failed',
            duration: const Duration(seconds: 5),
            backgroundColor: Theme.of(context).primaryColor,
            padding: 12.0,
            context: context);
      }
    }
  }

  Future<void> _navigateToOrgRegistration() async {
    var result = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: AuthRegistrationMain(
              prefsOGx: prefsOGx,
              dataApiDog: dataApiDog,
              cacheManager: cacheManager,
              firebaseAuth: firebaseAuth,
            )));

    if (result is ur.User) {
      pp('$mm _navigateToOrgRegistration: 👌👌👌 Returned from Registration; will navigate to Dashboard :  👌👌👌 ${result.toJson()}');
      setState(() {
        user = result;
      });
      _navigateToDashboard();
    } else {
      pp('$mm _navigateToOrgRegistration: 😡😡  Returned from Registration; we do not have a user :  😡 $result');
    }
  }

  onSelected(Locale p1, String p2) async {
    pp('$mm locale selected: $p1 - $p2');
    settingsModel.organizationId = user!.organizationId;
    await widget.prefsOGx.saveSettings(settingsModel);
    await _setTexts();
    Locale newLocale = Locale(p1.languageCode);
    final m = LocaleAndTheme(
        themeIndex: settingsModel.themeIndex!, locale: newLocale);
    themeBloc.themeStreamController.sink.add(m);
    widget.fcmBloc.settingsStreamController.sink.add(settingsModel!);

    ;
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
        title: const Text('Geo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: authed
              ? Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close)),
                  ],
                )
              : Card(
                  elevation: 4,
                  color: Colors.black38,
                  shape: getRoundedBorder(radius: 16),
                  child: authed
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LocaleChooser(
                                onSelected: onSelected,
                                color: color,
                                hint: hint == null ? 'Select Language' : hint!),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: _navigateToSignIn,
                                child: const Text('Sign In')),
                            const SizedBox(
                              width: 120,
                            ),
                            TextButton(
                                onPressed: _navigateToOrgRegistration,
                                child: const Text('Register Organization')),
                            LocaleChooser(
                                onSelected: onSelected,
                                color: color,
                                hint: hint == null ? 'Select Language' : hint!),
                          ],
                        ),
                ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            // itemExtent: ,
            children: [
              IntroPageLandscape(
                title: 'Geo',
                assetPath: 'assets/intro/pic2.jpg',
                text: infrastructure == null ? lorem : infrastructure!,
                width: 420,
              ),
              IntroPageLandscape(
                title: organizations == null ? 'Organizations' : organizations!,
                assetPath: 'assets/intro/pic5.jpg',
                text: youth == null ? lorem : youth!,
                width: 420,
              ),
              IntroPageLandscape(
                title: managementPeople == null ? 'People' : managementPeople!,
                assetPath: 'assets/intro/pic1.jpg',
                text: community == null ? lorem : community!,
                width: 420,
              ),
              IntroPageLandscape(
                title: fieldWorkers == null ? 'Field Monitors' : fieldWorkers!,
                assetPath: 'assets/intro/pic5.jpg',
                text: lorem,
                width: 420,
              ),
              IntroPageLandscape(
                title: thankYou == null ? 'Thank You' : thankYou!,
                assetPath: 'assets/intro/pic3.webp',
                text: thankYouMessage == null ? lorem : thankYouMessage!,
                width: 420,
              ),
            ],
          )
        ],
      ),
    ));
  }
}
