import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/theme_bloc.dart';
import 'package:geo_monitor/library/data/country.dart';
import 'package:geo_monitor/library/data/organization.dart';
import 'package:geo_monitor/library/data/organization_registration_bag.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:uuid/uuid.dart';

import '../../device_location/device_location_bloc.dart';
import '../../l10n/translation_handler.dart';
import '../../library/api/data_api_og.dart';
import '../../library/cache_manager.dart';
import '../../library/data/user.dart' as ur;
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../../library/users/edit/country_chooser.dart';

class AuthEmailRegistrationPortrait extends StatefulWidget {
  const AuthEmailRegistrationPortrait(
      {Key? key, required this.amInsideLandscape})
      : super(key: key);

  final bool amInsideLandscape;
  @override
  AuthEmailRegistrationPortraitState createState() =>
      AuthEmailRegistrationPortraitState();
}

class AuthEmailRegistrationPortraitState
    extends State<AuthEmailRegistrationPortrait>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final mm = '🥬🥬🥬🥬🥬🥬 AuthEmailRegistrationPortrait: ';
  String? phoneVerificationId;
  String? code;
  final phoneController = TextEditingController(text: "+27659990000");
  final passwordController = TextEditingController(text: "pass123");
  final passwordController2 = TextEditingController(text: "pass123");

  final orgNameController = TextEditingController();
  final adminController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool verificationFailed = false, verificationCompleted = false;
  bool busy = false;
  final _formKey = GlobalKey<FormState>();
  ur.User? user;
  Country? country;

  final errorController = StreamController<ErrorAnimationType>();
  String? currentText;

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 2000),
        reverseDuration: const Duration(milliseconds: 2000),
        vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? password;
  void _submitRegistration() async {
    pp('$mm register organization, ......................');
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (country == null) {
      pp('$mm country is null, should show toast ......................');

      showToast(
          duration: const Duration(seconds: 3),
          padding: 24.0,
          message: 'Please select country',
          context: context);
      setState(() {
        busy = false;
      });
      return;
    }
    setState(() {
      busy = true;
    });

    try {
      pp('\n\n$mm .... submit registration ...... 🍎${orgNameController.value.text}');
      password = passwordController.value.text;
      var email = emailController.value.text;

      var userCred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password!);
      pp('\n$mm createUserWithEmailAndPassword: firebase user credential obtained:  🍎 $userCred');

      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password!);
      pp('\n\n$mm signInWithEmailAndPassword: firebase user signed in with email/password, userCred:  🍎 $userCred \n');

      await _doTheRegistration(userCred, password!);

      if (mounted) {
        showToast(
            duration: const Duration(seconds: 2),
            message: '${orgNameController.value.text} registered',
            padding: 24,
            context: context);

        if (widget.amInsideLandscape) {
          //todo - what do we do here, Boss! .....
        } else {
          Navigator.of(context).pop(user);
        }
      }
    } catch (e) {
      pp(e);
      String msg = e.toString();
      if (msg.contains('dup key')) {
        msg = 'Duplicate organization name, please modify';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(duration: const Duration(seconds: 5), content: Text(msg)));
        setState(() {
          busy = false;
        });
      }
      return;
    }
    setState(() {
      busy = false;
    });

    _popOut();
  }

  Future<void> _doTheRegistration(
      UserCredential userCred, String password) async {

    var org = Organization(
        name: orgNameController.value.text,
        countryId: country!.countryId,
        email: '',
        created: DateTime.now().toUtc().toIso8601String(),
        countryName: country!.name,
        organizationId: const Uuid().v4());

    final sett1 = await cacheManager.getSettings();
    final memberAdded = await translator.translate('memberAddedChanged', sett1.locale!);
    final messageFromGeo = await getFCMMessageTitle();
    user = ur.User(
        name: adminController.value.text,
        email: emailController.value.text,
        userId: userCred.user!.uid,
        cellphone: phoneController.value.text,
        created: DateTime.now().toUtc().toIso8601String(),
        userType: ur.UserType.orgAdministrator,
        gender: null,
        active: 0,
        organizationName: orgNameController.value.text,
        organizationId: org.organizationId,
        countryId: country!.countryId,
        translatedMessage: memberAdded,
        translatedTitle: messageFromGeo,
        password: password);

    await prefsOGx.saveUser(user!);
    var sett = getBaseSettings();
    sett.organizationId = org.organizationId!;

    var mSettings = await dataApiDog.addSettings(sett);

    await prefsOGx.saveSettings(mSettings);

    var loc = await locationBloc.getLocation();

    if (loc != null) {
      var bag = OrganizationRegistrationBag(
          organization: org,
          projectPosition: null,
          settings: mSettings,
          user: user,
          project: null,
          date: DateTime.now().toUtc().toIso8601String(),
          latitude: loc.latitude,
          longitude: loc.longitude);

      var resultBag = await dataApiDog.registerOrganization(bag);
      await firebaseAuth.signOut();
      var cred = await firebaseAuth.signInWithEmailAndPassword(
          email: user!.email!, password: password);
      pp('$mm cred after signing in again after auth update: 🍎 $cred 🍎');
      await prefsOGx.getUser();
      await themeBloc.changeToTheme(mSettings.themeIndex!);

      pp('\n\n$mm Organization registered: 🌍🌍🌍🌍 🍎 resultBag: ${resultBag.toJson()} 🌍🌍🌍🌍\n\n');
    } else {
      if (mounted) {
        showToast(
            message: 'Unable to obtain device location', context: context);
      }
    }
  }

  void _popOut() {
    if (user == null) return;
    if (mounted) {
      Navigator.of(context).pop(user);
    }
  }

  _onCountrySelected(Country p1) {
    if (mounted) {
      setState(() {
        country = p1;
      });
    }
    prefsOGx.saveCountry(p1);
  }
  bool refreshCountries = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: getRoundedBorder(radius: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SizedBox(
                      width: 500,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            busy
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 6,
                                            backgroundColor: Colors.pink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(
                                    height: 12,
                                  ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              'Organization Registration',
                              style: myTextStyleLarge(context),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 48.0),
                              child: Row(
                                children: [
                                  CountryChooser(
                                      refreshCountries: refreshCountries,
                                      onSelected: _onCountrySelected,
                                    hint: 'Please select country',),
                                  const SizedBox(
                                    width: 64,
                                  ),
                                  country == null
                                      ? const SizedBox()
                                      : Text(
                                          '${country!.name}',
                                          style: myTextStyleMedium(context),
                                        ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  width: 400,
                                  child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: orgNameController,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Enter Organization Name',
                                                hintStyle:
                                                    myTextStyleSmall(context),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 0.6,
                                                      color: Theme.of(context)
                                                          .primaryColor), //<-- SEE HERE
                                                ),
                                                label: Text(
                                                  'Organization Name',
                                                  style:
                                                      myTextStyleSmall(context),
                                                )),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Organization Name';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          TextFormField(
                                            controller: adminController,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Enter Administrator Name',
                                                hintStyle:
                                                    myTextStyleSmall(context),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 0.6,
                                                      color: Theme.of(context)
                                                          .primaryColor), //<-- SEE HERE
                                                ),
                                                label: Text(
                                                  'Administrator Name',
                                                  style:
                                                      myTextStyleSmall(context),
                                                )),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Administrator Name';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          TextFormField(
                                            controller: phoneController,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Enter CellPhone Number',
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 0.6,
                                                      color: Theme.of(context)
                                                          .primaryColor), //<-- SEE HERE
                                                ),
                                                label: const Text(
                                                    'CellPhone Number')),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Cell Phone Number';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          TextFormField(
                                            controller: emailController,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                                hintText: 'Enter Email Address',
                                                hintStyle:
                                                    myTextStyleSmall(context),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 0.6,
                                                      color: Theme.of(context)
                                                          .primaryColor), //<-- SEE HERE
                                                ),
                                                label: Text(
                                                  'Email Address',
                                                  style:
                                                      myTextStyleSmall(context),
                                                )),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Email address';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          TextFormField(
                                            controller: passwordController,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            decoration: InputDecoration(
                                                hintText: 'Enter Password',
                                                hintStyle:
                                                    myTextStyleSmall(context),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 0.6,
                                                      color: Theme.of(context)
                                                          .primaryColor), //<-- SEE HERE
                                                ),
                                                label: Text(
                                                  'Password',
                                                  style:
                                                      myTextStyleSmall(context),
                                                )),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter password';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 48,
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                _submitRegistration();
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(12.0),
                                                child:
                                                    Text('Submit Registration'),
                                              )),
                                          const SizedBox(
                                            height: 12,
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

////
