import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:geo_monitor/library/emojis.dart';
import 'package:geo_monitor/library/generic_functions.dart';

import '../api/data_api_og.dart';
import '../api/prefs_og.dart';
import '../data/user.dart';
import '../functions.dart';

class KillUserPage extends StatefulWidget {
  const KillUserPage({Key? key, required this.user}) : super(key: key);

  final User user;
  @override
  KillUserPageState createState() => KillUserPageState();
}

class KillUserPageState extends State<KillUserPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final mm =
      '${E.redDot}${E.redDot}${E.redDot}${E.redDot} KillUserPage: ';
  bool busy = false;
  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.0,
        duration: const Duration(milliseconds: 2000),
        reverseDuration: const Duration(milliseconds: 1000),
        vsync: this);
    super.initState();
    _animate();
  }

  void _animate() {
    Future.delayed(const Duration(milliseconds: 200), (){
      _animationController.forward();
    });
  }

  void _sendKillRequest() async {
    pp('$mm sending kill request for ${widget.user.name!}');
    var killer = await prefsOGx.getUser();
    setState(() {
      busy = true;
    });
    try {
      var res = await dataApiDog.killUser(
          userId: widget.user.userId!, killerId: killer!.userId!);
      pp('\n$mm ... someone has gotten killed! ${res.toJson()}\n');
      if (mounted) {
        showToast(
            duration: const Duration(seconds: 5),
            backgroundColor: Theme.of(context).primaryColor,
            message: 'Request to remove user completed',
            context: context);
        //bye!
        _animationController.reverse().then((value) {
          Navigator.of(context).pop();
        });

      }
    } catch (e) {
      pp(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Kill user failed: $e')));
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'User Removal',
          style: myTextStyleSmall(context),
        ),
      ),
      body: Stack(
        children: [
          const SizedBox(height: 100,),
          AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget? child) {
              return FadeScaleTransition(animation: _animationController, child: child,);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: getRoundedBorder(radius: 16),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      Text(
                        widget.user.organizationName!,
                        style: myTextStyleMediumBold(context),
                      ),
                      const SizedBox(
                        height: 36,
                      ),
                      Text(
                        'You are about to permanently remove this user from the organization! ',
                        style: myTextStyleMedium(context),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const SizedBox(
                        height: 36,
                      ),
                      Text(
                        widget.user.name!,
                        style: myTextStyleLargePrimaryColor(context),
                      ),
                      const SizedBox(
                        height: 36,
                      ),
                      Text(
                        'If you are sure, please press the button below.',
                        style: myTextStyleMedium(context),
                      ),
                      const SizedBox(
                        height: 24,
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
                          : ElevatedButton(
                              onPressed: _sendKillRequest,
                              child: const Text('Remove User')),
                      const SizedBox(
                        height: 24,
                      ),
                      TextButton(onPressed: (){
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }, child: const Text('Cancel')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
