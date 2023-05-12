import 'dart:io';

import 'package:badges/badges.dart' as bd;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/bloc/geo_uploader.dart';
import 'package:geo_monitor/library/data/user.dart';
import 'package:geo_monitor/library/generic_functions.dart';
import 'package:geo_monitor/library/users/avatar_editor.dart';
import 'package:geo_monitor/ui/activity/user_profile_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../l10n/translation_handler.dart';
import '../functions.dart';

class UserBatchControl extends StatefulWidget {
  const UserBatchControl({Key? key}) : super(key: key);

  @override
  UserBatchControlState createState() => UserBatchControlState();
}

class UserBatchControlState extends State<UserBatchControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵 UserBatchControl: 🍎';
  User? user;
  var users = <User>[];
  bool busy = false;
  String? uploadMemberBatchFile,
      pickMemberBatchFile,
      memberUploadFailed,
      downloadExampleFiles,
      uploadInstruction;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setTexts();
    _getUser();
  }

  Future _setTexts() async {
    final sett = await prefsOGx.getSettings();
    pickMemberBatchFile =
        await translator.translate('pickMemberBatchFile', sett.locale!);
    memberUploadFailed =
        await translator.translate('memberUploadFailed', sett.locale!);
    downloadExampleFiles =
        await translator.translate('downloadExampleFiles', sett.locale!);
    uploadInstruction =
        await translator.translate('uploadInstruction', sett.locale!);
    uploadMemberBatchFile =
        await translator.translate('uploadMemberBatchFile', sett.locale!);
  }

  void _getUser() async {
    user = await prefsOGx.getUser();
    pp('$mm user: ${user!.toJson()}');
  }

  void _pickFile() async {
    var result =
        await FilePicker.platform.pickFiles(dialogTitle: "Pick Member File");
    if (result == null) {
      return;
    }
    setState(() {
      busy = true;
    });
    if (result.count > 0) {
      try {
        var paths = result.paths;
        if (paths.isNotEmpty) {
          pp('$mm paths from file picker: ${paths!.length}');
          await _startUpload(paths);
        }
      } catch (e) {
        pp(e);
        if (mounted) {
          showToast(
              backgroundColor: Theme.of(context).primaryColor,
              textStyle: myTextStyleMedium(context),
              duration: const Duration(seconds: 3),
              padding: 16,
              message: memberUploadFailed!,
              context: context);
        }
      }
    }
    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  Future<void> _startUpload(List<String?> paths) async {
    pp('$mm  _startUpload ...');
    File file = File(paths.first!);
    users = await geoUploader.startUserBatchUpload(
        organizationId: user!.organizationId!, file: file);
    pp('$mm users uploaded: ${users.length}');
    final sett = await prefsOGx.getSettings();

    for (var mUser in users) {
      switch (mUser.userType) {
        case UserType.orgAdministrator:
          mUser.userType =
              await translator.translate('administrator', sett.locale!);
          break;
        case UserType.fieldMonitor:
          mUser.userType =
              await translator.translate('fieldMonitor', sett.locale!);
          break;
        case UserType.orgExecutive:
          mUser.userType =
              await translator.translate('executive', sett.locale!);
          break;
      }
    }

    pp('$mm  _startUpload completed!');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<void> _navigateToUserProfilePicture(User user) async {
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: const Duration(seconds: 1),
            child: UserProfilePictureEditor(user: user,
                goToDashboardWhenDone: false)));

  }


  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(uploadMemberBatchFile == null
                  ? 'Upload Member File'
                  : uploadMemberBatchFile!),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(180),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 8,
                          shape: getRoundedBorder(radius: 12),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  uploadInstruction == null
                                      ? 'instructions for the administrator'
                                      : uploadInstruction!,
                                  style: myTextStyleSmall(context),
                                ),
                              ),
                              const SizedBox(height: 4,),
                              TextButton(onPressed: (){}, child: Text(downloadExampleFiles == null?
                              'Download Examples':downloadExampleFiles!, style: myTextStyleMediumPrimaryColor(context),))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      )
                    ],
                  )),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: bd.Badge(
                        badgeContent: Text('${users.length}'),
                        badgeAnimation: const bd.BadgeAnimation.slide(),
                        badgeStyle: bd.BadgeStyle(
                            padding: const EdgeInsets.all(12),
                            badgeColor: Theme.of(context).primaryColor),
                        position: bd.BadgePosition.topEnd(end: 32, top: -8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final mUser = users.elementAt(index);
                                return GestureDetector(
                                  onTap: (){
                                    _navigateToUserProfilePicture(mUser);
                                  },
                                  child: UserProfileCard(
                                      userName: mUser.name!,
                                      padding: 0.0,
                                      textStyle: myTextStyleMediumBold(context),
                                      avatarRadius: 16,
                                      namePictureHorizontal: false),
                                );
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                    bottom: 12,
                    right: 12,
                    child: busy
                        ? const SizedBox()
                        : Card(
                            elevation: 8,
                            shape: getRoundedBorder(radius: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _pickFile();
                                },
                                child: Text(pickMemberBatchFile == null
                                    ? 'Pick Member File'
                                    : pickMemberBatchFile!),
                              ),
                            ),
                          )),
                busy
                    ? const Positioned(
                        child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: Colors.pink,
                          ),
                        ),
                      ))
                    : const SizedBox(),
              ],
            )),
      ),
    );
  }
}
