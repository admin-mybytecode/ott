import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  Widget appBar() {
    return AppBar(
      leading: SizedBox(),
      elevation: 0.0,
      title: Text(
        "Music",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: primaryColor,
      body: Container(),
    );
  }
}
