import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/data_refresher.dart';
import 'package:geo_monitor/library/bloc/organization_bloc.dart';
import 'package:geo_monitor/library/bloc/theme_bloc.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/functions.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/data_api_og.dart';
import '../../library/generic_functions.dart';

class AuthEmailSignIn extends StatefulWidget {
  const AuthEmailSignIn(
      {Key? key,
      required this.showHeader,
      required this.externalPadding,
      required this.internalPadding,
      required this.onSignedIn,
      required this.onError})
      : super(key: key);

  final bool showHeader;
  final double externalPadding;
  final double internalPadding;
  final Function onSignedIn;
  final Function(String) onError;

  @override
  State<AuthEmailSignIn> createState() => AuthEmailSignInState();
}

class AuthEmailSignInState extends State<AuthEmailSignIn> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;
  bool busy = false;

  String? signInText,
      enterEmail,
      signInFailed,
      signedInOK,
      notFound,
      emailAddress,
      enterPassword,
      emailAuth,
      password;

  SettingsModel? settingsModel;

  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  Future _setTexts() async {
    settingsModel = await prefsOGx.getSettings();
      settingsModel =getBaseSettings();
      await prefsOGx.saveSettings(settingsModel!);

    signInText = await translator.translate('signIn', settingsModel!.locale!);
    enterEmail = await translator.translate('enterEmail', settingsModel!.locale!);
    emailAddress = await translator.translate('emailAddress', settingsModel!.locale!);
    enterPassword =
        await translator.translate('enterPassword', settingsModel!.locale!);
    password = await translator.translate('password', settingsModel!.locale!);
    signInFailed = await translator.translate('signInFailed', settingsModel!.locale!);
    signedInOK = await translator.translate('signedInOK', settingsModel!.locale!);
    notFound = await translator.translate('memberNotExist', settingsModel!.locale!);

    emailAuth = await translator.translate('emailAuth', settingsModel!.locale!);

    setState(() {});
  }

  void _submitSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      busy = true;
    });

    try {
      var email = emailController.value.text;
      var password = passwordController.value.text;
      var userCred = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCred.user != null) {
        var user = await dataApiDog.getUserById(userId: userCred.user!.uid);
        if (user != null) {
          await prefsOGx.saveUser(user);
          var map = await getStartEndDates();
          final startDate = map['startDate'];
          final endDate = map['endDate'];
          await organizationBloc.getOrganizationData(
              organizationId: user.organizationId!,
              forceRefresh: true,
              startDate: startDate!,
              endDate: endDate!);
          var settingsList =
              await dataApiDog.getOrganizationSettings(user.organizationId!);
          settingsList.sort((a, b) => b.created!.compareTo(a.created!));

          await prefsOGx.saveSettings(settingsList.first);
          await themeBloc.changeToTheme(settingsList.first.themeIndex!);
          String? txt =
              await translator.translate('memberSignedIn', settingsList.first.locale!);
          String? notFound =
              await translator.translate('memberNotExist', settingsList.first.locale!);

          dataRefresher.manageRefresh(numberOfDays:  settingsList.first.numberOfDays!,
              organizationId:  settingsList.first.organizationId!,
              projectId: null, userId: null);

          if (mounted) {
            showToast(
                message: txt == null ? 'Member sign in succeeded' : txt!,
                context: context);

            widget.onSignedIn();
          }
        } else {
          if (mounted) {
            showToast(
                message: notFound == null ? 'Member not found' : notFound!,
                context: context);
          }
        }
      } else {
        if (mounted) {
          showToast(message: 'Member authentication failed', context: context);
        }
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showToast(message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
            child: Padding(
          padding: EdgeInsets.all(
              widget.externalPadding == null ? 64.0 : widget.externalPadding!),
          child: Card(
            elevation: 4,
            shape: getRoundedBorder(radius: 16),
            child: Padding(
              padding: EdgeInsets.all(widget.internalPadding == null
                  ? 100.0
                  : widget.internalPadding!),
              child: Column(
                children: [
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 32,
                          ),
                          Text(
                            emailAuth == null
                                ? 'Email Authentication'
                                : emailAuth!,
                            style: myTextStyleMediumBold(context),
                          ),
                          const SizedBox(
                            height: 48,
                          ),
                          SizedBox(
                            width: 400,
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  hintText: enterEmail == null
                                      ? 'Enter Email Address'
                                      : enterEmail!,
                                  hintStyle: myTextStyleSmall(context),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 0.6,
                                        color: Theme.of(context)
                                            .primaryColor), //<-- SEE HERE
                                  ),
                                  label: Text(
                                    emailAddress == null
                                        ? 'Email Address'
                                        : emailAddress!,
                                    style: myTextStyleSmall(context),
                                  )),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return enterEmail == null
                                      ? 'Please enter Email address'
                                      : enterEmail!;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 400,
                            child: TextFormField(
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  hintText: enterPassword == null
                                      ? 'Enter Password'
                                      : enterPassword,
                                  hintStyle: myTextStyleSmall(context),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 0.6,
                                        color: Theme.of(context)
                                            .primaryColor), //<-- SEE HERE
                                  ),
                                  label: Text(
                                    password == null ? 'Password' : password!,
                                    style: myTextStyleSmall(context),
                                  )),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return enterPassword == null
                                      ? 'Please enter password'
                                      : enterPassword!;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    backgroundColor: Colors.pink,
                                  ),
                                )
                              : SizedBox(
                                  width: 200,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        _submitSignIn();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(signInText == null
                                            ? 'Sign In'
                                            : signInText!),
                                      )),
                                ),
                          const SizedBox(
                            height: 48,
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ))
      ],
    );
  }
}
