import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_monitor/initializer.dart';
import 'package:geo_monitor/l10n/translation_handler.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/project_bloc.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:geo_monitor/splash/splash_page.dart';
import 'package:geo_monitor/ui/dashboard/dashboard_main.dart';
import 'package:geo_monitor/ui/intro/intro_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:universal_platform/universal_platform.dart';

import 'firebase_options.dart';
import 'library/api/data_api_og.dart';
import 'library/api/prefs_og.dart';
import 'library/bloc/cloud_storage_bloc.dart';
import 'library/bloc/fcm_bloc.dart';
import 'library/bloc/geo_uploader.dart';
import 'library/bloc/theme_bloc.dart';
import 'library/cache_manager.dart';
import 'library/emojis.dart';

int themeIndex = 0;
var locale = const Locale('en');
late FirebaseApp firebaseApp;
fb.User? fbAuthedUser;
final mx =
    '${E.heartGreen}${E.heartGreen}${E.heartGreen}${E.heartGreen} main: ';
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: GeoApp()));
}

class GeoApp extends ConsumerWidget {
  const GeoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return GestureDetector(
      onTap: () {
        pp('$mx 🌀🌀🌀🌀 Tap detected; should dismiss keyboard ...');
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StreamBuilder<LocaleAndTheme>(
        stream: themeBloc.localeAndThemeStream,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            pp('${E.check}${E.check}${E.check}'
                'build: theme index has changed to ${snapshot.data!.themeIndex}'
                '  and locale is ${snapshot.data!.locale.toString()}');
            themeIndex = snapshot.data!.themeIndex;
            locale = snapshot.data!.locale;
            pp('${E.check}${E.check}${E.check} GeoApp: build: locale object received from stream: $locale');
          }

          return MaterialApp(
            locale: locale,
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            title: 'Gio',
            theme: themeBloc.getTheme(themeIndex).lightTheme,
            darkTheme: themeBloc.getTheme(themeIndex).darkTheme,
            themeMode: ThemeMode.system,
            // home:  const ComboAudio()
            home: AnimatedSplashScreen(
              duration: 5000,
              splash: const SplashWidget(),
              animationDuration: const Duration(milliseconds: 3000),
              curve: Curves.easeInCirc,
              splashIconSize: 160.0,
              nextScreen: const LandingPage(),
              splashTransition: SplashTransition.fadeTransition,
              pageTransitionType: PageTransitionType.leftToRight,
              backgroundColor: Colors.pink.shade900,
            ),
          );
        },
      ),
    );
  }
}

late StreamSubscription killSubscriptionFCM;

void showKillDialog({required String message, required BuildContext context}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(
        "Critical App Message",
        style: myTextStyleLarge(ctx),
      ),
      content: Text(
        message,
        style: myTextStyleMedium(ctx),
      ),
      shape: getRoundedBorder(radius: 16),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            pp('$mm Navigator popping for the last time, Sucker! 🔵🔵🔵');
            var android = UniversalPlatform.isAndroid;
            var ios = UniversalPlatform.isIOS;
            if (android) {
              SystemNavigator.pop();
            }
            if (ios) {
              Navigator.of(ctx).pop();
              Navigator.of(ctx).pop();
            }
          },
          child: const Text("Exit the App"),
        ),
      ],
    ),
  );
}

StreamSubscription<String> listenForKill({required BuildContext context}) {
  pp('\n$mx Kill message; listen for KILL message ...... 🍎🍎🍎🍎 ......');

  var sub = fcmBloc.killStream.listen((event) {
    pp('$mm Kill message arrived: 🍎🍎🍎🍎 $event 🍎🍎🍎🍎');
    try {
      showKillDialog(message: event, context: context);
    } catch (e) {
      pp(e);
    }
  });

  return sub;
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  final mx = '🔵🔵🔵🔵🔵🔵 LandingPage 🔵🔵';
  bool busy = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future initialize() async {
    pp('$mx ...................... initialize .............🍎🍎🍎');
    final start = DateTime.now();
    setState(() {
      busy = true;
    });

    firebaseApp = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    pp('$mx initialize: '
        ' Firebase App has been initialized: ${firebaseApp.name}, checking for authed current user');
    fbAuthedUser = fb.FirebaseAuth.instance.currentUser;
    await initializer.initializeGeo();

    final end = DateTime.now();
    pp('$mx ................. initialization took: 🔆 ${end.difference(start).inMilliseconds} inMilliseconds 🔆');

    setState(() {
      busy = false;
    });
  }

  Widget getWidget() {
    if (busy) {
      pp('$mx getWidget returning empty sizeBox because initialization is still going on ...');
      return const SizedBox();
    }
    if (fbAuthedUser == null) {
      pp('$mx getWidget returning widget IntroMain ..');
      return IntroMain(
        prefsOGx: prefsOGx,
        dataApiDog: dataApiDog,
        cacheManager: cacheManager,
        isolateHandler: dataHandler,
        fcmBloc: fcmBloc,
        organizationBloc: organizationBloc,
        projectBloc: projectBloc,
        geoUploader: geoUploader,
        cloudStorageBloc: cloudStorageBloc,
      );
    } else {
      pp('$mx getWidget returning widget DashboardMain ..');
      return DashboardMain(
        dataHandler: dataHandler,
        dataApiDog: dataApiDog,
        fcmBloc: fcmBloc,
        projectBloc: projectBloc,
        prefsOGx: prefsOGx,
        cloudStorageBloc: cloudStorageBloc,
        geoUploader: geoUploader,
        organizationBloc: organizationBloc,
        cacheManager: cacheManager,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    pp('$mx build method starting ....');
    return busy
        ? Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image.asset(
                'assets/gio.png',
                height: 100,
                width: 80,
              ),
            ),
          )
        : getWidget();
  }
}
