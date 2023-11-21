import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getFormattedDateTime(num dt,{String pattren = 'MMM dd yyyy'})=>
    DateFormat(pattren).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));


Future<bool> setTempUnitStatus(bool status)async{
  final pref = await SharedPreferences.getInstance();
  return pref.setBool('status', status);
}

Future<bool> getTempUnitStatus()async{
  final pref = await SharedPreferences.getInstance();
  return pref.getBool('status') ?? false;
}
