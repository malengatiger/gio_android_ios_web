import 'package:flutter/material.dart';

import '../../library/api/prefs_og.dart';
import '../../library/bloc/admin_bloc.dart';
import '../../library/data/community.dart';
import '../../library/data/country.dart';
import '../../library/data/user.dart';
import '../../library/functions.dart';
import '../../library/generic_functions.dart';
import '../../library/ui/countries.dart';


class SettlementEditor extends StatefulWidget {
  final Community settlement;

  const SettlementEditor({super.key, required this.settlement});

  @override
  SettlementEditorState createState() => SettlementEditorState();

}
class SettlementEditorState extends State<SettlementEditor>
    implements CountryListener {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController nameCntrl = TextEditingController();
  TextEditingController emailCntrl = TextEditingController();
  TextEditingController cellCntrl = TextEditingController();
  TextEditingController popCntrl = TextEditingController();
  bool isBusy = false;
  User? user;
  List<Country> countries = [];
  Community? community;

  @override
  void initState() {
    super.initState();
    nameCntrl.text = widget.settlement.name!;
    emailCntrl.text = widget.settlement.email!;
    popCntrl.text = '${widget.settlement.population}';
    community = widget.settlement;
    _getData();
  }

  _getData() async {
    user = await prefsOGx.getUser();
    countries = await adminBloc.getCountries();
    if (countries.length == 1) {
      _country = countries.elementAt(0);
      await prefsOGx.saveCountry(_country!);
      prettyPrint(_country!.toJson(), '💙 💙 💙 country.  check country id');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Settlement Editor'),
        backgroundColor: Colors.indigo[300],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: <Widget>[
              Text(
                user == null ? '' : user!.organizationName!,
                style: Styles.blackBoldMedium,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      body: isBusy
          ? const Center(
              child: SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 28,
                  backgroundColor: Colors.pink,
                ),
              ),
            )
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 12,
                      ),
                      TextField(
                        controller: nameCntrl,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Enter settlement name',
                          labelText: 'Settlement Name',
                        ),
                        onChanged: _onNameChanged,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextField(
                        controller: emailCntrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Enter email address',
                          labelText: 'Email',
                        ),
                        onChanged: _onEmailChanged,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextField(
                        controller: cellCntrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Enter cellphone number',
                          labelText: 'Cellphone',
                        ),
                        onChanged: _onCellChanged,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextField(
                        controller: popCntrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: false),
                        decoration: const InputDecoration(
                          hintText: 'Enter population',
                          labelText: 'Population',
                        ),
                        onChanged: _onPopChanged,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _country == null
                          ? Container()
                          : Text(
                              _country!.name!,
                              style: Styles.blackBoldLarge,
                            ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(

                        onPressed: _submit,

                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Text(
                            'Submit Settlement',
                            style: Styles.whiteSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Country? _country;
  @override
  onCountrySelected(Country country) {
    _country = country;
    setState(() {});
    return null;
  }

  String? name;
  void _onNameChanged(String value) {
    name = value;
  }

  String? email;
  void _onEmailChanged(String value) {
    email = value;
  }

  String? cell;
  void _onCellChanged(String value) {
    cell = value;
  }

  int pop = 0;
  void _onPopChanged(String value) {
    pop = int.parse(value);
  }

  void _submit() async {
    setState(() {
      isBusy = true;
    });

    try {
      assert(_country != null);
      if (community == null) {
        community = Community(
          countryId: _country!.countryId,
          countryName: _country!.name!,
          name: name,
          population: pop,
          email: email, created: DateTime.now().toUtc().toIso8601String(),
        );
        await adminBloc.addCommunity(community!);
      } else {
        community!.name = name;
        community!.population = pop;
        community!.email = email;
        await adminBloc.updateCommunity(community!);
      }

      setState(() {
        isBusy = false;
      });
      if (mounted) {
        showToast(message: 'Settlement added', context: context);
      }

    } catch (e) {
      setState(() {
        isBusy = false;
      });
      pp(e);
    }
  }


}
