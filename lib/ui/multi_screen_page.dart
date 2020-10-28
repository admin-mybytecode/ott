import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/controller/navigation_bar_controller.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/ui/create_screen_profile.dart';

import '../home.dart';

var screen1;
var screen2;
var screen3;
var screen4;
var myActiveScreen;

class MultiScreenPage extends StatefulWidget {
  @override
  _MultiScreenPageState createState() => _MultiScreenPageState();
}

class _MultiScreenPageState extends State<MultiScreenPage> {
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
    return null;
  }

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

  @override
  void initState() {
    // TODO: implement initState
    getAllScreens();
    super.initState();
  }

  void writeToFile(String key, String value) {
    Map<String, String> content = {key: value};

    Map<dynamic, dynamic> jsonFileContent =
        json.decode(jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));

    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

  Widget appBar() {
    return AppBar(
      title: CachedNetworkImage(
        imageUrl: '${APIData.logoImageUri}${loginConfigData['logo']}',
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.edit,
              size: 30,
              color: Colors.white,
            ),
            padding: EdgeInsets.only(right: 15.0),
            onPressed: () {
              var router = new MaterialPageRoute(
                  builder: (BuildContext context) => CreateMultiProfile());
              Navigator.of(context).push(router);
            }),
      ],
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Color.fromRGBO(34, 34, 34, 1.0).withOpacity(0.98),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: appBar(),
          body: screenList.length == 0
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(top: 30.0, bottom: 30.0),
                                  child: Text(
                                    "Who's Watching?",
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return InkWell(
                                child: Container(
                                  width: 110.0,
                                  height: 110.0,
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/avatar.png',
                                        width: 100.0,
                                        height: 80.0,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        "${screenList[index]}",
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color:
                                                Colors.white.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  writeToFile(
                                      "screenName", "${screenList[index]}");
                                  writeToFile("screenStatus", "YES");
                                  writeToFile("screenCount", "${index + 1}");
                                  setState(() {
                                    myActiveScreen = screenList[index];
                                    screenCount = index + 1;
                                  });
                                  var router = MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          BottomNavigationBarController());
                                  Navigator.of(context).push(router);
                                },
                              );
                            },
                            childCount:
                                mScreenCount, // Your desired amount of children here
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        onWillPop: onWillPopS);
  }
}
