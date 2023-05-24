import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_monitor/library/users/edit/user_form.dart';
import 'package:geo_monitor/library/users/full_user_photo.dart';
import 'package:page_transition/page_transition.dart';

import '../../../l10n/translation_handler.dart';
import '../../api/prefs_og.dart';
import '../../bloc/fcm_bloc.dart';
import '../../data/country.dart';
import '../../data/settings_model.dart';
import '../../data/user.dart' as ar;
import '../../functions.dart';

class UserEditMobile extends StatefulWidget {
  final ar.User? user;
  const UserEditMobile(this.user, {super.key});

  @override
  UserEditMobileState createState() => UserEditMobileState();
}

class UserEditMobileState extends State<UserEditMobile>
    with SingleTickerProviderStateMixin {
  // var nameController = TextEditingController();
  // var emailController = TextEditingController();
  // var passwordController = TextEditingController();
  // var cellphoneController = TextEditingController();
  ar.User? admin;
  final _key = GlobalKey<ScaffoldState>();
  var isBusy = false;
  Country? country;
  int userType = -1;
  int genderType = -1;
  String? type;
  String? gender;
  String? name, hint, title, newMember, editMember;
  String? countryName,
      userName,
      cellphone,
      male,
      female,
      monitor,
      executive,
      administrator;

  UserFormStrings? userFormStrings;
  late StreamSubscription<SettingsModel> settingsSubscription;

  @override
  void initState() {
    super.initState();
    _listen();
    _setTexts();
    _getAdministrator();
  }

  void _getAdministrator() async {
    admin = await prefsOGx.getUser();
    setState(() {});
  }

  void _setTexts() async {
    var sett = await prefsOGx.getSettings();
    userFormStrings = await UserFormStrings.getTranslated();
    hint = await translator.translate('pleaseSelectCountry', sett.locale!);
    title = await translator.translate('members', sett.locale!);
    newMember = await translator.translate('newMember', sett.locale!);
    editMember = await translator.translate('editMember', sett.locale!);
    name = await translator.translate('name', sett.locale!);
    setState(() {});
  }

  void _listen() async {
    settingsSubscription = fcmBloc.settingsStream.listen((event) async {
      if (country != null) {
        countryName = await translator.translate(country!.name!, event.locale!);
      }
      if (mounted) {
        _setTexts();
      }
    });
  }


  @override
  void dispose() {
    settingsSubscription.cancel();
    super.dispose();
  }

  void _navigateToFullPhoto() async {
    Navigator.of(context).pop();
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 2),
            child: FullUserPhoto(
              user: widget.user!,
            )));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var deviceType = getThisDeviceType();

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);
    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Colors.white;
    }
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(
            title == null ? 'User Editor' : title!, style: myTextStyleLargeWithColor(context, color),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Column(
              children: [
                admin == null
                    ? Container()
                    : const SizedBox(
                        height: 8,
                      ),
                Text(
                  admin == null ? '' : admin!.organizationName!,
                  style: myTextStyleMediumBoldWithColor(context,color),
                ),
                const SizedBox(
                  height: 24,
                )
              ],
            ),
          ),
        ),
        backgroundColor: isDarkMode?Theme.of(context).canvasColor: Colors.brown[50],

        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: UserForm(
                    user: widget.user,
                    width: width,
                    internalPadding: 8.0),
              ),
            ),
            widget.user?.thumbnailUrl == null
                ? const Positioned(
                    right: 2,
                    top: 0,
                    child: CircleAvatar(
                      radius: 24,
                    ))
                : Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: _navigateToFullPhoto,
                      child: CircleAvatar(
                        radius: deviceType == 'phone'?36:48,
                        backgroundImage:
                            NetworkImage(widget.user!.thumbnailUrl!),
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}

class UserFormStrings {
  late String emailAddress,
      selectCountry,
      userName,
      cellphone,
      male,
      female,
      fieldMonitor,
      executive,
      administrator,
      submitMember,
      enterFullName,
      enterEmail,
      enterCell,
      profilePhoto;

  UserFormStrings(
      {required this.userName,
      required this.cellphone,
      required this.male,
      required this.selectCountry,
      required this.emailAddress,
      required this.female,
      required this.fieldMonitor,
      required this.executive,
      required this.administrator,
      required this.enterCell,
      required this.enterEmail,
      required this.enterFullName,
      required this.submitMember,
      required this.profilePhoto});

  static Future<UserFormStrings?> getTranslated() async {
    var sett = await prefsOGx.getSettings();
    var userName = await translator.translate('name', sett.locale!);
    var cellphone = await translator.translate('cellphone', sett.locale!);
    var male = await translator.translate('male', sett.locale!);
    var female = await translator.translate('female', sett.locale!);
    var fieldMonitor = await translator.translate('fieldMonitor', sett.locale!);
    var executive = await translator.translate('executive', sett.locale!);
    var administrator = await translator.translate('administrator', sett.locale!);
    var submitUser = await translator.translate('submitMember', sett.locale!);
    var profilePhoto = await translator.translate('profilePhoto', sett.locale!);
    var enterCell = await translator.translate('enterCell', sett.locale!);
    var enterEmail = await translator.translate('enterEmail', sett.locale!);
    var enterFullName = await translator.translate('enterFullName', sett.locale!);
    var selectCountry = await translator.translate('pleaseSelectCountry', sett.locale!);
    var emailAddress = await translator.translate('emailAddress', sett.locale!);

    var m = UserFormStrings(
        selectCountry: selectCountry,
        emailAddress: emailAddress,
        enterCell: enterCell,
        enterEmail: enterEmail,
        enterFullName: enterFullName,
        userName: userName,
        cellphone: cellphone,
        male: male,
        female: female,
        fieldMonitor: fieldMonitor,
        executive: executive,
        administrator: administrator,
        submitMember: submitUser,
        profilePhoto: profilePhoto);
    return m;
    return null;
  }
}
