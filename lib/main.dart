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
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:geo_monitor/splash/splash_page.dart';
import 'package:geo_monitor/ui/dashboard/dashboard_main.dart';
import 'package:geo_monitor/ui/intro/intro_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:page_transition/page_transition.dart';
import 'package:universal_platform/universal_platform.dart';

import 'firebase_options.dart';
import 'library/api/data_api_og.dart';
import 'library/api/prefs_og.dart';
import 'library/bloc/fcm_bloc.dart';
import 'library/bloc/theme_bloc.dart';
import 'library/cache_manager.dart';
import 'library/emojis.dart';
import 'library/ui/loading_card.dart';

int themeIndex = 0;
var locale = const Locale('en');
SettingsModel? settings;
late FirebaseApp firebaseApp;
fb.User? fbAuthedUser;
final mx =
    '${E.heartGreen}${E.heartGreen}${E.heartGreen}${E.heartGreen} main: ';
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  pp('$mx main: '
      ' Firebase App has been initialized: ${firebaseApp.name}, checking for authed current user');
  fbAuthedUser = fb.FirebaseAuth.instance.currentUser;

  pp('$mx main: setting up GetStorage ...');
  await GetStorage.init(cacheName);
  prefsOGx = PrefsOGx();
  settings = await prefsOGx.getSettings();
  locale = Locale(settings!.locale!);

  /// check user auth status
  if (fbAuthedUser == null) {
    pp('$mx main: fbAuthedUser is NULL ${E.redDot}${E.redDot}${E.redDot} no user signed in.');
  } else {
    pp('$mx main: fbAuthedUser is OK! check whether user exists, '
        'auth could be from old instance of app${E.leaf}${E.leaf}${E.leaf}');
    var user = await prefsOGx.getUser();
    if (user == null) {
      pp('$mx main: 🔴🔴🔴 user is null; cleanup necessary! '
          '🔴fbAuthedUser will be set to null');
      await fb.FirebaseAuth.instance.signOut();
      fbAuthedUser = null;
    }
    //cameras = await availableCameras();
  }
  await dotenv.load(fileName: ".env");
  pp('$mx $heartBlue DotEnv has been loaded');

  if (settings != null) {
    translator.translate('settings', settings!.locale!);
    pp('$mx $heartBlue translation service initialization started for locale👌 ${settings!.locale!}');
  }

  //await initializer.initializeGeo();
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  runApp(const ProviderScope(child: GeoApp()));
}

class GeoApp extends ConsumerWidget {
  const GeoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final data = ref.watch(dataProvider);
    // pp('$mx 🌀🌀🌀🌀 RiverPod ref.watch: ${data.shoutOut()} ...');

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
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool busy = false;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    setState(() {
      busy = true;
    });
    fbAuthedUser = fb.FirebaseAuth.instance.currentUser;
    await initializer.initializeGeo();
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return busy
        ? const LoadingCard(loadingData: 'loadingActivities')
        : fbAuthedUser == null
            ? IntroMain(
                prefsOGx: prefsOGx,
                dataApiDog: dataApiDog,
                cacheManager: cacheManager,
                isolateHandler: dataHandler,
                fcmBloc: fcmBloc,
                organizationBloc: organizationBloc,
                projectBloc: projectBloc,
              )
            : DashboardMain(
                isolateHandler: dataHandler,
                dataApiDog: dataApiDog,
                fcmBloc: fcmBloc,
                projectBloc: projectBloc,
                prefsOGx: prefsOGx,
                organizationBloc: organizationBloc, cacheManager: cacheManager,
              );
  }
}
