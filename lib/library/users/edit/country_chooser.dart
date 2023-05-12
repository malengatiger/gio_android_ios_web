import 'package:flutter/material.dart';
import 'package:geo_monitor/library/api/prefs_og.dart';

import '../../../l10n/translation_handler.dart';

import '../../api/data_api_og.dart';
import '../../cache_manager.dart';
import '../../data/country.dart';
import '../../data/settings_model.dart';
import '../../functions.dart';

class CountryChooser extends StatefulWidget {
  const CountryChooser({Key? key, required this.onSelected, required this.hint, required this.refreshCountries})
      : super(key: key);

  final Function(Country) onSelected;
  final String hint;
  final bool refreshCountries;

  @override
  State<CountryChooser> createState() => CountryChooserState();
}

class CountryChooserState extends State<CountryChooser> {
  List<Country> countries = <Country>[];
  bool loading = false;
  SettingsModel? settings;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    setState(() {
      loading = true;
    });
    settings = await prefsOGx.getSettings();
    countries = await cacheManager.getCountries();
    if (countries.isEmpty) {
      countries = await dataApiDog.getCountries();
    }
    countries.sort((a, b) => a.name!.compareTo(b.name!));
    await _buildDropDown();
    setState(() {
      loading = false;
    });
  }

  var list = <DropdownMenuItem>[];
  Future _buildDropDown() async {
    var style = myTextStyleSmall(context);
    for (var entry in countries) {
      var translated = await translator.translate('${entry.name}', settings!.locale!);
      list.add(DropdownMenuItem<Country>(
        value: entry,
        child: Text(
          translated,
          style: style,
        ),
      ));
    }

  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: Colors.pink,
            ),
          )
        : DropdownButton(
            elevation: 4,
            hint: Text(
              widget.hint,
              style: myTextStyleSmall(context),
            ),
            items: list,
            onChanged: onChanged);
  }

  void onChanged(value) {
    widget.onSelected(value);
  }
}
