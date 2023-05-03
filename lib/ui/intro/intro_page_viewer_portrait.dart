import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/ui/settings/settings_form.dart';
import 'package:geo_monitor/ui/auth/auth_registration_main.dart';
import 'package:geo_monitor/ui/auth/auth_signin_main.dart';
import 'package:page_transition/page_transition.dart';

import '../../dashboard_khaya/xd_dashboard.dart';
import '../../l10n/translation_handler.dart';
import '../../library/api/data_api_og.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/fcm_bloc.dart';
import '../../library/bloc/isolate_handler.dart';
import '../../library/bloc/organization_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/user.dart' as ur;
import '../../library/emojis.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../intro/intro_page_one.dart';

class IntroPageViewerPortrait extends StatefulWidget {
  const IntroPageViewerPortrait({
    Key? key, required this.prefsOGx, required this.dataApiDog, required this.cacheManager, required this.isolateHandler, required this.fcmBloc, required this.organizationBloc,
  }) : super(key: key);
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  final IsolateDataHandler isolateHandler;
  final FCMBloc fcmBloc;
  final OrganizationBloc organizationBloc;


  @override
  IntroPageViewerPortraitState createState() => IntroPageViewerPortraitState();
}

class IntroPageViewerPortraitState extends State<IntroPageViewerPortrait>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final PageController _pageController = PageController();
  bool authed = false;
  fb.FirebaseAuth firebaseAuth = fb.FirebaseAuth.instance;
  ur.User? user;
  String? signInFailed;


  final mm =
      '${E.pear}${E.pear}${E.pear}${E.pear} IntroPageViewerPortrait: ${E.pear} ';

  SettingsModel? settingsModel;
  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _getAuthenticationStatus();
  }

  IntroStrings? introStrings;

  Future _setTexts({String? selectedLocale}) async {
    settingsModel = await prefsOGx.getSettings();
      settingsModel = getBaseSettings();
      await prefsOGx.saveSettings(settingsModel!);

    introStrings = await IntroStrings.getTranslated();
    signInFailed = await translator.translate('signInFailed', settingsModel!.locale!);
    setState(() {});
  }

  void _getAuthenticationStatus() async {
    pp('\n\n$mm _getAuthenticationStatus ....... '
        'check both Firebase user ang Geo user');
    var user = await prefsOGx.getUser();
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
      cacheManager.initialize(forceInitialization: true);
      pp('$mm _getAuthenticationStatus .......  '
          '${E.redDot}${E.redDot}${E.redDot}'
          'the device should be ready for sign in or registration');
    }
    pp('$mm ......... _getAuthenticationStatus ....... setting state, authed = $authed ');
    setState(() {});
  }

  void _navigateToDashboard() {
    if (user != null) {
      //Navigator.of(context).pop(user);
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.scale,
              alignment: Alignment.topLeft,
              duration: const Duration(seconds: 2),
              child:  DashboardKhaya(
                dataApiDog: widget.dataApiDog,
                isolateHandler: widget.isolateHandler, fcmBloc: widget.fcmBloc, organizationBloc: widget.organizationBloc,)));
    } else {
      pp('User is null,  🔆 🔆 🔆 🔆 cannot navigate to Dashboard');
    }
  }


  Future<void> _navigateToSignIn() async {
    pp('$mm _navigateToSignIn ....... ');

    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child:  AuthSignIn(
              prefsOGx: prefsOGx, dataApiDog: dataApiDog, cacheManager: cacheManager,
            )));

    pp('$mm _navigateToSignIn ....... back from PhoneLogin with maybe a user ..');
    user = await prefsOGx.getUser();
    pp('\n\n$mm 😡😡Returned from sign in, checking if login succeeded 😡');

    if (user != null) {
      pp('$mm _navigateToSignIn: 👌👌👌 Returned from sign in; '
          'will navigate to Dashboard :  👌👌👌 ${user!.toJson()}');
      setState(() {});
      _navigateToDashboard();
    } else {
      pp('$mm 😡😡 Returned from sign in; cached user not found. '
          '${E.redDot}${E.redDot} NOT GOOD! ${E.redDot}');
      if (mounted) {
        showToast(
            message: signInFailed == null?'Phone Sign In Failed':signInFailed!,
            duration: const Duration(seconds: 5),
            backgroundColor: Theme.of(context).primaryColor,
            padding: 12.0,
            context: context);
      }
    }
  }

  Future<void> _navigateToOrgRegistration() async {
    //mainSetup();
    var result = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child:  AuthRegistrationMain(
              prefsOGx: prefsOGx, dataApiDog: dataApiDog, cacheManager: cacheManager,
            )));

    if (result is ur.User) {
      pp(' 👌👌👌 Returned from sign in; will navigate to Dashboard :  👌👌👌 ${result.toJson()}');
      setState(() {
        user = result;
      });
      _navigateToDashboard();
    } else {
      pp(' 😡  😡  Returned from sign in is NOT a user :  😡 $result');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  double currentIndexPage = 0.0;
  int pageIndex = 0;
  String? hint;
  void _onPageChanged(int value) {
    if (mounted) {
      setState(() {
        currentIndexPage = value.toDouble();
      });
    }
  }

  void onSignIn() {
    pp('$mm onSignIn ...');
    _navigateToSignIn();
  }

  void onRegistration() {
    pp('$mm onRegistration ...');
    _navigateToOrgRegistration();
  }

  onLanguageSelected(Locale p1, String p2) async {
    pp('$mm locale selected: $p1 - $p2, will save in new settings ... ');

    final baseSettings = getBaseSettings();
    baseSettings.locale = p1.languageCode;
    await prefsOGx.saveSettings(baseSettings);
    await _setTexts(selectedLocale: p1.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          introStrings == null ? 'Geo Information' : introStrings!.information!,
          style: myTextStyleLarge(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(authed ? 36 : 100),
          child: authed
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LocaleChooser(
                        onSelected: onLanguageSelected,
                        hint: introStrings == null ? 'Select Language' : introStrings!.hint),
                  ],
                )
              : Card(
                  elevation: 4,
                  color: Colors.black26,
                  // shape: getRoundedBorder(radius: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: onSignIn, child:  Text(introStrings == null?
                              'Sign In': introStrings!.signIn)),
                          TextButton(
                              onPressed: onRegistration,
                              child: Text(introStrings == null
                                  ? 'Register Organization'
                                  : introStrings!.registerOrganization)),
                        ],
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          LocaleChooser(
                              onSelected: onLanguageSelected,
                              hint: introStrings == null ? 'Select Language' : introStrings!.hint),

                        ],
                      )
                    ],
                  ),
                ),
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              IntroPage(
                title: 'Geo',
                assetPath: 'assets/intro/pic2.jpg',
                text: introStrings == null ? lorem : introStrings!.infrastructure,
              ),
              IntroPage(
                title: introStrings == null ? 'Organizations' : introStrings!.organizations,
                assetPath: 'assets/intro/pic5.jpg',
                text: introStrings == null ? lorem : introStrings!.youth,
              ),
              IntroPage(
                title: introStrings == null ? 'People' : introStrings!.managementPeople,
                assetPath: 'assets/intro/pic1.jpg',
                text: introStrings == null ? lorem : introStrings!.community,
              ),
              IntroPage(
                title: introStrings == null ? 'Field Monitors' : introStrings!.fieldWorkers,
                assetPath: 'assets/intro/pic5.jpg',
                text: lorem,
              ),
              IntroPage(
                title: introStrings == null ? 'Thank You' : introStrings!.thankYou,
                assetPath: 'assets/intro/pic3.webp',
                text: introStrings == null ? lorem : introStrings!.thankYouMessage,
              ),
            ],
          ),
          Positioned(
            bottom: 2,
            left: 48,
            right: 40,
            child: SizedBox(
              width: 200,
              height: 48,
              child: Card(
                color: Colors.black12,
                shape: getRoundedBorder(radius: 8),
                child: DotsIndicator(
                  dotsCount: 5,
                  position: currentIndexPage,
                  decorator: const DotsDecorator(
                    colors: [
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                      Colors.grey,
                    ], // Inactive dot colors
                    activeColors: [
                      Colors.pink,
                      Colors.blue,
                      Colors.teal,
                      Colors.indigo,
                      Colors.deepOrange,
                    ], // Àctive dot colors
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class IntroStrings {
  late String organizations,
      managementPeople,
      fieldWorkers,
      executives,
      information,
      thankYou,
      thankYouMessage,
      infrastructure,
      govt,
      youth,
      hint, signIn, signInFailed,
      community,
      registerOrganization;

  IntroStrings(
      {required this.organizations,
      required this.managementPeople,
      required this.fieldWorkers,
      required this.executives,
      required this.information,
      required this.thankYou,
      required this.thankYouMessage,
      required this.infrastructure,
      required this.govt,
      required this.youth,
      required this.hint,
        required this.signIn,
      required this.community,

      required this.registerOrganization});

  static Future<IntroStrings> getTranslated() async {
    var settingsModel = await prefsOGx.getSettings();
    var hint = await translator.translate('selectLanguage', settingsModel!.locale!);

    var signIn = await translator.translate('signIn', settingsModel.locale!);
    var organizations =
        await translator.translate('organizations', settingsModel.locale!);
    var managementPeople =
        await translator.translate('managementPeople', settingsModel.locale!);
    var fieldWorkers =
        await translator.translate('fieldWorkers', settingsModel.locale!);
    var executives = await translator.translate('executives', settingsModel.locale!);
    var information = await translator.translate('information', settingsModel.locale!);
    var thankYou = await translator.translate('thankYou', settingsModel.locale!);
    var thankYouMessage =
        await translator.translate('thankYouMessage', settingsModel.locale!);

    var infrastructure =
        await translator.translate('infrastructure', settingsModel.locale!);
    var govt = await translator.translate('govt', settingsModel.locale!);
    var youth = await translator.translate('youth', settingsModel.locale!);
    var community = await translator.translate('community', settingsModel.locale!);
    var registerOrganization =
        await translator.translate('registerOrganization', settingsModel.locale!);

    final m = IntroStrings(
        organizations: organizations,
        managementPeople: managementPeople,
        fieldWorkers: fieldWorkers,
        executives: executives,
        information: information,
        thankYou: thankYou,
        signIn: signIn,
        thankYouMessage: thankYouMessage,
        infrastructure: infrastructure,
        govt: govt,
        youth: youth,
        hint: hint,
        community: community,
        registerOrganization: registerOrganization);
    return m;
  }
}
