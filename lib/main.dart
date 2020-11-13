import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/model/musicpage_state.dart';
import 'package:nexthour/repository/database_creator.dart';
import 'package:nexthour/loading/loading_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await DatabaseCreator().initDatabase();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: primaryColor, // navigation bar color
      statusBarColor: primaryColor, // status bar color
    ),
  );

  runApp(
    ChangeNotifierProvider<AudioState>(
      create: (context) => AudioState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Next Hour',
        home: LoadingScreen(),
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: primaryColor,
          accentColor: redPrime,
        ),
      ),
    ),
  );
}
