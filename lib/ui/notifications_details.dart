import 'package:flutter/material.dart';
import 'package:nexthour/global.dart';

import '../global.dart';

class NotificationsDetailsPage extends StatefulWidget {
  NotificationsDetailsPage({this.title, this.data});
  final String title;
  final String data;
  @override
  _NotificationsDetailsPageState createState() => _NotificationsDetailsPageState();
}

class _NotificationsDetailsPageState extends State<NotificationsDetailsPage> {

  Widget appBar(){
    return AppBar(
      elevation: 0.0,
      centerTitle: true,
      backgroundColor: primaryDarkColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
         Padding(
           padding: EdgeInsets.all(15.0),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.start,
             children: <Widget>[
               Expanded(
                 flex: 1,
                 child: Text(widget.title, style: TextStyle(fontSize: 20.0),),
               ),
             ],
           ),
         ),

          Padding(
            padding: EdgeInsets.all(25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(widget.data, style: TextStyle(fontSize: 16.0, color: Colors.white.withOpacity(0.6),
                  height: 1.5),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
