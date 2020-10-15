import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/ui/multi_screen_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../global.dart';
import 'package:http/http.dart' as http;

var x;
class PlayerEpisode extends StatefulWidget{
  PlayerEpisode({this.id});
  final int id;

  @override
  _PlayerEpisodeState createState() => _PlayerEpisodeState();
}

class _PlayerEpisodeState extends State<PlayerEpisode> with WidgetsBindingObserver{
  WebViewController _controller1;
  DateTime currentBackPressTime;

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        print("1000");
        _controller1?.reload();
//        Navigator.pop(context);
        screenLogout();
        break;
      case AppLifecycleState.paused:
        print("1001");
        _controller1?.reload();
        screenLogout();
//        Navigator.pop(context);
        break;
      case AppLifecycleState.resumed:
        updateScreens(myActiveScreen, fileContent["screenCount"]);
        print("1003");
//        Navigator.pop(context);
        break;
      case AppLifecycleState.detached:
        screenLogout();
      // TODO: Handle this case.
        break;
    }
  }


  void stopScreenLock() async{
    Wakelock.enable();
  }

  saveNewToken(token) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('token', "$token");
  }

  getNewToken() async {
    // obtain shared preferences
    prefs = await SharedPreferences.getInstance();
    prefs.getString('token');
    nToken = prefs.getString('token');
  }


  updateScreens(screen, count) async {
    final updateScreensResponse = await http.post(APIData.updateScreensApi, body: {
      "macaddress": '$ip',
      "screen": '$screen',
      "count": '$count',
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken
    });
    print(updateScreensResponse.statusCode);
    print(fullData);
    print(updateScreensResponse.body);
    if (updateScreensResponse.statusCode == 200) {
      print(updateScreensResponse.body);
    }
  }

  //  Handle back press
  Future<bool> onWillPopS() {
    print("Back Pressed");
    if(userPaymentType != "Free"){
      screenLogout();
    }
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Navigator.pop(context);
      return Future.value(true);
    }
    return Future.value(true);
  }

  screenLogout() async{
    Wakelock.disable();
    final screenLogOutResponse = await http.post( APIData.screenLogOutApi, body: {
      "screen": '$myActiveScreen',
      "count": '${fileContent['screenCount']}',
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: fullData
    });
    print(screenLogOutResponse.statusCode);
    print(screenLogOutResponse.body);

    final accessToken = await http.post(APIData.tokenApi, body: {
      "email": fileContent['user'],
      "password": fileContent['pass'],
    });

    if(accessToken.statusCode == 200){
      print("Logged In");
      var user = json.decode(accessToken.body);
      var newToken = "Bearer ${user['access_token']}";
//      saveNewToken(newToken);
//      getNewToken();
      setState(() {
        fullData = "Bearer ${user['access_token']}";
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Episode URL: ${APIData.episodePlayer+'$userId/$code/${widget.id}'}");
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // TODO: implement build
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    print("player episodes");
    return WillPopScope(
      child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                width: width,
                height: height,
                child: WebView(
                  initialUrl: APIData.episodePlayer+'$userId/$code/${widget.id}',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller1 = webViewController;
                  },
                ),
              ),
              Positioned(
                top: 26.0,
                left: 4.0,
                child: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed:(){
                  Navigator.pop(context);
                }),
//              child: new BackButton(color: Colors.white),
              ),
            ],
          )
      ),
      onWillPop: onWillPopS,
    );

  }
}

class LocalLoader{
  Future<String> loadLocal() async {
    return await rootBundle.loadString(APIData.moviePlayer+'$userId/$code/$x');
  }
}