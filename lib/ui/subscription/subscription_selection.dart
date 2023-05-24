import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/data/pricing.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/data/subscription.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:geo_monitor/stitch/stitch_service.dart';
import 'package:geo_monitor/utilities/transitions.dart';
import 'package:intl/intl.dart';
import 'package:pay/pay.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../l10n/translation_handler.dart';
import '../../library/ui/stitch/gio_stitch_payment_page.dart';

class SubscriptionSelection extends StatefulWidget {
  const SubscriptionSelection(
      {Key? key, required this.prefsOGx, required this.dataApiDog, required this.stitchService})
      : super(key: key);

  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;
  final StitchService stitchService;


  @override
  SubscriptionSelectionState createState() => SubscriptionSelectionState();
}

class SubscriptionSelectionState extends State<SubscriptionSelection> {
  static const mm = ' 🌸🌸🌸🌸🌸🌸🌸🌸SubscriptionSelection  🌸🌸';
  GioSubscription? subscription;
  late SettingsModel settings;
  String? freeTitle,
      monthlyTitle,
      annualTitle,
      corporateTitle,
      free, subscriptionPlans,
      subscriptionSubTitle;
  String? freeDesc, monthlyDesc, annualDesc, corporateDesc, submitText;
  Pricing? pricing;
  bool busy = false;
  Locale? myLocale;
  var placeHolder =
      "Discover the perfect subscription plan for Gio's services. Unlock advanced features, analytics, "
      "priority support, and seamless integrations. Streamline your remote workforce management with ease. "
      "Choose Gio and revolutionize your off-site operations.";

  @override
  void initState() {
    super.initState();
    _getSubscription();
  }

  @override
  void didChangeDependencies() {
    myLocale = Localizations.localeOf(context);
    pp('$mm didChangeDependencies: my locale $myLocale');
    super.didChangeDependencies();
  }

  void _getSubscription() async {
    setState(() {
      busy = true;
    });
    try {
      settings = await widget.prefsOGx.getSettings();
      subscription = await widget.prefsOGx.getGioSubscription();
      await _setTexts();
      await _getPricingByCountry();
    } catch (e) {
      pp(e);
      showSnackBar(
          message: 'Pricing not available. Please try later', context: context);
    }

    setState(() {
      busy = false;
    });
  }

  Future? _getPricingByCountry() async {
    var country = await widget.prefsOGx.getCountry();
    if (country != null) {
      final prices = await widget.dataApiDog.getPricing(country.countryId!);
      if (prices.isNotEmpty) {
        pricing = prices[0];
      }
    } else {
      if (mounted) {
        showSnackBar(
            message: 'Country not available. Please try later',
            context: context);
        Navigator.of(context).pop();
      }
    }
    setState(() {});
  }

  Future _setTexts() async {
    String locale = settings.locale!;
    freeTitle = await translator.translate('freeSub', locale);
    subscriptionPlans = await translator.translate('subscriptionPlans', locale);

    monthlyTitle = await translator.translate('monthly', locale);
    annualTitle = await translator.translate('annual', locale);
    corporateTitle = await translator.translate('corporate', locale);
    subscriptionSubTitle =
        await translator.translate('subscriptionSubTitle', locale);
    monthlyDesc = await translator.translate('monthlyDesc', locale);
    corporateDesc = await translator.translate('corporateDesc', locale);
    submitText = await translator.translate('submitText', locale);
    freeTitle = await translator.translate('freeSub', locale);
    freeDesc = await translator.translate('freeDesc', locale);
    free = await translator.translate('free', locale);
    annualDesc = await translator.translate('annualDesc', locale);

    setState(() {});
  }

  void _onFreeSelected() {
    pp('$mm _onFreeSelected ...');
  }

  void _onMonthlySelected() {
    pp('$mm _onMonthlySelected ...');
    _startPayment(pricing!.monthlyPrice!, monthlyTitle!);
  }

  void _onAnnualSelected() {
    pp('$mm _onAnnualSelected ...');
    _startPayment(pricing!.annualPrice!, annualTitle!);
  }

  void _onCorporateSelected() {
    pp('$mm _onCorporateSelected ...  🔵 🔵 🔵 send email to info@gio.com ....');
  }

  void _startPayment(double amount, String label) async {
    pp('$mm _startPayment .. nav to PaymentMethods ...');

    var result = await navigateWithScale(
        GioStitchPaymentPage(
          amount: amount.toInt(),
          title: label,
          dataApiDog: widget.dataApiDog,
          stitchService: widget.stitchService,
          prefsOGx: widget.prefsOGx,
        ),
        context);
    pp('$mm result of payment: $result');
  }

  List<Widget> _getItems() {
    var mSubmitText = 'Select This Plan';
    if (submitText != null) {
      mSubmitText = submitText!;
    }
    if (pricing == null) {
      return [];
    }
    final fmt = NumberFormat.decimalPatternDigits(
        locale: settings.locale, decimalDigits: 2);
    final items = <SubscriptionItem>[];
    items.add(SubscriptionItem(
        title: freeTitle == null ? 'Free' : freeTitle!,
        description: freeDesc == null ? 'Free Description ...' : freeDesc!,
        submitText: mSubmitText,
        price: free == null ? 'Free' : free!,
        hideButton: true,
        onSelected: _onFreeSelected));

    items.add(SubscriptionItem(
        title: monthlyTitle == null ? 'Monthly Subscription' : monthlyTitle!,
        description:
            monthlyDesc == null ? 'Monthly Description ...' : monthlyDesc!,
        submitText: mSubmitText,
        hideButton: false,
        price: fmt.format(pricing!.monthlyPrice!),
        onSelected: _onMonthlySelected));

    items.add(SubscriptionItem(
        title: annualTitle == null ? 'Annual Subscription' : annualTitle!,
        description:
            annualDesc == null ? 'Annual Description ...' : annualDesc!,
        submitText: mSubmitText,
        hideButton: false,
        price: fmt.format(pricing!.annualPrice!),
        onSelected: _onAnnualSelected));

    items.add(SubscriptionItem(
        title:
            corporateTitle == null ? 'Corporate Subscription' : corporateTitle!,
        description: corporateDesc == null
            ? 'Corporate Description ...'
            : corporateDesc!,
        price: 'Contract',
        hideButton: false,
        onSelected: _onCorporateSelected,
        submitText: mSubmitText));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            backgroundColor: Colors.pink,
          ),
        ),
      );
    }
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    var  color = getTextColorForBackground(Theme.of(context).primaryColor);

    if (isDarkMode) {
      color = Theme.of(context).primaryColor;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(subscriptionPlans == null?
          'Subscription Plans':subscriptionPlans!,
          style: myTextStyleMediumLargeWithColor(context, color),
        ),
        // backgroundColor: isDarkMode? Colors.transparent: Colors.brown[50],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(160),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    subscriptionSubTitle == null
                        ? placeHolder
                        : subscriptionSubTitle!,
                    style: myTextStyleSmallWithColor(context, color),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                ],
              ),
            )),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (ctx) {
          return Container(color: isDarkMode? Colors.transparent: Colors.brown[50],
            // height: 560,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _getItems(),
            ),
          );
        },
        tablet: (ctx) {
          return Container(color: isDarkMode? Colors.transparent: Colors.brown[50],
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _getItems(),
            ),
          );
        },
      ),
    ));
  }
}

class SubscriptionItem extends StatelessWidget {
  const SubscriptionItem({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    this.options,
    required this.onSelected,
    required this.submitText,
    required this.hideButton,
  }) : super(key: key);
  final String title, description, submitText;
  final String price;
  final List<String>? options;
  final Function onSelected;
  final bool hideButton;

  @override
  Widget build(BuildContext context) {
    var color = getTextColorForBackground(Theme.of(context).primaryColor);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (isDarkMode) {
      color = Colors.white;
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: getRoundedBorder(radius: 16),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                const SizedBox(
                  height: 48,
                ),
                Text(
                  title,
                  style: myTextStyleMediumLarge(context),
                ),
                const SizedBox(
                  height: 48,
                ),
                Text(
                  price,
                  style: myNumberStyleWithSizeColor(
                      context, 64, Theme.of(context).primaryColor),
                ),
                const SizedBox(
                  height: 48,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    description,
                    style: myTextStyleMedium(context),
                  ),
                ),
                const SizedBox(
                  height: 48,
                ),
                hideButton
                    ? const SizedBox()
                    : ElevatedButton(
                        style: const ButtonStyle(
                            elevation: MaterialStatePropertyAll(8.0)),
                        onPressed: () {
                          onSelected();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(submitText, style: myTextStyleMediumWithColor(context, color),),
                        )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionConstants {
  static const int freeSubscription = 0;
  static const int monthlySubscription = 1;
  static const int annualSubscription = 2;
  static const int corporateSubscription = 3;
  static const int freeSubscriptionDays = 14;
}

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({
    Key? key,
    required this.amount,
    required this.label,
    required this.stitchService, required this.prefsOGx, required this.dataApiDog,
  }) : super(key: key);
  final double amount;
  final String label;
  final StitchService stitchService;
  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;



  @override
  State<PaymentMethods> createState() => PaymentMethodsState();
}

class PaymentMethodsState extends State<PaymentMethods> {
  final mm = '🍎🍎🍎🍎🍎🍎 PaymentMethods 🍎🍎🍎';
  final _paymentItems = <PaymentItem>[];
  PaymentConfiguration? _googlePayConfig;
  PaymentConfiguration? _applePayConfig;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _setConfig();
  }

  Future _setConfig() async {
    setState(() {
      busy = true;
    });
    _googlePayConfig = await PaymentConfiguration.fromAsset(
        'payment/default_google_pay_config.json');
    _applePayConfig = await PaymentConfiguration.fromAsset(
        'payment/default_apple_pay_config.json');

    _paymentItems.add(
        PaymentItem(label: widget.label, amount: widget.amount.toString()));

    pp('$mm ............ _googlePayConfigFuture: ${_googlePayConfig!.provider.name}');
    pp('$mm ............ _applePayConfigFuture: ${_applePayConfig!.provider.name}');

    setState(() {
      busy = false;
    });
  }

  void onApplePayResult(Map<String, dynamic> paymentResult) {
    pp('$mm onApplePayResult: Send the resulting Apple Pay token to your server / PSP; paymentResult: $paymentResult');
  }

  void onGooglePayResult(Map<String, dynamic> paymentResult) {
    pp('$mm onGooglePayResult: Send the resulting Google Pay token to your server / PSP; paymentResult: $paymentResult');
  }

  void _navigateToStitch() {
    navigateWithScale(
        GioStitchPaymentPage(
          stitchService: widget.stitchService,
          prefsOGx: widget.prefsOGx,
          title: widget.label,
          dataApiDog: widget.dataApiDog,
          amount: widget.amount.toInt(),
        ),
        context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Payment'),
      ),
      body: Center(
        child: busy
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              )
            : Card(
                shape: getRoundedBorder(radius: 16),
                elevation: 8.0,
                child: SizedBox(
                  height: 400,
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 60,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _navigateToStitch();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('Stitch Payment'),
                            )),
                        const SizedBox(
                          height: 32,
                        ),
                        GooglePayButton(
                          paymentConfiguration: _googlePayConfig,
                          paymentItems: _paymentItems,
                          type: GooglePayButtonType.pay,
                          margin: const EdgeInsets.only(top: 15.0),
                          onPaymentResult: onGooglePayResult,
                          loadingIndicator: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        ApplePayButton(
                          paymentConfiguration: _applePayConfig,
                          paymentItems: _paymentItems,
                          style: ApplePayButtonStyle.automatic,
                          type: ApplePayButtonType.buy,
                          margin: const EdgeInsets.only(top: 15.0),
                          onPaymentResult: onApplePayResult,
                          loadingIndicator: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          childOnError: const Text('Apple Button Error'),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    ));
  }
}
