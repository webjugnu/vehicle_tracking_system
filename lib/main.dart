import 'package:flutter/material.dart';
import 'package:vehicle_tracking_system/login.dart';
import 'package:vehicle_tracking_system/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTS',
      theme: ThemeData(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Login(),
      routes:{
        '/login': (BuildContext context) => const Login(),
        '/home': (BuildContext context) => const Home(),
      },
    );
  }
}