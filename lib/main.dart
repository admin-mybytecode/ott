import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:nexthour/repository/database_creator.dart';
import 'package:nexthour/loading/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await DatabaseCreator().initDatabase();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black, // navigation bar color
    statusBarColor: Colors.black, // status bar color
  ));

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Next Hour',
      home: LoadingScreen(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue[800],
        accentColor: Color.fromRGBO(125, 183, 91, 1.0),
      ),
    ),
  );
}
