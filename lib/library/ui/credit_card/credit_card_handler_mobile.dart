import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/custom_card_type_icon.dart';
import 'package:flutter_credit_card/glassmorphism_config.dart';

import '../../api/prefs_og.dart';
import '../../data/user.dart';
import '../../functions.dart';


class CreditCardHandlerMobile extends StatefulWidget {
  final User? user;

  const CreditCardHandlerMobile({Key? key, this.user}) : super(key: key);

  @override
  CreditCardHandlerMobileState createState() =>
      CreditCardHandlerMobileState();
}

class CreditCardHandlerMobileState extends State<CreditCardHandlerMobile>
    with SingleTickerProviderStateMixin {

       final mm = '🧩🧩🧩🧩🧩 CreditCardHandler: ';
       late AnimationController _controller;
       String cardNumber = '';
       String expiryDate = '';
       String cardHolderName = '';
       String cvvCode = '';
       bool isCvvFocused = false;
       bool useGlassMorphism = false;
       bool useBackgroundImage = false;
       OutlineInputBorder? border;
       final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _key = GlobalKey<ScaffoldState>();
  User? user;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    if (widget.user != null) {
      user = widget.user;
      cardHolderName = user!.name!;
    } else {
      _getUser();
    }
  }

  void _getUser() async {
    user = await prefsOGx.getUser();
    if (user != null) {
      cardHolderName = user!.name!;
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            'Service Subscription',
            style: myTextStyleSmall(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20),
            child: Column(
              children: [
                user == null? const SizedBox() : Text(
                  user!.organizationName!,
                  style: myTextStyleSmall(context),
                ),
                const SizedBox(
                  height: 8,
                )
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 60,),
                const SizedBox(
                  height: 30,
                ),
                CreditCardWidget(
                  glassmorphismConfig:
                  useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  bankName: 'Axis Bank',
                  showBackView: isCvvFocused,
                  obscureCardNumber: true,
                  obscureCardCvv: true,
                  isHolderNameVisible: true,
                  cardBgColor: Colors.amber,
                  backgroundImage:
                  useBackgroundImage ? 'assets/card_bg.png' : null,
                  isSwipeGestureEnabled: true,
                  onCreditCardWidgetChange:
                      (CreditCardBrand creditCardBrand) {},
                  customCardTypeIcons: <CustomCardTypeIcon>[
                    CustomCardTypeIcon(
                      cardType: CardType.mastercard,
                      cardImage: Image.asset(
                        'assets/mastercard.png',
                        height: 48,
                        width: 48,
                      ),
                    ),
                  ],
                ),
                // Expanded(
                //   child: SingleChildScrollView(
                //     child: CreditCardForm(
                //         key: _formKey, onCreditCardModelChange: _onChange),
                //   ),
                // ),
              ],
            ),
            showSubmit
                ? Positioned(
                    right: 12,
                    bottom: 12,
                    child: Card(
                      elevation: 8,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 32, right: 32, top: 12, bottom: 12),
                          child: Text(
                            'Submit Card',
                            style: Styles.whiteSmall,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }


  bool showSubmit = false;
  void _onChange(CreditCardModel creditCardModel) {
    pp('😡 😡 😡 Credit Card Details changed '
        'cardHolderName: ${creditCardModel.cardHolderName} 💙 cardNumber: ${creditCardModel.cardNumber} '
        ' 💙 expiryDate: ${creditCardModel.expiryDate} 💙 cvv: ${creditCardModel.cvvCode}');
    int cnt = 0;
    if (creditCardModel.cardNumber.isNotEmpty) {
      cnt++;
    }
    if (creditCardModel.cardHolderName.isNotEmpty) {
      cnt++;
    }
    if (creditCardModel.cvvCode.isNotEmpty) {
      cnt++;
    }
    if (creditCardModel.expiryDate.isNotEmpty) {
      cnt++;
    }
    if (cnt == 4) {
      showSubmit = true;
    } else {
      showSubmit = false;
    }

    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void _submit() {
    pp('$mm 😡😡😡 Credit Card about to be submitted here 💙💙💙💙💙 what do we do here? ');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment made')));
  }

  void _onCreditCardChange(CreditCardBrand p1) {
    pp('$mm _onCreditCardChange,  🍎brand: ${p1.brandName} -  🍎$p1');
  }
}
