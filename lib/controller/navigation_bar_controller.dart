import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/download/download_videos.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/page_home.dart';
import 'package:nexthour/ui/custom_drawer.dart';
import 'package:nexthour/ui/donation_page.dart';
import 'package:nexthour/ui/multi_screen_page.dart';
import 'package:nexthour/ui/search.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/ui/store_page.dart';

class BottomNavigationBarController extends StatefulWidget {
  BottomNavigationBarController({this.pageInd});
  final pageInd;

  @override
  _BottomNavigationBarControllerState createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends State<BottomNavigationBarController> {
  int _selectedIndex;
  DataConnectionChecker dataConnectivity;
  StreamSubscription<DataConnectionStatus> listener;

  Future<String> getAllScreens() async {
    final getAllScreensResponse =
        await http.get(Uri.encodeFull(APIData.showScreensApi), headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
    });
    print(getAllScreensResponse.statusCode);
    print(getAllScreensResponse.body);
    var screensRes = json.decode(getAllScreensResponse.body);
    setState(() {
      screen1 = screensRes['screen']['screen1'] == null
          ? "Screen1"
          : screensRes['screen']['screen1'];
      screen2 = screensRes['screen']['screen2'] == null
          ? "Screen2"
          : screensRes['screen']['screen2'];
      screen3 = screensRes['screen']['screen3'] == null
          ? "Screen3"
          : screensRes['screen']['screen3'];
      screen4 = screensRes['screen']['screen4'] == null
          ? "Screen4"
          : screensRes['screen']['screen4'];
    });
    setState(() {
      screenList = [screen1, screen2, screen3, screen4];
    });
    print("$screenList");
    return null;
  }

  static List<Widget> _widgetOptions = <Widget>[
    PageHome(),
    SearchResultList(),
    StorePage(),
    DonationPage(),
    CustomDrawer()
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.pageInd != null ? widget.pageInd : 0;
    dataConnectivity = new DataConnectionChecker();
    dataConnectivity.onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          _selectedIndex = widget.pageInd != null ? widget.pageInd : 0;
          break;
        case DataConnectionStatus.disconnected:
          _selectedIndex = widget.pageInd != null ? widget.pageInd : 3;
          var router = new MaterialPageRoute(
              builder: (BuildContext context) => OfflineDownloadPage());
          Navigator.of(context).push(router);
          break;
      }
    });
    if (status == "1") {
      if (userPaymentType != "Free") {
        getAllScreens();
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: primaryColor,
            extendBody: true,
            body: Stack(
              children: <Widget>[
                Center(
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 5.0,
                          sigmaY: 5.0,
                        ),
                        child: BottomNavigationBar(
                          type: BottomNavigationBarType.fixed,
                          backgroundColor: primaryColor.withOpacity(0.6),
                          items: const <BottomNavigationBarItem>[
                            BottomNavigationBarItem(
                                label: "Home", icon: Icon(Icons.home)),
                            BottomNavigationBarItem(
                                label: "Search", icon: Icon(Icons.search)),
                            BottomNavigationBarItem(
                                label: "Store",
                                icon: Icon(Icons.store_outlined)),
                            BottomNavigationBarItem(
                                label: "Donation",
                                icon: Icon(Icons.money_rounded)),
                            BottomNavigationBarItem(
                              label: 'Menu',
                              icon: Icon(Icons.menu),
                            ),
                          ],
                          currentIndex: _selectedIndex,
                          selectedItemColor: redPrime,
                          unselectedLabelStyle: TextStyle(color: primaryColor),
                          unselectedItemColor: textColor,
                          onTap: _onItemTapped,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
        onWillPop: onWillPopS);
  }
}

// Handle back press to exit
Future<bool> onWillPopS() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    currentBackPressTime = now;
    Fluttertoast.showToast(msg: "Press again to exit.");
    return Future.value(false);
  }
  return SystemNavigator.pop();
}
