import 'package:flutter/material.dart';

import '../library/data/user.dart';
import '../library/functions.dart';

class MemberList extends StatelessWidget {
  final Function(User) onUserTapped;
  final List<User> users;

  const MemberList(
      {super.key,
      required this.onUserTapped,
      required this.users});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
          itemCount: users.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final user = users.elementAt(index);
            return GestureDetector(
                onTap: () {
                  onUserTapped(user);
                },
                child: UserView(user: user, height: 40, width: 140));
          }),
    );
  }
}

class UserView extends StatelessWidget {
  const UserView(
      {Key? key, required this.user, required this.height, required this.width})
      : super(key: key);
  final User user;
  final double height, width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        shape: getRoundedBorder(radius: 10),
        elevation: 4,
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            user.thumbnailUrl == null
                ? const CircleAvatar(
                    radius: 40,
                    child: Icon(
                      Icons.person,
                      size: 36,
                    ),
                  )
                : CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      user.thumbnailUrl!,
                    ),
                  ),
            const SizedBox(
              height: 16,
            ),
            Flexible(
              child: Text(
                '${user.name}',
                overflow: TextOverflow.ellipsis,
                style: myTextStyleTinyPrimaryColor(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
