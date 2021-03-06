import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:nexthour/apidata/apidata.dart';
import 'package:nexthour/global.dart';
import 'package:nexthour/home.dart';
import 'package:nexthour/ui/login_page.dart';
import 'package:nexthour/ui/music_player.dart';

class IntroScreen extends StatefulWidget {
  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  Function goToTab;

  @override
  void initState() {
    super.initState();
    List.generate(homeDataBlocks == null ? 0 : homeDataBlocks.length, (int i) {
      return slides.add(
        new Slide(
          title: "${homeDataBlocks[i]['heading']}",
          styleTitle: TextStyle(
              color: redPrime.withOpacity(0.8),
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono'),
          description: "${homeDataBlocks[i]['detail']}",
          styleDescription: TextStyle(
              color: Colors.grey.withOpacity(0.8),
              fontSize: 16.0,
              fontStyle: FontStyle.normal,
              fontFamily: 'Raleway'),
          pathImage:
              "${APIData.landingPageImageUri}${homeDataBlocks[i]['image']}",
        ),
      );
    });
  }

//  WillPopScope to handle back press.
  Future<bool> onWillPopS() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press again to exit.");
      return Future.value(false);
    }
    audioPlayer.stop();
    return SystemNavigator.pop();
  }

//  Custom tabs
  List<Widget> renderListCustomTabs() {
    List<Widget> tabs = new List();
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: primaryColor.withOpacity(1.0),
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(0.0),
                      bottomLeft: Radius.circular(0.0)),
                  image: new DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.9), BlendMode.dstATop),
                    image: new NetworkImage(currentSlide.pathImage),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 2,
                  sigmaY: 2,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        child: Text(
                          currentSlide.title,
                          style: currentSlide.styleTitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        child: Text(
                          currentSlide.description,
                          style: currentSlide.styleDescription,
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                      ),
                    ],
                  ),
                  margin:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

// Intro slider
  Widget introSlider() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/bg.jpeg'), fit: BoxFit.cover),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Stack(
            children: [
              Positioned(
                child: Image.asset(
                  'assets/logo.png',
                  width: 250,
                ),
                top: 30,
                left: 15,
              ),
              Positioned(
                child: RaisedButton(
                  color: Colors.red,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (ctx) => LoginPage()));
                  },
                  child: Text('Start',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                bottom: 30,
                left: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: introSlider(), onWillPop: onWillPopS);
  }
}
