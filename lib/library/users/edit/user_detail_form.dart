import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geo_monitor/library/bloc/fcm_bloc.dart';
import 'package:geo_monitor/library/data/country.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/errors/error_handler.dart';
import 'package:geo_monitor/library/users/edit/user_edit_mobile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/translation_handler.dart';

import '../../api/data_api_og.dart';
import '../../api/prefs_og.dart';
import '../../bloc/geo_exception.dart';
import '../../bloc/organization_bloc.dart';
import '../../cache_manager.dart';
import '../../data/user.dart' as ar;
import '../../data/user.dart';
import '../../functions.dart';
import '../../generic_functions.dart';
import '../avatar_editor.dart';
import '../full_user_photo.dart';
import 'country_chooser.dart';

class UserDetailForm extends StatefulWidget {
  const UserDetailForm({
    Key? key,
    this.user,
    required this.width,
    required this.internalPadding,
  }) : super(key: key);

  final ar.User? user;
  final double width, internalPadding;

  @override
  State<UserDetailForm> createState() => UserDetailFormState();
}

class UserDetailFormState extends State<UserDetailForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var cellphoneController = TextEditingController();
  ar.User? admin;
  final _formKey = GlobalKey<FormState>();
  var isBusy = false;
  Country? country;
  int userType = -1;
  int genderType = -1;
  String? type;
  String? gender, translatedCountryName,
      memberUpdateFailed,memberCreateFailed,
      pleaseSelectGender, pleaseSelectType, memberCreated,
      pleaseSelectCountry;

  UserFormStrings? userFormStrings;
  SettingsModel? settingsModel;
  late StreamSubscription<SettingsModel> settingsSubscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setup();
    _setTexts();
  }

  void _setTexts() async {
    admin = await prefsOGx.getUser();
    settingsModel = await prefsOGx.getSettings();
    userFormStrings = await UserFormStrings.getTranslated();
    pleaseSelectCountry = await translator.translate('pleaseSelectCountry',
        settingsModel!.locale!);
    memberUpdateFailed = await translator.translate('memberUpdateFailed',
        settingsModel!.locale!);
    memberCreateFailed = await translator.translate('memberCreateFailed',
        settingsModel!.locale!);
    pleaseSelectCountry = await translator.translate('pleaseSelectCountry',
        settingsModel!.locale!);
    pleaseSelectGender = await translator.translate('pleaseSelectGender',
        settingsModel!.locale!);
    pleaseSelectType = await translator.translate('pleaseSelectType',
        settingsModel!.locale!);
    memberCreated = await translator.translate('memberCreated',
        settingsModel!.locale!);

    setState(() {});
  }

  Future<void> _setup() async {
    if (widget.user != null) {
      nameController.text = widget.user!.name!;
      emailController.text = widget.user!.email!;
      cellphoneController.text = widget.user!.cellphone!;
      _setTypeRadio();
      _setGenderRadio();
      await _setCountry();
    }
  }
  void _setTypeRadio() {
    if (widget.user != null) {
      if (widget.user!.userType == UserType.fieldMonitor) {
        type = UserType.fieldMonitor;
        userType = 0;
      }
      if (widget.user!.userType == UserType.orgAdministrator) {
        type = UserType.orgAdministrator;
        userType = 1;
      }
      if (widget.user!.userType == UserType.orgExecutive) {
        type = UserType.orgExecutive;
        userType = 2;
      }
    }
  }

  void _setGenderRadio() {
    if (widget.user != null) {
      if (widget.user!.gender != null) {
        gender = widget.user!.gender!;
        switch (widget.user!.gender) {
          case 'Male':
            genderType = 0;
            break;
          case 'Female':
            genderType = 1;
            break;
        }
      }
    }
  }

  Future _setCountry() async {
    if (widget.user != null) {
      if (widget.user!.countryId != null) {
        var countries = await cacheManager.getCountries();
        var sett = await prefsOGx.getSettings();
        for (var value in countries) {
          if (widget.user!.countryId == value.countryId) {
            translatedCountryName = await translator.translate(value.name!, sett!.locale!);
            country = value;
          }
        }
      }
    }
  }

  void _listen() async {
    settingsSubscription = fcmBloc.settingsStream.listen((event) async {
      if (country != null) {
        translatedCountryName = await translator.translate(country!.name!, event.locale!);
      }
      if (mounted) {
        _setTexts();
        setState(() {
          refreshCountries = !refreshCountries;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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

  bool refreshCountries = false;

  @override
  Widget build(BuildContext context) {
    var spaceToButtons = 0.0;
    var spaceToTop = 0.0;
    var ori = MediaQuery.of(context).orientation;
    if (ori.name == 'portrait') {
      spaceToButtons = 20;
      spaceToTop = 24;
    } else {
      spaceToButtons = 20;
      spaceToTop = 12;
    }
    return SizedBox(
      width: widget.width,
      child: Card(
        elevation: 8.0,
        shape: getRoundedBorder(radius: 16),
        child: Padding(
          padding: EdgeInsets.all(widget.internalPadding),
          child: userFormStrings == null
              ? const SizedBox()
              : Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: spaceToTop,
                  ),
                  TextFormField(
                    readOnly: true,
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    style: myTextStyleSmall(context),
                    decoration: InputDecoration(
                        icon: Icon(
                          Icons.person,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelText: userFormStrings!.userName,
                        hintStyle: myTextStyleSmall(context),
                        hintText: userFormStrings!.enterFullName),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return userFormStrings!.enterFullName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    readOnly: true,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: myTextStyleSmall(context),
                    decoration: InputDecoration(
                        icon: Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelText: userFormStrings!.emailAddress,
                        hintStyle: myTextStyleSmall(context),
                        hintText: userFormStrings!.enterEmail),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return userFormStrings!.enterEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  TextFormField(
                    readOnly: true,
                    controller: cellphoneController,
                    keyboardType: TextInputType.phone,
                    style: myTextStyleSmall(context),
                    decoration: InputDecoration(
                        icon: Icon(
                          Icons.phone,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelText: userFormStrings!.cellphone,
                        hintStyle: myTextStyleSmall(context),
                        hintText: userFormStrings!.enterCell),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return userFormStrings!.enterCell;
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: spaceToButtons,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Radio(
                        toggleable: false,
                        value: 0,
                        groupValue: genderType,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value){},
                      ),
                      Text(
                        userFormStrings!.male,
                        style: myTextStyleSmall(context),
                      ),
                      Radio(
                        toggleable: false,
                        value: 1,
                        groupValue: genderType,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value){},
                      ),
                      Text(userFormStrings!.female,
                          style: myTextStyleSmall(context)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Radio(
                            value: 0,
                            toggleable: false,
                            groupValue: userType,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value){},
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            userFormStrings!.fieldMonitor,
                            style: myTextStyleSmall(context),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            toggleable: false,
                            value: 1,
                            groupValue: userType,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value){},
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(userFormStrings!.administrator,
                              style: myTextStyleSmall(context)),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            toggleable: false,
                            value: 2,
                            groupValue: userType,
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value){},
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            userFormStrings!.executive,
                            style: myTextStyleSmall(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  SizedBox(
                    height: spaceToButtons,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
