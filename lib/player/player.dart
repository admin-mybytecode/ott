import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/ui/multi_screen_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../global.dart';

class PlayerMovie extends StatefulWidget {
  PlayerMovie({this.id, this.type});

  final int id;
  final String type;

  @override
  _PlayerMovieState createState() => _PlayerMovieState();
}

class _PlayerMovieState extends State<PlayerMovie> with WidgetsBindingObserver {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController _controller1;
  var playerResponse;
  var status;
  GlobalKey sc = new GlobalKey<ScaffoldState>();
  DateTime currentBackPressTime;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.initState();
    this.loadLocal();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _controller1?.reload();
        screenLogout();
        print("Inactive");
        break;
      case AppLifecycleState.resumed:
        _controller1?.reload();
        updateScreens(myActiveScreen, fileContent["screenCount"]);
        break;
      case AppLifecycleState.paused:
        _controller1?.reload();
        screenLogout();
        print("Paused");
        break;
      case AppLifecycleState.detached:
        print("Detached");
//        screenLogout();
        // TODO: Handle this case.
        break;
    }
  }

  screenLogout() async {
    Wakelock.disable();
    final screenLogOutResponse =
        await http.post(APIData.screenLogOutApi, body: {
      "screen": '$myActiveScreen',
      "count": '${fileContent['screenCount']}',
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
    });
    print(screenLogOutResponse.statusCode);
    print(screenLogOutResponse.body);

    final accessToken = await http.post(APIData.tokenApi, body: {
      "email": fileContent['user'],
      "password": fileContent['pass'],
    });

    if (accessToken.statusCode == 200) {
      var user = json.decode(accessToken.body);
      var newToken = "Bearer ${user['access_token']}";
      saveNewToken(newToken);
      getNewToken();
      setState(() {
        fullData = "Bearer ${user['access_token']}";
      });
    }
  }

  void stopScreenLock() async {
    Wakelock.enable();
  }

  saveNewToken(token) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('token', "$token");
  }

  getNewToken() async {
    prefs = await SharedPreferences.getInstance();
    prefs.getString('token');
    nToken = prefs.getString('token');
  }

  updateScreens(screen, count) async {
    final updateScreensResponse =
        await http.post(APIData.updateScreensApi, body: {
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
    if (userPaymentType != "Free") {
      screenLogout();
    }
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Navigator.pop(context);
      return Future.value(true);
    }
    return Future.value(true);
  }

  Future<String> loadLocal() async {
    playerResponse = await http.get(widget.type == 'T'
        ? APIData.tvSeriesPlayer + '$userId/$code/$ser'
        : APIData.moviePlayer + '$userId/$code/${widget.id}');
    print("status: ${playerResponse.statusCode}");
    setState(() {
      status = playerResponse.statusCode;
    });
    var responseUrl = playerResponse.body;
    return responseUrl;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.type == 'T'
        ? APIData.tvSeriesPlayer + '$userId/$code/$ser'
        : APIData.moviePlayer + '$userId/$code/${widget.id}');

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
      return JavascriptChannel(
          name: 'Toaster',
          onMessageReceived: (JavascriptMessage message) {
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          });
    }

    return WillPopScope(
        child: Scaffold(
          key: sc,
          body: Stack(
            children: <Widget>[
              Container(
                  width: width,
                  height: height,
                  child: WebView(
                      initialUrl: widget.type == 'T'
                          ? APIData.tvSeriesPlayer + '$userId/$code/$ser'
                          : APIData.moviePlayer + '$userId/$code/${widget.id}',
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller1 = webViewController;
                      },
                      javascriptChannels: <JavascriptChannel>[
                        _toasterJavascriptChannel(context),
                      ].toSet())),
              Positioned(
                top: 26.0,
                left: 4.0,
                child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      _controller1?.reload();
                      Navigator.pop(context);
                    }),
              ),
            ],
          ),
        ),
        onWillPop: onWillPopS);
//    );
  }
}
