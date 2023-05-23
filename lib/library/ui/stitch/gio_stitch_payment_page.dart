import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/data/stitch/amount.dart';
import 'package:geo_monitor/library/data/stitch/payment_request.dart';
import 'package:geo_monitor/stitch/stitch_service.dart';
import 'package:geo_monitor/ui/subscription/stitch_web_viewer.dart';
import 'package:geo_monitor/utilities/transitions.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../data/user.dart';
import '../../functions.dart';

class GioStitchPaymentPage extends StatefulWidget {
  const GioStitchPaymentPage(
      {Key? key,
      required this.stitchService,
      required this.prefsOGx,
      required this.title,
      required this.amount, required this.dataApiDog})
      : super(key: key);

  final StitchService stitchService;
  final PrefsOGx prefsOGx;
  final String title;
  final int amount;
  final DataApiDog dataApiDog;

  @override
  GioStitchPaymentPageState createState() => GioStitchPaymentPageState();
}

class GioStitchPaymentPageState extends State<GioStitchPaymentPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final mm = '🍐🍐🍐🍐🍐🍐🍐🔵🔵 GioStitchPaymentPage: ✅';

  String? token;
  bool busy = false;
  bool busy2 = false;
  late SettingsModel settings;
  User? user;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getToken();
  }

  Future _getToken() async {
    setState(() {
      busy = true;
    });
    try {
      settings = await widget.prefsOGx.getSettings();
      user = await widget.prefsOGx.getUser();
      token = await widget.stitchService.getToken();
      pp('$mm token from Stitch: $token');
    } catch (e) {
      pp(e);
      showSnackBar(message: '$e', context: context);
    }

    setState(() {
      busy = false;
    });
  }
  GioPaymentRequest? gioPaymentRequest;

  Future _getPaymentRequest() async {
    pp('$mm _getPaymentRequest, token: $token');
    setState(() {
      busy2 = true;
    });
    try {
      gioPaymentRequest = GioPaymentRequest(
          amount: Amount(quantity: widget.amount, currency: 'ZAR'),
          payerReference: 'Gio Services',
          externalReference: settings.organizationId,
          beneficiaryAccountNumber: '123456789',
          beneficiaryBankId: 'fnb',
          beneficiaryReference: settings.organizationId,
          merchant: 'merchant_id_here',
          beneficiaryName: user!.organizationName);
      pp('$mm _getPaymentRequest, request: ${gioPaymentRequest!.toJson()}');
      var result =
          await widget.stitchService.sendGraphQlPaymentRequest(gioPaymentRequest!, token!);
      pp('$mm back in the land of the living, id: ${result['id']} url: ${result['url']}');
      _navigateToWebView(result['id'], result['url']);
    } catch (e) {
      pp(e);
      showSnackBar(message: '$e', context: context);
    }
    setState(() {
      busy2 = false;
    });
  }

  _navigateToWebView(String id, String url) async {
    const redirectUrl = 'http://localhost:8080/return';
    final mUri = Uri.encodeComponent(redirectUrl);
    var redirect = '$url?redirect_uri=$mUri';
    pp('$mm url: $redirect');
    var id = await navigateWithScale(StitchWebViewer(url: redirect), context);
    if (id is String) {
      //todo - write id to database
      pp('$mm id returned from payment: $id, will be written to the database ...');
      var sub = await widget.prefsOGx.getGioSubscription();
      gioPaymentRequest?.paymentRequestId = id;
      gioPaymentRequest?.organizationId = settings.organizationId;
      gioPaymentRequest?.date = DateTime.now().toUtc().toIso8601String();
      if (sub != null) {
        gioPaymentRequest?.subscriptionId = sub.subscriptionId;
      }
      widget.dataApiDog.addPaymentRequest(gioPaymentRequest!);

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var fmt = NumberFormat.compactCurrency(locale: Intl.getCurrentLocale());
    final num = fmt.format(widget.amount);
    return ScreenTypeLayout.builder(
      mobile: (ctx) {
        return SafeArea(
            child: Scaffold(
          appBar: AppBar(
            title: const Text('Stitch Payment'),
          ),
          body: busy
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: Card(
                      shape: getRoundedBorder(radius: 16),
                      elevation: 8,
                      child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Card(
                            child: SizedBox(height: 400,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  Text(
                                    widget.title,
                                    style: myTextStyleLarge(context),
                                  ),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  Text(
                                    num,
                                    style: myTextStyleLargerPrimaryColor(
                                        context),
                                  ),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  busy2
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            backgroundColor: Colors.pink,
                                          ),
                                        )
                                      : ElevatedButton(
                                          style: const ButtonStyle(elevation: MaterialStatePropertyAll(8.0)),
                                          onPressed: () {
                                            _getPaymentRequest();
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(28.0),
                                            child: Text('Submit Transaction'),
                                          )),
                                ],
                              ),
                            ),
                          )))),
        ));
      },
      tablet: (ctx) {
        return const Text('Tablet');
      },
    );
  }
}
