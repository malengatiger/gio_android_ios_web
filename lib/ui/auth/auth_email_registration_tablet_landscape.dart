import 'package:flutter/material.dart';
import 'package:geo_monitor/ui/intro/intro_page_one_landscape.dart';

import '../../library/functions.dart';
import 'auth_email_registration_tablet_portrait.dart';

////

class AuthEmailRegistrationLandscape extends StatelessWidget {
  const AuthEmailRegistrationLandscape({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Geo!'),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              const AuthEmailRegistrationPortrait(
                amInsideLandscape: true,
              ),
              const SizedBox(
                width: 0,
              ),
              Card(
                shape: getRoundedBorder(radius: 16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: IntroPageLandscape(
                    title: 'GeoMonitor',
                    assetPath: 'assets/intro/pic2.jpg',
                    text: lorem,
                    width: 400,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }
}
