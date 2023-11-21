import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/pages/setting_page.dart';
import 'package:weatherapp/providers/weather_providers.dart';
import 'package:weatherapp/utils/constanse.dart';
import 'package:weatherapp/utils/helper_functions.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  @override
  void didChangeDependencies() {
    Provider.of<WeatherProviders>(context, listen: false).getData();
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
              onPressed: () async{
                final result =await showSearch(context: context, delegate: _CitysSearchDelegate()) as String;
                if(result.isNotEmpty){
                  EasyLoading.show(status: 'Please wait');
                  await Provider.of<WeatherProviders>(context,listen: false).convertCityLatLong(result);
                  EasyLoading.dismiss();
                }
              },
              icon: Icon(Icons.search)),

          IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingPage())),
              icon: Icon(Icons.settings))
        ],
      ),
      body: Consumer<WeatherProviders>(
        builder: (context, provider, _) {
          return provider.hasDataLoaded
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentWeatherSection(provider, context),
                      _forecastWeatherSection(provider, context),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  Widget _currentWeatherSection(
      WeatherProviders provider, BuildContext context) {
    return Column(
      children: [
        Text(
          '${getFormattedDateTime(provider.currentWeather!.dt!)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '${provider.currentWeather!.name},${provider.currentWeather!.sys!.country}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
                '$iconUrlPrefix${provider.currentWeather!.weather![0].icon}$iconUrlSufix'),
            Text(
              '${provider.currentWeather!.main!.temp!.toStringAsFixed(0)}$degree${provider.unitSymbol}',
              style: TextStyle(fontSize: 50),
            ),
          ],
        ),
        Text(
          'Feels like: ${provider.currentWeather!.main!.feelsLike!.toStringAsFixed(0)}$degree${provider.unitSymbol}',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          provider.currentWeather!.weather![0].description!,
          style: TextStyle(fontSize: 25),
        ),
      ],
    );
  }

  Widget _forecastWeatherSection(
      WeatherProviders provider, BuildContext context) {
    final forecastItemList = provider.forecasteWeather!.list!;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastItemList.length,
        itemBuilder: (context, index) {
          final item = forecastItemList[index];
          return Card(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(getFormattedDateTime(item.dt!, pattren: 'EEE HH:mm')),
                  Image.network(
                      '$iconUrlPrefix${item.weather![0].icon}$iconUrlSufix'),
                  Text(
                      '${item.main!.tempMax!.toStringAsFixed(0)}/${item.main!.tempMin!.toStringAsFixed(0)}$degree${provider.unitSymbol}'),
                  Text(item.weather![0].description!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CitysSearchDelegate extends SearchDelegate<String>{
  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(onPressed: (){
        query = '';
      },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: (){
          close(context, query);
        },
        icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: (){
        close(context, query);
      },
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filterdList = query.isEmpty ? citise :
        citise.where((city) => city.toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filterdList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: (){
          query = filterdList[index];
          close(context, query);
        },
        title: Text(filterdList[index]),

      ),
    );
  }
  
}
