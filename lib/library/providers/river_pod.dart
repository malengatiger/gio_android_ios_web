
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_monitor/library/functions.dart';

import '../data/country.dart';
import 'dio_service.dart';


final dataProvider = Provider((ref) => MyDataRequests(dioService));


class MyDataRequests {
  final DioService dioService;

  MyDataRequests(this.dioService);

  Future<List<Country>> getCountries() async {
    var countries = <Country>[];
    final requestUrl  = '${getUrl()}getCountries';
    final List jsonList = await dioService.callGet(requestUrl: requestUrl,);
    for (var value in jsonList) {
      countries.add(Country.fromJson(jsonDecode(value)));
    }
    return countries;
  }
}