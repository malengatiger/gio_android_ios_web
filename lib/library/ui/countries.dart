import 'package:flutter/material.dart';

import '../api/data_api.dart';
import '../data/country.dart';
import '../functions.dart';
class CountriesDropDown extends StatefulWidget {
  final CountryListener countryListener;

  const CountriesDropDown(this.countryListener, {super.key});

  @override
  CountriesDropDownState createState() => CountriesDropDownState();
}

class CountriesDropDownState extends State<CountriesDropDown> {
  @override
  void initState() {
    super.initState();
    _getCountries();
  }

  List<Country> _countries = [];
  _getCountries() async {
    _countries = await DataAPI.getCountries();
    pp('🦠 🦠 🦠 getCountries .....🦠 ${_countries.length} found');
    for (var c in _countries) {
      var item = DropdownMenuItem<Country>(
        child: ListTile(
          leading: const Icon(Icons.local_library),
          title: Text('${c.name}'),
        ),
      );
      items.add(item);
      prettyPrint(c.toJson(), '🏀🏀 Country ...  🏀🏀');
    }
    pp('🧩 🧩  setting state ');
    setState(() {});
  }

  List<DropdownMenuItem<Country>> items = [];

  @override
  Widget build(BuildContext context) {
    pp('👽 👽 build starting ...  🐲 🐲 🐲 🐲 ');
    if (items.isEmpty) {
      return Container();
    }
    return DropdownButton<Country>(
      items: items,
      onChanged: _onDropDownChanged,
    );
  }

  void _onDropDownChanged(Country? value) {
    pp('🔆🔆🔆 _onDropDownChanged ... ');
    widget.countryListener.onCountrySelected(value!);
  }
}

abstract class CountryListener {
  onCountrySelected(Country country);
}
