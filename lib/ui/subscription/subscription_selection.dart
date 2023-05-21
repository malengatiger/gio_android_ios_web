import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/data_api_og.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';
import 'package:geo_monitor/library/data/pricing.dart';
import 'package:geo_monitor/library/data/settings_model.dart';
import 'package:geo_monitor/library/data/subscription.dart';
import 'package:geo_monitor/library/functions.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SubscriptionSelection extends StatefulWidget {
  const SubscriptionSelection(
      {Key? key, required this.prefsOGx, required this.dataApiDog})
      : super(key: key);

  final PrefsOGx prefsOGx;
  final DataApiDog dataApiDog;

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
      await setTexts();
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
  }

  Future setTexts() async {}

  void _onFreeSelected() {}

  void _onMonthlySelected() {
    _startPayment();
  }

  void _onAnnualSelected() {
    _startPayment();
  }

  void _onCorporateSelected() {
    _startPayment();
  }

  void _startPayment() async {}

  List<Widget> _getItems() {
    var mSubmitText = 'Select This Plan';
    if (submitText != null) {
      mSubmitText = submitText!;
    }
    final items = <SubscriptionItem>[];
    items.add(SubscriptionItem(
        title: freeTitle == null ? 'Free' : freeTitle!,
        description: freeDesc == null ? 'Free Description ...' : freeDesc!,
        submitText: mSubmitText,
        price: 0.0,
        onSelected: _onFreeSelected));

    items.add(SubscriptionItem(
        title: monthlyTitle == null ? 'Monthly Subscription' : monthlyTitle!,
        description:
            monthlyDesc == null ? 'Monthly Description ...' : monthlyDesc!,
        submitText: mSubmitText,
        price: pricing!.monthlyPrice!,
        onSelected: _onMonthlySelected));

    items.add(SubscriptionItem(
        title: annualTitle == null ? 'Annual Subscription' : annualTitle!,
        description:
            annualDesc == null ? 'Annual Description ...' : annualDesc!,
        submitText: mSubmitText,
        price: pricing!.annualPrice!,
        onSelected: _onAnnualSelected));

    items.add(SubscriptionItem(
        title:
            corporateTitle == null ? 'Corporate Subscription' : corporateTitle!,
        description: corporateDesc == null
            ? 'Corporate Description ...'
            : corporateDesc!,
        price: 0.0,
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
    final color = getTextColorForBackground(Theme.of(context).primaryColor);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscription Plans',
          style: myTextStyleLargeWithColor(context, color),
        ),
        bottom:  PreferredSize(
            preferredSize: const Size.fromHeight(160),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(subscriptionSubTitle == null? placeHolder: subscriptionSubTitle!, style: myTextStyleSmallWithColor(context, color),),
                  const SizedBox(
                    height: 48,
                  ),
                ],
              ),
            )),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (ctx) {
          return SizedBox(
            height: 440,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _getItems(),
            ),
          );
        },
        tablet: (ctx) {
          return ListView(
            scrollDirection: Axis.horizontal,
            children: _getItems(),
          );
        },
      ),
    ));
  }
}

class SubscriptionItem extends StatelessWidget {
  const SubscriptionItem(
      {Key? key,
      required this.title,
      required this.description,
      required this.price,
      this.options,
      required this.onSelected,
      required this.submitText,})
      : super(key: key);
  final String title, description, submitText;
  final double price;
  final List<String>? options;
  final Function onSelected;

  @override
  Widget build(BuildContext context) {
    final color = getTextColorForBackground(Theme.of(context).primaryColor);
    final locale = Intl.getCurrentLocale();
    final fmt = NumberFormat.compactSimpleCurrency(locale: locale);
    final mPrice = fmt.format(price);

    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                  height: 8,
                ),
                Text(
                  title,
                  style: myTextStyleMediumLarge(context),
                ),
                const SizedBox(
                  height: 48,
                ),
                Text(
                  mPrice,
                  style: myNumberStyleWithSizeColor(context, 64, Theme.of(context).primaryColor),
                ),
                const SizedBox(
                  height: 48,
                ),
                Text(
                  description,
                  style: myTextStyleMedium(context),
                ),
                const SizedBox(
                  height: 48,
                ),
                ElevatedButton(
                    onPressed: () {
                      onSelected();
                    },
                    child: Text(submitText)),
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
