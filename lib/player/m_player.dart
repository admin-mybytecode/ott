import 'dart:convert';
import 'dart:io';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/custom_player/chewie.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/ui/multi_screen_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;
import '../global.dart';

class MyCustomPlayer extends StatefulWidget {
  MyCustomPlayer({this.title, this.url, this.downloadStatus});

  final String title;
  final String url;
  final int downloadStatus;

  @override
  State<StatefulWidget> createState() {
    return _MyCustomPlayerState();
  }
}

class _MyCustomPlayerState extends State<MyCustomPlayer> with WidgetsBindingObserver {
  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  VideoPlayerController _videoPlayerController2;
  ChewieController _chewieController;
  DateTime currentBackPressTime;


  void stopScreenLock() async{
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
    final updateScreensResponse = await http.post(APIData.updateScreensApi, body: {
      "macaddress": '$ip',
      "screen": '$screen',
      "count": '$count',
    }, headers: {
      // ignore: deprecated_member_use
      HttpHeaders.AUTHORIZATION: nToken == null ? fullData : nToken
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

  screenLogout() async {
    Wakelock.disable();
    final screenLogOutResponse = await http.post( APIData.screenLogOutApi, body: {
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


    if(accessToken.statusCode == 200){
      print("Logged In");
      var user = json.decode(accessToken.body);
      var newToken = "Bearer ${user['access_token']}";
      saveNewToken(newToken);
      getNewToken();
    }
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch(state){
      case AppLifecycleState.inactive:
        _chewieController.pause();
        debugPrint("Inactive");
        break;
      case AppLifecycleState.resumed:
        _chewieController.pause();
        if(userPaymentType != "Free"){
          updateScreens(myActiveScreen, fileContent["screenCount"]);
        }
        break;
      case AppLifecycleState.paused:
        _chewieController.pause();
        if(userPaymentType != "Free"){
          screenLogout();
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    this.stopScreenLock();
    setState(() {
      playerTitle = widget.title;
    });
    WidgetsBinding.instance.addObserver(this);
    print(widget.url);
    _videoPlayerController1 = VideoPlayerController.network(
        widget.url);
    _videoPlayerController2 = VideoPlayerController.network(widget.url);


    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      aspectRatio: 3/2,
      autoPlay: true,
      looping: true,
       materialProgressColors: ChewieProgressColors(
         playedColor: Colors.red,
         handleColor: Colors.red,
         backgroundColor: Colors.white.withOpacity(0.6),
         bufferedColor: Colors.white,
       ),
       placeholder: Container(
         color: Colors.black,
       ),
      // autoInitialize: true,
    );

    var r = _videoPlayerController1.value.aspectRatio;
    print("neeraj $r");
    String os = Platform.operatingSystem;

    if(os == 'android'){
      setState(() {
        _platform = TargetPlatform.android;
      });
    }else{
      setState(() {
        _platform = TargetPlatform.iOS;
      });
    }

  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Chewie(
                    controller: _chewieController,
                    title: widget.title,
                    downloadStatus: widget.downloadStatus,
                  ),
                ),
              ),
            ],
          ),
        ),
        onWillPop: onWillPopS);
  }
}