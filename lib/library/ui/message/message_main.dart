import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../data/user.dart';
import 'message_desktop.dart';
import 'message_mobile.dart';
import 'message_tablet.dart';
class MessageMain extends StatefulWidget {
  final User? user;
  const MessageMain({Key? key,this.user}) : super(key: key);

  @override
  MessageMainState createState() => MessageMainState();
}

class MessageMainState extends State<MessageMain> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: MessageMobile(
        user: widget.user,
      ),
      tablet: MessageTablet(
        user: widget.user,
      ),
      desktop: MessageDesktop(
        user: widget.user,
      ),
    );
  }
}
