import 'package:flutter/material.dart';

import '../api/prefs_og.dart';
import '../bloc/admin_bloc.dart';
import '../data/community.dart';
import '../data/country.dart';
import '../functions.dart';

abstract class CommunityListener {
  onSettlementSelected(Community settlement);
}

class CommunityList extends StatefulWidget {
  final CommunityListener listener;

  const CommunityList(this.listener, {super.key});

  @override
  CommunityListState createState() => CommunityListState();
}

class CommunityListState extends State<CommunityList> {
  Country? country;
  List<Community> list = [];
  List<Country> countries = [];
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    _getCommunities();
  }

  _getCommunities() async {
    setState(() {
      isBusy = true;
    });
    country = await prefsOGx.getCountry();
    if (country == null) {
      countries = await adminBloc.getCountries();
      if (countries.length == 1) {
        country = countries.elementAt(0);
      }
    }
    if (country != null) {
      try {
        await adminBloc.findCommunitiesByCountry(country!.countryId!);
      } catch (e) {
        pp('👿 error getting community list ... 👿👿👿👿 does fucking the snackBar show?');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Query failed, what now, Boss?: $e')));
        }
      }
    }
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: adminBloc.settlementStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          list = snapshot.data;
          pp(' 🛎 settlements received from snapshot:  🛎 🛎 ${list.length}  🛎 🛎');
        }

        return Scaffold(
          key: _key,
          appBar: AppBar(
            title: const Text('Settlements'),
            backgroundColor: Colors.indigo[400],
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _getCommunities,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "Total Settlements",
                          style: Styles.whiteSmall,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          '${list.length}',
                          style: Styles.blackBoldLarge,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Colors.brown[100],
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
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      var sett = list.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          widget.listener.onSettlementSelected(sett);
                        },
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 8.0),
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(
                                    Icons.apps,
                                    color: getRandomColor(),
                                  ),
                                  title: Text(
                                    sett.name!,
                                    style: Styles.blackBoldSmall,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
