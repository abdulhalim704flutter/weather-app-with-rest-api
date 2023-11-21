import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/providers/weather_providers.dart';
import 'package:weatherapp/utils/helper_functions.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool status = false;
  @override
  void initState() {
    getTempUnitStatus().then((value){
      setState(() {
        status=value;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Show temperature in fahrenheit'),
            subtitle: const Text('Default is Celsius'),
            value: status,
              onChanged: (value) async{
              setState(() {
                status = value;
              });
              await setTempUnitStatus(status);
              Provider.of<WeatherProviders>(context,listen: false)
              .getData();

              }
              ),
        ],
      ),
    );
  }
}
