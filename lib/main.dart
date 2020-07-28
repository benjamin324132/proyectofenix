import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:uber_clone/screens/Geolocate.dart';
import 'package:uber_clone/screens/Home.dart';

import 'Rotas.dart';

final ThemeData defaultTheme =
    ThemeData(primaryColor: Color(0xff37474f), accentColor: Color(0xff546e7a));

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Uber",
      home: Home(),
      // home: GeolocateApp(),
      theme: defaultTheme,
      initialRoute: "/",
      onGenerateRoute: Rotas.gerarRotas,
      debugShowCheckedModeBanner: false,
    );
  }
}
