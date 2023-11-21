import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:weatherapp/models/current_weather.dart';
import 'package:weatherapp/models/forecast_weather.dart';
import 'package:weatherapp/utils/constanse.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geo;
import 'package:weatherapp/utils/helper_functions.dart';
import 'package:geolocator/geolocator.dart';



class WeatherProviders extends ChangeNotifier{
  CurrentWeather? currentWeather;
  ForecastWeather? forecasteWeather;
  String unit = metric;
  double latitude = 23.810332, longitude = 90.41251809999994;
  String unitSymbol = celsius;
  bool shouldGetLoactionFromCityName = false;
  String baseUrl = 'https://api.openweathermap.org/data/2.5/';


  bool get hasDataLoaded => currentWeather != null && forecasteWeather != null;

  Future<void> getData() async {
    if(!shouldGetLoactionFromCityName){
      final position = await _determinePosition();
      longitude = position.longitude;
      latitude = position.latitude;
    }
    await _getCurrentData();
    await _getForecastData();
  }
  /*void setTempStatus(bool value){
    unit = value ? imperial : metric;
    getData();
  }*/
  Future<void> getTempUnitFromPref()async{
    final status = await getTempUnitStatus();
    unit = status ? imperial : metric;
    unitSymbol = status ? fahrenheit :celsius;
  }

  Future<void> _getCurrentData()async{
    await getTempUnitFromPref();
    final endUrl = 'weather?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=$unit';
    final url = Uri.parse('$baseUrl$endUrl');

    try{
      final response = await http.get(url);
      final json = jsonDecode(response.body) as Map<String,dynamic>;
      if(response.statusCode == 200){
        currentWeather = CurrentWeather.fromJson(json);
        notifyListeners();
      }else{
        print(json['message']);
      }
    }catch(error){
      print(error.toString());
    }
  }

  Future<void> _getForecastData()async{
    await getTempUnitFromPref();
    final endUrl = 'forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=$unit';
    final url = Uri.parse('$baseUrl$endUrl');

    try{
      final response = await http.get(url);
      final json = jsonDecode(response.body) as Map<String,dynamic>;
      if(response.statusCode == 200){
        forecasteWeather = ForecastWeather.fromJson(json);
        notifyListeners();
      }else{
        print(json['message']);
      }
    }catch(error){
      print(error.toString());
    }
  }
Future<void> convertCityLatLong(String city) async{
    try{
      final locationList = await geo.locationFromAddress(city);
      if(locationList.isNotEmpty){
        final location = locationList.first;
        longitude = location.longitude;
        latitude = location.latitude;
        shouldGetLoactionFromCityName = true;
        getData();
      }

    }catch (error){
      print(error.toString());

    }

}

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

}