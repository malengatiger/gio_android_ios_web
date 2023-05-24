import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:geo_monitor/l10n/translation_handler.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';

import '../../data/user.dart';
import '../../functions.dart';

class UserListCard extends StatefulWidget {
  const UserListCard(
      {Key? key,
      required this.users,
      required this.deviceUser,
      required this.navigateToPhone,
      required this.navigateToMessaging,
      required this.navigateToUserDashboard,
      required this.navigateToUserEdit,
      required this.navigateToScheduler,
      required this.navigateToKillPage,
      required this.amInLandscape,
      required this.badgeTapped,
      required this.navigateToLocationRequest,
      required this.avatarRadius, required this.subTitle})
      : super(key: key);

  final List<User> users;
  final User deviceUser;
  final bool amInLandscape;
  final double avatarRadius;
  final String subTitle;

  final Function(User) navigateToPhone;
  final Function(User) navigateToMessaging;
  final Function(User) navigateToUserDashboard;

  final Function(User) navigateToUserEdit;
  final Function(User) navigateToScheduler;
  final Function(User) navigateToKillPage;
  final Function(User) navigateToLocationRequest;
  final Function() badgeTapped;

  @override
  State<UserListCard> createState() => _UserListCardState();
}

class _UserListCardState extends State<UserListCard> {
  String? callMember, sendMemberMessage, memberDashboard,editMember,
      requestMemberLocation, fieldMonitorSchedules, removeMember;
  @override
  void initState() {
    super.initState();
    _setTexts();
  }

  void _setTexts() async {
    var sett = await prefsOGx.getSettings();
    callMember = await translator.translate('callMember', sett.locale!);
    sendMemberMessage = await translator.translate('sendMemberMessage', sett.locale!);
    memberDashboard = await translator.translate('memberDashboard', sett.locale!);
    editMember = await translator.translate('editMember', sett.locale!);
    requestMemberLocation = await translator.translate('requestMemberLocation', sett.locale!);
    fieldMonitorSchedules = await translator.translate('fieldMonitorSchedules', sett.locale!);
    removeMember = await translator.translate('removeMember', sett.locale!);
    setState(() {

    });
  }

  List<FocusedMenuItem> _getMenuItems(User someUser, BuildContext context) {
    List<FocusedMenuItem> list = [];

    if (someUser.userId != widget.deviceUser.userId) {
      list.add(FocusedMenuItem(
          title: Text(callMember == null?'Call User': callMember!,
              style: myTextStyleSmallBlack(context)),
          // backgroundColor: Theme.of(context).primaryColor,
          trailingIcon: Icon(
            Icons.phone,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            widget.navigateToPhone(someUser);
          }));
      list.add(FocusedMenuItem(
          title: Text(sendMemberMessage == null?
              'Send Message': sendMemberMessage!,
              style: myTextStyleSmallBlack(context)),
          // backgroundColor: Theme.of(context).primaryColor,
          trailingIcon: Icon(
            Icons.send,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            widget.navigateToMessaging(someUser);
          }));
    }

    if (widget.deviceUser.userType == UserType.fieldMonitor) {
      // pp('$mm Field monitor cannot edit any other users');
    } else {
      list.add(FocusedMenuItem(
          title:
              Text(memberDashboard == null?
                  'Member Dashboard': memberDashboard!,
                  style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.dashboard,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            widget.navigateToUserDashboard(someUser);
          }));
      list.add(FocusedMenuItem(
          title: Text(editMember == null?
            'Edit Member': editMember!,
            style: myTextStyleSmallBlack(context),
          ),
          trailingIcon: Icon(
            Icons.create,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            widget.navigateToUserEdit(someUser);
          }));
    }

    if (widget.deviceUser.userType == UserType.orgAdministrator ||
        widget.deviceUser.userType == UserType.orgExecutive) {
      list.add(FocusedMenuItem(
          title: Text(requestMemberLocation == null?
              'Request Member Location': requestMemberLocation!,
              style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.location_on,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            widget.navigateToLocationRequest(someUser);
          }));
      list.add(FocusedMenuItem(
          title: Text(fieldMonitorSchedules == null?
              'Schedule FieldMonitor': fieldMonitorSchedules!,
              style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            widget.navigateToScheduler(someUser);
          }));
      list.add(FocusedMenuItem(
          title: Text(removeMember == null?
              'Remove User': removeMember!,
              style: myTextStyleSmallBlack(context)),
          trailingIcon: Icon(
            Icons.cut,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            widget.navigateToKillPage(someUser);
          }));
    }
    // }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var color = getTextColorForBackground(Theme.of(context).primaryColor);
    var color2 = getTextColorForBackground(Theme.of(context).primaryColor);

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (!isDarkMode) {
      color = Colors.black;
      color2 = Colors.white;
    } else {
      color = Theme.of(context).primaryColor;
      color2 = Colors.white;

    }
    return Card(
      elevation: 4,
      shape: getRoundedBorder(radius: 16),
      child: Padding(
        padding: widget.amInLandscape
            ? const EdgeInsets.symmetric(horizontal: 12.0)
            : const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 32,
            ),
            Padding(
              padding: const EdgeInsets.only(left:16.0),
              child: Text(
                widget.deviceUser.organizationName!,
                style: myTextStyleMediumWithColor(context, color),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.subTitle,
                  style: myTextStyleSmall(context),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
            SizedBox(
              height: widget.amInLandscape ? 48 : 60,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  widget.badgeTapped();
                },
                child: bd.Badge(
                  badgeContent: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '${widget.users.length}',
                      style: myTextStyleSmallWithColor(context, color2),
                    ),
                  ),
                  badgeStyle: bd.BadgeStyle(
                    badgeColor: Theme.of(context).primaryColor,
                    elevation: 8,
                    padding: const EdgeInsets.all(4),
                  ),
                  position: bd.BadgePosition.topEnd(top: -24, end: 4),
                  child: ListView.builder(
                    itemCount: widget.users.length,
                    itemBuilder: (BuildContext context, int index) {
                      var mUser = widget.users.elementAt(index);
                      DateTime? created;
                      int deltaHours = 0;
                      if (mUser.created != null) {
                        created = DateTime.parse(mUser.created!);
                        var now = DateTime.now();
                        var ms = now.millisecondsSinceEpoch -
                            created.millisecondsSinceEpoch;
                        deltaHours = Duration(milliseconds: ms).inHours;
                      }

                      return FocusedMenuHolder(
                        menuOffset: 20,
                        duration: const Duration(milliseconds: 300),
                        menuItems: _getMenuItems(mUser, context),
                        animateMenuItems: true,
                        openWithTap: true,
                        onPressed: () {
                          pp('💛️💛️💛💛️💛️💛💛️💛️💛️ tapped FocusedMenuHolder ...');
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8),
                                child: Row(
                                  children: [
                                    mUser.thumbnailUrl == null
                                        ? CircleAvatar(
                                            radius: widget.avatarRadius,
                                          )
                                        : CircleAvatar(
                                            radius: widget.avatarRadius,
                                            backgroundImage: NetworkImage(
                                                mUser.thumbnailUrl!),
                                          ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Text(
                                            mUser.name!,
                                            style: myTextStyleSmall(context),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          deltaHours < 4
                                              ? const SizedBox(
                                                  width: 8,
                                                  height: 8,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    backgroundColor:
                                                        Colors.pink,
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
