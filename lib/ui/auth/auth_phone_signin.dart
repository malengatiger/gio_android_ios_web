import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/bloc/isolate_handler.dart';
import 'package:geo_monitor/library/data/settings_model.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

import '../../l10n/translation_handler.dart';
import '../../library/api/prefs_og.dart';
import '../../library/bloc/theme_bloc.dart';
import '../../library/cache_manager.dart';
import '../../library/data/country.dart';
import '../../library/data/user.dart' as ur;
import '../../library/functions.dart';

class AuthPhoneSignIn extends StatefulWidget {
  const AuthPhoneSignIn({
    Key? key,
    required this.onSignedIn,
    required this.onError,
    required this.prefsOGx,
    required this.dataApiDog,
    required this.cacheManager,
  }) : super(key: key);

  final Function(ur.User) onSignedIn;
  final Function(String) onError;
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;
  @override
  AuthPhoneSignInState createState() => AuthPhoneSignInState();
}

class AuthPhoneSignInState extends State<AuthPhoneSignIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final mm = '🥬🥬🥬🥬🥬🥬 AuthPhoneSignIn: ';
  String? phoneVerificationId;
  String? code;
  final phoneController = TextEditingController(text: "+19985550000");
  final codeController = TextEditingController(text: '123456');
  final orgNameController = TextEditingController();
  final adminController = TextEditingController();
  final errorController = StreamController<ErrorAnimationType>();
  String? currentText;
  bool verificationFailed = false;
  bool verificationCompleted = false;
  bool busy = false;
  ur.User? user;
  SignInStrings? signInStrings;
  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 2000),
        reverseDuration: const Duration(milliseconds: 2000),
        vsync: this);
    super.initState();
    _setTexts();
  }

  Future _setTexts() async {
    final sett = await widget.prefsOGx.getSettings();
    signInStrings = await SignInStrings.getTranslated(sett);
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToAvatarBuilder() async {
    Navigator.of(context).pop(user!);
    pp('$mm _navigateToAvatarBuilder .... after popping current page  🍎🍎');
    // Navigator.push(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.scale,
    //         alignment: Alignment.topLeft,
    //         duration: const Duration(seconds: 1),
    //         child: UserProfilePictureEditor(
    //           user: user!,
    //           goToDashboardWhenDone: true,
    //         )));
  }

  void _onSignedIn(ur.User user) async {
    dataHandler.getOrganizationData();
    if (mounted) {
      Navigator.of(context).pop(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = getThisDeviceType();
    if (deviceType == 'phone') {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: Text(
            signInStrings == null ? 'Phone SignIn' : signInStrings!.phoneSignIn,
            style: myTextStyleMedium(context),
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100.0),
              child: Column(
                children: const [
                  SizedBox(),
                ],
              )),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AuthPhoneSigninCard(
                  prefsOGx: widget.prefsOGx,
                  cacheManager: widget.cacheManager,
                  dataApiDog: widget.dataApiDog,
                  showAvatarBuilder: () {
                    _navigateToAvatarBuilder();
                  },
                  width: MediaQuery.of(context).size.width,
                  onSuccessfulSignIn: (ur.User user) {
                    _onSignedIn(user);
                  },
                ),
              ),
            )
          ],
        ),
      ));
    } else {
      return AuthPhoneSigninCard(
        dataApiDog: widget.dataApiDog,
        cacheManager: widget.cacheManager,
        prefsOGx: widget.prefsOGx,
        width: 500,
        showAvatarBuilder: () {},
        onSuccessfulSignIn: (ur.User user) {
          widget.onSignedIn(user);
        },
      );
    }
  }
}

class AuthPhoneSigninCard extends StatefulWidget {
  const AuthPhoneSigninCard(
      {Key? key,
      required this.showAvatarBuilder,
      required this.width,
      required this.onSuccessfulSignIn,
      required this.prefsOGx,
      required this.dataApiDog,
      required this.cacheManager})
      : super(key: key);

  final Function showAvatarBuilder;
  final Function(ur.User user) onSuccessfulSignIn;
  final double width;
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final CacheManager cacheManager;

  @override
  State<AuthPhoneSigninCard> createState() => _AuthPhoneSigninCardState();
}

class _AuthPhoneSigninCardState extends State<AuthPhoneSigninCard> {
  final _formKey = GlobalKey<FormState>();
  bool _codeHasBeenSent = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final mm = '🥬🥬🥬🥬🥬🥬 AuthPhoneSignInMobile: ';
  String? phoneVerificationId;
  String? code;
  final phoneController = TextEditingController(text: "+19985550000");
  final codeController = TextEditingController(text: '123456');
  final orgNameController = TextEditingController();
  final adminController = TextEditingController();
  final errorController = StreamController<ErrorAnimationType>();
  String? currentText;
  bool verificationFailed = false;
  bool verificationCompleted = false;
  bool busy = false;
  ur.User? user;
  SignInStrings? signInStrings;

  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  Future _setTexts() async {
    final sett = await widget.prefsOGx.getSettings();
    signInStrings = await SignInStrings.getTranslated(sett);
    setState(() {});
  }

  void _processSignIn() async {
    pp('\n\n$mm _processSignIn ... sign in the user using code: ${codeController.value.text}');
    setState(() {
      busy = true;
    });
    code = codeController.value.text;

    if (code == null || code!.isEmpty) {
      showSnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).primaryColor,
          textStyle: myTextStyleMedium(context),
          message: signInStrings == null
              ? 'Please put in the code that was sent to you'
              : signInStrings!.putInCode,
          context: context);
      setState(() {
        busy = false;
      });
      return;
    }
    UserCredential? userCred;
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: phoneVerificationId!, smsCode: code!);
      userCred = await firebaseAuth.signInWithCredential(authCredential);
      pp('\n$mm user signed in to firebase? userCred: $userCred');
      pp('$mm seeking to acquire this user from the Geo database by their id: 🌀🌀🌀${userCred.user?.uid}');
      user = await widget.dataApiDog.getUserById(userId: userCred.user!.uid);

      if (user != null) {
        pp('$mm Gio user found on database:  🍎 ${user!.name!} 🍎');
        final org =
        await widget.dataApiDog.getOrganization(user!.organizationId!);
        final countries = await widget.dataApiDog.getCountries();
        Country? myCountry;
        for (var country in countries) {
          await widget.cacheManager.addCountry(country: country);
          if (country.countryId == org!.countryId!) {
            myCountry = country;
            await widget.prefsOGx.saveCountry(myCountry);
            user!.countryId = myCountry.countryId!;
          }
        }
        await widget.prefsOGx.saveUser(user!);
        await widget.cacheManager.addUser(user: user!);
        var settingsList = await widget.dataApiDog
            .getOrganizationSettings(user!.organizationId!);
        settingsList.sort((a, b) => b.created!.compareTo(a.created!));
        await themeBloc.changeToTheme(settingsList.first.themeIndex!);
        if (settingsList.isEmpty) {
          var sett = getBaseSettings();
          sett.organizationId = user!.organizationId!;
          await widget.prefsOGx.saveSettings(sett);
          await widget.dataApiDog.addSettings(sett);
          await themeBloc.changeToTheme(0);
          await themeBloc.changeToLocale(sett.locale!);
        } else {
          await widget.prefsOGx.saveSettings(settingsList.first);
          await themeBloc.changeToTheme(settingsList.first.themeIndex!);
          await themeBloc.changeToLocale(settingsList.first.locale!);
        }
        setState(() {
          busy = false;
        });
        if (mounted) {
          showSnackBar(
              message: signInStrings == null
                  ? '${user!.name} has been signed in'
                  : signInStrings!.memberSignedIn,
              backgroundColor: Theme.of(context).primaryColorDark,
              context: context);
        }
        widget.onSuccessfulSignIn(user!);
        return;
      }
    } catch (e) {
      pp('\n\n\n .... $e \n\n\n');
      String msg = '$e';
      if (msg.contains('dup key')) {
        msg = signInStrings == null
            ? 'Duplicate organization name'
            : signInStrings!.duplicateOrg;
      }
      if (msg.contains('not found')) {
        msg = signInStrings == null
            ? 'User not found'
            : signInStrings!.memberNotExist;
      }
      if (msg.contains('Bad response format')) {
        msg = signInStrings == null
            ? 'User not found'
            : signInStrings!.memberNotExist;
      }
      if (msg.contains('server cannot be reached')) {
        msg = signInStrings == null
            ? 'Server cannot be reached'
            : signInStrings!.serverUnreachable;
      }
      pp(msg);
      if (mounted) {
        showSnackBar(
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.pink.shade700,
            textStyle: myTextStyleMedium(context),
            padding: 20.0,
            message: msg,
            context: context);
        setState(() {
          busy = false;
        });
      }
      return;
    }
  }

  void _start() async {
    pp('$mm _start: ....... Verifying phone number ...');
    setState(() {
      busy = true;
    });

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneController.value.text,
        timeout: const Duration(seconds: 90),
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
          pp('$mm verificationCompleted: $phoneAuthCredential');
          var message = phoneAuthCredential.smsCode ?? "";
          if (message.isNotEmpty) {
            codeController.text = message;
          }
          if (mounted) {
            setState(() {
              verificationCompleted = true;
              busy = false;
            });
            showSnackBar(
                backgroundColor: Theme.of(context).colorScheme.background,
                textStyle: myTextStyleMedium(context),
                message: signInStrings == null
                    ? 'Verification completed. Thank you!'
                    : signInStrings!.verifyComplete!,
                context: context);
          }
        },
        verificationFailed: (FirebaseAuthException error) {
          pp('\n$mm verificationFailed : $error \n');
          if (mounted) {
            setState(() {
              verificationFailed = true;
              busy = false;
            });
            showSnackBar(
                backgroundColor: Theme.of(context).colorScheme.background,
                textStyle: myTextStyleMedium(context),
                message: signInStrings == null
                    ? 'Verification failed. Please try later'
                    : signInStrings!.verifyFailed,
                context: context);
          }
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          pp('$mm onCodeSent: 🔵 verificationId: $verificationId 🔵 will set state ...');
          phoneVerificationId = verificationId;
          if (mounted) {
            pp('$mm setting state  _codeHasBeenSent to true');
            setState(() {
              _codeHasBeenSent = true;
              busy = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          pp('$mm codeAutoRetrievalTimeout verificationId: $verificationId');
          if (mounted) {
            setState(() {
              busy = false;
              _codeHasBeenSent = false;
            });
            showSnackBar(
                message: signInStrings == null
                    ? 'Code retrieval failed, please try again'
                    : signInStrings!.verifyFailed,
                context: context);
            Navigator.of(context).pop();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: getRoundedBorder(radius: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
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
                height: 24,
              ),
              SizedBox(
                width: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      signInStrings == null
                          ? 'Phone Authentication'
                          : signInStrings!.phoneAuth,
                      style: myTextStyleMediumBold(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          width: 400,
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                hintText: signInStrings == null
                                    ? 'Enter Phone Number'
                                    : signInStrings!.enterPhone,
                                label: Text(signInStrings == null
                                    ? 'Phone Number'
                                    : signInStrings!.phoneNumber)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return signInStrings == null
                                    ? 'Please enter Phone Number'
                                    : signInStrings!.enterPhone;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _start();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(signInStrings == null
                                  ? 'Verify Phone Number'
                                  : signInStrings!.verifyPhone),
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        _codeHasBeenSent
                            ? SizedBox(
                                height: 200,
                                child: Column(
                                  children: [
                                    Text(
                                      signInStrings == null
                                          ? 'Enter SMS pin code sent'
                                          : signInStrings!.enterSMS,
                                      style: myTextStyleSmall(context),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: PinCodeTextField(
                                        length: 6,
                                        obscureText: false,
                                        textStyle: myNumberStyleLarge(context),
                                        animationType: AnimationType.fade,
                                        pinTheme: PinTheme(
                                          shape: PinCodeFieldShape.box,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          fieldHeight: 50,
                                          fieldWidth: 40,
                                          activeFillColor: Theme.of(context)
                                              .colorScheme
                                              .background,
                                        ),
                                        animationDuration:
                                            const Duration(milliseconds: 300),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        enableActiveFill: true,
                                        errorAnimationController:
                                            errorController,
                                        controller: codeController,
                                        onCompleted: (v) {
                                          pp("$mm PinCodeTextField: Completed: $v - should call submit ...");
                                        },
                                        onChanged: (value) {
                                          pp(value);
                                          setState(() {
                                            currentText = value;
                                          });
                                        },
                                        beforeTextPaste: (text) {
                                          pp("$mm Allowing to paste $text");
                                          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                          //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                          return true;
                                        },
                                        appContext: context,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 28,
                                    ),
                                    busy
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 4,
                                              backgroundColor: Colors.pink,
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: _processSignIn,
                                            style: ButtonStyle(
                                              elevation: MaterialStateProperty
                                                  .all<double>(8.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(signInStrings == null
                                                  ? 'Send Code'
                                                  : signInStrings!.sendCode),
                                            )),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SignInStrings {
  late String signIn,
      memberSignedIn,
      putInCode,
      duplicateOrg,
      enterPhone,
      serverUnreachable,
      phoneSignIn,
      phoneAuth,
      phoneNumber,
      verifyPhone,
      enterSMS,
      sendCode,
      verifyComplete,
      verifyFailed,
      enterOrg,
      orgName,
      enterAdmin,
      adminName,
      enterEmail,
      pleaseSelectCountry,
      memberNotExist,
      registerOrganization,
      signInOK,
      enterPassword,
      password,
      emailAddress;

  SignInStrings(
      {required this.signIn,
      required this.memberSignedIn,
      required this.putInCode,
      required this.duplicateOrg,
      required this.enterPhone,
      required this.serverUnreachable,
      required this.phoneSignIn,
      required this.phoneAuth,
      required this.phoneNumber,
      required this.verifyPhone,
      required this.enterSMS,
      required this.sendCode,
      required this.registerOrganization,
      required this.verifyComplete,
      required this.verifyFailed,
      required this.enterOrg,
      required this.orgName,
      required this.enterAdmin,
      required this.adminName,
      required this.memberNotExist,
      required this.enterEmail,
      required this.pleaseSelectCountry,
      required this.signInOK,
      required this.enterPassword,
      required this.password,
      required this.emailAddress});

  static Future<SignInStrings> getTranslated(SettingsModel sett) async {
    var signIn = await translator.translate('signIn', sett!.locale!);
    var memberNotExist =
        await translator.translate('memberNotExist', sett.locale!);
    var memberSignedIn =
        await translator.translate('memberSignedIn', sett.locale!);
    var putInCode = await translator.translate('putInCode', sett.locale!);
    var duplicateOrg = await translator.translate('duplicateOrg', sett.locale!);
    var pleaseSelectCountry =
        await translator.translate('pleaseSelectCountry', sett.locale!);

    var registerOrganization =
        await translator.translate('registerOrganization', sett.locale!);

    var enterPhone = await translator.translate('enterPhone', sett.locale!);
    var signInOK = await translator.translate('signInOK', sett.locale!);

    var enterPassword =
        await translator.translate('enterPassword', sett.locale!);

    var password = await translator.translate('password', sett.locale!);

    var serverUnreachable =
        await translator.translate('serverUnreachable', sett.locale!);
    var phoneSignIn = await translator.translate('phoneSignIn', sett.locale!);
    var phoneAuth = await translator.translate('phoneAuth', sett.locale!);
    var phoneNumber = await translator.translate('phoneNumber', sett.locale!);
    var verifyPhone = await translator.translate('verifyPhone', sett.locale!);
    var enterSMS = await translator.translate('enterSMS', sett.locale!);
    var sendCode = await translator.translate('sendCode', sett.locale!);
    var verifyComplete =
        await translator.translate('verifyComplete', sett.locale!);
    var verifyFailed = await translator.translate('verifyFailed', sett.locale!);
    var enterOrg = await translator.translate('enterOrg', sett.locale!);
    var orgName = await translator.translate('orgName', sett.locale!);
    var enterAdmin = await translator.translate('enterAdmin', sett.locale!);
    var adminName = await translator.translate('adminName', sett.locale!);
    var enterEmail = await translator.translate('enterEmail', sett.locale!);
    var emailAddress = await translator.translate('emailAddress', sett.locale!);

    final m = SignInStrings(
        signIn: signIn,
        signInOK: signInOK,
        password: password,
        enterPassword: enterPassword,
        memberSignedIn: memberSignedIn,
        putInCode: putInCode,
        duplicateOrg: duplicateOrg,
        enterPhone: enterPhone,
        serverUnreachable: serverUnreachable,
        phoneSignIn: phoneSignIn,
        phoneAuth: phoneAuth,
        pleaseSelectCountry: pleaseSelectCountry,
        phoneNumber: phoneNumber,
        verifyPhone: verifyPhone,
        enterSMS: enterSMS,
        sendCode: sendCode,
        registerOrganization: registerOrganization,
        verifyComplete: verifyComplete,
        verifyFailed: verifyFailed,
        enterOrg: enterOrg,
        orgName: orgName,
        enterAdmin: enterAdmin,
        adminName: adminName,
        enterEmail: enterEmail,
        memberNotExist: memberNotExist,
        emailAddress: emailAddress);

    return m;
  }
}
