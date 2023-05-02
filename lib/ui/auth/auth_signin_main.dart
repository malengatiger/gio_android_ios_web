import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/ui/auth/auth_phone_signin.dart';
import 'package:geo_monitor/ui/auth/auth_tablet_signin.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../library/cache_manager.dart';
import '../../library/data/user.dart';
import 'auth_email_signin.dart';

class AuthSignIn extends StatelessWidget {
  const AuthSignIn({Key? key, required this.dataApiDog, required this.prefsOGx, required this.cacheManager}) : super(key: key);

  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: AuthPhoneSignIn(
        onSignedIn: (user) {},
        onError: (msg) {},
        prefsOGx: prefsOGx, dataApiDog: dataApiDog, cacheManager: cacheManager,
      ),
      tablet:  AuthTabletSignIn(
        prefsOGx: prefsOGx, dataApiDog: dataApiDog, cacheManager: cacheManager,
      ),
    );
  }
}
